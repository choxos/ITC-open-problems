## ---------------------------------------------------------------------------
## IDN-01: what each transitivity screen can see.
##
## Triangle network A, B, C; comparisons AB, AC, BC with M studies each.
## Study s of comparison (t1, t2) estimates theta_s with SE 0.15:
##   theta_s = (d_t2 - d_t1) + (beta_t2 - beta_t1) xbar_s + shift_s,
## d_A = 0, d_B = -0.3, d_C = -0.5. Studies report xbar_s (the measured modifier).
## Mechanisms (size V):
##   none           no modification, no shifts
##   measured_em    beta_C = V / 0.5 on the measured modifier, whose study means
##                  differ by comparison (AB 0, AC 0.5, BC 1): visible in xbar
##   unmeasured_em  an unreported modifier shifts every AC and BC study by V
##                  (C tested where it works better), measured means equal:
##                  loop-consistent, so no screen can see it
##   loop_break     BC studies shifted by V only: breaks the loop
##   drift          study-specific shifts N(0, V^2), unrelated to comparison
## Estimand: B versus C in the declared target, measured modifier 0.5 and no
## unreported shift: d_C - d_B + (beta_C - beta_B) 0.5.
## Estimator: fixed-effect NMA of B versus C (inverse-variance pooled direct and
## indirect evidence), evaluated at the target by meta-regression when the
## measured modifier varies.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261018L
SE <- 0.15; D <- c(A = 0, B = -0.3, C = -0.5); X_T <- 0.5; ALPHA <- 0.10; N_SIM <- 2000L
LEVELS <- list(mech = c("none", "measured_em", "unmeasured_em", "loop_break", "drift"), V = c(0.1, 0.2, 0.4), M = c(2L, 5L))
build_grid <- function() {
  g <- expand.grid(mech = LEVELS$mech, V = LEVELS$V, M = LEVELS$M, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g <- g[!(g$mech == "none" & g$V != 0.1), ]; g$V[g$mech == "none"] <- 0
  g$cell <- seq_len(nrow(g)); g
}
COMP <- list(AB = c("A", "B"), AC = c("A", "C"), BC = c("B", "C"))

truth <- function(cell) { bC <- if (cell$mech == "measured_em") cell$V / 0.5 else 0; (D[["C"]] - D[["B"]]) + bC * X_T }

draw <- function(cell) {
  bC <- if (cell$mech == "measured_em") cell$V / 0.5 else 0; beta <- c(A = 0, B = 0, C = bC)
  do.call(rbind, lapply(names(COMP), function(cp) { t1 <- COMP[[cp]][1]; t2 <- COMP[[cp]][2]
    xm <- if (cell$mech == "measured_em") c(AB = 0, AC = 0.5, BC = 1)[[cp]] else 0.5
    xbar <- xm + stats::rnorm(cell$M, 0, 0.1)
    ## unmeasured_em: C looks better by V against both A and B, so the AC and BC
    ## contrasts (C minus the other) both move by -V and the loop still closes.
    shift <- switch(cell$mech, unmeasured_em = if (cp %in% c("AC", "BC")) -cell$V else 0,
                    loop_break = if (cp == "BC") cell$V else 0, drift = stats::rnorm(cell$M, 0, cell$V), 0)
    th <- (D[[t2]] - D[[t1]]) + (beta[[t2]] - beta[[t1]]) * xbar + shift
    data.frame(comp = cp, xbar = xbar, est = th + stats::rnorm(cell$M, 0, SE), se = SE) }))
}

pool <- function(e, s) { w <- 1 / s^2; c(sum(w * e) / sum(w), sqrt(1 / sum(w))) }

fit_all <- function(cell, d) {
  p <- lapply(split(d, d$comp), function(z) pool(z$est, z$se))
  ## Screens.
  ds <- stats::anova(stats::lm(xbar ~ comp, data = d))[["Pr(>F)"]][1]                      # dissimilarity of the measured modifier
  ind <- p$AC[1] - p$AB[1]; dir <- p$BC[1]
  inc <- 2 * stats::pnorm(-abs(dir - ind) / sqrt(p$BC[2]^2 + p$AC[2]^2 + p$AB[2]^2))          # Bucher loop test
  Q <- sum(sapply(split(d, d$comp), function(z) { m <- pool(z$est, z$se)[1]; sum((z$est - m)^2 / z$se^2) }))
  het <- stats::pchisq(Q, nrow(d) - 3, lower.tail = FALSE)
  ## Estimator: consistency-model NMA of B versus C by weighted least squares on basic
  ## parameters (d_AB, d_AC) with a common slope on xbar for comparisons involving C
  ## when the measured modifier varies (meta-regression), evaluated at the target.
  X <- cbind(dB = ifelse(d$comp == "AB", 1, ifelse(d$comp == "BC", -1, 0)), dC = ifelse(d$comp %in% c("AC", "BC"), 1, 0))
  use_mr <- stats::sd(d$xbar) > 0.2
  if (use_mr) X <- cbind(X, bC = X[, "dC"] * d$xbar)
  f <- stats::lm.wfit(X, d$est, 1 / d$se^2); b <- f$coefficients
  V <- solve(crossprod(X * (1 / d$se), X * (1 / d$se)))
  a <- c(-1, 1, if (use_mr) X_T); est <- sum(a * b); se <- sqrt(drop(t(a) %*% V %*% a))
  c(est = est, se = se, p_dissim = ds, p_incons = inc, p_het = het)
}
