## Data-generating mechanism.
##
## Two randomized trials sharing comparator C. The source trial (A vs C) supplies
## individual patient data. The target trial (B vs C) supplies a baseline table
## and its own treatment effect. The analysis transports the source A vs C effect
## to the target population and anchors on C.
##
## THE OUTCOME IS CONTINUOUS AND THE LINK IS THE IDENTITY. That is deliberate and
## it is the study's largest restriction. It removes non-collapsibility, so the
## marginal and conditional treatment effects coincide and the realized error of
## an estimate decomposes exactly into a covariate-adjustment bias and a Monte
## Carlo noise term. A study asking whether a diagnostic predicts realized error
## needs realized error to have a clean decomposition; on the log-odds scale part
## of the error would be a collapsibility artifact that no covariate diagnostic is
## about. The study therefore says nothing about diagnostics under non-collapsible
## effect measures, and the protocol says so.
##
## THE TARGET'S REPORTED MOMENTS ARE ITS SUPERPOPULATION MOMENTS, not sample
## moments. Study 1 of this program (MIS-03) measured what target-moment sampling
## error costs. Carrying it here would add a noise channel that no source-side
## diagnostic can observe, and would depress every discrimination measure by a
## common factor without changing which diagnostic beats which. It is excluded on
## purpose and recorded as an exclusion.
##
## Three bias channels are built in, and they differ in whether a diagnostic could
## in principle see them. That difference is the study.
##
##   omitted    a genuine effect modifier X4 is left out of the adjustment set.
##              X4 is measured in the source, so its treatment interaction is
##              estimable there; whether the target reports its mean decides
##              whether any diagnostic has the information to catch this.
##   joint      the modifier function contains an X1 X2 term and the source and
##              target differ in that correlation. Matching marginal means and
##              standard deviations does not match a cross-moment, so this bias is
##              invisible to every balance diagnostic in routine use, by
##              construction and not by bad luck.
##   overlap    the target mean is displaced from the source mean, so the weights
##              must extrapolate. This channel moves effective sample size and
##              bias together, which is what gives effective sample size its only
##              real chance of predicting bias.
##
## The first two channels are switched by factors, so the design contains cells
## with poor overlap and no bias and cells with good overlap and large bias. A
## design in which overlap alone drove everything would make effective sample size
## look like a bias diagnostic when it is a variance diagnostic.

P <- 4L                                  # X1, X2, X3 adjusted for; X4 is not
X_NAMES <- c("X1", "X2", "X3", "X4")
MATCHED <- 1:3                           # the analyst's adjustment set

## Source and target covariate covariances. Unit variances throughout, so a
## standardized mean difference is a raw mean difference and the overlap factor
## reads directly in standard deviations.
RHO_12_SOURCE <- 0.30
RHO_12_TARGET <- 0.70                    # the cross-moment the weights cannot match
RHO_13 <- 0.20
RHO_23 <- 0.20

cov_matrix <- function(rho12, rho4, sdv = 1) {
  R <- diag(P)
  R[1, 2] <- R[2, 1] <- rho12
  R[1, 3] <- R[3, 1] <- RHO_13
  R[2, 3] <- R[3, 2] <- RHO_23
  R[4, 1:3] <- R[1:3, 4] <- rho4
  s <- rep(sdv, P)
  diag(s) %*% R %*% diag(s)
}

## Reject a factor combination whose covariance is not a covariance. With rho4 up
## to 0.5 and the block above this stays positive definite, but it is checked
## rather than assumed.
stopifnot(all(eigen(cov_matrix(RHO_12_SOURCE, 0.5), only.values = TRUE)$values > 0),
          all(eigen(cov_matrix(RHO_12_TARGET, 0.5), only.values = TRUE)$values > 0))

draw_X <- function(n, mu, S) {
  L <- chol(S)
  matrix(stats::rnorm(n * P), n, P) %*% L + rep(mu, each = n)
}

## Prognostic function, common to both trials and to every arm.
BETA_PROG <- c(0.50, 0.30, 0.40, 0.20)
f_prog <- function(X) as.vector(X %*% BETA_PROG)

