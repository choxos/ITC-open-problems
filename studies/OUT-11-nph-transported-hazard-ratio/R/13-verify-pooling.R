## ---------------------------------------------------------------------------
## Does the flexible ML-NMR arm's baseline POOLING cost anything here?
##
## Round 5 found that the two ML-NMR arms differ in two ways at once, not one:
##
##   MLNMR-PH    aux_by = c(.study)      -> scoef[S1, k], scoef[S2, k]
##                                          baseline spline is STUDY-SPECIFIC
##   MLNMR-flex  aux_regression = ~ .trt -> beta_aux[.trtPBO, k], [.trtA, k], ...
##                                          baseline spline is TREATMENT-specific
##                                          and POOLED ACROSS STUDIES
##
## That is the same confound round 2 raised against the MAIC and STC rows, in the
## row that had been treated as clean, and it sits inside a registered primary
## contrast. `aux_by` cannot be combined with `aux_regression` (documented), and
## adding `.study` to the aux_regression formula is SILENTLY IGNORED: both
## `~ .trt` and `~ .study + .trt` produce the same 18 treatment-indexed
## parameters, with no error and no warning. So multinma 0.9.1 offers no
## specification giving both non-proportional hazards and study-specific
## baselines. That is a reportable finding about the method, of the same class as
## the aux_by transport failure in R/probe-integration.R.
##
## WHETHER IT DAMAGES THIS STUDY IS A SEPARATE QUESTION, AND THE ANSWER IS NO.
##
## Both arms retain study intercepts mu[S1], mu[S2]. What the pooling forces is a
## common baseline SHAPE, not a common level. This design's two studies differ
## only in Weibull scale (12 against 14) or Gompertz level (1/25 against 1/30),
## and both are pure LEVEL shifts on the log-cumulative-hazard scale:
##
##   Weibull   log H(t) = a0 log(t/s_j)              -> shift -a0 log(s_j)
##   Gompertz  log H(t) = log(b_j/xi) + log(e^{xi t} - 1) -> shift log(b_j)
##
## neither of which depends on t. The study intercepts absorb them exactly, so
## the pooled spline is not misspecified for this mechanism. This file checks
## that rather than asserting it, at every family, kappa, gamma and covariate
## value the design uses.
##
## THE LIMITATION THIS LEAVES is precise and is declared rather than buried: a
## mechanism whose two studies differ in baseline SHAPE, not merely level, would
## activate the software limitation, and this study does not test that case.
## ---------------------------------------------------------------------------

source("R/00-config.R")
source("R/01-dgm.R")

logH <- function(S) log(-log(pmax(S, 1e-300)))

pooling_check <- function(tt = seq(0.5, T_ADMIN, length.out = 400)) {
  g <- expand.grid(family = c("weibull", "gompertz"), kappa = c(0, 0.30),
                   gamma = c(0, GAMMA), x = c(-1, 0, 1),
                   stringsAsFactors = FALSE)
  do.call(rbind, lapply(seq_len(nrow(g)), function(i) {
    r <- g[i, ]
    ai <- make_arm(r$family, "ipd", beta = BETA_A, kappa = r$kappa, gamma = r$gamma)
    at <- make_arm(r$family, "tgt", beta = BETA_A, kappa = r$kappa, gamma = r$gamma)
    d  <- logH(arm_S(tt, r$x, ai)) - logH(arm_S(tt, r$x, at))
    data.frame(r, shift = mean(d), variation_over_t = max(d) - min(d))
  }))
}

if (!interactive() && Sys.getenv("POOL_NOMAIN") == "") {
  res <- pooling_check()
  cat("=== between-study baseline difference on the log-cumulative-hazard scale ===\n")
  print(res, row.names = FALSE, digits = 6)
  worst <- max(res$variation_over_t)
  cat(sprintf("\nworst variation over time: %.3e\n", worst))
  cat(sprintf("Weibull shift  %.6f  (a0 log(s_tgt/s_ipd) = %.6f)\n",
              res$shift[res$family == "weibull"][1], A0 * log(S_TGT / S_IPD)))
  cat(sprintf("Gompertz shift %.6f  (log(b_ipd/b_tgt)    = %.6f)\n",
              res$shift[res$family == "gompertz"][1], log(B_IPD / B_TGT)))
  if (worst > 1e-10)
    stop("the between-study difference is NOT a pure level shift; the flexible ",
         "arm's baseline pooling is then a real confound and the primary ",
         "within-row ML-NMR contrast cannot be read as isolating proportionality")
  cat("\nPASS: pure level shift, absorbed by the study intercepts. Pooling the\n")
  cat("baseline shape across studies costs nothing under this mechanism.\n")
  saveRDS(list(check = res, worst = worst), "results/pooling-check.rds")
  cat("\nwritten: results/pooling-check.rds\n")
}
