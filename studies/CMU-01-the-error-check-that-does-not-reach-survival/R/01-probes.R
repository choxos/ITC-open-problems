## P1 ladder end to end (Weibull, S 4) with optimizer convergence and reference
## stability; P2 the firing threshold of the check; P3 the integration-free null;
## P4 the M-spline S 12 unit cost; P5 the real check runs (short chains).
## Writes results/probes.md.   nice -n 19 Rscript R/01-probes.R
source("R/00-model.R"); g <- build_grid(); out <- c("# Probes", "")
cpu <- function(expr) { t0 <- proc.time()[["user.self"]]; v <- force(expr); list(v = v, s = proc.time()[["user.self"]] - t0) }
row <- function(r) sprintf("| %d | %.3f | %.3f | %s | %s | %s | %.3g | %d | %d |", r$Q, r$contrast, r$r, ifelse(is.na(r$r_prefix), "", sprintf("%.3f", r$r_prefix)),
  ifelse(is.na(r$shift_q), "", sprintf("%.3f", r$shift_q)), ifelse(is.na(r$shift_lp), "", sprintf("%.3f", r$shift_lp)), r$arm_err_max, r$conv, r$evals)
hdr <- c("| Q | contrast | r(Q) | prefix r | largest saved shift | lp__ shift | largest arm log-lik error | convergence | evaluations |", "|---:|---:|---:|---:|---:|---:|---:|---:|---:|")

set.seed(1); p1 <- cpu(one_rep(g[g$lik == "weibull" & g$S == 4 & g$kind == "main", ]))
out <- c(out, "## P1 ladder, Weibull, S 4 (one dataset)", "", hdr, row(p1$v), "",
  sprintf("- CPU %.0f s; reference stability |r(512)| = %.3f SD (registered: at most 0.05); SD of the contrast %.3f; %d unconstrained parameters",
          p1$s, abs(p1$v$r[p1$v$Q == 512]), p1$v$sd_c[1], p1$v$n_upars[1]), "")

set.seed(3); p3 <- cpu(one_rep(g[g$kind == "null", ]))
out <- c(out, "## P3 integration-free null (aggregate covariate SDs published as zero)", "", hdr, row(p3$v), "",
  sprintf("- largest |r(Q)| %.1e and largest saved shift %.1e (exact value 0; the residual is optimizer tolerance)", max(abs(p3$v$r)), max(p3$v$shift_q, na.rm = TRUE)), "")

p2 <- cpu(dstar(n_set = 100))
out <- c(out, "## P2 firing threshold of the split-chain check (100 sets of ideal chains per shift)", "",
  sprintf("- P(fire) at shift %s: %s", paste(p2$v$grid, collapse = ", "), paste(sprintf("%.2f", p2$v$p_fire), collapse = ", ")),
  sprintf("- DSTAR = %.3f posterior SD; the analysis recomputes it with 400 sets (CPU here %.0f s)", p2$v$dstar, p2$s), "")

set.seed(4); p4 <- cpu(one_rep(g[g$lik == "mspline" & g$S == 12 & g$kind == "main", ]))
out <- c(out, "## P4 ladder, M-spline, S 12 (one dataset; the primary cell)", "", hdr, row(p4$v), "",
  sprintf("- CPU %.0f s; %d unconstrained parameters; reference stability |r(512)| = %.3f SD", p4$s, p4$v$n_upars[1], abs(p4$v$r[p4$v$Q == 512])), "")

set.seed(5); cv <- g[g$kind == "validate", ]; net <- make_data(cv)
p5 <- cpu(real_check(net, cv, 8, iter = 300))
out <- c(out, "## P5 real int_check fit (Weibull, S 4, Q 8, 4 chains x 300 iterations)", "",
  sprintf("- runs end to end; fired: %s; CPU %.0f s, so a default 4 x 2000 fit costs about %.0f s", p5$v, p5$s, p5$s * 2000 / 300), "")

## Budget. Main cells: Weibull S 4 from P1, M-spline S 12 from P4, the other two
## interpolated as their geometric mean (labeled); validation: two default real fits
## (Q 8 and 16, the latter at twice the Q 8 cost) plus a short ladder per dataset.
main <- c(p1$s, sqrt(p1$s * p4$s), sqrt(p1$s * p4$s), p4$s)
val <- p5$s * 2000 / 300 * 3 + p1$s / 2
tot <- (N_SIM * sum(main) + N_SIM * p3$s + N_VAL * val) / 3600
out <- c(out, "## Budget", "",
  sprintf("- per dataset CPU s: Weibull S 4 %.0f, M-spline S 4 and Weibull S 12 about %.0f (interpolated), M-spline S 12 %.0f, null %.0f, validation about %.0f",
          p1$s, main[2], p4$s, p3$s, val),
  sprintf("- total: %d datasets in each of 5 ladder cells and %d validation datasets, about %.1f CPU hours (user time under load average %s; an upper bound)",
          N_SIM, N_VAL, tot, strsplit(system("sysctl -n vm.loadavg", intern = TRUE), " ")[[1]][2]),
  sprintf("- peak R heap of this probe process: %.1f GB (Stan autodiff memory is outside it)", sum(gc()[, 7]) / 1024), "")
writeLines(out, "results/probes.md"); cat(out, sep = "\n")
