## ---------------------------------------------------------------------------
## DEC-01: re-score COV-03's stored replicates (108 cells x 5 methods x 1000) by
## decision error and compare the decision ranking with the RMSE ranking.
##
## Threshold tau = truth + d, d in {-0.3, -0.1, 0.1, 0.3} on the log OR scale
## (near: |d| = 0.1; far: 0.3). Decision "adopt" (B over A) when the estimate
## favors B relative to tau. With loss ratio c = cost(wrong adopt)/cost(wrong
## reject), the rule adopts when P(Delta < tau) >= c / (1 + c) under N(est, se^2);
## c = 1 is the plain rule est < tau. Expected loss per replicate is c for a wrong
## adoption and 1 for a wrong rejection (regret |d| is constant within a stratum).
## ---------------------------------------------------------------------------
SRC <- "../COV-03-prognostic-index-variance"
D_LEVELS <- c(-0.3, -0.1, 0.1, 0.3); C_LEVELS <- c(1, 2, 5)
cfg <- read.csv(file.path(SRC, "results/summary.csv"))
cfg <- unique(cfg[, c("cell", "design", "var_T", "ratio", "shift", "em")])
files <- list.files(file.path(SRC, "results/run"), full.names = TRUE)
score <- function(z) {
  z <- z[is.finite(z$est) & is.finite(z$se), ]
  do.call(rbind, lapply(split(z, z$method), function(m) {
    e <- m$est - m$truth
    do.call(rbind, lapply(D_LEVELS, function(d) do.call(rbind, lapply(C_LEVELS, function(cc) {
      tau <- m$truth + d; adopt_right <- m$truth < tau
      adopt <- stats::pnorm((tau - m$est) / m$se) >= cc / (1 + cc)
      loss <- ifelse(adopt & !adopt_right, cc, 0) + ifelse(!adopt & adopt_right, 1, 0)
      data.frame(cell = m$cell[1], method = m$method[1], d = d, c = cc, n = nrow(m),
                 rmse = sqrt(mean(e^2)), bias = mean(e), wrong = mean(loss > 0), loss = mean(loss), loss_se = stats::sd(loss) / sqrt(nrow(m)))
    }))))
  }))
}
out <- do.call(rbind, lapply(files, function(f) score(readRDS(f))))
out <- merge(cfg, out, by = "cell")
write.csv(out, "results/scored.csv", row.names = FALSE)
cat("scored", nrow(out), "rows\n")
