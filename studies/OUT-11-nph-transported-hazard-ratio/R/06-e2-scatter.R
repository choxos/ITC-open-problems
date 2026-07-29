## ---------------------------------------------------------------------------
## E2: finite-sample behavior of the ANCHORED transported hazard ratio around
## the E1 limit.
##
## E1 computes exactly what an anchored Bucher contrast built from two fitted
## constant hazard ratios converges to under each pair of censoring regimes, so
## the DIRECTION and SIZE of the censoring dependence need no simulation. What
## the theorem does not give is (a) whether that analytic limit is actually what
## finite samples converge to, and (b) whether an analyst at realistic sample
## sizes can tell the regimes apart. The first is a check on E1; the second
## decides whether the E1 result matters in practice or is a large-sample
## curiosity. Both are here, and both cost coxph fits only.
##
## VERSION 5 CHANGES WHAT IS SIMULATED. Version 4 generated ONE study comparing
## B against A directly and fitted one Cox model to it. Round four found that
## this is not the quantity OUT-11 concerns: an anchored indirect comparison is
## assembled from a separate A-versus-placebo study and a separate
## B-versus-placebo study, and least-false Cox coefficients are not transitive
## under non-proportional hazards, so the direct coefficient and the Bucher
## difference are different numbers. E1 measured the gap at 0.9% to 1.8%.
##
## The structure now mirrors anchored_limit() exactly:
##
##   * TWO independent studies per replicate. Leg A is the IPD study, PBO versus
##     A at N_IPD_ARM per arm; leg B is the aggregate study, PBO versus B at
##     N_AGD_ARM per arm. Two separate placebo samples, because two separate
##     trials is what an indirect comparison has.
##   * Each leg is fitted under ITS OWN censoring regime, and the two regimes are
##     crossed independently over all four, giving a 4 x 4 grid. The diagonal is
##     the "both studies followed alike" case; the off-diagonal is differential
##     follow-up, which is the case the catalog entry names and which version 4
##     could not express at all.
##   * The legs are simulated once per regime and reused across every crossing,
##     which is both eight times cheaper than simulating each of the sixteen
##     cells and more faithful: leg A's data cannot depend on the follow-up of a
##     trial it was not part of.
##
## EACH LEG IS SIMULATED IN ITS OWN STUDY, at the TARGET covariate law, which is
## exactly the specification E1 computes. Leg A carries the IPD study's baseline
## hazard and leg B the aggregate study's, because population adjustment
## reweights patients and does not transport a baseline; giving leg A the target
## baseline would hand it an accuracy no method delivers, and it measurably
## matters (up to 2.86% on the hazard-ratio scale at kappa_A = 0.30, varying
## across regimes). See the header of R/02b-anchored-limit.R.
##
## What IS idealized is the covariate adjustment, which is assumed perfect so
## that the only thing moving is the censoring. Covariate-adjustment error is
## E3's subject, measured separately and not confounded into this.
##
## Every parameter is read from R/00-config.R. A round-three critique found that
## this experiment previously existed only as prose, naming neither its family
## nor its treatment contrast, and it was right that a preregistration which
## cannot be executed from its own text is not one.
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(survival))
source("R/04-calibrate.R")
source("R/02b-anchored-limit.R")
dir.create("results", showWarnings = FALSE)

## Truth is held EXACTLY fixed across regimes by construction, since censoring
## touches no survival function, and beta_B is re-solved per cell so the true
## RMST difference sits on the same registered margin at every kappa. So any
## spread across regimes is the estimator moving, not the estimand.
e2_cells <- function() {
  do.call(rbind, lapply(E2_KAPPA_A, function(ka)
    do.call(rbind, lapply(E2_KAPPA_B, function(kb) data.frame(
      family = E2_FAMILY, kappa_a = ka, kappa_b = kb, gamma = E2_GAMMA,
      beta_b = solve_beta_b(E2_FAMILY, kb, E2_GAMMA,
                            unname(MARGIN_LEVELS[E2_MARGIN]), ka),
      stringsAsFactors = FALSE)))))
}

