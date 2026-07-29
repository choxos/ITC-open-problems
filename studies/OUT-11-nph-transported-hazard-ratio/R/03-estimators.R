## ---------------------------------------------------------------------------
## The frequentist estimators. REWRITTEN after round three, which found a bug
## and a design error that between them invalidated the first pilot.
##
## WHAT WAS WRONG, BOTH FOUND BY A REVIEWER READING THE CODE
##
## 1. STC did not integrate over the target law at all. `STC_NODES` stored
##    Gauss-Hermite weights and the marginalization never used them, taking a
##    plain `mean` over the abscissas instead. Equal weighting of 32 Gauss-
##    Hermite nodes spans -9.48 to +10.68 and implies a covariate SD of 5.568
##    against a target of 1.000. Checked: E[S] came out 0.4609 equal-weighted
##    against 0.4753 both GH-weighted and by 4,000,000-draw Monte Carlo. Every
##    STC number in the first pilot was integrating over the wrong distribution,
##    including the "+0.383 non-collapsibility bias" that had been registered as
##    an anticipated mechanism. It was an artifact.
##
## 2. Forcing STC through the same marginal log-cumulative-hazard graft as MAIC
##    handicapped it before sampling. Marginalization is nonlinear, so a ratio
##    of MARGINAL cumulative hazards formed under the IPD study's baseline is
##    not transportable to a different baseline. MAIC has no way around that and
##    the graft is its own native limitation, declared. STC does: it has a
##    conditional structural model, so it can transport the CONDITIONAL
##    relationship to the target baseline and marginalize only at the end. Each
##    method now gets the strongest valid transport its own structure supports.
##
## A property of the registered DGM makes step 2 exact and is worth stating: the
## covariate has NO effect under placebo (verified: placebo survival at t=12 is
## 0.4356 at x = -2, 0 and +2), so it is a pure modifier of active versus
## placebo rather than a prognostic factor. The aggregate study's placebo arm
## therefore identifies the target baseline cumulative hazard directly. The code
## below does NOT assume this: it estimates the placebo covariate effect from
## the IPD and solves for the target baseline accordingly, so it stays correct
## if that effect is nonzero.
## ---------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(flexsurv); library(survival)
})
source("R/02-cox-limit.R")   # cox_project, the registered common functional

## Internal knots, Royston-Parmar side. Registered in R/00-config.R as N_KNOTS so
## the M-spline and the Royston-Parmar bases move together when the complexity
## arm varies them; the protocol registers that arm "for both bases", and until
## round 6 neither base could be reached from outside its own file.
RP_KNOTS <- N_KNOTS

## --- the target law, as a weighted quadrature rule ---------------------------
## One object, carrying nodes AND weights together, so the two can no longer be
## separated by accident. Every marginalization in this file goes through
## `marginalize()`; nothing calls `mean()` on conditional survival.
target_quad <- function(mu = MU_TGT, sd = SD_X, n = 32) {
  g <- gh_nodes(n)
  list(x = mu + sqrt(2) * sd * g$x, w = g$w / sqrt(pi))
}
marginalize <- function(S_by_node, q) as.vector(S_by_node %*% q$w)

## Guard: the quadrature rule must reproduce the target moments. Cheap, exact,
## and it fails loudly on the exact error that got through before.
verify_quad <- function(q, mu = MU_TGT, sd = SD_X, tol = 1e-8) {
  m <- sum(q$w * q$x); v <- sum(q$w * (q$x - m)^2)
  if (abs(sum(q$w) - 1) > tol || abs(m - mu) > 1e-6 || abs(sqrt(v) - sd) > 1e-6)
    stop(sprintf("target quadrature wrong: sum(w)=%.10f mean=%.6f sd=%.6f",
                 sum(q$w), m, sqrt(v)))
  invisible(TRUE)
}

## --- MAIC weights ------------------------------------------------------------
## Method-of-moments exponential tilt matching the target's first and second
## moments (Signorovitch et al. 2010, doi:10.2165/11538370-000000000-00000).
maic_weights <- function(x, mu_t, sd_t) {
  X <- cbind(x - mu_t, (x - mu_t)^2 - sd_t^2)
  obj <- function(a) sum(exp(X %*% a))
  gr  <- function(a) colSums(as.vector(exp(X %*% a)) * X)
  o <- optim(c(0, 0), obj, gr, method = "BFGS",
             control = list(maxit = 500, reltol = 1e-12))
  w <- as.vector(exp(X %*% o$par))
  list(w = w * length(w) / sum(w), ess = sum(w)^2 / sum(w^2),
       converged = o$convergence == 0)
}

