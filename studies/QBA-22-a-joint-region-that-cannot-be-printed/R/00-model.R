## ---------------------------------------------------------------------------
## QBA-22: which summary of a joint decision-invariant region should be printed.
##
## Bias model imported from DIA-13 (studies/DIA-13-biases-that-act-together/R/
## 00-model.R, restated here, not sourced): unanchored MAIC of A (individual data)
## against B (aggregate); logit P(Y = 1) = -1 + 0.5 x + g_u U + d B. Source
## x ~ N(0, 1), U ~ Bern(0.3); target x ~ N(0.5, 1), U ~ Bern(0.5). Bias vector
## gamma = (g_u, m, q): omitted confounder effect g_u; comparator outcome
## misclassification, sensitivity 1 - m and specificity 1 - m / 2; reliability
## loss q = 1 - r of the matched covariate. Estimand: target marginal log OR,
## B versus A. The MAIC limit is L(d, gamma); the truth T(d, g_u).
##
## Tipping surface S(gamma) = L(0, gamma): the estimate a null effect would
## produce under bias gamma. L is increasing in d, so the decision corrected for
## gamma is "B better" iff theta_hat < S(gamma), and S(0) = 0. For one reported
## estimate every summary's verdict is theta_hat against one number: the minimum
## (or maximum) of S over a set, or a quantile of S under a distribution.
##   OAT     the cross: each coordinate over its elicited range, others at 0
##   box     the elicited box; equals min-norm >= 1 under the L-infinity metric
##           in half-range units, and the inradius at the origin is that norm
##   ball    min-norm >= 1 under the Euclidean metric in half-range units
##   frac    preservation fraction >= 0.95 under the elicited distribution P
## Verdict truth (DIA-14's definition): flip = sign(theta_hat - S(gamma*)) !=
## sign(theta_hat), with gamma* the true bias vector.
##
## A replicate draws gamma* from the world W and theta_hat ~ N(L(d, gamma*),
## SE_HAT^2), SE_HAT the delta-method SE of the MAIC log OR at 300 per arm.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261522L
N_SIM <- 2000L; N_P <- 4000L; PI_FRAC <- 0.95
N_A <- 300L; N_B <- 300L; P_S <- 0.3; P_T <- 0.5; MX_T <- 0.5
HALF <- c(g_u = 1, m = 0.2, q = 0.4)                   # elicited half-ranges (m, q one-sided)
LO <- c(g_u = -1, m = 0, q = 0); HI <- LO + HALF * c(2, 1, 1)
GH <- statmod::gauss.quad.prob(80, "normal")