## One leg: a two-arm study, simulated once per regime and fitted unadjusted.
## Returns the coefficient and its model standard error per (regime, replicate).
##
## COMMON RANDOM NUMBERS ACROSS REGIMES WITHIN A LEG. The seed is reset to the
## same value before each regime, so the covariate draws and the latent event
## times are identical and only the censoring differs. Because R draws an
## exponential as a standard exponential divided by the rate, resetting the seed
## also couples the censoring times themselves across regimes rather than merely
## redrawing them, which makes the paired regime contrast as clean as it can be.
## BOTH VARIANCE ESTIMATORS ARE RECORDED. Round 5 objected that E2 used the
## model-based Cox variance, and that under non-proportional hazards the ordinary
## inverse-information variance need not estimate the sampling variance of the
## least-false coefficient, so the reported coverage could be a variance-estimator
## artifact rather than a fact about the estimator. The objection is right in
## general. Measured here it does not bite: the two agree to 0.1% and give
## identical coverage. Recording both is what makes that checkable instead of
## asserted.
e2_leg <- function(arm_ref, arm_cmp, n_arm, seed_base, n_rep, rate_col) {
  co <- se <- se_rob <- matrix(NA_real_, nrow(CENS_REGIMES), n_rep)
  for (j in seq_len(nrow(CENS_REGIMES))) {
    rg <- CENS_REGIMES[j, ]
    rate <- rg[[rate_col]]
    for (r in seq_len(n_rep)) {
      set.seed(seed_base + r)
      x0 <- rnorm(n_arm, MU_TGT, SD_X); x1 <- rnorm(n_arm, MU_TGT, SD_X)
      d0 <- sim_arm(n_arm, x0, arm_ref, rate, rg$t_admin)
      d1 <- sim_arm(n_arm, x1, arm_cmp, rate, rg$t_admin)
      d  <- rbind(cbind(d0, z = 0), cbind(d1, z = 1))
      f <- try(coxph(Surv(time, status) ~ z, data = d, robust = TRUE),
               silent = TRUE)
      if (!inherits(f, "try-error")) {
        co[j, r]     <- unname(coef(f))
        se[j, r]     <- unname(sqrt(f$naive.var[1, 1]))   # model-based
        se_rob[j, r] <- unname(sqrt(f$var[1, 1]))         # robust sandwich
      }
    }
  }
  list(coef = co, se = se, se_rob = se_rob)
}

## Seed layout. Each (leg, cell) gets a block of E2_SEED_STRIDE consecutive
## seeds and replicate r takes the r-th of them. The stride MUST exceed the
## replicate count: an earlier version used a stride of 1,000 with 2,000
## replicates, so cells whose leg-A parameters were identical drew literally the
## same 1,000 datasets as their neighbors. Nothing reported was wrong, since
## every number in E2 is computed within a cell, but correlated cells are a trap
## for anyone who later pools them, and the guard costs nothing.
E2_SEED_STRIDE <- 100000L

e2_run <- function(n_rep = N_REP_E2) {
  stopifnot("E2 seed stride must exceed the replicate count" =
              n_rep < E2_SEED_STRIDE)
  cells <- e2_cells()
  out <- list(); draws <- list()
  for (i in seq_len(nrow(cells))) {
    cc <- cells[i, ]
    ## Leg A lives in the IPD study and leg B in the aggregate study, each with
    ## its own placebo arm and its own baseline hazard, exactly as E1 computes
    ## them. Both are simulated at the TARGET covariate law, which is the
    ## perfect-covariate-adjustment idealization; neither is given the other
    ## study's baseline, because no adjustment method transports one.
    pbo_a <- placebo_arm(cc$family, "ipd")
    a     <- make_arm(cc$family, "ipd", beta = BETA_A, kappa = cc$kappa_a,
                      gamma = cc$gamma)
    pbo_b <- placebo_arm(cc$family, "tgt")
    b     <- make_arm(cc$family, "tgt", beta = cc$beta_b, kappa = cc$kappa_b,
                      gamma = cc$gamma)
    ## Distinct seed streams for the two legs: they are independent trials, and
    ## coupling them would manufacture a correlation the Bucher variance
    ## formula assumes is absent.
    legA <- e2_leg(pbo_a, a, E2_N_A_ARM,
                   SEED + E2_SEED_STRIDE * (10L + i), n_rep, "rate_ipd")
    legB <- e2_leg(pbo_b, b, E2_N_B_ARM,
                   SEED + E2_SEED_STRIDE * (50L + i), n_rep, "rate_agd")

    for (ja in seq_len(nrow(CENS_REGIMES))) {
      for (jb in seq_len(nrow(CENS_REGIMES))) {
        lim <- anchored_limit(pbo_a, a, pbo_b, b, MU_TGT, SD_X,
                              CENS_REGIMES$rate_ipd[ja], CENS_REGIMES$t_admin[ja],
                              CENS_REGIMES$rate_agd[jb], CENS_REGIMES$t_admin[jb])
        est <- legB$coef[jb, ] - legA$coef[ja, ]                  # Bucher
        sev <- sqrt(legB$se[jb, ]^2 + legA$se[ja, ]^2)            # Bucher SE
        sev_rob <- sqrt(legB$se_rob[jb, ]^2 + legA$se_rob[ja, ]^2)
        ## Coverage of the E1 LIMIT, not of any truth. A Wald interval around a
        ## least-false parameter is correctly centered on that parameter and on
        ## nothing else, so this is an independent check that the analytic limit
        ## is what the simulation actually converges to. It is emphatically NOT
        ## evidence that the interval covers the estimand; under
        ## non-proportional hazards it does not, which is the whole point.
        cov_lim <- mean(abs(est - unname(lim["anchored"])) < 1.96 * sev, na.rm = TRUE)
        cov_lim_rob <- mean(abs(est - unname(lim["anchored"])) < 1.96 * sev_rob,
                            na.rm = TRUE)
        out[[length(out) + 1L]] <- data.frame(
          kappa_a = cc$kappa_a, kappa_b = cc$kappa_b,
          regime_a = CENS_REGIMES$label[ja], regime_b = CENS_REGIMES$label[jb],
          matched = ja == jb,
          limit_hr = exp(unname(lim["anchored"])),
          mean_hr = exp(mean(est, na.rm = TRUE)),
          bias_log = mean(est, na.rm = TRUE) - unname(lim["anchored"]),
          mcse_bias = sd(est, na.rm = TRUE) / sqrt(sum(!is.na(est))),
          sd_log = sd(est, na.rm = TRUE),
          cover_limit = cov_lim, cover_limit_robust = cov_lim_rob,
          se_ratio = mean(sev_rob / sev, na.rm = TRUE), n_ok = sum(!is.na(est)),
          stringsAsFactors = FALSE)
        draws[[length(draws) + 1L]] <- est
      }
    }
  }
  res <- do.call(rbind, out)
  attr(res, "draws") <- draws
  res
}

