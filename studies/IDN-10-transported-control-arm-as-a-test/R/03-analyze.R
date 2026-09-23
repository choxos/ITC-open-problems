## The check as a classifier of material contrast bias; decision.
source("R/00-model.R")
g <- build_grid()
d <- do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS))
d <- merge(d[is.finite(d$est), ], g, by = "cell")
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) { e <- z$est - z$truth
  data.frame(cell = z$cell[1], bias = mean(e), mcse = stats::sd(e) / sqrt(nrow(z)),
             coverage = mean(abs(e) <= 1.96 * z$se), alarm = mean(abs(z$check_z) > 1.96)) }))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
## Cell-level truth: the contrast is biased when the modifier shifts.
summ$biased <- summ$mu_v > 0
auroc <- function(s, y) { r <- rank(c(s[y], s[!y])); ny <- sum(y); (sum(r[seq_len(ny)]) - ny * (ny + 1) / 2) / (ny * sum(!y)) }
d$biased <- d$mu_v > 0
au <- auroc(abs(d$check_z), d$biased)
tol <- c(1, 1.645, 1.96, 2.576)
oc <- data.frame(z_tol = tol, false_alarm = sapply(tol, function(t) mean(abs(d$check_z[!d$biased]) > t)),
                 detection = sapply(tol, function(t) mean(abs(d$check_z[d$biased]) > t)))
fr <- summ[summ$mu_u == 0 & summ$mu_v > 0, ]; fa <- summ[summ$mu_u > 0 & summ$mu_v == 0, ]
confirmed <- all(fr$alarm < 0.10) && all(fa$alarm[fa$mu_u == 0.6] > 0.20)
md <- c("# Decision", "",
  sprintf("**Design's table confirmed (modifier shift: alarm below 0.10 though biased; prognostic shift 0.6: alarm above 0.20 though unbiased): %s.**",
          confirmed), "",
  "| u shift | v shift | target n | contrast bias | coverage | alarm rate |", "|---:|---:|---:|---:|---:|---:|",
  sprintf("| %.1f | %.1f | %d | %.3f | %.3f | %.3f |", summ$mu_u, summ$mu_v, summ$n_t, summ$bias, summ$coverage, summ$alarm), "",
  sprintf("Per-replicate AUROC of |z| for a biased contrast: %.3f.", au), "",
  "| alarm threshold on abs z | false alarm (unbiased cells) | detection (biased cells) |", "|---:|---:|---:|",
  sprintf("| %.3f | %.3f | %.3f |", oc$z_tol, oc$false_alarm, oc$detection), "")
write.csv(data.frame(auroc = au), "results/auroc.csv", row.names = FALSE)
write.csv(oc, "results/thresholds.csv", row.names = FALSE)
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
