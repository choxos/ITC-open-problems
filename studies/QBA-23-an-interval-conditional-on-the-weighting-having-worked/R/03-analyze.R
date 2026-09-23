## Coverage conditional on success and unconditional, by grid point; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$m), drop = TRUE), function(z) data.frame(n = z$n[1], m = z$m[1], original_feasible = mean(z$orig_ok),
  resample_failure = mean(z$fail_share), ess = mean(z$ess, na.rm = TRUE), bias = mean(z$est - z$m, na.rm = TRUE),
  coverage_given_success = mean(z$lo <= z$m & z$m <= z$hi, na.rm = TRUE), coverage_unconditional = mean(ifelse(is.na(z$lo), FALSE, z$lo <= z$m & z$m <= z$hi)),
  width = mean(z$hi - z$lo, na.rm = TRUE))))
summ <- summ[order(summ$n, summ$m), ]
write.csv(summ, "results/summary.csv", row.names = FALSE)
hi <- summ[summ$resample_failure > 0.1, ]
fails <- nrow(hi) > 0 && (any(hi$coverage_given_success < 0.85) || any(hi$coverage_given_success - hi$coverage_unconditional > 0.05))
md <- c("# Decision", "",
  sprintf("**Refuting sentence (failure rates are low enough that conditioning on success is immaterial): %s.** Where more than 10%% of resamples failed, coverage given success %.3f to %.3f and unconditional %.3f to %.3f.",
          if (fails) "FAILS" else "HOLDS", min(hi$coverage_given_success), max(hi$coverage_given_success), min(hi$coverage_unconditional), max(hi$coverage_unconditional)), "",
  "| n | assumed target mean | original fit feasible | resamples failed | ESS | bias | coverage given success | coverage unconditional | width |", "|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %d | %.1f | %.3f | %.3f | %.1f | %.3f | %.3f | %.3f | %.3f |", summ$n, summ$m, summ$original_feasible, summ$resample_failure, summ$ess, summ$bias,
          summ$coverage_given_success, summ$coverage_unconditional, summ$width), "")
writeLines(md, "results/decision.md"); cat(md[1:3], sep = "\n")
