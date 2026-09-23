## G-computation performance by cell; each aggregated diagnostic, over the true law and
## over the independence reconstruction, scored as a classifier of interval failure;
## controls; decision.
source("R/00-model.R")
g <- build_grid()
L <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
W <- reshape(L[, c("cell", "rep", "diag", "true_law", "indep")], idvar = c("cell", "rep"), timevar = "diag", direction = "wide")
d <- merge(unique(L[, c("cell", "rep", "est", "se", "truth", "mu", "rho", "shape")]), W, by = c("cell", "rep"))
d <- d[!is.na(d$est), ]; d$err <- d$est - d$truth
d$fail <- abs(d$err) > 1.96 * d$se; d$fail_mat <- abs(d$err) > MATERIAL
d$se.contrast <- d$se

summ <- do.call(rbind, lapply(split(d, d$cell), function(z) data.frame(cell = z$cell[1], n_ok = nrow(z), bias = mean(z$err),
  mcse = stats::sd(z$err) / sqrt(nrow(z)), rmse = sqrt(mean(z$err^2)), coverage = 1 - mean(z$fail), cov_mcse = sqrt(mean(z$fail) * (1 - mean(z$fail)) / nrow(z)),
  fail_mat = mean(z$fail_mat), hull_true = mean(z$true_law.hull), hull_indep = mean(z$indep.hull))))
summ <- merge(g, summ, by = "cell"); summ$truth <- vapply(seq_len(nrow(summ)), function(i) truth(summ[i, ]), 0)
write.csv(summ, "results/summary.csv", row.names = FALSE)

auroc <- function(s, y) { if (!any(y) || all(y)) return(NA)
  r <- rank(c(s[y], s[!y])); (sum(r[seq_len(sum(y))]) - sum(y) * (sum(y) + 1) / 2) / (sum(y) * sum(!y)) }
cols <- c(paste0("true_law.", DIAGS), paste0("indep.", DIAGS), "se.contrast")
score <- function(z, f) vapply(cols, function(k) auroc(z[[k]], z[[f]]), 0)
pools <- list(bent = d[d$shape == "bent", ], linear = d[d$shape == "linear", ], all = d)
## Bootstrap within cells, the same resample for every diagnostic, so gaps are paired.
set.seed(MASTER_SEED + 1)
boot <- function(z, f) { idx <- split(seq_len(nrow(z)), z$cell)
  t(replicate(200, { i <- unlist(lapply(idx, function(k) k[sample.int(length(k), replace = TRUE)])); score(z[i, ], f) })) }
au <- do.call(rbind, lapply(names(pools), function(p) do.call(rbind, lapply(c("fail", "fail_mat"), function(f) {
  z <- pools[[p]]; a <- score(z, f); b <- boot(z, f)
  data.frame(pool = p, failure = f, diagnostic = cols, auroc = a, se = apply(b, 2, stats::sd),
             gap_vs_indep = c(a[1:5] - a[6:10], rep(NA, 6)), gap_se = c(apply(b[, 1:5] - b[, 6:10], 2, stats::sd), rep(NA, 6)),
             failure_rate = mean(z[[f]])) }))))
rownames(au) <- NULL; write.csv(au, "results/auroc.csv", row.names = FALSE)

pb <- au[au$pool == "bent" & au$failure == "fail", ]; A <- setNames(pb$auroc, pb$diagnostic)
gap <- pb$gap_vs_indep[pb$diagnostic == "true_law.hull"]; gse <- pb$gap_se[pb$diagnostic == "true_law.hull"]
verdict <- if (gap >= 0.10) "CONFIRMED: reconstruction from marginals removes a material part of the diagnostic's discrimination" else
  if (gap < 0.03) "IMMATERIAL: the reconstructed-law diagnostic discriminates as the true-law one does" else "PARTIAL: a loss below the registered 0.10"