## --- Royston-Parmar fits ------------------------------------------------------
rp_fit <- function(d, flexible, weights = NULL, covariate = FALSE, k = RP_KNOTS) {
  fml <- if (covariate) Surv(time, status) ~ trt01 + x1 + trt01:x1
         else           Surv(time, status) ~ trt01
  anc <- if (flexible)
    stats::setNames(rep(list(~ trt01), k + 1),
                    c("gamma1", paste0("gamma", seq_len(k) + 1))) else NULL
  args <- list(formula = fml, data = d, k = k, scale = "hazard")
  if (!is.null(weights)) args$weights <- weights
  if (!is.null(anc))     args$anc <- anc
  do.call(flexsurvspline, args)
}

## Conditional survival matrix: rows are times, columns are quadrature nodes.
## Returning the full matrix rather than a collapsed mean is what makes the
## weighting explicit at every call site.
rp_surv_nodes <- function(fit, tt, trt, xs) {
  nd <- data.frame(trt01 = trt, x1 = xs)
  S <- summary(fit, newdata = nd, t = tt, type = "survival", ci = FALSE,
               tidy = TRUE)
  matrix(S$est, nrow = length(tt), ncol = length(xs))
}
rp_surv_marginal_fit <- function(fit, tt, trt) {
  S <- summary(fit, newdata = data.frame(trt01 = trt), t = tt,
               type = "survival", ci = FALSE, tidy = TRUE)
  as.vector(S$est)
}

logH  <- function(S) log(pmax(-log(pmin(pmax(S, 1e-12), 1 - 1e-12)), 1e-12))
S_of  <- function(lh) exp(-exp(lh))

## --- STC: transport the CONDITIONAL model, marginalize last ------------------
## Sol's prescribed fix, implemented in the general form that does not assume
## the placebo covariate effect is zero.
##
##   1. Fit the conditional outcome model on the IPD. This gives conditional
##      log-cumulative-hazard for PBO and A as functions of t and x, under the
##      IPD study's baseline.
##   2. Read off the placebo covariate effect theta(t, x) = logH_PBO,ipd(t|x)
##      - logH_PBO,ipd(t|0), and the treatment effect
##      delta(t, x) = logH_A,ipd(t|x) - logH_PBO,ipd(t|x).
##   3. Solve for the TARGET baseline c(t) such that the implied marginal
##      placebo curve matches the aggregate study's observed one:
##         E_x[ exp(-exp(c(t) + theta(t,x))) ] = S_PBO,agd(t).
##      With no placebo covariate effect this collapses to
##      c(t) = log(-log S_PBO,agd(t)), which is why the step is cheap here.
##   4. Build the target conditional curve for A and marginalize ONCE, at the
##      end, with the correct quadrature weights.
stc_target_A <- function(fit_ipd, S_pbo_agd, tt, q) {
  lh_pbo_x <- logH(rp_surv_nodes(fit_ipd, tt, 0, q$x))    # times x nodes
  lh_A_x   <- logH(rp_surv_nodes(fit_ipd, tt, 1, q$x))
  theta <- lh_pbo_x - rowMeans(lh_pbo_x)                  # centered placebo x-effect
  delta <- lh_A_x - lh_pbo_x                              # conditional trt effect
  ct <- vapply(seq_along(tt), function(i) {
    target <- S_pbo_agd[i]
    f <- function(cc) sum(q$w * exp(-exp(cc + theta[i, ]))) - target
    lo <- -30; hi <- 10
    if (f(lo) * f(hi) > 0) return(logH(target))
    uniroot(f, c(lo, hi), tol = 1e-10)$root
  }, numeric(1))
  marginalize(S_of(ct + theta + delta), q)
}

## --- the shared RMST reduction ------------------------------------------------
rmst_of <- function(S, tt, tau = TAU)
  { i <- tt <= tau; sum(diff(tt[i]) * (head(S[i], -1) + tail(S[i], -1)) / 2) }

