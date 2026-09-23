## ---------------------------------------------------------------------------
## HET-03: at what number of studies per class can a shared and a separate
## between-study variance be told apart?
##
## Two treatment classes, each with m studies of a class-specific effect; study
## estimates y ~ N(theta_k, s^2 + tau_k^2), within-study SE uniform on 0.1 to 0.25,
## tau_1 = 0.1 and tau_2 = 0.1 sqrt(R) for a variance ratio R of 1 (shared is true),
## 2 or 5. Shared and separate REML fits; selection by AIC, by BIC and by the
## likelihood-ratio test at 5% (reference chi-square with 1 df).
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261215L; N_SIM <- 2000L
build_grid <- function() { g <- expand.grid(m = c(2L, 3L, 5L, 8L, 12L, 20L, 40L), ratio = c(1, 2, 5), KEEP.OUT.ATTRS = FALSE); g$cell <- seq_len(nrow(g)); g }
reml_ll <- function(y, s2, grp, t2g) { t2 <- t2g[grp]; w <- 1 / (s2 + t2)
  mu <- tapply(w * y, grp, sum) / tapply(w, grp, sum); r <- y - mu[grp]
  -0.5 * (sum(log(s2 + t2)) + sum(log(tapply(w, grp, sum))) + sum(w * r^2)) }
fit_shared <- function(y, s2, grp) { o <- stats::optimize(function(lt) -reml_ll(y, s2, grp, rep(exp(lt), 2)), c(-15, 2)); c(ll = -o$objective, k = 1) }
fit_sep <- function(y, s2, grp) { o <- stats::optim(c(log(0.01), log(0.01)), function(lt) -reml_ll(y, s2, grp, exp(lt)), method = "L-BFGS-B", lower = -15, upper = 2); c(ll = -o$value, k = 2) }
one_rep <- function(cell) { grp <- rep(1:2, each = cell$m); s2 <- stats::runif(2 * cell$m, 0.1, 0.25)^2; tk <- c(0.1, 0.1 * sqrt(cell$ratio))
  y <- c(-0.3, -0.5)[grp] + stats::rnorm(2 * cell$m, 0, tk[grp]) + stats::rnorm(2 * cell$m, 0, sqrt(s2))
  a <- fit_shared(y, s2, grp); b <- fit_sep(y, s2, grp); n <- 2 * cell$m - 2
  lr <- max(0, 2 * (b[["ll"]] - a[["ll"]]))
  c(aic_sep = (-2 * b[["ll"]] + 2 * 2) < (-2 * a[["ll"]] + 2 * 1), bic_sep = (-2 * b[["ll"]] + log(n) * 2) < (-2 * a[["ll"]] + log(n) * 1),
    lrt_sep = lr > stats::qchisq(0.95, 1)) }
