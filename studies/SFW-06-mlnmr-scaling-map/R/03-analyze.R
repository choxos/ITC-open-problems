## Arithmetic (E1) and geometry (E2) elasticities, controls, switch points; decision.
source("R/00-model.R")
g <- build_grid(); bind <- function(l) { cols <- unique(unlist(lapply(l, names))); do.call(rbind, lapply(l, function(z) { z[setdiff(cols, names(z))] <- NA; z[cols] })) }
raw <- bind(lapply(list.files("results/run", full.names = TRUE), readRDS)); fails <- sum(!is.na(raw$error))
d <- merge(raw[is.na(raw$error), ], g, by = "cell")
e1 <- d[d$exp == "E1", ]; e2 <- d[d$exp == "E2", ]
slope <- function(x, y) { f <- stats::lm(log(y) ~ log(x)); c(b = unname(stats::coef(f)[2]), se = unname(sqrt(diag(stats::vcov(f)))[2])) }
f2 <- function(x) sprintf("%.2f", x); f3 <- function(x) sprintf("%.3f", x)

## E1 per cell.
s1 <- do.call(rbind, lapply(split(e1, e1$cell), function(z) data.frame(cell = z$cell[1], n = nrow(z), t_grad_ms = 1e3 * exp(mean(log(z$t_grad))),
  sd_log = stats::sd(log(z$t_grad)), setup_cpu = mean(z$setup_cpu), n_upars = z$n_upars[1], load = mean(z$load))))
s1 <- merge(g, s1, by = "cell"); write.csv(s1, "results/summary-e1.csv", row.names = FALSE)
sel <- function(z, ...) { a <- list(...); z[Reduce(`&`, Map(function(k, v) z[[k]] == v, names(a), a)), ] }

## Controls. Positive: t_grad linear in rows at the largest configuration. Null: a
## regression-free network (no integration) must not cost more at Q 512 than at 32.
pos <- sel(e1, outcome = "mspline", S = 16L, p = 5L, effects = "fixed", reg = TRUE); pos <- pos[pos$Q >= 128, ]
pos_b <- slope(pos$Q, pos$t_grad); pos_ok <- pos_b[["b"]] >= 0.85
nul <- sel(e1, reg = FALSE); nul_ratio <- exp(mean(log(nul$t_grad[nul$Q == 512])) - mean(log(nul$t_grad[nul$Q == 32])))
nul_ok <- nul_ratio >= 0.8 && nul_ratio <= 1.25

## Product sufficiency: equal rows at (S 4, 4Q) and (S 16, Q).
ps <- do.call(rbind, lapply(split(s1[s1$reg, ], list(s1$outcome[s1$reg], s1$p[s1$reg], s1$effects[s1$reg]), drop = TRUE), function(z)
  do.call(rbind, lapply(c(32, 128), function(q) data.frame(outcome = z$outcome[1], p = z$p[1], effects = z$effects[1], Q16 = q,
    ratio = z$t_grad_ms[z$S == 4 & z$Q == 4 * q] / z$t_grad_ms[z$S == 16 & z$Q == q])))))
ps_ok <- mean(ps$ratio >= 0.8 & ps$ratio <= 1.25)

## Switch point: t_grad = a + c * Q within each configuration; Q* = a / c is the
## integration order at which aggregate integration is half the per-gradient cost.
sw <- do.call(rbind, lapply(split(s1[s1$reg, ], list(s1$outcome[s1$reg], s1$S[s1$reg], s1$p[s1$reg], s1$effects[s1$reg]), drop = TRUE), function(z) {
  cf <- stats::coef(stats::lm(t_grad_ms ~ Q, data = z)); data.frame(outcome = z$outcome[1], S = z$S[1], p = z$p[1], effects = z$effects[1],
    fixed_ms = cf[[1]], ms_per_point = cf[[2]], q_switch = cf[[1]] / cf[[2]]) }))
write.csv(sw, "results/switch-points.csv", row.names = FALSE)

## E2: gradients per effective draw (geometry) and the primary elasticity.
e2$G <- e2$leapfrog_sampling / e2$ess_bulk
s2 <- do.call(rbind, lapply(split(e2, e2$cell), function(z) data.frame(cell = z$cell[1], n = nrow(z), G = exp(mean(log(z$G))), ess_bulk = mean(z$ess_bulk),
  ess_tail = mean(z$ess_tail), rhat = max(z$rhat), div_rate = mean(z$div_rate), treedepth = mean(z$treedepth), cpu = mean(z$cpu),
  cpu_per_ess = exp(mean(log(z$cpu / z$ess_bulk))))))