## Could anyone notice? Two framings, because they answer different questions
## and only the second is what an analyst actually faces.
##
## `shift_per_sd` is the regime-induced shift in units of the sampling standard
## deviation of ONE reported anchored hazard ratio. This is the interpretable
## quantity: if it is well below 1, the systematic movement E1 computes is
## smaller than the noise on any single reported estimate and cannot be seen.
##
## `p_two_networks_differ` is the probability that two analysts, each holding an
## independent pair of trials conducted under different follow-up, would call
## their anchored estimates significantly different. Independent, not paired,
## because that is the real situation; the paired common-random-number version
## would flatter the test by removing variation no analyst can remove.
##
## The reference is the matched reference-regime crossing, so every row answers
## "against the case where both trials were followed alike, how far does this
## configuration move, and would anyone see it?"
e2_discriminate <- function(res) {
  dr <- attr(res, "draws")
  key <- paste(res$kappa_a, res$kappa_b)
  do.call(rbind, lapply(unique(key), function(k) {
    idx <- which(key == k)
    ref_i <- idx[res$regime_a[idx] == CENS_REGIMES$label[1] &
                 res$regime_b[idx] == CENS_REGIMES$label[1]]
    ref <- dr[[ref_i]]; sd_ref <- sd(ref, na.rm = TRUE)
    do.call(rbind, lapply(setdiff(idx, ref_i), function(j) {
      cur <- dr[[j]]; sd_cur <- sd(cur, na.rm = TRUE)
      shift <- mean(cur, na.rm = TRUE) - mean(ref, na.rm = TRUE)
      se_ind <- sqrt(sd_ref^2 + sd_cur^2)
      d_ind <- cur - sample(ref)      # break the CRN coupling on purpose
      data.frame(kappa_a = res$kappa_a[j], kappa_b = res$kappa_b[j],
                 regime_a = res$regime_a[j], regime_b = res$regime_b[j],
                 matched = res$matched[j],
                 shift_log = shift, sd_single = sd_cur,
                 shift_per_sd = shift / sd_cur,
                 p_two_networks_differ =
                   mean(abs(d_ind) > 1.96 * se_ind, na.rm = TRUE),
                 stringsAsFactors = FALSE)
    }))
  }))
}

if (!interactive() && Sys.getenv("E2_NOMAIN") == "") {
  set.seed(SEED)
  res <- e2_run()
  cat("=== E2.1 anchored fitted HR against its exact limit, per regime pair ===\n")
  print(res[, c("kappa_a", "kappa_b", "regime_a", "regime_b", "matched",
                "limit_hr", "mean_hr", "bias_log", "mcse_bias", "sd_log",
                "cover_limit")], row.names = FALSE, digits = 4)

  cat("\n=== E2.2 does the simulation land on the E1 limit? ===\n")
  cat(sprintf("worst |bias| over %d regime pairs: %.4f (log scale)\n",
              nrow(res), max(abs(res$bias_log))))
  cat(sprintf("largest |bias| / its own MCSE: %.2f\n",
              max(abs(res$bias_log) / res$mcse_bias)))
  cat(sprintf("coverage of the E1 limit, model-based SE: %.3f to %.3f\n",
              min(res$cover_limit), max(res$cover_limit)))
  cat(sprintf("coverage of the E1 limit, robust sandwich: %.3f to %.3f\n",
              min(res$cover_limit_robust), max(res$cover_limit_robust)))
  cat(sprintf("mean robust/model SE ratio: %.4f\n", mean(res$se_ratio)))

  cat("\n=== E2.3 can an analyst distinguish follow-up regimes? ===\n")
  dis <- e2_discriminate(res)
  print(dis, row.names = FALSE, digits = 4)
  cat(sprintf("\nlargest shift per single-estimate SD: %.3f\n",
              max(abs(dis$shift_per_sd))))
  cat(sprintf("largest detection probability: %.3f (nominal size 0.05)\n",
              max(dis$p_two_networks_differ)))

  saveRDS(list(scatter = res, discriminate = dis), "results/e2-scatter.rds")
  cat("\nwritten: results/e2-scatter.rds\n")
}
