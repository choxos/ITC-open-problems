## Registered run.   nice -n 19 Rscript R/02-run.R     (WORKERS=1: timings are the measurement)
## Every (cell, repeat) is one task, run in a seeded random order so machine
## contention falls on all configurations alike; resumable per task. A failed task
## is kept as a row carrying its error.
source("R/00-model.R")
g <- build_grid(); dir.create("results/run", recursive = TRUE, showWarnings = FALSE)
md5 <- unname(tools::md5sum("R/00-model.R"))
tasks <- rbind(expand.grid(cell = g$cell[g$exp == "E1"], rep = seq_len(N_REP_E1)), expand.grid(cell = g$cell[g$exp == "E2"], rep = seq_len(N_REP_E2)))
set.seed(MASTER_SEED); tasks <- tasks[sample.int(nrow(tasks)), ]
tasks$file <- sprintf("results/run/cell-%03d-rep-%d.rds", tasks$cell, tasks$rep); tasks <- tasks[!file.exists(tasks$file), ]
invisible(parallel::mclapply(seq_len(nrow(tasks)), function(i) { tk <- tasks[i, ]; cc <- g[g$cell == tk$cell, ]
  set.seed(MASTER_SEED %% 1e6 + 7919L * tk$rep + 104729L * tk$cell)
  r <- tryCatch(transform(one_rep(cc), error = NA_character_), error = function(e) data.frame(error = conditionMessage(e)))
  r$cell <- tk$cell; r$rep <- tk$rep; r$code_md5 <- md5; saveRDS(r, tk$file)
  cat("cell", tk$cell, "rep", tk$rep, if (is.na(r$error[1])) "done" else paste("FAILED:", r$error[1]), "\n")
}, mc.cores = as.integer(Sys.getenv("WORKERS", "1")), mc.preschedule = FALSE))
cat("all tasks complete\n")
