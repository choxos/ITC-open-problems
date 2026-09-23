## Registered run.   Rscript R/02-run.R
source("R/00-model.R")
g <- build_grid(); dir.create("results/run", recursive = TRUE, showWarnings = FALSE)
for (i in seq_len(nrow(g))) {
  cc <- g[i, ]; f <- sprintf("results/run/cell-%02d.rds", cc$cell)
  if (file.exists(f)) next
  tr <- truths(cc)
  r <- do.call(rbind, lapply(seq_len(N_SIM), function(k) { set.seed(MASTER_SEED %% 1e6 + 7919L * k + 104729L * cc$cell)
    data.frame(t(fit_all(cc, draw(cc))), rep = k) }))
  r$cell <- cc$cell; r$truth <- tr[["truth"]]; r$limit <- tr[["limit"]]; r$bias_true <- tr[["bias"]]
  saveRDS(r, f); cat("cell", cc$cell, "done\n")
}
cat("all cells complete\n")
