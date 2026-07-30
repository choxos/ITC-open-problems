## ---------------------------------------------------------------------------
## E3: the benchmark run.
##
## One replicate = one simulated two-study network, analyzed by all seven
## estimators, so every comparison is PAIRED on the replicate. That pairing is
## what makes the registered contrasts (flexible versus proportional within a
## row, method family across rows) resolvable at this replicate count; nothing
## here is powered as an unpaired comparison and the analysis never treats it
## as one.
##
## Results are written PER REPLICATE, not per cell. Version 4 checkpointed per
## cell, which was adequate when a cell was 1.6 hours; at the restored counts a
## condition is about 6.2 hours, and this machine has terminated long-running
## background jobs repeatedly, so a per-cell checkpoint would discard hours of
## finished work on every kill. Round-three critique required that failures be
## recorded rather than dropped, so every fit records its sampler diagnostics
## whether or not it passed.
## ---------------------------------------------------------------------------

suppressPackageStartupMessages({library(parallel); library(dplyr)})
Sys.setenv(PROBE_NOMAIN = "1")
source("R/probe-integration.R")     # sim_network, build_net, fit_ph, fit_flex
source("R/03-estimators.R")
source("R/04-calibrate.R")

stopifnot("N_INT must be frozen before the run" = !is.na(N_INT))

TT <- seq(0.05, TAU, length.out = 200)
dir.create("results/cells", recursive = TRUE, showWarnings = FALSE)

## Sampler policy, registered in protocol section 7.2. Binds on the DERIVED
## estimand, not on every internal spline coefficient: the global minimum over
## weakly identified nuisance parameters was measured at 25 to 646 while the
## derived estimand sat above 2000, and a policy on the former would fail almost
## every fit on a number the study never uses.
## A pass criterion whose input is missing evaluates to TRUE and passes
## everything, which is how the tail-ESS threshold came to be a no-op. Every
## threshold is tested against a real number or the run stops.
sampler_ok <- function(d) {
  v <- c(d$rhat, d$ess_bulk, d$ess_tail, d$divergent, d$treedepth, d$iter)
  stopifnot("sampler diagnostics incomplete; a threshold would pass by default"
            = length(v) == 6L && all(is.finite(v)))
  ## THE DIVERGENCE CRITERION IS A RATE, and it was a count until one production
  ## replicate showed the count unmeetable. Both arms failed on divergences alone
  ## after the registered escalation, at 8 and 3 out of 2,000 post-warmup draws,
  ## with Rhat 1.0007 and 1.0002 and bulk ESS 1,696 and 2,015. That is the same
  ## defect section 7.2 already records for the ESS half of this rule, surviving
  ## untouched in the other half: a criterion that rejects a fit with 1,696
  ## effective draws on the registered estimand is reporting its own threshold.
  ##
  ## The rate is over POST-WARMUP draws, which is iter/2 per chain by construction
  ## here, so the denominator is derived rather than assumed.
  post <- d$iter / 2 * N_CHAINS
  d$divergent_rate <- d$divergent / post
  base <- d$rhat < 1.01 && d$ess_bulk >= 400 && d$ess_tail >= 400 &&
    d$divergent_rate <= DIVERGENT_RATE_MAX && d$treedepth == 0
  ## The policy binds on the survival differences too, and round 6 found it was
  ## being applied to RMST alone. A fit whose survival prediction failed
  ## outright was stored with a NULL and still passed.
  if (is.null(d$surv_rhat)) return(FALSE)
  sv <- c(d$surv_rhat, d$surv_ess_bulk, d$surv_ess_tail)
  if (!all(is.finite(sv))) return(FALSE)
  base && all(d$surv_rhat < 1.01) && all(d$surv_ess_bulk >= 400) &&
    all(d$surv_ess_tail >= 400)
}

## p_WAIC from the `log_lik` generated quantity multinma's survival likelihoods
## always emit. Returns NA rather than stopping if the quantity is absent, since
## a missing diagnostic must not take down a fit that is otherwise valid; the
## analysis reports how many replicates carry it.
p_waic <- function(f) {
  ll <- try(rstan::extract(f$stanfit, pars = "log_lik",
                           permuted = TRUE)$log_lik, silent = TRUE)
  if (inherits(ll, "try-error") || is.null(ll)) return(NA_real_)
  sum(apply(ll, 2, stats::var))
}

