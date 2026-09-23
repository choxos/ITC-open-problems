## The (weighting, outcome) x omitted-variable table, sensitivity-region location, decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
ms <- c("maic_wrong", "maic_right", "or_wrong", "or_right", "dr_both_right", "dr_w_wrong", "dr_o_wrong", "dr_both_wrong")
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) do.call(rbind, lapply(ms, function(m) {
  e <- z[[m]] - z$truth; loc <- z[[m]] - z$functional
  lo <- z[[m]] - G_MAX * D_MAX; hi <- z[[m]]
  data.frame(cell = z$cell[1], method = m, bias = mean(e), mcse = stats::sd(e) / sqrt(nrow(z)), rmse = sqrt(mean(e^2)),
             location_error = mean(loc), loc_mcse = stats::sd(loc) / sqrt(nrow(z)),
             region_includes = mean(lo <= z$truth & z$truth <= hi)) }))))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
b <- function(m, cond) summ[summ$method == m & cond, ]
## Primary: DR (both right) against each correct single-model estimator, paired, by cell.
pd <- do.call(rbind, lapply(split(d, d$cell), function(z) data.frame(cell = z$cell[1],
  dr_minus_or = mean(z$dr_both_right - z$or_right), se_or = stats::sd(z$dr_both_right - z$or_right) / sqrt(nrow(z)),
  dr_minus_maic = mean(z$dr_both_right - z$maic_right), max_abs_dr_minus_maic = max(abs(z$dr_both_right - z$maic_right)))))
pd <- merge(g, pd, by = "cell")
write.csv(pd, "results/paired.csv", row.names = FALSE)
dr <- summ[summ$method == "dr_both_right", ]
coincide <- all(abs(pd$dr_minus_or) <= 3 * pd$se_or | abs(pd$dr_minus_or) < 0.005) && all(abs(dr$bias - dr$gamma * dr$imbalance) <= 3 * dr$mcse)
z0 <- summ$gamma == 0
sn <- all(abs(b("dr_w_wrong", z0)$bias) <= 3 * b("dr_w_wrong", z0)$mcse) && all(abs(b("dr_o_wrong", z0)$bias) <= 3 * b("dr_o_wrong", z0)$mcse) &&
      all(abs(b("maic_wrong", z0)$bias) > 3 * b("maic_wrong", z0)$mcse) && all(abs(b("or_wrong", z0)$bias) > 3 * b("or_wrong", z0)$mcse)
pos <- summ[summ$gamma == 1 & summ$imbalance == 0.3, ]
bw <- merge(summ[summ$method == "dr_both_wrong", c("cell", "gamma", "imbalance", "mu1_t", "bias", "mcse")],
            summ[summ$method == "dr_both_wrong" & summ$gamma == 0, c("imbalance", "mu1_t", "bias")], by = c("imbalance", "mu1_t"), suffixes = c("", "_0"))
bw$interaction <- bw$bias - bw$bias_0 - bw$gamma * bw$imbalance
tab <- summ[summ$gamma %in% c(0, 1) & summ$imbalance == 0.3 & summ$mu1_t == 0.5, c("gamma", "method", "bias", "location_error", "region_includes")]
md <- c("# Decision", "",
  sprintf("**Primary (DR with both models correct against correctly specified single-model estimators, across gamma): %s.** Largest |DR - outcome regression| %.4f; largest |DR - MAIC with correct weights| in any replicate %.2e.",
          if (coincide) "CURVES COINCIDE" else "CURVES DIFFER", max(abs(pd$dr_minus_or)), max(pd$max_abs_dr_minus_maic)), "",
  sprintf("Second null control (gamma = 0, one model wrong: DR unbiased, the wrong single model biased): %s.", sn), "",
  sprintf("Positive control (gamma = 1, imbalance 0.3): smallest |bias| %.3f, smallest |bias|/MCSE %.1f.", min(abs(pos$bias)), min(abs(pos$bias) / pos$mcse)), "",
  sprintf("Falsifier (interaction of misspecification and omitted-variable bias, both models wrong): largest |interaction| %.3f; within 3 MCSE in %d of %d cells.",
          max(abs(bw$interaction)), sum(abs(bw$interaction) <= 3 * sqrt(2) * bw$mcse), nrow(bw)), "",
  "Imbalance 0.3, target mean of x1 0.5:", "",
  "| gamma | method | bias | location error | region includes truth |", "|---:|---|---:|---:|---:|",
  sprintf("| %.0f | %s | %.3f | %.3f | %.3f |", tab$gamma, tab$method, tab$bias, tab$location_error, tab$region_includes), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
