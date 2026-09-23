## Registered run.   Rscript R/02-run.R
source("R/00-model.R")
g <- build_grid(); dir.create("results/run", recursive = TRUE, showWarnings = FALSE)
todo <- g[!file.exists(sprintf("results/run/cell-%02d.rds", g$cell)), ]
invisible(parallel::mclapply(seq_len(nrow(todo)), function(i) {
  cc <- todo[i, ]; tr <- truths(cc)
  r <- do.call(rbind, lapply(seq_len(N_SIM), function(k) {
    set.seed(MASTER_SEED %% 1e6 + 7919L * k + 104729L * cc$cell)
    f <- tryCatch(fit(cc, draw(cc)), error = function(e) NULL)
    if (is.null(f)) f <- c(est = NA, se_fixed = NA, se_ess = NA, se_stack = NA, se_stack_hc1 = NA, ess = NA)
    f }))
  saveRDS(data.frame(cell = cc$cell, rep = seq_len(N_SIM), r, target = tr[["target"]], induced = tr[["induced"]]),
          sprintf("results/run/cell-%02d.rds", cc$cell)); cat("cell", cc$cell, "done\n")
}, mc.cores = as.integer(Sys.getenv("WORKERS", "1")), mc.preschedule = FALSE))
cat("all cells complete\n")
