## PIT uniformity per cell and test quantity, controls, construction gap; decision.
source("R/00-model.R")
g <- build_grid(); raw <- do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS))
fails <- tapply(!is.na(raw$error), raw$cell, function(x) length(unique(raw$rep[x])))
d <- merge(raw[is.na(raw$error), ], g, by = "cell")

## Departure of a PIT sample from U(0, 1), on z = qnorm(u) ~ N(0, 1) under the null:
## location (z test of the mean), dispersion (two-sided chi-square on the variance)
## and shape (Kolmogorov-Smirnov on u); Bonferroni over the three.
dep <- function(u) { u <- pmin(pmax(u, 1e-5), 1 - 1e-5); z <- stats::qnorm(u); n <- length(u); v <- (n - 1) * stats::var(z)
  p_mean <- 2 * stats::pnorm(-abs(mean(z)) * sqrt(n)); p_var <- 2 * min(stats::pchisq(v, n - 1), stats::pchisq(v, n - 1, lower.tail = FALSE))
  p_ks <- stats::ks.test(u, "punif")$p.value
  c(n = n, mean_z = mean(z), mean_z_mcse = 1 / sqrt(n), sd_z = stats::sd(z), sd_z_mcse = stats::sd(z) / sqrt(2 * (n - 1)),
    p_mean = p_mean, p_ks = p_ks, p_var = p_var, p_dep = min(1, 3 * min(p_mean, p_var, p_ks))) }
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$quantity), drop = TRUE), function(z)
  data.frame(cell = z$cell[1], quantity = z$quantity[1], t(dep(z$u)), k_gt_07 = mean(z$k_hat > 0.7))))
summ <- merge(g, summ, by = "cell"); write.csv(summ, "results/summary.csv", row.names = FALSE)

P <- function(cell, q) summ$p_dep[summ$cell == cell & summ$quantity == q]
departs <- function(cell) P(cell, "contrast") < 0.005 || P(cell, "loglik") < 0.005
nul <- g$cell[g$cons == "coded" & g$impl == "correct" & g$sampler == "is"]
null_ok <- all(vapply(nul, function(i) min(summ$p_dep[summ$cell == i]) >= 0.001, TRUE))
pri <- g$cell[g$impl == "prior"]; sgn <- g$cell[g$impl == "sign"]; nuts <- g$cell[g$sampler == "nuts"]
params <- LAB
modrak <- P(pri, "loglik") < 0.005 && all(vapply(c(params, "contrast"), function(q) P(pri, q) >= 0.005, TRUE))
sign_ok <- min(summ$p_dep[summ$cell == sgn]) < 0.005
e2e <- g[g$cons == "e2e", ]; e2e$departs <- vapply(e2e$cell, departs, TRUE)
at64 <- e2e$departs[e2e$Q == 64]; hiQ <- e2e$departs[e2e$Q >= 64]
verdict <- if (!null_ok) "STOP: the coded-likelihood null fails, so the harness or the implementation is wrong and no integration conclusion is drawn" else
  if (any(at64)) "CONSEQUENTIAL: end-to-end replicates depart from uniformity at the production integration order while coded replicates do not" else
  if (!any(hiQ)) "IMMATERIAL AT THESE SETTINGS: no end-to-end cell at Q 64 or 512 departs" else "MIXED: see the table"
nrm <- e2e[e2e$margin == "normal", ]; skw <- e2e[e2e$margin == "skewed", ]
falsifier <- any(nrm$departs[nrm$Q == 512])
f3 <- function(x) sprintf("%.3f", x); fp <- function(x) sprintf("%.2g", x)
md <- c("# Decision", "", sprintf("**Registered primary: %s.**", verdict), "",
  sprintf("End-to-end cells departing (p < 0.005 on the contrast or the joint log-likelihood): %s of %d; at Q 64: %s.", sum(e2e$departs), nrow(e2e),
          paste(sprintf("cell %d (%s, %s) %s", e2e$cell[e2e$Q == 64], e2e$margin[e2e$Q == 64], e2e$ident[e2e$Q == 64], ifelse(at64, "departs", "uniform")), collapse = "; ")), "",
  sprintf("Mechanism: normal margins depart at Q 16, 64, 512: %s; skewed margins: %s.",
          paste(vapply(c(16, 64, 512), function(q) paste(nrm$departs[nrm$Q == q], collapse = "/"), ""), collapse = ", "),
          paste(vapply(c(16, 64, 512), function(q) paste(skw$departs[skw$Q == q], collapse = "/"), ""), collapse = ", ")), "",
  sprintf("Falsifier (normal margins at Q 512 depart, so the gap is not integration error): %s.", falsifier), "",
  sprintf("Null control (coded construction, correct implementation, cells %s: every quantity p >= 0.001): %s. NUTS null (cell %d): contrast p %s, log-likelihood p %s.",
          paste(nul, collapse = ", "), null_ok, nuts, fp(P(nuts, "contrast")), fp(P(nuts, "loglik"))), "",
  sprintf("Positive control, prior returned as posterior (cell %d): joint log-likelihood departs and no parameter or contrast does: %s (log-likelihood p %s, smallest other p %s).",
          pri, modrak, fp(P(pri, "loglik")), fp(min(summ$p_dep[summ$cell == pri & summ$quantity != "loglik"]))), "",
  sprintf("Positive control, sign error (cell %d): some quantity departs: %s (smallest p %s).", sgn, sign_ok, fp(min(summ$p_dep[summ$cell == sgn]))), "",
  sprintf("Replicates failed per cell: %s. Share of replicates with Pareto k above 0.7 per cell: %s.", paste(sprintf("%s: %d", names(fails), fails), collapse = ", "),
          paste(sprintf("%d: %.3f", unique(summ$cell), tapply(summ$k_gt_07, summ$cell, max)), collapse = ", ")), "",
  "| cell | construction | Q | margin | identification | implementation | sampler | quantity | mean of z | SD of z | mean p | variance p | KS p |",
  "|---:|---|---:|---|---|---|---|---|---:|---:|---:|---:|---:|",
  with(summ[summ$quantity %in% c("contrast", "loglik", "d[B]", "beta[.trtB:x1]"), ],
       sprintf("| %d | %s | %d | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |", cell, cons, Q, margin, ident, impl, sampler, quantity, f3(mean_z), f3(sd_z), fp(p_mean), fp(p_var), fp(p_ks))), "")
writeLines(md, "results/decision.md"); cat(md[1:17], sep = "\n")
