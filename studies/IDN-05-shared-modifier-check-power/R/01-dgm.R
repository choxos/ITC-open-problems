## ---------------------------------------------------------------------------
## Data-generating mechanism and the exact truth it implies.
## ---------------------------------------------------------------------------

XN     <- paste0("x", seq_len(K_COV))
CHOL_X <- chol(SIGMA_X)

draw_x <- function(n, mu)
  matrix(rnorm(n * K_COV), n, K_COV) %*% CHOL_X + matrix(mu, n, K_COV, byrow = TRUE)

## --- exact marginal risk ------------------------------------------------------
## The linear predictor is linear in x, so in a target N(mu_T, SIGMA_X) it is
## normal and the marginal risk is a one-dimensional Gaussian integral, taken by
## Gauss-Hermite rather than by simulation.
GH      <- statmod::gauss.quad(41, "hermite")
GH_NODE <- GH$nodes * sqrt(2)
GH_WT   <- GH$weights / sqrt(pi)

marginal_risk <- function(mu_T, intercept, a_vec, d_add = 0) {
  m  <- intercept + sum(a_vec * mu_T) + d_add
  s2 <- as.numeric(t(a_vec) %*% SIGMA_X %*% a_vec)
  sum(GH_WT * plogis(m + sqrt(s2) * GH_NODE))
}

## --- the reference intercept that fixes the placebo risk ----------------------
## Solved once per target displacement so that displacing the target moves the
## treatment contrast without also sliding the placebo risk along the logistic
## curve. Without this, M1 would confound effect-modifier extrapolation with a
## changing risk scale.
solve_mu_ref <- function(s) {
  f <- function(m) marginal_risk(target_mean(s), m, BETA) - P_REF
  uniroot(f, c(-8, 8), tol = 1e-12)$root
}
MU_REF <- vapply(TARGET_SHIFT, solve_mu_ref, numeric(1))
names(MU_REF) <- as.character(TARGET_SHIFT)

## Study intercepts are centred on the displacement-0 solution, which is the
## population the network itself is drawn from.
MU_MEAN <- MU_REF[["0"]]

lin_pred <- function(X, trt, mu_j, gam, re = NULL) {
  eta <- mu_j + as.vector(X %*% BETA)
  act <- trt != TRT_REF
  if (any(act)) {
    tk <- trt[act]
    gk <- gam[tk, , drop = FALSE]
    eta[act] <- eta[act] + D_ACT + rowSums(X[act, , drop = FALSE] * gk) +
      if (is.null(re)) 0 else re[tk]
  }
  eta
}

