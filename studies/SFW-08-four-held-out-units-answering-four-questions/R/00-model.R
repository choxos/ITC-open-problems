## ---------------------------------------------------------------------------
## SFW-08: which held-out unit a leave-one-out elpd answers in a mixed IPD and
## aggregate likelihood, and when PSIS-LOO approximates it.
##
## ML-NMR with an identity link and known variances, so the posterior is exactly
## Gaussian and every leave-unit-out refit is closed form (Gaussian conditioning).
## Six two-arm studies over A, B, C: S1 A-B, S2 A-B, S3 A-C, S4 A-C, S5 B-C,
## S6 A-B. 100 per arm; S6 400 per arm and covariate mean 2 in the leverage
## cells. x ~ N(m_j, 1), m = (-0.5, -0.2, 0.1, 0.4, 0.6, 0).
##   y = mu_j + BETA x + d_k - d_b + GAMMA x ([k != A] - [b != A]) + delta_j [k != b] + e,
##   e ~ N(0, 1), mu_j ~ N(0, 0.5^2), delta_j ~ N(0, TAU^2), d = (0, -0.5, -0.3).
## IPD studies (1, 3 or 6 of 6) contribute patients; the others contribute arm
## means with variance 1 / n and the arm's covariate mean (exact under the
## identity link). Priors N(0, 10^2); TAU and the residual SD are known.
## Models: M1 (true, with GAMMA) and M0 (without).
## Held-out units (P1):
##   pointwise  every IPD patient and every aggregate arm, the unit multinma's
##              loo() sums over;
##   arm        every arm held out, its mean predicted;
##   study      each study's non-baseline arm held out and its mean predicted
##              given the rest, its own baseline arm included: a new study's
##              contrast, which does not depend on the prior for its baseline
##              mu_j. Predicting the arm mean, not the joint density of its
##              patients, keeps one scalar per study whatever the data type.
##   treatment  not defined: dropping every arm of B or C leaves d_B or d_C with
##              its prior only (rank test in probes), so it has no predictive
##              estimand without exchangeable treatment effects.
## Estimand: the exact leave-unit-out elpd of each model at each unit, by
## conditioning. Approximation: PSIS-LOO on S exact posterior draws, r_eff = 1
## (independent draws, no MCMC): importance ratios from the held-out group's
## full likelihood, the arm mean's density averaged under them (loo::E_loo).
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261232L; N_SIM <- 400L; S_DRAWS <- 2000L; N_ARM <- 100L
BETA <- 0.5; GAMMA <- 0.4; D <- c(A = 0, B = -0.5, C = -0.3); M_STUDY <- c(-0.5, -0.2, 0.1, 0.4, 0.6, 0)
STUDIES <- data.frame(b = c("A", "A", "A", "A", "B", "A"), k = c("B", "B", "C", "C", "C", "B"), stringsAsFactors = FALSE)
IPD_SETS <- list(`1` = 1L, `3` = c(1L, 3L, 5L), `6` = 1:6)
build_grid <- function() { g <- expand.grid(ipd = c(1L, 3L, 6L), tau = c(0, 0.3), leverage = c("none", "one"), KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$cell <- seq_len(nrow(g)); g }
truth <- function(cell) c(correct_model = 1)   # the elpd truths are exact per replicate (exact_point, exact_mean)

draw <- function(cell) { mu <- stats::rnorm(6, 0, 0.5); dl <- stats::rnorm(6, 0, cell$tau); ipd <- IPD_SETS[[as.character(cell$ipd)]]
  do.call(rbind, lapply(1:6, function(j) { n <- if (j == 6 && cell$leverage == "one") 4L * N_ARM else N_ARM; m <- if (j == 6 && cell$leverage == "one") 2 else M_STUDY[j]
    do.call(rbind, lapply(c(STUDIES$b[j], STUDIES$k[j]), function(t) { x <- stats::rnorm(n, m); trt <- t != STUDIES$b[j]
      y <- mu[j] + BETA * x + D[[t]] - D[[STUDIES$b[j]]] + GAMMA * x * ((t != "A") - (STUDIES$b[j] != "A")) + dl[j] * trt + stats::rnorm(n)
      if (j %in% ipd) data.frame(study = j, trt = t, is_trt = trt, x = x, y = y, v = 1) else data.frame(study = j, trt = t, is_trt = trt, x = mean(x), y = mean(y), v = 1 / n) })) })) }

design <- function(d, model, tau) { Z <- cbind(outer(d$study, 1:6, "==") * 1, d$x,
    (d$trt == "B") - (STUDIES$b[d$study] == "B"), (d$trt == "C") - (STUDIES$b[d$study] == "C"))
  if (model == "M1") Z <- cbind(Z, d$x * ((d$trt != "A") - (STUDIES$b[d$study] != "A")))
  if (tau > 0) Z <- cbind(Z, outer(d$study, 1:6, "==") * d$is_trt)
  prior <- c(rep(1 / 100, ncol(Z) - if (tau > 0) 6 else 0), if (tau > 0) rep(1 / tau^2, 6))
  list(Z = Z, P0 = diag(prior, ncol(Z))) }
posterior <- function(Z, P0, y, v) { P <- P0 + crossprod(Z, Z / v); b <- crossprod(Z, y / v); list(P = P, b = b, m = drop(solve(P, b))) }

## Exact leave-group-out log predictive density (Gaussian conditioning).
exact_group <- function(ps, Z, y, v, G) { Zg <- Z[G, , drop = FALSE]; Pg <- ps$P - crossprod(Zg, Zg / v[G]); bg <- ps$b - crossprod(Zg, y[G] / v[G])
  S <- solve(Pg); mg <- drop(S %*% bg); C <- diag(v[G], length(G)) + Zg %*% S %*% t(Zg); r <- y[G] - drop(Zg %*% mg); L <- chol(C)
  -0.5 * (length(G) * log(2 * pi) + 2 * sum(log(diag(L))) + sum(backsolve(L, r, transpose = TRUE)^2)) }
## Exact leave-group-out log predictive density of the group's mean.
exact_mean <- function(ps, Z, y, v, G) { Zg <- Z[G, , drop = FALSE]; Pg <- ps$P - crossprod(Zg, Zg / v[G]); bg <- ps$b - crossprod(Zg, y[G] / v[G])
  S <- solve(Pg); zb <- colMeans(Zg); vb <- sum(v[G]) / length(G)^2
  stats::dnorm(mean(y[G]), sum(zb * drop(S %*% bg)), sqrt(vb + drop(t(zb) %*% S %*% zb)), log = TRUE) }
exact_point <- function(ps, Z, y, v) { h <- rowSums((Z %*% solve(ps$P)) * Z) / v; r <- (y - drop(Z %*% ps$m)) / (1 - h)
  stats::dnorm(r, 0, sqrt(v / (1 - h)), log = TRUE) }

units <- function(d) list(pointwise = as.list(seq_len(nrow(d))), arm = split(seq_len(nrow(d)), paste(d$study, d$trt)),
  study = split(which(d$is_trt), d$study[d$is_trt]))

fit_units <- function(d, model, tau) { ds <- design(d, model, tau); ps <- posterior(ds$Z, ds$P0, d$y, d$v); U <- units(d)
  th <- sweep(matrix(stats::rnorm(S_DRAWS * length(ps$m)), S_DRAWS) %*% chol(solve(ps$P)), 2, ps$m, "+")
  ll <- stats::dnorm(matrix(d$y, S_DRAWS, nrow(d), byrow = TRUE), th %*% t(ds$Z), matrix(sqrt(d$v), S_DRAWS, nrow(d), byrow = TRUE), log = TRUE)
  do.call(rbind, lapply(names(U), function(u) { G <- U[[u]]
    if (u == "pointwise") { ex <- exact_point(ps, ds$Z, d$y, d$v); lo <- suppressWarnings(loo::loo(ll, r_eff = rep(1, ncol(ll)))); ep <- lo$pointwise[, "elpd_loo"]; k <- lo$diagnostics$pareto_k
    } else { ex <- vapply(G, function(g) exact_mean(ps, ds$Z, d$y, d$v, g), 0)
      lg <- vapply(G, function(g) rowSums(ll[, g, drop = FALSE]), numeric(S_DRAWS))
      lb <- vapply(G, function(g) stats::dnorm(mean(d$y[g]), drop(th %*% colMeans(ds$Z[g, , drop = FALSE])), sqrt(sum(d$v[g])) / length(g), log = TRUE), numeric(S_DRAWS))
      w <- suppressWarnings(loo::psis(-lg, r_eff = rep(1, ncol(lg)))); k <- w$diagnostics$pareto_k
      ep <- log(suppressWarnings(loo::E_loo(exp(lb), w, type = "mean", log_ratios = -lg))$value) }
    bad <- k > 0.7
    data.frame(model = model, unit = u, n_terms = length(G), elpd_exact = sum(ex), elpd_psis = sum(ep), k_max = max(k), n_bad = sum(bad),
               abs_err_bad = sum(abs(ep - ex)[bad]), abs_err_good = sum(abs(ep - ex)[!bad]), error = NA_character_) })) }

one_rep <- function(cell) { d <- draw(cell)
  do.call(rbind, lapply(c("M1", "M0"), function(m) tryCatch(fit_units(d, m, cell$tau), error = function(e)
    data.frame(model = m, unit = c("pointwise", "arm", "study"), n_terms = NA, elpd_exact = NA_real_, elpd_psis = NA_real_, k_max = NA_real_, n_bad = NA,
               abs_err_bad = NA_real_, abs_err_good = NA_real_, error = conditionMessage(e))))) }
