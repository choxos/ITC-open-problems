## ---------------------------------------------------------------------------
## COV-09: the same covariate name, two instruments.
##
## Latent X ~ N(0, 1) in the source and N(MU_T, 1) in the target. The source records
## X_S = a_S + b_S X + e_S; the target reports the mean of X_T = a_T + b_T X + e_T.
## MAIC tilts the source on X_S to the reported mean m_T = a_T + b_T MU_T. For a
## normal source, tilting on X_S moves the latent mean by kappa times the shift in
## X_S, kappa = b_S / (b_S^2 + var(e_S)), so
##   E_w[X] = kappa (a_T + b_T MU_T - a_S),
## and the transported effect is biased by BETA (MU_T - E_w[X]). Two regimes:
##   same instrument (a_S = a_T, b_S = b_T = b): E_w[X] = lambda MU_T with
##   reliability lambda = b kappa, so the adjustment is attenuated by (1 - lambda)
##   and a known reliability corrects it exactly;
##   different instruments: the bias has either sign and no source-side quantity
##   identifies it.
## The balance table shows the recorded mean matched in both regimes.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261004L
N_ARM <- 200L; MU_T <- 0.5; DELTA <- -0.4; GAMMA <- 0.5
N_SIM <- 1000L
SCEN <- list(same = c(aS = 0, bS = 1, aT = 0, bT = 1),
             same_shifted = c(aS = 0.3, bS = 0.8, aT = 0.3, bT = 0.8),
             target_offset = c(aS = 0, bS = 1, aT = 0.3, bT = 1),
             target_slope = c(aS = 0, bS = 1, aT = 0, bT = 0.8),
             target_both = c(aS = 0, bS = 1, aT = -0.3, bT = 1.2))
LEVELS <- list(scen = names(SCEN), rel = c(1, 0.8, 0.6), beta = c(0, 0.3, 0.6))
## Declared sensitivity ranges for the target instrument relative to the source's.
SENS_A <- seq(-0.3, 0.3, length.out = 5); SENS_B <- seq(0.8, 1.2, length.out = 5)

build_grid <- function() {
  g <- expand.grid(scen = LEVELS$scen, rel = LEVELS$rel, beta = LEVELS$beta,
                   KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$cell <- seq_len(nrow(g)); g
}

## Error variance giving the source instrument reliability `rel`:
## lambda = bS^2 / (bS^2 + ve).
ve_for <- function(bS, rel) bS^2 * (1 - rel) / rel

truth <- function(cell) DELTA + cell$beta * MU_T
predicted_bias <- function(cell) {
  s <- SCEN[[cell$scen]]; ve <- ve_for(s[["bS"]], cell$rel)
  kap <- s[["bS"]] / (s[["bS"]]^2 + ve)
  cell$beta * (kap * (s[["aT"]] + s[["bT"]] * MU_T - s[["aS"]]) - MU_T)
}

draw <- function(cell) {
  s <- SCEN[[cell$scen]]; ve <- ve_for(s[["bS"]], cell$rel)
  X <- stats::rnorm(2 * N_ARM); A <- rep(0:1, each = N_ARM)
  y <- GAMMA * X + A * (DELTA + cell$beta * X) + stats::rnorm(2 * N_ARM)
  XS <- s[["aS"]] + s[["bS"]] * X + stats::rnorm(2 * N_ARM, 0, sqrt(ve))
  ## the target publication's reported mean, as a population value
  list(XS = XS, A = A, y = y, mT = s[["aT"]] + s[["bT"]] * MU_T)
}

tilt1 <- function(x, m) {
  xc <- x - m
  a <- stats::uniroot(function(a) sum(xc * exp(a * xc)), c(-30, 30), tol = 1e-12)$root
  exp(a * xc)
}
contrast <- function(d, w) {
  m1 <- sum(w * d$A * d$y) / sum(w * d$A); m0 <- sum(w * (1 - d$A) * d$y) / sum(w * (1 - d$A))
  v <- sum(w^2 * d$A * (d$y - m1)^2) / sum(w * d$A)^2 + sum(w^2 * (1 - d$A) * (d$y - m0)^2) / sum(w * (1 - d$A))^2
  c(est = m1 - m0, se = sqrt(v))
}

## Naive: match the reported number. Reliability-corrected: assume one instrument
## and a known source reliability, and match the disattenuated point
## mean(XS) + (mT - mean(XS)) / rel. Bounded: for each declared (a, b) of the target
## instrument relative to the source's, the implied source-scale target is
## a_S-scale value (mT - a) / b, corrected for reliability; report the envelope of
## the resulting intervals.
fit_all <- function(cell, d) {
  z <- stats::qnorm(0.975)
  nv <- contrast(d, tilt1(d$XS, d$mT))
  mS <- mean(d$XS)
  corr_pt <- mS + (d$mT - mS) / cell$rel
  rc <- tryCatch(contrast(d, tilt1(d$XS, corr_pt)), error = function(e) c(est = NA, se = NA))
  env <- c(Inf, -Inf)
  for (a in SENS_A) for (b in SENS_B) {
    pt <- mS + ((d$mT - a) / b - mS) / cell$rel
    r <- tryCatch(contrast(d, tilt1(d$XS, pt)), error = function(e) NULL)
    if (!is.null(r)) env <- c(min(env[1], r[["est"]] - z * r[["se"]]), max(env[2], r[["est"]] + z * r[["se"]]))
  }
  data.frame(method = c("naive", "reliability_corrected", "bounded"),
             est = c(nv[["est"]], rc[["est"]], NA), lo = c(nv[["est"]] - z * nv[["se"]], rc[["est"]] - z * rc[["se"]], env[1]),
             hi = c(nv[["est"]] + z * nv[["se"]], rc[["est"]] + z * rc[["se"]], env[2]))
}
