## ---------------------------------------------------------------------------
## Export every number the protocol quotes, so that review/verify-protocol.py
## can assert the document against the code rather than against my typing.
##
## THIS FILE EXISTS BECAUSE THE PREVIOUS EXPORT WAS AN AD-HOC ONE-LINER THAT WAS
## NEVER COMMITTED, AND THAT GAP LET A WHOLE TABLE OF WRONG NUMBERS SURVIVE.
##
## Round four found that section 10.3's pilot table still carried the STC-PH and
## STC-flex columns produced BEFORE the Gauss-Hermite weighting bug was fixed:
## twelve values from code that had been deleted for being wrong, including a
## sign flip on every STC-flex entry (+0.15 published against -0.05 measured)
## and a -0.028 that supported an entire claimed finding which, at the correct
## -0.176, does not exist. The verifier did not catch it because it only checked
## the scalars and beta_B values that the old one-liner happened to export.
##
## The rule this file enforces: if the protocol prints a number, that number is
## exported here and asserted there. Adding a claim to the document without
## adding it here is the failure mode, so the verifier also counts what it
## checked and the protocol's change log records the count.
##
##   Rscript R/09-export-design.R
##   python3 review/verify-protocol.py
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(jsonlite))
source("R/04-calibrate.R")

j <- function(x) x   # readability: everything below is assembled into one list

## THE ARTIFACTS ARE MANDATORY, NOT OPTIONAL.
##
## Round 6 found the advertised fail-closed protection was nothing of the kind.
## Every block below is guarded by `if (file.exists(...))`, and the verifier
## checks each key by `if key in DESIGN`, so a missing result file silently
## removed both the export and its assertions and the verifier still printed a
## clean pass. It had done exactly that: `results/dgm-verification.rds` was
## absent while the script reported 253 of 253 passing.
##
## The guards are kept, because a genuinely optional artifact does exist (the
## 512-point probe accumulates while the design is being written). What changes
## is that the file list is explicit and stated up front, so an artifact going
## missing is a loud failure here rather than a quiet subtraction from the
## verifier's denominator.
REQUIRED <- c("results/freq-pilot-v2.rds", "results/e1-decomposition.rds",
              "results/e2-scatter.rds", "results/ph-power.rds",
              "results/dgm-verification.rds", "results/graft-error.rds",
              "results/integration-pooled.rds", "results/pooling-check.rds",
              "results/anchoring-truth.rds", "results/anchoring-check.rds",
              "results/production-timing.rds", "results/d3-convergence.rds",
              "results/pooled-ph-probe.rds")
missing <- REQUIRED[!file.exists(REQUIRED)]
if (length(missing))
  stop("the export is missing artifacts the protocol quotes, so the verifier ",
       "would pass by checking fewer things:\n  ",
       paste(missing, collapse = "\n  "),
       "\nRegenerate them, or remove the claims they support.")

out <- list()

## --- locked scalars and the cell matrix --------------------------------------
cells <- build_cells()
out$n_cells      <- nrow(unique(cells[, c("arm", "family", "kappa_a", "kappa_b",
                                          "gamma", "margin")]))
out$n_cell_rows  <- nrow(cells)          # cells x censoring conditions
out$n_rep        <- N_REP
out$n_boot       <- N_BOOT
out$n_rep_e2     <- N_REP_E2
out$n_int        <- as.integer(N_INT)
out$n_chains     <- N_CHAINS
out$n_iter       <- N_ITER
out$n_replicates <- out$n_cell_rows * N_REP
out$tau <- TAU; out$t_admin <- T_ADMIN; out$threshold <- DELTA_THRESHOLD
out$n_ipd <- N_IPD_ARM; out$n_agd <- N_AGD_ARM
out$mu_ipd <- MU_IPD; out$mu_tgt <- MU_TGT; out$sd_x <- SD_X
out$beta_a <- BETA_A; out$gamma <- GAMMA
out$kappa_a_levels <- KAPPA_A_LEVELS; out$kappa_b_levels <- KAPPA_B_LEVELS
out$margins <- as.list(MARGIN_LEVELS)
out$n_regimes_e1 <- nrow(CENS_REGIMES); out$n_regimes_e3 <- nrow(E3_CENS)

u <- unique(cells[, c("arm", "family", "kappa_a", "kappa_b", "gamma", "margin",
                      "target_delta", "beta_b")])
out$cells <- lapply(seq_len(nrow(u)), function(i) as.list(u[i, ]))

