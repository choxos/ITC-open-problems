## Registered run.   Rscript R/02-run.R
source("R/00-model.R")
g <- build_grid(); dir.create("results/run", recursive = TRUE, showWarnings = FALSE)
for (i in seq_len(nrow(g))) {
  cc <- g[i, ]; fn <- sprintf("results/run/cell-%02d.rds", cc$cell)
  if (file.exists(fn)) next
  r <- do.call(rbind, lapply(seq_len(N_SIM), function(k) { set.seed(MASTER_SEED %% 1e6 + 7919L * k + 104729L * cc$cell)
    transform(one_rep(cc), rep = k) }))
  r$cell <- cc$cell; saveRDS(r, fn); cat("cell", cc$cell, "done\n")
}
cat("all cells complete\n")
