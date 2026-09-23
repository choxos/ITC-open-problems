## ---------------------------------------------------------------------------
## QBA-07: outcome ascertainment in an external comparator.
##
## Unanchored RMST(24) difference between a trial arm A (visits every 2 months,
## every progression detected at the next visit) and an external arm B from
## routine care (visits about every 3 months). Event times Weibull (shape 1.2)
## with a frailty exp(0.6 Z), Z ~ N(0, 1). In B:
##   visiting  regular (every 3 months) or informative (patient-specific spacing
##             3 exp(-0.5 Z) / E[exp(-0.5 Z)], so higher-risk patients are seen
##             more often)
##   detection each visit after the event detects it with probability SE_B;
##             missed events are found at a later visit or not at all
## Administrative end 36 months; dropout uniform on 12 to 60 months.
## Estimand: RMST(24) of B minus A from true event times.
## Methods: Kaplan-Meier on recorded times; midpoint of each patient's last
## negative and detecting visit; interval-censored Weibull with the event in
## (last negative visit, detecting visit].
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261101L
N_ARM <- 300L; TAU <- 24; ADMIN <- 36; SHAPE <- 1.2; SIG <- 0.6; MED_A <- 12; N_SIM <- 1000L
LEVELS <- list(se_b = c(1, 0.85, 0.7), visiting = c("regular", "informative"), effect = c(0, 3))
build_grid <- function() { g <- expand.grid(se_b = LEVELS$se_b, visiting = LEVELS$visiting, effect = LEVELS$effect, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE); g$cell <- seq_len(nrow(g)); g }
scale_for <- function(med) med / log(2)^(1 / SHAPE)
EZ <- exp(0.125)                                                                        # E[exp(-0.5 Z)]
rmst_true <- function(med) { z <- stats::qnorm(stats::ppoints(2000)); sc <- scale_for(med)
  mean(sapply(z, function(zz) stats::integrate(function(t) exp(-exp(SIG * zz) * (t / sc)^SHAPE), 0, TAU)$value)) }
.tr <- list()
truth <- function(cell) { k <- as.character(cell$effect); if (is.null(.tr[[k]])) .tr[[k]] <<- rmst_true(MED_A + cell$effect) - rmst_true(MED_A); .tr[[k]] }

draw_arm <- function(med, spacing_fun, se) {
  z <- stats::rnorm(N_ARM); sc <- scale_for(med)
  t <- sc * (stats::rexp(N_ARM) / exp(SIG * z))^(1 / SHAPE)
  cens <- pmin(ADMIN, stats::runif(N_ARM, 12, 60)); sp <- spacing_fun(z)
  out <- t(sapply(seq_len(N_ARM), function(i) {
    visits <- seq(sp[i], cens[i], by = sp[i]); if (!length(visits)) return(c(cens[i], 0, 0))
    after <- visits[visits >= t[i]]
    det <- if (length(after)) after[stats::runif(length(after)) < se][1] else NA
    if (is.na(det)) c(max(visits), 0, 0) else { prev <- max(c(0, visits[visits < det])); c(det, 1, prev) } }))
  data.frame(time = pmax(out[, 1], 1e-6), status = out[, 2], left = out[, 3])
}
km_rmst <- function(time, status) { f <- survival::survfit(survival::Surv(time, status) ~ 1)
  tt <- c(0, f$time[f$time <= TAU], TAU); ss <- c(1, f$surv[f$time <= TAU]); sum(diff(tt) * ss) }
ic_rmst <- function(a) { L <- ifelse(a$status == 1, pmax(a$left, 1e-6), a$time); R <- ifelse(a$status == 1, a$time, NA)
  f <- survival::survreg(survival::Surv(L, R, type = "interval2") ~ 1, dist = "weibull"); sh <- 1 / f$scale; sc <- exp(stats::coef(f)[[1]])
  stats::integrate(function(t) exp(-(t / sc)^sh), 0, TAU)$value }

fit_all <- function(cell) {
  a <- draw_arm(MED_A, function(z) rep(2, length(z)), 1)
  spB <- if (cell$visiting == "regular") function(z) rep(3, length(z)) else function(z) 3 * exp(-0.5 * z) / EZ
  b <- draw_arm(MED_A + cell$effect, spB, cell$se_b)
  mid <- function(x) { x$time <- ifelse(x$status == 1, (x$time + x$left) / 2, x$time); x }
  c(naive = km_rmst(b$time, b$status) - km_rmst(a$time, a$status),
    midpoint = { am <- mid(a); bm <- mid(b); km_rmst(bm$time, bm$status) - km_rmst(am$time, am$status) },
    interval = ic_rmst(b) - ic_rmst(a))
}
