## ---------------------------------------------------------------------------
## Choose the integration order by MEASURING it on this study's own network.
##
## The previous protocol cited IDN-05's finding that moving from 64 to 256
## integration points flipped 8.3% of its verdicts, and then chose 32 points. A
## critique pointed out that this is backwards: 32 is BELOW the order IDN-05
## found insufficient, so the citation argues against the choice it was used to
## justify. IDN-05 also explicitly recorded that 256 was not itself shown to be
## converged, so it is not an accuracy reference either.
##
## The fix is not a better citation. It is a measurement: fit the same replicate
## at 32, 64, 128 and 256 points, compare the target-standardized RMST
## difference against the highest order, and register the lowest order whose
## error is small relative to the Monte Carlo noise the run will carry anyway.
## Timing is recorded in the same pass so the runtime estimate is auditable.
## ---------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(multinma); library(dplyr); library(survival)
})
## Stan is already parallel over chains; BLAS threads on top of that oversubscribe
## the 4 performance cores and run everything at a fraction of speed.
do.call(Sys.setenv, as.list(setNames(rep("1", 6),
  c("OMP_NUM_THREADS", "VECLIB_MAXIMUM_THREADS", "OPENBLAS_NUM_THREADS",
    "MKL_NUM_THREADS", "RCPP_PARALLEL_NUM_THREADS", "STAN_NUM_THREADS"))))

source("R/00-config.R")
source("R/01-dgm.R")

## --- one simulated network, exactly as the run will build it ------------------
## kappa_a is an explicit argument as of version 4. It was previously read from
## the KAPPA_A global, which would have silently run the new ipd-nph cells at
## zero and reproduced exactly the defect round three found: all the
## non-proportionality sitting on the side of the network where MAIC and STC do
## not act.
sim_network <- function(seed, family = "weibull", kappa_b = 0.30, gamma = GAMMA,
                        beta_b = -0.1431, cens = E3_CENS[1, ],
                        kappa_a = KAPPA_A) {
  set.seed(seed)
  arm_rows <- function(study_key, sid, trt, n, mu, rate) {
    a <- make_arm(family, study_key,
                  beta  = switch(trt, PBO = 0, A = BETA_A,  B = beta_b),
                  kappa = switch(trt, PBO = 0, A = kappa_a, B = kappa_b),
                  gamma = switch(trt, PBO = 0, gamma))
    x <- rnorm(n, mu, SD_X)
    cbind(study = sid, trt = trt, sim_arm(n, x, a, rate, cens$t_admin))
  }
  ipd <- rbind(arm_rows("ipd", "S1", "PBO", N_IPD_ARM, MU_IPD, cens$rate_ipd),
               arm_rows("ipd", "S1", "A",   N_IPD_ARM, MU_IPD, cens$rate_ipd))
  agd <- rbind(arm_rows("tgt", "S2", "PBO", N_AGD_ARM, MU_TGT, cens$rate_agd),
               arm_rows("tgt", "S2", "B",   N_AGD_ARM, MU_TGT, cens$rate_agd))

  ## WHAT AN AGGREGATE STUDY ACTUALLY PUBLISHES, ENFORCED STRUCTURALLY.
  ##
  ## Round three found that the "aggregate" study was being analyzed as
  ## individual patient data: flexsurvspline was fitted straight to its records
  ## and individuals were bootstrapped from it. Reconstructed pseudo-individual
  ## event times ARE observable, because Kaplan-Meier curves are published and
  ## digitization is declared exact and out of scope. Individual COVARIATE
  ## values are not: a published trial reports covariate means and standard
  ## deviations, never the per-patient values.
  ##
  ## The x1 column is therefore dropped from the aggregate data and the
  ## summaries are computed here, once, at generation time. Any estimator that
  ## reaches for an aggregate individual covariate now fails loudly instead of
  ## quietly using information it could not have.
  summ <- do.call(rbind, lapply(split(agd, agd$trt), function(g) data.frame(
    study = g$study[1], trt = g$trt[1],
    x1_mean = mean(g$x1), x1_sd = sd(g$x1), n = nrow(g),
    stringsAsFactors = FALSE)))
  agd$x1 <- NULL
  list(ipd = ipd, agd = agd, agd_summ = summ)
}

