## P2 timing repeatability, smoke run of E1 corners and the null control, one small
## E2 fit, unit costs and total. Writes results/probes.md.   nice -n 19 Rscript R/01-probes.R
source("R/00-model.R"); g <- build_grid(); out <- c("# Probes", "")
ld <- function() as.numeric(strsplit(system("sysctl -n vm.loadavg", intern = TRUE), " ")[[1]][2])
cpu <- function(expr) { t0 <- proc.time()[["user.self"]]; v <- force(expr); list(v = v, s = proc.time()[["user.self"]] - t0) }
pick <- function(...) { a <- list(...); i <- which(Reduce(`&`, Map(function(k, v) g[[k]] == v, names(a), a))); g[i[1], ] }

## E1 corners and the null control (regression-free network, Q 32 and 512).
set.seed(1)
corners <- list(pick(exp = "E1", Q = 32, S = 4L, p = 2L, outcome = "binomial", effects = "fixed"),
                pick(exp = "E1", Q = 512, S = 16L, p = 5L, outcome = "binomial", effects = "fixed"),
                pick(exp = "E1", Q = 32, S = 4L, p = 2L, outcome = "mspline", effects = "fixed"),
                pick(exp = "E1", Q = 512, S = 16L, p = 5L, outcome = "mspline", effects = "fixed"),
                pick(exp = "E1", Q = 32, reg = FALSE), pick(exp = "E1", Q = 512, reg = FALSE),
                pick(exp = "E1", Q = 32, S = 16L, p = 2L, outcome = "binomial", effects = "fixed"))
e1 <- lapply(corners, function(cc) cpu(one_rep(cc)))
tab <- do.call(rbind, Map(function(cc, z) data.frame(cell = cc$cell, outcome = cc$outcome, S = cc$S, Q = cc$Q, p = cc$p, reg = cc$reg,
  t_grad_ms = 1e3 * z$v$t_grad, setup_cpu = z$v$setup_cpu, total_cpu = z$s, upars = z$v$n_upars), corners, e1))
out <- c(out, "## E1 corners and null control (one timing each)", "", "| cell | outcome | S | Q | p | regression | ms per gradient | setup CPU s | replicate CPU s | parameters |",
  "|---:|---|---:|---:|---:|---|---:|---:|---:|---:|",
  sprintf("| %d | %s | %d | %d | %d | %s | %.3f | %.1f | %.1f | %d |", tab$cell, tab$outcome, tab$S, tab$Q, tab$p, tab$reg, tab$t_grad_ms, tab$setup_cpu, tab$total_cpu, tab$upars), "",
  sprintf("- null control, regression-free network: t_grad at Q 512 over Q 32 = %.2f (registered: 0.8 to 1.25)", tab$t_grad_ms[6] / tab$t_grad_ms[5]),
  sprintf("- positive-control preview, M-spline S 16 p 5: rows ratio 512/32 = 16 against the S 4 p 2 corner; t_grad ratio %.1f", tab$t_grad_ms[4] / tab$t_grad_ms[3]), "")

## P2: timing repeatability at a mid-grid configuration (5 timings on one stanfit and
## 3 on fresh networks), which sets the E1 repeat count.
mid <- pick(exp = "E1", Q = 128, S = 16L, p = 2L, outcome = "binomial", effects = "fixed")
sf <- fit(make_net(mid), mid, chains = 2, iter = 1, warmup = 0, algorithm = "Fixed_param")$stanfit
same <- replicate(5, t_grad(sf)); fresh <- replicate(3, one_rep(mid)$t_grad)
cv <- stats::sd(log(c(same, fresh)))
out <- c(out, "## P2 timing repeatability (binomial, S 16, Q 128, p 2)", "",
  sprintf("- ms per gradient, same stanfit: %s; fresh networks: %s", paste(sprintf("%.4f", 1e3 * same), collapse = ", "), paste(sprintf("%.4f", 1e3 * fresh), collapse = ", ")),
  sprintf("- SD of log t_grad %.3f; with %d repeats per cell the MCSE of a log-log slope over Q 32 to 512 (4 doublings, 5 levels) is %.3f",
          cv, N_REP_E1, cv / sqrt(N_REP_E1 * sum((log(c(32, 64, 128, 256, 512)) - mean(log(c(32, 64, 128, 256, 512))))^2))), "")

