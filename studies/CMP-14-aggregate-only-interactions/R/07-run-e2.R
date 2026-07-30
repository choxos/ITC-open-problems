## ---------------------------------------------------------------------------
## E2: does E1's conclusion survive a nonlinear link?
##
## Asymptotic, not fitted and not exact. A logistic likelihood is not conjugate,
## so the posterior has no closed form; what is closed form is the Fisher
## information, and from it the large-sample posterior covariance and a
## first-order expansion of the posterior mode's sampling distribution. Every
## coverage number below is a normal approximation and is labeled as one.
##
## WHAT E2 REPORTS, AND THE RESTRICTION THAT TURNED OUT TO BE UNNECESSARY.
##
## Round 3 found the coverage calculation invalid wherever the model is
## misspecified, and round 3's algebra was right: under genuine misspecification
## the score variance is not the model Fisher information, and for an aggregate
## arm mean the expected Hessian is not either, since its second-derivative term
## vanishes only when the fitted mean equals the true one. Coverage was therefore
## suppressed wherever discordance or synergy acted, which is 28 of 72 scenarios.
##
## ROUND 6 FOUND THE PREMISE FALSE. Neither departure is misspecification.
## Discordance adds `discord` to the target modification in the AGGREGATE rows
## carrying the target, and in `ecological` and `curvature` the target appears in
## no other row. Synergy adds `synergy` to arms holding components 1 and 3
## together, and in `additivity` the target appears in no other arm. In both cases
## every touched row carries the target and every target-bearing row is touched,
## so a SINGLE shifted coefficient reproduces every true arm probability:
##
##   true_p(theta_true; departure)  ==  model_p(theta_true + shift * e_target)
##
## exactly, to 5.6e-17 over the grid. The model is correctly specified everywhere
## and it is the ESTIMAND that is aliased: the likelihood identifies
## Gamma_W + shift while the study asks about Gamma_W. That is not a technical
## correction, it is the thesis. An aggregate-only route recovers a different
## quantity with a correctly sized interval around it, which is worse than a wide
## interval and is exactly what CMP-14 asks whether the summaries can detect.
##
## So COVERAGE IS NOW REPORTED ON EVERY SCENARIO, computed the ordinary way at the
## pseudo-true parameter theta* rather than suppressed. Nothing about round 3's
## algebra is retracted; it simply never applied. `evaluate_e2` ASSERTS the exact
## reproduction per scenario against E2_ALIAS_TOL rather than relying on the
## argument above, so a future state whose departure touched only some
## target-bearing rows would stop the run instead of silently reinstating the
## misspecification this section says is absent.
##
## The expansion, now used everywhere: with p_i(theta) the model's mean for row i,
## the MAP solves score(theta) = -P0 theta, and about theta*
##
##   theta_hat - theta*  ~=  (I* + P0)^{-1} [ U* - P0 theta* ],
##
## with U* the score at theta*, whose mean is EXACTLY zero because the model is
## correct there. So E[theta_hat] = theta* - (I* + P0)^{-1} P0 theta*, the bias
## against the registered estimand Gamma_W = theta*_g - shift is
##
##   bias = shift - [ (I* + P0)^{-1} P0 theta* ]_g,
##
## the aliasing and the prior shrinkage in one expression, and
## Var(theta_hat) = (I* + P0)^{-1} I* (I* + P0)^{-1}. At shift = 0 this reduces
## term by term to what the well-specified branch computed before, so the 44
## scenarios that already had coverage keep their values.
##
##   Rscript R/07-run-e2.R
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(MASS))
source("R/06-nonlinear.R")

## The intercept that puts the placebo arm at the registered prevalence, so the
## curvature the link supplies is the same in every scenario rather than drifting
## with the parameter values.
base_alpha <- function() log(E2_BASE_P / (1 - E2_BASE_P))

theta_true_nl <- function(b) {
  th <- theta_true(b)
  th[seq_len(b$S)] <- base_alpha()
  th
}

## The TRUE arm means, which the additive logistic model cannot reproduce
## wherever discordance or synergy acts. Discordance replaces Gamma_W by
## Gamma_W + discord in the AGGREGATE rows carrying the target; synergy adds an
## unmodeled modification to arms holding components 1 and 3 together.
true_p <- function(b, theta, discord, synergy) {
  gh <- gh_rule(64)
  vapply(seq_len(nrow(b$net)), function(i) {
    th_i <- theta
    if (!as.logical(b$net$ipd[i]) && b$C[i, TARGET] == 1)
      th_i[gi_of(b)] <- th_i[gi_of(b)] + discord
    extra <- if (b$C[i, 1] == 1 && b$C[i, TARGET] == 1) synergy else 0
    xs <- b$net$mu[i] + sqrt(2) * b$net$sd[i] * gh$x
    w  <- gh$w / sqrt(pi)
    eta <- vapply(xs, function(x) {
      r <- design_row(b$net, i, x, b$S, b$K)
      sum(r * th_i) + extra * x
    }, 0)
    sum(w * expit(eta))
  }, 0)
}

