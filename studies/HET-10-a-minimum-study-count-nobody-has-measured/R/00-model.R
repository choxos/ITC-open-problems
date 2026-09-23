## ---------------------------------------------------------------------------
## HET-10: interval coverage for population-adjusted synthesis with few studies.
##
## One individual-data trial of A versus C (300 per arm, x ~ N(0, 1)); K aggregate
## trials of B versus C (200 per arm) in the target population (x mean 0.5).
## Continuous outcome; A's effect DELTA_A + BETA x, so MAIC transports it to the
## target; B's effect DELTA_B + u_k with heterogeneity u_k ~ N(0, TAU^2).
## Estimand: B versus A in the target, DELTA_B - (DELTA_A + BETA * 0.5).
## Every per-trial adjusted contrast B_k - A(target) reuses the same transported
## A-versus-C estimate, so the contrasts share one error.
## Methods: naive random-effects meta-analysis of the K contrasts with each one's
## variance (DerSimonian-Laird; Hartung-Knapp); two-step: pool the B-versus-C
## trials first (DerSimonian-Laird; Hartung-Knapp with t on K - 1), then subtract
## the transported A-versus-C estimate once.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261030L
N_IPD <- 300L; N_AGD <- 200L; DELTA_A <- -0.3; BETA <- 0.4; DELTA_B <- -0.5; N_SIM <- 2000L
LEVELS <- list(K = c(2L, 3L, 4L, 6L, 8L, 12L), tau = c(0, 0.1, 0.2))
build_grid <- function() { g <- expand.grid(K = LEVELS$K, tau = LEVELS$tau, KEEP.OUT.ATTRS = FALSE); g$cell <- seq_len(nrow(g)); g }
truth <- function() DELTA_B - (DELTA_A + BETA * 0.5)

draw <- function(cell) {
  x <- stats::rnorm(2 * N_IPD); A <- rep(0:1, each = N_IPD); y <- 0.5 * x + A * (DELTA_A + BETA * x) + stats::rnorm(2 * N_IPD)
  bc <- t(sapply(seq_len(cell$K), function(k) { u <- stats::rnorm(1, 0, cell$tau); xb <- stats::rnorm(2 * N_AGD, 0.5); B <- rep(0:1, each = N_AGD)
    yb <- 0.5 * xb + B * (DELTA_B + u) + stats::rnorm(2 * N_AGD); c(mean(yb[B == 1]) - mean(yb[B == 0]), stats::var(yb[B == 1]) / N_AGD + stats::var(yb[B == 0]) / N_AGD) }))
  list(ipd = data.frame(x = x, A = A, y = y), bc = bc)
}
maic_ac <- function(d) { xc <- d$x - 0.5; a <- stats::uniroot(function(a) sum(xc * exp(a * xc)), c(-20, 20))$root; w <- exp(a * xc)
  f <- stats::lm(y ~ A, data = d, weights = w); c(stats::coef(f)[["A"]], sandwich::vcovHC(f, "HC0")["A", "A"]) }
re <- function(e, v, hk = FALSE) { w <- 1 / v; m0 <- sum(w * e) / sum(w); k <- length(e); Q <- sum(w * (e - m0)^2)
  t2 <- if (k > 1) max(0, (Q - (k - 1)) / (sum(w) - sum(w^2) / sum(w))) else 0; ws <- 1 / (v + t2); m <- sum(ws * e) / sum(ws)
  if (!hk || k < 2) return(c(m, sqrt(1 / sum(ws)), stats::qnorm(0.975)))
  q <- sum(ws * (e - m)^2) / (k - 1); c(m, sqrt(q / sum(ws)), stats::qt(0.975, k - 1)) }
fit_all <- function(cell, d) {
  ac <- maic_ac(d$ipd); e <- d$bc[, 1] - ac[1]; v <- d$bc[, 2] + ac[2]
  out <- rbind(naive_dl = re(e, v), naive_hk = re(e, v, TRUE))
  b <- re(d$bc[, 1], d$bc[, 2]); bh <- re(d$bc[, 1], d$bc[, 2], TRUE)
  out <- rbind(out, twostep_dl = c(b[1] - ac[1], sqrt(b[2]^2 + ac[2]), stats::qnorm(0.975)),
                    twostep_hk = c(bh[1] - ac[1], sqrt(bh[2]^2 + ac[2]), bh[3]))
  data.frame(method = rownames(out), est = out[, 1], se = out[, 2], crit = out[, 3])
}