## INTERPOLATED AT THE REGISTERED TIMES, NOT SNAPPED TO THE NEAREST GRID POINT.
##
## Round 6 found that this took the nearest point of `seq(0.05, TAU,
## length.out = 200)`, so the values labeled t = 6 and t = 12 were evaluated at
## 6.0033 and 11.9565 and then compared against truths evaluated at exactly 6
## and 12. That folds a time-grid error into the reported calibration bias of
## registered primary outcome 4, and it is not small relative to the differences
## being reported: 0.0435 months of drift at t = 12.
## `edf` is the fitted model's effective degrees of freedom, registered in
## section 7.2 and absent from every checkpoint until round 6. On this side it is
## exact rather than estimated: a Royston-Parmar fit is maximum likelihood with no
## shrinkage, so the free-parameter count IS the degrees of freedom. The Bayesian
## rows report p_WAIC instead, for the reason given at `p_waic` in R/07-run.R.
pack <- function(S_A, S_B, tt, ess = NA_real_, edf = NA_real_) list(
  rmst_diff = rmst_of(S_B, tt) - rmst_of(S_A, tt),
  surv_diff = stats::approx(tt, S_B, xout = T_GRID, rule = 2)$y -
              stats::approx(tt, S_A, xout = T_GRID, rule = 2)$y,
  ## The registered common Cox projection, applied to THIS method's fitted
  ## target curves under the prespecified reference regime. Round 6 found the
  ## functional registered and applied to nothing.
  cox_hr = cox_project(tt, S_A, S_B, COX_PROJ_RATE, COX_PROJ_TADMIN),
  ess = ess, edf = edf)

## --- the estimators -----------------------------------------------------------
## `d$agd` carries NO individual covariate column; see sim_network. The
## aggregate study is observable only as reconstructed event times plus reported
## covariate summaries, which is what a published trial gives.
## EVERY METHOD USES THE PUBLISHED SUMMARIES, NOT THE SUPERPOPULATION VALUES.
##
## Round 6 found that MAIC and STC matched and marginalized to MU_TGT and SD_X,
## the true (0.60, 1.00), while ML-NMR's aggregate likelihood integrated over the
## REALIZED sample moments that `sim_network` computes from the generated
## aggregate patients. Target-summary sampling error therefore entered only the
## ML-NMR rows, and the protocol's claim that summaries are supplied "to every
## method as the true superpopulation values, identically" was false.
##
## The asymmetry is resolved toward the realistic side rather than the idealized
## one. An analyst has published moments, not superpopulation values: MAIC
## matches to what the paper reports, and ML-NMR integrates over a distribution
## fitted to what the paper reports. Giving the frequentist rows the true values
## was an advantage no analyst has. At 200 per arm the reported mean carries a
## standard error near 0.071 and the reported standard deviation near 0.050, and
## that noise is now shared by all seven rows.
##
## The TRUTH is still evaluated at the true target law, so all seven are scored
## against the same estimand.
published_moments <- function(d) {
  s <- d$agd_summ
  if (is.null(s)) return(list(mu = MU_TGT, sd = SD_X))
  ## Pooled across the aggregate study's arms, which is what a trial reports for
  ## its analysis population, weighted by arm size.
  list(mu = sum(s$x1_mean * s$n) / sum(s$n),
       sd = sqrt(sum((s$n - 1) * s$x1_sd^2) / (sum(s$n) - nrow(s))))
}

## `k` rides on the prep object rather than being read from the global, so a
## sensitivity arm that changes the knot count changes it for the aggregate-study
## fits built here and for the IPD fits built downstream, and cannot change one
## without the other.
prep <- function(d, tt, q, k = RP_KNOTS) {
  ipd <- transform(d$ipd, trt01 = as.integer(trt == "A"))
  agd <- transform(d$agd, trt01 = as.integer(trt == "B"))
  pm <- published_moments(d)
  list(ipd = ipd, agd = agd, tt = tt, q = q, mu_t = pm$mu, sd_t = pm$sd, k = k,
       agd_ph = rp_fit(agd, FALSE, k = k), agd_flex = rp_fit(agd, TRUE, k = k))
}

## MAIC keeps the marginal graft, because that is what MAIC is. Its
## approximation error under a different baseline is a property of the method
## and is reported as one, not engineered away.
est_maic <- function(p, flexible, mu_t = p$mu_t, sd_t = p$sd_t) {
  w <- maic_weights(p$ipd$x1, mu_t, sd_t)
  f <- rp_fit(p$ipd, flexible, weights = w$w, k = p$k)
  a <- if (flexible) p$agd_flex else p$agd_ph
  S_pbo <- rp_surv_marginal_fit(a, p$tt, 0)
  S_B   <- rp_surv_marginal_fit(a, p$tt, 1)
  dl <- logH(rp_surv_marginal_fit(f, p$tt, 1)) -
        logH(rp_surv_marginal_fit(f, p$tt, 0))
  pack(S_of(logH(S_pbo) + dl), S_B, p$tt, w$ess, length(stats::coef(f)))
}

