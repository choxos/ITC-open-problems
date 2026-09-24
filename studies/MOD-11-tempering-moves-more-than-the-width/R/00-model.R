## ---------------------------------------------------------------------------
## MOD-11: a Dirichlet-process mixture over study populations, transported to a
## declared target, against a conventional random-effects model; and what a
## learning rate eta does to each.
##
## Two-stage Gaussian evidence. Study j reports a log odds ratio y_j with known
## SE s_j and a covariate mean xbar_j ~ U(0, 1); IPD studies also report a
## within-study interaction b_j ~ N(beta, (2 s_j)^2). True study effect
##   delta_j = ALPHA + BETA xbar_j + phi_j,  phi_j = center[c_j] + N(0, 0.05^2),
## c_j uniform over 1 or 3 clusters with centers {-D, 0, D}. Target covariate
## X_T = 1.5 (outside every study). The target population is a new draw from the
## same population law, so the transported estimand is
##   theta_T = ALPHA + BETA X_T + phi_T,   phi_T ~ G,
## scored by predictive coverage, interval width and log score; the mean target
## contrast ALPHA + BETA X_T (G has mean 0) is reported alongside.
## Prior dependence of the clustering: the mean pairwise co-clustering probability
## at a = 0.3 minus that at a = 3, over the same difference under the prior
## (1/1.3 - 1/4); 1 means the partition moves one-for-one with the prior.
## Models share delta_j = beta xbar_j + phi_j, beta ~ N(0, 1):
##   re: phi_j ~ N(mu, tau^2), mu ~ N(0, 1), tau ~ HN(0.5); exact on a tau grid.
##   t : phi_j ~ mu + tau t_4, same priors; Gibbs (scale mixture).
##   dp: phi_j ~ N(psi_c, omega^2), psi ~ G, G ~ DP(a, N(mu, s0^2)); mu ~ N(0, 1),
##       s0 ~ HN(0.5), omega ~ HN(0.25); collapsed Gibbs (Neal algorithm 2).
## Tempering raises the likelihood to eta: in a Gaussian likelihood with known
## variance this is exactly s_j^2 -> s_j^2 / eta and v_j -> v_j / eta, and the
## prior levels (tau, omega, s0) are untouched.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261111L; N_SIM <- 400L
ALPHA <- -0.3; BETA <- 0.4; X_T <- 1.5; OMEGA_TRUE <- 0.05; NU <- 4
A_DP <- c(0.3, 1, 3); ETA <- c(1, 0.5); N_ITER <- 3000L; BURN <- 1000L
TAU_GRID <- seq(0, 2.5, length.out = 401)

