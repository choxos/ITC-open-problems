## ---------------------------------------------------------------------------
## COV-14: one individual-data trial of A against four aggregate single-arm
## comparators B1..B4 that report different covariate subsets. Unanchored MAIC.
##
## Outcome, continuous: Y(t) = ALPHA + sum_m c_m x_m + tau_t + e for comparators,
## and the same plus sum_m beta_m x_m for A. Nine independent normal covariates.
## Contrast k targets comparator k's population P_k:
##   Delta_k = tau_Bk - tau_A - sum_m beta_m mu_{m,k}.
## MAIC on a covariate set S_k matches those means exactly and, with independent
## covariates, leaves the others at the IPD mean, so its bias is exact:
##   b_k = sum_{m not in S_k} (c_m + beta_m) (mu_{m,k} - mu_{m,IPD}).
## In an unanchored comparison every prognostic covariate enters, not only the
## modifiers DESIGN.md section 2 wrote down; its zero-modification null control
## therefore cannot hold and is replaced (protocol.md).
##
## Ranking differences carry b_k - b_j. With a common set S, the omitted terms are
## the same covariates, so b_k - b_j = sum_{m not in S} (c_m + beta_m)(mu_{m,k} - mu_{m,j}),
## small when comparator populations are similar.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20260926L
M <- 9L; K <- 4L
N_IPD <- 300L; N_COMP <- 200L
ALPHA <- 0; TAU_A <- 0
MU_IPD <- rep(0, M)
MU_CENTER <- 0.4           # comparator populations sit 0.4 SD from the IPD on average
## Relative outcome coefficients: one strong covariate (m = 1), the rest graded.
C_SHAPE <- c(1, 0.8, 0.6, 0.5, 0.4, 0.4, 0.3, 0.2, 0.2)
BETA_SHAPE <- c(0.5, 0, 0.3, 0, 0, 0.2, 0, 0, 0)   # A's effect modifiers
N_SIM <- 1000L

LEVELS <- list(pattern = c("fawsitt", "random", "adversarial"),
               strength = c(0.1, 0.25, 0.5),
               similarity = c("similar", "dispersed"),
               separation = c("separated", "tied"))
SPREAD <- c(similar = 0.05, dispersed = 0.3)
TAU_B <- list(separated = c(0.6, 0.4, 0.2, 0), tied = c(0.5, 0.45, 0.2, 0))

