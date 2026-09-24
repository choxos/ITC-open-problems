## Registered run.   WORKERS=2 nice -n 19 Rscript R/02-run.R
## Resumable per cell. A failed replicate is kept as a row carrying its error: in SBC a
## dropped replicate breaks the rank identity, so failures are counted, never removed.
source("R/00-model.R")
g <- build_grid(); dir.create("results/run", recursive = TRUE, showWarnings = FALSE)
md5 <- unname(tools::md5sum("R/00-model.R"))
bind <- function(l) { cols <- unique(unlist(lapply(l, names))); do.call(rbind, lapply(l, function(z) { z[setdiff(cols, names(z))] <- NA; z[cols] })) }
todo <- g[!file.exists(sprintf("results/run/cell-%02d.rds", g$cell)), ]
invisible(parallel::mclapply(seq_len(nrow(todo)), function(i) { cc <- todo[i, ]
  n <- if (cc$sampler == "nuts") N_NUTS else N_SIM
  r <- bind(lapply(seq_len(n), function(k) { set.seed(MASTER_SEED %% 1e6 + 7919L * k + 104729L * cc$cell)
    tryCatch(transform(one_rep(cc), rep = k, error = NA_character_), error = function(e) data.frame(rep = k, error = conditionMessage(e))) }))
  r$cell <- cc$cell; r$code_md5 <- md5
  saveRDS(r, sprintf("results/run/cell-%02d.rds", cc$cell))
  cat("cell", cc$cell, "done;", sum(!is.na(r$error)), "failed replicates\n")
}, mc.cores = as.integer(Sys.getenv("WORKERS", "2")), mc.preschedule = FALSE))
cat("all cells complete\n")
