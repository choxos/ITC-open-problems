## ---------------------------------------------------------------------------
## DEC-28: uncertainty in the covariate value at which the better treatment changes.
##
## Two treatments; individual effect of A over B: eta(x) = DELTA + BETA x, so the
## boundary is x* = -DELTA / BETA. Evidence: one individual-data trial (400
## patients, x ~ N(0, 1), y = 0.3 x + A eta(x) + e, e ~ N(0, 1)) and five aggregate
## trials (400 patients each) at covariate means M_K reporting their effect with SE
## 0.1. Aggregate trial k's effect is eta(m_k) + B_ECO (m_k - mean(M_K)): an
## ecological term from a study-level factor that tracks the trial mean.
## Estimators of (DELTA, BETA): within (individual trial alone) and combined
## (generalized least squares on the individual trial's estimates and the aggregate
## effects, as a shared-interaction model does).
## For each: plug-in x*, delta-method interval, Fieller interval (bounded,
## exclusive or the whole line), and the pointwise optimality map
## P(A better at x) = Phi(eta-hat(x) / se(x)).
## Regret of the plug-in rule in the target x ~ N(0.5, 1), relative to the value of
## individualized treatment.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261125L; N_IPD <- 400L; M_K <- c(-1, -0.5, 0.5, 1, 1.5); SE_K <- 0.1; N_SIM <- 2000L
MU_T <- 0.5; Z <- stats::qnorm(0.975)
build_grid <- function() {
  g <- expand.grid(beta = c(0.3, 0.15, 0.05), xstar = c(0.5, 1.5), b_eco = c(0, 0.1), KEEP.OUT.ATTRS = FALSE)
  g$delta <- -g$beta * g$xstar; g$cell <- seq_len(nrow(g)); g
}
XG <- stats::qnorm(stats::ppoints(2001), MU_T, 1)                 # target quadrature
PROFILES <- c(-1, -0.5, 0, 0.5, 1)                                   # offsets from x*

draw_est <- function(cell) {
  x <- stats::rnorm(N_IPD); A <- rep(0:1, each = N_IPD / 2)
  y <- 0.3 * x + A * (cell$delta + cell$beta * x) + stats::rnorm(N_IPD)
  f <- stats::lm(y ~ x * A); th_w <- stats::coef(f)[c("A", "x:A")]; V_w <- stats::vcov(f)[c("A", "x:A"), c("A", "x:A")]
  d_k <- cell$delta + cell$beta * M_K + cell$b_eco * (M_K - mean(M_K)) + stats::rnorm(length(M_K), 0, SE_K)
  X <- cbind(1, M_K); P <- solve(V_w) + crossprod(X) / SE_K^2
  V_c <- solve(P); th_c <- drop(V_c %*% (solve(V_w, th_w) + crossprod(X, d_k) / SE_K^2))
  list(within = list(th = unname(th_w), V = unname(V_w)), combined = list(th = unname(th_c), V = unname(V_c)))
}

## Fieller set {x : (d + b x)^2 <= Z^2 (v_d + 2 x c + x^2 v_b)} as a type and endpoints,
## and whether it contains x0.
fieller <- function(th, V, x0) {
  a <- th[2]^2 - Z^2 * V[2, 2]; bb <- 2 * (th[1] * th[2] - Z^2 * V[1, 2]); cc <- th[1]^2 - Z^2 * V[1, 1]
  q <- function(x) a * x^2 + bb * x + cc; disc <- bb^2 - 4 * a * cc
  type <- if (a > 0) "bounded" else if (disc < 0) "whole_line" else "exclusive"
  r <- if (disc >= 0) sort((-bb + c(-1, 1) * sqrt(disc)) / (2 * a)) else c(NA, NA)
  list(type = type, lo = unname(r[1]), hi = unname(r[2]), covers = unname(q(x0) <= 0))
}

scores <- function(e, cell) {
  th <- e$th; V <- e$V; xs <- cell$xstar
  xh <- -th[1] / th[2]; g <- c(-1 / th[2], th[1] / th[2]^2); se <- sqrt(drop(t(g) %*% V %*% g))
  fl <- fieller(th, V, xs)
  eta <- cell$delta + cell$beta * XG; etah <- th[1] + th[2] * XG
  regret <- mean(abs(eta) * (sign(etah) != sign(eta))); value <- mean(pmax(eta, 0)) - max(mean(eta), 0)
  xp <- xs + PROFILES; pa <- stats::pnorm((th[1] + th[2] * xp) / sqrt(V[1, 1] + 2 * xp * V[1, 2] + xp^2 * V[2, 2]))
  truth_a <- (cell$delta + cell$beta * xp) > 0
  data.frame(xhat = xh, delta_cover = abs(xh - xs) <= Z * se, delta_width = 2 * Z * se,
             f_type = fl[["type"]], f_cover = as.logical(fl[["covers"]]), f_width = as.numeric(fl[["hi"]]) - as.numeric(fl[["lo"]]),
             beta_z = th[2] / sqrt(V[2, 2]), regret = regret, value = value,
             false_certain = { k <- PROFILES != 0; mean((pa[k] >= 0.975 & !truth_a[k]) | (pa[k] <= 0.025 & truth_a[k])) },
             brier = mean((pa[PROFILES != 0] - truth_a[PROFILES != 0])^2))
}

one_rep <- function(cell) { e <- draw_est(cell)
  sh <- 1 - e$combined$V[2, 2] / e$within$V[2, 2]           # share of the interaction's precision from between-trial variation
  rbind(data.frame(estimator = "within", scores(e$within, cell), between_share = 0),
        data.frame(estimator = "combined", scores(e$combined, cell), between_share = sh)) }
