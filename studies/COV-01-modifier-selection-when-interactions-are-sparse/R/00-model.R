## ---------------------------------------------------------------------------
## COV-01: can significance screening find an effect modifier at the strengths
## where omitting it matters, and is balancing on every candidate an alternative?
##
## Source trial A versus C, N_ARM per arm, P independent N(0, 1) candidate
## covariates (P = 6, the reviewed median, or 13, the reviewed maximum).
##   y = 0.3 sum_j x_j + A (-0.5 + BETA x_1) + e,  e ~ N(0, 1).
## One true modifier (x_1) of strength BETA; the rest are prognostic only.
## Target: every covariate mean shifted by DELTA, known as aggregate means.
## Estimand: target mean difference A versus C, -0.5 + BETA DELTA. The mean
## difference is collapsible, so balancing the modifier alone is sufficient and
## the omission bias of any set without x_1 is exactly -BETA DELTA.
## Screening: interactions with p < 0.05 in the full-interaction least-squares
## model of the source trial (all main effects, all P interactions).
## Methods, all on the same replicate:
##   none         unweighted mean difference (omits the modifier)
##   maic_oracle  method-of-moments weights balancing the true modifier set
##   maic_screen  weights balancing the screened set (none if the set is empty)
##   maic_all     weights balancing all P candidates
##   stc_all      full-interaction regression standardized at the target means
## MAIC standard errors: robust sandwich with the weights treated as fixed.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261301L; N_ARM <- 150L; N_SIM <- 1000L; ALPHA <- 0.05; MATERIAL <- 0.1
build_grid <- function() { g <- expand.grid(beta = c(0, 0.1, 0.25, 0.4, 0.6), delta = c(0.2, 0.5), p = c(6L, 13L),
  KEEP.OUT.ATTRS = FALSE); g$cell <- seq_len(nrow(g)); g }
truth <- function(cell) -0.5 + cell$beta * cell$delta

draw <- function(cell) { n <- 2L * N_ARM; X <- matrix(stats::rnorm(n * cell$p), n); A <- rep(0:1, each = N_ARM)
  list(X = X, A = A, y = 0.3 * rowSums(X) + A * (-0.5 + cell$beta * X[, 1]) + stats::rnorm(n)) }

## Method-of-moments weights: minimize log sum exp(Z a), Z the covariates centered at
## the target means. Stops if the balance is not achieved (target outside the hull).
maic_w <- function(Z) { if (ncol(Z) == 0) return(rep(1, nrow(Z)))
  f <- function(a) { u <- drop(Z %*% a); m <- max(u); m + log(sum(exp(u - m))) }
  gr <- function(a) { u <- drop(Z %*% a); w <- exp(u - max(u)); colSums(w * Z) / sum(w) }
  o <- stats::optim(rep(0, ncol(Z)), f, gr, method = "BFGS", control = list(maxit = 500, reltol = 1e-14))
  if (max(abs(gr(o$par))) > 1e-4) stop("weights did not balance")
  w <- exp(drop(Z %*% o$par) - max(drop(Z %*% o$par))); w / mean(w) }
maic_est <- function(w, A, y) { m <- vapply(0:1, function(a) sum(w[A == a] * y[A == a]) / sum(w[A == a]), 0)
  v <- vapply(0:1, function(a) sum(w[A == a]^2 * (y[A == a] - m[a + 1])^2) / sum(w[A == a])^2, 0)
  c(est = m[2] - m[1], se = sqrt(sum(v)), ess = sum(w)^2 / sum(w^2)) }

one_rep <- function(cell) {
  d <- draw(cell); p <- cell$p; n <- length(d$y); Z <- cbind(1, d$X, d$A, d$X * d$A)
  q <- qr(Z); b <- qr.coef(q, d$y); df <- n - ncol(Z); s2 <- sum(qr.resid(q, d$y)^2) / df
  V <- chol2inv(qr.R(q)) * s2; ii <- (p + 3):(2 * p + 2)
  pv <- 2 * stats::pt(-abs(b[ii] / sqrt(diag(V)[ii])), df); sel <- which(pv < ALPHA)
  g <- c(rep(0, p + 1), 1, rep(cell$delta, p)); stc <- c(est = sum(g * b), se = sqrt(drop(t(g) %*% V %*% g)), ess = NA)
  Zt <- d$X - cell$delta; oracle <- if (cell$beta > 0) 1L else integer(0)
  mm <- function(s) tryCatch(maic_est(maic_w(Zt[, s, drop = FALSE]), d$A, d$y), error = function(e) c(est = NA, se = NA, ess = NA))
  out <- rbind(none = mm(integer(0)), maic_oracle = mm(oracle), maic_screen = mm(sel), maic_all = mm(seq_len(p)), stc_all = stc)
  data.frame(method = rownames(out), est = out[, "est"], se = out[, "se"], ess = out[, "ess"], detect = 1L %in% sel,
             n_false = sum(sel != 1L), se_int1 = sqrt(V[ii[1], ii[1]]), df = df,
             set = paste(sel, collapse = "."), row.names = NULL)
}