## --- the pilot, which the protocol tabulates ---------------------------------
## Read from the saved pilot object, never retyped. The keys are the pilot's own
## cell labels so a renamed cell fails loudly instead of silently misaligning.
if (file.exists("results/freq-pilot-v2.rds")) {
  p <- readRDS("results/freq-pilot-v2.rds")
  out$pilot_n_rep <- nrow(p[[1]]$est)
  out$pilot_bias <- lapply(p, function(z) as.list(round(colMeans(z$est) - z$truth, 3)))
  out$pilot_sd   <- lapply(p, function(z) as.list(round(apply(z$est, 2, sd), 3)))
  out$pilot_truth <- lapply(p, function(z) z$truth)
  ## The planning SD the Monte Carlo section registers, and the noise floor that
  ## follows from it. Both are quoted in prose and both are derived here.
  sds <- unlist(lapply(p, function(z) apply(z$est, 2, sd)))
  out$pilot_sd_min <- round(min(sds), 2); out$pilot_sd_max <- round(max(sds), 2)
  out$planning_sd  <- 0.75
  out$noise_floor  <- round(pnorm((DELTA_THRESHOLD - 0.75) / out$planning_sd), 3)
  ## Decision loss, the secondary appendix, against both constant baselines.
  loss <- function(est, truth, thr = DELTA_THRESHOLD) {
    wrong <- if (truth > thr) est <= thr else est > thr
    mean(wrong) * abs(truth - thr)
  }
  per <- sapply(p, function(z) apply(z$est, 2, loss, truth = z$truth))
  out$pilot_decision_loss <- as.list(round(rowMeans(per), 4))
  tr <- vapply(p, function(z) z$truth, 0)
  out$pilot_loss_always <- round(mean(ifelse(tr > DELTA_THRESHOLD, 0,
                                             abs(tr - DELTA_THRESHOLD))), 4)
  out$pilot_loss_never  <- round(mean(ifelse(tr > DELTA_THRESHOLD,
                                             abs(tr - DELTA_THRESHOLD), 0)), 4)
}

## --- E1, the computed decomposition ------------------------------------------
if (file.exists("results/e1-decomposition.rds")) {
  e1 <- readRDS("results/e1-decomposition.rds")
  out$e1_d3_worst_range      <- round(max(e1$d3$range), 4)
  out$e1_d3_worst_range_diag <- round(max(e1$d3$range_diag), 4)
  ## The registered statistic is a decision flip, not a range against a level.
  out$e1_d3_pass <- all(e1$d3$flip_frac == 0)
  out$e1_d3_flip_cells <- sum(e1$d3$flip_frac > 0)
  out$e1_d3_n_cells <- nrow(e1$d3)
  out$e1_d3_worst_flip <- round(max(e1$d3$flip_frac), 4)
  out$e1_d3_worst_flip_n <- round(max(e1$d3$flip_frac) * 16)
  ## The alternative thresholds, RECOMPUTED rather than argued from a range.
  ## Round 6 found the protocol claiming the same four cells flip at 0.40 and
  ## 0.60, on the reasoning that the implied values span the threshold "while
  ## the truth sits at 0.750". The truth is 0.750 only in the `recommend` cells;
  ## the `margin` cells sit at 0.35, which is the reason they exist. A flip count
  ## depends on which side of the threshold each cell's TRUTH falls as well, so
  ## it cannot be read off a range at all.
  out$e1_d3_flip_cells_040 <- sum(e1$d3$flip_frac_040 > 0)
  out$e1_d3_flip_cells_060 <- sum(e1$d3$flip_frac_060 > 0)
  out$e1_d3_worst_flip_040 <- round(max(e1$d3$flip_frac_040), 4)
  out$e1_d3_worst_flip_060 <- round(max(e1$d3$flip_frac_060), 4)
  out$e1_d3_crossed_only <- sum(e1$d3$flip_frac > 0 & e1$d3$flip_frac_diag == 0)
  ## The counterexample to the OLD statistic, kept because it is what shows the
  ## old one could not have supported its own conclusion: a cell with a large
  ## range that flips nothing.
  j <- which(e1$d3$flip_frac == 0)
  if (length(j)) {
    j <- j[which.max(e1$d3$range[j])]
    out$e1_d3_big_range_no_flip <- round(e1$d3$range[j], 4)
  }
  out$e1_ablation_max <- signif(max(abs(e1$ablations$spread_pct)), 3)
  out$e1_spread_full_pct <- round(max(e1$least_false$spread_pct), 3)
  out$e1_spread_diag_pct <- round(max(e1$least_false$diag_pct), 3)
  ## The sharpest single number in the study: the ipd-nph cell where crossing
  ## the two studies' regimes moves D3 by a factor of many relative to matching
  ## them, because matched follow-up makes the two legs' movements cancel in the
  ## Bucher difference.
  k <- which.max(e1$d3$range / pmax(e1$d3$range_diag, 1e-12))
  out$e1_d3_ratio_cell  <- as.list(e1$d3[k, c("arm", "kappa_a", "kappa_b")])
  out$e1_d3_ratio_range <- round(e1$d3$range[k], 4)
  out$e1_d3_ratio_diag  <- round(e1$d3$range_diag[k], 4)
  out$e1_d3_ratio       <- round(e1$d3$range[k] / e1$d3$range_diag[k], 1)
}

