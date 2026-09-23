## ---------------------------------------------------------------------------
## MOD-15: the half-standard-error rule for pooling within-trial and across-trial
## interaction information.
##
## beta_W-hat ~ N(beta_W, sW^2) from within-trial interactions; beta_A-hat ~
## N(beta_W + delta, sA^2) from the meta-regression of trial effects on trial
## covariate means; delta is ecological bias. They are independent (within-trial
## deviations and trial means are orthogonal). The rule pools when
##   |D| < 0.5 sA,  D = beta_W-hat - beta_A-hat ~ N(-delta, sW^2 + sA^2).
## Under delta = 0 the pass probability is P(|Z| < 0.5 sA / sqrt(sW^2 + sA^2)),
## at most P(|Z| < 0.5) = 0.383: the rule refuses valid pooling at least 61.7% of
## the time in every regime. DESIGN.md called it "not necessarily strict".
##
## Everything conditional on passing is a bivariate normal integral, computed here
## exactly; the simulation's role is to supply realistic sW and sA from
## individual-level networks and to check them (R/01-check.R).
## ---------------------------------------------------------------------------

LEVELS <- list(K = c(5L, 10L, 20L), disp = c(0.25, 0.75), n = c(200L), delta = c(0, 0.1, 0.2, 0.4))
TARGET_SHIFT <- 1        # target covariate mean minus the reference, for transport
SIGMA <- 1               # residual SD; covariate SD within trial 1

build_grid <- function() {
  g <- expand.grid(K = LEVELS$K, disp = LEVELS$disp, n = LEVELS$n, delta = LEVELS$delta,
                   KEEP.OUT.ATTRS = FALSE)
  g$cell <- seq_len(nrow(g)); g
}

## Standard errors for a network of K trials of n (1:1) with trial covariate means
## spread with SD `disp`. Within: interaction from pooled within-trial deviations,
## var = 4 sigma^2 / (N var_x). Across: slope of trial effects (var 4 sigma^2 / n
## each) on trial means, var = (4 sigma^2 / n) / sum (xbar_k - mean)^2, with the
## trial means at their expected spread.
ses <- function(K, disp, n) {
  sW <- sqrt(4 * SIGMA^2 / (K * n * 1))
  ssx <- (K - 1) * disp^2
  sA <- sqrt((4 * SIGMA^2 / n) / ssx)
  sd_d <- sqrt(4 * SIGMA^2 / (K * n))   # pooled treatment effect at the reference
  c(sW = sW, sA = sA, sd_d = sd_d)
}

## Operating characteristics of a pooling rule, exactly. `crit(sW, sA)` is the
## pass threshold on |D|. Returns pass probability, and for the estimate used
## (pooled if pass, within if fail): bias, RMSE and coverage of the interaction and
## of the transported effect theta = d + beta TARGET_SHIFT.
oc <- function(sW, sA, sd_d, delta, crit, policy = "rule") {
  a <- (1 / sW^2) / (1 / sW^2 + 1 / sA^2); sP <- 1 / sqrt(1 / sW^2 + 1 / sA^2)
  sD <- sqrt(sW^2 + sA^2)
  ## beta_W-hat - beta = e_W, beta_A-hat - beta = delta + e_A. Given D, e_W is normal:
  ## E[e_W | D] = sW^2 / sD^2 * (D + delta), Var = sW^2 sA^2 / sD^2.
  cv <- sW^2 * sA^2 / sD^2
  z <- stats::qnorm(0.975)
  pooled_err <- function(D) {         # mean and SD of pooled error given D
    mW <- sW^2 / sD^2 * (D + delta)
    m <- mW - (1 - a) * D              # beta_P = beta_W-hat - (1 - a) D
    c(m = m, s = sqrt(cv))
  }
  within_err <- function(D) c(m = sW^2 / sD^2 * (D + delta), s = sqrt(cv))
  dens <- function(D) stats::dnorm(D, -delta, sD)
  c0 <- if (policy == "always_pool") Inf else if (policy == "never_pool") 0 else crit(sW, sA)
  integ <- function(f, lo, hi) if (hi <= lo) 0 else stats::integrate(f, lo, hi, rel.tol = 1e-10)$value
  pass <- if (is.infinite(c0)) 1 else integ(dens, -c0, c0)
  ## interaction: E[err], E[err^2], P(cover) integrated over D in each region
  moments <- function(region_fun, se_rep, lo, hi) {
    c(e1 = integ(function(D) sapply(D, function(d) region_fun(d)[["m"]]) * dens(D), lo, hi),
      e2 = integ(function(D) sapply(D, function(d) { r <- region_fun(d); r[["s"]]^2 + r[["m"]]^2 }) * dens(D), lo, hi),
      cov = integ(function(D) sapply(D, function(d) { r <- region_fun(d)
        stats::pnorm((z * se_rep - r[["m"]]) / r[["s"]]) - stats::pnorm((-z * se_rep - r[["m"]]) / r[["s"]]) }) * dens(D), lo, hi))
  }
  big <- 12 * sD + abs(delta)
  in_p <- if (is.infinite(c0)) moments(pooled_err, sP, -big, big) else moments(pooled_err, sP, -c0, c0)
  out_w1 <- if (is.infinite(c0)) c(e1 = 0, e2 = 0, cov = 0) else moments(within_err, sW, -big, -c0)
  out_w2 <- if (is.infinite(c0)) c(e1 = 0, e2 = 0, cov = 0) else moments(within_err, sW, c0, big)
  tot <- in_p + out_w1 + out_w2
  ## coverage of the pooled interval given a pass
  cond_cov <- if (pass > 0) in_p[["cov"]] / pass else NA
  c(pass = pass, bias = tot[["e1"]], rmse = sqrt(tot[["e2"]]), coverage = tot[["cov"]],
    cond_cover_pass = cond_cov, cond_bias_pass = if (pass > 0) in_p[["e1"]] / pass else NA)
}

rules <- list(
  half_sA = function(sW, sA) 0.5 * sA,
  test_05 = function(sW, sA) stats::qnorm(0.975) * sqrt(sW^2 + sA^2),
  test_20 = function(sW, sA) stats::qnorm(0.90) * sqrt(sW^2 + sA^2))
