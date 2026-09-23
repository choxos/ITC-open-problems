## ---------------------------------------------------------------------------
## MIS-02: participation weights multiplied by inverse-probability-of-censoring
## weights (the TADA construction) for a transported RMST difference.
##
## Individual data from a trial of A versus C, 250 per arm; covariates x1 ~ N(0, 1),
## x2 ~ Bern(0.4). Target publishes means: x1 ~ N(MU_T, 1), x2 ~ Bern(0.6).
## Events: Weibull PH, H(t | x, a) = (t / SCALE0)^1.2 exp(0.5 x1 + 0.4 x2 +
## a (-0.5 + 0.3 x1)). Censoring: exponential with hazard lambda_c exp(KAPPA x1).
## KAPPA > 0 makes censoring weights large where participation weights are large
## (target shifted to higher x1): positively correlated weight sets; KAPPA < 0
## the reverse. lambda_c is set so a declared share of patients is censored before
## TAU.
## Estimand: target RMST to TAU = 24, A minus C.
## Methods:
##   part_km    participation-weighted Kaplan-Meier (no censoring model)
##   tada       Hajek IPCW mean of min(T, TAU) with weights w_part / G(min(T, TAU)- | x),
##              Cox censoring model on x1, x2 per arm; bootstrap SE re-estimating both
##   tada_fixed the same estimate with a sandwich treating both weight sets as fixed
##   tada_miss  censoring model omitting x1; bootstrap SE
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(survival))
MASTER_SEED <- 20261120L
N_ARM <- 250L; SHAPE <- 1.2; SCALE0 <- 18 / log(2)^(1 / SHAPE); TAU <- 24; P2_S <- 0.4; P2_T <- 0.6
N_SIM <- 500L; N_BOOT <- 100L
lp <- function(x1, x2, a) 0.5 * x1 + 0.4 * x2 + a * (-0.5 + 0.3 * x1)

build_grid <- function() {
  g <- expand.grid(cens = c(0.25, 0.6), mu_t = c(0.5, 1.2), kappa = c(1.2, -1.2), KEEP.OUT.ATTRS = FALSE)
  g$ctrl <- "none"
  g <- rbind(g, data.frame(cens = c(0, 0.6), mu_t = 1.2, kappa = c(1.2, 0), ctrl = c("no_censoring", "independent")))
  g$cell <- seq_len(nrow(g))
  g$lambda_c <- vapply(seq_len(nrow(g)), function(i) lambda_c(g$cens[i], g$kappa[i]), 0)
  g
}

draw_times <- function(x1, x2, a) SCALE0 * (stats::rexp(length(x1)) / exp(lp(x1, x2, a)))^(1 / SHAPE)

## Censoring rate giving the declared share censored before min(T, TAU) in the
## source, by Monte Carlo with a fixed seed.
lambda_c <- function(frac, kappa) {
  if (frac == 0) return(0)
  old <- if (exists(".Random.seed", .GlobalEnv)) get(".Random.seed", .GlobalEnv) else NULL; set.seed(5)
  n <- 2e5; x1 <- stats::rnorm(n); x2 <- stats::rbinom(n, 1, P2_S); a <- rep(0:1, length.out = n)
  y <- pmin(draw_times(x1, x2, a), TAU); e <- stats::rexp(n)
  if (!is.null(old)) assign(".Random.seed", old, .GlobalEnv)
  stats::uniroot(function(l) mean(e / (l * exp(kappa * x1)) < y) - frac, c(1e-5, 5))$root
}

truth <- function(cell) {
  gh <- statmod::gauss.quad.prob(40, "normal", mu = cell$mu_t, sigma = 1)
  S <- function(t, a) vapply(t, function(u) sum(gh$weights * (P2_T * exp(-(u / SCALE0)^SHAPE * exp(lp(gh$nodes, 1, a))) +
    (1 - P2_T) * exp(-(u / SCALE0)^SHAPE * exp(lp(gh$nodes, 0, a))))), 0)
  stats::integrate(S, 0, TAU, a = 1)$value - stats::integrate(S, 0, TAU, a = 0)$value
}

draw <- function(cell) {
  n <- 2 * N_ARM; x1 <- stats::rnorm(n); x2 <- stats::rbinom(n, 1, P2_S); A <- rep(0:1, each = N_ARM)
  t <- draw_times(x1, x2, A)
  cz <- if (cell$lambda_c > 0) stats::rexp(n, cell$lambda_c * exp(cell$kappa * x1)) else rep(Inf, n)
  cz <- pmin(cz, 1.5 * TAU)                                   # administrative end after the horizon
  data.frame(x1 = x1, x2 = x2, A = A, time = pmin(t, cz), status = as.integer(t <= cz))
}

