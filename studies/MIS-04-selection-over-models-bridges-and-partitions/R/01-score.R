## ---------------------------------------------------------------------------
## MIS-04: model selection among population-adjustment methods, re-scored on
## DIA-08's stored replicates (16 scenarios x 2000; per replicate the estimate and
## SE of unadjusted, MAIC on means, MAIC on means and SDs, linear STC and
## quadratic STC for the target marginal log OR, B versus A).
## Candidates: the four adjusted methods. Rules:
##   prespecified_stc   linear STC always
##   prespecified_maic  MAIC on means always
##   min_se             the candidate with the smallest SE (selection by precision)
##   most_favorable     the candidate with the most negative estimate (selection by result)
##   averaged           equal-weight average; variance = mean within-model variance
##                      plus the between-model variance of the four estimates
## ---------------------------------------------------------------------------
SRC <- "../DIA-08-generators-that-decide-the-comparison"
cand <- c("maic_means", "maic_means_sds", "stc_linear", "stc_flexible")
g <- read.csv(file.path(SRC, "results/summary.csv")); g <- unique(g[, c("cell", "departure", "m", "law")])
score_cell <- function(f) { z <- readRDS(f); z <- z[z$method %in% cand, ]
  w <- lapply(split(z, z$rep), function(r) { r <- r[match(cand, r$method), ]; if (anyNA(r$est)) return(NULL)
    i1 <- which.min(r$se); i2 <- which.min(r$est); va <- mean(r$se^2) + stats::var(r$est)
    data.frame(rule = c("prespecified_stc", "prespecified_maic", "min_se", "most_favorable", "averaged"),
               est = c(r$est[3], r$est[1], r$est[i1], r$est[i2], mean(r$est)), se = c(r$se[3], r$se[1], r$se[i1], r$se[i2], sqrt(va)),
               chosen = c("stc_linear", "maic_means", cand[i1], cand[i2], "all")) })
  w <- do.call(rbind, w); w$truth <- z$truth[1]; w$cell <- z$cell[1]; w }
d <- do.call(rbind, lapply(list.files(file.path(SRC, "results/run"), full.names = TRUE), score_cell))
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$rule), drop = TRUE), function(z) { e <- z$est - z$truth; cv <- mean(abs(e) <= 1.96 * z$se)
  data.frame(cell = z$cell[1], rule = z$rule[1], bias = mean(e), rmse = sqrt(mean(e^2)), coverage = cv, cov_mcse = sqrt(cv * (1 - cv) / nrow(z)),
             width = mean(2 * 1.96 * z$se), top_choice = names(sort(table(z$chosen), decreasing = TRUE))[1], top_share = max(table(z$chosen)) / nrow(z)) }))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
r <- function(k) summ[summ$rule == k, ]
fails <- any(r("min_se")$coverage + 1.96 * r("min_se")$cov_mcse < 0.93) || any(r("most_favorable")$coverage < 0.93) ||
  any(abs(r("averaged")$coverage - r("prespecified_stc")$coverage) > 0.03)
md <- c("# Decision", "",
  sprintf("**Refuting sentence (averaging over surviving candidates changes nothing, so conditional intervals are adequate): %s.** Coverage: prespecified linear STC %.3f to %.3f; selection by smallest SE %.3f to %.3f; selection by most favorable estimate %.3f to %.3f; averaged %.3f to %.3f.",
          if (fails) "FAILS" else "HOLDS", min(r("prespecified_stc")$coverage), max(r("prespecified_stc")$coverage), min(r("min_se")$coverage), max(r("min_se")$coverage),
          min(r("most_favorable")$coverage), max(r("most_favorable")$coverage), min(r("averaged")$coverage), max(r("averaged")$coverage)), "",
  "| departure | target mean | law | rule | bias | RMSE | coverage | width | most chosen (share) |", "|---|---:|---|---|---:|---:|---:|---:|---|",
  sprintf("| %s | %.1f | %s | %s | %.3f | %.3f | %.3f | %.3f | %s (%.2f) |", summ$departure, summ$m, summ$law, summ$rule, summ$bias, summ$rmse, summ$coverage, summ$width, summ$top_choice, summ$top_share), "")
writeLines(md, "results/decision.md"); cat(md[1:3], sep = "\n")
