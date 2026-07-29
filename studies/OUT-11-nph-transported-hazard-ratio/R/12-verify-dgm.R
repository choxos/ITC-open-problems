## ---------------------------------------------------------------------------
## Run every data-generating-mechanism verifier and save the numbers, so the
## protocol's claims about them are asserted rather than remembered.
##
## These four checks are the reason the rebuilt parameterization is trusted at
## all, and the protocol quotes each of them to four significant figures. Until
## now those figures were typed from a terminal that has since scrolled away,
## which is exactly the provenance that let a whole stale table survive into
## version 4.
##
## verify_cox_limit simulates 400,000 per arm and takes a couple of minutes, so
## the results are cached here rather than recomputed by the exporter on every
## run.
##
##   Rscript R/12-verify-dgm.R
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(survival))
source("R/00-config.R")
source("R/01-dgm.R")
source("R/02-cox-limit.R")

## THE PLACEBO ARM IS NOT PROGNOSTIC.
##
## Round 6 found every analytic calculation in the study building placebo with
## gamma = GAMMA while sim_network builds it with gamma = 0, so E1, E2, the PH
## powers, the graft bound and the anchoring truth all described a mechanism the
## benchmark does not run. The protocol asserts the pure-effect-modifier property
## and verified it once, by hand, on one arm; nothing enforced it at the point
## where placebo arms are actually constructed.
verify_placebo_not_prognostic <- function(tol = 1e-12) {
  worst <- 0
  for (fam in c("weibull", "gompertz"))
    for (st in c("ipd", "tgt")) {
      a <- placebo_arm(fam, st)
      s <- vapply(c(-2, -1, 0, 1, 2), function(x) arm_S(12, x, a), 0)
      worst <- max(worst, max(s) - min(s))
    }
  if (worst > tol)
    stop("placebo survival depends on the covariate; the registered mechanism ",
         "makes it a pure effect modifier")
  worst
}

out <- list(
  ## 1. The treatment contrast does not depend on the study baseline, which is
  ##    what makes population adjustment separable from baseline differences.
  invariance = verify_invariance(),
  ## 2. kappa moves only the time-varying part of the contrast, so a cell's
  ##    non-proportionality is not confounded with its effect size.
  kappa_isolates = verify_kappa_isolates(),
  ## 3. The analytic least-false parameter agrees with a very large simulated
  ##    Cox fit. Tolerance is set by the SIMULATION's Monte Carlo error.
  cox_limit = verify_cox_limit(),
  ## 4. The quadrature truth agrees with Monte Carlo integration of the same
  ##    quantities, at both families and both arms.
  truth = as.list(verify_truth()),
  ## 5. Placebo survival does not depend on the covariate at all, so the
  ##    covariate is a pure effect modifier. Round 6 found this verifier written
  ##    and never called: it sat below the saveRDS that would have stored it, so
  ##    the property it enforces was checked by nothing. That is the same defect
  ##    class as the registered procedures with no implementation, in the file
  ##    whose whole purpose is to run the checks.
  placebo_flat = verify_placebo_not_prognostic())
out$truth_worst <- max(unlist(out$truth))

saveRDS(out, "results/dgm-verification.rds")
cat("=== DGM verification ===\n")
cat(sprintf("  invariance      %.4g   (baseline-invariance of the contrast)\n", out$invariance))
cat(sprintf("  kappa_isolates  %.4g   (kappa touches only the time-varying part)\n", out$kappa_isolates))
cat(sprintf("  cox_limit       %.4g   (analytic limit vs 400,000-per-arm Cox fit)\n", out$cox_limit))
cat(sprintf("  truth worst     %.4g   (quadrature vs Monte Carlo)\n", out$truth_worst))
cat(sprintf("  placebo flat    %.4g   (placebo survival spread over x in [-2, 2])\n",
            out$placebo_flat))
cat("\nwritten: results/dgm-verification.rds\n")