fit_one <- function(net, nd, flexible, adapt_delta, iter,
                    n_knots = N_KNOTS, prior_mult = 1) {
  f <- try(if (flexible) fit_flex(net, iter, adapt_delta, n_knots, prior_mult)
           else fit_ph(net, iter, adapt_delta, n_knots, prior_mult),
           silent = TRUE)
  if (inherits(f, "try-error"))
    return(list(ok = FALSE, err = conditionMessage(attr(f, "condition"))))
  dr <- try(target_rmst_diff(f, nd), silent = TRUE)
  if (inherits(dr, "try-error"))
    return(list(ok = FALSE, err = conditionMessage(attr(dr, "condition"))))
  sp <- rstan::get_sampler_params(f$stanfit, inc_warmup = FALSE)
  ## ess_tail is a distinct statistic, not a copy of ess_bulk. It was a copy
  ## until this was caught, which made the registered tail criterion a no-op; see
  ## target_rmst_diff in R/probe-integration.R.
  diag <- list(rhat = attr(dr, "rhat"), ess_bulk = attr(dr, "ess"),
               ess_tail = attr(dr, "ess_tail"), mcse = attr(dr, "mcse"),
               divergent = sum(vapply(sp, function(z) sum(z[, "divergent__"]), 0)),
               treedepth = sum(vapply(sp, function(z)
                 sum(z[, "treedepth__"] >= 10), 0)),
               glob_ess = min(rstan::summary(f$stanfit)$summary[, "n_eff"],
                              na.rm = TRUE),
               ## EFFECTIVE DEGREES OF FREEDOM, TAKEN WHILE THE FIT IS STILL IN
               ## SCOPE.
               ##
               ## Section 7.2 registers that "the effective degrees of freedom of
               ## each fitted survival model is recorded per replicate so the
               ## paper can report how far apart the flexibilities actually
               ## were rather than assuming they matched". Round 6 found no run
               ## pass returning it, and both fit objects are discarded one line
               ## later, so the diagnostic that the descriptive matched-
               ## flexibility comparison depends on could not have existed. The
               ## comparison it supports is the one round 2 forced: equal knot
               ## counts do NOT equate a Royston-Parmar log-cumulative-hazard
               ## spline with an M-spline on the hazard scale, so the paper has
               ## to measure the gap rather than assert it away.
               ##
               ## p_WAIC, the sum over observations of the posterior variance of
               ## the log-likelihood contribution, is the effective parameter
               ## count that is comparable across models of different structure;
               ## a raw coefficient count is not, because the M-spline
               ## coefficients are simplex-constrained and shrunk by their
               ## prior, so counting them overstates a flexible fit's real
               ## freedom by exactly the amount the arm is trying to measure.
               edf = p_waic(f),
               n_knots = n_knots, prior_mult = prior_mult,
               iter = iter, adapt_delta = adapt_delta)
  ## Registered primary outcome 4, which this path could not produce before
  ## round 6. Summarized to mean and pointwise 95% interval per time rather than
  ## carried as draws, because the draws would multiply every checkpoint by the
  ## posterior sample size for a quantity the analysis only ever summarizes.
  sd_draws <- try(target_surv_diff(f, nd), silent = TRUE)
  sd_summ <- if (inherits(sd_draws, "try-error")) NULL else list(
    est = colMeans(sd_draws),
    lo  = apply(sd_draws, 2, quantile, 0.025),
    hi  = apply(sd_draws, 2, quantile, 0.975),
    t_grid = T_GRID)
  if (!is.null(sd_summ)) {
    diag$surv_rhat     <- attr(sd_draws, "rhat")
    diag$surv_ess_bulk <- attr(sd_draws, "ess_bulk")
    diag$surv_ess_tail <- attr(sd_draws, "ess_tail")
  }
  cox_hr <- try(target_cox_hr(f, nd), silent = TRUE)
  list(ok = TRUE, est = mean(dr), lo = unname(quantile(dr, 0.025)),
       hi = unname(quantile(dr, 0.975)), diag = diag, surv = sd_summ,
       cox_hr = if (inherits(cox_hr, "try-error")) NA_real_ else cox_hr,
       surv_err = if (inherits(sd_draws, "try-error"))
         conditionMessage(attr(sd_draws, "condition")) else NULL,
       passed = sampler_ok(diag))
}

