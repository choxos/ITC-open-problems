## ---------------------------------------------------------------------------
## MOD-18: a risk score estimated in a prognostic cohort and used as a regressor
## in an individual-data meta-regression of treatment effect on risk.
##
## Covariates X ~ N(0, I_8); true baseline risk (logit) r = -1 + X gamma,
## gamma = (0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0, 0). Prognostic cohort of N_P untreated
## patients: logistic fit gives the score r-hat = X gamma-hat. Uniform shrinkage
## of the slopes is a linear rescaling of r-hat, which the trial intercepts and
## the interaction absorb, so effects at score percentiles are unchanged by it
## (the option is kept in the code but not run). Six trials of 400 per arm, with a trial-level
## calibration shift: logit p = r + cal_k + A theta(r), theta(r) = -0.4 - 0.25 (r + 1).
## Analysis: logistic regression pooled over trials with trial intercepts,
## y ~ trial + r-hat + A + A:r-hat. Estimand: theta at the 10th, 50th and 90th
## percentiles of true risk in the trials' population. Estimate: the fitted
## effect at the same percentiles of r-hat.
## Plug-in SE treats r-hat as data; propagated SE adds the variance across
## bootstrap refits of the prognostic model.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261020L
P <- 8L; GAMMA <- c(0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0, 0); K <- 6L; N_ARM <- 400L; B_BOOT <- 20L; N_SIM <- 500L
Q <- c(0.1, 0.5, 0.9)
LEVELS <- list(n_p = c(300L, 1000L, 5000L), shrink = "none", drift = c(0, 0.5))
build_grid <- function() {
  g <- expand.grid(n_p = LEVELS$n_p, shrink = LEVELS$shrink, drift = LEVELS$drift, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$cell <- seq_len(nrow(g)); g
}
theta <- function(r) -0.4 - 0.25 * (r + 1)
## Percentiles of true risk: r - (-1) is N(0, |gamma|^2).
truth <- function() theta(-1 + sqrt(sum(GAMMA^2)) * stats::qnorm(Q))

draw <- function(cell) {
  Xp <- matrix(stats::rnorm(cell$n_p * P), ncol = P)
  yp <- stats::rbinom(cell$n_p, 1, stats::plogis(-1 + Xp %*% GAMMA))
  n <- 2 * N_ARM * K; X <- matrix(stats::rnorm(n * P), ncol = P); r <- as.vector(-1 + X %*% GAMMA)
  trial <- rep(seq_len(K), each = 2 * N_ARM); A <- rep(rep(0:1, each = N_ARM), K)
  cal <- stats::rnorm(K, 0, cell$drift)[trial]
  y <- stats::rbinom(n, 1, stats::plogis(r + cal + A * theta(r)))
  list(cohort = list(X = Xp, y = yp), trials = list(X = X, trial = trial, A = A, y = y))
}

score_fit <- function(X, y, shrink) {
  f <- stats::glm.fit(cbind(1, X), y, family = stats::binomial())
  b <- f$coefficients
  if (shrink == "uniform") { chi <- f$null.deviance - f$deviance; s <- max(0, (chi - P) / chi); b[-1] <- s * b[-1] }
  b
}
trial_fit <- function(rh, tr) {
  d <- data.frame(y = tr$y, A = tr$A, rh = rh, trial = factor(tr$trial))
  f <- stats::glm(y ~ trial + rh + A + A:rh, family = stats::binomial(), data = d)
  qs <- stats::quantile(rh, Q); nm <- c("A", grep(":", names(stats::coef(f)), value = TRUE)); b <- stats::coef(f)[nm]; V <- stats::vcov(f)[nm, nm]
  est <- b[1] + b[2] * qs; se <- sqrt(V[1, 1] + qs^2 * V[2, 2] + 2 * qs * V[1, 2])
  c(est, se)
}

fit_all <- function(cell, dd) {
  b <- score_fit(dd$cohort$X, dd$cohort$y, cell$shrink)
  base <- trial_fit(as.vector(cbind(1, dd$trials$X) %*% b), dd$trials)
  bt <- t(replicate(B_BOOT, { i <- sample.int(cell$n_p, replace = TRUE)
    bb <- score_fit(dd$cohort$X[i, ], dd$cohort$y[i], cell$shrink)
    trial_fit(as.vector(cbind(1, dd$trials$X) %*% bb), dd$trials)[1:3] }))
  v_between <- apply(bt, 2, stats::var)
  est <- base[1:3]; se_plug <- base[4:6]; se_prop <- sqrt(se_plug^2 + v_between)
  c(est = unname(est), se_plug = unname(se_plug), se_prop = unname(se_prop))
}
