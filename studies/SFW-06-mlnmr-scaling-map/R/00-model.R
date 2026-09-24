## ---------------------------------------------------------------------------
## SFW-06: where ML-NMR cost binds, decomposed into arithmetic and geometry.
##
## CPU per effective draw factorizes exactly:
##   CPU / ESS = t_grad x (n_leapfrog / ESS),
## t_grad the CPU seconds of one log-density gradient (arithmetic; grows with
## integration rows) and n_leapfrog / ESS the gradients per effective draw of the
## decision contrast (geometry; counted by the sampler, independent of machine
## load). E1 times t_grad on a Fixed_param stanfit with rstan::grad_log_prob over
## the full grid; E2 counts gradients per effective draw from NUTS fits on a
## subgrid. multinma 0.9.1 defaults except int_check = FALSE (half the chains would
## otherwise run at Q/2) and cores = 1 (CPU is then user time of this process).
##
## Network: one IPD study (P vs A, 200 per arm) and S aggregate studies (P vs B,
## 100 per arm), p covariates N(m_j, 1) with study means m_j spread over
## [-1, 1]; regression ~ (x1 + ... + xp) + x1:.trt (one effect modifier; with all p
## interactions the aggregate-only B interactions made NUTS diverge in 6% of
## transitions in probe E2, a pathology rather than a computational factor). Outcomes: binomial logit, or
## survival with multinma's default M-spline baseline (7 knots), Weibull event
## times, uniform censoring. Aggregate survival arms carry their individual event
## and censoring times (reconstructed-data layout); covariates as summaries.
## Integration rows per gradient: binomial 2 S Q; survival 2 S x 100 x Q.
## Decision contrast: B vs A conditional effect at target x1 = 0.5.
## ---------------------------------------------------------------------------

suppressPackageStartupMessages({ library(multinma); library(survival) })
MASTER_SEED <- 20261606L; N_REP_E1 <- 5L; N_REP_E2 <- 3L; X_T <- 0.5
N_IPD <- 200L; N_AGD <- 100L; MIN_CPU <- 1                 # each E1 timing runs until it has used MIN_CPU seconds

