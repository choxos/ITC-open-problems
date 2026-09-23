## Per-contrast performance, per-analysis ranking error, controls, decision.
## Writes results/contrasts.csv, results/ranking.csv, results/decision.md.
source("R/00-model.R")
g <- build_grid()
d <- do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS))
d <- merge(d, g, by = "cell")

con <- do.call(rbind, lapply(split(d, list(d$cell, d$k), drop = TRUE), function(z) {
  cc <- g[g$cell == z$cell[1], ]; R <- reported(cc); I <- apply(R, 1, all); k <- z$k[1]
  em <- z$max_est - z$truth; ei <- z$int_est - z$truth; n <- nrow(z)
  data.frame(cell = z$cell[1], k = k,
             bias_max = mean(em), mcse_max = stats::sd(em) / sqrt(n),
             bias_int = mean(ei), mcse_int = stats::sd(ei) / sqrt(n),
             exact_max = exact_bias(cc, R[, k], k), exact_int = exact_bias(cc, I, k),
             cover_max = mean(abs(em) <= 1.96 * z$max_se), cover_int = mean(abs(ei) <= 1.96 * z$int_se),
             cover_bnd = mean(z$bnd_lo <= z$truth & z$truth <= z$bnd_hi),
             width_bnd = mean(z$bnd_hi - z$bnd_lo), width_max = mean(2 * 1.96 * z$max_se))
}))
con <- merge(con, g, by = "cell")
write.csv(con, "results/contrasts.csv", row.names = FALSE)

rk <- do.call(rbind, lapply(split(d, list(d$cell, d$rep), drop = TRUE), function(z) {
  z <- z[order(z$k), ]; tt <- which.max(z$truth)
  data.frame(cell = z$cell[1], rep = z$rep[1],
             top_max = which.max(z$max_est) != tt, top_int = which.max(z$int_est) != tt,
             any_max = any(rank(-z$max_est) != rank(-z$truth)),
             any_int = any(rank(-z$int_est) != rank(-z$truth)),
             diag = max(abs(z$max_est - z$int_est)))
}))
auroc <- function(s, y) { if (!any(y) || all(y)) return(NA)
  r <- rank(c(s[y], s[!y])); (sum(r[seq_len(sum(y))]) - sum(y) * (sum(y) + 1) / 2) / (sum(y) * sum(!y)) }
per <- do.call(rbind, lapply(split(rk, rk$cell), function(z) {
  dd <- z$top_int - z$top_max
  data.frame(cell = z$cell[1], p_top_max = mean(z$top_max), p_top_int = mean(z$top_int),
             diff_int_minus_max = mean(dd), diff_mcse = stats::sd(dd) / sqrt(nrow(z)),
             p_any_max = mean(z$any_max), p_any_int = mean(z$any_int))
}))
ab <- aggregate(cbind(abs_max = abs(bias_max), abs_int = abs(bias_int)) ~ cell, data = con, FUN = mean)
per <- merge(merge(per, ab, by = "cell"), g, by = "cell")
write.csv(per, "results/ranking.csv", row.names = FALSE)

prim <- per[per$pattern == "adversarial" & per$similarity == "similar" & per$separation == "tied", ]
int_better_rank <- (prim$diff_int_minus_max + 1.96 * prim$diff_mcse) < 0
max_better_rank <- (prim$diff_int_minus_max - 1.96 * prim$diff_mcse) > 0
max_better_bias <- prim$abs_max < prim$abs_int
verdict <- if (sum(int_better_rank & max_better_bias) >= 2) "INVERSION CONFIRMED" else
  if (sum(max_better_rank & max_better_bias) >= 2) "MAXIMAL VINDICATED" else
  if (sum(int_better_rank & !max_better_bias) >= 2) "INTERSECTION DOMINANT" else "NO REGISTERED BRANCH MET"

main <- rk[rk$cell %in% g$cell[g$pattern != "complete" & g$strength > 0], ]
au <- auroc(main$diag, main$top_max)
disp <- per[per$similarity == "dispersed" & per$pattern != "complete" & per$strength > 0, ]
simi <- per[per$similarity == "similar" & per$pattern != "complete" & per$strength > 0, ]
ctl1 <- con[con$pattern == "complete", ]; ctl2 <- con[con$strength == 0, ]
c1 <- all(abs(ctl1$bias_max - ctl1$bias_int) < 1e-10) && all(abs(ctl1$bias_max) <= 3 * ctl1$mcse_max)
c2 <- all(abs(ctl2$bias_max) <= 3 * ctl2$mcse_max) && all(abs(ctl2$bias_int) <= 3 * ctl2$mcse_int)
mc <- con[con$pattern != "complete" & con$strength > 0, ]
c3 <- mean(abs(mc$bias_max - mc$exact_max) <= 3 * mc$mcse_max & abs(mc$bias_int - mc$exact_int) <= 3 * mc$mcse_int)

md <- c("# Decision", "", sprintf("**Registered rule (protocol.md section 3): %s.**", verdict), "",
  "| strength | P(top wrong), maximal | P(top wrong), intersection | difference (MCSE) | mean abs bias, maximal | intersection |",
  "|---:|---:|---:|---:|---:|---:|",
  sprintf("| %.2f | %.3f | %.3f | %.3f (%.3f) | %.3f | %.3f |", prim$strength, prim$p_top_max, prim$p_top_int,
          prim$diff_int_minus_max, prim$diff_mcse, prim$abs_max, prim$abs_int), "",
  sprintf("Similar populations: intersection lower on top-rank error in %d of %d cells. Dispersed: %d of %d.",
          sum(simi$diff_int_minus_max < 0), nrow(simi), sum(disp$diff_int_minus_max < 0), nrow(disp)), "",
  sprintf("Diagnostic max_k |maximal - intersection| against a wrong top rank under the maximal set: AUROC %.3f (fit for purpose if >= 0.75).", au), "",
  sprintf("Bounded interval: coverage %.3f to %.3f, width ratio to the maximal interval %.2f to %.2f (median).",
          min(mc$cover_bnd), max(mc$cover_bnd), min(mc$width_bnd / mc$width_max), stats::median(mc$width_bnd / mc$width_max)), "",
  sprintf("Controls: complete reporting %s; zero strength %s; simulation within 3 MCSE of exact bias in %.1f%% of contrasts.",
          c1, c2, 100 * c3), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
