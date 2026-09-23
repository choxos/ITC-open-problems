## ---------------------------------------------------------------------------
## DIS-21: the admission threshold of a matched bridge across a disconnected network.
##
## Subnetwork 1: K trials of A versus C; subnetwork 2: K trials of B versus D; no
## trial links them. Each trial has a population with covariate means mu_t (three
## covariates, SD 1 within trials) drawn around 0 (subnetwork 1) or SHIFT
## (subnetwork 2), and an unmeasured study-level baseline shift alpha_t ~ N(0, TAU_S^2).
## Arm outcome means: alpha_t + PROG' xbar_arm + effect(arm) + N(0, 1/N_ARM).
## Effects: A -0.3, B -0.1, C 0, D 0, so A - B = -0.2 and the bridged C - D is 0.
## Bridge: every (C arm, D arm) pair across the gap whose covariate-mean distance
## (root mean square over the index's covariates) is at most theta is admitted as a
## pseudo-trial; admitted pairs are pooled by fixed effect, as are the A-C and B-D
## trials, and A - B = (A - C) + (C - D) - (B - D).
## theta is expressed in multiples of the median distance between the two arms of
## one randomized trial (the within-trial unit U).
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261127L; K <- 6L; N_ARM <- 150L; PROG <- c(0.5, 0.3, 0.1); SD_POP <- 0.3
EFF <- c(A = -0.3, B = -0.1, C = 0, D = 0); TRUE_AB <- EFF[["A"]] - EFF[["B"]]
MULT <- c(1, 2, 3, 5, 7, 10, 15, 20); N_SIM <- 2000L
build_grid <- function() {
  g <- expand.grid(shift = c(0, 0.5), index = c("all", "omits_x1"), tau_s = c(0, 0.1), KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$cell <- seq_len(nrow(g)); g
}
idx_cols <- function(index) if (index == "all") 1:3 else 2:3
dist <- function(a, b, cols) sqrt(mean((a[cols] - b[cols])^2))

## Within-trial unit: median distance between two arms of one trial.
unit <- function(index) { old <- if (exists(".Random.seed", .GlobalEnv)) get(".Random.seed", .GlobalEnv) else NULL; set.seed(3)
  u <- stats::median(replicate(1e4, dist(stats::rnorm(3, 0, 1 / sqrt(N_ARM)), stats::rnorm(3, 0, 1 / sqrt(N_ARM)), idx_cols(index))))
  if (!is.null(old)) assign(".Random.seed", old, .GlobalEnv); u }

trial <- function(center, arms, tau_s) {
  mu <- stats::rnorm(3, center, SD_POP); a <- stats::rnorm(1, 0, tau_s)
  lapply(arms, function(k) { xb <- mu + stats::rnorm(3, 0, 1 / sqrt(N_ARM))
    list(arm = k, x = xb, y = a + sum(PROG * xb) + EFF[[k]] + stats::rnorm(1, 0, 1 / sqrt(N_ARM))) })
}
fe <- function(est, v) c(est = sum(est / v) / sum(1 / v), var = 1 / sum(1 / v))

one_rep <- function(cell, u) {
  s1 <- lapply(seq_len(K), function(i) trial(0, c("A", "C"), cell$tau_s)); s2 <- lapply(seq_len(K), function(i) trial(cell$shift, c("B", "D"), cell$tau_s))
  v <- 2 / N_ARM
  ac <- fe(vapply(s1, function(t) t[[1]]$y - t[[2]]$y, 0), rep(v, K)); bd <- fe(vapply(s2, function(t) t[[1]]$y - t[[2]]$y, 0), rep(v, K))
  pr <- expand.grid(i = seq_len(K), j = seq_len(K))
  pr$d <- mapply(function(i, j) dist(s1[[i]][[2]]$x, s2[[j]][[2]]$x, idx_cols(cell$index)), pr$i, pr$j) / u
  pr$cd <- mapply(function(i, j) s1[[i]][[2]]$y - s2[[j]][[2]]$y, pr$i, pr$j)
  do.call(rbind, lapply(MULT, function(m) { a <- pr$d <= m
    if (!any(a)) return(data.frame(mult = m, n_adm = 0, est = NA, se = NA))
    cd <- fe(pr$cd[a], rep(v, sum(a)))
    data.frame(mult = m, n_adm = sum(a), est = ac[["est"]] + cd[["est"]] - bd[["est"]], se = sqrt(ac[["var"]] + cd[["var"]] + bd[["var"]])) }))
}
