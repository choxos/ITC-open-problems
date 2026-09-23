## ---------------------------------------------------------------------------
## CMP-12: within-trial covariance of population-adjusted contrasts from a
## multi-arm individual-data trial.
##
## Network: a three-arm individual-data trial (A, B, C) in the source population,
## MAIC-weighted to the target; aggregate two-arm trials A-vs-C and B-vs-C run in
## the target itself. Continuous outcome
##   y = MU + GAMMA x + d_t + beta_t x + e,  beta_A = 0.
## MAIC uses one weight vector for all arms, so the two adjusted contrasts d_AB
## and d_AC share the A arm and the weights. Their covariance is
##   Var(mu_A-hat) + (shared-weighting term),
## the second vanishing without effect modification (DESIGN.md section 2).
## Methods differ only in the covariance they give the pair:
##   split       each contrast's own sandwich, covariance zero (what splitting a
##               multi-arm trial into pairwise trials implies)
##   fixed       joint sandwich with the weights treated as known
##   stacked     joint M-estimation of weights and arm means
##   drop        the trial removed; the network is the two aggregate trials
## Network estimates by generalized least squares on (d_AB, d_AC).
## ---------------------------------------------------------------------------

MASTER_SEED <- 20260928L
MU <- 0; GAMMA <- 0.5; D <- c(A = 0, B = -0.3, C = -0.5)
N_BC <- 200L; N_AGD <- 200L
N_SIM <- 1000L
LEVELS <- list(em = c(0, 0.3, 0.6), align = c("same", "opposite"),
               shift = c(0.3, 0.8), nA_ratio = c(0.5, 1, 2))

build_grid <- function() {
  g <- expand.grid(em = LEVELS$em, align = LEVELS$align, shift = LEVELS$shift,
                   nA_ratio = LEVELS$nA_ratio, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g <- g[!(g$em == 0 & g$align == "opposite"), ]
  g$cell <- seq_len(nrow(g)); g
}
betas <- function(cell) c(A = 0, B = cell$em, C = if (cell$align == "same") cell$em else -cell$em)

## True contrasts in the target, x ~ N(shift, 1).
truth <- function(cell) {
  b <- betas(cell); s <- cell$shift
  c(AB = D[["B"]] - D[["A"]] + (b[["B"]] - b[["A"]]) * s,
    AC = D[["C"]] - D[["A"]] + (b[["C"]] - b[["A"]]) * s,
    BC = D[["C"]] - D[["B"]] + (b[["C"]] - b[["B"]]) * s)
}

draw <- function(cell) {
  b <- betas(cell)
  nA <- round(N_BC * cell$nA_ratio)
  arm <- rep(c("A", "B", "C"), c(nA, N_BC, N_BC))
  x <- stats::rnorm(length(arm))
  y <- MU + GAMMA * x + D[arm] + b[arm] * x + stats::rnorm(length(arm))
  agd <- function(t1, t0) {
    x1 <- stats::rnorm(N_AGD, cell$shift); x0 <- stats::rnorm(N_AGD, cell$shift)
    y1 <- MU + GAMMA * x1 + D[[t1]] + b[[t1]] * x1 + stats::rnorm(N_AGD)
    y0 <- MU + GAMMA * x0 + D[[t0]] + b[[t0]] * x0 + stats::rnorm(N_AGD)
    c(est = mean(y1) - mean(y0), var = stats::var(y1) / N_AGD + stats::var(y0) / N_AGD)
  }
  list(ipd = data.frame(x = x, y = y, arm = arm, stringsAsFactors = FALSE),
       AC = agd("C", "A"), BC = agd("C", "B"))
}

## Estimating equations, theta = (alpha, mu_A, mu_B, mu_C). Weights
## exp(alpha (x - m_T)) match the target mean m_T of x.
ee <- function(th, I, mT) {
  w <- exp(th[1] * (I$x - mT))
  cbind(w * (I$x - mT),
        sapply(c("A", "B", "C"), function(a) w * (I$arm == a) * (I$y - th[1 + match(a, c("A", "B", "C"))])))
}

fit_ipd <- function(I, mT) {
  a <- stats::uniroot(function(a) sum((I$x - mT) * exp(a * (I$x - mT))), c(-20, 20), tol = 1e-12)$root
  w <- exp(a * (I$x - mT))
  mu <- sapply(c("A", "B", "C"), function(t) sum(w[I$arm == t] * I$y[I$arm == t]) / sum(w[I$arm == t]))
  th <- c(a, mu)
  U <- ee(th, I, mT)
  Bm <- crossprod(U)
  Am <- numDeriv::jacobian(function(t) colSums(ee(t, I, mT)), th)
  V_stack <- solve(Am) %*% Bm %*% t(solve(Am))
  ## weights known: drop the first equation and its parameter
  Af <- Am[-1, -1, drop = FALSE]; Bf <- Bm[-1, -1, drop = FALSE]
  V_fixed <- matrix(0, 4, 4); V_fixed[-1, -1] <- solve(Af) %*% Bf %*% t(solve(Af))
  L <- rbind(AB = c(0, -1, 1, 0), AC = c(0, -1, 0, 1))
  list(est = drop(L %*% th), V_stack = L %*% V_stack %*% t(L), V_fixed = L %*% V_fixed %*% t(L),
       ess = sum(w)^2 / sum(w^2))
}

## Generalized least squares on basic parameters (d_AB, d_AC).
gls <- function(y, V, X) {
  Vi <- solve(V); S <- solve(t(X) %*% Vi %*% X)
  list(b = drop(S %*% t(X) %*% Vi %*% y), S = S)
}

fit_all <- function(cell, d) {
  f <- fit_ipd(d$ipd, cell$shift)
  z <- stats::qnorm(0.975)
  out <- list()
  ## aggregate rows: AC = d_AC, BC = d_AC - d_AB
  Xa <- rbind(c(0, 1), c(-1, 1)); ya <- c(d$AC[["est"]], d$BC[["est"]])
  Va <- diag(c(d$AC[["var"]], d$BC[["var"]]))
  Lq <- rbind(AB = c(1, 0), AC = c(0, 1), BC = c(-1, 1))
  covs <- list(split = diag(diag(f$V_stack)), fixed = f$V_fixed, stacked = f$V_stack)
  for (m in names(covs)) {
    V <- rbind(cbind(covs[[m]], matrix(0, 2, 2)), cbind(matrix(0, 2, 2), Va))
    g <- gls(c(f$est, ya), V, rbind(diag(2), Xa))
    q <- drop(Lq %*% g$b); se <- sqrt(diag(Lq %*% g$S %*% t(Lq)))
    out[[m]] <- c(q, se = se)
    ## the trial alone
    qi <- c(f$est, f$est[2] - f$est[1]); si <- sqrt(c(diag(covs[[m]]), sum(c(-1, 1) * (covs[[m]] %*% c(-1, 1)))))
    out[[paste0(m, "_trial")]] <- c(qi, se = si)
  }
  g <- gls(ya, Va, Xa)
  q <- drop(Lq %*% g$b); se <- sqrt(diag(Lq %*% g$S %*% t(Lq)))
  out$drop <- c(q, se = se)
  res <- do.call(rbind, lapply(names(out), function(m) data.frame(method = m,
    contrast = c("AB", "AC", "BC"), est = out[[m]][1:3], se = out[[m]][4:6])))
  attr(res, "raw") <- c(f$est, ess = f$ess)
  res
}
