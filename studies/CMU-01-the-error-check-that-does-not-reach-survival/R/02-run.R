## Registered run.   nice -n 19 Rscript R/02-run.R     (WORKERS=1: the probe peaked at a 4.5 GB R heap;
## every order's stanfit is held until the reference fit at Q 1024 is done)
## Resumable per (cell, dataset); a failed dataset is kept as a row carrying its error.
source("R/00-model.R")
g <- build_grid(); dir.create("results/run", recursive = TRUE, showWarnings = FALSE)
md5 <- unname(tools::md5sum("R/00-model.R"))
tasks <- do.call(rbind, lapply(g$cell, function(i) data.frame(cell = i, rep = seq_len(if (g$kind[i] == "validate") N_VAL else N_SIM))))
tasks$file <- sprintf("results/run/cell-%02d-rep-%02d.rds", tasks$cell, tasks$rep); tasks <- tasks[!file.exists(tasks$file), ]
invisible(parallel::mclapply(seq_len(nrow(tasks)), function(i) { tk <- tasks[i, ]; cc <- g[g$cell == tk$cell, ]
  set.seed(MASTER_SEED %% 1e6 + 7919L * tk$rep + 104729L * tk$cell)
  r <- tryCatch(transform(one_rep(cc), error = NA_character_), error = function(e) data.frame(error = conditionMessage(e)))
  r$cell <- tk$cell; r$rep <- tk$rep; r$code_md5 <- md5; saveRDS(r, tk$file)
  cat("cell", tk$cell, "rep", tk$rep, if (is.na(r$error[1])) "done" else paste("FAILED:", r$error[1]), "\n")
}, mc.cores = as.integer(Sys.getenv("WORKERS", "1")), mc.preschedule = FALSE))
cat("all tasks complete\n")
