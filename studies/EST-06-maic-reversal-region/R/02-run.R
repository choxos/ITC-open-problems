## Registered run.   WORKERS=1 Rscript R/02-run.R
source("R/00-model.R")
g <- build_grid(); dir.create("results/run", recursive = TRUE, showWarnings = FALSE)
todo <- g[!file.exists(sprintf("results/run/cell-%03d.rds", g$cell)), ]
invisible(parallel::mclapply(seq_len(nrow(todo)), function(i) {
  cc <- todo[i, ]
  r <- do.call(rbind, lapply(seq_len(N_SIM), function(k) {
    set.seed(MASTER_SEED %% 1e6 + 7919L * k + 104729L * cc$cell)
    f <- fit_all(cc, draw(cc))
    data.frame(cell = cc$cell, rep = k, method = rownames(f), est = f[, "est"], var = f[, "var"])
  }))
  saveRDS(r, sprintf("results/run/cell-%03d.rds", cc$cell)); cat("cell", cc$cell, "done\n")
}, mc.cores = as.integer(Sys.getenv("WORKERS", "1")), mc.preschedule = FALSE))
cat("all cells complete\n")
