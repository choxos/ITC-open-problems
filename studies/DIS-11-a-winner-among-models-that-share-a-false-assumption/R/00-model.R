## ---------------------------------------------------------------------------
## DIS-11: predictive criteria rank models that share a bridge assumption.
##
## Two disconnected subnetworks (A versus B trials; C versus D trials), K trials
## each, as in DIS-03, with a design nuisance ETA on subnetwork 2's baselines that
## the exchangeable-baseline bridge carries into the cross-gap contrast C versus A.
## Within each subnetwork the treatment contrast varies with a trial covariate z
## (slope GZ) plus heterogeneity. Three candidate models share the bridge and
## differ inside the subnetworks: common effect; random effects; meta-regression
## on z. Leave-one-trial-out log predictive density ranks them. The cross-gap
## estimate is the same bridge calculation under every candidate plus the
## candidates' within-subnetwork contrasts at the target covariate value.
## Estimand: C versus A at covariate 0.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261103L
K <- 8L; SE <- 0.15; TAU <- 0.1; D_BA <- -0.3; D_DC <- -0.2; D_CA <- 0.2; N_SIM <- 1000L
LEVELS <- list(eta = c(0, 0.2, 0.5), gz = c(0, 0.3))
build_grid <- function() { g <- expand.grid(eta = LEVELS$eta, gz = LEVELS$gz, KEEP.OUT.ATTRS = FALSE); g$cell <- seq_len(nrow(g)); g }

draw <- function(cell) {
  sub <- rep(1:2, each = K); z <- stats::runif(2 * K, -1, 1); mu <- -1 + stats::rnorm(2 * K, 0, 0.3) + cell$eta * (sub == 2)
  base_ctrl <- mu + ifelse(sub == 1, 0, D_CA)                                   # control arms: A in subnetwork 1, C in 2
  eff <- ifelse(sub == 1, D_BA, D_DC) + cell$gz * z + stats::rnorm(2 * K, 0, TAU)
  data.frame(sub = sub, z = z, y_ctrl = base_ctrl + stats::rnorm(2 * K, 0, SE), y_eff = eff + stats::rnorm(2 * K, 0, SE * sqrt(2)))
}
## Candidate within-subnetwork models for the contrast y_eff; each returns a
## prediction and predictive variance for a held-out trial.
fitters <- list(
  common = function(tr, te) { m <- mean(tr$y_eff); c(m, 2 * SE^2 + 2 * SE^2 / nrow(tr)) },
  random = function(tr, te) { m <- mean(tr$y_eff); t2 <- max(0, stats::var(tr$y_eff) - 2 * SE^2); c(m, 2 * SE^2 + t2 + (2 * SE^2 + t2) / nrow(tr)) },
  metareg = function(tr, te) { f <- stats::lm(y_eff ~ z, data = tr); p <- stats::predict(f, newdata = te, se.fit = TRUE)
    c(p$fit, 2 * SE^2 + max(0, summary(f)$sigma^2 - 2 * SE^2) + p$se.fit^2) })
loo <- function(d, k) sum(sapply(seq_len(nrow(d)), function(i) { tr <- d[-i, ]; te <- d[i, ]; p <- fitters[[k]](tr[tr$sub == te$sub, ], te)
  stats::dnorm(te$y_eff, p[1], sqrt(p[2]), log = TRUE) }))
fit_all <- function(cell, d) {
  bridge <- mean(d$y_ctrl[d$sub == 2]) - mean(d$y_ctrl[d$sub == 1])               # C versus A from exchangeable baselines
  scores <- sapply(names(fitters), function(k) loo(d, k))
  c(bridge = bridge, scores, winner = unname(which.max(scores)))
}