## --- one network -------------------------------------------------------------
make_network_data <- function(scen) {
  gam   <- gamma_true(scen$drift)
  J     <- scen$n_studies
  n_ipd <- N_IPD
  agd_active <- agd_allocation(J, n_ipd)

  ## Random treatment effects are study-specific deviations on the active arms,
  ## drawn independently per study and treatment with SD tau_re.
  re_for_study <- function() {
    if (scen$tau_re == 0) return(setNames(rep(0, length(TRT_ACTIVE)), TRT_ACTIVE))
    setNames(rnorm(length(TRT_ACTIVE), 0, scen$tau_re), TRT_ACTIVE)
  }

  ipd_rows <- lapply(seq_len(n_ipd), function(j) {
    mu_j  <- rnorm(1, MU_MEAN, MU_SD)
    delta <- rnorm(K_COV, 0, scen$spread)
    trt   <- rep(c(TRT_REF, IPD_ACTIVE), each = N_IPD_ARM)
    X     <- draw_x(length(trt), delta)
    d <- data.frame(study = sprintf("IPD%02d", j), trt = trt,
                    trtclass = ifelse(trt == TRT_REF, "ref", "active"),
                    r = rbinom(length(trt), 1,
                               plogis(lin_pred(X, trt, mu_j, gam, re_for_study()))))
    for (k in seq_len(K_COV)) d[[XN[k]]] <- X[, k]
    d
  })

  agd_rows <- lapply(seq_along(agd_active), function(j) {
    mu_j  <- rnorm(1, MU_MEAN, MU_SD)
    delta <- rnorm(K_COV, 0, scen$spread)
    re    <- re_for_study()
    do.call(rbind, lapply(c(TRT_REF, agd_active[j]), function(t) {
      X <- draw_x(N_AGD_ARM, delta)
      y <- rbinom(N_AGD_ARM, 1,
                  plogis(lin_pred(X, rep(t, N_AGD_ARM), mu_j, gam, re)))
      d <- data.frame(study = sprintf("AgD%02d", j), trt = t,
                      trtclass = ifelse(t == TRT_REF, "ref", "active"),
                      r = sum(y), n = N_AGD_ARM)
      ## the aggregate summaries a publication reports: means and SDs only.
      ## multinma reconstructs the joint distribution using a correlation matrix
      ## estimated from the individual-level studies, which is how it is done in
      ## practice; 05-analyze.R reports how far that estimate falls from the truth.
      for (k in seq_len(K_COV)) {
        d[[paste0(XN[k], "_mean")]] <- mean(X[, k])
        d[[paste0(XN[k], "_sd")]]   <- sd(X[, k])
      }
      d
    }))
  })

  list(ipd = do.call(rbind, ipd_rows), agd = do.call(rbind, agd_rows),
       n_agd_by_trt = table(factor(agd_active, levels = TRT_ACTIVE)))
}

build_network <- function(dat) {
  net <- combine_network(
    set_ipd(dat$ipd, study = study, trt = trt, trt_class = trtclass, r = r),
    set_agd_arm(dat$agd, study = study, trt = trt, trt_class = trtclass,
                r = r, n = n))
  add_integration(net,
                  x1 = distr(qnorm, x1_mean, x1_sd),
                  x2 = distr(qnorm, x2_mean, x2_sd),
                  n_int = N_INT)
}

target_frame <- function(s) {
  d <- data.frame(study = "TARGET")
  mu <- target_mean(s)
  for (k in seq_len(K_COV)) {
    d[[paste0(XN[k], "_mean")]] <- mu[k]
    d[[paste0(XN[k], "_sd")]]   <- 1
  }
  add_integration(d, x1 = distr(qnorm, x1_mean, x1_sd),
                  x2 = distr(qnorm, x2_mean, x2_sd),
                  n_int = N_INT, cor = SIGMA_X)
}

## --- exact truth --------------------------------------------------------------
truth_at <- function(drift, s) {
  gam  <- gamma_true(drift)
  mu_T <- target_mean(s)
  m    <- MU_REF[[as.character(s)]]
  p0 <- marginal_risk(mu_T, m, BETA)                 # equals P_REF by construction
  p  <- vapply(TRT_ACTIVE, function(k)
    marginal_risk(mu_T, m, BETA + gam[k, ], D_ACT), numeric(1))
  ## population-average CONDITIONAL log-odds effect (the average over the target
  ## of individual log-odds ratios). It is NOT the marginal log-odds ratio, and
  ## is not reported as one.
  lor <- vapply(TRT_ACTIVE, function(k) D_ACT + sum(gam[k, ] * mu_T), numeric(1))
  list(p_ref = p0, p_act = p, rd = p - p0,
       rd_CA = unname((p[["C"]] - p0) - (p[["A"]] - p0)),
       lor = lor, lor_CA = unname(lor[["C"]] - lor[["A"]]), mu_ref = m)
}

## --- the margin for the posterior rule ----------------------------------------
## EPS is the interaction contrast that makes the C-versus-A marginal risk
## difference exactly MATERIAL at displacement 1, so a rule with this margin asks
## "is the drift big enough to matter where a target typically sits" rather than
## "is it nonzero".
EPS <- local({
  f <- function(d) abs(truth_at(d, 1.0)$rd_CA) - MATERIAL
  uniroot(f, c(1e-6, 3), tol = 1e-10)$root
})
