## ---------------------------------------------------------------------------
## MOD-09: a decision map between MAIC, STC and ML-NMR over factors an analyst
## can compute before fitting, and ML-NMR's fitting burden measured on the same
## datasets.
##
## Star network, binary outcome, logit link, 200 per arm in every trial:
##   AB: individual data on A and B;  AC1, AC2: aggregate data on A and C
##   (events per arm; means and SDs of x1, x2).
## Covariates bivariate normal, SD 1; correlation 0 in AB, 0.6 in AC1, AC2 and
## the target. logit p = -0.5 + 0.5 x1 + 0.3 x2 + [B](-0.6 + 0.4 x1 + 0.2 x2)
##                        + [C](-0.4 + gC1 x1 + gC2 x2); study baselines equal.
## Target: an external population, means (0, 0), correlation 0.6, baseline -0.5.
## Estimand: marginal log odds ratio B versus C in the target.
## Factors: transport gap (AC means (0.2, -0.2) or (1.0, 0.6) on both
## covariates), overlap (AB means 0.3 or 1.2), target information (declared
## correlation 0.6, the truth, or 0, borrowed from the IPD), shared effect
## modification (gC = (0.4, 0.2) as for B, or half of it, so MAIC and STC keep
## half the gap while ML-NMR over-corrects by the other half). Plus a null cell with no
## modification and every population equal to the target.
## Methods: MAIC (entropy weights on the target means, sandwich SE) and STC
## (G-computation over the declared target law, delta-method SE), each combined
## with the inverse-variance pooled A vs C log odds ratio of AC1 and AC2; ML-NMR
## (the integrated likelihood with shared modification, maximized; delta-method
## SE; 256 Sobol points per aggregate trial, 1024 for the target, baseline of AB).
## Analytic terms (P1): the transport gap MAIC and STC inherit, the pooled
## A vs C contrast in the AC populations minus that in the target; and section
## 2's aggregation bias, the conditional contrast at the target means minus
## the marginal one.
## Burden: multinma 0.9.1 ML-NMR on the first N_BURDEN replicates of each cell
## under a fixed protocol (2 chains, 2000 iterations, 64 integration points,
## int_check on; one refit at adapt_delta 0.99 if any divergence; B and C in one
## treatment class with common interactions, the shared-modification model).
## multinma 0.9.1 under rstan 2.39.0.9000 fails with one chain (nint_vec is
## declared array[nchains] and a length-1 vector arrives as a scalar), so every
## multinma fit here uses at least 2 chains.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261230L; N_SIM <- 1000L; N_BURDEN <- 10L; N_ARM <- 200L
BETA <- c(0.5, 0.3); DB <- -0.6; GB <- c(0.4, 0.2); DC <- -0.4; MU <- -0.5; RHO_AGD <- 0.6
SOB <- function(n) stats::qnorm(randtoolbox::sobol(n, 2))
P_AGD <- SOB(256); P_TGT <- SOB(1024)
build_grid <- function() {
  g <- expand.grid(gap = c("low", "high"), overlap = c("good", "poor"), info = c("joint", "marginals"), em = c("shared", "violated"), KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g <- rbind(g, data.frame(gap = "none", overlap = "same", info = "joint", em = "none")); g$cell <- seq_len(nrow(g)); g }
pops <- function(cell) list(AB = if (cell$overlap == "poor") 1.2 else if (cell$overlap == "good") 0.3 else 0,
  AC = switch(cell$gap, low = c(0.2, -0.2), high = c(1.0, 0.6), none = c(0, 0)), gc = switch(cell$em, shared = GB, violated = GB / 2, none = c(0, 0)),
  gb = if (cell$em == "none") c(0, 0) else GB)
eta <- function(X, trt, p) MU + drop(X %*% BETA) + (trt == "B") * (DB + drop(X %*% p$gb)) + (trt == "C") * (DC + drop(X %*% p$gc))
law <- function(P, m, rho) { L <- chol(matrix(c(1, rho, rho, 1), 2)); sweep(P %*% L, 2, m, "+") }

## Truth and P1 terms by large-sample Monte Carlo over each population (fixed seed).
truth <- function(cell) { p <- pops(cell); old <- if (exists(".Random.seed", .GlobalEnv)) get(".Random.seed", .GlobalEnv) else NULL; set.seed(9)
  Z <- matrix(stats::rnorm(4e5), ncol = 2); if (!is.null(old)) assign(".Random.seed", old, .GlobalEnv)
  lor <- function(X, t1, t0) stats::qlogis(mean(stats::plogis(eta(X, t1, p)))) - stats::qlogis(mean(stats::plogis(eta(X, t0, p))))
  XT <- law(Z, c(0, 0), RHO_AGD); tr <- lor(XT, "B", "C")
  ac_pops <- mean(vapply(p$AC, function(m) lor(law(Z, c(m, m), RHO_AGD), "C", "A"), 0))
  c(truth = tr, gap_bias = lor(XT, "C", "A") - ac_pops, aggregation_bias = (DB - DC) - tr) }   # target means are 0

draw <- function(cell) { p <- pops(cell)
  xab <- law(matrix(stats::rnorm(4 * N_ARM), ncol = 2), c(p$AB, p$AB), 0); tab <- rep(c("A", "B"), each = N_ARM)
  ipd <- data.frame(x1 = xab[, 1], x2 = xab[, 2], trt = tab, y = stats::rbinom(2 * N_ARM, 1, stats::plogis(eta(xab, tab, p))))
  agd <- do.call(rbind, lapply(1:2, function(j) { X <- law(matrix(stats::rnorm(4 * N_ARM), ncol = 2), rep(p$AC[j], 2), RHO_AGD); tt <- rep(c("A", "C"), each = N_ARM)
    y <- stats::rbinom(2 * N_ARM, 1, stats::plogis(eta(X, tt, p)))
    data.frame(study = paste0("AC", j), trt = c("A", "C"), r = tapply(y, tt, sum)[c("A", "C")], n = N_ARM,
               x1_mean = mean(X[, 1]), x1_sd = stats::sd(X[, 1]), x2_mean = mean(X[, 2]), x2_sd = stats::sd(X[, 2])) }))
  list(ipd = ipd, agd = agd) }
decl_rho <- function(cell) if (cell$info == "joint") RHO_AGD else 0

## A vs C, inverse-variance pooled over AC1 and AC2 (MAIC and STC use it unadjusted).
d_ac <- function(agd) { e <- vapply(1:2, function(j) { z <- agd[agd$study == paste0("AC", j), ]; r <- z$r; n <- z$n
  c(log(r[2] / (n[2] - r[2])) - log(r[1] / (n[1] - r[1])), 1 / r[2] + 1 / (n[2] - r[2]) + 1 / r[1] + 1 / (n[1] - r[1])) }, numeric(2))
  w <- 1 / e[2, ]; c(est = sum(w * e[1, ]) / sum(w), var = 1 / sum(w)) }

maic <- function(d, ac) { X <- as.matrix(d$ipd[, c("x1", "x2")]); a <- stats::optim(c(0, 0), function(a) sum(exp(X %*% a)), function(a) colSums(drop(exp(X %*% a)) * X), method = "BFGS")$par
  w <- drop(exp(X %*% a)); b <- as.numeric(d$ipd$trt == "B"); Z <- cbind(1, b)
  f <- suppressWarnings(stats::glm(d$ipd$y ~ b, family = stats::quasibinomial(), weights = w)); pr <- stats::fitted(f)
  A <- crossprod(Z, w * pr * (1 - pr) * Z); S <- crossprod(Z, w^2 * (d$ipd$y - pr)^2 * Z); V <- solve(A) %*% S %*% solve(A)
  c(est = stats::coef(f)[[2]] - ac[["est"]], se = sqrt(V[2, 2] + ac[["var"]]), ess = sum(w)^2 / sum(w^2)) }

stc <- function(d, ac, XT) { f <- stats::glm(y ~ trt * (x1 + x2), family = stats::binomial(), data = d$ipd); b <- stats::coef(f)
  mk <- function(t) cbind(1, t, XT, t * XT); XA <- mk(0); XB <- mk(1); pA <- stats::plogis(drop(XA %*% b)); pB <- stats::plogis(drop(XB %*% b))
  mA <- mean(pA); mB <- mean(pB); g <- colMeans(pB * (1 - pB) * XB) / (mB * (1 - mB)) - colMeans(pA * (1 - pA) * XA) / (mA * (1 - mA))
  c(est = stats::qlogis(mB) - stats::qlogis(mA) - ac[["est"]], se = sqrt(drop(t(g) %*% stats::vcov(f) %*% g) + ac[["var"]])) }

## ML-NMR likelihood: theta = (mu_AB, mu_AC1, mu_AC2, beta1, beta2, dB, dC, g1, g2), modification shared by B and C.
mlnmr <- function(d, cell, XT) { X <- as.matrix(d$ipd[, c("x1", "x2")]); b <- as.numeric(d$ipd$trt == "B"); y <- d$ipd$y
  pts <- lapply(1:2, function(j) { z <- d$agd[d$agd$study == paste0("AC", j), ][1, ]
    sweep(sweep(law(P_AGD, c(0, 0), decl_rho(cell)), 2, c(z$x1_sd, z$x2_sd), "*"), 2, c(z$x1_mean, z$x2_mean), "+") })
  nll <- function(th) { e <- th[1] + drop(X %*% th[4:5]) + b * (th[6] + drop(X %*% th[8:9]))
    ll <- sum(y * e - log1p(exp(e)))
    for (j in 1:2) { z <- d$agd[d$agd$study == paste0("AC", j), ]; P <- pts[[j]]; base <- th[1 + j] + drop(P %*% th[4:5])
      pa <- mean(stats::plogis(base)); pc <- mean(stats::plogis(base + th[7] + drop(P %*% th[8:9])))
      ll <- ll + stats::dbinom(z$r[1], z$n[1], pa, log = TRUE) + stats::dbinom(z$r[2], z$n[2], pc, log = TRUE) }
    -ll }
  st <- c(rep(stats::qlogis(mean(y[b == 0])), 3), 0, 0, 0, 0, 0, 0)
  o <- stats::optim(st, nll, method = "BFGS", control = list(maxit = 500, reltol = 1e-12)); H <- stats::optimHess(o$par, nll)
  fn <- function(th) { base <- th[1] + drop(XT %*% th[4:5]) + drop(XT %*% th[8:9]); stats::qlogis(mean(stats::plogis(base + th[6]))) - stats::qlogis(mean(stats::plogis(base + th[7]))) }
  gr <- vapply(seq_along(o$par), function(k) { h <- 1e-5; e <- replace(numeric(9), k, h); (fn(o$par + e) - fn(o$par - e)) / (2 * h) }, 0)
  c(est = fn(o$par), se = sqrt(drop(t(gr) %*% solve(H) %*% gr)), converged = as.numeric(o$convergence == 0)) }

one_rep <- function(cell) { d <- draw(cell); ac <- d_ac(d$agd); XT <- law(P_TGT, c(0, 0), decl_rho(cell))
  fit <- function(m, f) tryCatch({ t0 <- proc.time()[["user.self"]]; v <- f(); data.frame(method = m, est = v[["est"]], se = v[["se"]], ess = if ("ess" %in% names(v)) v[["ess"]] else NA_real_,
    converged = if ("converged" %in% names(v)) v[["converged"]] else 1, sec = proc.time()[["user.self"]] - t0, error = NA_character_) },
    error = function(e) data.frame(method = m, est = NA_real_, se = NA_real_, ess = NA_real_, converged = 0, sec = NA_real_, error = conditionMessage(e)))
  rbind(fit("maic", function() maic(d, ac)), fit("stc", function() stc(d, ac, XT)), fit("mlnmr", function() mlnmr(d, cell, XT))) }

## multinma under the declared protocol, for the burden measurement.
burden_rep <- function(cell, seed, chains = 2L, iter = 2000L) {
  suppressPackageStartupMessages(library(multinma)); d <- draw(cell); rho <- decl_rho(cell); C <- matrix(c(1, rho, rho, 1), 2)
  ipd <- data.frame(study = "AB", d$ipd); agd <- d$agd; cls <- function(t) ifelse(t == "A", "control", "active"); ipd$cls <- cls(ipd$trt); agd$cls <- cls(agd$trt); t0 <- proc.time()
  net <- suppressMessages(combine_network(set_ipd(ipd, study, trt, r = y, trt_class = cls), set_agd_arm(agd, study, trt, r = r, n = n, trt_class = cls)))
  net <- add_integration(net, x1 = distr(qnorm, x1_mean, x1_sd), x2 = distr(qnorm, x2_mean, x2_sd), cor = C, n_int = 64)
  warn <- character(0); run <- function(ad) withCallingHandlers(nma(net, regression = ~ (x1 + x2) * .trt, class_interactions = "common", trt_effects = "fixed", link = "logit",
    chains = chains, iter = iter, seed = seed, refresh = 0, control = list(adapt_delta = ad), prior_intercept = normal(0, 10), prior_trt = normal(0, 10), prior_reg = normal(0, 10)),
    warning = function(w) { warn <<- c(warn, conditionMessage(w)); invokeRestart("muffleWarning") })
  f <- run(0.8); ndiv <- function(f) sum(vapply(rstan::get_sampler_params(f$stanfit, inc_warmup = FALSE), function(s) sum(s[, "divergent__"]), 0))
  refit <- ndiv(f) > 0; if (refit) f <- run(0.99)
  tg <- add_integration(data.frame(study = "target", x1_mean = 0, x1_sd = 1, x2_mean = 0, x2_sd = 1), x1 = distr(qnorm, x1_mean, x1_sd), x2 = distr(qnorm, x2_mean, x2_sd), cor = C, n_int = 1024)
  pr <- as.array(predict(f, newdata = tg, baseline = "AB", level = "aggregate", type = "response")); nm <- dimnames(pr)[[3]]
  pB <- as.vector(pr[, , grep(": B\\]", nm)]); pC <- as.vector(pr[, , grep(": C\\]", nm)]); v <- stats::qlogis(pB) - stats::qlogis(pC); el <- proc.time() - t0
  data.frame(est = mean(v), sd = stats::sd(v), cpu = el[["user.self"]] + el[["sys.self"]], divergent = ndiv(f), refit = refit, max_rhat = max(rstan::summary(f$stanfit)$summary[, "Rhat"], na.rm = TRUE),
             int_check_warning = any(grepl("integration", warn, ignore.case = TRUE)), n_warnings = length(warn)) }
