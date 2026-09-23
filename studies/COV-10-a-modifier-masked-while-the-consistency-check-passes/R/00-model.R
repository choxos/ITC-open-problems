## ---------------------------------------------------------------------------
## COV-10: interaction coefficients have their own consistency equation.
##
## Triangle network A, B, C, M studies per comparison. Study s of comparison
## (t1, t2) has covariate mean xbar_s ~ N(0.5, SDX^2) and estimates
##   theta_s = d_{t1 t2} + beta_{t1 t2} (xbar_s - 0.5) + loop_s,  SE 0.1,
## with d_AB = -0.3, d_AC = -0.5, d_BC = -0.2 + loop shift (effect inconsistency).
## Path slopes: AB a B, AC B, BC c B. Consistency of interactions requires
## beta_BC = beta_AC - beta_AB. With equal precision on the three paths the
## consistency meta-regression gives b_C = B (a + 2 + c) / 3 and
## b_B = B (2a + 1 - c) / 3, so (a, c) = (0, 1) is consistent, (-0.5, -0.5) partly
## opposing (b_C = B / 3, b_B = 0) and (-1, -1) cancelling (b_B = b_C = 0) although
## every path carries modification of size B.
## Analyses: consistency meta-regression with basic parameters d_B, d_C and
## interactions b_B, b_C; Wald test of b_B = b_C = 0 (modifier selection);
## interaction-consistency test (direct BC slope against b_C - b_B from AB and AC);
## effect-consistency (Bucher) test at the mean covariate.
## Target: C versus A at covariate value X_T = 1.5, truth from the AC path.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261022L
SE <- 0.1; B <- 0.3; X_T <- 1.5; ALPHA <- 0.10; N_SIM <- 2000L
SCEN <- list(consistent = c(0, 1), partial = c(-0.5, -0.5), cancelling = c(-1, -1))
LEVELS <- list(scen = names(SCEN), sdx = c(0.3, 1), M = c(2L, 4L, 8L), loop = c(0, 0.2))
build_grid <- function() {
  g <- expand.grid(scen = LEVELS$scen, sdx = LEVELS$sdx, M = LEVELS$M, loop = LEVELS$loop, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$cell <- seq_len(nrow(g)); g
}
truth <- function(cell) -0.5 + B * (X_T - 0.5)

draw <- function(cell) {
  d <- c(AB = -0.3, AC = -0.5, BC = -0.2 + cell$loop); ac <- SCEN[[cell$scen]]; b <- c(AB = ac[1] * B, AC = B, BC = ac[2] * B)
  do.call(rbind, lapply(names(d), function(cp) { xb <- stats::rnorm(cell$M, 0.5, cell$sdx)
    data.frame(comp = cp, xc = xb - 0.5, est = d[[cp]] + b[[cp]] * (xb - 0.5) + stats::rnorm(cell$M, 0, SE)) }))
}

wls <- function(X, y) { W <- diag(1 / SE^2, length(y)); V <- solve(t(X) %*% W %*% X); list(b = drop(V %*% t(X) %*% W %*% y), V = V) }

fit_all <- function(cell, d) {
  sB <- ifelse(d$comp == "AB", 1, ifelse(d$comp == "BC", -1, 0)); sC <- ifelse(d$comp %in% c("AC", "BC"), 1, 0)
  ## Consistency network meta-regression.
  f <- wls(cbind(dB = sB, dC = sC, bB = sB * d$xc, bC = sC * d$xc), d$est)
  wald <- drop(t(f$b[3:4]) %*% solve(f$V[3:4, 3:4]) %*% f$b[3:4]); p_int <- stats::pchisq(wald, 2, lower.tail = FALSE)
  ## Without the covariate.
  f0 <- wls(cbind(dB = sB, dC = sC), d$est)
  ## Interaction consistency: direct BC slope against the indirect b_C - b_B.
  slope <- function(cp) { z <- d[d$comp == cp, ]; wls(cbind(1, z$xc), z$est) }
  sAB <- slope("AB"); sAC <- slope("AC"); sBC <- slope("BC")
  ind <- sAC$b[2] - sAB$b[2]; vi <- sAC$V[2, 2] + sAB$V[2, 2]
  p_int_cons <- 2 * stats::pnorm(-abs(sBC$b[2] - ind) / sqrt(sBC$V[2, 2] + vi))
  ## Effect consistency at the mean covariate (intercepts of the per-comparison fits).
  p_eff_cons <- 2 * stats::pnorm(-abs(sBC$b[1] - (sAC$b[1] - sAB$b[1])) / sqrt(sBC$V[1, 1] + sAC$V[1, 1] + sAB$V[1, 1]))
  ## Target C versus A at X_T after selection (keep the covariate if p_int < ALPHA).
  a1 <- c(0, 1, 0, X_T - 0.5); est_sel <- if (p_int < ALPHA) sum(a1 * f$b) else f0$b[2]
  se_sel <- if (p_int < ALPHA) sqrt(drop(t(a1) %*% f$V %*% a1)) else sqrt(f0$V[2, 2])
  ## AC-path estimate (the path whose modification is real).
  est_ac <- sAC$b[1] + sAC$b[2] * (X_T - 0.5); se_ac <- sqrt(c(1, X_T - 0.5) %*% sAC$V %*% c(1, X_T - 0.5))
  c(bC = unname(f$b[4]), se_bC = sqrt(f$V[4, 4]), p_int = p_int, p_int_cons = unname(p_int_cons), p_eff_cons = unname(p_eff_cons),
    est_sel = unname(est_sel), se_sel = unname(se_sel), est_ac = unname(est_ac), se_ac = unname(se_ac))
}