## THE REGISTERED REFIT ESCALATION, ACTUALLY PERFORMED.
##
## Protocol section 14 registers "refit once at doubled iterations with
## adapt_delta = 0.99; a fit failing twice is recorded as a failure, not
## dropped". Version 4 registered that and could not have done it: fit_flex and
## fit_ph hardcoded both settings, so there was no way to escalate. Both are now
## arguments and the escalation runs here.
##
## Both attempts are retained. The analysis uses the second when it exists, and
## `refit` records that it happened, so the observed escalation rate is
## reportable against the 20% budget cap rather than inferred.
fit_mlnmr <- function(net, nd, flexible, n_knots = N_KNOTS, prior_mult = 1) {
  first <- fit_one(net, nd, flexible, adapt_delta = 0.8, iter = N_ITER,
                   n_knots = n_knots, prior_mult = prior_mult)
  if (isTRUE(first$ok) && isTRUE(first$passed))
    return(c(first, list(refit = FALSE)))
  second <- fit_one(net, nd, flexible, adapt_delta = 0.99, iter = 2 * N_ITER,
                    n_knots = n_knots, prior_mult = prior_mult)
  if (!isTRUE(second$ok)) return(c(first, list(refit = TRUE, refit_failed = TRUE,
                                               first = first)))
  ## THE FIRST ATTEMPT'S DIAGNOSTICS ARE KEPT, not just a flag saying it failed.
  ## Without them the realized refit rate is observable but its REASON is not, so
  ## a question that decides the run's cost, namely whether first attempts would
  ## pass under the rate rule, could not be answered from any checkpoint. That is
  ## the same defect as discarding the bootstrap draws: the only object that could
  ## settle it was thrown away. `first_diag` is small; the fit object is not kept.
  c(second, list(refit = TRUE, first_passed = isTRUE(first$passed),
                 first_diag = first$diag))
}

## THE RUN IS TWO PASSES, NOT ONE.
##
## Version 4 did the frequentist bootstrap and the two Stan fits inside a single
## replicate function. On four performance cores that is self-defeating: two
## replicates in flight at two chains each already saturates the machine, so a
## bootstrap running alongside them oversubscribes, and the same measurement that
## showed four chains cost 166.9 s against two chains' 74.1 s shows why that is
## expensive. Splitting the passes lets each use the whole machine on its own
## terms: the bootstrap forks over four cores and does no MCMC, the Stan pass
## runs two replicates of two chains and does no bootstrapping.
##
## The two passes checkpoint separately and are joined on (cell_id, rep) at
## analysis time, so either can be resumed, rerun or extended without touching
## the other. The SAME network is used by both, because it is regenerated from
## the same seed rather than passed between them, which is what keeps every
## estimator paired on the replicate.

## Keyed on `param_id`, the PARAMETER cell, so the three censoring variants of
## one cell are the same latent network censored three ways. Version 5 keyed it
## on `cell_id`, which runs over cell-by-censoring rows, so the regimes were
## independent draws and the censoring comparison was unpaired despite the
## protocol registering common random numbers. See build_cells in
## R/04-calibrate.R for why the streams stay aligned once the seed is shared.
net_seed <- function(cell, rep_id) SEED + 100000 + 997 * rep_id + cell$param_id

sim_for <- function(cell, rep_id) {
  cens <- E3_CENS[E3_CENS$label == cell$cens, ]
  sim_network(net_seed(cell, rep_id),
              family = cell$family, kappa_b = cell$kappa_b,
              gamma = cell$gamma, beta_b = cell$beta_b, cens = cens,
              kappa_a = cell$kappa_a)
}

rep_path <- function(pass, cell_id, rep_id)
  sprintf("results/cells/%s-%02d-rep-%03d.rds", pass, cell_id, rep_id)

## --- pass 1: the five frequentist rows, with the full-pipeline bootstrap -----
## Measured at 0.467 s per resample on one core and a 2.10x speedup on four, so
## 500 resamples is about four minutes of core time per replicate and about two
## minutes of wall clock.
freq_replicate <- function(cell, rep_id) {
  set.seed(net_seed(cell, rep_id) + 1L)          # bootstrap draws, reproducible
  fb <- try(freq_boot(sim_for(cell, rep_id), n_boot = N_BOOT, tt = TT,
                      cores = N_CORES_BOOT), silent = TRUE)
  list(cell = cell, rep = rep_id,
       freq = if (inherits(fb, "try-error")) NULL else fb)
}

