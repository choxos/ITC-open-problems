## ---------------------------------------------------------------------------
## SFW-14: testing drMAIC 0.1.0 (CRAN) against the properties it claims.
##
## Unanchored: individual data on 300 patients of A; the target publishes means
## and the SD of x1, the proportion with x2 = 1, and B's response proportion and
## its SE (from 300 patients). x1 ~ N(0, 1), x2 ~ Bern(0.4) in the source;
## x1 ~ N(M1_T, 0.8^2), x2 ~ Bern(0.6) in the target.
## logit P(Y = 1) = -0.5 + 0.6 x1 + 0.5 x2 + 0.4 x1^2 for A; B adds -0.4.
## Estimand: marginal log odds ratio, A versus B, in the target (drMAIC reports
## the individual-data treatment minus the comparator).
## 2 x 2: weighting correct (means and x1's second moment) or wrong (means only);
## outcome model correct (with x1^2) or wrong (linear).
## Estimators: drMAIC's itc_maic and itc_dr with its analytic interval; a correctly
## augmented estimator, E_T[m-hat] over the published target law plus the
## weighted residual mean, with a nonparametric bootstrap SE.
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(drMAIC))
MASTER_SEED <- 20261102L; N <- 300L; N_B <- 300L; SD1_T <- 0.8; P2_T <- 0.6; B_EFF <- -0.4; N_SIM <- 600L; N_BOOT <- 50L; N_SIM_BOOT <- 150L; R_PKG <- 200L
LEVELS <- list(weights = c("right", "wrong"), outcome = c("right", "wrong"), m1_t = c(0.5, 1))
build_grid <- function() { g <- expand.grid(weights = LEVELS$weights, outcome = LEVELS$outcome, m1_t = LEVELS$m1_t, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE); g$cell <- seq_len(nrow(g)); g }
lin <- function(x1, x2) -0.5 + 0.6 * x1 + 0.5 * x2 + 0.4 * x1^2
truth <- function(cell) { z <- stats::qnorm(stats::ppoints(4000), cell$m1_t, SD1_T)
  pa <- P2_T * mean(stats::plogis(lin(z, 1))) + (1 - P2_T) * mean(stats::plogis(lin(z, 0)))
  pb <- P2_T * mean(stats::plogis(lin(z, 1) + B_EFF)) + (1 - P2_T) * mean(stats::plogis(lin(z, 0) + B_EFF))
  stats::qlogis(pa) - stats::qlogis(pb) }

draw <- function(cell) { x1 <- stats::rnorm(N); x2 <- stats::rbinom(N, 1, 0.4); y <- stats::rbinom(N, 1, stats::plogis(lin(x1, x2)))
  zb <- stats::rnorm(N_B, cell$m1_t, SD1_T); xb <- stats::rbinom(N_B, 1, P2_T); yb <- stats::rbinom(N_B, 1, stats::plogis(lin(zb, xb) + B_EFF))
  list(ipd = data.frame(x1 = x1, x2 = x2, y = y), pB = mean(yb), seB = sqrt(mean(yb) * (1 - mean(yb)) / N_B)) }

PSEUDO <- NULL
pseudo <- function(m1) { u <- stats::qnorm(stats::ppoints(2000)); data.frame(x1 = rep(m1 + SD1_T * u, 2), x2 = rep(c(1, 0), each = 2000), wt = rep(c(P2_T, 1 - P2_T), each = 2000)) }

fit_all <- function(cell, d) {
  tm <- c(x1 = cell$m1_t, x2 = P2_T, x1_sd = SD1_T)
  w <- if (cell$weights == "right") compute_weights(d$ipd, tm, match_vars = c("x1", "x2"), match_var_types = c(x1 = "mean_sd", x2 = "binary"), verbose = FALSE) else
    compute_weights(d$ipd, tm[1:2], match_vars = c("x1", "x2"), verbose = FALSE)
  fo <- if (cell$outcome == "right") y ~ x1 + x2 + I(x1^2) else y ~ x1 + x2
  r <- suppressWarnings(dr_maic(w, outcome_var = "y", outcome_type = "binary", comparator_estimate = d$pB, comparator_se = d$seB, effect_measure = "OR",
                                outcome_model_formula = fo, outcome_model_family = stats::binomial()))
  ## Correct augmentation: outcome model averaged over the published target law.
  aug <- function(dd, wn) { f <- suppressWarnings(stats::glm(fo, family = stats::binomial(), data = dd)); ps <- pseudo(cell$m1_t)
    et <- sum(ps$wt * stats::predict(f, newdata = ps, type = "response")) / sum(ps$wt); et + sum(wn * (dd$y - stats::fitted(f))) }
  wn <- w$weights; pa <- aug(d$ipd, wn)
  bs <- replicate(N_BOOT, { i <- sample.int(N, replace = TRUE); dd <- d$ipd[i, ]
    wb <- tryCatch(if (cell$weights == "right") compute_weights(dd, tm, match_vars = c("x1", "x2"), match_var_types = c(x1 = "mean_sd", x2 = "binary"), verbose = FALSE) else
      compute_weights(dd, tm[1:2], match_vars = c("x1", "x2"), verbose = FALSE), error = function(e) NULL)
    if (is.null(wb)) NA else stats::qlogis(aug(dd, wb$weights)) })
  est_aug <- stats::qlogis(pa) - stats::qlogis(d$pB)
  se_aug <- sqrt(stats::var(bs, na.rm = TRUE) + d$seB^2 / (d$pB * (1 - d$pB))^2)
  c(itc_maic = unname(r$itc_maic), itc_dr = unname(r$itc_dr), dr_minus_maic = unname(r$theta_dr - r$theta_maic),
    lo_pkg = unname(r$ci_lower), hi_pkg = unname(r$ci_upper), se_pkg = unname(r$se_itc_dr), est_aug = est_aug, se_aug = se_aug, ess = w$ess)
}

## The package's own bootstrap interval (percentile) for itc_dr.
boot_pkg <- function(cell, d) {
  tm <- c(x1 = cell$m1_t, x2 = P2_T, x1_sd = SD1_T)
  w <- if (cell$weights == "right") compute_weights(d$ipd, tm, match_vars = c("x1", "x2"), match_var_types = c(x1 = "mean_sd", x2 = "binary"), verbose = FALSE) else
    compute_weights(d$ipd, tm[1:2], match_vars = c("x1", "x2"), verbose = FALSE)
  fo <- if (cell$outcome == "right") y ~ x1 + x2 + I(x1^2) else y ~ x1 + x2
  r <- suppressWarnings(dr_maic(w, outcome_var = "y", outcome_type = "binary", comparator_estimate = d$pB, comparator_se = d$seB, effect_measure = "OR",
                                outcome_model_formula = fo, outcome_model_family = stats::binomial()))
  b <- suppressWarnings(suppressMessages(bootstrap_ci(r, R = R_PKG, ci_type = "perc", verbose = FALSE)))
  c(itc_dr = unname(r$itc_dr), lo = unname(b$ci_dr[1]), hi = unname(b$ci_dr[2]))
}
