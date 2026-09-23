## Registered run.   WORKERS=2 Rscript R/02-run.R
source("R/00-model.R")
g <- build_grid(); dir.create("results/run", recursive = TRUE, showWarnings = FALSE)
todo <- g[!file.exists(sprintf("results/run/cell-%02d.rds", g$cell)), ]
invisible(parallel::mclapply(seq_len(nrow(todo)), function(i) {
  cc <- todo[i, ]; eb <- edge_bias(cc)
  r <- do.call(rbind, lapply(seq_len(N_SIM), function(k) {
    set.seed(MASTER_SEED %% 1e6 + 7919L * k + 104729L * cc$cell)
    z <- tryCatch(one_rep(cc, eb), error = function(e) data.frame(method = c("cstc", "unadjusted"), est = NA_real_, se = NA_real_, pred = NA_real_, error = conditionMessage(e)))
    transform(z, rep = k) }))
  r$cell <- cc$cell; r$truth <- truth(cc)
  saveRDS(r, sprintf("results/run/cell-%02d.rds", cc$cell)); cat("cell", cc$cell, "done;", sum(!is.na(r$error)), "failed fits\n")
}, mc.cores = as.integer(Sys.getenv("WORKERS", "2")), mc.preschedule = FALSE))
cat("all cells complete\n")
