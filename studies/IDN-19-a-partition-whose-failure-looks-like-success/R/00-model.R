## ---------------------------------------------------------------------------
## IDN-19: sensitivity of a network contrast to the shared effect-modifier partition.
##
## Reference A; active B, C, D with effect at covariate x: d_k + g_k x.
## Evidence: an individual-data trial of A vs B (400 patients, x ~ N(0, 1)) giving
## (d_B, g_B); two aggregate trials of A vs C at covariate means -0.5 and 0.5; one
## aggregate trial of A vs D at mean 0; 400 patients each, outcome SD 1, so each
## aggregate effect has variance 0.01.
## Truth: g_B = 0.3, g_C = 0.3 + SEP, g_D = 0.3 + HET (D belongs with B when HET = 0).
## Target: covariate mean 1. Estimand: D versus A in the target, d_D + g_D.
## Partitions (classes share one interaction): {BCD}; {BD}{C}; {B}{CD}. {BC}{D}
## and singletons leave g_D unidentified. Each is fitted by generalized least
## squares on the sufficient statistics; the residual chi-square tests its fit.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261205L; N_SIM <- 4000L; V_AGD <- 0.01; V_IPD <- 4 / 400; M_C <- c(-0.5, 0.5); M_D <- 0; X_T <- 1
D <- c(B = -0.2, C = -0.3, D = -0.25)
PARTS <- list(BCD = list(c("B", "C", "D")), BD_C = list(c("B", "D"), "C"), B_CD = list("B", c("C", "D")))
build_grid <- function() { g <- expand.grid(sep = c(0, 0.3), het = c(0, 0.15, 0.3), KEEP.OUT.ATTRS = FALSE); g$cell <- seq_len(nrow(g)); g }
gam_true <- function(cell) c(B = 0.3, C = 0.3 + cell$sep, D = 0.3 + cell$het)

## Observations: (d_B, g_B) from the IPD trial; y_C1, y_C2, y_D from aggregate trials.
draw <- function(cell) { g <- gam_true(cell)
  c(dB = D[["B"]] + stats::rnorm(1, 0, sqrt(V_IPD)), gB = g[["B"]] + stats::rnorm(1, 0, sqrt(V_IPD)),
    yC1 = D[["C"]] + g[["C"]] * M_C[1] + stats::rnorm(1, 0, sqrt(V_AGD)), yC2 = D[["C"]] + g[["C"]] * M_C[2] + stats::rnorm(1, 0, sqrt(V_AGD)),
    yD = D[["D"]] + g[["D"]] * M_D + stats::rnorm(1, 0, sqrt(V_AGD))) }
## Design for parameters (d_B, d_C, d_D, one interaction per class).
fit_partition <- function(obs, part) {
  cls <- function(k) which(vapply(part, function(p) k %in% p, TRUE)); nc <- length(part)
  X <- matrix(0, 5, 3 + nc); X[1, 1] <- 1; X[2, 3 + cls("B")] <- 1
  X[3, 2] <- 1; X[3, 3 + cls("C")] <- M_C[1]; X[4, 2] <- 1; X[4, 3 + cls("C")] <- M_C[2]
  X[5, 3] <- 1; X[5, 3 + cls("D")] <- M_D
  v <- c(V_IPD, V_IPD, V_AGD, V_AGD, V_AGD); P <- crossprod(X, X / v)
  a <- numeric(3 + nc); a[3] <- 1; a[3 + cls("D")] <- X_T
  if (qr(P)$rank < ncol(P) && max(abs(a %*% MASS::ginv(P) %*% P - a)) > 1e-8) return(c(est = NA, se = NA, q_p = NA))
  b <- MASS::ginv(P) %*% crossprod(X, obs / v); r <- obs - X %*% b; df <- 5 - qr(P)$rank
  c(est = drop(a %*% b), se = sqrt(drop(a %*% MASS::ginv(P) %*% a)), q_p = if (df > 0) stats::pchisq(sum(r^2 / v), df, lower.tail = FALSE) else NA)
}
one_rep <- function(cell) { obs <- draw(cell); f <- t(vapply(PARTS, function(p) fit_partition(obs, p), numeric(3)))
  tr <- D[["D"]] + gam_true(cell)[["D"]] * X_T
  data.frame(partition = names(PARTS), est = f[, "est"], se = f[, "se"], q_p = f[, "q_p"], truth = tr,
             range_lo = min(f[, "est"] - 1.96 * f[, "se"]), range_hi = max(f[, "est"] + 1.96 * f[, "se"]), pt_lo = min(f[, "est"]), pt_hi = max(f[, "est"])) }