## The aggregate study supplies reconstructed patient-level times and status
## (digitization assumed exact, declared out of scope) plus per-arm covariate
## summaries. Both treatments sit in one class, so the covariate interaction is
## SHARED across A and B: that is the anchored assumption MAIC and STC require,
## and putting ML-NMR on the same assumption is what makes the rows comparable.
build_net <- function(d, n_int) {
  cls <- c(PBO = "PBO", A = "active", B = "active")
  ipd <- transform(d$ipd, .trtclass = cls[as.character(trt)])
  agd <- transform(d$agd, .trtclass = cls[as.character(trt)])
  ## Covariate summaries come from what the aggregate study reports, not from
  ## its individual records, which no longer exist in `d$agd`.
  covs <- d$agd_summ[, c("study", "trt", "x1_mean", "x1_sd")]
  net <- combine_network(
    set_ipd(ipd, study = study, trt = trt, trt_class = .trtclass,
            Surv = Surv(time, status)),
    set_agd_surv(agd, study = study, trt = trt, trt_class = .trtclass,
                 Surv = Surv(time, status), covariates = covs))
  add_integration(net, x1 = distr(qnorm, x1_mean, x1_sd), n_int = n_int)
}

## THE FLEXIBLE ARM IS NOT `aux_by = c(.study, .trt)`, AND FINDING THAT OUT IS
## A RESULT.
##
## The OUT-11 catalog entry, and the previous version of this protocol, both
## name `aux_by = c(.study, .trt)` as the way to relax proportional hazards in a
## survival ML-NMR. That is correct for the WITHIN-STUDY fit and silently unable
## to transport. Stratifying the baseline hazard by study-arm makes each arm's
## spline a free parameter attached to a study that observed that arm, with no
## rule connecting it to a population where the arm was never given. Asked for a
## target-standardized prediction, multinma can only return the treatments whose
## auxiliary parameters exist in the named study: `aux = "S2"` returns PBO and
## B, `aux = "S1"` returns PBO and A, and there is no run in which A and B are
## both standardized to the target. The absolute values it does return are
## nonsense (RMST 3.3 and 4.6 months against a placebo of 14.7), and multinma
## emits a note pointing at `aux_regression` instead.
##
## `aux_regression = ~ .trt` is the specification that transports: the spline
## coefficients become a regression on treatment, so the SHAPE of a treatment's
## hazard is a shared, transportable function rather than a per-study-arm free
## parameter. All three treatments are then predicted in the target population.
## iter and adapt_delta are arguments so the REGISTERED refit escalation can
## actually be performed. Version 4's protocol registered "refit once at doubled
## iterations with adapt_delta = 0.99" while the fitting functions hardcoded
## both, so the escalation could not have run.
##
## `n_knots` and `prior_mult` are arguments for the same reason, and for a defect
## found one round later. The protocol registers a knot-complexity arm at 2 and 5
## internal knots and a prior arm that halves and doubles the interaction and
## auxiliary scales; both settings were hardcoded here, so neither arm could have
## been run either. `prior_mult` scales exactly the two families the protocol
## names, the covariate interaction and the auxiliaries, and leaves the
## intercept and treatment-effect priors at their registered normal(0, 10),
## because those are not what the arm varies.
fit_flex <- function(net, iter = N_ITER, adapt_delta = 0.8,
                     n_knots = N_KNOTS, prior_mult = 1) nma(net,
  likelihood = "mspline", n_knots = n_knots,
  trt_effects = "fixed", regression = ~ x1:.trtclass, class_interactions = "common",
  aux_regression = ~ .trt,
  prior_intercept = normal(0, 10), prior_trt = normal(0, 10),
  prior_reg = normal(0, prior_mult * PRIOR_REG_SD),
  prior_aux = half_normal(prior_mult * PRIOR_AUX_SD),
  prior_aux_reg = normal(0, prior_mult * PRIOR_AUX_REG_SD),
  chains = N_CHAINS, iter = iter, warmup = iter / 2, refresh = 0, cores = N_CHAINS,
  control = list(adapt_delta = adapt_delta))
## The proportional arm shares one baseline hazard within a study across its
## arms, so the treatment effect is a constant log hazard ratio. `aux_by` takes
## unevaluated column specials and cannot be chosen with an if/else, so the two
## calls are written out rather than parameterized.
fit_ph <- function(net, iter = N_ITER, adapt_delta = 0.8,
                   n_knots = N_KNOTS, prior_mult = 1) nma(net,
  likelihood = "mspline", n_knots = n_knots,
  trt_effects = "fixed", regression = ~ x1:.trtclass, class_interactions = "common",
  aux_by = c(.study),
  prior_intercept = normal(0, 10), prior_trt = normal(0, 10),
  prior_reg = normal(0, prior_mult * PRIOR_REG_SD),
  prior_aux = half_normal(prior_mult * PRIOR_AUX_SD),
  chains = N_CHAINS, iter = iter, warmup = iter / 2, refresh = 0, cores = N_CHAINS,
  control = list(adapt_delta = adapt_delta))

