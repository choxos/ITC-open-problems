## Registered run.   Rscript R/02-run.R
source("R/00-model.R")
g <- build_grid(); dir.create("results/run", recursive = TRUE, showWarnings = FALSE)
for (i in seq_len(nrow(g))) {
  cc <- g[i, ]; f <- sprintf("results/run/cell-%02d.rds", cc$cell)
  if (file.exists(f)) next
  r <- do.call(rbind, lapply(seq_len(N_SIM), function(k) {
    set.seed(MASTER_SEED %% 1e6 + 7919L * k + 104729L * cc$cell)
    s <- draw_source(cc); tm <- draw_target_moments(cc)
    z <- fit_all(cc, s, tm); z$truth <- truth(cc, tm); z$rep <- k; z }))
  r$cell <- cc$cell; saveRDS(r, f); cat("cell", cc$cell, "done\n")
}
