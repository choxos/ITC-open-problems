## ---------------------------------------------------------------------------
## COV-02: the adjustment set is a property of the scale.
##
## Population-level calculation, no sampling. Binary outcome
##   logit p = ALPHA + g sum_j x_j + A (DELTA + BETA sum_{j <= m} x_j),
## p covariates: m conditional modifiers (on the log odds ratio scale, also
## prognostic) and k prognostic non-modifiers. Source x ~ N(0, I); target x ~
## N(mu, I). Transport of the A-versus-C contrast by balancing covariate means
## (for independent normal covariates this moves each balanced covariate to its
## target law exactly). Omitting covariate j leaves it at its source law.
## A covariate "matters" on a scale if omitting it changes the target contrast on
## that scale by more than THRESH of the contrast's size.
## Scales: risk difference, log risk ratio, marginal log odds ratio, and the
## conditional log odds ratio at the target mean (which only modifiers move).
## Common random numbers (1e6 draws) make the differences exact to about 1e-4.
## ---------------------------------------------------------------------------

ALPHA <- stats::qlogis(0.25); DELTA <- -0.5; BETA <- 0.3; THRESH <- 0.05; N_MC <- 1e6
build_grid <- function() {
  g <- expand.grid(m = c(0L, 1L, 3L), k = c(2L, 6L), g = c(0.3, 0.6), mu = c(0.2, 0.5), KEEP.OUT.ATTRS = FALSE)
  g$scen <- seq_len(nrow(g)); g
}
contrasts <- function(Z, cell) {
  p <- cell$m + cell$k; lin <- ALPHA + cell$g * rowSums(Z); mod <- if (cell$m > 0) BETA * rowSums(Z[, seq_len(cell$m), drop = FALSE]) else 0
  p1 <- mean(stats::plogis(lin + DELTA + mod)); p0 <- mean(stats::plogis(lin))
  c(rd = p1 - p0, lrr = log(p1 / p0), lor = stats::qlogis(p1) - stats::qlogis(p0),
    clor = DELTA + BETA * (if (cell$m > 0) mean(rowSums(Z[, seq_len(cell$m), drop = FALSE])) else 0))
}
sets <- function(cell, seed = 1) {
  p <- cell$m + cell$k; set.seed(seed); E <- matrix(stats::rnorm(N_MC * p), ncol = p)
  full <- contrasts(E + cell$mu, cell)
  ch <- sapply(seq_len(p), function(j) { Z <- E + cell$mu; Z[, j] <- E[, j]; contrasts(Z, cell) - full })
  rel <- abs(ch) / abs(full)
  data.frame(scale = rownames(ch), n_mod_in = rowSums(rel[, seq_len(cell$m), drop = FALSE] > THRESH),
             n_prog_in = rowSums(rel[, cell$m + seq_len(cell$k), drop = FALSE] > THRESH),
             max_rel_prog = apply(rel[, cell$m + seq_len(cell$k), drop = FALSE], 1, max),
             max_rel_mod = if (cell$m > 0) apply(rel[, seq_len(cell$m), drop = FALSE], 1, max) else NA,
             contrast = full[rownames(ch)])
}