## The target population: the aggregate study's own covariate law, as an analyst
## would have it, i.e. from its reported mean and SD.
target_newdata <- function(d, n_int) {
  nd <- data.frame(study = "S2", x1_mean = MU_TGT, x1_sd = SD_X)
  add_integration(nd, x1 = distr(qnorm, x1_mean, x1_sd), n_int = n_int)
}

## Target-standardized RMST difference B versus A at TAU. Both arms are
## predicted in the SAME population off the SAME baseline, which is the only
## reading under which all six estimators target the same quantity.
## The target-standardized SURVIVAL difference at each registered time, which is
## registered primary outcome 4 and which nothing produced for the two ML-NMR
## rows until round 6: this path predicted `type = "rmst"` only, so no survival
## quantity existed for them at any time point. Returns a draws-by-time matrix,
## so bias and pointwise coverage both come from the same object.
target_surv_diff <- function(fit, nd, times = T_GRID) {
  p <- predict(fit, newdata = nd, baseline = "S2", aux = "S2",
               type = "survival", times = times, level = "aggregate",
               summary = FALSE)
  s <- p$sims; nm <- dimnames(s)[[3]]
  ## A survival prediction names its parameters `pred[New 1: B, 3]`, with the
  ## time index after the treatment, where an RMST prediction names them
  ## `pred[New 1: B]`. Matching the RMST pattern here found zero columns, so the
  ## layout is parsed rather than assumed: select on the treatment, then order by
  ## the time index parsed out of the name, so a change in multinma's column
  ## order cannot silently pair the wrong times.
  cols <- function(k) {
    j <- grep(sprintf(": %s, ", k), nm, fixed = TRUE)
    if (length(j) != length(times))
      stop(sprintf("expected %d '%s' columns, found %d in: %s", length(times),
                   k, length(j), paste(head(nm, 6), collapse = ", ")))
    j[order(as.integer(sub(".*,\\s*(\\d+)\\]$", "\\1", nm[j])))]
  }
  j_a <- cols("A"); jb <- cols("B")
  out <- vapply(seq_along(times),
                function(i) as.numeric(s[, , jb[i]]) - as.numeric(s[, , j_a[i]]),
                numeric(prod(dim(s)[1:2])))
  colnames(out) <- sprintf("s%g", times)
  ## DIAGNOSTICS PER TIME, because the registered sampler policy binds on "the
  ## derived estimand, the target-standardized RMST and the survival differences
  ## on the time grid" and round 6 found it was evaluated on RMST alone. A
  ## survival difference can mix badly, or fail to be produced at all, while the
  ## RMST it integrates mixes fine, and the pointwise intervals this study
  ## reports at each time come from exactly these draws.
  dm <- dim(s)[1:2]
  attr(out, "rhat")     <- vapply(seq_along(times), function(i)
    posterior::rhat(array(out[, i], dim = dm)), 0)
  attr(out, "ess_bulk") <- vapply(seq_along(times), function(i)
    posterior::ess_bulk(array(out[, i], dim = dm)), 0)
  attr(out, "ess_tail") <- vapply(seq_along(times), function(i)
    posterior::ess_tail(array(out[, i], dim = dm)), 0)
  out
}

## The registered common Cox projection for an ML-NMR fit: the posterior mean
## target survival curve for each active arm, put through the same functional the
## frequentist rows use and the same one E1 applies to the known truth.
target_cox_hr <- function(fit, nd, n_grid = COX_PROJ_NGRID) {
  tt <- seq(TAU / n_grid, T_ADMIN, length.out = n_grid)
  p <- predict(fit, newdata = nd, baseline = "S2", aux = "S2",
               type = "survival", times = tt, level = "aggregate",
               summary = FALSE)
  s <- p$sims; nm <- dimnames(s)[[3]]
  curve <- function(k) {
    j <- grep(sprintf(": %s, ", k), nm, fixed = TRUE)
    if (length(j) != length(tt)) return(NULL)
    j <- j[order(as.integer(sub(".*,\\s*(\\d+)\\]$", "\\1", nm[j])))]
    vapply(j, function(cl) mean(as.numeric(s[, , cl])), 0)
  }
  sa <- curve("A"); sb <- curve("B")
  if (is.null(sa) || is.null(sb)) return(NA_real_)
  cox_project(tt, sa, sb, COX_PROJ_RATE, COX_PROJ_TADMIN)
}

