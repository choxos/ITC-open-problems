## ---------------------------------------------------------------------------
## ADJ-10: data-driven modifier discovery across few trials.
##
## K trials with N_TOT patients in total (N_TOT / K per trial, half per arm), ten
## candidate covariates x_j ~ N(m_kj, 1) with trial means m_kj ~ N(0, 0.5^2).
## Continuous outcome y = 0.3 sum x + A (-0.5 + BETA sum_{j <= M} x_j + CONF * S_k) + e (BETA 0.2),
## with an unmeasured study-level factor S_k ~ N(0, 1). With confounding, x10's
## trial mean follows S_k (m_k10 = 0.7 S_k + noise), so x10 looks like a modifier
## across trials although it modifies nothing within them.
## Discovery (lasso on the ten interactions; penalty at the minimum cross-validated
## error and by the one-standard-error rule, from the same fit):
##   pooled   y ~ trial + A + x + A:x, one treatment effect
##   within   y ~ trial * A + x + A:x, trial-specific treatment effects
## Scored: power (true modifiers selected), false discoveries (others selected, x10
## separately), stability (Jaccard similarity of the sets from two independent
## replicates), and the error of the target effect (covariate means 0.5, S = 0)
## from least squares with the selected interactions.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261108L; N_TOT <- 2400L; P <- 10L; N_SIM <- 300L; BETA <- 0.2
LEVELS <- list(K = c(3L, 6L, 12L), M = c(1L, 3L), conf = c(0, 0.3))
build_grid <- function() { g <- expand.grid(K = LEVELS$K, M = LEVELS$M, conf = LEVELS$conf, KEEP.OUT.ATTRS = FALSE); g$cell <- seq_len(nrow(g)); g }
truth <- function(cell) -0.5 + BETA * cell$M * 0.5

draw <- function(cell) { n <- N_TOT %/% cell$K; S <- stats::rnorm(cell$K)
  m <- matrix(stats::rnorm(cell$K * P, 0, 0.5), cell$K); if (cell$conf > 0) m[, P] <- 0.7 * S + stats::rnorm(cell$K, 0, 0.3)
  do.call(rbind, lapply(seq_len(cell$K), function(k) { X <- sweep(matrix(stats::rnorm(n * P), n), 2, m[k, ], "+"); A <- rep(0:1, length.out = n)
    y <- 0.3 * rowSums(X) + A * (-0.5 + BETA * rowSums(X[, seq_len(cell$M), drop = FALSE]) + cell$conf * S[k]) + stats::rnorm(n)
    data.frame(trial = k, A = A, X, y = y) })) }

discover <- function(d, within) {
  X <- as.matrix(d[, paste0("X", 1:P)]); tr <- stats::model.matrix(~ factor(trial), d)[, -1, drop = FALSE]
  base <- if (within) cbind(tr, d$A, tr * d$A, X) else cbind(tr, d$A, X)
  Z <- cbind(base, X * d$A); pf <- c(rep(0, ncol(base)), rep(1, P))
  cv <- glmnet::cv.glmnet(Z, d$y, penalty.factor = pf, nfolds = 5)
  lapply(c(min = "lambda.min", `1se` = "lambda.1se"), function(l) { b <- stats::coef(cv, s = l)[-1, 1]; which(tail(b, P) != 0) })
}
target_effect <- function(d, sel, within) {
  X <- as.matrix(d[, paste0("X", 1:P)]); tr <- stats::model.matrix(~ factor(trial), d)[, -1, drop = FALSE]
  Z <- cbind(1, tr, d$A, if (within) tr * d$A, X, X[, sel, drop = FALSE] * d$A); f <- stats::lm.fit(Z, d$y); b <- f$coefficients
  ia <- 1 + ncol(tr) + 1; ib <- if (length(sel)) (ncol(Z) - length(sel) + 1):ncol(Z) else integer(0)
  a0 <- if (within) mean(c(b[ia], b[ia] + b[(ia + 1):(ia + ncol(tr))])) else b[ia]
  a0 + sum(b[ib] * 0.5)
}
one_rep <- function(cell) {
  d1 <- draw(cell); d2 <- draw(cell)
  do.call(rbind, lapply(c(FALSE, TRUE), function(w) { S1 <- discover(d1, w); S2 <- discover(d2, w)
    do.call(rbind, lapply(names(S1), function(k) { s1 <- S1[[k]]; s2 <- S2[[k]]
      jac <- if (length(union(s1, s2))) length(intersect(s1, s2)) / length(union(s1, s2)) else 1
      data.frame(method = if (w) "within" else "pooled", penalty = k, power = mean(seq_len(cell$M) %in% s1), false_disc = sum(!(s1 %in% c(seq_len(cell$M), P))),
                 x10 = as.numeric(P %in% s1), stability = jac, target = target_effect(d1, s1, w)) })) })) }