build_grid <- function() {
  e1 <- expand.grid(Q = c(32, 64, 128, 256, 512), S = c(4L, 16L), p = c(2L, 5L), outcome = c("binomial", "mspline"),
                    effects = c("fixed", "random"), reg = TRUE, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  nul <- data.frame(Q = c(32, 512), S = 16L, p = 2L, outcome = "binomial", effects = "fixed", reg = FALSE)
  e1 <- rbind(e1, nul); e1$exp <- "E1"
  e2 <- rbind(expand.grid(Q = c(32, 128, 512), S = 16L, p = 2L, outcome = "binomial", effects = c("fixed", "random"), reg = TRUE,
                          KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE),
              data.frame(Q = c(32, 128), S = 4L, p = 2L, outcome = "mspline", effects = "fixed", reg = TRUE))
  e2$exp <- "E2"; g <- rbind(e1, e2); g$cell <- seq_len(nrow(g)); g
}

## One synthetic network; parameter values fixed so only computational factors vary.
make_net <- function(cc) {
  p <- cc$p; b <- rep(0.3, p)
  sim <- function(s, k, n, m) { X <- matrix(stats::rnorm(n * p, m), n, dimnames = list(NULL, paste0("x", seq_len(p))))
    eta <- -0.5 + drop(X %*% b) + c(P = 0, A = -0.3, B = -0.5)[[k]] + c(P = 0, A = 0.2, B = 0.3)[[k]] * X[, 1]
    if (cc$outcome == "binomial") return(data.frame(study = s, trt = k, X, y = stats::rbinom(n, 1, stats::plogis(eta))))
    tt <- stats::rweibull(n, 1.3, 20 * exp(-eta / 1.3)); cz <- stats::runif(n, 5, 40)
    data.frame(study = s, trt = k, X, time = pmin(tt, cz), status = as.integer(tt <= cz)) }
  ipd <- rbind(sim("S0", "P", N_IPD, 0), sim("S0", "A", N_IPD, 0))
  ms <- seq(-1, 1, length.out = cc$S)
  agd <- do.call(rbind, lapply(seq_len(cc$S), function(j) rbind(sim(paste0("S", j), "P", N_AGD, ms[j]), sim(paste0("S", j), "B", N_AGD, ms[j]))))
  xs <- paste0("x", seq_len(p))
  cov <- do.call(rbind, lapply(split(agd, list(agd$study, agd$trt), drop = TRUE), function(z)
    data.frame(study = z$study[1], trt = z$trt[1], r = if (cc$outcome == "binomial") sum(z$y) else NA, n = nrow(z),
               stats::setNames(as.list(c(colMeans(z[xs]), apply(z[xs], 2, stats::sd))), c(paste0(xs, "_mean"), paste0(xs, "_sd"))))))
  net <- if (cc$outcome == "binomial") combine_network(set_ipd(ipd, study, trt, r = y), set_agd_arm(cov, study, trt, r = r, n = n), trt_ref = "P") else
    combine_network(set_ipd(ipd, study, trt, Surv = Surv(time, status)),
                    set_agd_surv(agd[, c("study", "trt", "time", "status")], study, trt, Surv = Surv(time, status), covariates = cov[, c("study", "trt", paste0(xs, "_mean"), paste0(xs, "_sd"))]),
                    trt_ref = "P")
  dists <- stats::setNames(lapply(xs, function(x) eval(bquote(distr(qnorm, mean = .(as.name(paste0(x, "_mean"))), sd = .(as.name(paste0(x, "_sd"))))))), xs)
  do.call(add_integration, c(list(net), dists, list(n_int = cc$Q, cor = diag(p))))
}

fit <- function(net, cc, ...) {
  reg <- if (cc$reg) stats::as.formula(paste("~ (", paste0("x", seq_len(cc$p), collapse = " + "), ") + x1:.trt")) else NULL
  suppressWarnings(suppressMessages(nma(net, trt_effects = cc$effects, likelihood = if (cc$outcome == "mspline") "mspline" else NULL,
    regression = reg, int_check = FALSE, refresh = 0, cores = 1, ...)))
}

## E1: CPU per gradient at a random point near the prior mode; repeated until
## MIN_CPU seconds have been used, so short gradients are not timer noise.
t_grad <- function(sf) { u <- stats::rnorm(rstan::get_num_upars(sf), 0, 0.1); n <- 0; t0 <- proc.time()[["user.self"]]
  repeat { rstan::grad_log_prob(sf, u); n <- n + 1; el <- proc.time()[["user.self"]] - t0; if (el >= MIN_CPU && n >= 5) break }
  el / n }

contrast_draws <- function(f, p) {
  A <- as.matrix(f$stanfit); nm <- function(k) intersect(c(sprintf("beta[x1:.trt%s]", k), sprintf("beta[.trt%s:x1]", k)), colnames(A))
  d <- A[, "d[B]"] - A[, "d[A]"] + X_T * (A[, nm("B")] - A[, nm("A")])
  arr <- as.array(f$stanfit); list(d = d, chains = dim(arr)[2], iter = dim(arr)[1])
}

one_rep <- function(cc) {
  net <- make_net(cc)
  if (cc$exp == "E1") {
    s0 <- proc.time()[["user.self"]]; sf <- fit(net, cc, chains = 2, iter = 1, warmup = 0, algorithm = "Fixed_param")$stanfit
    setup <- proc.time()[["user.self"]] - s0
    return(data.frame(t_grad = t_grad(sf), setup_cpu = setup, n_upars = rstan::get_num_upars(sf), load = as.numeric(strsplit(system("sysctl -n vm.loadavg", intern = TRUE), " ")[[1]][2])))
  }
  s0 <- proc.time()[["user.self"]]; f <- fit(net, cc, chains = 2, iter = 1000, warmup = 500, seed = sample.int(1e8, 1)); cpu <- proc.time()[["user.self"]] - s0
  sp <- rstan::get_sampler_params(f$stanfit, inc_warmup = TRUE); w <- seq_len(500)
  lf_all <- sum(vapply(sp, function(m) sum(m[, "n_leapfrog__"]), 0)); lf_s <- sum(vapply(sp, function(m) sum(m[-w, "n_leapfrog__"]), 0))
  cd <- contrast_draws(f, cc$p); m <- matrix(cd$d, cd$iter, cd$chains)
  data.frame(cpu = cpu, leapfrog_all = lf_all, leapfrog_sampling = lf_s, ess_bulk = posterior::ess_bulk(m), ess_tail = posterior::ess_tail(m),
             rhat = posterior::rhat(m), div_rate = mean(unlist(lapply(sp, function(z) z[-w, "divergent__"]))),
             treedepth = mean(unlist(lapply(sp, function(z) z[-w, "treedepth__"]))),
             load = as.numeric(strsplit(system("sysctl -n vm.loadavg", intern = TRUE), " ")[[1]][2]))
}
