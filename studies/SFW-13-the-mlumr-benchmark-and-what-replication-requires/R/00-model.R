## ---------------------------------------------------------------------------
## SFW-13: mlumr's ML-UMR against an independent g-computation, and its bias
## under an omitted prognostic covariate against the analytic value.
##
## Package under test: mlumr as installed (DESCRIPTION 0.1.0.9000, RemoteSha
## 006b604c741a13e5394679c1ce77b042cac844b6), binary outcome, logit link, shared
## prognostic factor assumption (SPFA), default priors.
## Unanchored: individual data on 300 patients given A; the comparator trial
## publishes B's events of 300 and the mean and SD of x1 and the proportion with
## x2 = 1. u is prognostic, differs between the trials and is never reported.
##   IPD:        x1 ~ N(0, 1),  x2 ~ Bern(0.4), u ~ N(0, 1)
##   comparator: x1 ~ N(M1, 1), x2 ~ Bern(0.5), u ~ N(1, 1)
##   logit P(Y = 1) = ALPHA[trt] + 0.6 x1 + 0.5 x2 + BU u, the same slopes for A
##   and B (SPFA true on the measured covariates).
## Target: the comparator population. Estimands: A's response probability there
## (primary) and the marginal log odds ratio A versus B there.
## Analytic bias (P1): the least-false logistic fit of y on (x1, x2) in the IPD
## population, u integrated out, standardized over the comparator's declared
## (x1, x2) law, minus the truth. B's probability is estimated by its observed
## proportion, so the log odds ratio's bias is A's on the logit scale.
## Methods: mlumr SPFA (2 chains, 2000 iterations, 256 integration points (P2), the
## declared law's correlation fixed at 0, its true value, rather than the IPD's);
## witness, an independent g-computation (glm on the IPD, quadrature over the
## declared comparator law, delta-method SE; no mlumr code); mlumr::stc();
## mlumr::naive().
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(mlumr))
MASTER_SEED <- 20261228L; N_SIM <- 200L; N <- 300L; ALPHA <- c(A = -0.3, B = -0.6); BETA <- c(0.6, 0.5)
P2 <- c(ipd = 0.4, comp = 0.5); DU <- 1; CHAINS <- 2L; ITER <- 2000L; N_INT <- 256L
build_grid <- function() { g <- expand.grid(bu = c(0, 0.25, 0.5), m1 = c(0.3, 1), KEEP.OUT.ATTRS = FALSE); g$cell <- seq_len(nrow(g)); g }

## Quadrature over x1 (normal), x2 (Bernoulli) and u (normal).
Q <- stats::qnorm(stats::ppoints(200))
grid_x <- function(m1, p2) { x1 <- rep(m1 + Q, 2); x2 <- rep(c(0, 1), each = length(Q)); list(x1 = x1, x2 = x2, w = rep(c(1 - p2, p2), each = length(Q)) / length(Q)) }
eu <- function(eta, bu, mu_u) vapply(eta, function(e) mean(stats::plogis(e + bu * (mu_u + Q))), 0)
truth <- function(cell) {
  gc <- grid_x(cell$m1, P2[["comp"]]); lin <- function(a, g) a + BETA[1] * g$x1 + BETA[2] * g$x2
  pA <- sum(gc$w * eu(lin(ALPHA[["A"]], gc), cell$bu, DU)); pB <- sum(gc$w * eu(lin(ALPHA[["B"]], gc), cell$bu, DU))
  gi <- grid_x(0, P2[["ipd"]]); yi <- eu(lin(ALPHA[["A"]], gi), cell$bu, 0)
  lf <- suppressWarnings(stats::glm(yi ~ gi$x1 + gi$x2, family = stats::quasibinomial(), weights = gi$w))   # least-false fit, u omitted
  pA_lim <- sum(gc$w * stats::plogis(drop(cbind(1, gc$x1, gc$x2) %*% stats::coef(lf))))
  c(pA = pA, pB = pB, lor = stats::qlogis(pA) - stats::qlogis(pB), bias_pA = pA_lim - pA, bias_lor = stats::qlogis(pA_lim) - stats::qlogis(pA)) }

draw <- function(cell) {
  ipd <- data.frame(trt = "A", x1 = stats::rnorm(N), x2 = stats::rbinom(N, 1, P2[["ipd"]]), u = stats::rnorm(N))
  ipd$y <- stats::rbinom(N, 1, stats::plogis(ALPHA[["A"]] + BETA[1] * ipd$x1 + BETA[2] * ipd$x2 + cell$bu * ipd$u))
  x1 <- stats::rnorm(N, cell$m1); x2 <- stats::rbinom(N, 1, P2[["comp"]]); u <- stats::rnorm(N, DU)
  yb <- stats::rbinom(N, 1, stats::plogis(ALPHA[["B"]] + BETA[1] * x1 + BETA[2] * x2 + cell$bu * u))
  list(ipd = ipd[, c("trt", "y", "x1", "x2")], agd = data.frame(trt = "B", n = N, r = sum(yb), x1_mean = mean(x1), x1_sd = stats::sd(x1), x2_mean = mean(x2))) }
