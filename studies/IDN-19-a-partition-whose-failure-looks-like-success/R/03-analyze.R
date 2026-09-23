## Per partition: bias, coverage, fit test; the induced range; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$partition), drop = TRUE), function(z) { e <- z$est - z$truth
  data.frame(cell = z$cell[1], partition = z$partition[1], truth = z$truth[1], bias = mean(e), mcse = stats::sd(e) / sqrt(nrow(z)), se = mean(z$se),
             coverage = mean(abs(e) <= 1.96 * z$se), q_reject = mean(z$q_p < 0.05, na.rm = TRUE)) }))
summ <- merge(g, summ, by = "cell")
rng <- do.call(rbind, lapply(split(d[d$partition == "BCD", ], d$cell[d$partition == "BCD"]), function(z) data.frame(cell = z$cell[1],
  range_contains = mean(z$range_lo <= z$truth & z$truth <= z$range_hi), point_range_contains = mean(z$pt_lo <= z$truth & z$truth <= z$pt_hi),
  range_width = mean(z$range_hi - z$range_lo), point_range_width = mean(z$pt_hi - z$pt_lo))))
rng <- merge(g, rng, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE); write.csv(rng, "results/range.csv", row.names = FALSE)
w <- summ[summ$partition == "BCD" & summ$het == 0.3 & summ$sep == 0, ]
confirmed <- abs(w$bias) >= 0.1 && w$coverage < 0.90 && w$q_reject < 0.2
f3 <- function(x) sprintf("%.3f", x)
md <- c("# Decision", "", sprintf("**Registered primary: %s.** Widest partition, D's interaction 0.3 from B's, C sharing B's: bias %s, coverage %s, fit test rejecting in %s of analyses.",
          if (confirmed) "CONFIRMED" else "NOT CONFIRMED", f3(w$bias), f3(w$coverage), f3(w$q_reject)), "",
  "| C separation | D heterogeneity | partition | truth | bias | SE | coverage | fit test rejects |", "|---:|---:|---|---:|---:|---:|---:|---:|",
  sprintf("| %.1f | %.2f | %s | %.3f | %.3f | %.3f | %.3f | %s |", summ$sep, summ$het, summ$partition, summ$truth, summ$bias, summ$se, summ$coverage, ifelse(is.na(summ$q_reject), "", f3(summ$q_reject))), "",
  "| C separation | D heterogeneity | range of intervals contains truth | range of estimates contains truth | mean range width (intervals) | mean range width (estimates) |", "|---:|---:|---:|---:|---:|---:|",
  sprintf("| %.1f | %.2f | %.3f | %.3f | %.3f | %.3f |", rng$sep, rng$het, rng$range_contains, rng$point_range_contains, rng$range_width, rng$point_range_width), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
