## Abstention by screen, controls, workflow coverage; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
ALPHA_Q <- 0.10
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) {
  n <- nrow(z); e <- z$pooled_cond - z$truth; cv <- abs(e) <= 1.96 * z$se_cond; pass <- z$p_cond >= ALPHA_Q
  data.frame(cell = z$cell[1], n_rep = n, abst_cond = mean(!pass), abst_marg = mean(z$p_marg < ALPHA_Q),
             abst_std = mean(z$p_std < ALPHA_Q), bias = mean(e), coverage_all = mean(cv),
             coverage_passed = if (any(pass)) mean(cv[pass]) else NA) }))
summ <- merge(g, summ, by = "cell")
mc <- function(p, n) sqrt(p * (1 - p) / n)
write.csv(summ, "results/summary.csv", row.names = FALSE)
m <- summ[summ$ctrl == "none", ]
v <- m[m$drift == "none" & m$G == 1.5, ]
gap <- v$abst_marg - v$abst_cond; gap_se <- sqrt(mc(v$abst_marg, v$n_rep)^2 + mc(v$abst_cond, v$n_rep)^2)
verdict <- if (all(gap - 1.96 * gap_se > 0) && all(gap >= 0.05)) "CONFIRMED" else if (all(gap <= 0.02)) "REFUTED" else "MIXED"
std_ok <- all(abs(v$abst_std - v$abst_cond) <= 0.03)
ctl <- summ[summ$ctrl != "none", ]
go <- merge(m[m$drift == "gap_only", ], m[m$drift == "none", c("K", "G", "abst_cond")], by = c("K", "G"), suffixes = c("", "_valid"))
md <- c("# Decision", "",
  sprintf("**Primary (consequence 1, marginal screen fires under a valid bridge): %s.** Valid bridge, G = 1.5: marginal minus conditional abstention %s (K = %s). Standardized within 0.03 of conditional: %s.",
          verdict, paste(sprintf("%.3f (SE %.3f)", gap, gap_se), collapse = ", "), paste(v$K, collapse = ", "), std_ok), "",
  "| K | G | drift | size | control | abstain cond | abstain marg | abstain std | bias in gap | coverage, all | coverage, passed |",
  "|---:|---:|---|---:|---|---:|---:|---:|---:|---:|---:|",
  sprintf("| %d | %.1f | %s | %.2f | %s | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f |", summ$K, summ$G, summ$drift, summ$size, summ$ctrl,
          summ$abst_cond, summ$abst_marg, summ$abst_std, summ$bias, summ$coverage_all, summ$coverage_passed), "",
  sprintf("Gap-only drift minus valid bridge, conditional abstention: %s (the logical half; equal in distribution by construction).",
          paste(sprintf("%.3f", go$abst_cond - go$abst_cond_valid), collapse = ", ")), "",
  sprintf("Controls: identical environments, abstention %s (nominal %.2f); risk-difference valid bridge, marginal %.3f; positive control, minimum %.3f.",
          paste(sprintf("%.3f", unlist(ctl[ctl$ctrl == "identical", c("abst_cond", "abst_marg", "abst_std")])), collapse = "/"), ALPHA_Q,
          ctl$abst_marg[ctl$ctrl == "rd"], min(unlist(ctl[ctl$ctrl == "positive", c("abst_cond", "abst_marg", "abst_std")]))), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
