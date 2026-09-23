## Registered run: one file per cell.   WORKERS=2 Rscript R/02-run.R
source("R/00-model.R")
g <- build_grid(); dir.create("results/run", recursive = TRUE, showWarnings = FALSE)
todo <- g[!file.exists(sprintf("results/run/cell-%03d.rds", g$cell)), ]
invisible(parallel::mclapply(seq_len(nrow(todo)), function(i) {
  cc <- todo[i, ]; a <- alpha_for(cc); th <- truth(cc)
  r <- t(vapply(seq_len(N_SIM), function(k) {
    set.seed(MASTER_SEED %% 1e6 + 7919L * k + 104729L * cc$cell); one_rep(cc, a) }, numeric(9)))
  saveRDS(data.frame(cell = cc$cell, rep = seq_len(N_SIM), r, truth = th),
          sprintf("results/run/cell-%03d.rds", cc$cell))
  cat("cell", cc$cell, "done\n")
}, mc.cores = as.integer(Sys.getenv("WORKERS", "2")), mc.preschedule = FALSE))
cat("all cells complete\n")
