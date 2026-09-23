## ---------------------------------------------------------------------------
## MOD-16: pooled versus arm-separate matching, constants, DGM and estimators.
##
## Continuous outcome, identity link, so the mechanism is not confounded with
## non-collapsibility. One matched covariate X, reported by arm in the aggregate
## trial, and one unmatched prognostic covariate U, not reported.
##
##   y = ALPHA + GX x + gu u + delta_t + BETA x 1[t active] + e
##
## The aggregate B-versus-C trial has an imposed chance imbalance: its B arm's X
## is shifted by kappa SD, and U follows X through the target's own correlation
## rho_T. Algebra (protocol.md section 2), conditional on kappa:
##
##   pooled matching        bias = kappa (BETA / 2 + GX + gu rho_T)
##   arm-separate matching  bias = kappa gu (rho_T - rho_S)
##
## so arm-separate matching cancels the aggregate trial's imbalance on matched
## covariates and on anything that shares the correlation structure, and is
## biased only by an unmatched prognostic covariate whose correlation with the
## matched one differs between trials. DESIGN.md said the bias is the product of
## unmatched prognostic strength and imbalance alone.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20260924L
ALPHA <- 0; GX <- 0.5; BETA <- 0.3
DELTA_A <- -0.4; DELTA_B <- -0.2
N_IPD <- 300L; N_AGD <- 300L        # per arm
MU_T <- c(x = 0.5, u = 0.5)         # target population means; source means 0
SIGMA <- 1                          # residual SD

LEVELS <- list(
  kappa = c("0", "0.1", "0.2", "random"),   # imposed X imbalance, B minus C, SD
  gu    = c(0, 0.25, 0.5),                   # prognostic strength of U
  corr  = c("shared0", "shared05", "S05_T0", "S0_T05"),
  em    = c(0, BETA)
)
CORR <- list(shared0 = c(S = 0, T = 0), shared05 = c(S = 0.5, T = 0.5),
             S05_T0 = c(S = 0.5, T = 0), S0_T05 = c(S = 0, T = 0.5))
N_SIM <- 1000L

build_grid <- function() {
  g <- expand.grid(kappa = LEVELS$kappa, gu = LEVELS$gu, corr = LEVELS$corr,
                   beta = LEVELS$em, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$cell <- seq_len(nrow(g)); g
}

## Estimand: B versus A in the target population, whose X mean is MU_T["x"].
## With shared modification on the identity scale it is delta_B - delta_A.
truth <- function(cell) DELTA_B - DELTA_A

predicted <- function(cell) {
  if (cell$kappa == "random") return(c(pooled = 0, separate = 0))
  k <- as.numeric(cell$kappa); r <- CORR[[cell$corr]]
  c(pooled = k * (cell$beta / 2 + GX + cell$gu * r[["T"]]),
    separate = k * cell$gu * (r[["T"]] - r[["S"]]))
}

draw_xu <- function(n, mx, mu, rho) {
  x <- stats::rnorm(n, mx)
  u <- mu + rho * (x - mx) + sqrt(1 - rho^2) * stats::rnorm(n)
  cbind(x = x, u = u)
}

outcome <- function(Z, t, cell) {
  d <- c(C = 0, A = DELTA_A, B = DELTA_B)[[t]]
  em <- if (t == "C") 0 else cell$beta
  ALPHA + GX * Z[, "x"] + cell$gu * Z[, "u"] + d + em * Z[, "x"] +
    stats::rnorm(nrow(Z), 0, SIGMA)
}

draw <- function(cell) {
  r <- CORR[[cell$corr]]
  ZA <- draw_xu(N_IPD, 0, 0, r[["S"]]); ZC <- draw_xu(N_IPD, 0, 0, r[["S"]])
  ## Aggregate trial. An imposed imbalance shifts the B arm's X by kappa; U
  ## follows X through the target's correlation, as it would when the imbalance
  ## is a draw rather than a design.
  k <- if (cell$kappa == "random") 0 else as.numeric(cell$kappa)
  ZB <- draw_xu(N_AGD, MU_T[["x"]] + k, MU_T[["u"]] + r[["T"]] * k, r[["T"]])
  ZD <- draw_xu(N_AGD, MU_T[["x"]], MU_T[["u"]], r[["T"]])
  if (cell$kappa != "random") {
    ## Impose the arm means exactly, so the factor is the realized imbalance.
    ZB[, "x"] <- ZB[, "x"] - mean(ZB[, "x"]) + MU_T[["x"]] + k
    ZD[, "x"] <- ZD[, "x"] - mean(ZD[, "x"]) + MU_T[["x"]]
  }
  yA <- outcome(ZA, "A", cell); yC <- outcome(ZC, "C", cell)
  yB <- outcome(ZB, "B", cell); yD <- outcome(ZD, "C", cell)
  list(ipd = data.frame(x = c(ZA[, "x"], ZC[, "x"]), u = c(ZA[, "u"], ZC[, "u"]),
                        y = c(yA, yC), A = rep(1:0, each = N_IPD)),
       agd = list(mB = mean(yB), mD = mean(yD), vB = stats::var(yB) / N_AGD,
                  vD = stats::var(yD) / N_AGD, xB = mean(ZB[, "x"]), xD = mean(ZD[, "x"])))
}

## Exponential-tilting weights matching a scalar mean.
w_match <- function(x, target) {
  xc <- x - target
  a <- stats::uniroot(function(a) sum(xc * exp(a * xc)), c(-20, 20), tol = 1e-12)$root
  exp(a * xc)
}

wmean <- function(y, w) {
  m <- sum(w * y) / sum(w)
  c(m = m, v = sum(w^2 * (y - m)^2) / sum(w)^2)
}

## Two-stage MAIC (Remiro-Azocar 2022): inverse propensity weights for arm within
## the IPD trial, multiplied by pooled trial-selection weights.
fit_all <- function(d) {
  I <- d$ipd; G <- d$agd
  agd_est <- G$mB - G$mD; agd_var <- G$vB + G$vD
  xT <- (G$xB + G$xD) / 2
  res <- list()
  con <- function(wA, wC) {
    a <- wmean(I$y[I$A == 1], wA); c0 <- wmean(I$y[I$A == 0], wC)
    ipd <- a[["m"]] - c0[["m"]]
    c(est = agd_est - ipd, se = sqrt(agd_var + a[["v"]] + c0[["v"]]),
      ess_A = sum(wA)^2 / sum(wA^2), ess_C = sum(wC)^2 / sum(wC^2),
      ## post-weighting balance on the unmatched covariate, the design's
      ## candidate diagnostic
      u_diff = sum(wA * I$u[I$A == 1]) / sum(wA) - sum(wC * I$u[I$A == 0]) / sum(wC))
  }
  one <- rep(1, N_IPD)
  res$unadjusted <- con(one, one)
  wp <- w_match(I$x, xT)
  res$pooled <- con(wp[I$A == 1], wp[I$A == 0])
  res$separate <- con(w_match(I$x[I$A == 1], G$xB), w_match(I$x[I$A == 0], G$xD))
  ps <- stats::fitted(stats::glm(A ~ x, family = stats::binomial(), data = I))
  wt <- ifelse(I$A == 1, 1 / ps, 1 / (1 - ps)) * wp
  res$two_stage <- con(wt[I$A == 1], wt[I$A == 0])
  res
}