target_rmst_diff <- function(fit, nd) {
  p <- predict(fit, newdata = nd, baseline = "S2", aux = "S2",
               type = "rmst", times = TAU, level = "aggregate", summary = FALSE)
  ## summary = FALSE returns an object carrying `$sims`, an
  ## iterations x chains x parameters array; flatten the first two.
  s <- p$sims
  nm <- dimnames(s)[[3]]
  gi <- function(k) {
    j <- grep(sprintf(": %s]", k), nm, fixed = TRUE)
    if (length(j) != 1L) stop(sprintf("expected 1 '%s' column, found %d in: %s",
                                      k, length(j), paste(nm, collapse = ", ")))
    as.numeric(s[, , j])
  }
  d <- gi("B") - gi("A")
  ## The Monte Carlo error of THIS quantity is what decides whether an
  ## order-to-order difference is quadrature error or sampler noise, so it is
  ## attached here rather than approximated later from a global minimum ESS
  ## over unrelated nuisance parameters.
  m <- array(d, dim = dim(s)[1:2])
  attr(d, "ess")  <- posterior::ess_bulk(m)
  ## TAIL ESS IS COMPUTED HERE BECAUSE THE REGISTERED SAMPLER POLICY BINDS ON IT
  ## AND NOTHING WAS EVALUATING IT. Protocol section 7.2 registers "bulk and tail
  ## ESS >= 400 on the derived estimand". R/07-run.R was filling `ess_tail` with
  ## this bulk value, so the pass criterion tested bulk twice and the tail
  ## criterion had never run. It is the binding one for the outputs that depend on
  ## it: the interval this study reports comes from the 2.5% and 97.5% quantiles
  ## of exactly this vector, and coverage of that interval is a registered
  ## outcome, so tail mixing is what decides whether that outcome means anything.
  attr(d, "ess_tail") <- posterior::ess_tail(m)
  attr(d, "mcse") <- posterior::mcse_mean(m)
  attr(d, "rhat") <- posterior::rhat(m)
  d
}

## --- the calibration ----------------------------------------------------------
## A first pass at 3 replicates over 32/64/128/256 could not support a
## conclusion, and noticing that is the point of running it. Each order is a
## SEPARATE MCMC run, so the difference between two orders carries the Monte
## Carlo error of both. At the observed posterior SD near 0.75 and ESS near 250,
## each posterior mean has a Monte Carlo standard error near 0.047, and the
## order-to-order differences were 0.02 to 0.07. The measurement was therefore
## the same size as its own noise, and the monotone pattern across two
## replicates was suggestive rather than decisive.
##
## The fix is pairing and replication, not a longer stare at two numbers: the
## orders are compared ON THE SAME SIMULATED DATA within a replicate, and the
## replicate count is set so the PAIRED difference has a standard error well
## below the effect that would change the decision. Eight replicates give a
## paired standard error near 0.024 against differences near 0.05.
ORDERS <- as.numeric(strsplit(Sys.getenv("ORDERS", "32,64,128,256"), ",")[[1]])
## REP_OFFSET lets an interrupted probe resume rather than repeat replicates it
## already paid for. The seed is SEED + r, so offsetting r gives fresh networks
## that pool with the earlier ones rather than duplicating them.
## ARMS is a design factor as of version 5. The probe previously fitted only
## the FLEXIBLE arm, which left an unmeasured hole: if quadrature error differs
## between the proportional and flexible ML-NMR arms, it does not cancel from
## MLNMR-PH versus MLNMR-flex, and that contrast is a registered PRIMARY
## outcome. Measuring both arms bounds the integration component of the one
## comparison the design exists to make.
ARMS <- strsplit(Sys.getenv("ARMS", "flex"), ",")[[1]]

## An elapsed time means nothing without the machine load that produced it. A
## previous "production" measurement on this machine came out about twice its
## true cost because a probe was still running that a bad process filter had
## missed, and that inflated number then justified a design decision. Recording
## the conditions next to the number costs one system call.
machine_load <- function() {
  la <- try(as.numeric(strsplit(sub(".*averages?: ", "",
              system("uptime", intern = TRUE)), "[ ,]+")[[1]][1]), silent = TRUE)
  if (inherits(la, "try-error") || length(la) != 1L || !is.finite(la))
    NA_real_ else la
}