## HOW FAR THE SHIFTED MODEL IS FROM THE TRUTH, measured POINTWISE IN THE
## COVARIATE rather than on the arm mean. The distinction is not pedantry: an IPD
## arm contributes a per-individual likelihood, so aliasing there requires the two
## probability FUNCTIONS to agree at every x, and two different functions can
## share a mean. Checking the integrand rather than the integral makes the
## assertion cover the IPD rows the synergy departure acts on.
alias_gap_max <- function(b, theta, discord, synergy, shift) {
  gh <- gh_rule(64)
  th_star <- theta; th_star[gi_of(b)] <- th_star[gi_of(b)] + shift
  gaps <- vapply(seq_len(nrow(b$net)), function(i) {
    th_i <- theta
    if (!as.logical(b$net$ipd[i]) && b$C[i, TARGET] == 1)
      th_i[gi_of(b)] <- th_i[gi_of(b)] + discord
    extra <- if (b$C[i, 1] == 1 && b$C[i, TARGET] == 1) synergy else 0
    xs <- b$net$mu[i] + sqrt(2) * b$net$sd[i] * gh$x
    max(vapply(xs, function(x) {
      r <- design_row(b$net, i, x, b$S, b$K)
      abs(expit(sum(r * th_i) + extra * x) - expit(sum(r * th_star)))
    }, 0))
  }, 0)
  max(gaps)
}

## For an IPD arm the model's contribution is per-individual, so its "row" is the
## quadrature expansion; for an aggregate arm it is the single arm proportion.
## The displacement U is assembled over the same rows the information is.
displacement <- function(b, theta, discord, synergy) {
  U <- numeric(b$p)
  gh <- gh_rule(64)
  qt <- true_p(b, theta, discord, synergy)
  for (i in seq_len(nrow(b$net))) {
    if (as.logical(b$net$ipd[i])) {
      ## Individual data: the model is wrong only through synergy, which acts on
      ## the covariate, so the discrepancy varies with x and must be integrated.
      xs <- b$net$mu[i] + sqrt(2) * b$net$sd[i] * gh$x
      w  <- gh$w / sqrt(pi)
      extra <- if (b$C[i, 1] == 1 && b$C[i, TARGET] == 1) synergy else 0
      for (j in seq_along(xs)) {
        r <- design_row(b$net, i, xs[j], b$S, b$K)
        p_mod <- expit(sum(r * theta))
        p_tru <- expit(sum(r * theta) + extra * xs[j])
        U <- U + b$net$n[i] * w[j] * (p_tru - p_mod) * r
      }
    } else {
      pb <- agg_p(theta, b, i)
      g <- agg_grad(theta, b, i)
      U <- U + (b$net$n[i] / (pb * (1 - pb))) * g * (qt[i] - pb)
    }
  }
  U
}

