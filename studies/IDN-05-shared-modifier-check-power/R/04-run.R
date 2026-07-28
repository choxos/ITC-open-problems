## ---------------------------------------------------------------------------
## Run the design. One checkpoint file per cell, so a killed run resumes.
##
##   Rscript R/04-run.R [n_workers]
## ---------------------------------------------------------------------------

## Pin every numerical library to one thread. Without this, each of the forked
## workers spawns its own thread pool and the machine thrashes: the first launch
## of this run reached load average 61 with the workers at 15% CPU each.
do.call(Sys.setenv, as.list(setNames(rep("1", 6),
  c("OMP_NUM_THREADS", "VECLIB_MAXIMUM_THREADS", "OPENBLAS_NUM_THREADS",
    "MKL_NUM_THREADS", "RCPP_PARALLEL_NUM_THREADS", "STAN_NUM_THREADS"))))

setwd(normalizePath(file.path(dirname(sub("^--file=", "",
  grep("^--file=", commandArgs(FALSE), value = TRUE)[1])), "..")))
source("R/00-config.R"); source("R/01-dgm.R")
source("R/02-fit.R"); source("R/03-replicate.R")
suppressPackageStartupMessages(library(parallel))

`%||%` <- function(a, b) if (is.null(a)) b else a

args <- commandArgs(TRUE)
N_WORKERS <- if (length(args)) as.integer(args[1]) else 3L
OUT <- "results/cells"; dir.create(OUT, recursive = TRUE, showWarnings = FALSE)

## The prior-sensitivity arm, prespecified: the thin end of the design, where the
## pre-run critique predicted the relaxed model would report the prior rather
## than the data, refitted with a normal(0, 1) prior on the regression
## coefficients instead of normal(0, 2.5).
PRIOR_SENS_CELLS <- DESIGN$cell[DESIGN$n_studies == 6L & DESIGN$spread == 0.25]
PRIOR_SENS_REP   <- 30L

## L'Ecuyer-CMRG streams indexed by (cell, replicate), so a replicate's data do
## not depend on how many workers happened to run. Seeds are assigned before any
## execution order is chosen.
RNGkind("L'Ecuyer-CMRG")
streams_for_cell <- function(cell) {
  set.seed(SEED_BASE, kind = "L'Ecuyer-CMRG")
  s <- .Random.seed
  for (i in seq_len((cell - 1L) * N_REP)) s <- parallel::nextRNGStream(s)
  out <- vector("list", N_REP)
  for (j in seq_len(N_REP)) { s <- parallel::nextRNGStream(s); out[[j]] <- s }
  out
}

run_cell <- function(ci, prior_reg = PRIOR_REG, n_rep = N_REP, tag = "") {
  f <- file.path(OUT, sprintf("cell-%03d%s.rds", ci, tag))
  if (file.exists(f)) return(sprintf("cell %3d%-6s cached", ci, tag))
  scen  <- as.list(DESIGN[ci, ])
  seeds <- streams_for_cell(ci)
  t0 <- Sys.time()

  reps <- mclapply(seq_len(n_rep), function(j) {
    assign(".Random.seed", seeds[[j]], envir = globalenv())
    tryCatch(one_replicate(scen, j, prior_reg),
             error = function(e) list(cell = ci, rep = j, ok = FALSE,
                                      reason = conditionMessage(e)))
  }, mc.cores = N_WORKERS, mc.preschedule = TRUE)

  ok <- vapply(reps, function(r) isTRUE(r$ok), TRUE)
  saveRDS(list(
    scen = scen,
    checks = do.call(rbind, lapply(reps[ok], check_rows)),
    est    = do.call(rbind, lapply(reps[ok], est_rows)),
    diag   = do.call(rbind, lapply(reps[ok], diag_rows)),
    n_ok = sum(ok), n_rep = n_rep,
    failures = if (any(!ok))
      vapply(reps[!ok], function(r) r$reason %||% "unknown", character(1)) else character(0)
  ), f)

  sprintf("cell %3d%-6s drift=%.2f J=%2d spread=%.2f tau=%.2f  ok=%3d/%3d  %5.1f min",
          ci, tag, scen$drift, scen$n_studies, scen$spread, scen$tau_re,
          sum(ok), n_rep, as.numeric(difftime(Sys.time(), t0, units = "mins")))
}

cat(sprintf("IDN-05: %d cells x %d replicates x %d fits = %s ML-NMR fits, %d workers\n",
            nrow(DESIGN), N_REP, length(FIT_SPLITS),
            format(nrow(DESIGN) * N_REP * length(FIT_SPLITS), big.mark = ","), N_WORKERS))
cat(sprintf("EPS (posterior margin, the contrast that is exactly material at displacement 1) = %.4f\n", EPS))
cat("MU_REF by displacement: ", paste(sprintf("%.4f", MU_REF), collapse = " "), "\n")
t_start <- Sys.time()

for (ci in seq_len(nrow(DESIGN))) { cat(run_cell(ci), "\n"); flush(stdout()) }

cat("\n-- prior sensitivity arm, normal(0, 1) on regression coefficients --\n")
for (ci in PRIOR_SENS_CELLS) {
  cat(run_cell(ci, PRIOR_REG_ALT, PRIOR_SENS_REP, "p1"), "\n"); flush(stdout())
}

cat(sprintf("done in %.2f h\n", as.numeric(difftime(Sys.time(), t_start, units = "hours"))))
