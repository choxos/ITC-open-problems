## Reversal probability, target difference versus sampling, remedies; decision.
## Writes results/summary.csv, results/reversal.csv, results/decision.md.
source("R/00-model.R")
g <- build_grid()
d <- do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS))
w <- reshape(d[, c("cell", "rep", "method", "est")], idvar = c("cell", "rep"), timevar = "method", direction = "wide")
names(w) <- sub("^est\\.", "", names(w))
rev <- do.call(rbind, lapply(split(w, w$cell), function(z) {
  cc <- g[g$cell == z$cell[1], ]; th <- truth(cc)
  a <- z$sponsorA; b <- z$sponsorB
  p_rev <- mean(sign(a) != sign(b))
  ## bivariate normal prediction with the empirical moments, with and without correlation
  pn <- function(r) {
    S <- matrix(c(stats::var(a), r * stats::sd(a) * stats::sd(b), r * stats::sd(a) * stats::sd(b), stats::var(b)), 2)
    m <- c(mean(a), mean(b))
    pp <- mvtnorm::pmvnorm(lower = c(0, 0), upper = c(Inf, Inf), mean = m, sigma = S)[1]
    nn <- mvtnorm::pmvnorm(lower = c(-Inf, -Inf), upper = c(0, 0), mean = m, sigma = S)[1]
    1 - pp - nn }
  data.frame(cell = z$cell[1], true_reversal = sign(th[["F_A"]]) != sign(th[["F_B"]]),
             p_reversal = p_rev, p_rev_mcse = sqrt(p_rev * (1 - p_rev) / nrow(z)), corr = stats::cor(a, b),
             p_pred_corr = pn(stats::cor(a, b)), p_pred_indep = pn(0))
}))
rev <- merge(g, rev, by = "cell")
write.csv(rev, "results/reversal.csv", row.names = FALSE)

tv <- function(cc) truth(cc)
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) {
  cc <- g[g$cell == z$cell[1], ]; th <- tv(cc)
  native <- switch(z$method[1], sponsorA = th[["F_B"]], sponsorB = th[["F_A"]], th[["F_D"]])
  e_n <- z$est - native; e_d <- z$est - th[["F_D"]]
  data.frame(cell = z$cell[1], method = z$method[1], bias_native = mean(e_n), mcse = stats::sd(z$est) / sqrt(nrow(z)),
             bias_FD = mean(e_d), rmse_FD = sqrt(mean(e_d^2)))
}))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)

main <- rev[rev$beta > 0 & rev$sep > 0, ]
key <- c("sep", "beta", "sizes", "sets")
bt <- merge(main[main$position == "between", c(key, "p_reversal")], main[main$position == "outside", c(key, "p_reversal")],
            by = key, suffixes = c("_between", "_outside"))
bt$diff <- bt$p_reversal_between - bt$p_reversal_outside
common <- bt[bt$sets == "common", ]
driver <- mean(common$diff > 0.20) > 0.5
pl <- main[main$position == "between" & main$sep <= 1 & main$beta <= 0.4 & main$sets == "common", ]
dsb <- summ[summ$method == "sponsorB" & summ$sets == "differing" & summ$beta > 0, ]
rem <- summ[summ$method %in% c("transportD", "average") & summ$beta > 0 & summ$sep > 0 & summ$sets == "common", ]
md <- c("# Decision", "",
  sprintf("**Target difference as a driver of disagreement: %s.** Reversal probability with the zero-effect point between the populations minus outside it exceeds 0.20 in %d of %d common-set configurations (median difference %.3f).",
          if (driver) "CONFIRMED (the refuting sentence fails)" else "NOT CONFIRMED", sum(common$diff > 0.20), nrow(common), stats::median(common$diff)), "",
  sprintf("Plausible range (separation <= 1 SD, beta <= 0.4, common sets, between): reversal probability %.3f to %.3f.",
          min(pl$p_reversal), max(pl$p_reversal)), "",
  sprintf("Correlation of the two sponsors' estimates: %.2f to %.2f. Bivariate-normal prediction error, max |simulated - predicted|: with correlation %.3f; assuming independence %.3f.",
          min(rev$corr), max(rev$corr), max(abs(rev$p_reversal - rev$p_pred_corr)), max(abs(rev$p_reversal - rev$p_pred_indep))), "",
  sprintf("Differing sets (sponsor B omits the modifier): bias against its native target %.3f to %.3f.",
          min(dsb$bias_native), max(dsb$bias_native)), "",
  sprintf("Remedies against Delta(F_D): transport-to-F_D max |bias| %.4f, median RMSE %.3f; average max |bias| %.4f, median RMSE %.3f.",
          max(abs(rem$bias_FD[rem$method == "transportD"])), stats::median(rem$rmse_FD[rem$method == "transportD"]),
          max(abs(rem$bias_FD[rem$method == "average"])), stats::median(rem$rmse_FD[rem$method == "average"])), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
