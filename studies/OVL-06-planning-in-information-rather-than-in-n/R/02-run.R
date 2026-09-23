## Registered run: the plan per cell, then the achieved SD from replicates.
source("R/00-model.R")
g <- build_grid(); dir.create("results/run", recursive = TRUE, showWarnings = FALSE)
for (i in seq_len(nrow(g))) {
  cc <- g[i, ]; f <- sprintf("results/run/cell-%02d.rds", cc$cell)
  if (file.exists(f)) next
  p <- plan(cc)
  est <- vapply(seq_len(N_SIM), function(k) { set.seed(MASTER_SEED %% 1e6 + 7919L * k + 104729L * cc$cell); one_rep(cc) }, 0)
  saveRDS(list(cell = cc$cell, plan = p, est = est), f); cat("cell", cc$cell, "done\n")
}