## --- E2, the finite-sample check on E1 and the detectability measurement -----
if (file.exists("results/e2-scatter.rds")) {
  e2 <- readRDS("results/e2-scatter.rds")
  if (is.list(e2) && !is.null(e2$scatter)) {
    out$e2_worst_abs_bias    <- round(max(abs(e2$scatter$bias_log)), 4)
    out$e2_worst_bias_t      <- round(max(abs(e2$scatter$bias_log) /
                                          e2$scatter$mcse_bias), 2)
    out$e2_cover_limit_min   <- round(min(e2$scatter$cover_limit), 3)
    out$e2_cover_limit_max   <- round(max(e2$scatter$cover_limit), 3)
    out$e2_max_shift_per_sd  <- round(max(abs(e2$discriminate$shift_per_sd)), 3)
    out$e2_max_detect        <- round(max(e2$discriminate$p_two_networks_differ), 3)
    ## Round 5 objected that E2 used the model-based Cox variance where the
    ## robust sandwich is the right one under non-proportional hazards. The
    ## answer is a measurement and the measurement is exported, not retyped.
    out$e2_cover_robust_min <- round(min(e2$scatter$cover_limit_robust), 3)
    out$e2_cover_robust_max <- round(max(e2$scatter$cover_limit_robust), 3)
    out$e2_se_ratio_mean    <- round(mean(e2$scatter$se_ratio), 4)
    out$e2_sd_single_min    <- round(min(e2$scatter$sd_log), 3)
    out$e2_sd_single_max    <- round(max(e2$scatter$sd_log), 3)
    out$e2_n_regime_pairs   <- nrow(e2$scatter)

    ## THE PER-CELL TABLES, so results/e2-results.md is checkable the same way
    ## the protocol is. Three of this study's fatal findings were tables of
    ## numbers that no longer followed from the code, and until now the only
    ## document guarded against that was the protocol; the results files feed
    ## the manuscript and were guarded by nothing.
    cellwise <- function(d, f) {
      g <- split(d, list(d$kappa_a, d$kappa_b), drop = TRUE)
      g <- g[order(vapply(g, function(z) z$kappa_b[1], 0),
                   vapply(g, function(z) z$kappa_a[1], 0))]
      lapply(unname(g), function(z) c(list(kappa_a = z$kappa_a[1],
                                           kappa_b = z$kappa_b[1]), f(z)))
    }
    ## Both columns report the WORST regime pair in the cell. The published
    ## table paired a worst-case bias with the cell's BEST coverage, which
    ## flatters the row: bias 0.0079 next to coverage 0.958 in the hardest cell,
    ## where that cell's worst coverage is 0.937. Nothing about the conclusion
    ## changes, since every cell is near nominal either way, but a table whose
    ## two columns take opposite extremes is not a summary of anything.
    out$e2_cells <- cellwise(e2$scatter, function(z) list(
      worst_abs_bias = round(max(abs(z$bias_log)), 4),
      worst_cover    = round(min(z$cover_limit), 3),
      best_cover     = round(max(z$cover_limit), 3)))
    out$e2_discriminate_cells <- cellwise(e2$discriminate, function(z) list(
      worst_shift_per_sd = round(max(abs(z$shift_per_sd)), 3),
      max_detect         = round(max(z$p_two_networks_differ), 3)))
    ## Crossed against matched follow-up: E1 computes that the two legs'
    ## movements partly cancel when both are followed alike, and E2's own
    ## numbers are what test it.
    dm <- e2$discriminate
    out$e2_shift_crossed <- round(max(abs(dm$shift_per_sd[!dm$matched])), 3)
    out$e2_shift_matched <- round(max(abs(dm$shift_per_sd[dm$matched])), 3)
  }
}

## --- E1's per-row tables, so results/e1-results.md is checkable too ----------
## Same reason as the E2 block: these tables feed the manuscript and nothing
## checked them. Rows are exported with their keys so the verifier can match on
## (arm, kappa_a, kappa_b) rather than on position.
if (file.exists("results/e1-decomposition.rds")) {
  e1 <- readRDS("results/e1-decomposition.rds")
  rows <- function(d, f) lapply(seq_len(nrow(d)), function(i) f(d[i, ]))
  out$e1_factorial <- rows(e1$factorial, function(r) list(
    kappa_b = r$kappa_b, gamma = r$gamma, spread_pct = signif(r$spread_pct, 4)))
  out$e1_ablations <- rows(e1$ablations, function(r) list(
    ablation = r$ablation, spread_pct = signif(r$spread_pct, 2)))
  out$e1_least_false <- rows(e1$least_false, function(r) list(
    arm = r$arm, kappa_a = r$kappa_a, kappa_b = r$kappa_b,
    spread_pct = signif(r$spread_pct, 4), diag_pct = signif(r$diag_pct, 4),
    leg_a = signif(r$leg_a_spread_pct, 4), leg_b = signif(r$leg_b_spread_pct, 4)))
  out$e1_d3 <- rows(e1$d3, function(r) list(
    arm = r$arm, kappa_a = r$kappa_a, kappa_b = r$kappa_b,
    truth = round(r$truth, 2), lo = round(r$lo, 3), hi = round(r$hi, 3),
    range = signif(r$range, 4), range_diag = signif(r$range_diag, 4)))
}

