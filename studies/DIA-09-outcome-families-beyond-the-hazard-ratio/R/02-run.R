## Registered run.   Rscript R/02-run.R
source("R/00-model.R")
g <- build_grid(); dir.create("results/run", recursive = TRUE, showWarnings = FALSE)
for (i in seq_len(nrow(g))) {
  cc <- g[i, ]; f <- sprintf("results/run/cell-%02d.rds", cc$cell)
  if (file.exists(f)) next
  th <- truth(cc)
  r <- do.call(rbind, lapply(seq_len(N_SIM), function(k) { set.seed(MASTER_SEED %% 1e6 + 7919L * k + 104729L * cc$cell)
    z <- tryCatch(fit_all(draw(cc)), error = function(e) NULL); if (is.null(z)) NULL else data.frame(t(z), rep = k) }))
  r$cell <- cc$cell; r$truth_diff <- th[["cif_diff"]]; r$truth_A <- th[["cif_A"]]; r$truth_hr <- -0.5 + cc$b * cc$m_t
  saveRDS(r, f); cat("cell", cc$cell, "done\n")
}
cat("all cells complete\n")
