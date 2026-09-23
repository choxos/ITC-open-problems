## Estimator performance, diagnostics as classifiers of failure, abstention frontier.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
perf <- function(est, se, tr) { e <- est - tr; cv <- mean(abs(e) <= 1.96 * se)
  c(bias = mean(e), mcse = stats::sd(e) / sqrt(length(e)), rmse = sqrt(mean(e^2)), coverage = cv, emp_sd = stats::sd(est), mean_se = mean(se)) }
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) {
  rbind(data.frame(cell = z$cell[1], method = "maic", t(perf(z$maic_est, z$maic_se, z$truth))),
        data.frame(cell = z$cell[1], method = "gcomp", t(perf(z$gc_est, z$gc_se, z$truth))),
        data.frame(cell = z$cell[1], method = "trimmed_vs_restricted", t(perf(z$trim_est, z$trim_se, z$truth_r)))) }))
summ <- merge(g, summ, by = "cell")
diag_means <- aggregate(cbind(ess_frac, unsup_mass, align_score) ~ cell, data = d, FUN = mean)
summ <- merge(summ, diag_means, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)

auroc <- function(s, y) { if (!any(y) || all(y)) return(NA)
  r <- rank(c(s[y], s[!y])); (sum(r[seq_len(sum(y))]) - sum(y) * (sum(y) + 1) / 2) / (sum(y) * sum(!y)) }
d$fail_gc <- abs(d$gc_est - d$truth) > 1.96 * d$gc_se
d$fail_maic <- abs(d$maic_est - d$truth) > 1.96 * d$maic_se
d$fail_gc_mat <- abs(d$gc_est - d$truth) > MATERIAL
## Each diagnostic oriented so that larger means more risk.
scores <- list(kish_ess = function(z) -z$ess_frac, unsupported_mass = function(z) z$unsup_mass,
               max_weight_share = function(z) z$max_w_share, alignment_score = function(z) z$align_score)
set.seed(2)
au <- do.call(rbind, lapply(c(list(all = d), split(d, d$c_trunc)), function(z) do.call(rbind, lapply(c("fail_gc", "fail_maic", "fail_gc_mat"), function(f)
  do.call(rbind, lapply(names(scores), function(s) {
    a <- auroc(scores[[s]](z), z[[f]])
    bs <- replicate(200, { i <- sample.int(nrow(z), replace = TRUE); auroc(scores[[s]](z[i, ]), z[[f]][i]) })
    data.frame(c_trunc = z$c_trunc[1], failure = f, diagnostic = s, auroc = a, se = stats::sd(bs), failure_rate = mean(z[[f]])) }))))))
au$c_trunc[au$c_trunc == Inf & nrow(au) > 0] <- au$c_trunc[au$c_trunc == Inf]
au$pool <- rep(c("all", names(split(d, d$c_trunc))), each = 12)
write.csv(au, "results/auroc.csv", row.names = FALSE)

## Abstention frontier on the weakest overlap: abstain when the score exceeds its quantile.
w <- d[d$c_trunc == 1, ]
fr <- do.call(rbind, lapply(names(scores), function(s) { sc <- scores[[s]](w)
  do.call(rbind, lapply(seq(0.1, 0.9, 0.1), function(p) { ab <- sc > stats::quantile(sc, 1 - p)
    data.frame(diagnostic = s, abstain_rate = mean(ab), missed_failure = mean(!ab[w$fail_gc]), false_abstention = mean(ab[!w$fail_gc])) })) }))
write.csv(fr, "results/frontier.csv", row.names = FALSE)

pw <- au[au$pool == "1" & au$failure == "fail_gc", ]
gap <- pw$auroc[pw$diagnostic == "alignment_score"] - pw$auroc[pw$diagnostic == "kish_ess"]
gse <- sqrt(sum(pw$se[pw$diagnostic %in% c("alignment_score", "kish_ess")]^2))
k_by <- au[au$failure == "fail_gc" & au$diagnostic == "kish_ess" & au$pool != "all", ]
a_by <- au[au$failure == "fail_gc" & au$diagnostic == "alignment_score" & au$pool != "all", ]
verdict <- if (gap >= 0.10) "CONFIRMED" else if (all(c(k_by$auroc, a_by$auroc) >= 0.7, na.rm = TRUE)) "REFUTED" else
  if (max(k_by$auroc, a_by$auroc, na.rm = TRUE) < 0.7) "NEITHER USABLE" else "NOT CONFIRMED"
gc <- summ[summ$method == "gcomp", ]; ma <- summ[summ$method == "maic", ]; tr <- summ[summ$method == "trimmed_vs_restricted", ]
ortho <- gc[gc$align == "orthogonal" & is.finite(gc$c_trunc), ]
pos <- gc[gc$align == "full" & gc$c_trunc == 1 & gc$shape == "bent", ]
null <- summ[is.infinite(summ$c_trunc) & summ$method != "trimmed_vs_restricted", ]
md <- c("# Decision", "",
  sprintf("**Primary (weakest overlap, G-computation interval failure): alignment-aware score minus Kish ESS AUROC %.3f (SE %.3f): %s.**", gap, gse, verdict), "",
  "| truncation | failure | diagnostic | AUROC | SE | failure rate |", "|---|---|---|---:|---:|---:|",
  sprintf("| %s | %s | %s | %.3f | %.3f | %.3f |", au$pool, au$failure, au$diagnostic, au$auroc, au$se, au$failure_rate), "",
  sprintf("Second null control (orthogonal alignment, truncated support): G-computation |bias| at most %.3f, within 3 MCSE in %d of %d cells.",
          max(abs(ortho$bias)), sum(abs(ortho$bias) <= 3 * ortho$mcse), nrow(ortho)), "",
  sprintf("Positive control (full alignment, bent, truncation at 1): G-computation bias %s; MAIC bias %s.",
          paste(sprintf("%.3f", pos$bias), collapse = ", "), paste(sprintf("%.3f", ma$bias[ma$cell %in% pos$cell]), collapse = ", ")), "",
  sprintf("Null control (full support): coverage %.3f to %.3f, |bias| at most %.3f.", min(null$coverage), max(null$coverage), max(abs(null$bias))), "",
  sprintf("Extrapolation falsifier (linear modification, full alignment, truncation at 1): G-computation bias %s.",
          paste(sprintf("%.3f", gc$bias[gc$align == "full" & gc$c_trunc == 1 & gc$shape == "linear"]), collapse = ", ")), "",
  sprintf("Trimmed G-computation against the restricted estimand: |bias| at most %.3f, coverage %.3f to %.3f.", max(abs(tr$bias)), min(tr$coverage), max(tr$coverage)), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
