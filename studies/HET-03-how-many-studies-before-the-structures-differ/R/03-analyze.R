## Selection rates by criterion and studies per class; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- merge(g, aggregate(cbind(aic_sep, bic_sep, lrt_sep) ~ cell, d, mean), by = "cell"); write.csv(summ, "results/summary.csv", row.names = FALSE)
## Accuracy at ratio 5: choosing separate when it is true, averaged with choosing shared when shared is true (ratio 1).
acc <- merge(summ[summ$ratio == 5, c("m", "aic_sep", "bic_sep", "lrt_sep")], summ[summ$ratio == 1, c("m", "aic_sep", "bic_sep", "lrt_sep")], by = "m", suffixes = c("_r5", "_r1"))
for (c0 in c("aic", "bic", "lrt")) acc[[paste0("acc_", c0)]] <- (acc[[paste0(c0, "_sep_r5")]] + 1 - acc[[paste0(c0, "_sep_r1")]]) / 2
write.csv(acc, "results/accuracy.csv", row.names = FALSE)
first <- function(v) { k <- which(v >= 0.8); if (length(k)) acc$m[min(k)] else NA }
md <- c("# Decision", "", sprintf("**Registered primary.** Balanced selection accuracy (separate at variance ratio 5, shared at ratio 1) reaches 0.8 at %s studies per class (AIC), %s (BIC), %s (likelihood-ratio test); NA means not within 40.",
          first(acc$acc_aic), first(acc$acc_bic), first(acc$acc_lrt)), "",
  "| studies per class | accuracy AIC | accuracy BIC | accuracy LRT | separate chosen at ratio 5 (AIC) | separate chosen at ratio 2 (AIC) | separate chosen when shared is true (AIC) |", "|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %d | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f |", acc$m, acc$acc_aic, acc$acc_bic, acc$acc_lrt, acc$aic_sep_r5, summ$aic_sep[summ$ratio == 2][match(acc$m, summ$m[summ$ratio == 2])], acc$aic_sep_r1), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
