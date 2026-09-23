## ---------------------------------------------------------------------------
## OUT-07: informative censoring in the source and the comparator of an indirect
## comparison, and whether the biases cancel.
##
## Latent frailty U ~ N(0, 1). Event hazard lambda_arm exp(0.7 U); censoring hazard
## kappa exp(alpha U), alpha the dependence of censoring on latent risk; kappa set
## for the censoring prevalence by TAU. Administrative end at 36; estimand RMST at
## TAU = 24 from complete data. Source trial: arm A (and C when anchored), alpha_S;
## comparator: arm B (and C when anchored), alpha_T. A baseline proxy W = 0.7 U +
## noise is recorded in the source only.
## Kaplan-Meier treats censoring as independent, so higher-risk patients censored
## early make survival look better. The contrast carries c_S - c_T.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261019L
N_ARM <- 300L; TAU <- 24; END <- 36; GU <- 0.7; N_SIM <- 1000L
LAMBDA <- c(A = 0.045, B = 0.05, C = 0.07)
LEVELS <- list(alpha_s = c(0, 1), alpha_t = c(0, 1, 2), prev = c(0.2, 0.5), design = c("unanchored", "anchored"))
build_grid <- function() {
  g <- expand.grid(alpha_s = LEVELS$alpha_s, alpha_t = LEVELS$alpha_t, prev = LEVELS$prev, design = LEVELS$design,
                   KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$cell <- seq_len(nrow(g)); g
}

.u <- NULL
ubank <- function() { if (is.null(.u)) { old <- if (exists(".Random.seed", .GlobalEnv)) get(".Random.seed", .GlobalEnv) else NULL
  set.seed(17); .u <<- stats::rnorm(2e5); if (!is.null(old)) assign(".Random.seed", old, .GlobalEnv) }; .u }
rmst_true <- function(arm) { u <- ubank(); h <- LAMBDA[[arm]] * exp(GU * u); mean((1 - exp(-h * TAU)) / h) }
## Censoring rate kappa giving P(censored before TAU and before the event) = prev.
.kap <- list()
kappa_for <- function(arm, alpha, prev) { key <- paste(arm, alpha, prev)
  if (is.null(.kap[[key]])) { u <- ubank()[1:5e4]; h <- LAMBDA[[arm]] * exp(GU * u)
    f <- function(k) { hc <- k * exp(alpha * u); mean(hc / (h + hc) * (1 - exp(-(h + hc) * TAU))) - prev }
    .kap[[key]] <<- stats::uniroot(f, c(1e-5, 5))$root }
  .kap[[key]] }

.tr <- list()
truth <- function(cell) { if (is.null(.tr[[cell$design]])) .tr[[cell$design]] <<- if (cell$design == "unanchored") rmst_true("A") - rmst_true("B") else
  (rmst_true("A") - rmst_true("C")) - (rmst_true("B") - rmst_true("C")); .tr[[cell$design]] }

sim_arm <- function(arm, alpha, prev, n = N_ARM) {
  u <- stats::rnorm(n); h <- LAMBDA[[arm]] * exp(GU * u); k <- kappa_for(arm, alpha, prev)
  t <- stats::rexp(n, h); cz <- pmin(stats::rexp(n, k * exp(alpha * u)), END)
  data.frame(time = pmin(t, cz), event = as.numeric(t <= cz), w = 0.7 * u + sqrt(1 - 0.49) * stats::rnorm(n))
}

## RMST to TAU from a (weighted) Kaplan-Meier curve; SE by the delta method on the
## unweighted curve.
km_rmst <- function(time, event, wt = rep(1, length(time))) {
  o <- order(time); time <- time[o]; event <- event[o]; wt <- wt[o]
  ut <- sort(unique(time[event == 1 & time <= TAU])); s <- 1; S <- numeric(0); var_terms <- numeric(0)
  for (tt in ut) { r <- sum(wt[time >= tt]); dd <- sum(wt[time == tt & event == 1]); s <- s * (1 - dd / r); S <- c(S, s)
    var_terms <- c(var_terms, dd / (r * (r - dd))) }
  grid <- c(0, ut, TAU); Sv <- c(1, S); area <- sum(Sv * diff(grid))
  ## Greenwood-type variance of RMST.
  tail_area <- rev(cumsum(rev(Sv[-1] * diff(grid)[-1])))
  v <- sum(tail_area^2 * var_terms)
  c(rmst = area, se = sqrt(v))
}

## IPCW on the source side: exponential censoring model log-linear in W,
## weights 1 / S_C(t | W) at each patient's own time, applied as time-varying
## risk-set weights through a person-period approximation at the event times.
ipcw_rmst <- function(d) {
  f <- stats::glm(I(1 - event) ~ w + offset(log(time)), family = stats::poisson(), data = d[d$time < END, , drop = FALSE])
  k <- exp(stats::coef(f)[1] + stats::coef(f)[2] * d$w)
  o <- order(d$time); d <- d[o, ]; k <- k[o]
  ut <- sort(unique(d$time[d$event == 1 & d$time <= TAU])); s <- 1; S <- numeric(0)
  for (tt in ut) { at <- d$time >= tt; wr <- exp(k[at] * tt); r <- sum(wr); dd <- sum(wr[d$time[at] == tt & d$event[at] == 1]); s <- s * (1 - dd / r); S <- c(S, s) }
  grid <- c(0, ut, TAU); sum(c(1, S) * diff(grid))
}

## Comparator-side delta adjustment: censored patients' remaining lifetime is
## exponential with rate delta times the arm's crude event rate; closed form.
delta_rmst <- function(d, delta) {
  h <- sum(d$event) / sum(d$time); r <- delta * h
  mean(ifelse(d$event == 1 & d$time <= TAU, d$time, ifelse(d$time >= TAU, TAU, d$time + (1 - exp(-r * (TAU - d$time))) / r)))
}

draw <- function(cell) {
  src <- list(A = sim_arm("A", cell$alpha_s, cell$prev)); cmp <- list(B = sim_arm("B", cell$alpha_t, cell$prev))
  if (cell$design == "anchored") { src$C <- sim_arm("C", cell$alpha_s, cell$prev); cmp$C <- sim_arm("C", cell$alpha_t, cell$prev) }
  list(src = src, cmp = cmp)
}

fit_all <- function(cell, dd) {
  km <- function(z) km_rmst(z$time, z$event)
  a <- km(dd$src$A); b <- km(dd$cmp$B); ai <- ipcw_rmst(dd$src$A)
  if (cell$design == "unanchored") {
    naive <- a[1] - b[1]; se <- sqrt(a[2]^2 + b[2]^2); ip <- ai - b[1]
    bfun <- function(dl) ai - delta_rmst(dd$cmp$B, dl)
  } else {
    c1 <- km(dd$src$C); c2 <- km(dd$cmp$C); ci <- ipcw_rmst(dd$src$C)
    naive <- (a[1] - c1[1]) - (b[1] - c2[1]); se <- sqrt(a[2]^2 + c1[2]^2 + b[2]^2 + c2[2]^2); ip <- (ai - ci) - (b[1] - c2[1])
    bfun <- function(dl) (ai - ci) - (delta_rmst(dd$cmp$B, dl) - delta_rmst(dd$cmp$C, dl))
  }
  ## One-sided comparator sensitivity (delta = 1 is independent censoring): does
  ## the decision (A better if the contrast is positive) change for delta in
  ## [0.5, 2], and which delta reproduces the true contrast (known only here).
  cs <- sapply(c(0.5, 1, 2), bfun)
  dtrue <- tryCatch(stats::uniroot(function(dl) bfun(dl) - truth(cell), c(0.1, 20))$root, error = function(e) NA)
  c(naive = unname(naive), naive_se = unname(se), ipcw = unname(ip), sens_lo = cs[1], sens_mid = cs[2], sens_hi = cs[3],
    fragile = as.numeric(length(unique(sign(cs))) > 1), delta_true = dtrue)
}
