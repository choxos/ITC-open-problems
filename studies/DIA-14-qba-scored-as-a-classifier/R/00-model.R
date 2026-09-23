## ---------------------------------------------------------------------------
## DIA-14: a quantitative bias analysis verdict scored as a classifier.
##
## Unanchored MAIC of A (individual data) against B (aggregate), binary outcome,
## measured covariate x balanced; an unmeasured binary confounder U with outcome
## log OR GU has prevalence P_S in the source and p_T in the target. The MAIC
## estimate converges to Delta + b*, with b* computable exactly.
##
## The analyst declares a region for the bias b, centered at b* + (centering
## error) with half-width w, and calls the decision ROBUST if "B better than A"
## (estimate - b below 0) holds for every b in the region, FRAGILE otherwise.
## The verdict is correct when ROBUST coincides with the naive decision being the
## right one. False reassurance: ROBUST when the naive decision is wrong.
##
## P(false reassurance) = P(b* outside the region) x P(wrong | outside, robust)
## (DESIGN.md section 2): the first factor belongs to the elicitation.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261012L
N_A <- 300L; N_B <- 300L; ALPHA <- stats::qlogis(0.3); GX <- 0.5; P_S <- 0.3
N_SIM <- 2000L
LEVELS <- list(gu = c(0.5, 1), p_t = c(0.3, 0.5, 0.7), delta = c(-0.3, -0.1, 0.1),
               width = c(0.05, 0.15, 0.3), centering = c(0, 0.1, 0.2))

build_grid <- function() {
  g <- expand.grid(gu = LEVELS$gu, p_t = LEVELS$p_t, delta = LEVELS$delta, KEEP.OUT.ATTRS = FALSE)
  g$cell <- seq_len(nrow(g)); g
}

## Target: x ~ N(0.5, 1), U ~ Bern(p_T); source x ~ N(0, 1), U ~ Bern(P_S).
## Conditional log odds: ALPHA + GX x + GU U + treatment (A: 0, B: delta).
risk <- function(mx, pu, gu, d) {
  gh <- statmod::gauss.quad.prob(60, "normal", mu = mx, sigma = 1)
  f <- function(u) sum(gh$weights * stats::plogis(ALPHA + GX * gh$nodes + gu * u + d))
  pu * f(1) + (1 - pu) * f(0)
}
## Truth: marginal log OR B versus A in the target. Limit of MAIC: B's risk in the
## target over A's risk transported on x only, i.e. with the source's U prevalence.
truth <- function(cell) stats::qlogis(risk(0.5, cell$p_t, cell$gu, cell$delta)) - stats::qlogis(risk(0.5, cell$p_t, cell$gu, 0))
limit <- function(cell) stats::qlogis(risk(0.5, cell$p_t, cell$gu, cell$delta)) - stats::qlogis(risk(0.5, P_S, cell$gu, 0))
bstar <- function(cell) limit(cell) - truth(cell)

draw_fit <- function(cell) {
  x <- stats::rnorm(N_A); u <- stats::rbinom(N_A, 1, P_S)
  y <- stats::rbinom(N_A, 1, stats::plogis(ALPHA + GX * x + cell$gu * u))
  xb <- stats::rnorm(N_B, 0.5); ub <- stats::rbinom(N_B, 1, cell$p_t)
  yb <- stats::rbinom(N_B, 1, stats::plogis(ALPHA + GX * xb + cell$gu * ub + cell$delta))
  xc <- x - mean(xb)
  a <- stats::uniroot(function(a) sum(xc * exp(a * xc)), c(-20, 20))$root; w <- exp(a * xc)
  pA <- sum(w * y) / sum(w); pB <- mean(yb)
  vA <- sum(w^2 * (y - pA)^2) / sum(w)^2 / (pA * (1 - pA))^2; vB <- 1 / sum(yb) + 1 / sum(1 - yb)
  c(est = stats::qlogis(pB) - stats::qlogis(pA), se = sqrt(vA + vB))
}

## Verdicts for every elicitation from one estimate. The decision is "B better"
## when the bias-adjusted estimate is below 0. The verdict's true value (DESIGN.md
## section 3) is whether the decision at the true bias b* equals the unadjusted
## one: flip = sign(est - b*) != sign(est).
##
## Elicitation: the analyst's region is [c - w, c + w] with c = b* + e and
## e ~ N(0, s^2), s = w / qnorm(1 - q/2), so the region excludes b* with
## probability q exactly (e = 0 when q = 0). Direction "symmetric" leaves the sign
## of e random; "understated" points it toward zero bias, e = -sign(b*) |e|, the
## analyst assuming the confounder weaker than it is. "zero" is a region centered
## at no bias, [-w, w], the common "bias is small" assumption; its exclusion rate
## follows from b* and w rather than being set (q is not used).
##
## Methods. Deterministic grid over the region: ROBUST if est - b keeps the sign of
## est for every b in it. For one scalar bias this verdict equals the bounds
## verdict and equals comparing the tipping point (b = est) with the region, so
## the three are one method here. Probabilistic QBA: b ~ Uniform(region) plus
## sampling error; ROBUST if P(est - b + se Z has the sign of est) >= PI_ROBUST,
## computed on a 400-point grid over b (exact to 1e-3) and, to measure the QBA's
## own Monte Carlo error, from M_QBA random draws. No QBA: always ROBUST.
PI_ROBUST <- 0.95; M_QBA <- 1000L
Q_EXCL <- c(0, 0.1, 0.3); WIDTH <- c(0.05, 0.15, 0.3); DIRS <- c("symmetric", "understated", "zero")

verdicts <- function(est, se, cell) {
  b <- bstar(cell); flip <- sign(est - b) != sign(est); s0 <- sign(est)
  do.call(rbind, lapply(DIRS, function(dir) do.call(rbind, lapply(if (dir == "zero") NA else Q_EXCL, function(q) do.call(rbind, lapply(WIDTH, function(w) {
    e <- if (is.na(q)) -b else if (q == 0) 0 else stats::rnorm(1, 0, w / stats::qnorm(1 - q / 2))
    if (dir == "understated" && b != 0) e <- -sign(b) * abs(e)
    lo <- b + e - w; hi <- b + e + w
    grid <- sign(est - lo) == s0 && sign(est - hi) == s0
    bb <- seq(lo, hi, length.out = 400)
    pr <- mean(stats::pnorm(s0 * (est - bb) / se))
    bm <- stats::runif(M_QBA, lo, hi); pm <- mean(sign(est - bm + se * stats::rnorm(M_QBA)) == s0)
    data.frame(dir = dir, q = q, width = w, covers = lo <= b && b <= hi, flip = flip,
               grid = grid, prob = pr >= PI_ROBUST, prob_mc = pm >= PI_ROBUST)
  }))))))
}

## One replicate: estimate, oracle-adjusted interval check, verdicts.
one_rep <- function(cell) {
  f <- draw_fit(cell); th <- truth(cell); b <- bstar(cell)
  v <- verdicts(f[["est"]], f[["se"]], cell)
  v$est <- f[["est"]]; v$se <- f[["se"]]
  v$oracle_cover <- abs(f[["est"]] - b - th) <= 1.96 * f[["se"]]
  v$naive_right <- sign(f[["est"]]) == sign(th)
  v
}
