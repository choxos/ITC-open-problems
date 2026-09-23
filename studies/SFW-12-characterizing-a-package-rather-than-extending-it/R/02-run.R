## Registered run.   Rscript R/02-run.R
source("R/00-model.R")
g <- build_grid(); dir.create("results/run", recursive = TRUE, showWarnings = FALSE)
pt <- c(gaussian = cal_param("gaussian", 0.5, TGT), clayton = cal_param("clayton", 0.5, TGT))
for (i in seq_len(nrow(g))) { cc <- g[i, ]; ps <- cal_param("gaussian", cc$source_rho, SRC)
  r <- do.call(rbind, lapply(seq_len(N_SIM), function(k) { set.seed(MASTER_SEED %% 1e6 + 7919L * k + 104729L * cc$cell)
    z <- tryCatch(suppressMessages(one_rep(cc, ps, pt[[cc$target_copula]])), error = function(e) NULL); if (is.null(z)) NULL else transform(z, rep = k) }))
  r$cell <- cc$cell; r$truth <- truth(cc, pt[[cc$target_copula]]); saveRDS(r, sprintf("results/run/cell-%02d.rds", cc$cell)); cat("cell", cc$cell, "done", length(unique(r$rep)), "\n") }
cat("all cells complete\n")
