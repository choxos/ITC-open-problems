## ---------------------------------------------------------------------------
## SFW-12: how far outstandR's G-computation estimate moves across target
## reconstructions.
##
## outstandR 2.0.0 (CRAN) reconstructs the aggregate trial's covariates from their
## published means and SDs with normal margins and a Gaussian copula whose
## parameter is, by default, the IPD's Pearson correlation. Here the target's
## covariates are skewed (x1 ~ Gamma(2, 2), x2 ~ Gamma(4, 4)) with a Clayton or
## Gaussian copula at Pearson correlation 0.5; the IPD trial's covariates come from
## Gamma(2, 2.5) and Gamma(4, 5) with a Gaussian copula at correlation 0.5 (same)
## or 0.1 (different). Binary outcome
##   logit p = -1 + 0.5 x1 + 0.5 x2 + a (-0.5 + 0.6 x1 + 0.4 x2)   (A)
## with B's effect -0.7 + 0.6 x1 + 0.4 x2. 300 per arm in each trial.
## Estimand: anchored marginal log OR of B versus A in the target.
## outstandR's internal gcomp_ml_means() is called directly (no bootstrap) with
## N = 20000 pseudo-patients under five reconstructions:
##   default       normal margins, IPD correlation
##   rho_target    normal margins, the target's sample correlation (if it were reported)
##   rho_zero      normal margins, independence
##   gamma         gamma margins by moments, IPD correlation
##   gamma_target  gamma margins, target correlation
## ---------------------------------------------------------------------------

suppressPackageStartupMessages({ library(outstandR); library(copula) })
MASTER_SEED <- 20261214L; N_ARM <- 300L; N_SIM <- 400L; N_PSEUDO <- 20000L
build_grid <- function() { g <- expand.grid(target_copula = c("gaussian", "clayton"), source_rho = c(0.5, 0.1), KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE); g$cell <- seq_len(nrow(g)); g }
TGT <- list(shape = c(2, 4), rate = c(2, 4)); SRC <- list(shape = c(2, 4), rate = c(2.5, 5))
## Copula parameters giving Pearson 0.5 on the gamma margins (Monte Carlo, fixed seed).
cal_param <- function(fam, r, margins) { old <- if (exists(".Random.seed", .GlobalEnv)) get(".Random.seed", .GlobalEnv) else NULL; on.exit(if (!is.null(old)) assign(".Random.seed", old, .GlobalEnv))
  f <- function(p) { set.seed(3); u <- rCopula(1e5, if (fam == "clayton") claytonCopula(p) else normalCopula(p))
    stats::cor(stats::qgamma(u[, 1], margins$shape[1], margins$rate[1]), stats::qgamma(u[, 2], margins$shape[2], margins$rate[2])) - r }
  stats::uniroot(f, if (fam == "clayton") c(0.01, 10) else c(0.01, 0.99))$root }
draw_x <- function(n, fam, p, margins) { u <- rCopula(n, if (fam == "clayton") claytonCopula(p) else normalCopula(p))
  data.frame(x1 = stats::qgamma(u[, 1], margins$shape[1], margins$rate[1]), x2 = stats::qgamma(u[, 2], margins$shape[2], margins$rate[2])) }
eta <- function(x, a, eff) -1 + 0.5 * x$x1 + 0.5 * x$x2 + a * (eff + 0.6 * x$x1 + 0.4 * x$x2)
truth <- function(cell, par_t) { old <- if (exists(".Random.seed", .GlobalEnv)) get(".Random.seed", .GlobalEnv) else NULL; set.seed(9)
  x <- draw_x(2e6, cell$target_copula, par_t, TGT); if (!is.null(old)) assign(".Random.seed", old, .GlobalEnv)
  lo <- function(eff) stats::qlogis(mean(stats::plogis(eta(x, 1, eff)))) - stats::qlogis(mean(stats::plogis(eta(x, 0, eff))))
  lo(-0.7) - lo(-0.5) }
one_rep <- function(cell, par_s, par_t) {
  xs <- draw_x(2 * N_ARM, "gaussian", par_s, SRC); a <- rep(0:1, each = N_ARM)
  ipd <- data.frame(xs, trt = factor(ifelse(a == 1, "A", "C"), levels = c("C", "A")), y = stats::rbinom(2 * N_ARM, 1, stats::plogis(eta(xs, a, -0.5))))
  xt <- draw_x(2 * N_ARM, cell$target_copula, par_t, TGT); yb <- stats::rbinom(2 * N_ARM, 1, stats::plogis(eta(xt, a, -0.7)))
  ald <- data.frame(variable = c("x1", "x1", "x2", "x2"), statistic = c("mean", "sd", "mean", "sd"), value = c(mean(xt$x1), stats::sd(xt$x1), mean(xt$x2), stats::sd(xt$x2)), trt = NA_character_)
  d_bc <- stats::qlogis(mean(yb[a == 1])) - stats::qlogis(mean(yb[a == 0]))
  rt <- stats::cor(xt$x1, xt$x2); mom <- function(m, s) list(shape = (m / s)^2, rate = m / s^2)
  gm <- list(x1 = mom(ald$value[1], ald$value[2]), x2 = mom(ald$value[3], ald$value[4]))
  specs <- list(default = list(rho = NA, d = NA, p = NA), rho_target = list(rho = rt, d = NA, p = NA), rho_zero = list(rho = 0, d = NA, p = NA),
                gamma = list(rho = NA, d = c(x1 = "gamma", x2 = "gamma"), p = gm), gamma_target = list(rho = rt, d = c(x1 = "gamma", x2 = "gamma"), p = gm))
  est <- vapply(specs, function(sp) { r <- outstandR:::gcomp_ml_means(outcome_model = y ~ x1 + x2 + trt * x1 + trt * x2, family = stats::binomial(), trt_var = "trt",
      ref_trt = "C", comp_trt = "A", rho = sp$rho, N = N_PSEUDO, marginal_distns = sp$d, marginal_params = sp$p, ald = ald, ipd = ipd)
    d_bc - (stats::qlogis(r$stats[["1"]]) - stats::qlogis(r$stats[["0"]])) }, 0)
  data.frame(method = names(est), est = unname(est))
}
