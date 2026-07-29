## ---------------------------------------------------------------------------
## Per-leg Grambsch-Therneau rejection rates, at enough replicates to print.
##
## TWO DEFECTS MADE THIS FILE NECESSARY, both found by sweeping the protocol for
## decimal literals the design export could not justify.
##
## FIRST: section 8's cell-properties table was read from
## `results/cell-properties.rds`, a file NOTHING WRITES. It predated round 5 and
## still carried `ph_reject`, the rate computed on a direct B-versus-A trial.
## Round 5's finding was that no such trial exists in this network: an analyst
## holds A-versus-placebo at 250 per arm and B-versus-placebo at 200, and runs
## the diagnostic on each separately. The per-leg replacement reached one of the
## protocol's two PH tables and not the other, so section 8 was still publishing
## a withdrawn statistic. A saved result that no code regenerates cannot be
## checked against anything, which is why the table is now computed.
##
## SECOND, and the reason this is a separate file rather than three lines in the
## exporter: these rates were being printed to three decimals off 200
## replicates. A rate near 0.65 then carries a Monte Carlo standard error of
## 0.034, so "0.627" and "0.660" are the same number and the third digit is
## noise presented as measurement. This study has already had to withdraw one
## finding that rested on Monte Carlo agreement mistaken for signal.
##
## N_REP_PH = 2000 puts the worst standard error at about 0.011, which supports
## the two decimals the protocol prints and no more. The run costs a few minutes
## and is cached, so the exporter stays fast and the numbers stay fixed.
##
##   Rscript R/16-ph-power.R          # writes results/ph-power.rds
## ---------------------------------------------------------------------------

source("R/04-calibrate.R")

PH_OUT     <- Sys.getenv("PH_OUT", "results/ph-power.rds")
N_REP_PH   <- as.integer(Sys.getenv("N_REP_PH", "2000"))

## One row per distinct cell of the registered design, so this table cannot
## drift from the design the way a hand-maintained list would.
cells <- build_cells()
keys  <- unique(cells[, c("arm", "family", "kappa_a", "kappa_b", "gamma",
                          "margin")])
keys  <- keys[order(match(keys$arm, c("primary", "margin", "control", "ipd-nph",
                                      "family")), keys$kappa_a, keys$kappa_b), ]

if (!interactive() && Sys.getenv("PHPOW_NOMAIN") == "") {
  done <- if (file.exists(PH_OUT)) readRDS(PH_OUT) else NULL
  if (!is.null(done) && !identical(attr(done, "n_rep_ph"), N_REP_PH)) {
    cat(sprintf("cached table was computed at %s replicates, not %d; recomputing\n",
                attr(done, "n_rep_ph"), N_REP_PH))
    done <- NULL
  }
  for (i in seq_len(nrow(keys))) {
    k <- keys[i, ]
    id <- paste(k$arm, k$family, k$kappa_a, k$kappa_b, k$gamma, k$margin)
    if (!is.null(done) && id %in% done$id) next
    bb <- cells$beta_b[cells$arm == k$arm & cells$family == k$family &
                       cells$kappa_a == k$kappa_a & cells$kappa_b == k$kappa_b &
                       cells$gamma == k$gamma & cells$margin == k$margin][1]
    t0 <- Sys.time()
    p <- cell_properties(k$family, bb, k$kappa_b, k$gamma, kappa_a = k$kappa_a,
                         n_rep_ph = N_REP_PH)
    ## Binomial standard error on each rate, so the protocol can state the
    ## precision it is entitled to instead of implying three exact decimals.
    se <- function(r) sqrt(r * (1 - r) / N_REP_PH)
    row <- data.frame(
      id = id, arm = k$arm, family = k$family, kappa_a = k$kappa_a,
      kappa_b = k$kappa_b, gamma = k$gamma, margin = k$margin, beta_b = bb,
      cond_cross = p$cond_cross, marg_cross = p$marg_cross,
      hr_min = p$hr_min, hr_max = p$hr_max,
      at_risk_tau_a = p$at_risk_tau_a, at_risk_tau_b = p$at_risk_tau_b,
      leg_a = p$ph_reject_leg_a, leg_b = p$ph_reject_leg_b,
      leg_a_se = se(p$ph_reject_leg_a), leg_b_se = se(p$ph_reject_leg_b),
      stringsAsFactors = FALSE)
    done <- rbind(done, row)
    attr(done, "n_rep_ph") <- N_REP_PH
    saveRDS(done, PH_OUT)                              # checkpoint per cell
    cat(sprintf("%-8s %-8s kA %.2f kB %.2f  legA %.3f (%.3f)  legB %.3f (%.3f)  %.0f s\n",
                k$arm, k$family, k$kappa_a, k$kappa_b, row$leg_a, row$leg_a_se,
                row$leg_b, row$leg_b_se,
                as.numeric(difftime(Sys.time(), t0, units = "secs"))))
    flush.console()
  }
  cat(sprintf("\n%d cells at %d replicates; worst standard error %.4f\n",
              nrow(done), N_REP_PH, max(c(done$leg_a_se, done$leg_b_se))))
  cat(sprintf("written: %s\n", PH_OUT))
}
