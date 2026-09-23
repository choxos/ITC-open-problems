## Size and power by rule, violation, heterogeneity, spread and position; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
rej <- function(z) abs(z) > 1.96
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) { n <- nrow(z)
  f <- function(x) c(mean(x), sqrt(mean(x) * (1 - mean(x)) / n))
  data.frame(cell = z$cell[1], full = f(rej(z$z_full))[1], full_mcse = f(rej(z$z_full))[2], naive = mean(rej(z$z_naive)),
             wrong_target = mean(rej(z$z_wrong_target)), decision_flip = mean(z$decision_flip),
             mean_D = mean(z$D), mean_D_wrong = mean(z$D_wrong), var_D = stats::var(z$D),
             share_pred = mean(z$v_pred) / stats::var(z$D), share_obs = mean(z$v_obs) / stats::var(z$D), share_tau = mean(z$tau2) / stats::var(z$D)) }))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
n0 <- summ[summ$v == 0, ]; p3 <- summ[summ$v == 0.3, ]; p15 <- summ[summ$v == 0.15, ]
size_ok <- all(n0$full <= 0.07)
verdict <- if (size_ok && all(p15$full >= 0.8)) "A CALIBRATED RULE EXISTS" else if (size_ok && all(p3$full < 0.5)) "COHERENT BUT UNDERPOWERED" else
  if (!size_ok) "FULL RULE SIZE NOT HELD" else "MIXED POWER"
md <- c("# Decision", "",
  sprintf("**Registered rule: %s.** Size of the fully propagated rule at no violation %.3f to %.3f; naive rule %.3f to %.3f; reduced-network target %.3f to %.3f.",
          verdict, min(n0$full), max(n0$full), min(n0$naive), max(n0$naive), min(n0$wrong_target), max(n0$wrong_target)), "",
  sprintf("Power of the full rule: violation 0.15, %.3f to %.3f; violation 0.3, %.3f to %.3f.", min(p15$full), max(p15$full), min(p3$full), max(p3$full)), "",
  sprintf("E[D] under the null: external target at most %.3f in absolute value; reduced-network target %.3f to %.3f.",
          max(abs(n0$mean_D)), min(n0$mean_D_wrong), max(n0$mean_D_wrong)), "",
  "| violation | tau | spread | withheld | full | naive | reduced-network target | decision flip | E[D] | share of Var(D): prediction, observed, tau-hat |",
  "|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|",
  sprintf("| %.2f | %.1f | %d | %s | %.3f | %.3f | %.3f | %.3f | %.3f | %.2f, %.2f, %.2f |", summ$v, summ$tau, summ$s, ifelse(summ$held == 3, "central", "peripheral"),
          summ$full, summ$naive, summ$wrong_target, summ$decision_flip, summ$mean_D, summ$share_pred, summ$share_obs, summ$share_tau), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