## --- pass 2: the two ML-NMR rows --------------------------------------------
mlnmr_replicate <- function(cell, rep_id) {
  d <- sim_for(cell, rep_id)
  net <- build_net(d, N_INT); nd <- target_newdata(d, N_INT)
  list(cell = cell, rep = rep_id,
       mlnmr_ph = fit_mlnmr(net, nd, FALSE),
       mlnmr_flex = fit_mlnmr(net, nd, TRUE))
}

## --- pass 3: the sensitivity arms, which had no driver until round 6 ---------
##
## The protocol registered three arms, gave them a budget line, and named no
## cells; the fitting functions hardcoded the knot count and the prior scales the
## arms are supposed to vary; and nothing here could launch them. That is the
## fourth registered-but-unimplementable procedure this study has found, after
## the refit escalation, the tail-ESS criterion and the common Cox projection.
##
## Two properties make the arms comparisons rather than separate little studies:
##
## 1. THE SEED IS THE PRODUCTION SEED. `sens_replicate` calls the same
##    `sim_for(cell, rep_id)` as the main run, so replicate 7 of the kappa_B=0.30
##    primary cell is the SAME NETWORK here and in pass 2. Every arm is therefore
##    paired with the production fit on identical data and the contrast carries
##    only the setting, not a fresh draw. This is why N_SENS_PER_CELL must stay
##    at or below N_REP: replicate 26 of a 25-replicate arm would have no
##    production counterpart to pair with.
##
## 2. THE SETTINGS COME FROM THE REGISTERED TABLE. `SENS_SETTINGS` in
##    R/00-config.R is one row per fit set, and it is the same table R/10-budget.R
##    multiplies, so the number of fit sets run and the number priced cannot
##    diverge.
sens_replicate <- function(cell, rep_id, s) {
  d <- sim_for(cell, rep_id)
  net <- build_net(d, s$n_int); nd <- target_newdata(d, s$n_int)
  out <- list(cell = cell, rep = rep_id, arm = s$arm, setting = s$setting,
              n_int = s$n_int, n_knots = s$n_knots, prior_mult = s$prior_mult,
              mlnmr_ph = fit_mlnmr(net, nd, FALSE, s$n_knots, s$prior_mult),
              mlnmr_flex = fit_mlnmr(net, nd, TRUE, s$n_knots, s$prior_mult))
  ## The knot arm is registered "for both bases", so it reruns the
  ## Royston-Parmar rows as well, at the full resample count rather than a
  ## reduced one, because interval coverage is a registered primary outcome and a
  ## short bootstrap would make the arm's coverage incomparable with the
  ## production coverage it is being read against. Round 6 found the frequentist
  ## half of this arm with no budget line at all.
  if (isTRUE(s$freq)) {
    set.seed(net_seed(cell, rep_id) + 1L)        # the production bootstrap seed
    fb <- try(freq_boot(d, n_boot = N_BOOT, tt = TT, cores = N_CORES_BOOT,
                        k = s$n_knots), silent = TRUE)
    out$freq <- if (inherits(fb, "try-error")) NULL else fb
  }
  out
}

## The prespecified two-cell subset, resolved against the locked cell table so a
## typo in SENS_CELLS is an error rather than a silently empty arm.
sens_cells <- function(cells) {
  key <- function(z) do.call(paste, c(z[, c("arm", "family", "kappa_a",
                                            "kappa_b", "margin", "cens")],
                                      sep = "|"))
  sel <- cells[key(cells) %in% key(SENS_CELLS), ]
  stopifnot("SENS_CELLS does not resolve to the registered subset"
            = nrow(sel) == nrow(SENS_CELLS))
  stopifnot("sensitivity replicates must pair with production replicates"
            = N_SENS_PER_CELL <= N_REP)
  sel
}

run_cell <- function(cell, pass, fn, n_rep = N_REP) {
  for (r in seq_len(n_rep)) {
    p <- rep_path(pass, cell$cell_id, r)
    if (file.exists(p)) next                     # resume, do not repeat
    z <- try(fn(cell, r), silent = TRUE)
    if (!inherits(z, "try-error")) z$code <- code_stamp()
    saveRDS(z, p)                                # checkpoint immediately
    cat(sprintf("%s cell %2d rep %3d/%d %s\n", pass, cell$cell_id, r, n_rep,
                if (inherits(z, "try-error")) "ERR" else "ok"))
    flush.console()
  }
  invisible(NULL)
}

