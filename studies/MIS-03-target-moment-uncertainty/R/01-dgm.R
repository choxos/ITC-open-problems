## Data-generating mechanism.
##
## Two randomized trials sharing a common comparator C. The source trial (A vs C)
## supplies individual patient data. The target trial (B vs C) supplies only what
## a publication would: the arm-level treatment effect, and a baseline table of
## per-covariate means, standard deviations and the sample size.
##
## The point of the study is in one detail. The target trial's participants are
## generated, and then discarded: the estimator sees only sample moments computed
## from those participants. Those sample moments are therefore estimates of the
## target superpopulation moments and carry sampling error of order 1/sqrt(nT).
## Standard population adjustment conditions on them as if they were exact.
##
## Covariates are trivariate normal so that the covariance among the six
## calibration moments has a closed form under the reconstruction method, and so
## the marginal treatment effect has a closed form. Both are deliberate: they let
## the study isolate the variance question from estimation of the truth. They are
## also the study's main limitation, recorded in the protocol.

## Equicorrelation matrix with unit variances.
equicorr <- function(p, rho) {
  m <- matrix(rho, p, p)
  diag(m) <- 1
  m
}

## Draw covariates. `mu` is a scalar shift applied to every covariate, so the
## overlap factor is one number: the standardized mean difference between source
## and target on each covariate.
draw_X <- function(n, mu, rho, p = 3L) {
  L <- chol(equicorr(p, rho))
  Z <- matrix(stats::rnorm(n * p), n, p)
  X <- Z %*% L
  X + rep(mu, each = n)
}

## The six calibration moments per participant: the covariates and their squares.
## Matching on these is matching on the reported means and standard deviations,
## because a mean and an SD together pin down the first and second raw moments.
h_of <- function(X) cbind(X, X^2)

H_NAMES <- c("X1", "X2", "X3", "X1sq", "X2sq", "X3sq")

## Prognostic function, common to both trials. Contains squared terms so that
## reported standard deviations, and not only reported means, carry information
## about the transported effect.
f_prog <- function(X) {
  0.20 + 0.35 * X[, 1] - 0.25 * X[, 2] + 0.20 * X[, 3] +
    0.10 * (X[, 1]^2 - 1) - 0.08 * (X[, 2]^2 - 1) + 0.05 * (X[, 3]^2 - 1)
}

## Unscaled effect-modifying function.
A_LIN <- c(0.30, -0.20, 0.20)     # coefficients on X
A_SQ  <- c(0.15, -0.10, 0.10)     # coefficients on X^2 - 1

g_base <- function(X) {
  as.vector(X %*% A_LIN + (X^2 - 1) %*% A_SQ)
}

## Standard deviation of `g_base` in a target population with covariate means d
## and equicorrelation rho.
##
## This is why effect-modification strength is a calibrated factor rather than a
## fixed coefficient vector. Because the quadratic coefficients are half the
## linear ones, shifting the covariate means multiplies the effective linear
## coefficient by (1 + d): the same coefficients describe an effect modifier of
## SD 0.477 at d = 0 and 0.745 at d = 0.8. Holding the coefficients fixed and
## calling that "varying overlap" would vary effect-modification strength at the
## same time, and any result would be a mixture of the two.
sd_g_base <- function(d, rho) {
  cvec <- c(A_LIN, A_SQ)
  Om <- Omega_normal(rep(d, 3), rep(1, 3), equicorr(3, rho))
  sqrt(as.numeric(cvec %*% Om %*% cvec))
}

## Scale factor giving an effect modifier with the requested SD in the target.
em_scale <- function(em_sd, d, rho) {
  if (em_sd == 0) return(0)
  em_sd / sd_g_base(d, rho)
}

TAU0 <- -0.10

## Conditional treatment effects.
##
##   tau_AC(X) = TAU0 + s * g_base(X)
##   tau_BC(X) = TAU0 + kappa * s * g_base(X)
##
## `s` is set so the modifier has the requested SD in the target population.
## `kappa` is the alignment between the two trials' effect modification, and it
## is the factor that stops the mechanism from deciding the answer.
##
## In the source paper's design only kappa = 0 and kappa = 1 appeared. At
## kappa = 0 the omitted target-moment term is necessarily +Var_T(s g)/nT, so
## every non-null cell shows the interval is too narrow, by construction. At
## kappa = 1 the transported A vs C estimate and the observed B vs C estimate
## move together and the omitted covariance is negative, so the interval is too
## wide. Using only the two endpoints means the sign of the result is specified
## rather than discovered. Varying kappa continuously through 0.5 locates where
## the two contributions cancel, which is a property of the estimator and not of
## the mechanism.
tau_AC <- function(X, s) TAU0 + s * g_base(X)
tau_BC <- function(X, s, kappa) TAU0 + kappa * s * g_base(X)