## --- section 8's cell-properties table --------------------------------------
## Found by sweeping the protocol for decimal literals the export could not
## justify. The table came from `results/cell-properties.rds`, which NOTHING
## WRITES: it is an orphan from before round 5, and it still carried the
## `ph_reject` column computed on a direct B-versus-A trial. Round 5's fatal
## finding was that no such trial exists in this network, and the per-leg
## replacement went into one of the protocol's two PH tables but not the other,
## so section 8 was still publishing a withdrawn statistic.
##
## The fix is to compute the properties HERE, from `build_cells()`, so the table
## is a function of the registered design rather than of a file on disk. A saved
## result that no code regenerates cannot be checked against anything.
## The rejection rates are cached by R/16-ph-power.R at 2,000 replicates rather
## than recomputed here at 200, because a rate near 0.65 off 200 replicates has a
## standard error of 0.034 and the protocol was printing three decimals of it.
if (file.exists("results/ph-power.rds")) {
  pw <- readRDS("results/ph-power.rds")
  out$ph_n_rep    <- attr(pw, "n_rep_ph")
  out$ph_worst_se <- signif(max(c(pw$leg_a_se, pw$leg_b_se)), 3)
  out$cell_properties <- lapply(seq_len(nrow(pw)), function(i) { p <- pw[i, ]
    list(arm = p$arm, family = p$family, kappa_a = p$kappa_a,
         kappa_b = p$kappa_b, gamma = p$gamma,
         cond_cross = if (is.na(p$cond_cross)) NULL else round(p$cond_cross, 1),
         marg_cross = if (is.na(p$marg_cross)) NULL else round(p$marg_cross, 0),
         hr_min = round(p$hr_min, 3), hr_max = round(p$hr_max, 3),
         at_risk_a = round(p$at_risk_tau_a, 3),
         at_risk_b = round(p$at_risk_tau_b, 3),
         ph_reject_leg_a = round(p$leg_a, 3),
         ph_reject_leg_b = round(p$leg_b, 3)) })
}

## --- the DGM verifiers, which the protocol quotes to four figures ------------
if (file.exists("results/dgm-verification.rds")) {
  v <- readRDS("results/dgm-verification.rds")
  out$verify_invariance     <- signif(v$invariance, 4)
  out$verify_kappa_isolates <- signif(v$kappa_isolates, 4)
  out$verify_cox_limit      <- signif(v$cox_limit, 4)
  out$verify_truth_worst    <- signif(v$truth_worst, 4)
  ## Exactly zero, and stated as exactly zero: placebo survival is identical at
  ## every covariate value because the registered mechanism gives placebo no
  ## covariate term at all. Round 6 found this property asserted in prose in six
  ## files while eighteen call sites built placebo with a nonzero gamma.
  out$dgm_placebo_flat      <- v$placebo_flat
}

## --- the graft error, which answers round 4's fair-comparison objection ------
if (file.exists("results/graft-error.rds")) {
  ge <- readRDS("results/graft-error.rds")
  out$graft_worst <- round(ge$graft$graft_bias_delta[
    which.max(abs(ge$graft$graft_bias_delta))], 4)
  out$graft_zero_at_gamma0 <- signif(max(abs(
    ge$graft$graft_bias_delta[ge$graft$gamma == 0])), 3)
  out$stc_structural_worst <- signif(max(abs(ge$stc$stc_structural_bias)), 3)
}

## --- the integration measurement, pooled across every run that survived -----
if (file.exists("results/integration-pooled.rds")) {
  ip <- readRDS("results/integration-pooled.rds")
  pr <- function(lo, hi) {
    w <- reshape(ip[ip$n_int %in% c(lo, hi), c("rep", "n_int", "est")],
                 idvar = "rep", timevar = "n_int", direction = "wide")
    w <- w[complete.cases(w), ]
    x <- w[[paste0("est.", hi)]] - w[[paste0("est.", lo)]]
    if (length(x) < 2) return(NULL)
    list(n = length(x), mean = round(mean(x), 4),
         se = round(sd(x) / sqrt(length(x)), 4),
         t = round(mean(x) / (sd(x) / sqrt(length(x))), 2),
         ci_hi = round(mean(x) + 1.96 * sd(x) / sqrt(length(x)), 4))
  }
  out$integration <- Filter(Negate(is.null),
    list(`128_vs_64` = pr(64, 128), `256_vs_64` = pr(64, 256),
         `256_vs_128` = pr(128, 256)))
  out$fit_secs <- as.list(round(tapply(ip$secs, ip$n_int, mean), 1))
}

## --- the ARM-DIFFERENTIAL integration error ---------------------------------
## Found by the author while answering round 5, not raised by any reviewer.
## Every earlier integration probe fitted only the FLEXIBLE arm, so it could
## measure the quadrature error of one estimator and say nothing about the
## registered contrast, which is flexible against proportional WITHIN the ML-NMR
## row. Extending the probe to the proportional arm shows the two errors moving
## in OPPOSITE directions, which means they add in that difference instead of
## cancelling. This block computes the differential paired on the replicate.
if (file.exists("results/integration-256-512.rds")) {
  q <- readRDS("results/integration-256-512.rds")
  w <- reshape(q[, c("rep", "n_int", "arm", "est")], idvar = c("rep", "arm"),
               timevar = "n_int", direction = "wide")
  w <- w[complete.cases(w), ]
  w$d <- w$est.512 - w$est.256
  summ <- function(z) if (length(z) < 2) NULL else list(
    n = length(z), mean = round(mean(z), 4),
    se = round(sd(z) / sqrt(length(z)), 4),
    t = round(mean(z) / (sd(z) / sqrt(length(z))), 2))
  arm_of <- function(a) summ(w$d[w$arm == a])
  k <- intersect(w$rep[w$arm == "flex"], w$rep[w$arm == "ph"])
  paired <- w$d[w$arm == "flex"][match(k, w$rep[w$arm == "flex"])] -
            w$d[w$arm == "ph"][match(k, w$rep[w$arm == "ph"])]
  out$integration_512 <- Filter(Negate(is.null),
    list(flex = arm_of("flex"), ph = arm_of("ph"), differential = summ(paired)))
  if (length(paired) >= 2) {
    m <- mean(paired); s <- sd(paired) / sqrt(length(paired))
    ## The bound registered against it, on the same principle as the MAIC graft
    ## in section 7.2: a difference this study cannot distinguish from its own
    ## quadrature error is withdrawn BEFORE the run, not explained after it.
    out$integration_512_bound <- round(m + 1.96 * s, 4)
  }
}

