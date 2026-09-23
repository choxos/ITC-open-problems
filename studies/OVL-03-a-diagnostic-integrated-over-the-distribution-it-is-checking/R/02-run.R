## Registered run.   WORKERS=3 nice -n 19 Rscript R/02-run.R
source("R/00-model.R")
g <- build_grid(); dir.create("results/run", recursive = TRUE, showWarnings = FALSE)
todo <- g[!file.exists(sprintf("results/run/cell-%02d.rds", g$cell)), ]
invisible(parallel::mclapply(seq_len(nrow(todo)), function(i) {
  cc <- todo[i, ]
  r <- do.call(rbind, lapply(seq_len(N_SIM), function(k) {
    set.seed(MASTER_SEED %% 1e6 + 7919L * k + 104729L * cc$cell)
    z <- tryCatch(transform(one_rep(cc), msg = NA_character_), error = function(e)
      data.frame(est = NA_real_, se = NA_real_, diag = DIAGS, true_law = NA_real_, indep = NA_real_, msg = conditionMessage(e)))
    transform(z, rep = k) }))
  r$cell <- cc$cell; r$truth <- truth(cc)
  saveRDS(r, sprintf("results/run/cell-%02d.rds", cc$cell))
  cat("cell", cc$cell, "done;", sum(!is.na(r$msg)) / length(DIAGS), "replicates failed\n")
}, mc.cores = as.integer(Sys.getenv("WORKERS", "3")), mc.preschedule = FALSE))
cat("all cells complete\n")