main <- function(n_rep = 3, offset = as.integer(Sys.getenv("REP_OFFSET", "0"))) {
  out <- list()
  path <- Sys.getenv("PROBE_OUT", "results/integration-calibration.rds")
  ## Resume from whatever a killed run already paid for, keyed on the full
  ## (rep, n_int, arm) triple.
  if (file.exists(path)) {
    prev <- readRDS(path)
    if (is.null(prev$arm)) prev$arm <- "flex"
    ## Rows written before load recording existed are marked as such rather than
    ## quietly inheriting the current run's conditions.
    if (is.null(prev$load_start))   prev$load_start   <- NA_real_
    if (is.null(prev$load_end))     prev$load_end     <- NA_real_
    if (is.null(prev$ess_tail_est)) prev$ess_tail_est <- NA_real_
    ## Two probes launched against one file both skip what is already recorded
    ## and then both fit whatever comes next, so the file can end up with the
    ## same (rep, n_int, arm) twice. Keep the first and say so, rather than
    ## letting a duplicated fit be averaged in as though it were a replicate.
    key <- paste(prev$rep, prev$n_int, prev$arm)
    if (any(duplicated(key))) {
      cat(sprintf("WARNING: %d duplicate (rep, n_int, arm) rows dropped; a second\n",
                  sum(duplicated(key))))
      cat("probe was running against this file. Keeping the first of each.\n")
      prev <- prev[!duplicated(key), ]
    }
    out <- split(prev, seq_len(nrow(prev)))
    cat(sprintf("resuming with %d fits already recorded\n", nrow(prev)))
  }
  done <- function(r, ni, arm) any(vapply(out, function(z)
    z$rep == r && z$n_int == ni && identical(as.character(z$arm), arm), logical(1)))

  for (r in offset + seq_len(n_rep)) {
    d <- sim_network(SEED + r)
    for (ni in ORDERS) {
      net <- build_net(d, ni)
      nd  <- target_newdata(d, ni)
      for (arm in ARMS) {
        if (done(r, ni, arm)) next
        t0 <- Sys.time(); l0 <- machine_load()
        f <- try(if (arm == "flex") fit_flex(net) else fit_ph(net), silent = TRUE)
        el <- as.numeric(difftime(Sys.time(), t0, units = "secs")); l1 <- machine_load()
        if (inherits(f, "try-error")) {
          cat(sprintf("rep %d int %3d %-4s ERR %s\n", r, ni, arm,
                      conditionMessage(attr(f, "condition")))); flush.console(); next
        }
        dr <- target_rmst_diff(f, nd)
        su <- rstan::summary(f$stanfit)$summary
        out[[length(out) + 1L]] <- data.frame(
          rep = r, n_int = ni, arm = arm, secs = el, est = mean(dr), sd = sd(dr),
          mcse = attr(dr, "mcse"), ess_est = attr(dr, "ess"),
          ## Recorded so the registered tail-ESS threshold can be checked at
          ## PRODUCTION settings before the run, rather than extrapolated from a
          ## smoke fit. The refit-rate cap in section 14 was costed while the
          ## tail criterion was inert, so what fraction of production fits it
          ## would fail is now a measurement this probe supplies for free.
          ess_tail_est = attr(dr, "ess_tail"),
          rhat_est = attr(dr, "rhat"),
          rhat = max(su[, "Rhat"], na.rm = TRUE),
          ess_bulk = min(su[, "n_eff"], na.rm = TRUE),
          divergent = sum(vapply(rstan::get_sampler_params(f$stanfit, inc_warmup = FALSE),
                                 function(z) sum(z[, "divergent__"]), 0)),
          load_start = l0, load_end = l1,
          stringsAsFactors = FALSE)
        cat(sprintf(paste("rep %d int %3d %-4s %6.1f s est %+.4f mcse %.4f",
                          "estESS %5.0f estRhat %.3f globESS %5.0f div %d\n"),
                    r, ni, arm, el, mean(dr), attr(dr, "mcse"), attr(dr, "ess"),
                    attr(dr, "rhat"), min(su[, "n_eff"], na.rm = TRUE),
                    out[[length(out)]]$divergent))
        flush.console()
        ## Checkpoint after EVERY fit, not at the end, so an interrupted probe
        ## keeps what it has already paid for. It also makes an accidental
        ## duplicate launch recoverable rather than silently corrupting: resume
        ## is keyed on the (rep, n_int, arm) triple and the loader drops repeats
        ## of one. See the header of R/14-verify-anchoring.R for how three came
        ## to be running at once, which was a process-detection error and not, as
        ## had been assumed throughout this study, the machine killing jobs.
        saveRDS(do.call(rbind, out), path)
      }
    }
  }
  res <- do.call(rbind, out)
  saveRDS(res, path)
  cat("\n=== fits recorded, by order and arm ===\n")
  print(table(res$n_int, res$arm))
  res
}

if (!interactive() && Sys.getenv("PROBE_NOMAIN") == "")
  main(as.integer(Sys.getenv("N_REP_PROBE", "3")))
