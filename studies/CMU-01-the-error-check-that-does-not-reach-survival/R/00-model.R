## ---------------------------------------------------------------------------
## CMU-01: does multinma's split-chain integration check see material residual
## integration error in a survival ML-NMR contrast?
##
## Network: one IPD study (P vs A, 200 per arm) and S aggregate studies (P vs B,
## 100 per arm, individual event and censoring times, 5 covariates as means and
## SDs; study means spread over [-0.5, 0.5]). Weibull event times (shape 1.3),
## log hazard ratio x'b + d_k + g_k x1 with b = 0.3, g_A = 0.2, g_B = 0.3;
## uniform censoring on (5, 40). Fitted by multinma 0.9.1 with a Weibull or
## M-spline (7 knots) baseline, fixed effects, regression ~ (x1 + ... + x5) + x1:.trt,
## center = FALSE, QR = FALSE, default priors.
## Estimand: conditional log hazard ratio B vs A at target x1 = 0.5, c(theta).
## Integration error is measured at the Laplace level on multinma's own log
## density (rstan::log_prob and grad_log_prob on a Fixed_param stanfit): posterior
## mode at each Q in LADDER and at Q_REF (Sobol points are extensible, so every
## smaller Q is a prefix of Q_REF). Residual error r(Q) = (c(Q) - c(Q_REF)) / SD,
## SD the Laplace posterior SD of c at Q_SD. Material: |r(Q)| >= MATERIAL.
## Split-chain check (int_check): half the chains at Q, half at Q/2; it warns when
## the pooled chains fail R-hat 1.05 or ESS 400 while each order alone passes.
## Emulated from the modes: for every quantity multinma saves (parameters, per
## observation log_lik and resdev, lp__), its shift between the Q and Q/2 modes in
## units of its Laplace SD; the check fires when the largest shift reaches DSTAR,
## the shift at which multinma's own decision code fires on half of the sets of
## ideal chains simulated by dstar(). A validation cell runs the real check.
## ---------------------------------------------------------------------------

suppressPackageStartupMessages({ library(multinma); library(survival) })
MASTER_SEED <- 20261001L; N_SIM <- 50L; N_VAL <- 10L
P <- 5L; N_IPD <- 200L; N_AGD <- 100L; X1_T <- 0.5
LADDER <- c(8, 16, 32, 64, 128, 256, 512); Q_REF <- 1024; Q_SD <- 128; MATERIAL <- 0.25

