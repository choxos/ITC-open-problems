## ---------------------------------------------------------------------------
## MOD-10: a flexible treatment-effect surface inside a multilevel network
## likelihood, integrated over a target partly outside the source support.
##
## Six studies of A versus C, 150 per arm, one covariate x with a uniform law per
## study inside the support S = [-1, 1]: two with individual data, x ~ U(-1, 0.6)
## and U(-0.6, 1); four with arm means only, x ~ U(-1, -0.2), U(-0.6, 0.2),
## U(-0.2, 0.6), U(0.2, 1). Continuous outcome
##   y = MU_s + 0.3 x + A tau(x) + e,  e ~ N(0, 1),
##   linear   tau = -0.5 + 0.3 x
##   hinge    tau = -0.5 + 0.3 x + 0.8 max(x, 0)           (continues past S)
##   plateau  tau = hinge(min(x, 1))                        (flat past S)
## Hinge and plateau coincide on S, so no data distinguish them.
## Target: x ~ (1 - PI) U(0.5, 1) + PI U(1, 2); PI is the unsupported mass.
## Estimand: target mean difference, the integral of tau over the target.
## Identity link, so the multilevel likelihood of an arm mean is exactly a linear
## functional of the individual model: each aggregate row carries the surface
## averaged over Q quadrature points of its study's law (mgcv's summation
## convention), with weight n_arm on the shared residual variance.
## Methods: par (linear treatment interaction, weighted least squares);
## spline (thin-plate smooth, REML, K knots spanning S, so a natural cubic spline
## that extrapolates linearly past S with its boundary slope); gp (low-rank
## Gaussian-process smooth, mgcv bs = "gp" at its default Matern 3/2 covariance with
## range 2, the knot span, plus a linear trend; same knots, REML); spline_gated
## (the spline held at its boundary value past S). Each integrated over the target by midpoint quadrature, which is
## exact for tau linear between the knots, so the supported and unsupported
## parts of the bias separate exactly.
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(mgcv))
MASTER_SEED <- 20261310L; N_ARM <- 150L; N_SIM <- 1000L; Q <- 64L; K <- 10L; KNOTS <- seq(-1, 1, length.out = K)
LAW <- rbind(c(-1, 0.6), c(-0.6, 1), c(-1, -0.2), c(-0.6, 0.2), c(-0.2, 0.6), c(0.2, 1)); IPD <- 1:2
MU <- c(0, 0.2, -0.1, 0.1, 0.3, -0.2)
build_grid <- function() { g <- rbind(expand.grid(shape = c("linear", "hinge"), pi = c(0, 0.05, 0.2), stringsAsFactors = FALSE),
  expand.grid(shape = "plateau", pi = c(0.05, 0.2), stringsAsFactors = FALSE)); g$cell <- seq_len(nrow(g)); g }
tau <- function(x, shape) { if (shape == "plateau") x <- pmin(x, 1); -0.5 + 0.3 * x + if (shape == "linear") 0 else 0.8 * pmax(x, 0) }
mid <- function(a, b) a + (b - a) * (seq_len(Q) - 0.5) / Q
TGT <- list(S = mid(0.5, 1), U = mid(1, 2))
twt <- function(cell) list(S = rep((1 - cell$pi) / Q, Q), U = rep(cell$pi / Q, Q))
truth <- function(cell) { w <- twt(cell); sum(w$S * tau(TGT$S, cell$shape)) + sum(w$U * tau(TGT$U, cell$shape)) }

## Individual rows for the IPD studies; arm means for the others, with their laws'
## quadrature points in the rows of X and the averaging weights in L.
draw <- function(cell) {
  rows <- lapply(seq_len(nrow(LAW)), function(s) { x <- stats::runif(2 * N_ARM, LAW[s, 1], LAW[s, 2]); A <- rep(0:1, each = N_ARM)
    y <- MU[s] + 0.3 * x + A * tau(x, cell$shape) + stats::rnorm(2 * N_ARM)
    if (s %in% IPD) list(y = y, A = A, X = matrix(x, length(x), Q), L = cbind(1, matrix(0, length(x), Q - 1)), w = rep(1, length(x)), s = rep(s, length(x)))
    else list(y = c(mean(y[A == 0]), mean(y[A == 1])), A = 0:1, X = matrix(mid(LAW[s, 1], LAW[s, 2]), 2, Q, byrow = TRUE),
              L = matrix(1 / Q, 2, Q), w = rep(N_ARM, 2), s = rep(s, 2)) })
  cat_ <- function(k) do.call(rbind, lapply(rows, `[[`, k)); vec <- function(k) unlist(lapply(rows, `[[`, k))
  X <- cat_("X"); L <- cat_("L"); A <- vec("A")
  list(y = vec("y"), A = A, xbar = rowSums(X * L), X = X, LA = L * A, w = vec("w"), s = factor(vec("s")))
}

## Surface estimates integrated over the target's supported and unsupported
## parts separately, with a delta-method SE for the total.
one_rep <- function(cell) {
  d <- draw(cell); tw <- twt(cell); out <- list(); tm <- c()
  tm["par"] <- system.time(f0 <- stats::lm(y ~ s + xbar + A + A:xbar, data = d, weights = w))[["user.self"]]
  b <- stats::coef(f0); V <- stats::vcov(f0); ia <- c("A", "xbar:A")
  lin <- function(x) cbind(1, x); est_par <- function(x, ww) sum(ww * drop(lin(x) %*% b[ia]))
  gl <- colSums(tw$S * lin(TGT$S)) + colSums(tw$U * lin(TGT$U))
  out$par <- c(est_par(TGT$S, tw$S), est_par(TGT$U, tw$U), sqrt(drop(t(gl) %*% V[ia, ia] %*% gl)))
  for (m in c("spline", "gp")) { bsm <- if (m == "gp") "gp" else "tp"
    tm[m] <- system.time(f <- mgcv::gam(y ~ s + xbar + s(X, by = LA, k = K, bs = bsm), data = d, weights = w, method = "REML",
                                        knots = list(X = KNOTS)))[["user.self"]]
    cols <- f$smooth[[1]]$first.para:f$smooth[[1]]$last.para
    B <- function(x) { nd <- list(s = factor(rep(1, length(x)), levels = levels(d$s)), xbar = rep(0, length(x)), X = matrix(x, ncol = 1), LA = matrix(1, length(x), 1))
      stats::predict(f, nd, type = "lpmatrix")[, cols, drop = FALSE] }
    ev <- function(xS, xU) { BS <- B(xS); BU <- B(xU); g <- colSums(tw$S * BS) + colSums(tw$U * BU)
      c(sum(tw$S * drop(BS %*% stats::coef(f)[cols])), sum(tw$U * drop(BU %*% stats::coef(f)[cols])), sqrt(drop(t(g) %*% f$Vp[cols, cols] %*% g))) }
    out[[m]] <- ev(TGT$S, TGT$U)
    if (m == "spline") out$spline_gated <- ev(TGT$S, pmin(TGT$U, 1))
  }
  tm["spline_gated"] <- NA
  data.frame(method = names(out), est_S = sapply(out, `[`, 1), est_U = sapply(out, `[`, 2), se = sapply(out, `[`, 3),
             cpu = tm[names(out)], row.names = NULL)
}
