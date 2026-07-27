## Run the design.
##
##   Rscript R/03-run.R
##
## Resumable: completed scenarios are cached under results/raw/ and skipped.
## Delete that directory to force a full rerun.

## Resolve the study directory from this script's own location, so the script
## runs the same from the study directory, the repository root, or RStudio.
.f <- grep("^--file=", commandArgs(FALSE), value = TRUE)
STUDY <- if (length(.f)) dirname(dirname(normalizePath(sub("^--file=", "", .f[1]))))
         else normalizePath(".")
here <- function(...) file.path(STUDY, ...)
stopifnot(file.exists(here("R", "00-config.R")))

source(here("R", "02-estimators.R"))
source(here("R", "01-dgm.R"))
source(here("R", "00-config.R"))
source(here("..", "_shared", "R", "harness.R"))

OUTDIR <- here("results")
dir.create(OUTDIR, recursive = TRUE, showWarnings = FALSE)

scenarios <- build_scenarios()

## One replicate: generate, estimate, return one row per method.
##
## A replicate on which the fit failed still returns rows, one per method, with a
## missing estimate and the reason recorded. That is what makes the convergence
## rate in the analysis a real denominator rather than the count of replicates
## that happened to work.
one_rep <- function(scen, rep_id) {
  r <- gen_replicate(nS = scen$nS, nT = scen$nT, d = scen$d,
                     rho_S = scen$rho_S, rho_T = scen$rho_T,
                     em_sd = scen$em_sd, kappa = scen$kappa)
  ## The analyst borrows the source correlation, because a published baseline
  ## table does not identify the target's. Whether that borrowing is right is
  ## the rho_T factor.
  out <- estimate_all(r, equicorr(3, scen$rho_S))
  if (inherits(out, "estim_fail")) {
    return(data.frame(
      method = c("target-fixed", "normal-recon", "reported-cov", "joint-score"),
      est = NA_real_, se = NA_real_, lower = NA_real_, upper = NA_real_,
      ess = NA_real_, max_imbalance = NA_real_,
      fail = attr(out, "why"), stringsAsFactors = FALSE))
  }
  out$fail <- NA_character_
  out
}

res <- run_design(one_rep, scenarios, n_rep = N_REP, master_seed = MASTER_SEED,
                  outdir = OUTDIR)

write_provenance(
  OUTDIR,
  packages = c("stats", "future", "furrr"),
  extra = list(
    study = "MIS-03 / EST-07 target-moment uncertainty",
    scenarios = nrow(scenarios),
    replicates_per_scenario = N_REP,
    total_replicates = nrow(scenarios) * N_REP,
    master_seed = MASTER_SEED
  )
)

cat(sprintf("\n%d rows over %d scenarios x %d replicates x 4 methods\n",
            nrow(res), nrow(scenarios), N_REP))
cat(sprintf("replicate failures: %d (%.3f%%)\n",
            sum(!is.na(res$fail)) / 4, 100 * mean(!is.na(res$fail))))
if (any(!is.na(res$fail))) print(table(res$fail))