## True target-superpopulation marginal A vs B mean difference.
##
## E_T[tau_AC] - E_T[tau_BC] = (1 - kappa) * s * E_T[g_base], and with
## X_j ~ N(d, 1), E[X_j] = d and E[X_j^2 - 1] = d^2, so
## E_T[g_base] = (sum A_LIN) d + (sum A_SQ) d^2 = 0.30 d + 0.15 d^2.
## Correlation does not enter because g_base contains no cross-products. The
## outcome is continuous and the effect additive, so marginal and conditional
## effects coincide and no noncollapsibility term appears; that is why this study
## uses a continuous outcome.
true_theta_AB <- function(d, em_sd, kappa, rho_T) {
  s <- em_scale(em_sd, d, rho_T)
  (1 - kappa) * s * (sum(A_LIN) * d + sum(A_SQ) * d^2)
}

## Generate one replicate.
##
## Returns the source IPD, and for the target only what a publication reports:
## the sample size, the per-covariate means and standard deviations, and the
## unadjusted arm-mean difference with its standard error. `hidden` carries the
## target quantities that ordinary reporting does not include; the enhanced
## reporting methods are handed specific pieces of it and nothing else, which is
## how the study measures what extra reporting would buy.
gen_replicate <- function(nS, nT, d, rho_S, rho_T, em_sd, kappa) {
  s <- em_scale(em_sd, d, rho_T)

  ## Source trial: A vs C, equal allocation, covariates centered at zero.
  XS <- draw_X(nS, 0, rho_S)
  AS <- rep(c(1L, 0L), each = nS / 2)          # 1 = A, 0 = C
  YS <- f_prog(XS) + AS * tau_AC(XS, s) + stats::rnorm(nS)

  ## Target trial: B vs C, covariates shifted by d.
  XT <- draw_X(nT, d, rho_T)
  BT <- rep(c(1L, 0L), each = nT / 2)          # 1 = B, 0 = C
  YT <- f_prog(XT) + BT * tau_BC(XT, s, kappa) + stats::rnorm(nT)

  ## What the target publication reports.
  tmean <- colMeans(XT)
  tsd <- apply(XT, 2, stats::sd)
  ## A reported mean and SD determine the second raw moment. The (nT-1)/nT
  ## factor converts the unbiased sample variance a paper reports into the
  ## second central sample moment, so the calibration target is exactly the
  ## sample mean of h(X) and the estimator is not asked to match a quantity the
  ## target sample does not attain.
  m2 <- ((nT - 1) / nT) * tsd^2 + tmean^2
  m_T <- c(tmean, m2)
  names(m_T) <- H_NAMES

  yB <- YT[BT == 1L]; yC <- YT[BT == 0L]
  theta_BC <- mean(yB) - mean(yC)
  var_BC <- stats::var(yB) / length(yB) + stats::var(yC) / length(yC)

  hT <- h_of(XT)
  ## Influence function of the unadjusted target arm-mean difference, per target
  ## participant. Var(phi)/nT reproduces var_BC, which the tests check.
  phi_BC <- (BT / 0.5) * (YT - mean(yB)) - ((1 - BT) / 0.5) * (YT - mean(yC))

  list(
    source = list(X = XS, A = AS, Y = YS, h = h_of(XS)),
    target_reported = list(nT = nT, mean = tmean, sd = tsd, m = m_T,
                           theta_BC = theta_BC, var_BC = var_BC),
    hidden = list(
      ## Covariance of h(X) among target participants. Enhanced reporting: what
      ## a paper would have to publish beyond means and SDs.
      Omega_hh = stats::cov(hT),
      ## The 7 by 7 joint covariance of h(X) and the outcome influence function.
      ## This is the information needed for fully unconditional inference when
      ## the moments and the treatment effect come from the same people.
      Omega_T = stats::cov(cbind(hT, phi_BC = phi_BC))
    )
  )
}
