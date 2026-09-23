## ---------------------------------------------------------------------------
## EST-06: the MAIC paradox. Two trials, A versus C in population F_A and B versus
## C in population F_B, analyzed by two sponsors on the same data: sponsor A holds
## A's individual data and targets F_B; sponsor B holds B's and targets F_A.
##
## Continuous outcome y = G'x + d_t + beta x1 1[t = B] + e, two covariates, only B
## modified by x1. The B-versus-A effect in population F is
##   Delta(F) = (d_B - d_A) + beta mean_F(x1),
## so the two sponsors' targets have opposite signs exactly when the zero-effect
## point x1* = -(d_B - d_A) / beta lies between the two populations' x1 means.
## With linear modification the average of the two native effects equals the effect
## in a population whose x1 mean is the midpoint.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20260929L
G <- c(0.5, 0.5)                 # prognostic coefficients
D_A <- 0; D_C <- 0
N_SIM <- 1000L
LEVELS <- list(sep = c(0.5, 1, 1.5),            # x1 mean of F_B minus F_A, in SD
               beta = c(0.2, 0.4, 0.6),
               position = c("between", "at_A", "outside"),
               sizes = c("equal", "3to1"),
               sets = c("common", "differing"))

build_grid <- function() {
  g <- expand.grid(sep = LEVELS$sep, beta = LEVELS$beta, position = LEVELS$position,
                   sizes = LEVELS$sizes, sets = LEVELS$sets, KEEP.OUT.ATTRS = FALSE,
                   stringsAsFactors = FALSE)
  ## Controls: no modification, and no separation.
  ctl <- expand.grid(sep = c(0, 1), beta = c(0, 0.4), position = "between",
                     sizes = "equal", sets = "common", KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  ctl <- ctl[ctl$sep == 0 | ctl$beta == 0, ]
  g <- rbind(g, ctl); g$cell <- seq_len(nrow(g)); g
}

means <- function(cell) list(A = c(-cell$sep / 2, 0), B = c(cell$sep / 2, 0))

## d_B chosen so the zero-effect point x1* sits where the position factor says.
d_B <- function(cell) {
  if (cell$beta == 0) return(0.2)
  xs <- switch(cell$position, between = 0.1 * cell$sep, at_A = -cell$sep / 2,
               outside = cell$sep / 2 + 0.5)
  -cell$beta * xs
}

delta_at <- function(cell, x1) d_B(cell) - D_A + cell$beta * x1
truth <- function(cell) {
  m <- means(cell)
  c(F_A = delta_at(cell, m$A[1]), F_B = delta_at(cell, m$B[1]), F_D = delta_at(cell, 0))
}

arm_n <- function(cell) if (cell$sizes == "equal") c(A = 200L, B = 200L) else c(A = 300L, B = 100L)

gen <- function(n, mu, t, cell) {
  X <- cbind(stats::rnorm(n, mu[1]), stats::rnorm(n, mu[2]))
  d <- c(A = D_A, B = d_B(cell), C = D_C)[[t]]
  y <- drop(X %*% G) + d + (t == "B") * cell$beta * X[, 1] + stats::rnorm(n)
  list(X = X, y = y)
}

draw <- function(cell) {
  m <- means(cell); n <- arm_n(cell)
  list(A1 = gen(n[["A"]], m$A, "A", cell), A0 = gen(n[["A"]], m$A, "C", cell),
       B1 = gen(n[["B"]], m$B, "B", cell), B0 = gen(n[["B"]], m$B, "C", cell))
}

maic_w <- function(X, target) {
  Xc <- sweep(X, 2, target)
  f <- function(a) sum(exp(Xc %*% a))
  gr <- function(a) colSums(Xc * as.vector(exp(Xc %*% a)))
  o <- stats::optim(rep(0, ncol(Xc)), f, gr, method = "BFGS", control = list(reltol = 1e-14))
  as.vector(exp(Xc %*% o$par))
}

## Weighted A-versus-C (or B-versus-C) contrast in an individual-data trial, with
## weights to a target on the chosen columns, and its sandwich variance.
wcon <- function(t1, t0, target, cols) {
  X <- rbind(t1$X, t0$X); y <- c(t1$y, t0$y); a <- rep(1:0, c(length(t1$y), length(t0$y)))
  w <- if (length(cols)) maic_w(X[, cols, drop = FALSE], target[cols]) else rep(1, length(y))
  m1 <- sum(w[a == 1] * y[a == 1]) / sum(w[a == 1]); m0 <- sum(w[a == 0] * y[a == 0]) / sum(w[a == 0])
  v <- sum(w[a == 1]^2 * (y[a == 1] - m1)^2) / sum(w[a == 1])^2 +
       sum(w[a == 0]^2 * (y[a == 0] - m0)^2) / sum(w[a == 0])^2
  c(est = m1 - m0, var = v)
}
agg <- function(t1, t0) c(est = mean(t1$y) - mean(t0$y),
                          var = stats::var(t1$y) / length(t1$y) + stats::var(t0$y) / length(t0$y))

fit_all <- function(cell, d) {
  xA <- colMeans(rbind(d$A1$X, d$A0$X)); xB <- colMeans(rbind(d$B1$X, d$B0$X))
  ## Sponsor A: A's individual data weighted to F_B, B's published contrast.
  cA <- wcon(d$A1, d$A0, xB, 1:2); bB <- agg(d$B1, d$B0)
  sA <- c(est = bB[["est"]] - cA[["est"]], var = bB[["var"]] + cA[["var"]])
  ## Sponsor B: B's individual data weighted to F_A, A's published contrast.
  ## With differing sets, sponsor B adjusts for x2 only and omits the modifier.
  colsB <- if (cell$sets == "common") 1:2 else 2L
  cB <- wcon(d$B1, d$B0, xA, colsB); aA <- agg(d$A1, d$A0)
  sB <- c(est = cB[["est"]] - aA[["est"]], var = cB[["var"]] + aA[["var"]])
  ## Both individual data sets, both transported to the declared F_D (x means 0).
  cA_D <- wcon(d$A1, d$A0, c(0, 0), 1:2); cB_D <- wcon(d$B1, d$B0, c(0, 0), 1:2)
  sD <- c(est = cB_D[["est"]] - cA_D[["est"]], var = cB_D[["var"]] + cA_D[["var"]])
  avg <- c(est = (sA[["est"]] + sB[["est"]]) / 2, var = NA)
  rbind(sponsorA = sA, sponsorB = sB, transportD = sD, average = avg)
}
