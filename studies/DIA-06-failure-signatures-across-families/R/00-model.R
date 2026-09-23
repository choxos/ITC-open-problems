## ---------------------------------------------------------------------------
## DIA-06: how each estimator family fails as overlap goes.
##
## Source trial A versus C, N_ARM per arm, x ~ N(0, 1). Target x ~ N(delta, 1),
## a known law. chi^2(F_T || F_S) = exp(delta^2) - 1, so the divergence axis is
## log(1 + chi^2) = delta^2, spaced evenly. The density ratio exp(delta x -
## delta^2 / 2) is log-linear, so MAIC on the mean is the exact weight model for
## every outcome surface and ESS/n -> exp(-delta^2): weighting can fail only by
## variance.
##
## Linear predictor eta_a(x) = PROG x + a tau(x), tau(x) = TAU0 + TAU1 x +
## beta2 (x^2 - 1). Continuous: y = eta + e, e ~ N(0, 1). Binary: logit P(y = 1)
## = B0 + eta. Under the source law x and x^2 - 1 are orthogonal, so the
## least-false linear-interaction model has slope TAU1 and on the continuous
## scale its target bias is exactly -beta2 delta^2. Curvature beta2 moves the
## outcome model's error at fixed divergence and leaves the covariate law, the
## weights and every weight diagnostic unchanged.
##
## Estimand: target marginal A versus C effect (mean difference; log odds ratio),
## by Gauss-Hermite quadrature over the target law. In an anchored comparison the
## target's B versus C estimate adds independent noise and no bias, so the
## transported A versus C contrast carries each family's whole error.
##
## Methods: unadjusted; MAIC (mean, robust SE); STC (linear interaction model,
## marginalized over the target law, delta-method SE); DR (the STC model plus
## MAIC-weighted residuals in each arm); RF (ranger regression forest per arm,
## fixed tuning, marginalized over the target law). DR and RF carry no SE.
## ---------------------------------------------------------------------------

suppressPackageStartupMessages({ library(ranger); library(sandwich) })
MASTER_SEED <- 20261406L
N_ARM <- 500L; N_SIM <- 1000L
PROG <- 0.5; TAU0 <- -0.5; TAU1 <- 0.3; B0 <- -0.5
D2 <- c(0, 0.6, 1.2, 1.8, 2.4, 3.0)            # log(1 + chi^2), evenly spaced
BETA2 <- c(linear = 0, moderate = 0.1, strong = 0.25)
MATERIAL <- 0.1                                  # bias onset, both scales
SD_RATIO <- 2                                    # variance onset: SD / SD at delta = 0
RF_TREES <- 200L; RF_NODE <- 20L                 # declared before the run, not tuned
BEYOND <- 3.6                                    # onset value when the grid never reaches it
GH <- statmod::gauss.quad.prob(60, "normal")
QG <- stats::qnorm((seq_len(2000) - 0.5) / 2000)  # equal-weight grid for the forest's step functions
METHODS <- c("unadjusted", "maic", "stc", "dr", "rf")

## Common random numbers: the covariates, the uniforms behind y and the forest seeds
## depend on the replicate, the divergence level and the scale, not on curvature, so
## weights and every weight diagnostic are identical across curvature by construction.
crn_block <- function(cell) cell$level + length(D2) * (cell$scale == "binary")

## Onset: the smallest log(1 + chi^2) at which a curve first reaches thr, linearly
## interpolated between grid levels; BEYOND if it never does on the grid.
onset <- function(d2, y, thr) { i <- which(y >= thr)[1]
  if (is.na(i)) BEYOND else if (i == 1) d2[1] else d2[i - 1] + (thr - y[i - 1]) / (y[i] - y[i - 1]) * (d2[i] - d2[i - 1]) }