est_stc <- function(p, flexible) {
  f <- rp_fit(p$ipd, flexible, covariate = TRUE, k = p$k)
  a <- if (flexible) p$agd_flex else p$agd_ph
  S_pbo <- rp_surv_marginal_fit(a, p$tt, 0)
  S_B   <- rp_surv_marginal_fit(a, p$tt, 1)
  pack(stc_target_A(f, S_pbo, p$tt, p$q), S_B, p$tt,
       edf = length(stats::coef(f)))
}

## "MAIC as practiced": weighted Cox with a Breslow baseline. Reported on its
## own; never used to define a column effect.
est_maic_cox <- function(p, mu_t = p$mu_t, sd_t = p$sd_t) {
  w  <- maic_weights(p$ipd$x1, mu_t, sd_t)
  cx <- coxph(Surv(time, status) ~ trt01, data = p$ipd, weights = w$w,
              robust = TRUE)
  S_pbo <- rp_surv_marginal_fit(p$agd_ph, p$tt, 0)
  S_B   <- rp_surv_marginal_fit(p$agd_ph, p$tt, 1)
  pack(S_of(logH(S_pbo) + unname(coef(cx))), S_B, p$tt, w$ess,
       length(stats::coef(cx)))
}

freq_all <- function(d, tt = seq(0.05, TAU, length.out = 200), q = NULL,
                     k = RP_KNOTS) {
  ## The quadrature rule STC marginalizes through is built on the PUBLISHED
  ## moments for the same reason the MAIC weights are, so no frequentist row
  ## reads a superpopulation value the analyst does not have. `q` is still an
  ## argument so a caller can pin the rule, but it is no longer the default.
  pm <- published_moments(d)
  if (is.null(q)) { q <- target_quad(pm$mu, pm$sd); verify_quad(q, pm$mu, pm$sd) }
  p <- prep(d, tt, q, k = k)
  list(`MAIC-PH`  = est_maic(p, FALSE), `MAIC-flex` = est_maic(p, TRUE),
       `STC-PH`   = est_stc(p, FALSE),  `STC-flex`  = est_stc(p, TRUE),
       `MAIC-Cox` = est_maic_cox(p))
}

## --- bootstrap ----------------------------------------------------------------
## Stratified by study and arm, which is what resampling a completed trial means.
##
## The resample INDICES are all drawn up front in the parent process and the
## fitting is then farmed out. Drawing them inside the workers would make the
## result depend on how many cores the machine happened to have, and this
## bootstrap feeds a registered primary outcome (interval coverage), so it has to
## reproduce exactly from the seed regardless of where it runs.
boot_indices <- function(d, n_boot) {
  grp <- function(z) split(seq_len(nrow(z)), list(z$study, z$trt), drop = TRUE)
  gi <- grp(d$ipd); ga <- grp(d$agd)
  lapply(seq_len(n_boot), function(b) list(
    ipd = unlist(lapply(gi, function(ix) sample(ix, length(ix), replace = TRUE))),
    agd = unlist(lapply(ga, function(ix) sample(ix, length(ix), replace = TRUE)))))
}

boot_apply <- function(d, ix) list(ipd = d$ipd[ix$ipd, ], agd = d$agd[ix$agd, ])

