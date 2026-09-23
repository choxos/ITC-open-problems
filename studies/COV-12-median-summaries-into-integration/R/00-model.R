## ---------------------------------------------------------------------------
## COV-12: target covariate marginals reconstructed from a median with IQR or range.
##
## The target publication reports a covariate as median (q1, q3) or median
## (min, max) computed on n_T patients. An integration-based adjustment needs the
## whole marginal. The error in the target contrast is integral tau d(F_hat - F):
## under an identity link with linear modification only the reconstructed mean
## enters; under a logit link the variance and shape enter too (DESIGN.md section 2).
## The conditional model is held known here so that reconstruction is the only
## source of error.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261011L
ALPHA <- stats::qlogis(0.3); G <- 0.8; DELTA <- -0.6
N_SIM <- 1000L
LEVELS <- list(link = c("identity", "logit"), skew = c(0, 0.5, 1), summary = c("iqr", "range"),
               n_t = c(50L, 200L, 1000L), beta = c(0.3, 0.8))

build_grid <- function() {
  g <- expand.grid(link = LEVELS$link, skew = LEVELS$skew, summary = LEVELS$summary,
                   n_t = LEVELS$n_t, beta = LEVELS$beta, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$cell <- seq_len(nrow(g)); g
}

## True covariate law: lognormal with log-SD `skew`, scaled to mean 1 and SD 1
## (skew 0 is standard normal shifted to mean 1).
rtrue <- function(n, skew) if (skew == 0) stats::rnorm(n, 1, 1) else {
  s <- skew; m <- -s^2 / 2; sdx <- sqrt((exp(s^2) - 1))
  1 + (exp(stats::rnorm(n, m, s)) - 1) / sdx }
qtrue <- function(p, skew) if (skew == 0) stats::qnorm(p, 1, 1) else {
  s <- skew; sdx <- sqrt(exp(s^2) - 1); 1 + (exp(stats::qnorm(p, -s^2 / 2, s)) - 1) / sdx }

## Conditional effect of A versus C at covariate x, on the analysis scale.
cond_rates <- function(x, cell) {
  if (cell$link == "identity") list(p1 = G * x + DELTA + cell$beta * x, p0 = G * x)
  else list(p1 = stats::plogis(ALPHA + G * x + DELTA + cell$beta * x), p0 = stats::plogis(ALPHA + G * x))
}
contrast_over <- function(xq, cell) {
  r <- cond_rates(xq, cell)
  if (cell$link == "identity") mean(r$p1) - mean(r$p0) else stats::qlogis(mean(r$p1)) - stats::qlogis(mean(r$p0))
}
## Integration points: 2000 equally spaced quantiles of a law.
PQ <- (seq_len(2000) - 0.5) / 2000
truth <- function(cell) contrast_over(qtrue(PQ, cell$skew), cell)

## Reconstructions from the reported summary.
recon <- function(s, cell, family) {
  if (cell$summary == "iqr") {
    m <- (s$q1 + s$med + s$q3) / 3; sd <- (s$q3 - s$q1) / 1.35          # Wan et al. (2014), normal
  } else {
    m <- (s$min + 2 * s$med + s$max) / 4; sd <- (s$max - s$min) / (2 * stats::qnorm((cell$n_t - 0.375) / (cell$n_t + 0.25)))
  }
  if (family == "normal") return(stats::qnorm(PQ, m, sd))
  ## Shifted lognormal matched to the median and the two reported quantiles:
  ## x = c + exp(mu + s z); choose c so the reported quantiles are asymmetric
  ## about the median in the right proportion.
  lo <- if (cell$summary == "iqr") s$q1 else s$min; hi <- if (cell$summary == "iqr") s$q3 else s$max
  zq <- if (cell$summary == "iqr") stats::qnorm(0.75) else stats::qnorm((cell$n_t - 0.375) / (cell$n_t + 0.25))
  r <- (hi - s$med) / (s$med - lo)
  if (!is.finite(r) || r <= 1.02) return(stats::qnorm(PQ, m, sd))    # no evidence of right skew
  sg <- log(r) / zq                                                    # exp(s z) / exp(-s z) = r at z = zq
  a <- (s$med - lo) / (1 - exp(-sg * zq)); cc <- s$med - a
  cc + a * exp(sg * stats::qnorm(PQ))
}

one_rep <- function(cell, th) {
  x <- rtrue(cell$n_t, cell$skew)
  s <- list(med = stats::median(x), q1 = stats::quantile(x, 0.25, names = FALSE), q3 = stats::quantile(x, 0.75, names = FALSE),
            min = min(x), max = max(x))
  rn <- recon(s, cell, "normal"); rl <- recon(s, cell, "lognormal")
  est <- c(normal = contrast_over(rn, cell), lognormal = contrast_over(rl, cell),
           sample_exact = contrast_over(x, cell))
  ## the reconstructed means' errors against the sample mean, for the registered
  ## test of whether contrast error is a function of mean error alone
  c(est - th, mean_err_normal = mean(rn) - mean(x), mean_err_lognormal = mean(rl) - mean(x))
}
