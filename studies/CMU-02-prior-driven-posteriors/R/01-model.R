## The evidence model, exactly.
##
## Every piece of evidence in this network is, or reduces without loss to, a
## normal observation of a linear function of the treatment parameters. Writing
## the stacked evidence as
##
##   z ~ N(H theta, V),
##
## with an independent normal prior theta ~ N(m0, S0), the posterior is exact:
##
##   S = (H' V^-1 H + S0^-1)^-1,   m = S (H' V^-1 z + S0^-1 m0).
##
## Doing it this way rather than by MCMC is a deliberate design choice, not a
## shortcut. The study evaluates diagnostics that are supposed to detect when a
## posterior is driven by its prior. If the posterior were itself a Monte Carlo
## approximation, every diagnostic would carry sampling noise of unknown size and
## a failure to detect could not be separated from a failure to converge. With an
## exact posterior, any failure belongs to the diagnostic. A Stan fit of the same
## model is run on a subset as a check that the reduction is faithful.
##
## Parameters, with A as reference so d_A = gamma_A = 0:
##
##   theta = (d_B, d_C, d_D, gamma_B, gamma_C, gamma_D)

PARS <- c("dB", "dC", "dD", "gB", "gC", "gD")
NP <- length(PARS)

TRUE_D <- c(dB = 0.30, dC = 0.40, dD = 0.35)
TRUE_G <- c(gB = 0.20, gD = 0.10)          # gamma_C is a factor
TAU <- 0.10                                 # between-trial SD of active effects
SIGMA <- 1                                  # residual SD

## Row of H for an aggregate contrast of treatment `t` against A in a trial whose
## covariate mean is mu: the contrast estimates d_t + gamma_t * mu.
row_vs_A <- function(t, mu) {
  r <- numeric(NP)
  r[match(paste0("d", t), PARS)] <- 1
  r[match(paste0("g", t), PARS)] <- mu
  r
}

## Row for a head-to-head contrast t2 minus t1, neither of them A.
row_pair <- function(t1, t2, mu) row_vs_A(t2, mu) - row_vs_A(t1, mu)

## Conditional covariance of the OLS treatment-main-effect and treatment-by-X
## coefficients in a 1:1 randomized trial with `n` per arm and X ~ N(mu, 1).
##
## Derived from the exact design expectation rather than assumed: with
## w = (1, X, T, T X) the information is N E[w w'], and the (T, T X) block of its
## inverse, scaled by sigma^2 / N, is what an individual-data trial contributes.
## Reducing the trial to these two numbers and this matrix loses nothing, because
## they are sufficient for the treatment parameters under this model.
ipd_cov <- function(n_arm, mu, sigma = SIGMA) {
  N <- 2 * n_arm
  ex <- mu; ex2 <- 1 + mu^2
  M <- matrix(c(
    1,      ex,     0.5,    ex / 2,
    ex,     ex2,    ex / 2, ex2 / 2,
    0.5,    ex / 2, 0.5,    ex / 2,
    ex / 2, ex2 / 2, ex / 2, ex2 / 2), 4, 4, byrow = TRUE)
  V <- sigma^2 * solve(M) / N
  V[3:4, 3:4]
}

