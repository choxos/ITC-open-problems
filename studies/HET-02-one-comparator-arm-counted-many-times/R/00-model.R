## ---------------------------------------------------------------------------
## HET-02: matched single-arm studies built against one comparator arm.
##
## Network A, B, C on a continuous outcome (SD 1). Randomized trial 1: B versus C
## (N_C per arm). Randomized trial 2: A versus B (200 per arm). M single-arm
## studies of A (100 patients each), each matched to trial 1's C arm, give
## pseudo-contrasts A_k - C with covariance Var(C arm mean) between every pair.
## True effects: A versus C = 0.15, B versus C = 0.3 (so A versus B = -0.15).
## Fixed-effect network by generalized least squares on basic parameters
## (A versus C, B versus C): with the correct block covariance, or entering the
## pseudo-contrasts as independent (their marginal variances only).
## Estimand: A versus C.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261031L
D_AC <- 0.15; D_BC <- 0.3; N_SIM <- 4000L
LEVELS <- list(M = c(1L, 2L, 4L, 8L), n_c = c(50L, 200L))
build_grid <- function() { g <- expand.grid(M = LEVELS$M, n_c = LEVELS$n_c, KEEP.OUT.ATTRS = FALSE); g$cell <- seq_len(nrow(g)); g }

draw <- function(cell) {
  c1 <- stats::rnorm(1, 0, 1 / sqrt(cell$n_c)); b1 <- stats::rnorm(1, D_BC, 1 / sqrt(cell$n_c))           # trial 1 arm means
  a2 <- stats::rnorm(1, D_AC, 1 / sqrt(200)); b2 <- stats::rnorm(1, D_BC, 1 / sqrt(200))                  # trial 2 arm means (C = 0 scale)
  ak <- stats::rnorm(cell$M, D_AC, 1 / sqrt(100))                                                         # single-arm A studies
  y <- c(b1 - c1, a2 - b2, ak - c1)
  X <- rbind(c(0, 1), c(1, -1), matrix(c(1, 0), cell$M, 2, byrow = TRUE))
  vc <- 1 / cell$n_c
  V <- diag(c(2 * vc, 2 / 200, rep(1 / 100 + vc, cell$M)))
  idx <- 2 + seq_len(cell$M)
  V[1, idx] <- vc; V[idx, 1] <- vc                                                                       # trial 1 contrast shares C with the pseudo-contrasts
  for (i in idx) for (j in idx) if (i != j) V[i, j] <- vc                                              # pseudo-contrasts share C with each other
  list(y = y, X = X, V = V)
}
gls <- function(y, X, V) { W <- solve(V); S <- solve(t(X) %*% W %*% X); b <- drop(S %*% t(X) %*% W %*% y); c(b[1], sqrt(S[1, 1])) }
fit_all <- function(d) { right <- gls(d$y, d$X, d$V); naive <- gls(d$y, d$X, diag(diag(d$V)))
  c(right = right[1], se_right = right[2], naive = naive[1], se_naive = naive[2]) }
