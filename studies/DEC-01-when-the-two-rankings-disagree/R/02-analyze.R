## Rank correlation between RMSE and expected-loss rankings by stratum; decision.
s <- read.csv("results/scored.csv")
s$near <- abs(s$d) == 0.1; s$poor <- s$shift == 0.6 & s$ratio == 0.5
rk <- do.call(rbind, lapply(split(s, list(s$cell, s$d, s$c), drop = TRUE), function(z) {
  data.frame(cell = z$cell[1], d = z$d[1], c = z$c[1], near = z$near[1], poor = z$poor[1], design = z$design[1],
             rho = suppressWarnings(stats::cor(z$rmse, z$loss, method = "spearman")),
             same_best = z$method[which.min(z$rmse)] == z$method[which.min(z$loss)],
             rmse_best = z$method[which.min(z$rmse)], loss_best = z$method[which.min(z$loss)]) }))
write.csv(rk, "results/rank-agreement.csv", row.names = FALSE)
agg <- aggregate(cbind(rho, same_best) ~ near + poor + c, data = rk, FUN = function(x) mean(x, na.rm = TRUE))
prim <- rk[rk$near & rk$poor & rk$c == 1, ]
set.seed(1); bs <- replicate(2000, mean(sample(prim$rho, replace = TRUE), na.rm = TRUE))
m <- mean(prim$rho, na.rm = TRUE); ci <- stats::quantile(bs, c(0.025, 0.975))
verdict <- if (m <= 0.7 && ci[2] < 0.9) "CONFIRMED" else if (m >= 0.9) "REFUTED" else "INCONCLUSIVE"
## Consequence 1: bias pointing away from the threshold lowers wrong-decision probability.
b <- s[abs(s$bias) > 0.05 & s$c == 1, ]; b$away <- sign(b$bias) != sign(b$d)
c1 <- aggregate(wrong ~ away + near, data = b, FUN = mean)
## Consequence 2: the same method's rank moves with the sign and size of d.
md <- c("# Decision", "",
  sprintf("**Primary (near threshold, poor overlap, symmetric loss): mean Spearman rho between RMSE and expected-loss rankings %.2f (95%% bootstrap interval %.2f to %.2f) over %d cell-threshold strata: %s.**",
          m, ci[1], ci[2], nrow(prim), verdict), "",
  sprintf("RMSE-best method also loss-best in %.0f%% of primary strata.", 100 * mean(prim$same_best)), "",
  "| near threshold | poor overlap | loss ratio | mean rho | share with the same best method |", "|:--:|:--:|---:|---:|---:|",
  sprintf("| %s | %s | %d | %.2f | %.2f |", agg$near, agg$poor, agg$c, agg$rho, agg$same_best), "",
  "Wrong-decision probability for methods with |bias| > 0.05, by whether the bias points away from the threshold:", "",
  "| near | bias away from threshold | wrong-decision probability |", "|:--:|:--:|---:|",
  sprintf("| %s | %s | %.3f |", c1$near, c1$away, c1$wrong), "",
  sprintf("Null control (far from threshold, good overlap: shift 0, ratio 1, symmetric loss): largest wrong-decision probability %.3f.",
          max(s$wrong[!s$near & s$shift == 0 & s$ratio == 1 & s$c == 1])), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