## Build H and V for one evidence configuration.
##
## `geometry` decides what evidence exists about treatment C, which is the
## treatment whose interaction the study is about.
build_evidence <- function(geometry, n_arm) {
  H <- list(); V <- list(); lab <- character(0)

  add_ipd <- function(t, mu) {
    H[[length(H) + 1L]] <<- rbind(row_vs_A(t, 0), row_vs_A(t, 1) - row_vs_A(t, 0))
    ## The two OLS coefficients estimate (d_t + gamma_t * 0) and gamma_t, i.e.
    ## the main effect at X = 0 and the slope, so the rows above are exactly
    ## the identity on (d_t, gamma_t).
    Vj <- ipd_cov(n_arm, mu)
    Vj[1, 1] <- Vj[1, 1] + TAU^2          # integrating the trial random effect
    V[[length(V) + 1L]] <<- Vj
    lab <<- c(lab, paste0("ipd:A-", t, "@", mu), paste0("ipd:A-", t, ":X@", mu))
  }
  add_agd <- function(t, mu, extra_tau2 = TAU^2) {
    H[[length(H) + 1L]] <<- matrix(row_vs_A(t, mu), 1)
    V[[length(V) + 1L]] <<- matrix(2 / n_arm + extra_tau2, 1, 1)
    lab <<- c(lab, paste0("agd:A-", t, "@", mu))
  }
  add_pair <- function(t1, t2, mu) {
    H[[length(H) + 1L]] <<- matrix(row_pair(t1, t2, mu), 1)
    V[[length(V) + 1L]] <<- matrix(2 / n_arm + 2 * TAU^2, 1, 1)
    lab <<- c(lab, paste0("agd:", t1, "-", t2, "@", mu))
  }

  ## The two anchoring A versus B individual-data trials are present in every
  ## geometry: they are what makes B well identified and C the interesting case.
  add_ipd("B", -0.25); add_ipd("B", 0.25)

  switch(geometry,
    `within-ipd` = { add_ipd("C", -0.25); add_ipd("C", 0.25) },
    `agd-wide`   = for (m in c(-1, -0.714, -0.429, -0.143, 0.143, 0.429, 0.714, 1)) add_agd("C", m),
    `agd-narrow` = for (m in c(-0.15, -0.107, -0.064, -0.021, 0.021, 0.064, 0.107, 0.15)) add_agd("C", m),
    `agd-flat`   = for (m in rep(0, 8)) add_agd("C", m),
    ## No A versus C evidence at all. C is reachable only through D, and the
    ## C-versus-D contrasts identify differences, so gamma_C is identified only
    ## up to what those contrasts and the prior supply.
    disconnected = { for (m in c(-0.75, -0.25, 0.25, 0.75)) add_pair("C", "D", m) },
    stop("unknown geometry: ", geometry))

  ## D always has some direct aggregate evidence, otherwise the disconnected
  ## geometry would have no anchor at all.
  if (geometry != "disconnected") for (m in c(-0.5, 0.5)) add_agd("D", m)
  else for (m in c(-0.5, 0.5)) add_agd("D", m)

  list(H = do.call(rbind, H), V = as.matrix(Matrix::bdiag(V)), labels = lab)
}

PRIORS <- list(
  tight   = list(d = 0.20, g = 0.10),
  regular = list(d = 0.50, g = 0.25),
  weak    = list(d = 2.00, g = 1.00)
)

prior_cov <- function(scale) {
  p <- PRIORS[[scale]]
  diag(c(rep(p$d^2, 3), rep(p$g^2, 3)))
}

## Exact Gaussian posterior.
posterior <- function(z, H, V, S0, m0 = rep(0, NP)) {
  Vi <- solve(V)
  G <- crossprod(H, Vi %*% H)
  S <- solve(G + solve(S0))
  m <- S %*% (crossprod(H, Vi %*% z) + solve(S0) %*% m0)
  list(m = as.vector(m), S = S, G = G)
}

## Design-based weak-direction share for a scalar contrast c'theta.
##
## This is the study's ground truth for "prior-driven", and it is computed from
## H, V and the prior alone, before any outcome is generated. Whiten by the prior,
## diagonalize the likelihood precision in that metric, and ask what share of the
## contrast's posterior variance sits in directions where the likelihood carries
## no more than a quarter of the prior's precision.
##
## It uses nothing from the data and nothing from any diagnostic being evaluated,
## which is what makes the evaluation non-circular.
weak_share <- function(cvec, H, V, S0, cut = 0.25) {
  L <- t(chol(S0))
  G <- crossprod(H, solve(V) %*% H)
  A <- crossprod(L, G %*% L)
  e <- eigen((A + t(A)) / 2, symmetric = TRUE)
  a <- as.vector(crossprod(e$vectors, crossprod(L, cvec)))
  contrib <- a^2 / (1 + pmax(e$values, 0))
  sum(contrib[e$values <= cut]) / sum(contrib)
}

CLASS <- function(w) ifelse(w >= 0.50, "prior-driven",
                     ifelse(w <= 0.10, "data-driven", "intermediate"))

## The decision contrast: target-population marginal C versus B mean difference.
## Delta_CB(mu) = (d_C - d_B) + (gamma_C - gamma_B) mu.
contrast_CB <- function(mu_target) {
  r <- numeric(NP)
  r[match("dC", PARS)] <- 1; r[match("dB", PARS)] <- -1
  r[match("gC", PARS)] <- mu_target; r[match("gB", PARS)] <- -mu_target
  r
}

true_theta <- function(gamma_C) {
  c(TRUE_D[["dB"]], TRUE_D[["dC"]], TRUE_D[["dD"]],
    TRUE_G[["gB"]], gamma_C, TRUE_G[["gD"]])
}

true_delta_CB <- function(gamma_C, mu_target) {
  (TRUE_D[["dC"]] - TRUE_D[["dB"]]) + (gamma_C - TRUE_G[["gB"]]) * mu_target
}

## Generate one evidence vector.
gen_z <- function(H, V, theta) {
  as.vector(H %*% theta) + as.vector(t(chol(V)) %*% stats::rnorm(nrow(V)))
}