build_grid <- function() {
  g <- expand.grid(het = c("one", "small", "large"), J = c(6L, 12L), ipd = c("one", "half"),
                   KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$cell <- seq_len(nrow(g)); g
}
centers <- function(het) switch(het, one = 0, small = c(-0.3, 0, 0.3), large = c(-0.9, 0, 0.9))
truth <- function(cell) ALPHA + BETA * X_T          # mean target contrast; theta_T is drawn per replicate

draw <- function(cell) {
  J <- cell$J; ce <- centers(cell$het)
  x <- stats::runif(J); s <- stats::runif(J, 0.1, 0.3)
  phi <- ce[sample.int(length(ce), J, replace = TRUE)] + stats::rnorm(J, 0, OMEGA_TRUE)
  ipd <- seq_len(J) <= (if (cell$ipd == "one") 1L else J %/% 2L)
  v <- 2 * s
  list(x = x, s = s, y = stats::rnorm(J, ALPHA + BETA * x + phi, s), ipd = ipd, v = v,
       b = ifelse(ipd, stats::rnorm(J, BETA, v), NA_real_),
       thetaT = ALPHA + BETA * X_T + ce[sample.int(length(ce), 1)] + stats::rnorm(1, 0, OMEGA_TRUE))
}

## Summary of a predictive distribution given draws (or an exact mixture for re).
summ <- function(draws, dens, meanT, extra) {
  q <- stats::quantile(draws, c(0.025, 0.975), names = FALSE)
  c(pred_lo = q[1], pred_hi = q[2], logscore = log(dens), mean_est = mean(meanT), mean_sd = stats::sd(meanT), extra)
}

## Conventional random-effects meta-regression, exact: Gaussian in (mu, beta)
## given tau, tau on a grid. prior_sd and tau_grid are arguments so the flat
## model of the second null control is the same code with tau fixed at 0 and xT = 0.
fit_re <- function(d, eta, thetaT, prior_sd = 1, tau_grid = TAU_GRID, xT = X_T) {
  S <- d$s^2 / eta; I <- which(d$ipd); V <- d$v[I]^2 / eta
  A <- rbind(cbind(1, d$x), cbind(rep(0, length(I)), rep(1, length(I)))); z <- c(d$y, d$b[I])
  g <- c(1, xT); P0 <- diag(1 / prior_sd^2, 2)
  res <- t(vapply(tau_grid, function(tau) {
    D <- c(S + tau^2, V); Pm <- P0 + crossprod(A / D, A); Cm <- solve(Pm); m <- drop(Cm %*% crossprod(A, z / D))
    M <- diag(D, length(D)) + A %*% (diag(prior_sd^2, 2) %*% t(A)); L <- chol(M)
    lml <- -sum(log(diag(L))) - 0.5 * sum(backsolve(L, z, transpose = TRUE)^2)
    c(lml = lml, mT = sum(g * m), vT = drop(t(g) %*% Cm %*% g), mb = m[2], vb = Cm[2, 2])
  }, numeric(5)))
  lw <- res[, "lml"] + (if (length(tau_grid) > 1) stats::dnorm(tau_grid, 0, 0.5, log = TRUE) else 0)
  w <- exp(lw - max(lw)); w <- w / sum(w)
  pv <- res[, "vT"] + tau_grid^2
  pdens <- function(t) sum(w * stats::dnorm(t, res[, "mT"], sqrt(pv)))
  pcdf <- function(t) sum(w * stats::pnorm(t, res[, "mT"], sqrt(pv)))
  ctr <- sum(w * res[, "mT"]); sp <- sqrt(sum(w * (pv + res[, "mT"]^2)) - ctr^2)
  qf <- function(p) stats::uniroot(function(t) pcdf(t) - p, ctr + c(-12, 12) * sp)$root
  mean_sd <- sqrt(sum(w * (res[, "vT"] + res[, "mT"]^2)) - ctr^2)
  vb <- sum(w * (res[, "vb"] + res[, "mb"]^2)) - sum(w * res[, "mb"])^2
  c(pred_lo = qf(0.025), pred_hi = qf(0.975), logscore = log(pdens(thetaT)), mean_est = ctr, mean_sd = mean_sd,
    tau = sum(w * tau_grid), K = NA, ipd_share = if (length(I)) sum(1 / V) * vb else 0, psame = NA)
}

rhn_mh <- function(cur, logpost, step = 0.3) {        # random-walk MH on log scale for a positive scale
  prop <- cur * exp(stats::rnorm(1, 0, step))
  if (log(stats::runif(1)) < logpost(prop) - logpost(cur) + log(prop) - log(cur)) prop else cur
}

## Heavy-tailed random effects: phi_j = mu + tau e_j / sqrt(lambda_j), lambda_j ~ Gamma(2, 2).
fit_t <- function(d, eta, thetaT) {
  S <- d$s^2 / eta; I <- which(d$ipd); V <- d$v[I]^2 / eta; J <- length(d$y)
  beta <- 0; mu <- 0; tau <- 0.2; lam <- rep(1, J); keep <- N_ITER - BURN
  dr <- dens <- mT <- numeric(keep)
  for (it in seq_len(N_ITER)) {
    pr <- 1 / S + lam / tau^2; phi <- stats::rnorm(J, ((d$y - beta * d$x) / S + mu * lam / tau^2) / pr, sqrt(1 / pr))
    lam <- stats::rgamma(J, (NU + 1) / 2, (NU + (phi - mu)^2 / tau^2) / 2)
    pm <- 1 + sum(lam) / tau^2; mu <- stats::rnorm(1, sum(lam * phi) / tau^2 / pm, sqrt(1 / pm))
    tau <- rhn_mh(tau, function(t) sum(stats::dnorm(phi, mu, t / sqrt(lam), log = TRUE)) + stats::dnorm(t, 0, 0.5, log = TRUE))
    pb <- 1 + sum(d$x^2 / S) + sum(1 / V); beta <- stats::rnorm(1, (sum(d$x * (d$y - phi) / S) + sum(d$b[I] / V)) / pb, sqrt(1 / pb))
    if (it > BURN) { k <- it - BURN; loc <- beta * X_T + mu
      dr[k] <- loc + tau * stats::rt(1, NU); dens[k] <- stats::dt((thetaT - loc) / tau, NU) / tau; mT[k] <- loc }
  }
  summ(dr, mean(dens), mT, c(tau = NA, K = NA, ipd_share = NA, psame = NA))
}

## Dirichlet-process mixture of normals over study effects, phi_j integrated out:
## y_j ~ N(beta xbar_j + psi_c(j), S_j + omega^2).
fit_dp <- function(d, eta, thetaT, a) {
  S <- d$s^2 / eta; I <- which(d$ipd); V <- d$v[I]^2 / eta; J <- length(d$y)
  beta <- 0; mu <- 0; s0 <- 0.3; om <- 0.1; cl <- rep(1L, J); psi <- mean(d$y); keep <- N_ITER - BURN
  dr <- dens <- mT <- Ks <- ps <- numeric(keep)
  for (it in seq_len(N_ITER)) {
    r <- d$y - beta * d$x; E <- S + om^2
    for (j in seq_len(J)) {
      cl[j] <- 0L; used <- sort(unique(cl[cl > 0])); psi <- psi[used]; cl[cl > 0] <- match(cl[cl > 0], used)
      nk <- tabulate(cl[cl > 0], length(psi))
      lw <- c(log(nk) + stats::dnorm(r[j], psi, sqrt(E[j]), log = TRUE), log(a) + stats::dnorm(r[j], mu, sqrt(E[j] + s0^2), log = TRUE))
      k <- sample.int(length(lw), 1, prob = exp(lw - max(lw)))
      if (k > length(psi)) { pp <- 1 / s0^2 + 1 / E[j]; psi <- c(psi, stats::rnorm(1, (mu / s0^2 + r[j] / E[j]) / pp, sqrt(1 / pp))) }
      cl[j] <- k
    }
    K <- length(psi)
    pp <- 1 / s0^2 + tapply(1 / E, factor(cl, seq_len(K)), sum); pm <- (mu / s0^2 + tapply(r / E, factor(cl, seq_len(K)), sum)) / pp
    psi <- stats::rnorm(K, pm, sqrt(1 / pp))
    pmu <- 1 + K / s0^2; mu <- stats::rnorm(1, sum(psi) / s0^2 / pmu, sqrt(1 / pmu))
    s0 <- rhn_mh(s0, function(t) sum(stats::dnorm(psi, mu, t, log = TRUE)) + stats::dnorm(t, 0, 0.5, log = TRUE))
    om <- rhn_mh(om, function(t) sum(stats::dnorm(r, psi[cl], sqrt(S + t^2), log = TRUE)) + stats::dnorm(t, 0, 0.25, log = TRUE))
    E <- S + om^2; pb <- 1 + sum(d$x^2 / E) + sum(1 / V)
    beta <- stats::rnorm(1, (sum(d$x * (d$y - psi[cl]) / E) + sum(d$b[I] / V)) / pb, sqrt(1 / pb))
    if (it > BURN) { k <- it - BURN; nk <- tabulate(cl, K); wk <- c(nk, a) / (J + a)
      m <- beta * X_T + c(psi, mu); sd <- sqrt(c(rep(om^2, K), s0^2 + om^2))
      h <- sample.int(K + 1, 1, prob = wk); dr[k] <- stats::rnorm(1, m[h], sd[h])
      dens[k] <- sum(wk * stats::dnorm(thetaT, m, sd)); mT[k] <- sum(wk * m); Ks[k] <- K; ps[k] <- sum(nk * (nk - 1)) / (J * (J - 1)) }
  }
  summ(dr, mean(dens), mT, c(tau = NA, K = mean(Ks), ipd_share = NA, psame = mean(ps)))
}

## Prior expected number of occupied clusters for J studies at concentration a, and
## prior probability that two studies share a cluster (Chinese restaurant process).
prior_K <- function(a, J) sum(a / (a + seq_len(J) - 1))
prior_same <- function(a) 1 / (1 + a)

one_rep <- function(cell) {
  d <- draw(cell); tt <- d$thetaT
  rows <- list(re_1 = fit_re(d, 1, tt), re_0.5 = fit_re(d, 0.5, tt), t_1 = fit_t(d, 1, tt),
               dp_1 = fit_dp(d, 1, tt, 1), dp_0.5 = fit_dp(d, 0.5, tt, 1),
               dplo_1 = fit_dp(d, 1, tt, A_DP[1]), dphi_1 = fit_dp(d, 1, tt, A_DP[3]))
  out <- data.frame(arm = names(rows), do.call(rbind, rows), row.names = NULL)
  out$method <- sub("_.*", "", out$arm); out$eta <- as.numeric(sub(".*_", "", out$arm)); out$thetaT <- tt
  out
}
