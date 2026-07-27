## Run the design.
##
##   Rscript R/04-run.R
##
## Resumable: completed scenarios are cached under results/raw/ and skipped.

.f <- grep("^--file=", commandArgs(FALSE), value = TRUE)
STUDY <- if (length(.f)) {
  dirname(dirname(normalizePath(sub("^--file=", "", .f[1]))))
} else {
  normalizePath(".")
}
here <- function(...) file.path(STUDY, ...)
stopifnot(file.exists(here("R", "00-config.R")))

source(here("R", "01-dgm.R"))
source(here("R", "02-estimators.R"))
source(here("R", "03-methods.R"))
source(here("R", "00-config.R"))
source(here("..", "_shared", "R", "harness.R"))

OUTDIR <- here("results")
dir.create(OUTDIR, recursive = TRUE, showWarnings = FALSE)

scenarios <- build_scenarios()

METHODS <- c("shared-info", "shared-sandwich", "joint-split", "ipd-anchored")
PARS <- c("gWA", "gWB")

blank <- function(why) {
  g <- expand.grid(method = METHODS, par = PARS, stringsAsFactors = FALSE)
  data.frame(g, est = NA_real_, se = NA_real_, lower = NA_real_, upper = NA_real_,
             not_estimable = FALSE, fail = why, stringsAsFactors = FALSE)
}

## One replicate. A replicate that fails still returns a full set of rows with a
## recorded reason, so convergence has a real denominator and the analysis can
## report performance both over converged replicates and counting failures as
## non-coverage, as the protocol requires.
one_rep <- function(scen, rep_id) {
  dat <- gen_replicate(n_arm = scen$n_arm, prev_set = scen$spread,
                       ipd_scheme = scen$ipd, pattern = scen$pattern,
                       structure = scen$network)
  r <- tryCatch(estimate_all(dat), error = function(e) NULL)
  if (is.null(r)) return(blank("estimation-failed"))
  ## Fill in any method-parameter combination the estimator declined to return,
  ## so every replicate contributes the same rows.
  full <- expand.grid(method = METHODS, par = PARS, stringsAsFactors = FALSE)
  m <- merge(full, r, by = c("method", "par"), all.x = TRUE)
  m$fail <- ifelse(is.na(m$est) & !m$not_estimable %in% TRUE, "no-interval", NA_character_)
  m$not_estimable[is.na(m$not_estimable)] <- FALSE
  m
}

res <- run_design(one_rep, scenarios, n_rep = N_REP, master_seed = MASTER_SEED,
                  outdir = OUTDIR)

write_provenance(
  OUTDIR, packages = c("stats", "future", "furrr"),
  extra = list(
    study = "CMP-13 / IDN-06 within versus across-trial component interaction",
    scenarios = nrow(scenarios),
    replicates_per_scenario = N_REP,
    total_datasets = nrow(scenarios) * N_REP,
    master_seed = MASTER_SEED))

cat(sprintf("\n%d rows over %d scenarios x %d replicates\n",
            nrow(res), nrow(scenarios), N_REP))
cat(sprintf("not estimable: %.2f%%   failed: %.2f%%\n",
            100 * mean(res$not_estimable, na.rm = TRUE),
            100 * mean(!is.na(res$fail))))
if (any(!is.na(res$fail))) print(table(res$fail))
