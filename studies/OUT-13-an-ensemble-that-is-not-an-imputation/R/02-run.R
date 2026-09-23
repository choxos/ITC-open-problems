## Registered run.   WORKERS=3 Rscript R/02-run.R
source("R/00-model.R")
g <- build_grid(); dir.create("results/run", recursive = TRUE, showWarnings = FALSE)
todo <- g[!file.exists(sprintf("results/run/cell-%02d.rds", g$cell)), ]
invisible(parallel::mclapply(seq_len(nrow(todo)), function(i) {
  cc <- todo[i, ]
  r <- do.call(rbind, lapply(seq_len(N_SIM), function(k) {
    set.seed(MASTER_SEED %% 1e6 + 7919L * k + 104729L * cc$cell)
    z <- tryCatch(one_rep(cc), error = function(e) NULL); if (is.null(z)) NULL else transform(z, rep = k) }))
  r$cell <- cc$cell
  saveRDS(r, sprintf("results/run/cell-%02d.rds", cc$cell)); cat("cell", cc$cell, "done", length(unique(r$rep)), "replicates\n")
}, mc.cores = as.integer(Sys.getenv("WORKERS", "3")), mc.preschedule = FALSE))
cat("all cells complete\n")
