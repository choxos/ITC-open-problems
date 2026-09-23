## ---------------------------------------------------------------------------
## OUT-05: a transported mean contrast is safe under a pooled normal residual; a
## transported responder probability is not.
##
## Source trial A versus C, 300 per arm, x ~ N(0, 1); target x ~ N(m, 1).
## Latent outcome Y* = 20 + 5 x + A (4 + 2 x) + sigma_A e, e standardized normal
## or standardized skewed (gamma, shape 4); sigma_C = 6, sigma_A = 6 * ratio.
## Observed Y = max(Y*, FLOOR) with FLOOR set so that the source control arm has
## the declared floor mass. Responder: Y > c, c at the target control-arm median
## (near) or 90th percentile (tail) of the latent outcome.
## Estimands in the target: mean of Y, A minus C; P(Y > c), A minus C.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261021L
N_ARM <- 300L; SIG_C <- 6; N_SIM <- 1000L; G_POINTS <- 2000L
LEVELS <- list(ratio = c(1, 2), skew = c("none", "moderate"), floor_mass = c(0, 0.1, 0.25), m = c(0.3, 1))
build_grid <- function() {
  g <- expand.grid(ratio = LEVELS$ratio, skew = LEVELS$skew, floor_mass = LEVELS$floor_mass, m = LEVELS$m,
                   KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$cell <- seq_len(nrow(g)); g
}
reps <- function(n, skew) if (skew == "none") stats::rnorm(n) else (stats::rgamma(n, 4) - 4) / 2
mu <- function(x, A) 20 + 5 * x + A * (4 + 2 * x)

.big <- NULL
bank <- function(skew) { old <- if (exists(".Random.seed", .GlobalEnv)) get(".Random.seed", .GlobalEnv) else NULL
  set.seed(if (skew == "none") 31 else 32); z <- list(x = stats::rnorm(4e5), e = reps(4e5, skew))
  if (!is.null(old)) assign(".Random.seed", old, .GlobalEnv); z }
floor_for <- function(cell) { b <- bank(cell$skew); if (cell$floor_mass == 0) return(-Inf)
  stats::quantile(mu(b$x, 0) + SIG_C * b$e, cell$floor_mass)[[1]] }
thresholds <- function(cell) { b <- bank(cell$skew); yc <- mu(b$x + cell$m, 0) + SIG_C * b$e
  c(near = stats::quantile(yc, 0.5)[[1]], tail = stats::quantile(yc, 0.9)[[1]]) }
truth <- function(cell) { b <- bank(cell$skew); fl <- floor_for(cell); x <- b$x + cell$m; th <- thresholds(cell)
  y1 <- pmax(mu(x, 1) + SIG_C * cell$ratio * b$e, fl); y0 <- pmax(mu(x, 0) + SIG_C * b$e, fl)
  c(mean = mean(y1) - mean(y0), near = mean(y1 > th[["near"]]) - mean(y0 > th[["near"]]), tail = mean(y1 > th[["tail"]]) - mean(y0 > th[["tail"]])) }

draw <- function(cell, fl) {
  x <- stats::rnorm(2 * N_ARM); A <- rep(0:1, each = N_ARM); s <- ifelse(A == 1, SIG_C * cell$ratio, SIG_C)
  data.frame(x = x, A = A, y = pmax(mu(x, A) + s * reps(2 * N_ARM, cell$skew), fl))
}

## G-computation of both estimands from a model's predictive distribution.
fit_all <- function(cell, d, fl, th) {
  z <- cell$m + stats::qnorm(stats::ppoints(G_POINTS))
  out <- list()
  f <- stats::lm(y ~ A * x, data = d); b <- stats::coef(f); r <- stats::residuals(f)
  m1 <- b[1] + b[2] + (b[3] + b[4]) * z; m0 <- b[1] + b[3] * z
  pr <- function(m, s, c) mean(stats::pnorm((m - c) / s))
  sp <- summary(f)$sigma; s1 <- stats::sd(r[d$A == 1]); s0 <- stats::sd(r[d$A == 0])
  mean_lin <- mean(m1 - m0)
  out$normal_pooled <- c(mean_lin, pr(m1, sp, th[1]) - pr(m0, sp, th[1]), pr(m1, sp, th[2]) - pr(m0, sp, th[2]))
  out$normal_arm_sd <- c(mean_lin, pr(m1, s1, th[1]) - pr(m0, s0, th[1]), pr(m1, s1, th[2]) - pr(m0, s0, th[2]))
  ## Censored normal (Tobit) with arm-specific scale; predicted mean of max(Y*, floor).
  if (is.finite(fl) && any(d$y <= fl)) {
    tb <- survival::survreg(survival::Surv(y, y > fl, type = "left") ~ A * x + strata(A), data = d, dist = "gaussian")
    bt <- stats::coef(tb); sc <- tb$scale; names(sc) <- NULL; sA <- sc[2]; sC <- sc[1]
    t1 <- bt[1] + bt[2] + (bt[3] + bt[4]) * z; t0 <- bt[1] + bt[3] * z
    em <- function(m, s) { a <- (fl - m) / s; fl * stats::pnorm(a) + m * (1 - stats::pnorm(a)) + s * stats::dnorm(a) }
    out$tobit <- c(mean(em(t1, sA)) - mean(em(t0, sC)), pr(t1, sA, th[1]) - pr(t0, sC, th[1]), pr(t1, sA, th[2]) - pr(t0, sC, th[2]))
  } else out$tobit <- out$normal_arm_sd
  ## Direct responder model: logistic regression of the dichotomized outcome.
  lg <- function(c) { g <- stats::glm(I(y > c) ~ A * x, family = stats::binomial(), data = d); cf <- stats::coef(g)
    mean(stats::plogis(cf[1] + cf[2] + (cf[3] + cf[4]) * z)) - mean(stats::plogis(cf[1] + cf[3] * z)) }
  out$logistic_responder <- c(mean_lin, lg(th[1]), lg(th[2]))
  do.call(rbind, lapply(names(out), function(k) data.frame(method = k, est_mean = out[[k]][1], est_near = out[[k]][2], est_tail = out[[k]][3])))
}