## --- the baseline-pooling check, round 5's flexible-arm finding --------------
if (file.exists("results/pooling-check.rds")) {
  pc <- readRDS("results/pooling-check.rds")
  out$pool_worst_variation <- signif(pc$worst, 3)
  out$pool_shift_weibull  <- round(pc$check$shift[pc$check$family == "weibull"][1], 6)
  out$pool_shift_gompertz <- round(pc$check$shift[pc$check$family == "gompertz"][1], 6)
}

## --- the flexible arm's target anchoring, round 5's other finding ------------
## The truth comes from results/anchoring-truth.rds, written by the diagnostic
## itself out of the DGM. It was previously three literals typed here, and a
## typed truth is not a check on anything.
if (file.exists("results/anchoring-truth.rds")) {
  at <- readRDS("results/anchoring-truth.rds")
  tr <- at$truth
  out$anchor_truth        <- as.list(round(tr, 3))
  out$anchor_truth_diff   <- round(unname(tr["B"] - tr["A"]), 3)
  out$anchor_wrong_target <- round(at$wrong_anchor, 3)

  ## One summary per (arm size, integration order) dataset. Keyed by the run
  ## context stored on the checkpoint, not by the file name.
  summarize_anchor <- function(path) {
    if (!file.exists(path)) return(NULL)
    d <- readRDS(path); n <- nrow(d)
    if (is.null(n) || n < 2) return(NULL)
    dif <- d$B - d$A
    mc  <- function(z) round(sd(z, na.rm = TRUE) / sqrt(sum(is.finite(z))), 3)
    list(n_int = as.integer(attr(d, "n_int")), n_mult = attr(d, "n_mult"),
         n_ipd = attr(d, "n_ipd"), n_agd = attr(d, "n_agd"), n = n,
         fit_pbo   = round(mean(d$PBO), 3),
         err_pbo   = round(mean(d$PBO) - unname(tr["PBO"]), 3),
         mcse_pbo  = mc(d$PBO),
         err_a     = round(mean(d$A) - unname(tr["A"]), 3),
         err_b     = round(mean(d$B) - unname(tr["B"]), 3),
         err_diff  = round(mean(dif) - unname(tr["B"] - tr["A"]), 3),
         mcse_diff = mc(dif),
         reps      = d$rep)
  }
  paths <- c(x1_256 = "results/anchoring-check.rds",
             x1_64  = "results/anchoring-64-x1.rds",
             x4_64  = "results/anchoring-64-x4.rds",
             x16_64 = "results/anchoring-64-x16.rds")
  anc <- Filter(Negate(is.null), lapply(paths, summarize_anchor))
  out$anchor <- lapply(anc, function(z) { z$reps <- NULL; z })

  ## Backward-compatible scalars: the production-settings run is what sections
  ## 7.1 and 12 quote, and the verifier already asserts these keys.
  if (!is.null(anc$x1_256)) {
    out$anchor_n        <- anc$x1_256$n
    out$anchor_err_pbo  <- anc$x1_256$err_pbo
    out$anchor_err_diff <- anc$x1_256$err_diff
    out$anchor_mcse_pbo <- anc$x1_256$mcse_pbo
  }

  ## The 64-point run exists only to make the large-sample arm affordable, so
  ## the claim that 64 reproduces 256 is exported rather than asserted in prose.
  if (!is.null(anc$x1_64) && !is.null(anc$x1_256)) {
    k <- intersect(anc$x1_64$reps, anc$x1_256$reps)
    a <- readRDS("results/anchoring-64-x1.rds")
    b <- readRDS("results/anchoring-check.rds")
    a <- a[match(k, a$rep), ]; b <- b[match(k, b$rep), ]
    out$anchor_order_agreement <- list(
      n = length(k),
      worst_abs = signif(max(abs(unlist(a[, c("PBO","A","B")]) -
                                 unlist(b[, c("PBO","A","B")]))), 3))
  }

  ## The structural-against-finite-sample decomposition that stood here is
  ## removed. It decomposed an absolute-scale bias that the placebo correction
  ## showed did not exist; the residual now changes sign between the two arm
  ## sizes, so there is no decay rate to fit.
}

