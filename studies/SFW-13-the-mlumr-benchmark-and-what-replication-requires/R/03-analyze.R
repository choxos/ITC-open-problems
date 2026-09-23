## Bias and coverage against truth and against the analytic omitted-covariate bias;
## agreement of mlumr with the independent g-computation; decision.
source("R/00-model.R")
g <- build_grid(); tr <- do.call(rbind, lapply(seq_len(nrow(g)), function(i) data.frame(cell = g$cell[i], t(truth(g[i, ])))))
names(tr)[names(tr) %in% c("pA", "pB", "lor")] <- c("pA_true", "pB_true", "lor_true")
d <- merge(do.call(rbind, lapply(list.files("results/run", pattern = "^cell", full.names = TRUE), readRDS)), tr, by = "cell")
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) { ok <- !is.na(z$pA); n <- sum(ok); z <- z[ok, ]
  e <- z$pA - z$pA_true; el <- z$lor - z$lor_true; cv <- z$lo <= z$pA_true & z$pA_true <= z$hi; cl <- z$lor_lo <= z$lor_true & z$lor_true <= z$lor_hi
  data.frame(cell = z$cell[1], method = z$method[1], n = n, fail_rate = 1 - n / (n + sum(!ok)), pA_true = z$pA_true[1], bias_pA = mean(e), mcse_pA = stats::sd(e) / sqrt(n),
             analytic_bias_pA = z$bias_pA[1], coverage_pA = mean(cv), mcse_cov = sqrt(mean(cv) * (1 - mean(cv)) / n), emp_sd_pA = stats::sd(z$pA), mean_se_pA = mean(z$se_pA),
             lor_true = z$lor_true[1], bias_lor = mean(el), mcse_lor = stats::sd(el) / sqrt(n), analytic_bias_lor = z$bias_lor[1], coverage_lor = mean(cl),
             rhat_gt_101 = mean(z$max_rhat > 1.01), any_divergent = mean(z$n_divergent > 0), mean_sec = mean(z$sec)) }))
summ <- merge(g, summ, by = "cell"); summ <- summ[order(summ$cell, summ$method), ]
write.csv(summ, "results/summary.csv", row.names = FALSE)

## Paired checks on mlumr: agreement with the witness, and reduction to the IPD mean in the IPD's own population.
m <- d[d$method == "mlumr" & !is.na(d$pA), ]; w <- d[d$method == "witness" & !is.na(d$pA), c("cell", "rep", "pA")]; names(w)[3] <- "pA_w"
m <- merge(m, w, by = c("cell", "rep"))
chk <- do.call(rbind, lapply(split(m, m$cell), function(z) data.frame(cell = z$cell[1], n = nrow(z),
  agree = mean(abs(z$pA - z$pA_w) <= 0.25 * z$se_pA), mean_abs_diff_sd = mean(abs(z$pA - z$pA_w) / z$se_pA),
  index_reduces = mean(abs(z$pA_index - z$ybar_ipd) <= 0.25 * z$sd_pA_index))))
chk <- merge(g, chk, by = "cell"); write.csv(chk, "results/checks.csv", row.names = FALSE)

ml <- summ[summ$method == "mlumr", ]; tol <- function(z) pmax(3 * z$mcse_pA, 0.005)
null <- ml[ml$bu == 0, ]; null_ok <- all(abs(null$bias_pA) <= tol(null) & null$coverage_pA >= 0.915 & null$coverage_pA <= 0.985)
agree_ok <- all(chk$agree >= 0.95); index_ok <- all(chk$index_reduces >= 0.95)
pos <- ml[ml$bu == 0.5, ]; fires <- all(abs(pos$analytic_bias_pA) >= 0.05)
pos_ok <- fires && all(abs(pos$bias_pA - pos$analytic_bias_pA) <= tol(pos)); beyond <- any(abs(pos$bias_pA) > abs(pos$analytic_bias_pA) + tol(pos))
verdict <- if (!(agree_ok && index_ok && null_ok)) "IMPLEMENTATION DEFECT INDICATED: localize before any claim" else
  if (beyond) "BIAS BEYOND THE KNOWN IDENTIFICATION FAILURE" else if (pos_ok) "BEHAVES AS THE THEORY SAYS on the checkable part" else "MIXED: see the table"
f3 <- function(x) sprintf("%.3f", x)
md <- c("# Decision", "", sprintf("**Registered primary: %s.**", verdict), "",
  sprintf("Agreement with the independent g-computation (|difference| <= 0.25 posterior SD in at least 95%% of replicates, every cell): %s; shares %s.", agree_ok, paste(f3(chk$agree), collapse = ", ")), "",
  sprintf("Reduction in the IPD's own population (posterior mean within 0.25 posterior SD of the IPD proportion in at least 95%%): %s; shares %s.", index_ok, paste(f3(chk$index_reduces), collapse = ", ")), "",
  sprintf("Null control (no omitted covariate: |bias| <= max(3 MCSE, 0.005), coverage 0.915 to 0.985): %s; bias %s, coverage %s.", null_ok, paste(f3(null$bias_pA), collapse = ", "), paste(f3(null$coverage_pA), collapse = ", ")), "",
  sprintf("Positive control (strong omitted covariate: bias equals the analytic value within max(3 MCSE, 0.005); analytic value at least 0.05): %s; bias %s against analytic %s.",
          pos_ok, paste(f3(pos$bias_pA), collapse = ", "), paste(f3(pos$analytic_bias_pA), collapse = ", ")), "",
  "| omitted BU | comparator x1 mean | method | failed | truth pA | bias pA (MCSE) | analytic bias | coverage pA | empirical SD | mean SE | bias LOR | coverage LOR | Rhat > 1.01 | divergent | s per fit |",
  "|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %.2f | %.1f | %s | %.3f | %.3f | %.4f (%.4f) | %.4f | %.3f | %.3f | %.3f | %.3f | %.3f | %s | %s | %s |", summ$bu, summ$m1, summ$method, summ$fail_rate, summ$pA_true,
          summ$bias_pA, summ$mcse_pA, summ$analytic_bias_pA, summ$coverage_pA, summ$emp_sd_pA, summ$mean_se_pA, summ$bias_lor, summ$coverage_lor,
          ifelse(is.na(summ$rhat_gt_101), "", f3(summ$rhat_gt_101)), ifelse(is.na(summ$any_divergent), "", f3(summ$any_divergent)), ifelse(is.na(summ$mean_sec), "", sprintf("%.1f", summ$mean_sec))), "")
writeLines(md, "results/decision.md"); cat(md[1:11], sep = "\n")
