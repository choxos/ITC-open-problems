## ---------------------------------------------------------------------------
## DIA-09 (competing-risks family): a transported cause-specific hazard ratio can
## be right while the cumulative incidence the decision uses is wrong.
##
## Source trial A versus C, 300 per arm, x ~ N(0, 1); target x ~ N(M_T, 1).
## Exponential cause-specific hazards:
##   cause 1 (event of interest)  h1 = 0.3 exp(0.5 x + A (-0.5 + b x))
##   cause 2 (competing)          h2 = K_pop 0.2 exp(0.5 x)
## K_S = 1 in the source; K_T in the target captures competing risk that the
## measured covariate does not explain (for example age beyond the recorded one).
## Administrative censoring at 3; estimand: target cumulative incidence of cause 1
## at TAU = 2, A minus C. The target publishes covariate means and SDs and the
## proportion of its control arm with a competing event by TAU.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261016L
N_ARM <- 300L; N_T <- 300L; TAU <- 2; CENS <- 3; G_POINTS <- 2000L; N_SIM <- 1000L
LEVELS <- list(k_t = c(0.5, 1, 2, 4), b = c(0, 0.4), m_t = c(0.5, 1))
build_grid <- function() {
  g <- expand.grid(k_t = LEVELS$k_t, b = LEVELS$b, m_t = LEVELS$m_t, KEEP.OUT.ATTRS = FALSE)
  g$cell <- seq_len(nrow(g)); g
}
h1f <- function(x, A, b) 0.3 * exp(0.5 * x + A * (-0.5 + b * x))
h2f <- function(x, k) k * 0.2 * exp(0.5 * x)
cif1 <- function(h1, h2, t) h1 / (h1 + h2) * (1 - exp(-(h1 + h2) * t))
cif2 <- function(h1, h2, t) h2 / (h1 + h2) * (1 - exp(-(h1 + h2) * t))

truth <- function(cell) {
  gh <- statmod::gauss.quad.prob(60, "normal", mu = cell$m_t, sigma = 1)
  f <- function(A) sum(gh$weights * cif1(h1f(gh$nodes, A, cell$b), h2f(gh$nodes, cell$k_t), TAU))
  c(cif_diff = f(1) - f(0), cif_A = f(1))
}

draw <- function(cell) {
  n <- 2 * N_ARM; x <- stats::rnorm(n); A <- rep(0:1, each = N_ARM)
  h1 <- h1f(x, A, cell$b); h2 <- h2f(x, 1)
  t <- stats::rexp(n, h1 + h2); cause <- ifelse(stats::runif(n) < h1 / (h1 + h2), 1L, 2L)
  cause[t > CENS] <- 0L; t <- pmin(t, CENS)
  xt <- stats::rnorm(N_T, cell$m_t); h1t <- h1f(xt, 0, cell$b); h2t <- h2f(xt, cell$k_t)
  tt <- stats::rexp(N_T, h1t + h2t); ct <- ifelse(stats::runif(N_T) < h1t / (h1t + h2t), 1L, 2L)
  structure(data.frame(x = x, A = A, time = t, cause = cause),
            target = list(m = mean(xt), s = stats::sd(xt), p2 = mean(tt <= TAU & ct == 2)))
}

## Weighted proportion with cause 1 by TAU (no censoring before TAU), per arm.
maic <- function(d, m, arm_only = FALSE) {
  xc <- d$x - m; a <- stats::uniroot(function(a) sum(xc * exp(a * xc)), c(-20, 20))$root; w <- exp(a * xc)
  ev <- as.numeric(d$time <= TAU & d$cause == 1)
  p <- function(k) { i <- d$A == k; wk <- w[i] / sum(w[i]); c(sum(wk * ev[i]), sum(wk^2 * (ev[i] - sum(wk * ev[i]))^2)) }
  p1 <- p(1); p0 <- p(0); if (arm_only) return(c(p1[1], sqrt(p1[2])))
  c(p1[1] - p0[1], sqrt(p1[2] + p0[2]))
}

