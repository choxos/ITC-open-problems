## ---------------------------------------------------------------------------
## DIS-03: a baseline-risk bridge across a disconnected network.
##
## Subnetwork 1: K trials of A versus B; subnetwork 2: K trials of C versus D.
## Arm-level log odds: mu_s + d_t, with study baseline
##   mu_s = MU + b_s + ETA * D_s + e_s,
## b_s ~ N(DRIFT * 1[subnetwork 2], 0.3^2) prognostic, D_s a binary design
## covariate (for example a more sensitive endpoint definition) with nuisance
## effect ETA on the baseline, e_s the arm-level sampling error (SE 0.15). D_s = 1
## in subnetwork 2 and 0 in subnetwork 1, except that a share OVERLAP of trials in
## each subnetwork uses the other's definition. d = (A 0, B -0.3, C 0.2, D -0.2).
## The bridge assumes exchangeable baselines, so the cross-gap contrast C versus A
## is the difference in mean study baselines plus within-network contrasts.
## Estimand: d_C - d_A = 0.2.
## Methods: reference prediction with exchangeable baselines; the same adjusting
## the baselines for D (needs D to vary within the subnetworks); the bridge
## contribution (how much of the contrast the baseline link supplies).
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261029L
MU <- -1; SE <- 0.15; TAU_B <- 0.3; N_SIM <- 2000L
D_T <- c(A = 0, B = -0.3, C = 0.2, D = -0.2)
LEVELS <- list(eta = c(0, 0.2, 0.5), overlap = c(0, 0.25), drift = c(0, 0.2), K = c(5L, 10L))
build_grid <- function() { g <- expand.grid(eta = LEVELS$eta, overlap = LEVELS$overlap, drift = LEVELS$drift, K = LEVELS$K, KEEP.OUT.ATTRS = FALSE); g$cell <- seq_len(nrow(g)); g }
truth <- function() D_T[["C"]] - D_T[["A"]]

draw <- function(cell) {
  sub <- rep(1:2, each = cell$K); D <- as.numeric(sub == 2); flip <- stats::runif(2 * cell$K) < cell$overlap; D[flip] <- 1 - D[flip]
  b <- stats::rnorm(2 * cell$K, cell$drift * (sub == 2), TAU_B); mu <- MU + b + cell$eta * D
  ctrl <- ifelse(sub == 1, "A", "C"); trt <- ifelse(sub == 1, "B", "D")
  data.frame(sub = sub, D = D, y_ctrl = mu + D_T[ctrl] + stats::rnorm(2 * cell$K, 0, SE), y_trt = mu + D_T[trt] + stats::rnorm(2 * cell$K, 0, SE))
}

fit_all <- function(cell, d) {
  ## Exchangeable baselines: study baseline estimated from its control arm; the cross-gap
  ## contrast C minus A is the difference in mean control-arm log odds between subnetworks.
  m1 <- mean(d$y_ctrl[d$sub == 1]); m2 <- mean(d$y_ctrl[d$sub == 2])
  s2 <- stats::var(d$y_ctrl[d$sub == 1]) / cell$K + stats::var(d$y_ctrl[d$sub == 2]) / cell$K
  exch <- c(m2 - m1, sqrt(s2))
  ## Adjusted for the design covariate: control-arm log odds regressed on subnetwork and D.
  adj <- if (length(unique(d$D[d$sub == 1])) > 1 || length(unique(d$D[d$sub == 2])) > 1) {
    f <- stats::lm(y_ctrl ~ factor(sub) + D, data = d); c(stats::coef(f)[["factor(sub)2"]], sqrt(stats::vcov(f)["factor(sub)2", "factor(sub)2"]))
  } else c(NA, NA)
  c(exch = exch[1], se_exch = exch[2], adj = adj[1], se_adj = adj[2])
}