build_grid <- function() {
  g <- expand.grid(pattern = LEVELS$pattern, strength = LEVELS$strength,
                   similarity = LEVELS$similarity, separation = LEVELS$separation,
                   KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  ## Controls: complete reporting (the two sets coincide), and reporting gaps with
  ## no covariate effect on the outcome (nothing omitted can bias).
  ctl <- rbind(
    expand.grid(pattern = "complete", strength = 0.5, similarity = LEVELS$similarity,
                separation = LEVELS$separation, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE),
    expand.grid(pattern = "fawsitt", strength = 0, similarity = LEVELS$similarity,
                separation = LEVELS$separation, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE))
  g <- rbind(g, ctl)
  g$cell <- seq_len(nrow(g)); g
}

## Comparator covariate means, fixed per cell from a cell-specific seed so a
## replicate's variation is sampling and not population drift.
comparator_means <- function(cell) {
  old <- if (exists(".Random.seed", .GlobalEnv)) get(".Random.seed", .GlobalEnv) else NULL
  set.seed(1000L + cell$cell)
  z <- matrix(stats::rnorm(M * K), M, K)
  if (!is.null(old)) assign(".Random.seed", old, .GlobalEnv)
  MU_CENTER + SPREAD[[cell$similarity]] * z
}

## Which covariates each comparator reports (TRUE = reported).
reported <- function(cell) {
  R <- matrix(TRUE, M, K)
  if (cell$pattern == "complete") return(R)
  if (cell$pattern == "fawsitt") {
    ## Mirrors the reporting gaps of Fawsitt et al.: one covariate missing from two
    ## comparators, a block of four missing from a third.
    R[1, 2:3] <- FALSE; R[5:8, 4] <- FALSE
  } else if (cell$pattern == "adversarial") {
    ## The strongest covariate is unreported by the comparator with the largest
    ## true effect, which is the one a reader would rank first.
    R[1, 1] <- FALSE; R[5:8, 4] <- FALSE
  } else {
    ## Three covariates missing per comparator, drawn once per cell.
    old <- if (exists(".Random.seed", .GlobalEnv)) get(".Random.seed", .GlobalEnv) else NULL
    set.seed(2000L + cell$cell)
    for (k in seq_len(K)) R[sample.int(M, 3), k] <- FALSE
    if (!is.null(old)) assign(".Random.seed", old, .GlobalEnv)
  }
  R
}

coefs <- function(cell) list(c = cell$strength * C_SHAPE, beta = cell$strength * BETA_SHAPE)

truth <- function(cell) {
  mu <- comparator_means(cell); cf <- coefs(cell)
  TAU_B[[cell$separation]] - TAU_A - as.vector(crossprod(cf$beta, mu))
}

## Exact population-level bias of MAIC on set S for contrast k.
exact_bias <- function(cell, S, k) {
  mu <- comparator_means(cell); cf <- coefs(cell)
  om <- !S
  sum(((cf$c + cf$beta) * (mu[, k] - MU_IPD))[om])
}

draw <- function(cell) {
  mu <- comparator_means(cell); cf <- coefs(cell)
  X <- matrix(stats::rnorm(N_IPD * M), N_IPD, M)
  yA <- ALPHA + TAU_A + X %*% (cf$c + cf$beta) + stats::rnorm(N_IPD)
  comp <- lapply(seq_len(K), function(k) {
    Z <- sweep(matrix(stats::rnorm(N_COMP * M), N_COMP, M), 2, mu[, k], "+")
    y <- ALPHA + TAU_B[[cell$separation]][k] + Z %*% cf$c + stats::rnorm(N_COMP)
    list(xbar = colMeans(Z), ybar = mean(y), v = stats::var(as.vector(y)) / N_COMP)
  })
  list(X = X, y = as.vector(yA), comp = comp)
}

maic_w <- function(X, target) {
  if (!length(target)) return(rep(1, nrow(X)))
  Xc <- sweep(X, 2, target)
  f <- function(a) sum(exp(Xc %*% a))
  gr <- function(a) colSums(Xc * as.vector(exp(Xc %*% a)))
  o <- stats::optim(rep(0, ncol(Xc)), f, gr, method = "BFGS",
                    control = list(maxit = 1000, reltol = 1e-14))
  as.vector(exp(Xc %*% o$par))
}

contrast <- function(d, k, S) {
  w <- maic_w(d$X[, S, drop = FALSE], d$comp[[k]]$xbar[S])
  m <- sum(w * d$y) / sum(w); v <- sum(w^2 * (d$y - m)^2) / sum(w)^2
  c(est = d$comp[[k]]$ybar - m, var = d$comp[[k]]$v + v, ess = sum(w)^2 / sum(w^2))
}

## Maximal: each contrast on everything its comparator reports.
## Intersection: every contrast on what all four report.
## Bounded: the maximal estimate with a bias bound for each unreported covariate,
## its coefficient estimated in the IPD and its comparator mean allowed anywhere in
## the range of the other comparators' reported means for it.
fit_all <- function(cell, d) {
  R <- reported(cell)
  I <- apply(R, 1, all)
  cf_hat <- stats::coef(stats::lm(d$y ~ d$X))[-1]
  out <- list()
  for (k in seq_len(K)) {
    mx <- contrast(d, k, R[, k]); ix <- contrast(d, k, I)
    om <- which(!R[, k]); half <- 0
    lo <- hi <- mx[["est"]]
    for (m in om) {
      others <- vapply(which(R[m, ]), function(j) d$comp[[j]]$xbar[m], 0)
      rng <- if (length(others)) range(others) else c(0, 0)
      ## the weighted IPD mean of an unmatched independent covariate stays near 0
      e <- cf_hat[m] * (rng - mean(d$X[, m]))
      lo <- lo + min(-e); hi <- hi + max(-e)
    }
    z <- stats::qnorm(0.975)
    out[[k]] <- data.frame(k = k, max_est = mx[["est"]], max_se = sqrt(mx[["var"]]),
                           max_ess = mx[["ess"]], int_est = ix[["est"]],
                           int_se = sqrt(ix[["var"]]), int_ess = ix[["ess"]],
                           bnd_lo = lo - z * sqrt(mx[["var"]]), bnd_hi = hi + z * sqrt(mx[["var"]]))
  }
  do.call(rbind, out)
}
