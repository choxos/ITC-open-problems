## The registered run: one file per cell, resumable, seeds a function of cell and
## replicate.   WORKERS=3 Rscript R/03-run.R

source("R/01-model.R")
RUN_DIR <- "results/run"

run_cell <- function(cell) {
  f <- file.path(RUN_DIR, sprintf("cell-%03d.rds", cell$cell))
  if (file.exists(f)) return(invisible(NULL))
  th <- truth(cell)
  res <- do.call(rbind, lapply(seq_len(N_SIM), function(r) {
    set.seed(MASTER_SEED %% 1e6 + 7919L * r + 104729L * cell$cell)
    fa <- tryCatch(fit_all(cell, draw(cell)), error = function(e) NULL)
    ms <- c("unadjusted", "maic_means", "maic_meanvar", "maic_index", "gcomp")
    do.call(rbind, lapply(ms, function(m) {
      z <- if (is.null(fa)) NULL else fa[[m]]
      data.frame(cell = cell$cell, rep = r, method = m,
                 est = if (is.null(z)) NA else z[["est"]],
                 se = if (is.null(z)) NA else z[["se"]],
                 ess = if (is.null(z)) NA else z[["ess"]], truth = th)
    }))
  }))
  saveRDS(res, f)
}

main <- function() {
  dir.create(RUN_DIR, recursive = TRUE, showWarnings = FALSE)
  g <- build_grid()
  todo <- g[!file.exists(file.path(RUN_DIR, sprintf("cell-%03d.rds", g$cell))), ]
  w <- as.integer(Sys.getenv("WORKERS", "3"))
  cat(sprintf("%d of %d cells to run, %d workers\n", nrow(todo), nrow(g), w))
  invisible(parallel::mclapply(seq_len(nrow(todo)), function(i) {
    t0 <- proc.time()[["elapsed"]]
    run_cell(todo[i, ])
    cat(sprintf("cell %3d done in %.0f s\n", todo$cell[i], proc.time()[["elapsed"]] - t0))
  }, mc.cores = w, mc.preschedule = FALSE))
  cat("all cells complete\n")
}

if (!interactive() && Sys.getenv("RUN_NOMAIN") == "") main()
