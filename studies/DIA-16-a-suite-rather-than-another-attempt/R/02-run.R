## Registered run.   WORKERS=3 Rscript R/02-run.R
source("R/00-model.R")
g <- build_grid(); dir.create("results/run", recursive = TRUE, showWarnings = FALSE)
stamp <- list(code_mtime = file.mtime("R/00-model.R"), multinma = as.character(utils::packageVersion("multinma")), R = R.version.string)
jobs <- rbind(data.frame(type = "cell", id = g$unit), data.frame(type = "null", id = seq_len(nrow(NULL_SET))))
jobs$file <- sprintf("results/run/%s-%02d.rds", jobs$type, jobs$id); jobs <- jobs[!file.exists(jobs$file), ]
invisible(parallel::mclapply(seq_len(nrow(jobs)), function(i) { j <- jobs[i, ]
  set.seed(MASTER_SEED %% 1e6 + 104729L * j$id + if (j$type == "null") 7919L else 0L)
  r <- if (j$type == "cell") tryCatch(one_unit(g[g$unit == j$id, ]), error = function(e) list(unit = g[g$unit == j$id, ], error = conditionMessage(e))) else
    list(set = NULL_SET[j$id, ], z = t(vapply(seq_len(R_NULL), function(k) tryCatch(null_split(j$id), error = function(e) c(d_naive = NA_real_, d_maic = NA_real_)), numeric(2))))
  saveRDS(c(r, stamp), j$file); cat(j$type, j$id, if (is.null(r$error)) "done" else paste("failed:", r$error), "\n")
}, mc.cores = as.integer(Sys.getenv("WORKERS", "3")), mc.preschedule = FALSE))
cat("all jobs complete\n")