## E2: one small NUTS fit end to end (binomial, S 16, Q 32, fixed).
set.seed(2); e2c <- pick(exp = "E2", Q = 32, outcome = "binomial", effects = "fixed"); e2 <- cpu(one_rep(e2c))
out <- c(out, "## E2 smoke fit (binomial, S 16, Q 32, fixed effects, 2 x 1000)", "",
  sprintf("- CPU %.1f s; leapfrog %d (sampling %d); bulk ESS %.0f, tail ESS %.0f; R-hat %.3f; divergence rate %.4f; mean treedepth %.1f; gradients per effective draw %.0f",
          e2$v$cpu, e2$v$leapfrog_all, e2$v$leapfrog_sampling, e2$v$ess_bulk, e2$v$ess_tail, e2$v$rhat, e2$v$div_rate, e2$v$treedepth, e2$v$leapfrog_sampling / e2$v$ess_bulk),
  sprintf("- in-sampler CPU per gradient %.4f ms against E1's %.4f ms at the same configuration (cell %d)", 1e3 * e2$v$cpu / e2$v$leapfrog_all, tab$t_grad_ms[7], tab$cell[7]), "")

## Budget. E1: setup scales with rows; interpolate log CPU per replicate on log rows
## between the measured corners of each outcome. E2: binomial from the smoke fit,
## scaled by t_grad ratio; M-spline extrapolated from its E1 t_grad and the smoke
## fit's leapfrog count (labeled).
rows <- function(cc) 2 * cc$S * cc$Q * ifelse(cc$outcome == "mspline", N_AGD, 1)
e1g <- g[g$exp == "E1", ]
est1 <- vapply(seq_len(nrow(e1g)), function(i) { cc <- e1g[i, ]; k <- if (cc$outcome == "mspline") 3:4 else 1:2
  r <- c(rows(corners[[k[1]]]), rows(corners[[k[2]]])); y <- log(tab$total_cpu[k]); exp(stats::approx(log(r), y, log(rows(cc)), rule = 2)$y) }, 0)
e2g <- g[g$exp == "E2", ]; lf <- e2$v$leapfrog_all
est2 <- vapply(seq_len(nrow(e2g)), function(i) { cc <- e2g[i, ]
  k <- if (cc$outcome == "mspline") 3:4 else c(1, 7, 2); r <- vapply(corners[k], rows, 0)
  tg <- exp(stats::approx(log(r), log(tab$t_grad_ms[k] / 1e3), log(rows(cc)), rule = 2, ties = mean)$y)
  lf * (if (cc$effects == "random") 2 else 1) * tg }, 0)
out <- c(out, "## Budget", "",
  sprintf("- E1: %d cells x %d repeats, about %.1f CPU hours (interpolated from the measured corners)", nrow(e1g), N_REP_E1, N_REP_E1 * sum(est1) / 3600),
  sprintf("- E2: %d cells x %d repeats, about %.1f CPU hours (extrapolated: t_grad interpolated on rows between measured E1 corners, times the smoke fit's leapfrog count, doubled for random effects)",
          nrow(e2g), N_REP_E2, N_REP_E2 * sum(est2) / 3600),
  sprintf("- per E2 cell, CPU hours per replicate: %s", paste(sprintf("%s/%s/Q%d %.2f", e2g$outcome, e2g$effects, e2g$Q, est2 / 3600), collapse = "; ")),
  sprintf("- load average during probes: %.0f; all CPU is user time of one process, an upper bound on a quiet machine", ld()), "")
writeLines(out, "results/probes.md"); cat(out, sep = "\n")
