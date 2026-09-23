## Unconditional coverage of the whole procedure by prior; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) { cv <- mean(z$lo <= z$truth & z$truth <= z$hi)
  data.frame(cell = z$cell[1], method = z$method[1], bias = mean(z$est - z$truth), mcse = stats::sd(z$est - z$truth) / sqrt(nrow(z)),
             coverage = cv, cov_mcse = sqrt(cv * (1 - cv) / nrow(z)), width = mean(z$hi - z$lo)) }))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
cont <- summ[summ$method %in% c("eb_ridge", "hier_normal"), ]
fails <- any(cont$coverage + 1.96 * cont$cov_mcse < 0.93)
md <- c("# Decision", "",
  sprintf("**Refuting sentence (continuous shrinkage does not select, so its posterior interval is honest): %s.** Coverage: empirical-Bayes ridge %.3f to %.3f; hierarchical normal %.3f to %.3f; spike-and-slab averaging %.3f to %.3f; median-probability model %.3f to %.3f; flat %.3f to %.3f.",
          if (fails) "FAILS" else "HOLDS", min(summ$coverage[summ$method == "eb_ridge"]), max(summ$coverage[summ$method == "eb_ridge"]),
          min(summ$coverage[summ$method == "hier_normal"]), max(summ$coverage[summ$method == "hier_normal"]),
          min(summ$coverage[summ$method == "spike_slab"]), max(summ$coverage[summ$method == "spike_slab"]),
          min(summ$coverage[summ$method == "median_model"]), max(summ$coverage[summ$method == "median_model"]),
          min(summ$coverage[summ$method == "flat"]), max(summ$coverage[summ$method == "flat"])), "",
  "| n per arm | pattern | prior | bias | coverage | width |", "|---:|---|---|---:|---:|---:|",
  sprintf("| %d | %s | %s | %.3f | %.3f | %.3f |", summ$n, summ$pattern, summ$method, summ$bias, summ$coverage, summ$width), "")
writeLines(md, "results/decision.md"); cat(md[1:3], sep = "\n")