evaluate_e2 <- function(row) {
  net <- build_state_nl(row$state, row$spread, row$sd_ratio, row$n)
  b <- build_design(net)
  th <- theta_true_nl(b)
  gi <- gi_of(b)
  P0 <- prior_precision(b, row$prior_sd)

  ## THE PSEUDO-TRUE PARAMETER, and the assertion that it is exact. The two
  ## departures never co-occur in the grid, so their sum is the shift.
  shift <- row$discord + row$synergy
  th_star <- th; th_star[gi] <- th_star[gi] + shift
  alias_gap <- alias_gap_max(b, th, row$discord, row$synergy, shift)
  if (alias_gap > E2_ALIAS_TOL)
    stop(sprintf(paste("scenario %d (%s, discord %.2f, synergy %.2f) is not",
                       "estimand aliasing: the shifted model misses the true arm",
                       "probabilities by %.3e, so the likelihood IS misspecified",
                       "here and the coverage calculation below does not apply"),
                 row$scenario, row$state, row$discord, row$synergy, alias_gap))

  ## Everything is evaluated at theta*, because that is where the data come from.
  ## On a logit link the information depends on the parameter, so the diagnostics
  ## move with the shift too; that is a property of the design under the truth,
  ## not a choice.
  inf <- logit_info(b, th_star)
  I <- inf$total
  A <- solve(I + P0)
  bias <- shift - as.vector(A %*% (P0 %*% th_star))[gi]
  v_samp <- (A %*% I %*% A)[gi, gi]
  sd_post <- sqrt(A[gi, gi])
  z <- stats::qnorm(1 - (1 - NOMINAL) / 2)
  cov <- {
    lo <- (-bias - z * sd_post) / sqrt(v_samp)
    hi <- (-bias + z * sd_post) / sqrt(v_samp)
    stats::pnorm(hi) - stats::pnorm(lo)
  }

  ## The same four diagnostics, read off the logit information. Every precision
  ## here is PRIOR-FREE after round 3; see `lik_marginal_precision`.
  contraction <- sd_post / row$prior_sd
  target_ratio <- lik_marginal_precision(I, gi) / P0[gi, gi]
  er <- eff_rank(I, P0, thresh = EFF_RATIO_OK)
  u <- numeric(b$p); u[gi] <- 1
  estimable <- sum(abs(I %*% (MASS::ginv(I) %*% u) - u)) < 1e-6

  ## The flattened design, which removes the between-study contrast in covariate
  ## SDs while leaving the contrast in means. Round 3 showed the previous version
  ## subtracted two prior-regularized aggregate-only precisions, both of which are
  ## exactly zero prior-free, and reported their ratio as this study's headline.
  ## The well-posed question is leave-one-source-out on the FULL information,
  ## which does identify the target.
  net_flat <- net
  net_flat$sd[!as.logical(net_flat$ipd)] <-
    mean(net_flat$sd[!as.logical(net_flat$ipd)])
  b_flat <- build_design(net_flat)
  th_flat <- theta_true_nl(b_flat)
  th_flat[gi_of(b_flat)] <- th_flat[gi_of(b_flat)] + shift
  inf_flat <- logit_info(b_flat, th_flat)
  ss <- source_shares(I, inf$within, inf_flat$total, gi)
  w_in <- lik_marginal_precision(inf$within, gi)
  w_bt <- lik_marginal_precision(inf$between, gi)

  cbind(row, data.frame(
    contraction = contraction, target_ratio = target_ratio,
    eff_rank = er$eff_rank, estimable = estimable,
    prec_within = w_in, prec_between = w_bt, prec_full = ss$full,
    surv_between = ss$surv_between, surv_sd = ss$surv_sd,
    bias = bias, post_sd = sd_post, samp_sd = sqrt(v_samp),
    coverage = cov, aliased = shift != 0, alias_shift = shift,
    alias_gap = alias_gap,
    stringsAsFactors = FALSE)) |>
    transform(failed = coverage < COVER_BAD)
}

rng_or_na <- function(x, f) {
  x <- x[!is.na(x)]
  if (!length(x)) NA_real_ else round(f(x), 3)
}

