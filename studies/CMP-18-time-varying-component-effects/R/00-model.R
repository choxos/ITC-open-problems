## ---------------------------------------------------------------------------
## CMP-18: time-constant component effects when the components' effects vary in
## time differently.
##
## Control hazard: Weibull, shape 1.2, scale 3 years. Component log hazard ratios:
##   constant  A -0.4, B -0.4
##   same      both delayed: -0.5 (1 - exp(-t / 0.7))
##   different A delayed as above, B waning: -0.5 exp(-t / 0.7)
## Two trials, A versus control and B versus control, 300 per arm, administrative
## censoring at F_A and F_B years. Estimand: RMST to 3 years of the combination A+B
## (log hazard ratios add) minus control, in the trials' common population.
## Models, both stratified by trial with additive component effects:
##   constant   Cox with time-constant A and B effects
##   piecewise  Cox with A and B effects separate before and after 1 year
## Prediction: control cumulative hazard from the Nelson-Aalen estimate of trial
## 1's control arm times the fitted hazard ratios; SEs from a 60-resample
## bootstrap within trial arms, re-estimating the baseline and the coefficients.
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(survival))
MASTER_SEED <- 20261212L; N_ARM <- 300L; N_SIM <- 500L; N_BOOT <- 60L; TAU <- 3; SH <- 1.2; SC <- 3
build_grid <- function() { g <- data.frame(profile = c("constant", "same", "different", "different"), fa = c(3, 3, 3, 1.5), fb = c(3, 3, 3, 3), stringsAsFactors = FALSE); g$cell <- seq_len(nrow(g)); g }
lhr <- function(t, comp, profile) switch(profile, constant = rep(-0.4, length(t)),
  same = -0.5 * (1 - exp(-t / 0.7)), different = if (comp == "A") -0.5 * (1 - exp(-t / 0.7)) else -0.5 * exp(-t / 0.7))
TG <- seq(0, 10, by = 0.005)
h0 <- function(t) SH / SC * (t / SC)^(SH - 1)
cumhaz <- function(comps, profile) { lh <- Reduce(`+`, lapply(comps, function(k) lhr(TG, k, profile)), 0 * TG)
  c(0, cumsum(diff(TG) * (h0(TG[-1]) * exp(lh[-1])))) }
rmst_from_H <- function(H, grid = TG) { s <- exp(-H); k <- grid <= TAU; sum(diff(grid[k]) * s[k][-1]) }
truth <- function(cell) rmst_from_H(cumhaz(c("A", "B"), cell$profile)) - rmst_from_H(cumhaz(character(0), cell$profile))
draw_times <- function(n, comps, profile) { H <- cumhaz(comps, profile); e <- stats::rexp(n); t <- stats::approx(H, TG, xout = e, rule = 2)$y; t[e > max(H)] <- max(TG); t }
draw <- function(cell) do.call(rbind, lapply(1:2, function(j) { comp <- c("A", "B")[j]; f <- c(cell$fa, cell$fb)[j]
  t0 <- draw_times(N_ARM, character(0), cell$profile); t1 <- draw_times(N_ARM, comp, cell$profile)
  data.frame(trial = j, A = as.integer(comp == "A") * rep(0:1, each = N_ARM), B = as.integer(comp == "B") * rep(0:1, each = N_ARM),
             time = pmin(c(t0, t1), f), status = as.integer(c(t0, t1) <= f)) }))
predict_rmst <- function(H0t, grid, lhr_fun) { H <- c(0, cumsum(diff(grid) * diff(c(0, H0t))[-1] / diff(grid) * exp(lhr_fun(grid[-1])))); rmst_from_H(H, grid) - rmst_from_H(H0t, grid) }
fit_all <- function(d) {
  ## Baseline: Breslow cumulative hazard of trial 1's control arm on a grid.
  g <- seq(0, TAU, by = 0.01); c1 <- d[d$trial == 1 & d$A == 0, ]; km <- survfit(Surv(time, status) ~ 1, data = c1)
  H0 <- stats::approx(c(0, km$time), c(0, cumsum(km$n.event / km$n.risk)), xout = g, method = "constant", rule = 2, f = 0)$y
  inc <- function(lh) { dH <- diff(H0) * exp(lh(g[-1])); H <- c(0, cumsum(dH)); sum(diff(g) * exp(-H)[-1]) - sum(diff(g) * exp(-H0)[-1]) }
  f1 <- coxph(Surv(time, status) ~ A + B + strata(trial), data = d); b1 <- stats::coef(f1)
  est1 <- inc(function(t) b1[["A"]] + b1[["B"]] + 0 * t)
  ds <- survSplit(Surv(time, status) ~ ., data = d, cut = 1, episode = "per")
  ds$A1 <- ds$A * (ds$per == 1); ds$A2 <- ds$A * (ds$per == 2); ds$B1 <- ds$B * (ds$per == 1); ds$B2 <- ds$B * (ds$per == 2)
  f2 <- coxph(Surv(tstart, time, status) ~ A1 + A2 + B1 + B2 + strata(trial), data = ds); b2 <- stats::coef(f2)
  est2 <- if (any(is.na(b2))) NA else inc(function(t) ifelse(t < 1, b2[1] + b2[3], b2[2] + b2[4]))
  c(constant = est1, piecewise = est2)
}
one_rep <- function(cell) { d <- draw(cell); e <- fit_all(d); grp <- interaction(d$trial, d$A + d$B)
  bs <- replicate(N_BOOT, { i <- unlist(lapply(split(seq_len(nrow(d)), grp), function(j) sample(j, replace = TRUE))); tryCatch(fit_all(d[i, ]), error = function(err) c(NA, NA)) })
  data.frame(method = names(e), est = unname(e), se = apply(bs, 1, stats::sd, na.rm = TRUE)) }