build_grid <- function() {
  g <- expand.grid(d2 = D2, curvature = names(BETA2), scale = c("continuous", "binary"),
                   KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$level <- match(g$d2, D2); g$beta2 <- BETA2[g$curvature]; g$cell <- seq_len(nrow(g)); g
}

eta <- function(x, a, b2) PROG * x + a * (TAU0 + TAU1 * x + b2 * (x^2 - 1))
link_contrast <- function(m1, m0, scale) if (scale == "binary") stats::qlogis(m1) - stats::qlogis(m0) else m1 - m0
mean_resp <- function(x, a, cell) if (cell$scale == "binary") stats::plogis(B0 + eta(x, a, cell$beta2)) else eta(x, a, cell$beta2)

## Target marginal effect by quadrature over x ~ N(delta, 1).
truth <- function(cell) { xt <- sqrt(cell$d2) + GH$nodes
  link_contrast(sum(GH$weights * mean_resp(xt, 1, cell)), sum(GH$weights * mean_resp(xt, 0, cell)), cell$scale) }

draw <- function(cell) {
  x <- stats::rnorm(2 * N_ARM); A <- rep(0:1, each = N_ARM); m <- mean_resp(x, A, cell)
  y <- if (cell$scale == "binary") as.integer(stats::runif(2 * N_ARM) < m) else m + stats::rnorm(2 * N_ARM)
  data.frame(x = x, A = A, y = y)
}

clamp <- function(p) pmin(pmax(p, 1e-3), 1 - 1e-3)

one_rep <- function(cell) {
  d <- draw(cell); delta <- sqrt(cell$d2); xt <- delta + GH$nodes; wt <- GH$weights
  bin <- cell$scale == "binary"; fam <- if (bin) stats::quasibinomial() else stats::gaussian()
  arm_means <- function(m1, m0) link_contrast(if (bin) clamp(m1) else m1, if (bin) clamp(m0) else m0, cell$scale)
  out <- data.frame(method = METHODS, est = NA_real_, se = NA_real_)
  ## Unadjusted: the source's own marginal contrast.
  fu <- stats::glm(y ~ A, family = fam, data = d)
  out[1, 2:3] <- c(stats::coef(fu)[["A"]], sqrt(stats::vcov(fu)["A", "A"]))
  ## MAIC on the mean, weights shared by both arms; robust SE ignoring weight estimation.
  xc <- d$x - delta
  a <- tryCatch(stats::uniroot(function(a) sum(xc * exp(a * xc)), c(-20, 20))$root, error = function(e) NA_real_)
  w <- if (is.na(a)) rep(NA_real_, nrow(d)) else exp(a * xc)
  if (!is.na(a)) { fm <- suppressWarnings(stats::glm(y ~ A, family = fam, data = d, weights = w))
    out[2, 2:3] <- c(stats::coef(fm)[["A"]], sqrt(sandwich::vcovHC(fm, type = "HC0")["A", "A"])) }
  ## STC: linear interaction model, standardized over the target law.
  fs <- stats::glm(y ~ A * x, family = fam, data = d); b <- stats::coef(fs); V <- stats::vcov(fs)
  X1 <- cbind(1, 1, xt, xt); X0 <- cbind(1, 0, xt, 0)
  p1 <- drop(X1 %*% b); p0 <- drop(X0 %*% b)
  if (bin) { m1 <- sum(wt * stats::plogis(p1)); m0 <- sum(wt * stats::plogis(p0))
    g <- colSums(wt * stats::dlogis(p1) * X1) / (m1 * (1 - m1)) - colSums(wt * stats::dlogis(p0) * X0) / (m0 * (1 - m0))
  } else { m1 <- sum(wt * p1); m0 <- sum(wt * p0); g <- colSums(wt * X1) - colSums(wt * X0) }
  out[3, 2:3] <- c(arm_means(m1, m0), sqrt(drop(t(g) %*% V %*% g)))
  ## DR: STC predictions over the target plus MAIC-weighted residuals in each arm.
  if (!is.na(a)) { r <- d$y - stats::predict(fs, type = "response")
    aug <- vapply(0:1, function(k) sum(w[d$A == k] * r[d$A == k]) / sum(w[d$A == k]), 0)
    out[4, 2] <- arm_means(m1 + aug[2], m0 + aug[1]) }
  ## RF: one regression forest per arm (a probability forest in effect for 0/1 y),
  ## averaged over an equal-weight quantile grid: Gauss-Hermite is inexact for steps.
  rf <- lapply(0:1, function(k) ranger::ranger(y ~ x, data = d[d$A == k, ], num.trees = RF_TREES,
                                               min.node.size = RF_NODE, num.threads = 1))
  pr <- vapply(rf, function(f) mean(stats::predict(f, data.frame(x = delta + QG), num.threads = 1)$predictions), 0)
  out[5, 2] <- arm_means(pr[2], pr[1])
  ## Diagnostics an analyst would report: ESS, and target mass beyond the source's largest x.
  out$ess <- if (is.na(a)) NA_real_ else sum(w)^2 / sum(w^2)
  out$mass_out <- 1 - stats::pnorm(max(d$x) - delta)
  out
}