build_grid <- function() {
  g <- expand.grid(lik = c("weibull", "mspline"), S = c(4L, 12L), kind = "main", KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g <- rbind(g, data.frame(lik = "weibull", S = 4L, kind = c("null", "validate")))
  g$cell <- seq_len(nrow(g)); g
}

## Data and the network the fit sees. kind "null": aggregate covariate SDs published
## as zero, so every integration point is the mean and every Q integrates exactly.
make_data <- function(cc) {
  b <- rep(0.3, P)
  sim <- function(s, k, n, m) { X <- matrix(stats::rnorm(n * P, m), n, dimnames = list(NULL, paste0("x", seq_len(P))))
    lhr <- drop(X %*% b) + c(P = 0, A = -0.3, B = -0.5)[[k]] + c(P = 0, A = 0.2, B = 0.3)[[k]] * X[, 1]
    tt <- stats::rweibull(n, 1.3, 20 * exp(-lhr / 1.3)); cz <- stats::runif(n, 5, 40)
    data.frame(study = s, trt = k, X, time = pmin(tt, cz), status = as.integer(tt <= cz)) }
  ms <- seq(-0.5, 0.5, length.out = cc$S); xs <- paste0("x", seq_len(P))
  ipd <- rbind(sim("S0", "P", N_IPD, 0), sim("S0", "A", N_IPD, 0))
  agd <- do.call(rbind, lapply(seq_len(cc$S), function(j) rbind(sim(paste0("S", j), "P", N_AGD, ms[j]), sim(paste0("S", j), "B", N_AGD, ms[j]))))
  cov <- do.call(rbind, lapply(split(agd, list(agd$study, agd$trt), drop = TRUE), function(z)
    data.frame(study = z$study[1], trt = z$trt[1], stats::setNames(as.list(c(colMeans(z[xs]), if (cc$kind == "null") rep(0, P) else apply(z[xs], 2, stats::sd))),
                                                                   c(paste0(xs, "_mean"), paste0(xs, "_sd"))))))
  combine_network(set_ipd(ipd, study, trt, Surv = Surv(time, status)),
                  set_agd_surv(agd[, c("study", "trt", "time", "status")], study, trt, Surv = Surv(time, status), covariates = cov), trt_ref = "P")
}
at_Q <- function(net, Q) { xs <- paste0("x", seq_len(P))
  dists <- stats::setNames(lapply(xs, function(x) eval(bquote(distr(qnorm, mean = .(as.name(paste0(x, "_mean"))), sd = .(as.name(paste0(x, "_sd"))))))), xs)
  do.call(add_integration, c(list(net), dists, list(n_int = Q, cor = diag(P)))) }
REG <- stats::as.formula(paste("~ (", paste0("x", seq_len(P), collapse = " + "), ") + x1:.trt"))
nma_of <- function(neti, cc, ...) suppressWarnings(suppressMessages(nma(neti, trt_effects = "fixed", likelihood = cc$lik, regression = REG,
  center = FALSE, QR = FALSE, refresh = 0, cores = 1, ...)))
fixed_sf <- function(neti, cc) nma_of(neti, cc, chains = 2, iter = 1, warmup = 0, algorithm = "Fixed_param", int_check = FALSE)$stanfit

## Contrast as a linear function of the unconstrained vector: beta_tilde = c(mu, d, beta)
## occupies its first entries when QR = FALSE.
contrast_grad <- function(sf) { fn <- sf@sim$fnames_oi
  bt <- c(grep("^mu\\[", fn, value = TRUE), grep("^d\\[", fn, value = TRUE), grep("^beta\\[", fn, value = TRUE))
  gv <- numeric(rstan::get_num_upars(sf)); i <- match(c("d[A]", "d[B]", "beta[x1:.trtA]", "beta[x1:.trtB]"), bt)
  if (anyNA(i)) i <- match(c("d[A]", "d[B]", "beta[.trtA:x1]", "beta[.trtB:x1]"), bt)
  gv[i] <- c(-1, 1, -X1_T, X1_T); gv }

map_fit <- function(sf, start) { fn <- function(u) -rstan::log_prob(sf, u); gr <- function(u) -rstan::grad_log_prob(sf, u)
  op <- stats::optim(start, fn, gr, method = "L-BFGS-B", control = list(maxit = 5000, factr = 1e3))
  list(u = op$par, lp = -op$value, conv = op$convergence, evals = op$counts[[1]]) }

## Everything multinma saves for R-hat and ESS, flattened and labeled as in the fit.
saved <- function(sf, u) { cp <- rstan::constrain_pars(sf, u); keep <- intersect(names(cp), setdiff(sf@sim$pars_oi, "lp__"))
  v <- unlist(lapply(cp[keep], as.vector)); fn <- sf@sim$fnames_oi
  nm <- unlist(lapply(keep, function(p) fn[startsWith(fn, paste0(p, "[")) | fn == p])); stopifnot(length(nm) == length(v))
  stats::setNames(v, nm) }

## The standardized between-order shift at which multinma's int_check fires: 4 chains
## of 1000 independent N(0, 1) draws, two shifted by delta, passed through the same
## R-hat and ESS rules multinma applies (pooled chains warn, each order alone does not).
dstar <- function(n_set = 200, grid = seq(0, 0.4, by = 0.02), seed = 1) { set.seed(seed)
  fires <- function(x) { pooled <- rstan::Rhat(x) > 1.05 || rstan::ess_bulk(x) < 400 || rstan::ess_tail(x) < 400
    within <- any(vapply(list(1:2, 3:4), function(k) rstan::Rhat(x[, k]) > 1.05 || rstan::ess_bulk(x[, k]) / 2 < 100 || rstan::ess_tail(x[, k]) / 2 < 100, TRUE))
    pooled && !within }
  pf <- vapply(grid, function(dl) mean(replicate(n_set, fires(matrix(stats::rnorm(4000), 1000) + rep(c(0, 0, dl, dl), each = 1000)))), 0)
  list(grid = grid, p_fire = pf, dstar = stats::approx(pf, grid, 0.5, ties = min)$y) }

## One dataset: modes along the ladder, the reference, Laplace SDs, residual errors,
## and the standardized shift of every saved quantity between Q and Q/2.
ladder_rep <- function(cc, net, ladder = LADDER) {
  qs <- sort(unique(c(ladder, ladder / 2, Q_SD, Q_REF))); sfs <- list(); modes <- list(); start <- NULL
  for (q in qs) { sf <- fixed_sf(at_Q(net, q), cc); if (is.null(start)) start <- rep(0, rstan::get_num_upars(sf))
    m <- map_fit(sf, start); start <- m$u; sfs[[as.character(q)]] <- sf; modes[[as.character(q)]] <- m }
  gv <- contrast_grad(sfs[[1]]); sfd <- sfs[[as.character(Q_SD)]]; ud <- modes[[as.character(Q_SD)]]$u
  H <- stats::optimHess(ud, function(u) -rstan::log_prob(sfd, u), function(u) -rstan::grad_log_prob(sfd, u)); Sig <- solve((H + t(H)) / 2)
  sd_c <- sqrt(drop(t(gv) %*% Sig %*% gv)); v0 <- saved(sfd, ud)
  J <- vapply(seq_along(ud), function(k) { e <- ud; e[k] <- e[k] + 1e-5; (saved(sfd, e) - v0) / 1e-5 }, v0)
  sd_q <- sqrt(pmax(rowSums((J %*% Sig) * J), 1e-12)); np <- length(ud)
  cref <- sum(gv * modes[[as.character(Q_REF)]]$u)
  ll_ref <- saved(sfs[[as.character(Q_REF)]], modes[[as.character(Q_REF)]]$u); isll <- startsWith(names(ll_ref), "log_lik[")
  lab <- sub(", [0-9]+\\]$", "", sub("^log_lik\\[", "", names(ll_ref)[isll]))
  do.call(rbind, lapply(ladder, function(q) { m <- modes[[as.character(q)]]; c_q <- sum(gv * m$u)
    shift <- if (as.character(q / 2) %in% names(modes)) { h <- modes[[as.character(q / 2)]]
      c(max(abs(saved(sfs[[as.character(q)]], m$u) - saved(sfs[[as.character(q / 2)]], h$u)) / sd_q), abs(m$lp - h$lp) / sqrt(np / 2)) } else c(NA, NA)
    arm <- tapply(saved(sfs[[as.character(q)]], modes[[as.character(Q_REF)]]$u)[isll] - ll_ref[isll], lab, sum)
    data.frame(Q = q, contrast = c_q, r = (c_q - cref) / sd_c, sd_c = sd_c, shift_q = shift[1], shift_lp = shift[2],
               r_prefix = if (as.character(q / 2) %in% names(modes)) (c_q - sum(gv * modes[[as.character(q / 2)]]$u)) / sd_c else NA,
               arm_err_max = max(abs(arm)), conv = m$conv, evals = m$evals, n_upars = np) }))
}

## Real check: default chains and iterations, int_check on; TRUE if multinma
## attributes a warning to integration.
real_check <- function(net, cc, q, iter = 2000) { fired <- FALSE
  withCallingHandlers(nma(at_Q(net, q), trt_effects = "fixed", likelihood = cc$lik, regression = REG, center = FALSE, QR = FALSE,
                          refresh = 0, cores = 1, int_check = TRUE, iter = iter, seed = sample.int(1e8, 1)),
    warning = function(w) { if (inherits(w, c("int_check_rhat", "int_check_essb", "int_check_esst"))) fired <<- TRUE; invokeRestart("muffleWarning") },
    message = function(m) invokeRestart("muffleMessage"))
  fired }

one_rep <- function(cc) {
  net <- make_data(cc)
  if (cc$kind != "validate") return(ladder_rep(cc, net))
  r <- ladder_rep(cc, net, ladder = c(8, 16)); r$real_fired <- vapply(r$Q, function(q) real_check(net, cc, q), TRUE); r
}