s2 <- merge(g, s2, by = "cell")
s2$t_grad_ms <- vapply(seq_len(nrow(s2)), function(i) { z <- sel(s1, outcome = s2$outcome[i], S = s2$S[i], p = s2$p[i], effects = s2$effects[i], Q = s2$Q[i], reg = TRUE); z$t_grad_ms }, 0)
s2$cpu_h_per_1000 <- s2$t_grad_ms / 1e3 * s2$G * 1000 / 3600
write.csv(s2, "results/summary-e2.csv", row.names = FALSE)
el <- do.call(rbind, lapply(c("fixed", "random"), function(ef) {
  a <- sel(e1, outcome = "binomial", S = 16L, p = 2L, effects = ef, reg = TRUE); a <- a[a$Q %in% c(32, 128, 512), ]
  b <- sel(e2, outcome = "binomial", effects = ef); eg <- slope(a$Q, a$t_grad); eG <- slope(b$Q, b$G); ec <- slope(b$Q, b$cpu / b$ess_bulk)
  data.frame(effects = ef, e_g = eg[["b"]], e_g_se = eg[["se"]], e_G = eG[["b"]], e_G_se = eG[["se"]], e_C = eg[["b"]] + eG[["b"]],
             e_C_se = sqrt(eg[["se"]]^2 + eG[["se"]]^2), e_C_direct = ec[["b"]]) }))
ms <- sel(e2, outcome = "mspline"); ms_eG <- slope(ms$Q, ms$G)
mq <- sel(e1, outcome = "mspline", S = 4L, p = 2L, effects = "fixed", reg = TRUE); mq <- mq[mq$Q %in% c(32, 128), ]; ms_eg <- slope(mq$Q, mq$t_grad)
verdict <- if (all(el$e_C >= 0.7)) "INTEGRATION ROWS BIND: cost per effective draw rises nearly in proportion to integration points" else
  if (all(el$e_C <= 0.3)) "REFUTING SENTENCE HOLDS: cost per effective draw is insensitive to integration points" else "MIXED: see the table"
falsifier <- any(el$e_G <= -0.2)
md <- c("# Decision", "", sprintf("**Registered primary: %s.**", verdict), "",
  sprintf("Elasticity of CPU per effective draw with respect to Q (binomial, 16 aggregate studies, Q 32 to 512), e_C = e_g + e_G: %s.",
          paste(sprintf("%s effects %s (MCSE %s) = arithmetic %s + geometry %s; measured directly %s", el$effects, f2(el$e_C), f2(el$e_C_se), f2(el$e_g), f2(el$e_G), f2(el$e_C_direct)), collapse = "; ")), "",
  sprintf("Factorization check (|e_C - directly measured elasticity| at most 0.2 in both): %s.", all(abs(el$e_C - el$e_C_direct) <= 0.2)), "",
  sprintf("Falsifier (more points buy mixing, e_G at most -0.2): %s. M-spline, 4 studies, Q 32 to 128: arithmetic %s, geometry %s.", falsifier, f2(ms_eg[["b"]]), f2(ms_eG[["b"]])), "",
  sprintf("Positive control (M-spline, 16 studies, 5 covariates, Q 128 to 512: log-log slope of t_grad at least 0.85): %s (%s, MCSE %s).", pos_ok, f3(pos_b[["b"]]), f3(pos_b[["se"]])), "",
  sprintf("Null control (regression-free network: t_grad ratio Q 512 / Q 32 within 0.8 to 1.25): %s (%s).", nul_ok, f3(nul_ratio)), "",
  sprintf("Product sufficiency (t_grad at S 4 and 4Q over S 16 and Q within 0.8 to 1.25): %s of %d comparisons; range %s to %s.", sprintf("%.0f%%", 100 * ps_ok), nrow(ps), f2(min(ps$ratio)), f2(max(ps$ratio))), "",
  sprintf("Failed tasks: %d. Mean load average during timings: %.0f.", fails, mean(d$load)), "",
  "| outcome | effects | S | Q | ms per gradient | gradients per effective draw | CPU hours per 1000 effective draws | bulk ESS | tail ESS | max R-hat | divergence rate | treedepth |",
  "|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %s | %s | %d | %d | %.3f | %.0f | %.3f | %.0f | %.0f | %.3f | %.4f | %.1f |", s2$outcome, s2$effects, s2$S, s2$Q, s2$t_grad_ms, s2$G, s2$cpu_h_per_1000,
          s2$ess_bulk, s2$ess_tail, s2$rhat, s2$div_rate, s2$treedepth), "",
  "| outcome | S | p | effects | fixed ms per gradient | ms per integration point | switch Q |", "|---|---:|---:|---|---:|---:|---:|",
  sprintf("| %s | %d | %d | %s | %.3f | %.5f | %.0f |", sw$outcome, sw$S, sw$p, sw$effects, sw$fixed_ms, sw$ms_per_point, sw$q_switch), "")
writeLines(md, "results/decision.md"); cat(md[1:15], sep = "\n")
