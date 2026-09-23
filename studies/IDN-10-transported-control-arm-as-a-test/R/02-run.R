## Registered run.   Rscript R/02-run.R
source("R/00-model.R")
g <- build_grid(); dir.create("results/run", recursive = TRUE, showWarnings = FALSE)
for (i in seq_len(nrow(g))) {
  cc <- g[i, ]; f <- sprintf("results/run/cell-%02d.rds", cc$cell)
  if (file.exists(f)) next
  tr <- truths(cc)
  r <- t(vapply(seq_len(N_SIM), function(k) { set.seed(MASTER_SEED %% 1e6 + 7919L * k + 104729L * cc$cell)
    tryCatch(fit(draw(cc)), error = function(e) rep(NA_real_, 5)) }, numeric(5)))
  colnames(r) <- c("est", "se", "check_D", "check_z", "pC_transported")
  saveRDS(data.frame(cell = cc$cell, rep = seq_len(N_SIM), r, truth = tr[["log_or_BA"]], pC = tr[["p_C"]]), f)
  cat("cell", cc$cell, "done\n")
}
