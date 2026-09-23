## Registered run.   WORKERS=3 Rscript R/02-run.R
source("R/00-model.R")
g <- build_grid(); dir.create("results/run", recursive = TRUE, showWarnings = FALSE)
todo <- g[!file.exists(sprintf("results/run/cell-%02d.rds", g$unit)), ]
stamp <- list(code_mtime = file.mtime("R/00-model.R"), multinma = as.character(utils::packageVersion("multinma")), R = R.version.string, n_boot = N_BOOT)
invisible(parallel::mclapply(seq_len(nrow(todo)), function(i) {
  u <- todo[i, ]; set.seed(MASTER_SEED %% 1e6 + 104729L * u$unit)
  r <- tryCatch(one_unit(u), error = function(e) list(unit = u, error = conditionMessage(e)))
  saveRDS(c(r, stamp), sprintf("results/run/cell-%02d.rds", u$unit))
  cat("unit", u$unit, if (is.null(r$error)) "done" else paste("failed:", r$error), "\n")
}, mc.cores = as.integer(Sys.getenv("WORKERS", "3")), mc.preschedule = FALSE))
cat("all units complete\n")