## --- section 8's cell-properties table --------------------------------------
## Found by sweeping the protocol for decimal literals the export could not
## justify. The table came from `results/cell-properties.rds`, which NOTHING
## WRITES: it is an orphan from before round 5, and it still carried the
## `ph_reject` column computed on a direct B-versus-A trial. Round 5's fatal
## finding was that no such trial exists in this network, and the per-leg
## replacement went into one of the protocol's two PH tables but not the other,
## so section 8 was still publishing a withdrawn statistic.
##
## The fix is to compute the properties HERE, from `build_cells()`, so the table
## is a function of the registered design rather than of a file on disk. A saved
## result that no code regenerates cannot be checked against anything.
## The rejection rates are cached by R/16-ph-power.R at 2,000 replicates rather
## than recomputed here at 200, because a rate near 0.65 off 200 replicates has a
## standard error of 0.034 and the protocol was printing three decimals of it.
if (file.exists("results/ph-power.rds")) {
  pw <- readRDS("results/ph-power.rds")
  out$ph_n_rep    <- attr(pw, "n_rep_ph")
  out$ph_worst_se <- signif(max(c(pw$leg_a_se, pw$leg_b_se)), 3)
  out$cell_properties <- lapply(seq_len(nrow(pw)), function(i) { p <- pw[i, ]
    list(arm = p$arm, family = p$family, kappa_a = p$kappa_a,
         kappa_b = p$kappa_b, gamma = p$gamma,
         cond_cross = if (is.na(p$cond_cross)) NULL else round(p$cond_cross, 1),
         marg_cross = if (is.na(p$marg_cross)) NULL else round(p$marg_cross, 0),
         hr_min = round(p$hr_min, 3), hr_max = round(p$hr_max, 3),
         at_risk_a = round(p$at_risk_tau_a, 3),
         at_risk_b = round(p$at_risk_tau_b, 3),
         ph_reject_leg_a = round(p$leg_a, 3),
         ph_reject_leg_b = round(p$leg_b, 3)) })
}

## --- the DGM verifiers, which the protocol quotes to four figures ------------
if (file.exists("results/dgm-verification.rds")) {
  v <- readRDS("results/dgm-verification.rds")
  out$verify_invariance     <- signif(v$invariance, 4)
  out$verify_kappa_isolates <- signif(v$kappa_isolates, 4)
  out$verify_cox_limit      <- signif(v$cox_limit, 4)
  out$verify_truth_worst    <- signif(v$truth_worst, 4)
  ## Exactly zero, and stated as exactly zero: placebo survival is identical at
  ## every covariate value because the registered mechanism gives placebo no
  ## covariate term at all. Round 6 found this property asserted in prose in six
  ## files while eighteen call sites built placebo with a nonzero gamma.
  out$dgm_placebo_flat      <- v$placebo_flat
}

## --- the graft error, which answers round 4's fair-comparison objection ------
if (file.exists("results/graft-error.rds")) {
  ge <- readRDS("results/graft-error.rds")
  out$graft_worst <- round(ge$graft$graft_bias_delta[
    which.max(abs(ge$graft$graft_bias_delta))], 4)
  out$graft_zero_at_gamma0 <- signif(max(abs(
    ge$graft$graft_bias_delta[ge$graft$gamma == 0])), 3)
  out$stc_structural_worst <- signif(max(abs(ge$stc$stc_structural_bias)), 3)
}

## --- the integration measurement, pooled across every run that survived -----
if (file.exists("results/integration-pooled.rds")) {
  ip <- readRDS("results/integration-pooled.rds")
  pr <- function(lo, hi) {
    w <- reshape(ip[ip$n_int %in% c(lo, hi), c("rep", "n_int", "est")],
                 idvar = "rep", timevar = "n_int", direction = "wide")
    w <- w[complete.cases(w), ]
    x <- w[[paste0("est.", hi)]] - w[[paste0("est.", lo)]]
    if (length(x) < 2) return(NULL)
    list(n = length(x), mean = round(mean(x), 4),
         se = round(sd(x) / sqrt(length(x)), 4),
         t = round(mean(x) / (sd(x) / sqrt(length(x))), 2),
         ci_hi = round(mean(x) + 1.96 * sd(x) / sqrt(length(x)), 4))
  }
  out$integration <- Filter(Negate(is.null),
    list(`128_vs_64` = pr(64, 128), `256_vs_64` = pr(64, 256),
         `256_vs_128` = pr(128, 256)))
  out$fit_secs <- as.list(round(tapply(ip$secs, ip$n_int, mean), 1))
}