agg <- A[["true_law.maha_q95"]] - A[["true_law.maha_mean"]]
aggv <- if (agg >= 0.05) "TAIL BETTER" else if (agg <= -0.05) "MEAN BETTER" else "EQUIVALENT"
comp <- max(A[["se.contrast"]], A[["indep.predsd"]]) >= A[["indep.hull"]] - 0.02
lin <- summ[summ$shape == "linear", ]; pl <- au[au$pool == "linear" & au$failure == "fail", ]
null_ok <- all(1 - lin$coverage >= 0.03 & 1 - lin$coverage <= 0.07) && all(pl$auroc >= 0.45 & pl$auroc <= 0.55, na.rm = TRUE)
z0 <- L[L$rho == 0, ]; id0 <- max(abs(z0$true_law - z0$indep), na.rm = TRUE)
pc <- summ[summ$mu == 0.6 & summ$rho == max(RHO) & summ$shape == "bent", ]
pos_ok <- abs(pc$bias) >= 0.3 && 1 - pc$coverage >= 0.6 && pc$hull_true - pc$hull_indep >= 0.02
f3 <- function(x) sprintf("%.3f", x)
md <- c("# Decision", "", sprintf("**Registered primary (bent cells, interval failure): hull mass AUROC over the true law minus over the independence reconstruction %s (SE %s): %s.**", f3(gap), f3(gse), verdict), "",
  sprintf("Hull mass AUROC: true law %s, independence %s.", f3(A[["true_law.hull"]]), f3(A[["indep.hull"]])), "",
  sprintf("Aggregation (true law, Mahalanobis distance): 95th percentile minus mean AUROC %s: %s (registered: tail better if at least 0.05, mean better if at most -0.05).", f3(agg), aggv), "",
  sprintf("Comparator that can win: the model's own contrast SE (%s) or mean prediction SD over the reconstruction (%s) within 0.02 of the reconstructed hull mass (%s): %s.",
          f3(A[["se.contrast"]]), f3(A[["indep.predsd"]]), f3(A[["indep.hull"]]), comp), "",
  sprintf("Null control (linear cells: failure 0.03 to 0.07 in each; every AUROC 0.45 to 0.55): %s; failure %s.", null_ok, paste(f3(1 - lin$coverage), collapse = ", ")), "",
  sprintf("Second null (rho = 0: true-law and reconstructed diagnostics identical): largest difference %.1e.", id0), "",
  sprintf("Positive control (mean 0.6, largest rho, bent: |bias| at least 0.3, failure at least 0.6, hull understated by at least 0.02): %s; bias %s, failure %s, understatement %s.",
          pos_ok, f3(pc$bias), f3(1 - pc$coverage), f3(pc$hull_true - pc$hull_indep)), "",
  sprintf("Replicates lost: %d of %d.", length(unique(paste(L$cell, L$rep))) - nrow(d), length(unique(paste(L$cell, L$rep)))), "",
  "| target mean | rho | shape | truth | bias (MCSE) | coverage (MCSE) | P(|error| > 0.2) | hull mass true | hull mass reconstructed |",
  "|---:|---:|---|---:|---:|---:|---:|---:|---:|",
  sprintf("| %.1f | %.1f | %s | %.3f | %.3f (%.3f) | %.3f (%.3f) | %.3f | %.3f | %.3f |", summ$mu, summ$rho, summ$shape, summ$truth, summ$bias, summ$mcse,
          summ$coverage, summ$cov_mcse, summ$fail_mat, summ$hull_true, summ$hull_indep), "",
  "| pool | failure | diagnostic | AUROC (SE) | true minus reconstructed (SE) | failure rate |", "|---|---|---|---:|---:|---:|",
  sprintf("| %s | %s | %s | %.3f (%.3f) | %s | %.3f |", au$pool, au$failure, au$diagnostic, au$auroc, au$se,
          ifelse(is.na(au$gap_vs_indep), "", sprintf("%.3f (%.3f)", au$gap_vs_indep, au$gap_se)), au$failure_rate), "")
writeLines(md, "results/decision.md"); cat(md[1:15], sep = "\n")
