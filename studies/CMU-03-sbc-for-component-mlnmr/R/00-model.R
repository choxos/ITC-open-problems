## ---------------------------------------------------------------------------
## CMU-03: simulation-based calibration of ML-NMR under two replicate
## constructions, with data-dependent test quantities and two broken
## implementations.
##
## Network: one IPD study (P vs A) and four aggregate studies (P vs B), 200 per
## arm, covariates x1, x2 independent with SD 1. Binomial logit ML-NMR fitted by
## multinma 0.9.1 (fixed effects, center = FALSE, QR = FALSE):
##   logit p = mu_j + x'b + d_k + x'g_k,   k in {A, B}, d_P = g_P = 0,
## priors mu ~ N(0, 1), d ~ N(0, 1), all 6 regression terms ~ N(0, 0.5^2).
## theta is drawn from exactly these priors. Aggregate arms publish r, n and
## covariate means and SDs; multinma integrates over N(mean, sd) margins with an
## independence copula on Q Sobol points.
## Constructions: coded (aggregate r ~ Bin(n, mean over multinma's own Q points
## of plogis(eta)), identical to the likelihood the fit conditions on) and
## end-to-end (individuals simulated from the true covariate law, outcomes drawn,
## then aggregated). IPD outcomes are Bernoulli in both.
## Posterior: importance sampling on multinma's own log density (rstan::log_prob
## on a Fixed_param stanfit), multivariate t_5 proposal at the Laplace fit,
## Pareto-smoothed weights; S_IS proposal draws. One cell repeats the null with
## multinma's NUTS sampler.
## Test quantities: PIT of each parameter, of the decision contrast (B vs A,
## conditional log odds ratio at target covariates X_T) and of the joint coded
## log-likelihood of the replicate's data (Modrak et al.).
## Broken implementations: "prior" returns prior draws as the posterior; "sign"
## fits a network whose aggregate covariate means carry the wrong sign.
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(multinma))
MASTER_SEED <- 20261303L; N_SIM <- 1000L; N_NUTS <- 200L
N_ARM <- 200L; S_IS <- 4000L; X_T <- c(0.5, 0.5); PSD <- c(mu = 1, d = 1, beta = 0.5)
M_AGD <- list(strong = c(-0.6, -0.2, 0.2, 0.6), weak = rep(0.3, 4))
STUDIES <- paste0("S", 0:4); REG <- c("x1", "x2", ".trtA:x1", ".trtB:x1", ".trtA:x2", ".trtB:x2")
LAB <- c(sprintf("mu[%s]", STUDIES), "d[A]", "d[B]", sprintf("beta[%s]", REG))

build_grid <- function() {
  g <- rbind(data.frame(cons = "coded", Q = 64, margin = "normal", ident = c("strong", "weak"), impl = "correct", sampler = "is"),
             transform(expand.grid(cons = "e2e", Q = c(16, 64, 512), margin = c("normal", "skewed"), ident = c("strong", "weak"),
                                   KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE), impl = "correct", sampler = "is"),
             data.frame(cons = "coded", Q = 64, margin = "normal", ident = "strong", impl = c("prior", "sign"), sampler = "is"),
             data.frame(cons = "coded", Q = 64, margin = "normal", ident = "strong", impl = "correct", sampler = "nuts"))
  g$cell <- seq_len(nrow(g)); g
}

draw_theta <- function() stats::setNames(c(stats::rnorm(5, 0, PSD[["mu"]]), stats::rnorm(2, 0, PSD[["d"]]), stats::rnorm(6, 0, PSD[["beta"]])), LAB)
prior_sd <- c(rep(PSD[["mu"]], 5), rep(PSD[["d"]], 2), rep(PSD[["beta"]], 6))
contrast <- function(th) th[["d[B]"]] - th[["d[A]"]] + sum((th[c("beta[.trtB:x1]", "beta[.trtB:x2]")] - th[c("beta[.trtA:x1]", "beta[.trtA:x2]")]) * X_T)

