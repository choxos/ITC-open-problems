## Registered run.   WORKERS=3 Rscript R/02-run.R
## Main grid (MAIC, STC, ML-NMR by maximum likelihood), then the multinma burden
## subsample on the first N_BURDEN replicates of each cell (same datasets).
source("R/00-model.R")
g <- build_grid(); dir.create("results/run", recursive = TRUE, showWarnings = FALSE)
seed_of <- function(k, cell) MASTER_SEED %% 1e6 + 7919L * k + 104729L * cell
todo <- g[!file.exists(sprintf("results/run/cell-%02d.rds", g$cell)), ]
invisible(parallel::mclapply(seq_len(nrow(todo)), function(i) { cc <- todo[i, ]
  r <- do.call(rbind, lapply(seq_len(N_SIM), function(k) { set.seed(seed_of(k, cc$cell))
    z <- tryCatch(one_rep(cc), error = function(e) data.frame(method = c("maic", "stc", "mlnmr"), est = NA_real_, se = NA_real_, ess = NA_real_, converged = 0, sec = NA_real_, error = conditionMessage(e)))
    transform(z, rep = k) }))
  r$cell <- cc$cell; saveRDS(r, sprintf("results/run/cell-%02d.rds", cc$cell)); cat("cell", cc$cell, "done;", sum(!is.na(r$error)), "failed fits\n")
}, mc.cores = as.integer(Sys.getenv("WORKERS", "3")), mc.preschedule = FALSE))
todo <- if (N_BURDEN > 0) g[!file.exists(sprintf("results/run/burden-%02d.rds", g$cell)), ] else g[0, ]
invisible(parallel::mclapply(seq_len(nrow(todo)), function(i) { cc <- todo[i, ]
  r <- do.call(rbind, lapply(seq_len(N_BURDEN), function(k) { set.seed(seed_of(k, cc$cell))
    z <- tryCatch(cbind(burden_rep(cc, seed = seed_of(k, cc$cell)), error = NA_character_), error = function(e) data.frame(est = NA_real_, sd = NA_real_, cpu = NA_real_, divergent = NA_real_,
      refit = NA, max_rhat = NA_real_, int_check_warning = NA, n_warnings = NA_real_, error = conditionMessage(e)))
    transform(z, rep = k) }))
  r$cell <- cc$cell; saveRDS(r, sprintf("results/run/burden-%02d.rds", cc$cell)); cat("burden cell", cc$cell, "done\n")
}, mc.cores = as.integer(Sys.getenv("WORKERS", "3")), mc.preschedule = FALSE))
cat("all cells complete\n")