build_grid_e2 <- function() {
  g <- expand.grid(state = E2_STATES, spread = E2_SPREADS,
                   sd_ratio = E2_SD_RATIO, discord = E2_DISCORD,
                   n = E2_TOTAL_N, prior_sd = E2_PRIOR_SD,
                   synergy = E2_SYNERGY,
                   KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  ## Same structural restrictions as E1, plus one for the new factor: the SD
  ## ratio acts only on `curvature`, and the between-study mean spread does not
  ## act on it at all, since that state holds the means equal by construction.
  g <- g[!(g$synergy != 0 & g$state != "additivity"), ]
  g <- g[!(g$discord != 0 & !g$state %in% c("ecological", "curvature")), ]
  g <- g[!(g$sd_ratio != 1 & g$state != "curvature"), ]
  g <- g[!(g$state == "curvature" & g$spread != E2_SPREADS[1]), ]
  rownames(g) <- NULL
  g$scenario <- seq_len(nrow(g))
  g
}

main <- function() {
  g <- build_grid_e2()
  cat(sprintf("E2: %d registered scenarios on a %s link\n", nrow(g), E2_LINK))
  res <- do.call(rbind, lapply(seq_len(nrow(g)), function(i) evaluate_e2(g[i, ])))
  rownames(res) <- NULL

  ## THE NEGATIVE CONTROL FOR THE NEW STATE. Equal aggregate SDs must identify
  ## nothing, or `curvature` is not a curvature route at all and the state is
  ## withdrawn. This is the control round 1's finding made necessary.
  eq <- res[res$state == "curvature" & res$sd_ratio == 1, ]
  if (nrow(eq) && any(eq$estimable))
    stop("the curvature state is estimable with EQUAL aggregate SDs in ",
         sum(eq$estimable), " scenarios; the registered mechanism is wrong and ",
         "the state must be withdrawn")
  ne <- res[res$state == "curvature" & res$sd_ratio > 1, ]
  if (nrow(ne) && !all(ne$estimable))
    stop("the curvature state is NOT estimable with unequal aggregate SDs; the ",
         "registered mechanism is wrong")

  saveRDS(res, "results/e2.rds")
  cat(sprintf("written: results/e2.rds  (%d rows)\n\n", nrow(res)))
  cat("coverage and contraction by state, logit link:\n")
  print(do.call(rbind, lapply(split(res, res$state), function(z) data.frame(
    state = z$state[1], n = nrow(z),
    cover_min = round(min(z$coverage), 3),
    cover_max = round(max(z$coverage), 3),
    contract_min = round(min(z$contraction), 4),
    contract_max = round(max(z$contraction), 4),
    ## `absent` identifies the target from nothing, so its share is NA in every
    ## row and min/max over an empty vector would print Inf and -Inf as though
    ## they were measurements.
    surv_between_min = rng_or_na(z$surv_between, min),
    surv_between_max = rng_or_na(z$surv_between, max)))),
    row.names = FALSE)
}

if (!interactive() && Sys.getenv("E2_NOMAIN") == "") main()

## --- the three registered rules, evaluated rather than eyeballed -------------
## Section 7 of the protocol registers exactly what E2 must show for E1's
## conclusion to be withdrawn. Those conditions are checked here so the verdict
## is arithmetic, and so a reader can see it was not reached by looking at a
## table of ranges and forming an impression.
e2_verdict <- function(res) {
  ## ROUND 3 REBUILT THIS. The first version checked contraction and the
  ## per-parameter ratio only, never the whole-model effective-rank count, so one
  ## of the two summaries CMP-14 actually asks for controlled no decision. It also
  ## compared a coverage-filtered subset, keeping failing aggregate rows and
  ## nominal additivity rows and discarding the rest, so a registered separation
  ## could occur among the discarded rows without triggering withdrawal. And it
  ## let equal-SD curvature rows into the curvature comparisons although the
  ## protocol says those contain no curvature identification at all.
  ##
  ## Separation is a property of the diagnostics and the design, not of coverage,
  ## so the rule now compares the COMPLETE per-state distribution of each
  ## diagnostic over every registered row of that state, with the equal-SD
  ## curvature rows excluded from the curvature side because the protocol
  ## registers them as identifying nothing.
  rows_for <- function(st) {
    z <- res[res$state == st, ]
    if (st == "curvature") z <- z[z$sd_ratio > 1, ]
    z
  }
  ## Separable if the two states' value ranges do not overlap at all: some
  ## threshold puts every member of one on one side and every member of the other
  ## on the other. Direction-free, because a summary that inverted would still be
  ## a summary that separates.
  separates <- function(stat, s1, s2) {
    a <- rows_for(s1)[[stat]]; b <- rows_for(s2)[[stat]]
    a <- a[is.finite(a)]; b <- b[is.finite(b)]
    if (!length(a) || !length(b)) return(NA)
    min(a) > max(b) || min(b) > max(a)
  }
  grid <- expand.grid(
    stat = c("contraction", "target_ratio", "eff_rank"),
    against = c("ecological", "curvature"),
    stringsAsFactors = FALSE)
  rules <- do.call(rbind, lapply(seq_len(nrow(grid)), function(i) data.frame(
    rule = sprintf("%s separates additivity from %s", grid$stat[i],
                   grid$against[i]),
    separates = separates(grid$stat[i], "additivity", grid$against[i]),
    stringsAsFactors = FALSE)))

  ## The source-share condition, on the prior-free leave-one-source-out statistic.
  cs <- unique(rows_for("curvature")$surv_sd)
  es <- unique(rows_for("ecological")$surv_sd)
  cs <- cs[!is.na(cs)]; es <- es[!is.na(es)]
  list(rules = rules,
       withdraw_e1 = isTRUE(any(rules$separates)),
       curvature_share = unique(rows_for("curvature")$surv_between[
         !is.na(rows_for("curvature")$surv_between)]),
       ecological_share = unique(rows_for("ecological")$surv_between[
         !is.na(rows_for("ecological")$surv_between)]),
       surv_between_is_constructional = FALSE,
       surv_sd_curvature = if (length(cs)) range(cs) else NA,
       surv_sd_ecological = if (length(es)) range(es) else NA,
       surv_sd_separates = length(cs) > 0 && length(es) > 0 &&
         (min(cs) > max(es) || min(es) > max(cs)))
}

if (!interactive() && Sys.getenv("E2_NOMAIN") == "") {
  res <- readRDS("results/e2.rds")
  v <- e2_verdict(res)
  cat("\n=== the registered withdrawal rules ===\n")
  print(v$rules, row.names = FALSE)
  cat(sprintf("\nE1's conclusion is withdrawn: %s\n", v$withdraw_e1))
  cat(sprintf(paste("coverage reported for %d of %d scenarios; %d carry an",
                    "aliased estimand, worst reproduction gap %.2e\n"),
              sum(!is.na(res$coverage)), nrow(res), sum(res$aliased),
              max(res$alias_gap)))
  stopifnot("a scenario has no coverage, which the aliasing result says cannot
             happen since the model is correctly specified everywhere"
              = !any(is.na(res$coverage)),
            "a scenario's departure is not exact aliasing"
              = max(res$alias_gap) <= E2_ALIAS_TOL)
  cat(sprintf("source share, curvature: %s | ecological: %s | separates them: %s\n",
              paste(v$curvature_share, collapse = ", "),
              paste(v$ecological_share, collapse = ", "),
              v$share_separates_curvature))
  ## --- PLACEBO PREVALENCE IS 0.3 AT x = 0, NOT IN THE ARM --------------------
  ##
  ## The protocol said "placebo arms sit at prevalence 0.3". The code sets
  ## alpha = logit(0.3), the CONDITIONAL risk at x = 0. On a curved link the
  ## arm-level prevalence is the covariate distribution integrated through expit,
  ## so it depends on the study's covariate mean and SD and equals 0.3 nowhere.
  ##
  ## That is a labelling error with a consequence, and the consequence is why it
  ## earns a guard rather than a word change. The curvature state's registered
  ## restriction is EQUAL TARGET-STUDY BASELINES. Its two target studies share an
  ## INTERCEPT and differ in covariate SD, so their arm-level PREVALENCES differ.
  ## Read as prevalence the state fails its own restriction; read as the
  ## intercept, which is what the rank calculation uses, it holds. The document
  ## now says intercept, and this asserts that the intercept is what is equal and
  ## that the two readings really do differ.
  pbo_prev <- unlist(lapply(E2_STATES, function(s) {
    net <- build_state_nl(s, spread = 0.6, sd_ratio = 2.0, total_n = 3000L)
    b <- build_design(net); th <- theta_true_nl(b)
    vapply(which(rowSums(abs(b$C)) == 0), function(i) agg_p(th, b, i), 0)
  }))
  cv <- build_state_nl("curvature", spread = 0.6, sd_ratio = 2.0, total_n = 3000L)
  bcv <- build_design(cv); thcv <- theta_true_nl(bcv)
  cv_alpha <- thcv[unique(bcv$net$study[!as.logical(bcv$net$ipd)])]
  cv_prev <- vapply(which(rowSums(abs(bcv$C)) == 0 & !as.logical(bcv$net$ipd)),
                    function(i) agg_p(thcv, bcv, i), 0)
  cat(sprintf("\nplacebo conditional risk at x=0: %.4f\n", 0.3))
  cat(sprintf("placebo ARM prevalence across states: %.4f to %.4f\n",
              min(pbo_prev), max(pbo_prev)))
  cat(sprintf("curvature target arm prevalences: %s\n",
              paste(sprintf("%.4f", cv_prev), collapse = ", ")))
  cat(sprintf("curvature target intercepts equal: %s\n",
              length(unique(round(cv_alpha, 12))) == 1L))
  stopifnot(
    "placebo arm prevalence is exactly 0.3 somewhere, so the wording this guard
     replaced was defensible and the guard tests the wrong thing"
      = !any(abs(pbo_prev - 0.3) < 1e-9),
    "curvature's target studies no longer share an intercept, which is the
     restriction its equal-SD non-identifiability claim needs"
      = length(unique(round(cv_alpha, 12))) == 1L,
    "curvature's target arm prevalences are equal, so the intercept-versus-
     prevalence distinction this guard exists to make has stopped existing"
      = length(unique(round(cv_prev, 9))) > 1L)
  v$pbo_prev_min <- min(pbo_prev)
  v$pbo_prev_max <- max(pbo_prev)
  v$curv_pbo_prev <- sort(cv_prev)

  saveRDS(v, "results/e2-verdict.rds")
  cat("written: results/e2-verdict.rds\n")
}