## Effect modification of A versus C. B versus C is not modified, so the A versus
## B contrast depends on the population through g_A alone and population
## adjustment is doing real work.
GAMMA_MAIN <- c(0.30, -0.20, 0.25)       # on X1, X2, X3, always present
D_A <- 0.40                              # A vs C at X = 0
D_B <- 0.25                              # B vs C, no modification
SIGMA <- 1

## `joint` is the coefficient on X1 X2 and `omit` the coefficient on X4.
g_A <- function(X, joint, omit) {
  as.vector(X[, MATCHED, drop = FALSE] %*% GAMMA_MAIN) +
    joint * X[, 1] * X[, 2] + omit * X[, 4]
}

## True A versus C effect in the TARGET SUPERPOPULATION.
##
## Closed form because everything is linear in X and in the cross-moment:
##   theta_AC(T) = d_A + gamma' mu_T + joint E_T[X1 X2] + omit mu_T4,
## with E_T[X1 X2] = Cov_T(X1, X2) + mu1 mu2.
theta_AC_target <- function(mu, S, joint, omit) {
  D_A + sum(GAMMA_MAIN * mu[MATCHED]) +
    joint * (S[1, 2] + mu[1] * mu[2]) + omit * mu[4]
}

theta_BC_target <- function() D_B

## Reported target baseline table: per-covariate mean and standard deviation, and
## the treatment effect with its standard error. Means and standard deviations are
## the superpopulation values; the effect is estimated from n_T per arm, because a
## published effect is an estimate and pretending otherwise would understate the
## anchored interval.
target_report <- function(mu, S, n_T) {
  list(mean = mu, sd = sqrt(diag(S)), n = n_T,
       theta_BC = stats::rnorm(1, theta_BC_target(), sqrt(2 * SIGMA^2 / n_T)),
       var_BC = 2 * SIGMA^2 / n_T)
}

## One source trial: n_arm participants per arm, 1:1 randomization to A and C.
draw_source <- function(n_arm, S, joint, omit) {
  n <- 2L * n_arm
  X <- draw_X(n, rep(0, P), S)
  A <- rep(c(1L, 0L), each = n_arm)
  Y <- f_prog(X) + A * (D_A + g_A(X, joint, omit)) + stats::rnorm(n, 0, SIGMA)
  list(X = X, A = A, Y = Y, n = n)
}

## The calibration moments the analyst matches on: means and second raw moments of
## the adjustment set. A reported mean and standard deviation together determine
## the first and second raw moments, so this is exactly what a baseline table
## supports.
h_of <- function(X) cbind(X[, MATCHED, drop = FALSE], X[, MATCHED, drop = FALSE]^2)
H_NAMES <- c("X1", "X2", "X3", "X1sq", "X2sq", "X3sq")

m_target <- function(rep) {
  c(rep$mean[MATCHED], rep$sd[MATCHED]^2 + rep$mean[MATCHED]^2)
}

## Everything a replicate needs.
gen_replicate <- function(scen) {
  S_src <- cov_matrix(RHO_12_SOURCE, scen$rho4)
  S_tgt <- cov_matrix(RHO_12_TARGET, scen$rho4, scen$sd_target)
  mu_T <- rep(scen$overlap, P)

  src <- draw_source(scen$n_arm, S_src, scen$joint, scen$omit)
  tr <- target_report(mu_T, S_tgt, scen$n_T)

  list(source = src, target = tr,
       m_T = m_target(tr),
       truth = list(
         theta_AC = theta_AC_target(mu_T, S_tgt, scen$joint, scen$omit),
         theta_BC = theta_BC_target(),
         ## E_T[X1 X2]. No baseline table reports a correlation, so this is the
         ## quantity an analyst provably cannot have; it is carried here only to
         ## compute the oracle.
         target_cross = S_tgt[1, 2] + mu_T[1] * mu_T[2],
         ## The source-population A versus C effect, which is what an unadjusted
         ## comparison estimates. Reported so the study can say how much of the
         ## adjustment problem there was to solve in each cell.
         theta_AC_source = D_A + scen$joint * RHO_12_SOURCE))
}