as_mlumr <- function(d) { dat <- combine_data(set_ipd(d$ipd, treatment = "trt", outcome = "y", covariates = c("x1", "x2")),
    set_agd(d$agd, treatment = "trt", outcome_n = "n", outcome_r = "r", cov_means = c("x1_mean", "x2_mean"), cov_sds = c("x1_sd", NA), cov_types = c("continuous", "binary")))
  suppressMessages(add_integration(dat, n_int = N_INT, cor = diag(2), verbose = FALSE, x1 = distr(qnorm, mean = x1_mean, sd = x1_sd), x2 = distr(qbern, prob = x2_mean))) }

## Independent g-computation over the declared comparator law (normal x1, Bernoulli x2, independent).
witness <- function(d) { f <- stats::glm(y ~ x1 + x2, family = stats::binomial(), data = d$ipd); g <- grid_x(0, d$agd$x2_mean)
  X <- cbind(1, d$agd$x1_mean + d$agd$x1_sd * (g$x1), g$x2); p <- stats::plogis(drop(X %*% stats::coef(f)))
  pA <- sum(g$w * p); gr <- colSums(g$w * p * (1 - p) * X); se_pA <- sqrt(drop(t(gr) %*% stats::vcov(f) %*% gr))
  pB <- d$agd$r / d$agd$n; se_pB <- sqrt(pB * (1 - pB) / d$agd$n)
  c(pA = pA, se_pA = se_pA, lor = stats::qlogis(pA) - stats::qlogis(pB), se_lor = sqrt((se_pA / (pA * (1 - pA)))^2 + (se_pB / (pB * (1 - pB)))^2)) }

row <- function(method, pA, se_pA, lo, hi, lor, se_lor, lor_lo, lor_hi, extra = list())
  data.frame(method = method, pA = pA, se_pA = se_pA, lo = lo, hi = hi, lor = lor, se_lor = se_lor, lor_lo = lor_lo, lor_hi = lor_hi,
             pA_index = if (is.null(extra$pi)) NA_real_ else extra$pi, sd_pA_index = if (is.null(extra$spi)) NA_real_ else extra$spi,
             ybar_ipd = if (is.null(extra$yb)) NA_real_ else extra$yb, max_rhat = if (is.null(extra$rh)) NA_real_ else extra$rh,
             n_divergent = if (is.null(extra$dv)) NA_real_ else extra$dv, sec = if (is.null(extra$sec)) NA_real_ else extra$sec, error = NA_character_)
fail <- function(method, e) { r <- row(method, NA, NA, NA, NA, NA, NA, NA, NA); r$error <- conditionMessage(e); r }

fit_mlumr <- function(dat, seed, chains = CHAINS, iter = ITER) {
  t0 <- proc.time()[["elapsed"]]
  fit <- suppressWarnings(mlumr(dat, model = "spfa", chains = chains, iter = iter, warmup = iter %/% 2, seed = seed, refresh = 0, verbose = FALSE))
  pd <- predict(fit, population = "both", summary = FALSE); col <- function(s) pd[[grep(s, names(pd))[1]]]
  pa <- col("_index_comparator$"); pb <- col("_comparator_comparator$"); pi <- col("_index_index$"); lor <- stats::qlogis(pa) - stats::qlogis(pb)
  q <- function(v, p) unname(stats::quantile(v, p))
  row("mlumr", mean(pa), stats::sd(pa), q(pa, 0.025), q(pa, 0.975), mean(lor), stats::sd(lor), q(lor, 0.025), q(lor, 0.975),
      list(pi = mean(pi), spi = stats::sd(pi), rh = suppressWarnings(max(fit$summary$Rhat, na.rm = TRUE)),
           dv = sum(fit$diagnostics$n_divergent), sec = proc.time()[["elapsed"]] - t0)) }

one_rep <- function(cell, seed, stan = TRUE) {
  d <- draw(cell); dat <- as_mlumr(d); z <- 1.96
  w <- tryCatch({ v <- witness(d); row("witness", v[["pA"]], v[["se_pA"]], v[["pA"]] - z * v[["se_pA"]], v[["pA"]] + z * v[["se_pA"]], v[["lor"]], v[["se_lor"]],
      v[["lor"]] - z * v[["se_lor"]], v[["lor"]] + z * v[["se_lor"]], list(yb = mean(d$ipd$y))) }, error = function(e) fail("witness", e))
  s <- tryCatch({ v <- stc(dat); row("stc", v$p_hat_index, v$p_hat_index_se, v$p_hat_index_lower, v$p_hat_index_upper, v$estimate, v$se, v$ci_lower, v$ci_upper) }, error = function(e) fail("stc", e))
  n <- tryCatch({ v <- naive(dat); row("naive", v$p_index, v$p_index_se, v$p_index_lower, v$p_index_upper, v$estimate, v$se, v$ci_lower, v$ci_upper) }, error = function(e) fail("naive", e))
  m <- if (stan) tryCatch({ r <- fit_mlumr(dat, seed); r$ybar_ipd <- mean(d$ipd$y); r }, error = function(e) fail("mlumr", e)) else NULL
  rbind(w, s, n, m) }
