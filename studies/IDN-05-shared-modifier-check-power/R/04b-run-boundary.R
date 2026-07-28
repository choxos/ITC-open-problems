## ---------------------------------------------------------------------------
## The amendment arm: eight cells at drift 0.15, one EPS, the contrast that makes
## the target estimate exactly material at displacement 1.
##
## The registered grid is 0, 1.96, 3.92 and 7.84 EPS, so it has nothing between
## the null and twice the decision boundary. A pre-run critique that arrived
## mid-run identified that gap. These cells fill it. They are numbered 33 to 40 so
## that nothing about cells 1 to 32 changes.
##
##   Rscript R/04b-run-boundary.R [n_workers]
## ---------------------------------------------------------------------------

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

RNGkind("L'Ecuyer-CMRG")
streams_for_cell <- function(cell) {
  set.seed(SEED_BASE, kind = "L'Ecuyer-CMRG")
  s <- .Random.seed
  for (i in seq_len((cell - 1L) * N_REP)) s <- parallel::nextRNGStream(s)
  out <- vector("list", N_REP)
  for (j in seq_len(N_REP)) { s <- parallel::nextRNGStream(s); out[[j]] <- s }
  out
}

run_cell <- function(ci) {
  f <- file.path(OUT, sprintf("cell-%03d.rds", ci))
  if (file.exists(f)) return(sprintf("cell %3d cached", ci))
  scen <- as.list(DESIGN[DESIGN$cell == ci, ])
  seeds <- streams_for_cell(ci)
  t0 <- Sys.time()
  reps <- mclapply(seq_len(N_REP), function(j) {
    assign(".Random.seed", seeds[[j]], envir = globalenv())
    tryCatch(one_replicate(scen, j),
             error = function(e) list(cell = ci, rep = j, ok = FALSE,
                                      reason = conditionMessage(e)))
  }, mc.cores = N_WORKERS, mc.preschedule = TRUE)
  ok <- vapply(reps, function(r) isTRUE(r$ok), TRUE)
  saveRDS(list(scen = scen,
               checks = do.call(rbind, lapply(reps[ok], check_rows)),
               est    = do.call(rbind, lapply(reps[ok], est_rows)),
               diag   = do.call(rbind, lapply(reps[ok], diag_rows)),
               n_ok = sum(ok), n_rep = N_REP,
               failures = if (any(!ok))
                 vapply(reps[!ok], function(r) r$reason %||% "unknown",
                        character(1)) else character(0)), f)
  sprintf("cell %3d  drift=%.2f J=%2d spread=%.2f tau=%.2f  ok=%3d/%3d  %5.1f min",
          ci, scen$drift, scen$n_studies, scen$spread, scen$tau_re,
          sum(ok), N_REP, as.numeric(difftime(Sys.time(), t0, units = "mins")))
}

cat(sprintf("boundary arm: %d cells at drift %.2f (EPS = %.4f), %d replicates\n",
            length(BOUNDARY_CELLS), DESIGN$drift[DESIGN$cell == BOUNDARY_CELLS[1]],
            EPS, N_REP))
for (ci in BOUNDARY_CELLS) { cat(run_cell(ci), "\n"); flush(stdout()) }
cat("boundary arm done\n")
