## Tipping-set shape, monotonicity and cancellation; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) data.frame(cell = z$cell[1], n = nrow(z), not_single = mean(z$not_single), any_flip = mean(z$any_flip),
  nonmonotone = mean(!z$monotone), flat = mean(z$max_abs_move < 0.05), mean_slope = mean(z$slope), mean_move = mean(z$max_abs_move), bias0 = mean(z$est0) - truth())))
summ <- merge(g, summ, by = "cell"); write.csv(summ, "results/summary.csv", row.names = FALSE)
pr <- summ[summ$miss2 != summ$miss1, ]
verdict <- if (any(pr$not_single >= 0.05)) "CONFIRMED: the tipping set is often not a single point" else if (all(pr$flat < 0.05)) "REFUTED" else "CANCELLATION WITHOUT NON-UNIQUE TIPPING SETS"
f3 <- function(x) sprintf("%.3f", x)
md <- c("# Decision", "", sprintf("**Registered primary: %s.** Differing missingness (30%% and 10%%): tipping set not a single point in %s of replicates (integration route off, on).",
          verdict, paste(f3(pr$not_single), collapse = ", ")), "",
  "| missingness trial 2 | integration route | not a single point | any reversal | non-monotone curve | flat curve (move < 0.05) | mean slope | mean largest move | bias at delta 0 |", "|---:|---|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %.1f | %s | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f |", summ$miss2, ifelse(summ$route_b, "on", "off"), summ$not_single, summ$any_flip, summ$nonmonotone, summ$flat, summ$mean_slope, summ$mean_move, summ$bias0), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
