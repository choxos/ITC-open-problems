## Bias against the b1 prediction, coverage, RMSE by method; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
## Predicted b1: aggregate edges' share of the pooled precision times the difference
## between their own-population and target marginal effects (population values).
pred_b1 <- function(cell, w_agd) w_agd * (marg(cell$scale, cell$beta, X_T - cell$sep) - marg(cell$scale, cell$beta, X_T))
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) { e <- z$est - z$truth; n <- nrow(z)
  data.frame(cell = z$cell[1], method = z$method[1], truth = z$truth[1], n = n, bias = mean(e), mcse = stats::sd(e) / sqrt(n), emp_sd = stats::sd(z$est),
             se_ratio = mean(z$se) / stats::sd(z$est), coverage = mean(abs(e) <= 1.96 * z$se), rmse = sqrt(mean(e^2))) }))
summ <- merge(g, summ, by = "cell")
summ$pred_b1 <- vapply(seq_len(nrow(summ)), function(i) pred_b1(summ[i, ], 1 - summ$p_ipd[i]), 0)
write.csv(summ, "results/summary.csv", row.names = FALSE)
tm <- summ[summ$method == "two_stage_marg", ]; fit <- stats::lm(bias ~ pred_b1, data = tm)
key <- summ[summ$beta == 0.3 & summ$sep > 0 & summ$sep <= 0.5, ]
cmp <- merge(key[key$method == "two_stage_marg", c("cell", "rmse")], key[key$method == "transported", c("cell", "rmse")], by = "cell", suffixes = c("_two", "_tr"))
holds <- all(cmp$rmse_two <= cmp$rmse_tr)
b2 <- merge(summ[summ$method == "two_stage_cond", c("cell", "scale", "bias")], summ[summ$method == "two_stage_marg", c("cell", "bias")], by = "cell", suffixes = c("_cond", "_marg"))
f3 <- function(x) sprintf("%.3f", x)
md <- c("# Decision", "", sprintf("**Refuting sentence (two-stage is the better practical choice at realistic separations): %s.** Two-stage RMSE against transported RMSE at separation 0.5 with modification 0.3: %s.",
          if (holds) "HOLDS" else "FAILS", paste(sprintf("cell %d: %s vs %s", cmp$cell, f3(cmp$rmse_two), f3(cmp$rmse_tr)), collapse = "; ")), "",
  sprintf("b1 check: two-stage (marginal) bias on predicted b1, slope %.3f, intercept %.4f, R^2 %.3f.", stats::coef(fit)[2], stats::coef(fit)[1], summary(fit)$r.squared), "",
  sprintf("b2 (conditional minus marginal IPD edges): continuous %s; binary %s.", paste(f3(range(b2$bias_cond[b2$scale == "continuous"] - b2$bias_marg[b2$scale == "continuous"])), collapse = " to "),
          paste(f3(range(b2$bias_cond[b2$scale == "binary"] - b2$bias_marg[b2$scale == "binary"])), collapse = " to ")), "",
  "| scale | IPD share | separation | modification | method | truth | bias | predicted b1 | coverage | SE ratio | RMSE |", "|---|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|",
  sprintf("| %s | %.2f | %.1f | %.1f | %s | %.3f | %.3f | %.3f | %.3f | %.2f | %.3f |", summ$scale, summ$p_ipd, summ$sep, summ$beta, summ$method, summ$truth, summ$bias, summ$pred_b1, summ$coverage, summ$se_ratio, summ$rmse), "")
writeLines(md, "results/decision.md"); cat(md[1:7], sep = "\n")
