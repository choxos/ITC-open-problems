## Detection against materiality along the modifier-strength axis; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) { n_all <- nrow(z); z <- z[!is.na(z$est), ]
  e <- z$est - z$truth; n <- nrow(z); cv <- mean(abs(e) <= 1.96 * z$se)
  data.frame(cell = z$cell[1], method = z$method[1], truth = z$truth[1], n = n, failed = n_all - n, bias = mean(e), mcse = stats::sd(e) / sqrt(n),
             emp_sd = stats::sd(z$est), coverage = cv, cov_mcse = sqrt(cv * (1 - cv) / n), rmse = sqrt(mean(e^2)), ess = mean(z$ess)) }))
## Screening statistics are per replicate and identical across methods.
sel <- do.call(rbind, lapply(split(d[d$method == "none", ], d$cell[d$method == "none"]), function(z) { cc <- g[g$cell == z$cell[1], ]; n <- nrow(z)
  tc <- stats::qt(1 - ALPHA / 2, z$df[1]); ncp <- cc$beta / stats::median(z$se_int1)
  pw <- stats::pt(tc, z$df[1], ncp, lower.tail = FALSE) + stats::pt(-tc, z$df[1], ncp)
  fr <- if (cc$beta > 0) mean(z$n_false) / (cc$p - 1) else mean(z$n_false + z$detect) / cc$p
  data.frame(cell = cc$cell, reps = n, detect = mean(z$detect), detect_mcse = sqrt(mean(z$detect) * (1 - mean(z$detect)) / n), power_analytic = pw,
             false_rate = fr, stability = sum((table(z$set) / n)^2)) }))
summ <- merge(merge(g, summ, by = "cell"), sel, by = "cell"); summ <- summ[order(summ$p, summ$delta, summ$beta, summ$method), ]; write.csv(summ, "results/summary.csv", row.names = FALSE)

pick <- function(m) summ[summ$method == m, ]
none <- pick("none"); none <- none[order(none$p, none$delta, none$beta), ]
gap <- do.call(rbind, lapply(split(none, list(none$p, none$delta), drop = TRUE), function(z) { z1 <- z[z$beta > 0, ]
  ip <- function(x, y, at) if (at < min(x) || at > max(x)) NA else stats::approx(x, y, xout = at, ties = mean)$y
  data.frame(p = z$p[1], delta = z$delta[1], beta_material = ip(abs(z$bias), z$beta, MATERIAL), beta_80 = ip(z$detect, z$beta, 0.8),
             gap = paste(z1$beta[abs(z1$bias) >= MATERIAL & z1$detect < 0.8], collapse = ", ")) }))
pg <- gap[gap$p == 6 & gap$delta == 0.5, ]
verdict <- if (nzchar(pg$gap)) "CONFIRMED: omission is material at a strength screening detects in fewer than 80% of replicates" else
  "REFUTED: screening detects in at least 80% of replicates wherever omission is material"
pc <- none[none$p == 6 & none$delta == 0.5, ]
mech <- all(abs(pc$detect - pc$power_analytic) <= 3 * pmax(sqrt(pc$power_analytic * (1 - pc$power_analytic) / pc$reps), 0.005))
fals <- vapply(c(6L, 13L), function(pp) { s <- summ[summ$p == pp & summ$delta == 0.5 & summ$beta > 0, ]; scr <- s[s$method == "maic_screen", ]
  ok <- vapply(c("stc_all", "maic_all"), function(m) { a <- s[s$method == m, ]; a <- a[match(scr$beta, a$beta), ]
    all(abs(a$bias) <= 3 * a$mcse & a$rmse <= scr$rmse) }, TRUE)
  if (any(ok)) paste(names(ok)[ok], collapse = " and ") else "neither" }, "")
nul <- summ[summ$beta == 0, ]; null_ok <- all(abs(nul$bias) <= 3 * nul$mcse) && all(nul$false_rate >= 0.04 & nul$false_rate <= 0.06)
pos <- summ[summ$beta == 0.6 & summ$delta == 0.5, ]
pos_ok <- all(abs(pos$bias[pos$method == "none"]) >= MATERIAL) && all(abs(pos$bias[pos$method == "maic_oracle"]) <= 3 * pos$mcse[pos$method == "maic_oracle"])
f3 <- function(x) sprintf("%.3f", x)
md <- c("# Decision", "", sprintf("**Registered primary: %s.** Six candidates, target shift 0.5 SD: omission bias by strength %s; screening detection %s (analytic power %s).",
          verdict, paste(sprintf("%.2f: %s", pc$beta, f3(pc$bias)), collapse = "; "), paste(f3(pc$detect), collapse = ", "), paste(f3(pc$power_analytic), collapse = ", ")), "",
  sprintf("Mechanism check (empirical detection within 3 MCSE of the analytic power at every strength, primary cells): %s.", mech), "",
  "Detection-materiality gap, two strengths on one axis (linear interpolation on the grid; NA if outside it):", "",
  "| candidates | target shift | strength at material omission | strength at 80% detection | grid strengths in the gap |", "|---:|---:|---:|---:|---|",
  sprintf("| %d | %.1f | %s | %s | %s |", gap$p, gap$delta, f3(gap$beta_material), f3(gap$beta_80), ifelse(nzchar(gap$gap), gap$gap, "none")), "",
  sprintf("Falsifier (an all-candidate method unbiased within 3 MCSE with RMSE no larger than screened MAIC at every strength, shift 0.5): 6 candidates %s; 13 candidates %s.", fals[1], fals[2]), "",
  sprintf("Null control (strength 0: every method unbiased within 3 MCSE; per-candidate false selection 0.04 to 0.06): %s; false selection %s.", null_ok, paste(f3(unique(nul$false_rate)), collapse = ", ")), "",
  sprintf("Positive control (strength 0.6, shift 0.5: omission bias at least %.1f and oracle MAIC unbiased within 3 MCSE): %s.", MATERIAL, pos_ok), "",
  sprintf("Replicates dropped: %d. Method failures (weights not balancing): %s.", sum(N_SIM - unique(summ[, c("cell", "reps")])$reps),
          paste(sprintf("%s %d", names(tapply(summ$failed, summ$method, sum)), tapply(summ$failed, summ$method, sum)), collapse = ", ")), "",
  "| candidates | shift | strength | method | truth | bias | MCSE | coverage | RMSE | ESS | detection | false selection | stability |", "|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %d | %.1f | %.2f | %s | %.3f | %.3f | %.3f | %.3f | %.3f | %s | %.3f | %.3f | %.3f |", summ$p, summ$delta, summ$beta, summ$method, summ$truth, summ$bias, summ$mcse,
          summ$coverage, summ$rmse, ifelse(is.na(summ$ess), "", sprintf("%.0f", summ$ess)), summ$detect, summ$false_rate, summ$stability), "")
writeLines(md, "results/decision.md"); cat(md[1:13], sep = "\n")
