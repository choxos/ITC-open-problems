## Registered run.   WORKERS=2 Rscript R/02-run.R
source("R/00-model.R")
g <- build_grid(); dir.create("results/run", recursive = TRUE, showWarnings = FALSE)
todo <- g[!file.exists(sprintf("results/run/cell-%02d.rds", g$cell)), ]
invisible(parallel::mclapply(seq_len(nrow(todo)), function(i) {
  cc <- todo[i, ]; th <- truth(cc)
  res <- lapply(seq_len(N_SIM), function(k) {
    set.seed(MASTER_SEED %% 1e6 + 7919L * k + 104729L * cc$cell)
    r <- fit_all(cc, draw(cc)); raw <- attr(r, "raw")
    r$rep <- k; list(r = r, raw = c(rep = k, raw))
  })
  r <- do.call(rbind, lapply(res, `[[`, "r")); r$truth <- th[r$contrast]; r$cell <- cc$cell
  raw <- as.data.frame(do.call(rbind, lapply(res, `[[`, "raw"))); raw$cell <- cc$cell
  saveRDS(list(r = r, raw = raw), sprintf("results/run/cell-%02d.rds", cc$cell))
  cat("cell", cc$cell, "done\n")
}, mc.cores = as.integer(Sys.getenv("WORKERS", "2")), mc.preschedule = FALSE))
cat("all cells complete\n")
