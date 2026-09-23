## ---------------------------------------------------------------------------
## QBA-13: a simulated-covariate bias analysis by STC and by MAIC.
##
## Unanchored: individual data on 300 patients of A; the target publishes x's
## mean (0.5). Unmeasured binary U: P(U = 1 | x) = plogis(a_S + RHO x) with source
## prevalence 0.3; in the target plogis(a_T + RHO x) with true prevalence 0.5.
## logit P(Y = 1) = -1 + 0.5 x + GAMMA U. Estimand: A's marginal log odds in the
## target (the unanchored comparison's A side).
## The analyst assumes RHO and GAMMA (correctly here) and sweeps the target
## prevalence p of U. For each p and M imputations of U from P(U | x, y) in the
## source (Bayes rule with the assumed model):
##   STC:  logistic y ~ x + U per imputation, standardized over target x ~ N(0.5, 1)
##         with U | x at intercept giving prevalence p; Rubin's rules.
##   MAIC: weights balancing the means of x and U (to 0.5 and p); weighted log odds;
##         Rubin's rules. Feasibility and effective sample size recorded.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261105L; N <- 300L; GAMMA <- 0.8; P_S <- 0.3; P_TRUE <- 0.5; M_IMP <- 10L; N_SIM <- 500L
SWEEP <- c(0.1, 0.3, 0.5, 0.7, 0.9)
LEVELS <- list(rho = c(0, 0.8))
build_grid <- function() { g <- data.frame(rho = LEVELS$rho); g$cell <- seq_len(nrow(g)); g }
GH <- statmod::gauss.quad.prob(40, "normal")
int_for <- function(p, rho, mx) stats::uniroot(function(a) sum(GH$weights * stats::plogis(a + rho * (mx + GH$nodes))) - p, c(-20, 20))$root
target_logodds <- function(p, rho) { a <- int_for(p, rho, 0.5); x <- 0.5 + GH$nodes; pu <- stats::plogis(a + rho * x)
  stats::qlogis(sum(GH$weights * (pu * stats::plogis(-1 + 0.5 * x + GAMMA) + (1 - pu) * stats::plogis(-1 + 0.5 * x)))) }
truth <- function(cell) target_logodds(P_TRUE, cell$rho)

draw <- function(cell) { aS <- int_for(P_S, cell$rho, 0); x <- stats::rnorm(N); u <- stats::rbinom(N, 1, stats::plogis(aS + cell$rho * x))
  data.frame(x = x, y = stats::rbinom(N, 1, stats::plogis(-1 + 0.5 * x + GAMMA * u))) }

rubin <- function(e, v) { m <- mean(e); b <- stats::var(e); c(m, sqrt(mean(v) + (1 + 1 / length(e)) * b)) }
fit_all <- function(cell, d) {
  aS <- int_for(P_S, cell$rho, 0); pu <- stats::plogis(aS + cell$rho * d$x)
  l1 <- stats::dbinom(d$y, 1, stats::plogis(-1 + 0.5 * d$x + GAMMA)); l0 <- stats::dbinom(d$y, 1, stats::plogis(-1 + 0.5 * d$x))
  post <- pu * l1 / (pu * l1 + (1 - pu) * l0)                                  # P(U = 1 | x, y) under the assumed model
  imps <- replicate(M_IMP, stats::rbinom(N, 1, post))
  do.call(rbind, lapply(SWEEP, function(p) {
    aT <- int_for(p, cell$rho, 0.5); xs <- 0.5 + GH$nodes; puT <- stats::plogis(aT + cell$rho * xs)
    stc <- t(apply(imps, 2, function(u) { f <- stats::glm(d$y ~ d$x + u, family = stats::binomial()); b <- stats::coef(f)
      pr1 <- stats::plogis(b[1] + b[2] * xs + b[3]); pr0 <- stats::plogis(b[1] + b[2] * xs); q <- sum(GH$weights * (puT * pr1 + (1 - puT) * pr0))
      g <- c(sum(GH$weights * (puT * pr1 * (1 - pr1) + (1 - puT) * pr0 * (1 - pr0))), sum(GH$weights * xs * (puT * pr1 * (1 - pr1) + (1 - puT) * pr0 * (1 - pr0))),
             sum(GH$weights * puT * pr1 * (1 - pr1))) / (q * (1 - q))
      c(stats::qlogis(q), drop(t(g) %*% stats::vcov(f) %*% g)) }))
    mc <- t(apply(imps, 2, function(u) { X <- cbind(d$x - 0.5, u - p)
      if (min(u) == max(u)) return(c(NA, NA, 0, 0))
      o <- tryCatch(stats::optim(c(0, 0), function(a) sum(exp(X %*% a)), function(a) colSums(X * as.vector(exp(X %*% a))), method = "BFGS", control = list(maxit = 500)), error = function(e) NULL)
      if (is.null(o)) return(c(NA, NA, 0, 0)); w <- as.vector(exp(X %*% o$par)); bal <- max(abs(colSums(X * w) / sum(w)))
      if (bal > 1e-3) return(c(NA, NA, 0, 0))
      wn <- w / sum(w); q <- sum(wn * d$y); c(stats::qlogis(q), sum(wn^2 * (d$y - q)^2) / (q * (1 - q))^2, 1, sum(w)^2 / sum(w^2)) }))
    ok <- mc[, 3] == 1
    s <- rubin(stc[, 1], stc[, 2]); m <- if (sum(ok) >= 2) rubin(mc[ok, 1], mc[ok, 2]) else c(NA, NA)
    data.frame(p = p, stc = s[1], se_stc = s[2], maic = m[1], se_maic = m[2], feasible = mean(ok), ess = mean(mc[ok, 4]))
  }))
}
