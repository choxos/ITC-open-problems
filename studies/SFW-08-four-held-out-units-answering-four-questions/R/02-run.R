## Registered run.   WORKERS=3 Rscript R/02-run.R
source("R/00-model.R")
g <- build_grid(); dir.create("results/run", recursive = TRUE, showWarnings = FALSE)
todo <- g[!file.exists(sprintf("results/run/cell-%02d.rds", g$cell)), ]
invisible(parallel::mclapply(seq_len(nrow(todo)), function(i) { cc <- todo[i, ]
  r <- do.call(rbind, lapply(seq_len(N_SIM), function(k) { set.seed(MASTER_SEED %% 1e6 + 7919L * k + 104729L * cc$cell)
    z <- tryCatch(one_rep(cc), error = function(e) data.frame(model = rep(c("M1", "M0"), each = 3), unit = c("pointwise", "arm", "study"), n_terms = NA, elpd_exact = NA_real_,
      elpd_psis = NA_real_, k_max = NA_real_, n_bad = NA, abs_err_bad = NA_real_, abs_err_good = NA_real_, error = conditionMessage(e)))
    transform(z, rep = k) }))
  r$cell <- cc$cell; saveRDS(r, sprintf("results/run/cell-%02d.rds", cc$cell)); cat("cell", cc$cell, "done;", sum(!is.na(r$error)), "failed\n")
}, mc.cores = as.integer(Sys.getenv("WORKERS", "3")), mc.preschedule = FALSE))
cat("all cells complete\n")