build_grid <- function() {
  g <- expand.grid(p = c(2L, 3L), dependence = c("independent", "positive", "negative"), world = c("calibrated", "overconfident"),
                   d = c(-0.3, 0.3), KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$rho <- c(independent = 0, positive = 0.5, negative = -0.5)[g$dependence]
  g$scale_w <- c(calibrated = 1, overconfident = 1.5)[g$world]; g$cell <- seq_len(nrow(g)); g
}

## Vectorized over bias vectors: risk integrates x over its normal law.
Fx <- function(mx, gu, u, d) colSums(GH$weights * stats::plogis(-1 + 0.5 * outer(GH$nodes, mx, "+") + rep(gu * u + d, each = length(GH$nodes))))
risk <- function(mx, pu, gu, d) pu * Fx(mx, gu, 1, d) + (1 - pu) * Fx(mx, gu, 0, d)
L_lim <- function(d, G) { n <- nrow(G); pB <- risk(rep(MX_T, n), P_T, G[, 1], d)
  obs <- (1 - G[, 2]) * pB + (G[, 2] / 2) * (1 - pB); stats::qlogis(obs) - stats::qlogis(risk(MX_T * (1 - G[, 3]), P_S, G[, 1], 0)) }
S_tip <- function(G) L_lim(0, G)
## Target marginal log OR, B versus A; depends on the bias vector through g_u only.
truth <- function(cell, g_u = 0) stats::qlogis(risk(MX_T, P_T, g_u, cell$d)) - stats::qlogis(risk(MX_T, P_T, g_u, 0))

## Delta-method SE of the MAIC log OR at gamma = 0: A's weighted proportion with the
## tilt estimated (influence w (y - pA - c (x - MX_T)), c = Cov_T(p, x)), B's raw.
SE_HAT <- local({ z <- GH$nodes; w <- GH$weights; p <- function(x) stats::plogis(-1 + 0.5 * x)
  pA <- sum(w * p(z + MX_T)); cc <- sum(w * (p(z + MX_T) - pA) * z)
  vA <- exp(MX_T^2) * sum(w * (p(z + 2 * MX_T) * (1 - p(z + 2 * MX_T)) + (p(z + 2 * MX_T) - pA - cc * (z + MX_T))^2)) / N_A
  pB <- pA; sqrt(vA / (pA * (1 - pA))^2 + 1 / (N_B * pB * (1 - pB))) })

active <- function(cell) if (cell$p == 3L) c(TRUE, TRUE, TRUE) else c(TRUE, TRUE, FALSE)
## Gaussian copula with corr(g_u, m) = corr(g_u, q) = rho, corr(m, q) = 0, uniform
## margins on the elicited ranges scaled by s; inactive coordinates held at 0.
rbias <- function(n, cell, s = 1) { R <- diag(3); R[1, 2:3] <- R[2:3, 1] <- cell$rho
  U <- stats::pnorm(matrix(MASS::mvrnorm(n, rep(0, 3), R), nrow = n)); G <- sweep(sweep(U, 2, (HI - LO) * s, "*"), 2, LO * s, "+")
  G[, !active(cell)] <- 0; colnames(G) <- names(HALF); G }

## Per cell, once: the extended grid (twice the box), its norms, and the thresholds.
K_AX <- c(41L, 21L, 21L)
grid_ext <- function(cell, k = K_AX) { ax <- lapply(1:3, function(j) if (active(cell)[j]) seq(2 * LO[j], 2 * HI[j], length.out = k[j]) else 0)
  G <- as.matrix(expand.grid(ax)); colnames(G) <- names(HALF); U <- sweep(G, 2, HALF, "/")
  list(G = G, S = S_tip(G), n2 = sqrt(rowSums(U^2)), ninf = apply(abs(U), 1, max),
       cross = rowSums(G != 0) <= 1) }
prep <- function(cell, k = K_AX) { e <- grid_ext(cell, k); inbox <- e$ninf <= 1 + 1e-9
  old <- get(".Random.seed", globalenv()); on.exit(assign(".Random.seed", old, globalenv()))
  set.seed(MASTER_SEED + cell$cell); sp <- S_tip(rbias(N_P, cell))
  th <- function(k) c(lo = min(e$S[k]), hi = max(e$S[k]))
  c(e, list(t_oat = th(inbox & e$cross), t_box = th(inbox), t_ball = th(e$n2 <= 1 + 1e-9),
            t_frac = c(lo = unname(stats::quantile(sp, 1 - PI_FRAC)), hi = unname(stats::quantile(sp, PI_FRAC))), sp = sp)) }
PREP <- list()

## The world's bias vector for one replicate.
draw <- function(cell) rbias(1, cell, cell$scale_w)

one_rep <- function(cell) {
  key <- as.character(cell$cell); if (is.null(PREP[[key]])) PREP[[key]] <<- prep(cell); P <- PREP[[key]]
  gs <- draw(cell); th <- L_lim(cell$d, gs) + SE_HAT * stats::rnorm(1)
  neg <- th < 0; flip <- (th < S_tip(gs)) != neg
  robust <- function(t) if (neg) th < t[["lo"]] else th > t[["hi"]]
  fl <- if (neg) P$S < th else P$S > th                 # grid points at which the decision flips
  data.frame(theta_hat = th, s_true = S_tip(gs), true_effect = truth(cell, gs[1]), flip = flip,
             oat = robust(P$t_oat), box = robust(P$t_box), ball = robust(P$t_ball), frac = robust(P$t_frac),
             frac_value = mean(if (neg) P$sp > th else P$sp < th),
             minnorm_2 = if (any(fl)) min(P$n2[fl]) else max(P$n2), minnorm_inf = if (any(fl)) min(P$ninf[fl]) else max(P$ninf),
             oat_value = if (any(fl & P$cross)) min(P$ninf[fl & P$cross]) else max(P$ninf))
}