## THE RUN RECORDS THE CODE IT IS RUNNING, because a long run does not reload it.
##
## R loads source at `source()` time. The frequentist pass ran for eleven hours in
## a process started BEFORE the divergence criterion was changed from a count to a
## rate, so that process still held `divergent == 0` and would have applied it to
## the Stan pass: every fit marked failed, every fit refit, and the fix that was
## made specifically to prevent that never in effect. Per-replicate checkpointing
## meant restarting cost nothing, but noticing was luck.
##
## Every checkpoint now carries the modification time of the code that produced it,
## so a mixed-policy run is detectable afterwards rather than invisible, and the
## banner prints the loaded policy so a running job can be checked against the
## file on disk.
code_stamp <- function() {
  fs <- list.files("R", pattern = "\\.R$", full.names = TRUE)
  list(newest = max(file.info(fs)$mtime),
       divergent_rate_max = DIVERGENT_RATE_MAX,
       refit_assumed = REFIT_RATE_ASSUMED, n_int = N_INT, n_iter = N_ITER)
}

main <- function(pass = Sys.getenv("PASS", "both"),
                 workers = as.integer(Sys.getenv("WORKERS", "2"))) {
  cells <- build_cells(); cells$cell_id <- seq_len(nrow(cells))
  todo <- split(cells, cells$cell_id)
  run_pass <- function(tag, fn, w, cells = todo, n_rep = N_REP) {
    left <- Filter(function(cc)
      any(!file.exists(rep_path(tag, cc$cell_id, seq_len(n_rep)))), cells)
    n_left <- sum(vapply(left, function(cc)
      sum(!file.exists(rep_path(tag, cc$cell_id, seq_len(n_rep)))), 0L))
    cat(sprintf("pass %-16s: %d cells incomplete, %d of %d replicates left, %d workers\n",
                tag, length(left), n_left, length(cells) * n_rep, w))
    if (n_left) invisible(mclapply(left, run_cell, pass = tag, fn = fn,
                                   n_rep = n_rep,
                                   mc.cores = w, mc.preschedule = FALSE))
  }
  cs <- code_stamp()
  cat(sprintf("N_INT = %d, N_REP = %d, N_BOOT = %d\n", N_INT, N_REP, N_BOOT))
  cat(sprintf("policy loaded: divergent rate <= %.3f, refit assumed %.2f\n",
              cs$divergent_rate_max, cs$refit_assumed))
  cat(sprintf("newest file in R/ at load time: %s\n", format(cs$newest)))
  ## The frequentist pass parallelizes INSIDE a replicate over N_CORES_BOOT, so
  ## it runs one replicate at a time; the Stan pass parallelizes ACROSS them.
  if (pass %in% c("both", "freq"))  run_pass("freq",  freq_replicate, 1L)
  if (pass %in% c("both", "mlnmr")) run_pass("mlnmr", mlnmr_replicate, workers)

  ## The sensitivity arms run LAST and are never part of "both", because they are
  ## separately resumable and separately reportable and the main run is the part
  ## that must complete. `PASS=sens` runs every registered setting; `PASS=sens
  ## SENS_SETTING=knots_5` runs one, so an arm can be scheduled on its own
  ## without editing anything.
  if (pass == "sens") {
    only <- Sys.getenv("SENS_SETTING", "")
    st <- if (nzchar(only)) SENS_SETTINGS[SENS_SETTINGS$setting == only, ]
          else SENS_SETTINGS
    stopifnot("no such registered sensitivity setting" = nrow(st) > 0)
    sc <- sens_cells(cells)
    todo_s <- split(sc, sc$cell_id)
    for (i in seq_len(nrow(st))) {
      s <- st[i, ]
      ## The knot arm also reruns the bootstrap, so it cannot share the Stan
      ## pass's two workers without oversubscribing four performance cores the
      ## same way version 4's single-pass design did.
      w <- if (isTRUE(s$freq)) 1L else workers
      run_pass(paste0("sens-", s$setting),
               function(cell, r) sens_replicate(cell, r, s), w,
               cells = todo_s, n_rep = N_SENS_PER_CELL)
    }
  }
}

if (!interactive() && Sys.getenv("RUN_NOMAIN") == "") main()
