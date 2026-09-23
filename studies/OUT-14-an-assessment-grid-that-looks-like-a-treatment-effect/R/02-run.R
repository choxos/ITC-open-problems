## Registered run.   Rscript R/02-run.R
source("R/00-model.R")
g <- build_grid(); dir.create("results/run", recursive = TRUE, showWarnings = FALSE)
for (i in seq_len(nrow(g))) {
  cc <- g[i, ]; f <- sprintf("results/run/cell-%02d.rds", cc$cell)
  if (file.exists(f)) next
  r <- t(vapply(seq_len(N_SIM), function(k) {
    set.seed(MASTER_SEED %% 1e6 + 7919L * k + 104729L * cc$cell)
    tryCatch(fit_all(cc), error = function(e) c(naive = NA, midpoint = NA, interval = NA)) }, numeric(3)))
  saveRDS(data.frame(cell = cc$cell, rep = seq_len(N_SIM), r, truth = truth(cc), predicted = predicted_bias(cc)), f)
  cat("cell", cc$cell, "done\n")
}