## --- the ARM-DIFFERENTIAL integration error ---------------------------------
## Found by the author while answering round 5, not raised by any reviewer.
## Every earlier integration probe fitted only the FLEXIBLE arm, so it could
## measure the quadrature error of one estimator and say nothing about the
## registered contrast, which is flexible against proportional WITHIN the ML-NMR
## row. Extending the probe to the proportional arm shows the two errors moving
## in OPPOSITE directions, which means they add in that difference instead of
## cancelling. This block computes the differential paired on the replicate.
if (file.exists("results/integration-256-512.rds")) {
  q <- readRDS("results/integration-256-512.rds")
  w <- reshape(q[, c("rep", "n_int", "arm", "est")], idvar = c("rep", "arm"),
               timevar = "n_int", direction = "wide")
  w <- w[complete.cases(w), ]
  w$d <- w$est.512 - w$est.256
  summ <- function(z) if (length(z) < 2) NULL else list(
    n = length(z), mean = round(mean(z), 4),
    se = round(sd(z) / sqrt(length(z)), 4),
    t = round(mean(z) / (sd(z) / sqrt(length(z))), 2))
  arm_of <- function(a) summ(w$d[w$arm == a])
  k <- intersect(w$rep[w$arm == "flex"], w$rep[w$arm == "ph"])
  paired <- w$d[w$arm == "flex"][match(k, w$rep[w$arm == "flex"])] -
            w$d[w$arm == "ph"][match(k, w$rep[w$arm == "ph"])]
  out$integration_512 <- Filter(Negate(is.null),
    list(flex = arm_of("flex"), ph = arm_of("ph"), differential = summ(paired)))
  if (length(paired) >= 2) {
    m <- mean(paired); s <- sd(paired) / sqrt(length(paired))
    ## The bound registered against it, on the same principle as the MAIC graft
    ## in section 7.2: a difference this study cannot distinguish from its own
    ## quadrature error is withdrawn BEFORE the run, not explained after it.
    out$integration_512_bound <- round(m + 1.96 * s, 4)
  }
}

## --- the baseline-pooling check, round 5's flexible-arm finding --------------
if (file.exists("results/pooling-check.rds")) {
  pc <- readRDS("results/pooling-check.rds")
  out$pool_worst_variation <- signif(pc$worst, 3)
  out$pool_shift_weibull  <- round(pc$check$shift[pc$check$family == "weibull"][1], 6)
  out$pool_shift_gompertz <- round(pc$check$shift[pc$check$family == "gompertz"][1], 6)
}

## --- the flexible arm's target anchoring, round 5's other finding ------------
## The truth comes from results/anchoring-truth.rds, written by the diagnostic
## itself out of the DGM. It was previously three literals typed here, and a
## typed truth is not a check on anything.
if (file.exists("results/anchoring-truth.rds")) {
  at <- readRDS("results/anchoring-truth.rds")
  tr <- at$truth
  out$anchor_truth        <- as.list(round(tr, 3))
  out$anchor_truth_diff   <- round(unname(tr["B"] - tr["A"]), 3)
  out$anchor_wrong_target <- round(at$wrong_anchor, 3)

  ## One summary per (arm size, integration order) dataset. Keyed by the run
  ## context stored on the checkpoint, not by the file name.
  summarize_anchor <- function(path) {
    if (!file.exists(path)) return(NULL)
    d <- readRDS(path); n <- nrow(d)
    if (is.null(n) || n < 2) return(NULL)
    dif <- d$B - d$A
    mc  <- function(z) round(sd(z, na.rm = TRUE) / sqrt(sum(is.finite(z))), 3)
    list(n_int = as.integer(attr(d, "n_int")), n_mult = attr(d, "n_mult"),
         n_ipd = attr(d, "n_ipd"), n_agd = attr(d, "n_agd"), n = n,
         fit_pbo   = round(mean(d$PBO), 3),
         err_pbo   = round(mean(d$PBO) - unname(tr["PBO"]), 3),
         mcse_pbo  = mc(d$PBO),
         err_a     = round(mean(d$A) - unname(tr["A"]), 3),
         err_b     = round(mean(d$B) - unname(tr["B"]), 3),
         err_diff  = round(mean(dif) - unname(tr["B"] - tr["A"]), 3),
         mcse_diff = mc(dif),
         reps      = d$rep)
  }
  paths <- c(x1_256 = "results/anchoring-check.rds",
             x1_64  = "results/anchoring-64-x1.rds",
             x4_64  = "results/anchoring-64-x4.rds",
             x16_64 = "results/anchoring-64-x16.rds")
  anc <- Filter(Negate(is.null), lapply(paths, summarize_anchor))
  out$anchor <- lapply(anc, function(z) { z$reps <- NULL; z })

  ## Backward-compatible scalars: the production-settings run is what sections
  ## 7.1 and 12 quote, and the verifier already asserts these keys.
  if (!is.null(anc$x1_256)) {
    out$anchor_n        <- anc$x1_256$n
    out$anchor_err_pbo  <- anc$x1_256$err_pbo
    out$anchor_err_diff <- anc$x1_256$err_diff
    out$anchor_mcse_pbo <- anc$x1_256$mcse_pbo
  }

  ## The 64-point run exists only to make the large-sample arm affordable, so
  ## the claim that 64 reproduces 256 is exported rather than asserted in prose.
  if (!is.null(anc$x1_64) && !is.null(anc$x1_256)) {
    k <- intersect(anc$x1_64$reps, anc$x1_256$reps)
    a <- readRDS("results/anchoring-64-x1.rds")
    b <- readRDS("results/anchoring-check.rds")
    a <- a[match(k, a$rep), ]; b <- b[match(k, b$rep), ]
    out$anchor_order_agreement <- list(
      n = length(k),
      worst_abs = signif(max(abs(unlist(a[, c("PBO","A","B")]) -
                                 unlist(b[, c("PBO","A","B")]))), 3))
  }

  ## Structural against finite-sample, on the replicates the two arm sizes
  ## share, because an unpaired comparison here mixes in seed variation.
  if (!is.null(anc$x1_64) && !is.null(anc$x4_64)) {
    a <- readRDS("results/anchoring-64-x1.rds")
    b <- readRDS("results/anchoring-64-x4.rds")
    k <- intersect(a$rep, b$rep)
    a <- a[match(k, a$rep), ]; b <- b[match(k, b$rep), ]
    b1 <- mean(a$PBO) - unname(tr["PBO"]); b4 <- mean(b$PBO) - unname(tr["PBO"])
    dd <- b$PBO - a$PBO
    out$anchor_scaling <- list(
      n_paired = length(k),
      bias_x1 = round(b1, 3), bias_x4 = round(b4, 3),
      ratio = round(b4 / b1, 3),
      paired_change = round(mean(dd), 3),
      paired_mcse   = round(sd(dd) / sqrt(length(dd)), 3),
      paired_t      = round(mean(dd) / (sd(dd) / sqrt(length(dd))), 2),
      pred_x4_1_over_n = round(b1 / 4, 3),
      pred_x4_1_over_sqrt_n = round(b1 / 2, 3),
      pred_x4_structural = round(b1, 3),
      floor_c = round(b1 - 2 * (b1 - b4), 3), decay_d = round(2 * (b1 - b4), 3),
      pred_x16_1_over_sqrt_n = round(b1 / 4, 3),
      pred_x16_two_part = round(b1 - 2 * (b1 - b4) + (2 * (b1 - b4)) / 4, 3),
      pred_x16_structural = round(b1, 3))
  }
}

