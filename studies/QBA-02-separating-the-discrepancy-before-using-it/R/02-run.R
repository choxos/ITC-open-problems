## Registered run.   WORKERS=3 nice -n 19 Rscript R/02-run.R
source("R/00-model.R")
g <- build_grid(); dir.create("results/run", recursive = TRUE, showWarnings = FALSE)
todo <- g[!file.exists(sprintf("results/run/cell-%02d.rds", g$cell)), ]
invisible(parallel::mclapply(seq_len(nrow(todo)), function(i) {
  cc <- todo[i, ]
  r <- do.call(rbind, lapply(seq_len(N_SIM), function(k) {
    set.seed(MASTER_SEED %% 1e6 + 7919L * k + 104729L * crn_block(cc))
    z <- tryCatch(transform(one_rep(cc), msg = NA_character_), error = function(e)
      data.frame(method = METHODS, mu_hat = NA_real_, tau2_hat = NA_real_, halfwidth = NA_real_, coverage = NA_real_, reml_ok = NA, excess = NA_real_,
                 msg = conditionMessage(e)))
    transform(z, rep = k) }))
  r$cell <- cc$cell
  saveRDS(r, sprintf("results/run/cell-%02d.rds", cc$cell)); cat("cell", cc$cell, "done;", sum(!is.na(r$msg)) / length(METHODS), "replicates failed\n")
}, mc.cores = as.integer(Sys.getenv("WORKERS", "3")), mc.preschedule = FALSE))
cat("all cells complete\n")
