## Coverage overall and in the unsupported tail; infinite intervals; ESS identity; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) data.frame(cell = z$cell[1], mu = z$mu[1], method = z$method[1],
  coverage = mean(z$coverage), coverage_tail = mean(z$coverage_tail, na.rm = TRUE), infinite = mean(z$infinite), tail_infinite = mean(z$tail_infinite, na.rm = TRUE),
  median_width = mean(z$median_width), ess_cal = mean(z$ess_cal), ess_formula = N_CAL / exp(z$mu[1]^2), tail_share = mean(z$tail_share))))
write.csv(summ, "results/summary.csv", row.names = FALSE)
w <- summ[summ$method == "weighted", ]
fails <- any(w$coverage_tail < 0.85) || any(w$tail_infinite > 0.05)
md <- c("# Decision", "",
  sprintf("**Refuting sentence (weighted conformal restores a valid coverage statement, so the support problem is solved): %s.** Weighted conformal coverage overall %.3f to %.3f; in the target region beyond the source's range %.3f to %.3f, with %.1f%% to %.1f%% of intervals there infinite.",
          if (fails) "FAILS" else "HOLDS", min(w$coverage), max(w$coverage), min(w$coverage_tail), max(w$coverage_tail), 100 * min(w$tail_infinite), 100 * max(w$tail_infinite)), "",
  "| target mean | method | coverage | coverage beyond the source's range | infinite intervals | infinite beyond range | median width | calibration ESS | n / (1 + chi-square) |",
  "|---:|---|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %.1f | %s | %.3f | %.3f | %.3f | %.3f | %.2f | %.1f | %.1f |", summ$mu, summ$method, summ$coverage, summ$coverage_tail, summ$infinite, summ$tail_infinite,
          summ$median_width, summ$ess_cal, summ$ess_formula), "")
writeLines(md, "results/decision.md"); cat(md[1:3], sep = "\n")