## --- measured costs and the computed budget ---------------------------------
## These come from timing files written by the probes rather than from prose, so
## a budget line can be checked against the measurement that justifies it.
if (file.exists("results/production-timing.rds")) {
  ti <- readRDS("results/production-timing.rds")
  out$cost <- lapply(ti, function(z) if (is.numeric(z)) round(z, 4) else z)
  out$refit_rate_assumed <- REFIT_RATE_ASSUMED
  out$divergent_rate_max <- DIVERGENT_RATE_MAX
  Sys.setenv(BUDGET_NOMAIN = "1"); source("R/10-budget.R")
  b <- budget(ti); b$unit <- NULL
  out$budget <- b
}

## --- D3's numerical error, measured rather than borrowed ---------------------
## Round 6 found version 5 bounding it with the PROPORTIONAL control cell's
## across-regime cancellation, which measures how exactly two nearly identical
## calculations cancel in the easiest case rather than the absolute error of a
## root-find through a crossing marginal hazard. The replacement is a convergence
## study.
if (file.exists("results/d3-convergence.rds")) {
  cv <- readRDS("results/d3-convergence.rds")
  out$d3_conv_worst_move <- signif(cv$worst_move, 2)
  out$d3_conv_margin     <- round(cv$margin, 4)
  out$d3_conv_ratio_cell <- floor(cv$ratio_per_cell)
  out$d3_conv_stable     <- cv$verdict_stable
  out$d3_conv_flips_base <- sum(cv$flips_base > 0)
  out$d3_conv_flips_fine <- sum(cv$flips_fine > 0)
}

## --- whether a pooling-matched proportional ML-NMR arm exists ----------------
## The registered within-row contrast changes proportionality and baseline
## pooling together. Two candidate specifications that would separate them were
## tried; the export records which, if any, multinma 0.9.1 accepts, so the scope
## limitation in section 12 rests on a result rather than on a recollection.
if (file.exists("results/pooled-ph-probe.rds")) {
  pp <- readRDS("results/pooled-ph-probe.rds")
  out$pooled_ph_usable <- if (is.null(pp$usable)) character(0) else pp$usable
  out$pooled_ph_tried <- vapply(pp[c("pooled_ph", "const_ph")],
                                function(z) z$label, "")
  out$pooled_ph_rejected <- sum(vapply(pp[c("pooled_ph", "const_ph")],
                                       function(z) !isTRUE(z$ok), TRUE))
}

## --- the sensitivity program, exported so the protocol's table is checkable --
## Round 6 found the arms registered in prose with no cells named, no driver and
## no reachable settings, and priced at roughly half their minimum cost. The
## table in section 14 is now generated from these two objects rather than typed
## beside them.
out$sens_cells <- SENS_CELLS
out$sens_settings <- SENS_SETTINGS
out$sens_n_per_cell <- N_SENS_PER_CELL
out$sens_n <- N_SENS
out$n_mcse_rep <- N_MCSE_REP
out$n_knots <- N_KNOTS
out$prior_scales <- list(reg = PRIOR_REG_SD, aux = PRIOR_AUX_SD,
                         aux_reg = PRIOR_AUX_REG_SD)

writeLines(toJSON(out, auto_unbox = TRUE, digits = 8, null = "null"),
           "results/registered-design.json")
cat("written: results/registered-design.json\n")
cat(sprintf("exported %d top-level keys, %d cells\n", length(out), length(out$cells)))