## Exponential cause-specific models by Poisson regression with a log-time offset.
cs_fit <- function(d) {
  d$lt <- log(d$time)
  f1 <- stats::glm(I(cause == 1) ~ x * A + offset(lt), family = stats::poisson(), data = d)
  f2 <- stats::glm(I(cause == 2) ~ x + offset(lt), family = stats::poisson(), data = d)
  list(b1 = stats::coef(f1), V1 = stats::vcov(f1), b2 = stats::coef(f2), V2 = stats::vcov(f2))
}
Z <- NULL
zdraw <- function() { if (is.null(Z)) { old <- if (exists(".Random.seed", .GlobalEnv)) get(".Random.seed", .GlobalEnv) else NULL
  set.seed(8); Z <<- stats::rnorm(G_POINTS); if (!is.null(old)) assign(".Random.seed", old, .GlobalEnv) }; Z }
## Target CIF difference from coefficients; shift adds to the cause-2 intercept.
cif_from <- function(b1, b2, tg, shift = 0, arm = NA) { z <- tg$m + tg$s * zdraw()
  h1 <- function(A) exp(b1[1] + b1[2] * z + A * (b1[3] + b1[4] * z)); h2 <- exp(b2[1] + shift + b2[2] * z)
  if (!is.na(arm)) return(mean(cif1(h1(arm), h2, TAU)))
  mean(cif1(h1(1), h2, TAU)) - mean(cif1(h1(0), h2, TAU)) }
delta_se <- function(fun, b, V) { g <- sapply(seq_along(b), function(j) { e <- replace(0 * b, j, 1e-5); (fun(b + e) - fun(b - e)) / 2e-5 })
  sqrt(drop(t(g) %*% V %*% g)) }

fit_all <- function(d) {
  tg <- attr(d, "target"); cs <- cs_fit(d)
  mc <- maic(d, tg$m)
  ## STC with the source's competing hazard.
  est <- cif_from(cs$b1, cs$b2, tg)
  se <- sqrt(delta_se(function(b) cif_from(b, cs$b2, tg), cs$b1, cs$V1)^2 + delta_se(function(b) cif_from(cs$b1, b, tg), cs$b2, cs$V2)^2)
  ## STC with the competing hazard recalibrated to the target's reported
  ## proportion of control patients with a competing event by TAU.
  z <- tg$m + tg$s * zdraw()
  pc <- function(sh) mean(cif2(exp(cs$b1[1] + cs$b1[2] * z), exp(cs$b2[1] + sh + cs$b2[2] * z), TAU)) - tg$p2
  sh <- tryCatch(stats::uniroot(pc, c(-5, 5))$root, error = function(e) NA)
  est_r <- if (is.na(sh)) NA else cif_from(cs$b1, cs$b2, tg, sh)
  se_r <- if (is.na(sh)) NA else delta_se(function(b) cif_from(b, cs$b2, tg, sh), cs$b1, cs$V1)
  ma <- maic(d, tg$m, TRUE)
  ea <- cif_from(cs$b1, cs$b2, tg, arm = 1)
  sea <- sqrt(delta_se(function(b) cif_from(b, cs$b2, tg, arm = 1), cs$b1, cs$V1)^2 + delta_se(function(b) cif_from(cs$b1, b, tg, arm = 1), cs$b2, cs$V2)^2)
  ear <- if (is.na(sh)) NA else cif_from(cs$b1, cs$b2, tg, sh, arm = 1)
  sear <- if (is.na(sh)) NA else delta_se(function(b) cif_from(b, cs$b2, tg, sh, arm = 1), cs$b1, cs$V1)
  c(maic = mc[1], maic_se = mc[2], stc = est, stc_se = se, stc_recal = est_r, stc_recal_se = se_r,
    maic_A = ma[1], maic_A_se = ma[2], stc_A = ea, stc_A_se = sea, stc_recal_A = ear, stc_recal_A_se = sear,
    log_hr1 = unname(cs$b1[3] + cs$b1[4] * tg$m), log_hr1_se = sqrt(cs$V1[3, 3] + tg$m^2 * cs$V1[4, 4] + 2 * tg$m * cs$V1[3, 4]))
}
