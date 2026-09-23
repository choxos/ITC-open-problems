## Registered run.   WORKERS=3 Rscript R/02-run.R
source("R/00-model.R")
g <- build_grid(); dir.create("results/run", recursive = TRUE, showWarnings = FALSE)
if (!file.exists("results/run/cuts.rds")) saveRDS(lapply(NETS, enum_cuts), "results/run/cuts.rds")
CUTS <- readRDS("results/run/cuts.rds"); g <- g[vapply(CUTS[g$net], length, 0L) >= MIN_CUTS, ]
todo <- g[!file.exists(sprintf("results/run/cell-%02d.rds", g$cell)), ]
stamp <- list(code_mtime = file.mtime("R/00-model.R"), versions = vapply(c("multinma", "netmeta"), function(p) as.character(utils::packageVersion(p)), ""), R = R.version.string)
invisible(parallel::mclapply(seq_len(nrow(todo)), function(i) {
  cc <- todo[i, ]; set.seed(MASTER_SEED %% 1e6 + 104729L * cc$cell)
  r <- tryCatch(run_cell(cc, CUTS[[cc$net]]), error = function(e) list(error = conditionMessage(e)))
  saveRDS(c(list(cell = cc), r, stamp), sprintf("results/run/cell-%02d.rds", cc$cell))
  cat("cell", cc$cell, cc$net, cc$type, if (is.null(r$error)) "done" else paste("failed:", r$error), "\n")
}, mc.cores = as.integer(Sys.getenv("WORKERS", "3")), mc.preschedule = FALSE))
cat("all cells complete\n")
