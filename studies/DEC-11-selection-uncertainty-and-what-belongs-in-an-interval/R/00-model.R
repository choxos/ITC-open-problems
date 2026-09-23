## ---------------------------------------------------------------------------
## DEC-11: coverage of an STC interval computed after selecting effect modifiers
## on the same data.
##
## Source trial A versus C, six independent normal candidates, binary outcome
##   logit p = -0.5 + 0.3 sum_j x_j + A (-0.5 + 0.3 sum_{m in M} x_m).
## Target: covariate means 0.4, SD 1. Estimand: marginal log OR, A versus C, in the
## target. Estimator: G-computation from a logistic model with all six main effects
## and the interactions a rule selects, marginalized over the target law.
## The delta-method interval treats the selected model as fixed. The
## whole-procedure bootstrap reruns the selection in each resample.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261005L
P <- 6L; M_T <- rep(0.4, P); G_POINTS <- 3000L
N_SIM <- 400L; N_BOOT <- 60L; P_KEEP <- 0.2
LEVELS <- list(n = c(100L, 300L, 1000L), n_mod = c(1L, 3L))

build_grid <- function() {
  g <- expand.grid(n = LEVELS$n, n_mod = LEVELS$n_mod, KEEP.OUT.ATTRS = FALSE)
  g$cell <- seq_len(nrow(g)); g
}
mods <- function(cell) seq_len(cell$n_mod)

truth <- function(cell) {
  old <- if (exists(".Random.seed", .GlobalEnv)) get(".Random.seed", .GlobalEnv) else NULL
  set.seed(99)
  X <- sweep(matrix(stats::rnorm(1e6 * P), ncol = P), 2, M_T, "+")
  if (!is.null(old)) assign(".Random.seed", old, .GlobalEnv)
  eta <- -0.5 + 0.3 * rowSums(X)
  em <- 0.3 * rowSums(X[, mods(cell), drop = FALSE])
  stats::qlogis(mean(stats::plogis(eta - 0.5 + em))) - stats::qlogis(mean(stats::plogis(eta)))
}

draw <- function(cell) {
  X <- matrix(stats::rnorm(2 * cell$n * P), ncol = P); A <- rep(0:1, each = cell$n)
  em <- 0.3 * rowSums(X[, mods(cell), drop = FALSE])
  y <- stats::rbinom(2 * cell$n, 1, stats::plogis(-0.5 + 0.3 * rowSums(X) + A * (-0.5 + em)))
  d <- data.frame(y = y, A = A, X); names(d) <- c("y", "A", paste0("x", 1:P)); d
}

ZT <- NULL
target_draws <- function() {
  if (is.null(ZT)) {
    old <- if (exists(".Random.seed", .GlobalEnv)) get(".Random.seed", .GlobalEnv) else NULL
    set.seed(7)
    ZT <<- sweep(matrix(stats::rnorm(G_POINTS * P), ncol = P), 2, M_T, "+")
    if (!is.null(old)) assign(".Random.seed", old, .GlobalEnv)
  }
  ZT
}

form_for <- function(S) stats::as.formula(paste("y ~ A +", paste0("x", 1:P, collapse = " + "),
  if (length(S)) paste0(" + ", paste0("A:x", S, collapse = " + ")) else ""))

## G-computation estimate and delta-method SE for a fitted model.
gcomp <- function(f, S) {
  Z <- target_draws(); b <- stats::coef(f)
  mk <- function(a) { M <- cbind(1, a, Z); if (length(S)) M <- cbind(M, a * Z[, S, drop = FALSE]); M }
  M1 <- mk(1); M0 <- mk(0)
  p1 <- stats::plogis(M1 %*% b); p0 <- stats::plogis(M0 %*% b); q1 <- mean(p1); q0 <- mean(p0)
  g <- colMeans(M1 * as.vector(p1 * (1 - p1))) / (q1 * (1 - q1)) - colMeans(M0 * as.vector(p0 * (1 - p0))) / (q0 * (1 - q0))
  c(est = stats::qlogis(q1) - stats::qlogis(q0), se = sqrt(drop(t(g) %*% stats::vcov(f) %*% g)))
}

## Selection rules. Each returns the interaction set S.
select_sig <- function(d) {
  f <- stats::glm(form_for(1:P), family = stats::binomial(), data = d)
  pv <- summary(f)$coefficients[paste0("A:x", 1:P), 4]
  which(pv < P_KEEP)
}
select_lasso <- function(d) {
  X <- stats::model.matrix(form_for(1:P), d)[, -1]
  pf <- ifelse(grepl("^A:", colnames(X)), 1, 0)
  cv <- glmnet::cv.glmnet(X, d$y, family = "binomial", penalty.factor = pf, nfolds = 5)
  b <- stats::coef(cv, s = "lambda.1se")[-1, 1]
  as.integer(sub("A:x", "", names(b)[grepl("^A:", names(b)) & b != 0]))
}

fit_rule <- function(d, S) gcomp(stats::glm(form_for(S), family = stats::binomial(), data = d), S)

fit_all <- function(cell, d) {
  rules <- list(all = 1:P, oracle = mods(cell), none = integer(0),
                significance = select_sig(d), lasso = select_lasso(d))
  out <- lapply(names(rules), function(r) c(fit_rule(d, rules[[r]]), n_sel = length(rules[[r]]),
                                            hit = all(mods(cell) %in% rules[[r]])))
  names(out) <- names(rules)
  ## whole-procedure bootstrap for the significance rule
  bs <- vapply(seq_len(N_BOOT), function(b) {
    i <- c(sample(which(d$A == 0), replace = TRUE), sample(which(d$A == 1), replace = TRUE))
    db <- d[i, ]; fit_rule(db, select_sig(db))[["est"]] }, 0)
  out$significance_boot <- c(est = out$significance[["est"]], se = stats::sd(bs),
                             n_sel = out$significance[["n_sel"]], hit = out$significance[["hit"]])
  do.call(rbind, lapply(names(out), function(r) data.frame(rule = r, t(out[[r]]))))
}
