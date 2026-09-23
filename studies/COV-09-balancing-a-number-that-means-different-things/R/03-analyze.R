## Bias against the closed form, correction by regime, bounds; decision.
source("R/00-model.R")
g <- build_grid()
d <- do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS))
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) {
  e <- z$est - z$truth
  data.frame(cell = z$cell[1], method = z$method[1], bias = mean(e, na.rm = TRUE),
             mcse = stats::sd(e, na.rm = TRUE) / sqrt(sum(is.finite(e))),
             coverage = mean(z$lo <= z$truth & z$truth <= z$hi, na.rm = TRUE),
             width = mean(z$hi - z$lo, na.rm = TRUE), predicted = z$predicted[1])
}))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
nv <- summ[summ$method == "naive", ]
f <- stats::lm(bias ~ predicted, data = nv, weights = 1 / nv$mcse^2)
rc <- summ[summ$method == "reliability_corrected" & summ$beta > 0, ]
same <- rc[rc$scen %in% c("same", "same_shifted"), ]; diffr <- rc[!rc$scen %in% c("same", "same_shifted"), ]
bd <- summ[summ$method == "bounded", ]
md <- c("# Decision", "",
  sprintf("Mechanism: naive bias on the closed form, slope %.3f (SE %.3f), %d cells.", coef(f)[["predicted"]],
          sqrt(diag(vcov(f)))[["predicted"]], nrow(nv)), "",
  sprintf("**Refuting sentence (one reliability factor recovers the effect): holds for a shared instrument (corrected bias within 3 MCSE in %d of %d cells); fails for differing instruments (corrected |bias| above 0.05 in %d of %d cells, max %.3f).**",
          sum(abs(same$bias) <= 3 * same$mcse), nrow(same), sum(abs(diffr$bias) > 0.05), nrow(diffr), max(abs(diffr$bias))), "",
  sprintf("Bounded interval over declared instrument offsets and slopes: coverage %.3f to %.3f; width %.2f to %.2f times the naive interval.",
          min(bd$coverage), max(bd$coverage), min(bd$width / nv$width[match(bd$cell, nv$cell)]),
          max(bd$width / nv$width[match(bd$cell, nv$cell)])), "",
  sprintf("Null control (beta = 0): naive within 3 MCSE in %d of %d cells.",
          sum(abs(nv$bias[nv$beta == 0]) <= 3 * nv$mcse[nv$beta == 0]), sum(nv$beta == 0)), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
