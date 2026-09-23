## ---------------------------------------------------------------------------
## OUT-14: assessment grids that differ between trials.
##
## An event at time t assessed on a grid of spacing d is recorded at the next
## visit, t + U with U in [0, d). Treating recorded times as exact inflates
## RMST(tau) = E[min(T, tau)] by E[min(T + U, tau) - min(T, tau)], which for a
## locally flat hazard is about (d / 2) F(tau): half the spacing times the
## probability of an event before tau (DESIGN.md wrote d / 2 without F(tau)).
## Within a trial the shift is common to both arms up to their F(tau) difference;
## across trials with different grids it lands on the contrast.
##
## Unanchored comparison of A (trial 1, grid d1) with B (trial 2, grid d2), both
## single-arm, no covariates: grids are a design feature and no covariate
## balancing can act on them. Weibull event times, administrative censoring.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261006L
N_ARM <- 300L; TAU <- 24; ADMIN <- 36; SHAPE <- 1.2
N_SIM <- 1000L
LEVELS <- list(d1 = c(0, 1, 2, 3), d2 = c(0, 3), median_A = c(8, 16), effect = c(0, 3))

build_grid <- function() {
  g <- expand.grid(d1 = LEVELS$d1, d2 = LEVELS$d2, median_A = LEVELS$median_A,
                   effect = LEVELS$effect, KEEP.OUT.ATTRS = FALSE)
  g$cell <- seq_len(nrow(g)); g
}

scale_for <- function(med) med / log(2)^(1 / SHAPE)
rmst_true <- function(med) stats::integrate(function(t) exp(-(t / scale_for(med))^SHAPE), 0, TAU)$value
## B's median is A's plus `effect` months.
truth <- function(cell) rmst_true(cell$median_A + cell$effect) - rmst_true(cell$median_A)
predicted_shift <- function(med, d) (d / 2) * (1 - exp(-(TAU / scale_for(med))^SHAPE))
predicted_bias <- function(cell) predicted_shift(cell$median_A + cell$effect, cell$d2) -
  predicted_shift(cell$median_A, cell$d1)

## Recorded data for one arm: event at the next visit on grid d (exact if d = 0);
## censoring at the administrative date, and a visit-free right-censoring time
## drawn uniformly over follow-up to mimic dropout.
draw_arm <- function(med, d) {
  t <- stats::rweibull(N_ARM, SHAPE, scale_for(med))
  cens <- pmin(ADMIN, stats::runif(N_ARM, 12, 60))
  ev <- t <= cens
  rec <- if (d > 0) ceiling(t / d) * d else t
  ## an event recorded after the censoring time is seen as censored at the last
  ## visit before censoring
  last_visit <- if (d > 0) floor(cens / d) * d else cens
  obs_ev <- ev & rec <= cens
  time <- ifelse(obs_ev, rec, ifelse(ev, last_visit, cens))
  left <- ifelse(obs_ev, if (d > 0) rec - d else rec, time)
  data.frame(time = pmax(time, 1e-6), status = as.integer(obs_ev), left = left)
}

km_rmst <- function(time, status) {
  f <- survival::survfit(survival::Surv(time, status) ~ 1)
  tt <- c(0, f$time[f$time <= TAU], TAU); ss <- c(1, f$surv[f$time <= TAU])
  sum(diff(tt) * ss)
}

## Interval-censored Weibull: event in (left, time], right-censored at time.
ic_rmst <- function(a) {
  L <- ifelse(a$status == 1, pmax(a$left, 1e-6), a$time); R <- ifelse(a$status == 1, a$time, NA)
  f <- survival::survreg(survival::Surv(L, R, type = "interval2") ~ 1, dist = "weibull")
  sh <- 1 / f$scale; sc <- exp(stats::coef(f)[[1]])
  stats::integrate(function(t) exp(-(t / sc)^sh), 0, TAU)$value
}

fit_all <- function(cell) {
  a <- draw_arm(cell$median_A, cell$d1); b <- draw_arm(cell$median_A + cell$effect, cell$d2)
  mid <- function(x, d) { x$time <- ifelse(x$status == 1 & d > 0, x$time - d / 2, x$time); x }
  am <- mid(a, cell$d1); bm <- mid(b, cell$d2)
  c(naive = km_rmst(b$time, b$status) - km_rmst(a$time, a$status),
    midpoint = km_rmst(bm$time, bm$status) - km_rmst(am$time, am$status),
    interval = ic_rmst(b) - ic_rmst(a))
}
