## ---------------------------------------------------------------------------
## DIA-10: does reconstruction error, the access mechanism simulations omit,
## change the ranking of methods, or only their level?
##
## The comparator arm is published as a Kaplan-Meier figure and reconstructed
## with Guyot's algorithm; the data-generating and publication model is OUT-13's
## (R/00-model.R there: 250 patients, Weibull events, pixel-rounded figure, risk
## table every 6 months or none, spread or clustered censoring, fine or coarse
## resolution). Estimand: the arm's RMST to 24 months, which enters an unanchored
## RMST difference additively, so the individual-data arm is common to every
## method and omitted here.
## Methods for the comparator's RMST:
##   km_recon       Kaplan-Meier on the reconstruction (summary of event times)
##   weibull_recon  Weibull fit to the reconstruction (a likelihood on individual
##                  event and censoring times)
##   curve          the digitized curve integrated directly, no reconstruction
## and, as the no-access-error baseline, km_ipd and weibull_ipd on the true data.
## ---------------------------------------------------------------------------

source("../OUT-13-an-ensemble-that-is-not-an-imputation/R/00-model.R")
MASTER_SEED <- 20261211L; N_SIM_DIA <- 1000L
build_grid_dia <- function() { g <- expand.grid(res = names(RES), table = c(6, 0), cens = c("spread", "clustered"), KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE); g$cell <- seq_len(nrow(g)); g }
TRUE_RMST <- stats::integrate(S_pop, 0, TAU)$value
rmst_km <- function(d) summary(survfit(Surv(time, status) ~ 1, data = d), rmean = TAU)$table[["rmean"]]
rmst_wb <- function(d) { w <- survreg(Surv(pmax(time, 1e-3), status) ~ 1, data = d, dist = "weibull")
  sh <- 1 / w$scale; sc <- exp(stats::coef(w)[[1]]); stats::integrate(function(t) exp(-(t / sc)^sh), 0, TAU)$value }
rmst_curve <- function(pts) { p <- pts[order(pts$time), ]; p <- p[p$time <= TAU, ]; tt <- c(p$time, TAU); sum(diff(tt) * p$surv) }
one_rep_dia <- function(cell) {
  d <- draw(cell); pub <- publish(d, cell); r <- reconstruct(pub$pts, pub)
  c(km_ipd = rmst_km(d), weibull_ipd = rmst_wb(d), km_recon = rmst_km(r), weibull_recon = rmst_wb(r), curve = rmst_curve(pub$pts))
}