## Linear predictor for covariate matrix X (n x 2) in study s on treatment k.
eta <- function(th, X, s, k) {
  e <- th[[sprintf("mu[%s]", s)]] + X %*% th[c("beta[x1]", "beta[x2]")]
  if (k != "P") e <- e + th[[sprintf("d[%s]", k)]] + X %*% th[sprintf("beta[.trt%s:x%d]", k, 1:2)]
  drop(e)
}
rcov <- function(n, m, margin) if (margin == "normal") matrix(stats::rnorm(2 * n, m), n) else m + matrix(stats::rexp(2 * n) - 1, n)

agd_summary <- function(X, s, k, r) data.frame(study = s, trt = k, r = r, n = nrow(X), x1_mean = mean(X[, 1]), x1_sd = stats::sd(X[, 1]),
                                               x2_mean = mean(X[, 2]), x2_sd = stats::sd(X[, 2]))
integrate_net <- function(ipd, agd, Q) {
  net <- combine_network(set_ipd(ipd, study, trt, r = y), set_agd_arm(agd, study, trt, r = r, n = n), trt_ref = "P")
  add_integration(net, x1 = distr(qnorm, mean = x1_mean, sd = x1_sd), x2 = distr(qnorm, mean = x2_mean, sd = x2_sd), n_int = Q, cor = diag(2))
}

## One replicate's data: theta, the integrated network the fit sees, and (for the
## sign break) the network the broken implementation sees.
simulate <- function(cell) {
  th <- draw_theta()
  ipd <- do.call(rbind, lapply(c("P", "A"), function(k) { X <- rcov(N_ARM, 0, cell$margin)
    data.frame(study = "S0", trt = k, x1 = X[, 1], x2 = X[, 2], y = stats::rbinom(N_ARM, 1, stats::plogis(eta(th, X, "S0", k)))) }))
  arms <- expand.grid(k = c("P", "B"), j = 1:4, stringsAsFactors = FALSE)
  Xs <- lapply(seq_len(nrow(arms)), function(i) rcov(N_ARM, M_AGD[[cell$ident]][arms$j[i]], cell$margin))
  r0 <- vapply(seq_len(nrow(arms)), function(i) sum(stats::rbinom(N_ARM, 1, stats::plogis(eta(th, Xs[[i]], STUDIES[arms$j[i] + 1], arms$k[i])))), 0)
  agd <- do.call(rbind, lapply(seq_len(nrow(arms)), function(i) agd_summary(Xs[[i]], STUDIES[arms$j[i] + 1], arms$k[i], r0[i])))
  net <- integrate_net(ipd, agd, cell$Q)
  if (cell$cons == "coded") {                        # redraw r from the coded likelihood on multinma's own points
    a <- net$agd_arm; P <- vapply(seq_len(nrow(a)), function(i)
      mean(stats::plogis(eta(th, cbind(a$.int_x1[[i]], a$.int_x2[[i]]), as.character(a$.study[i]), as.character(a$.trt[i])))), 0)
    net$agd_arm$.r <- net$agd_arm$r <- stats::rbinom(nrow(a), a$.n, P)
  }
  fit_net <- net
  if (cell$impl == "sign") { bad <- agd; bad$r <- net$agd_arm$r[match(paste(bad$study, bad$trt), paste(net$agd_arm$.study, net$agd_arm$.trt))]
    bad$x1_mean <- -bad$x1_mean; bad$x2_mean <- -bad$x2_mean; fit_net <- integrate_net(ipd, bad, cell$Q) }
  list(th = th, net = fit_net)
}

stanfit_of <- function(net, ...) nma(net, trt_effects = "fixed", regression = ~(x1 + x2) * .trt, center = FALSE, QR = FALSE,
  prior_intercept = normal(0, PSD[["mu"]]), prior_trt = normal(0, PSD[["d"]]), prior_reg = normal(0, PSD[["beta"]]),
  int_check = FALSE, refresh = 0, ...)$stanfit