freq_boot <- function(d, n_boot = N_BOOT, tt = seq(0.05, TAU, length.out = 200),
                      cores = getOption("boot_cores", NULL), k = RP_KNOTS) {
  if (is.null(cores))
    cores <- if (exists("N_CORES_BOOT")) N_CORES_BOOT else 1L
  q <- target_quad(); verify_quad(q)
  base <- freq_all(d, tt, q, k = k); nm <- names(base)
  idx <- boot_indices(d, n_boot)
  ## THE SURVIVAL DIFFERENCES ARE KEPT, NOT DISCARDED.
  ##
  ## `pack` has computed surv_diff at T_GRID since version 3 and every version
  ## through 5 threw it away here, keeping only rmst_diff. Round 6 found that
  ## this made registered PRIMARY OUTCOME 4, "calibration over time: bias and
  ## pointwise 95% coverage of S_B(t) - S_A(t) at t in {6, 12, 18}", impossible
  ## to produce for any estimator. A grep for surv_diff across R/ returned one
  ## hit: its own definition.
  ##
  ## Each resample now returns one flat vector over estimator x quantity, so the
  ## same percentile machinery gives intervals for the survival differences and
  ## for RMST at once, at no extra fitting cost.
  qty <- c("rmst", sprintf("s%g", T_GRID), "cox")
  flat <- function(r) unlist(lapply(nm, function(k)
    c(r[[k]]$rmst_diff, r[[k]]$surv_diff, r[[k]]$cox_hr)))
  one <- function(ix) {
    r <- try(freq_all(boot_apply(d, ix), tt, q, k = k), silent = TRUE)
    if (inherits(r, "try-error")) return(NULL)
    flat(r)
  }
  reps <- if (cores > 1L && .Platform$OS.type != "windows")
    parallel::mclapply(idx, one, mc.cores = cores) else lapply(idx, one)
  reps <- do.call(rbind, Filter(Negate(is.null), reps))
  ci <- t(apply(reps, 2, quantile, c(0.025, 0.975), na.rm = TRUE))

  ## THE INNER MONTE CARLO ERROR OF THE ENDPOINTS, COMPUTED BEFORE THE DRAWS ARE
  ## DISCARDED.
  ##
  ## Protocol section 7.2 registers that "the inner Monte Carlo error of a
  ## 500-resample percentile interval is reported rather than assumed
  ## negligible", and round 6 found this function keeping only the endpoints and
  ## `n_ok`. The resample draws are the only object from which that error can be
  ## recovered, and they were thrown away one line later, so the registered
  ## quantity was unreconstructible from every checkpoint the run would write.
  ##
  ## Estimated by resampling the STORED resample values, which involves no model
  ## fitting at all: the expensive part of a bootstrap is producing the B
  ## statistics, and quantiles of a length-B numeric vector are free. The
  ## alternative, the asymptotic quantile formula sqrt(p(1-p)/B)/f(q_p), needs a
  ## density estimate at the endpoint, which is the least stable place to put
  ## one. `N_MCSE_REP` resamples of the resamples is enough for a standard error
  ## on a standard error, and the count is registered rather than chosen here.
  ##
  ## This is Monte Carlo error CONDITIONAL ON THE DATA: how much the interval
  ## would move if the same trial were bootstrapped again with a different
  ## resampling seed. It is not the sampling variability of the interval across
  ## replicates, which the run measures directly by having 40 of them.
  mcse_endpoints <- function(col) {
    v <- col[is.finite(col)]
    if (length(v) < 20) return(c(NA_real_, NA_real_))
    m <- replicate(N_MCSE_REP,
                   quantile(sample(v, length(v), replace = TRUE),
                            c(0.025, 0.975), names = FALSE))
    c(stats::sd(m[1, ]), stats::sd(m[2, ]))
  }
  mc <- t(apply(reps, 2, mcse_endpoints))

  ## Reshape the flat vector back to estimator x quantity. Column order is
  ## (estimator-major, quantity-minor) by construction in `flat`.
  shape <- function(v) matrix(v, nrow = length(nm), ncol = length(qty),
                              byrow = TRUE, dimnames = list(nm, qty))
  e <- shape(flat(base)); l <- shape(ci[, 1]); h <- shape(ci[, 2])
  ml <- shape(mc[, 1]); mh <- shape(mc[, 2])
  list(est = setNames(e[, "rmst"], nm),
       lo  = setNames(l[, "rmst"], nm),
       hi  = setNames(h[, "rmst"], nm),
       ## estimator x time, for primary outcome 4
       surv_est = e[, sprintf("s%g", T_GRID), drop = FALSE],
       surv_lo  = l[, sprintf("s%g", T_GRID), drop = FALSE],
       surv_hi  = h[, sprintf("s%g", T_GRID), drop = FALSE], t_grid = T_GRID,
       ## the registered common Cox projection, with a bootstrap interval
       cox_est = setNames(e[, "cox"], nm), cox_lo = setNames(l[, "cox"], nm),
       cox_hi = setNames(h[, "cox"], nm),
       ## inner Monte Carlo error of both endpoints, estimator x quantity, kept
       ## for every quantity rather than for RMST alone so the calibration-over-
       ## time and Cox intervals carry it too
       mcse_lo = ml, mcse_hi = mh, qty = qty,
       ## effective degrees of freedom per estimator, exact on this side
       edf = vapply(base, function(z) as.numeric(z$edf), 0),
       n_knots = k,
       n_ok = nrow(reps))
}
