## ---------------------------------------------------------------------------
## QBA-24: does a hazard-scale bias translate proportionally into RMST?
##
## Population-level calculation. Baseline cumulative hazard H(t) of four shapes,
## each scaled so that survival at TAU = 24 months is S_TAU (0.8, 0.5 or 0.2):
## constant (Weibull 1), increasing (Weibull 1.5), decreasing (Weibull 0.7), and
## bathtub (half decreasing Weibull 0.5, half increasing Weibull 3 by TAU).
## A bias gamma multiplies the hazard: S*(t) = exp(-exp(gamma) H(t)).
## Delta RMST(gamma) = RMST* - RMST over [0, TAU]; the first-order slope at 0 is
## -integral_0^TAU S(u) H(u) du, and the "proportional reinterpretation" predicts
## Delta = gamma times that slope.
## ---------------------------------------------------------------------------

TAU <- 24; GAMMAS <- log(c(1.1, 1.25, 1.5, 2)); S_TAUS <- c(0.8, 0.5, 0.2)
SHAPES <- c("constant", "increasing", "decreasing", "bathtub")
H_unit <- function(shape, t) switch(shape, constant = t / TAU, increasing = (t / TAU)^1.5, decreasing = (t / TAU)^0.7,
                                    bathtub = 0.5 * (t / TAU)^0.5 + 0.5 * (t / TAU)^3)
rmst <- function(shape, s_tau, gamma) { c0 <- -log(s_tau)
  stats::integrate(function(u) exp(-exp(gamma) * c0 * H_unit(shape, u)), 0, TAU, rel.tol = 1e-10)$value }
slope0 <- function(shape, s_tau) { c0 <- -log(s_tau)
  -stats::integrate(function(u) exp(-c0 * H_unit(shape, u)) * c0 * H_unit(shape, u), 0, TAU, rel.tol = 1e-10)$value }
