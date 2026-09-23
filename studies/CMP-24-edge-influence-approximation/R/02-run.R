## Registered run.   Rscript R/02-run.R
source("R/00-model.R")
g <- build_grid(); dir.create("results/run", recursive = TRUE, showWarnings = FALSE)
invisible(parallel::mclapply(seq_len(nrow(g)), function(i) { cc <- g[i, ]
  r <- do.call(rbind, lapply(seq_len(N_SIM), function(k) { set.seed(MASTER_SEED %% 1e6 + 7919L * k + 104729L * cc$cell)
    z <- tryCatch(one_rep(cc), error = function(e) NULL); if (is.null(z)) NULL else transform(z, rep = k) }))
  r$cell <- cc$cell; saveRDS(r, sprintf("results/run/cell-%02d.rds", cc$cell)); cat("cell", cc$cell, "done", nrow(r), "\n") }, mc.cores = 2L, mc.preschedule = FALSE))
cat("all cells complete\n")
