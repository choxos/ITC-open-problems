## ---------------------------------------------------------------------------
## MIS-01: missing values of a matched covariate in the individual-data trial.
##
## Covariates: x1 (matched, partly missing), x2 (matched, observed), u (not in the
## target publication, observed in the trial). Continuous outcome
##   y = G1 x1 + G2 x2 + GU u + A (DELTA + B1 x1 + BU u) + e.
## MAIC balances x1, x2 to the target means. The within-trial contrast A versus C
## is weighted identically in both arms, so a shift in u that complete-case
## deletion causes in both arms cancels unless u modifies the effect (BU != 0),
## and a shift in one arm only does not cancel even when u is purely prognostic.
## DESIGN.md wrote the bias as u's outcome effect times its shift; for an
## anchored, within-trial contrast the operative coefficients are u's
## modification, or its prognostic effect under arm-differential missingness.
##
## Target: x1, x2 ~ N(0.5, 1); u | x as in the source (u = RHO x1 + noise), so
## E_T[u] = RHO * 0.5. Estimand: A versus C mean difference in the target.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261002L
N_ARM <- 250L; RHO <- 0.5
G1 <- 0.5; G2 <- 0.5; GU <- 0.5; DELTA <- -0.4; B1 <- 0.3
M_T <- c(0.5, 0.5)
N_SIM <- 1000L; N_IMP <- 5L
LEVELS <- list(rate = c(0.15, 0.30, 0.50),
               mech = c("MCAR", "MAR_x2", "MAR_u", "MAR_u_armA", "MAR_y", "MNAR_x1"),
               bu = c(0, 0.3))

build_grid <- function() {
  g <- expand.grid(rate = LEVELS$rate, mech = LEVELS$mech, bu = LEVELS$bu,
                   KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$cell <- seq_len(nrow(g)); g
}

truth <- function(cell) DELTA + B1 * M_T[1] + cell$bu * RHO * M_T[1]

draw <- function(cell) {
  n <- 2 * N_ARM; A <- rep(0:1, each = N_ARM)
  x1 <- stats::rnorm(n); x2 <- stats::rnorm(n)
  u <- RHO * x1 + sqrt(1 - RHO^2) * stats::rnorm(n)
  y <- G1 * x1 + G2 * x2 + GU * u + A * (DELTA + B1 * x1 + cell$bu * u) + stats::rnorm(n)
  ## missingness score, standardized, then an intercept giving the target rate
  z <- switch(cell$mech, MCAR = rep(0, n), MAR_x2 = x2, MAR_u = u,
              MAR_u_armA = ifelse(A == 1, 1.5 * u, -Inf), MAR_y = as.vector(scale(y)),
              MNAR_x1 = x1)
  if (cell$mech == "MAR_u_armA") {
    ## all missingness in arm A, at twice the rate, so the overall rate matches
    pr <- rep(0, n)
    a0 <- stats::uniroot(function(a) mean(stats::plogis(a + z[A == 1])) - min(0.95, 2 * cell$rate), c(-20, 20))$root
    pr[A == 1] <- stats::plogis(a0 + z[A == 1])
  } else {
    a0 <- stats::uniroot(function(a) mean(stats::plogis(a + 1.5 * z)) - cell$rate, c(-20, 20))$root
    pr <- stats::plogis(a0 + 1.5 * z)
  }
  miss <- stats::runif(n) < pr
  x1o <- x1; x1o[miss] <- NA
  data.frame(A = A, x1 = x1o, x2 = x2, u = u, y = y)
}

tilt_w <- function(X, m, base = rep(1, nrow(X))) {
  Xc <- sweep(X, 2, m)
  f <- function(a) sum(base * exp(Xc %*% a))
  gr <- function(a) colSums(Xc * as.vector(base * exp(Xc %*% a)))
  a <- stats::optim(rep(0, ncol(Xc)), f, gr, method = "BFGS", control = list(reltol = 1e-14))$par
  base * as.vector(exp(Xc %*% a))
}

contrast <- function(d, w) {
  m1 <- sum(w * d$A * d$y) / sum(w * d$A); m0 <- sum(w * (1 - d$A) * d$y) / sum(w * (1 - d$A))
  v <- sum(w^2 * d$A * (d$y - m1)^2) / sum(w * d$A)^2 + sum(w^2 * (1 - d$A) * (d$y - m0)^2) / sum(w * (1 - d$A))^2
  c(est = m1 - m0, var = v)
}

## Normal-regression imputation with parameter draws (proper MI).
impute <- function(d, form) {
  cc <- !is.na(d$x1)
  X <- stats::model.matrix(form, d)
  f <- stats::lm.fit(X[cc, , drop = FALSE], d$x1[cc])
  df <- sum(cc) - ncol(X); s2 <- sum(f$residuals^2) / df
  XtXi <- chol2inv(qr.R(f$qr))
  lapply(seq_len(N_IMP), function(k) {
    s2k <- s2 * df / stats::rchisq(1, df)
    b <- f$coefficients + drop(t(chol(XtXi * s2k)) %*% stats::rnorm(ncol(X)))
    dd <- d; dd$x1[!cc] <- drop(X[!cc, , drop = FALSE] %*% b) + stats::rnorm(sum(!cc), 0, sqrt(s2k))
    dd
  })
}

rubin <- function(ests) {
  q <- sapply(ests, `[[`, "est"); u <- sapply(ests, `[[`, "var")
  B <- stats::var(q); m <- length(q)
  c(est = mean(q), var = mean(u) + (1 + 1 / m) * B)
}

fit_all <- function(d) {
  out <- list()
  full_ok <- !is.na(d$x1)
  cc <- d[full_ok, ]
  out$complete_case <- contrast(cc, tilt_w(as.matrix(cc[, c("x1", "x2")]), M_T))
  ## Fang et al.: inverse probability of being observed, modeled on everything
  ## always observed, with arm interactions, multiplied into the matching weights.
  pobs <- stats::fitted(suppressWarnings(stats::glm(full_ok ~ (x2 + u + y) * A, family = stats::binomial(), data = d)))
  out$ipw <- contrast(cc, tilt_w(as.matrix(cc[, c("x1", "x2")]), M_T, base = 1 / pobs[full_ok]))
  run_mi <- function(form) rubin(lapply(impute(d, form), function(dd)
    as.list(contrast(dd, tilt_w(as.matrix(dd[, c("x1", "x2")]), M_T)))))
  ## Within each arm (x1, x2, u, y) is jointly normal, so x1 given the rest is
  ## linear with arm-specific coefficients: the congenial model interacts every
  ## predictor with arm. The generic one does not.
  out$mi_congenial <- run_mi(~ (x2 + u + y) * A)
  out$mi_generic <- run_mi(~ x2 + u + y)
  do.call(rbind, lapply(names(out), function(m) data.frame(method = m, est = out[[m]][["est"]],
                                                          se = sqrt(out[[m]][["var"]]))))
}