## Unconstrained vector (beta_tilde = c(mu, d, beta) when QR = FALSE) from named theta.
upars_order <- function(sf) { fn <- sf@sim$fnames_oi; c(grep("^mu\\[", fn, value = TRUE), grep("^d\\[", fn, value = TRUE), grep("^beta\\[", fn, value = TRUE)) }
logprior <- function(U) -0.5 * colSums((t(U) / prior_sd)^2)

## PIT of the true value of each test quantity among posterior draws: weighted for
## importance sampling, randomized rank (r + U) / (L + 1) for equally weighted draws.
pit <- function(Fd, ftrue, w) vapply(seq_along(ftrue), function(q) if (is.null(w)) (sum(Fd[, q] < ftrue[q]) + stats::runif(1)) / (nrow(Fd) + 1) else
  sum(w[Fd[, q] < ftrue[q]]) + stats::runif(1) * sum(w[Fd[, q] == ftrue[q]]), 0)

one_rep <- function(cell) {
  sm <- simulate(cell); th <- sm$th
  sf <- suppressWarnings(suppressMessages(stanfit_of(sm$net, chains = 2, iter = 1, warmup = 0, algorithm = "Fixed_param")))
  ord <- upars_order(sf); stopifnot(setequal(ord, LAB)); ut <- th[ord]
  lp <- function(u) rstan::log_prob(sf, u, adjust_transform = FALSE)
  ll_true <- lp(ut) - logprior(t(ut)); dg <- c(k_hat = NA, rhat = NA, n_div = NA)
  if (cell$impl == "prior") {                        # broken: the prior returned as the posterior
    U <- t(replicate(S_IS, draw_theta()[ord])); w <- NULL
  } else if (cell$sampler == "nuts") {
    fit <- suppressWarnings(suppressMessages(stanfit_of(sm$net, chains = 2, iter = 1000, warmup = 500, cores = 1, seed = sample.int(1e8, 1))))
    A <- as.array(fit)[, , ord]; keep <- seq(10, dim(A)[1], by = 10)
    U <- do.call(rbind, lapply(1:2, function(ch) A[keep, ch, ])); w <- NULL
    sp <- rstan::get_sampler_params(fit, inc_warmup = FALSE)
    dg <- c(k_hat = NA, rhat = max(apply(A, 3, rstan::Rhat)), n_div = sum(vapply(sp, function(m) sum(m[, "divergent__"]), 0)))
  } else {                                           # importance sampling on the coded posterior
    fn <- function(u) -lp(u); gr <- function(u) -rstan::grad_log_prob(sf, u, adjust_transform = FALSE)
    op <- stats::optim(rep(0, length(ord)), fn, gr, method = "BFGS", control = list(maxit = 2000, reltol = 1e-12))
    Sig <- solve(stats::optimHess(op$par, fn, gr)); Sig <- (Sig + t(Sig)) / 2
    is_run <- function(S, df, infl) { U <- mvtnorm::rmvt(S, sigma = Sig * infl, df = df, delta = op$par)
      lw <- apply(U, 1, lp) - mvtnorm::dmvt(U, delta = op$par, sigma = Sig * infl, df = df, log = TRUE)
      ps <- suppressWarnings(loo::psis(lw, r_eff = 1)); list(U = U, w = stats::weights(ps, log = FALSE), k = loo::pareto_k_values(ps)) }
    r <- is_run(S_IS, 5, 1.2); if (r$k > 0.7) r <- is_run(4 * S_IS, 3, 1.5)
    U <- r$U; w <- r$w; dg[["k_hat"]] <- r$k
  }
  colnames(U) <- ord
  ll <- apply(U, 1, lp) - logprior(U)
  Fd <- cbind(U[, LAB], contrast = apply(U[, LAB], 1, contrast), loglik = ll)
  ft <- c(th[LAB], contrast = contrast(th), loglik = ll_true)
  data.frame(quantity = colnames(Fd), u = pit(Fd, ft, w), t(dg), row.names = NULL)
}