## Method-of-moments participation weights (pooled over arms) matching the
## target's x1 mean and x2 proportion.
part_w <- function(d, cell) {
  X <- cbind(d$x1 - cell$mu_t, d$x2 - P2_T)
  o <- stats::optim(c(0, 0), function(b) sum(exp(X %*% b)), function(b) colSums(X * as.vector(exp(X %*% b))), method = "BFGS")
  as.vector(exp(X %*% o$par))
}

## Inverse probability of remaining uncensored at min(T, TAU)-, from a Cox model
## for censoring within each arm. Zero for patients censored before the horizon.
ipcw <- function(d, form) {
  y <- pmin(d$time, TAU); obs <- d$status == 1 | d$time >= TAU; out <- numeric(nrow(d))
  for (a in 0:1) {
    s <- d$A == a; ds <- d[s, ]
    if (sum(ds$status == 0 & ds$time < TAU) == 0) { out[s] <- as.numeric(obs[s]); next }
    mm <- stats::model.matrix(form, ds)[, -1, drop = FALSE]; ev <- 1 - ds$status
    f <- coxph(Surv(ds$time, ev) ~ mm, ties = "breslow"); r <- exp(as.vector(mm %*% stats::coef(f)))
    ut <- sort(unique(ds$time[ev == 1]))
    dl <- vapply(ut, function(u) sum(ev[ds$time == u]) / sum(r[ds$time >= u]), 0)   # Breslow increments
    H <- c(0, cumsum(dl))[findInterval(y[s], ut, left.open = TRUE) + 1]              # cumulative hazard at y-
    G <- exp(-H * r)
    out[s] <- obs[s] / G
  }
  out
}

rmst_km <- function(d, w) vapply(0:1, function(a) { s <- d$A == a
  f <- survfit(Surv(time, status) ~ 1, data = d[s, ], weights = w[s]); summary(f, rmean = TAU)$table[["rmean"]] }, 0)

tada_est <- function(d, wp, wc) { y <- pmin(d$time, TAU); w <- wp * wc
  m <- vapply(0:1, function(a) { s <- d$A == a; sum(w[s] * y[s]) / sum(w[s]) }, 0)
  v <- vapply(0:1, function(a) { s <- d$A == a; sum(w[s]^2 * (y[s] - m[a + 1])^2) / sum(w[s])^2 }, 0)
  c(est = m[2] - m[1], se_fixed = sqrt(sum(v))) }

FORM_OK <- ~ x1 + x2; FORM_MISS <- ~ x2
estimates <- function(d, cell) {
  wp <- part_w(d, cell); wc <- ipcw(d, FORM_OK); wm <- ipcw(d, FORM_MISS)
  k <- rmst_km(d, wp); t1 <- tada_est(d, wp, wc); t2 <- tada_est(d, wp, wm)
  list(est = c(part_km = k[2] - k[1], tada = t1[["est"]], tada_miss = t2[["est"]]), se_fixed = t1[["se_fixed"]], wp = wp, wc = wc)
}

ess <- function(w) sum(w)^2 / sum(w^2)
one_rep <- function(cell) {
  d <- draw(cell); e <- estimates(d, cell)
  bs <- replicate(N_BOOT, { i <- c(sample(which(d$A == 0), replace = TRUE), sample(which(d$A == 1), replace = TRUE))
    tryCatch(estimates(d[i, ], cell)$est, error = function(err) rep(NA, 3)) })
  se <- apply(bs, 1, stats::sd, na.rm = TRUE); obs <- e$wc > 0
  data.frame(method = c("part_km", "tada", "tada_fixed", "tada_miss"),
             est = c(e$est[["part_km"]], e$est[["tada"]], e$est[["tada"]], e$est[["tada_miss"]]),
             se = c(se[["part_km"]], se[["tada"]], e$se_fixed, se[["tada_miss"]]),
             boot_fail = mean(is.na(bs[2, ])), ess_part = ess(e$wp), ess_cens = ess(e$wc), ess_prod = ess(e$wp * e$wc),
             cor_w = if (sd(e$wc[obs]) > 0) stats::cor(e$wp[obs], e$wc[obs]) else NA, cens_share = mean(d$status == 0 & d$time < TAU))
}
