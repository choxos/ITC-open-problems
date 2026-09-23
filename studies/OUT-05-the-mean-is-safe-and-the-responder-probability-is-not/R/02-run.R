## Registered run.   WORKERS=2 Rscript R/02-run.R
source("R/00-model.R")
g <- build_grid(); dir.create("results/run", recursive = TRUE, showWarnings = FALSE)
todo <- g[!file.exists(sprintf("results/run/cell-%02d.rds", g$cell)), ]
invisible(parallel::mclapply(seq_len(nrow(todo)), function(i) {
  cc <- todo[i, ]; fl <- floor_for(cc); th <- thresholds(cc); tr <- truth(cc)
  r <- do.call(rbind, lapply(seq_len(N_SIM), function(k) {
    set.seed(MASTER_SEED %% 1e6 + 7919L * k + 104729L * cc$cell)
    z <- tryCatch(fit_all(cc, draw(cc, fl), fl, th), error = function(e) NULL); if (is.null(z)) NULL else transform(z, rep = k) }))
  r$cell <- cc$cell; r$t_mean <- tr[["mean"]]; r$t_near <- tr[["near"]]; r$t_tail <- tr[["tail"]]
  saveRDS(r, sprintf("results/run/cell-%02d.rds", cc$cell)); cat("cell", cc$cell, "done\n")
}, mc.cores = as.integer(Sys.getenv("WORKERS", "2")), mc.preschedule = FALSE))
cat("all cells complete\n")
