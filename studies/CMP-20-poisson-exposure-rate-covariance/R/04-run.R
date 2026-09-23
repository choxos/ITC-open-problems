## ---------------------------------------------------------------------------
## The registered run. One file per cell, resumable by file existence.
##
##   WORKERS=3 Rscript R/04-run.R
##
## Each replicate's seed is a deterministic function of the cell and replicate, so
## results do not depend on scheduling and a resumed run reproduces a continuous
## one. Failed fits are recorded, never dropped.
## ---------------------------------------------------------------------------

source("R/02-fit.R")
RUN_DIR <- "results/run"

rep_seed <- function(cell, r) as.integer(MASTER_SEED %% 1e6 + 7919L * r + 104729L * cell)

run_replicate <- function(cell, r) {
  set.seed(rep_seed(cell$cell, r))
  d <- draw_network(cell)
  f <- fit_all(d)
  th <- truth(cell)
  row <- function(m, x) {
    if (is.null(x)) return(data.frame(method = m, est = NA_real_, se = NA_real_,
                                      lo = NA_real_, hi = NA_real_, ok = FALSE))
    z <- stats::qnorm(0.975)
    data.frame(method = m, est = x$est, se = x$se, lo = x$est - z * x$se,
               hi = x$est + z * x$se, ok = TRUE)
  }
  out <- rbind(row("unweighted", f$unweighted), row("weighted", f$weighted),
               row("borrowed", f$borrowed))
  if (!is.null(f$sens)) {
    out <- rbind(out, data.frame(method = "sensitivity", est = f$unweighted$est,
                                 se = NA_real_, lo = f$sens[["lo"]],
                                 hi = f$sens[["hi"]], ok = TRUE))
  } else out <- rbind(out, row("sensitivity", NULL))
  out$cell <- cell$cell; out$rep <- r; out$truth <- th
  out$realized_bias <- d$realized_bias
  ar <- if (is.null(f$unweighted)) c(NA, NA) else f$unweighted$arm_rate
  out$arm_rate_C <- ar[1]; out$arm_rate_B <- ar[2]
  out
}

run_cell <- function(cell) {
  f <- file.path(RUN_DIR, sprintf("cell-%03d.rds", cell$cell))
  if (file.exists(f)) return(invisible(NULL))
  res <- do.call(rbind, lapply(seq_len(N_SIM), function(r) run_replicate(cell, r)))
  saveRDS(res, f)
  invisible(NULL)
}

main <- function() {
  dir.create(RUN_DIR, recursive = TRUE, showWarnings = FALSE)
  g <- build_grid()
  g <- g[vapply(seq_len(nrow(g)), function(i) attainable(g[i, ]), TRUE), ]
  todo <- g[!file.exists(file.path(RUN_DIR, sprintf("cell-%03d.rds", g$cell))), ]
  w <- as.integer(Sys.getenv("WORKERS", "3"))
  cat(sprintf("%d cells to run of %d attainable, %d workers\n", nrow(todo), nrow(g), w))
  invisible(parallel::mclapply(seq_len(nrow(todo)), function(i) {
    t0 <- proc.time()[["elapsed"]]
    run_cell(todo[i, ])
    cat(sprintf("cell %3d done in %.0f s\n", todo$cell[i],
                proc.time()[["elapsed"]] - t0))
  }, mc.cores = w, mc.preschedule = FALSE))
  cat("all cells complete\n")
}

if (!interactive() && Sys.getenv("RUN_NOMAIN") == "") main()
