## Discovery power, false discoveries, stability and target error by trials and confounding; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method, d$penalty), drop = TRUE), function(z) data.frame(cell = z$cell[1], method = z$method[1], penalty = z$penalty[1],
  power = mean(z$power), false_disc = mean(z$false_disc), x10 = mean(z$x10), x10_mcse = sqrt(mean(z$x10) * (1 - mean(z$x10)) / nrow(z)), stability = mean(z$stability),
  bias = mean(z$target - z$truth), rmse = sqrt(mean((z$target - z$truth)^2)))))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
st <- aggregate(stability ~ K + method + penalty, summ, mean)
usable <- all(summ$stability >= 0.8 & summ$false_disc <= 0.5)
cf <- summ[summ$conf > 0, ]; c0 <- summ[summ$conf == 0, ]
x10_gap <- merge(cf[, c("K", "M", "method", "penalty", "x10")], c0[, c("K", "M", "method", "penalty", "x10")], by = c("K", "M", "method", "penalty"), suffixes = c("_conf", "_none"))
md <- c("# Decision", "",
  sprintf("**Refuting sentence (discovered modifier sets are stable and accurate enough to be a usable component): %s.** Stability (Jaccard similarity across independent replicates) %.2f to %.2f; false discoveries among seven null covariates %.2f to %.2f per analysis.",
          if (usable) "HOLDS" else "FAILS", min(summ$stability), max(summ$stability), min(summ$false_disc), max(summ$false_disc)), "",
  sprintf("Study-level confounding: the confounded covariate x10 was selected in %.2f to %.2f of pooled analyses and %.2f to %.2f of within-trial analyses, against %.2f to %.2f without confounding.",
          min(x10_gap$x10_conf[x10_gap$method == "pooled"]), max(x10_gap$x10_conf[x10_gap$method == "pooled"]), min(x10_gap$x10_conf[x10_gap$method == "within"]), max(x10_gap$x10_conf[x10_gap$method == "within"]),
          min(x10_gap$x10_none), max(x10_gap$x10_none)), "",
  "| trials | true modifiers | confounding | method | penalty | power | false discoveries | x10 selected | stability | target bias | target RMSE |", "|---:|---:|---:|---|---|---:|---:|---:|---:|---:|---:|",
  sprintf("| %d | %d | %.1f | %s | %s | %.3f | %.2f | %.3f | %.2f | %.3f | %.3f |", summ$K, summ$M, summ$conf, summ$method, summ$penalty, summ$power, summ$false_disc, summ$x10, summ$stability, summ$bias, summ$rmse), "")
writeLines(md, "results/decision.md"); cat(md[1:5], sep = "\n")
