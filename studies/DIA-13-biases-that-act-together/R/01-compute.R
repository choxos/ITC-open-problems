## Bias surface, pairwise and three-way interactions, one-at-a-time bounds; decision.
source("R/00-model.R")
g <- expand.grid(gu = c(-1, -0.5, 0, 0.5, 1), m = c(0, 0.1, 0.2), r = c(1, 0.8, 0.6))
g$b <- mapply(bias, g$gu, g$m, g$r)
b0 <- bias(0, 0, 1)
g$b_oc <- mapply(function(a) bias(a, 0, 1), g$gu) - b0
g$b_mc <- mapply(function(a) bias(0, a, 1), g$m) - b0
g$b_me <- mapply(function(a) bias(0, 0, a), g$r) - b0
g$sum_marg <- g$b_oc + g$b_mc + g$b_me
g$interaction <- (g$b - b0) - g$sum_marg
g$rel_inter <- ifelse(abs(g$sum_marg) > 1e-8, abs(g$interaction) / abs(g$sum_marg), NA)
g$oat_max <- pmax(abs(g$b_oc), abs(g$b_mc), abs(g$b_me))
g$exceeds_oat <- abs(g$b - b0) > g$oat_max + 1e-9
g$cancel <- sign(g$b_oc) * sign(g$b_mc + g$b_me) < 0
write.csv(g, "results/surface.csv", row.names = FALSE)
act <- g[(g$gu != 0) + (g$m != 0) + (g$r != 1) >= 2, ]
additive <- max(act$rel_inter, na.rm = TRUE) <= 0.10
md <- c("# Decision", "",
  sprintf("**Refuting sentence (biases combine approximately additively, so one-at-a-time analyses bound the joint effect): %s.** Where two or three mechanisms act together, the interaction is at most %.1f%% of the sum of the marginal biases (median %.1f%%); the joint bias exceeds the largest single-mechanism bias in %d of %d such scenarios, and mechanisms partly cancel in %d.",
          if (additive) "ADDITIVITY HOLDS, but one-at-a-time maxima do not bound the joint bias" else "FAILS", 100 * max(act$rel_inter, na.rm = TRUE),
          100 * stats::median(act$rel_inter, na.rm = TRUE), sum(act$exceeds_oat), nrow(act), sum(act$cancel)), "",
  sprintf("Baseline bias with no mechanism active (non-collapsibility of the unanchored contrast): %.4f.", b0), "",
  "| omitted confounder effect | misclassification | reliability | joint bias | OC alone | MC alone | ME alone | interaction | joint beyond the largest single bias |",
  "|---:|---:|---:|---:|---:|---:|---:|---:|:--:|",
  sprintf("| %.1f | %.1f | %.1f | %.3f | %.3f | %.3f | %.3f | %.4f | %s |", g$gu, g$m, g$r, g$b - b0, g$b_oc, g$b_mc, g$b_me, g$interaction, g$exceeds_oat), "")
writeLines(md, "results/decision.md"); cat(md[1:5], sep = "\n")
