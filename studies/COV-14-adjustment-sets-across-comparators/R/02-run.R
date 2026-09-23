## Registered run: one file per cell, resumable.   WORKERS=2 Rscript R/02-run.R
source("R/00-model.R")
RUN_DIR <- "results/run"
run_cell <- function(cc) {
  f <- file.path(RUN_DIR, sprintf("cell-%02d.rds", cc$cell))
  if (file.exists(f)) return(invisible(NULL))
  th <- truth(cc)
  res <- do.call(rbind, lapply(seq_len(N_SIM), function(r) {
    set.seed(MASTER_SEED %% 1e6 + 7919L * r + 104729L * cc$cell)
    z <- tryCatch(fit_all(cc, draw(cc)), error = function(e) NULL)
    if (is.null(z)) return(NULL)
    z$rep <- r; z$truth <- th; z
  }))
  res$cell <- cc$cell
  saveRDS(res, f)
}
dir.create(RUN_DIR, recursive = TRUE, showWarnings = FALSE)
g <- build_grid()
todo <- g[!file.exists(file.path(RUN_DIR, sprintf("cell-%02d.rds", g$cell))), ]
invisible(parallel::mclapply(seq_len(nrow(todo)), function(i) { run_cell(todo[i, ]); cat("cell", todo$cell[i], "done\n") },
  mc.cores = as.integer(Sys.getenv("WORKERS", "2")), mc.preschedule = FALSE))
cat("all cells complete\n")
