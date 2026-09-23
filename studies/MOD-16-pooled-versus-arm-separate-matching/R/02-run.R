## The registered run: one file per cell, resumable.   WORKERS=2 Rscript R/02-run.R

source("R/00-model.R")
RUN_DIR <- "results/run"

run_cell <- function(cell) {
  f <- file.path(RUN_DIR, sprintf("cell-%03d.rds", cell$cell))
  if (file.exists(f)) return(invisible(NULL))
  res <- do.call(rbind, lapply(seq_len(N_SIM), function(r) {
    set.seed(MASTER_SEED %% 1e6 + 7919L * r + 104729L * cell$cell)
    fa <- tryCatch(fit_all(draw(cell)), error = function(e) NULL)
    if (is.null(fa)) return(data.frame(cell = cell$cell, rep = r, method = NA,
      est = NA, se = NA, ess_A = NA, ess_C = NA, u_diff = NA))
    do.call(rbind, lapply(names(fa), function(m) data.frame(cell = cell$cell, rep = r,
      method = m, t(fa[[m]]))))
  }))
  res$truth <- truth(cell)
  saveRDS(res, f)
}

main <- function() {
  dir.create(RUN_DIR, recursive = TRUE, showWarnings = FALSE)
  g <- build_grid()
  todo <- g[!file.exists(file.path(RUN_DIR, sprintf("cell-%03d.rds", g$cell))), ]
  w <- as.integer(Sys.getenv("WORKERS", "2"))
  cat(sprintf("%d of %d cells to run, %d workers\n", nrow(todo), nrow(g), w))
  invisible(parallel::mclapply(seq_len(nrow(todo)), function(i) {
    run_cell(todo[i, ]); cat(sprintf("cell %3d done\n", todo$cell[i]))
  }, mc.cores = w, mc.preschedule = FALSE))
  cat("all cells complete\n")
}

if (!interactive() && Sys.getenv("RUN_NOMAIN") == "") main()
