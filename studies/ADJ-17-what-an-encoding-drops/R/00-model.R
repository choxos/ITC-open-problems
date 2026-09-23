## ---------------------------------------------------------------------------
## ADJ-17: what a reconstruction-objective encoding of the covariates drops.
##
## Twenty covariates x ~ N(0, Sigma), Sigma with five strong directions (variance
## 3) and fifteen weak ones (variance 0.1), eigenvectors from a fixed random
## rotation. The treatment effect is modified by one direction v's standardized
## score: y = x'b + a (-0.5 + 0.4 v'x / sd(v'x)) + e, b fixed, e ~ N(0, 1).
## v is a strong direction (high variance share) or a weak one (low share).
## Target: covariate mean shifted by SHIFT standard deviations along v, plus an
## equal shift along one strong direction unrelated to the effect.
## Estimand: target mean difference, -0.5 + 0.4 SHIFT.
## Methods, each STC (linear, treatment interactions) standardized at the target
## means: full (all 20 covariates); pca_k (first k principal components of the
## source covariates, the reconstruction objective); declared (the analyst's
## declared modifier score v'x plus the full main effects).
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261210L; P <- 20L; N_ARM <- 300L; N_SIM <- 1000L
ROT <- local({ set.seed(17); qr.Q(qr(matrix(stats::rnorm(P * P), P))) })
EV <- c(rep(3, 5), rep(0.1, 15)); SIGMA <- ROT %*% diag(EV) %*% t(ROT)
B_PROG <- local({ set.seed(18); stats::rnorm(P, 0, 0.2) })
build_grid <- function() { g <- expand.grid(dir = c("high", "low"), k = c(2L, 5L, 10L), shift = c(0.5, 1), KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE); g$cell <- seq_len(nrow(g)); g }
vdir <- function(dir) ROT[, if (dir == "high") 1 else 12]
truth <- function(cell) -0.5 + 0.4 * cell$shift
target_mean <- function(cell) { v <- vdir(cell$dir); sdv <- sqrt(drop(t(v) %*% SIGMA %*% v)); u <- ROT[, 3]; sdu <- sqrt(drop(t(u) %*% SIGMA %*% u))
  v * cell$shift * sdv / sum(v^2) + u * 0.5 * sdu }
draw <- function(cell) { x <- MASS::mvrnorm(2 * N_ARM, rep(0, P), SIGMA); A <- rep(0:1, each = N_ARM); v <- vdir(cell$dir)
  s <- drop(x %*% v) / sqrt(drop(t(v) %*% SIGMA %*% v))
  list(x = x, A = A, y = drop(x %*% B_PROG) + A * (-0.5 + 0.4 * s) + stats::rnorm(2 * N_ARM)) }
stc <- function(Z, zt, A, y) { f <- stats::lm(y ~ Z * A); b <- stats::coef(f); V <- stats::vcov(f)
  q <- ncol(Z); g <- c(0, rep(0, q), 1, zt); nm <- names(b); g <- g[seq_along(b)]; ok <- !is.na(b)
  c(est = sum(g[ok] * b[ok]), se = sqrt(drop(t(g[ok]) %*% V %*% g[ok]))) }
one_rep <- function(cell) {
  d <- draw(cell); mt <- target_mean(cell); v <- vdir(cell$dir); sdv <- sqrt(drop(t(v) %*% SIGMA %*% v))
  pc <- stats::prcomp(d$x, center = TRUE, scale. = FALSE); R <- pc$rotation[, seq_len(cell$k), drop = FALSE]
  Zp <- scale(d$x, center = pc$center, scale = FALSE) %*% R; zt <- drop((mt - pc$center) %*% R)
  recon <- sum(pc$sdev[seq_len(cell$k)]^2) / sum(pc$sdev^2)
  sc <- drop(d$x %*% v) / sdv
  out <- rbind(full = stc(d$x, mt, d$A, d$y), pca = stc(Zp, zt, d$A, d$y),
               declared = { f <- stats::lm(d$y ~ d$x + d$A + d$A:sc); b <- stats::coef(f); g <- c(0, rep(0, P), 1, sum(mt * v) / sdv); c(est = sum(g * b), se = sqrt(drop(t(g) %*% stats::vcov(f) %*% g))) })
  data.frame(method = rownames(out), est = out[, "est"], se = out[, "se"], recon = recon)
}
