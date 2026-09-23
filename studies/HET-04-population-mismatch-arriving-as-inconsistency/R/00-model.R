## ---------------------------------------------------------------------------
## HET-04: a population difference between the direct and indirect study sets
## arrives in node splitting as inconsistency.
##
## Triangle A, B, C, M studies per comparison, study SE 0.1. AB and AC studies
## have covariate means N(0, 0.2^2); BC studies N(GAP, 0.2^2). C's effect
## against A is modified by BETA x (consistent interactions: AB slope 0, AC and BC
## slope BETA). True loop inconsistency IOTA enters the BC studies.
##   theta_AB = -0.3, theta_AC = -0.5 + BETA xbar, theta_BC = -0.2 + BETA xbar + IOTA.
## Unadjusted split: direct BC pooled estimate minus indirect (AC - AB) at their own
## populations, w = IOTA + BETA (xbar_BC - xbar_AC) on average.
## Adjusted split: meta-regression with the interaction and a BC-specific
## inconsistency parameter.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261024L
SE <- 0.1; ALPHA <- 0.05; N_SIM <- 2000L
LEVELS <- list(gap = c(0, 0.5, 1), beta = c(0, 0.2, 0.4), iota = c(-0.2, 0, 0.2), M = c(2L, 4L))
build_grid <- function() {
  g <- expand.grid(gap = LEVELS$gap, beta = LEVELS$beta, iota = LEVELS$iota, M = LEVELS$M, KEEP.OUT.ATTRS = FALSE)
  g$cell <- seq_len(nrow(g)); g
}
draw <- function(cell) do.call(rbind, lapply(c("AB", "AC", "BC"), function(cp) {
  xb <- stats::rnorm(cell$M, if (cp == "BC") cell$gap else 0, 0.2)
  th <- switch(cp, AB = -0.3 + 0 * xb, AC = -0.5 + cell$beta * xb, BC = -0.2 + cell$beta * xb + cell$iota)
  data.frame(comp = cp, xbar = xb, est = th + stats::rnorm(cell$M, 0, SE)) }))

wls <- function(X, y) { V <- solve(crossprod(X) / SE^2); list(b = drop(V %*% crossprod(X, y) / SE^2), V = V) }
pool <- function(e) c(mean(e), SE / sqrt(length(e)))

fit_all <- function(cell, d) {
  p <- lapply(split(d$est, d$comp), pool)
  w <- p$BC[1] - (p$AC[1] - p$AB[1]); sw <- sqrt(p$BC[2]^2 + p$AC[2]^2 + p$AB[2]^2)
  sB <- ifelse(d$comp == "AB", 1, ifelse(d$comp == "BC", -1, 0)); sC <- ifelse(d$comp %in% c("AC", "BC"), 1, 0)
  X <- cbind(dB = sB, dC = sC, bB = sB * d$xbar, bC = sC * d$xbar, iota = as.numeric(d$comp == "BC"))
  f <- tryCatch(wls(X, d$est), error = function(e) NULL)
  ia <- if (is.null(f)) c(NA, NA) else unname(c(f$b[5], sqrt(f$V[5, 5])))
  c(w = w, p_unadj = 2 * stats::pnorm(-abs(w / sw)), iota_adj = ia[1], p_adj = 2 * stats::pnorm(-abs(ia[1] / ia[2])), se_adj = ia[2], se_unadj = sw)
}
