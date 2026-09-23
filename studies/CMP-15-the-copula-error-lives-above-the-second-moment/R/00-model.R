## ---------------------------------------------------------------------------
## CMP-15: does the copula family matter once the correlation is calibrated?
##
## Population-level numerical study. Three target covariates with common margins
## (standard normal, or a standardized lognormal) and exchangeable dependence from a
## true copula (Gaussian, Clayton, Gumbel, t with 3 df), each calibrated so the
## covariates' Pearson correlation equals r. Outcome model
##   eta_a(x) = ALPHA[link] + BETA sum(x) + a (DELTA + GAMMA sum(x)),
## and the target-standardized marginal contrast on the link scale,
##   h(E[h^-1(eta_1)]) - h(E[h^-1(eta_0)]),
## for identity, logit, log and complementary log-log (survival at t = 1 under an
## exponential model: the marginal log cumulative hazard ratio) links.
## A reconstruction from margins and correlations uses a Gaussian copula whose
## latent correlation is calibrated to reproduce r on the output margins (current
## practice), or set equal to r (uncalibrated). Its error is its contrast minus the
## contrast under the true copula. Alternative families, each calibrated to r, give
## an envelope.
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(copula))
D <- 3L; BETA <- 0.5; DELTA <- -0.5; SH <- c(2, 6)
ALPHA <- c(identity = 0, logit = -1, log = 0, cloglog = -0.5)
LINKS <- names(ALPHA); GAMMAS <- c(0.15, 0.3)
N_DRAW <- 1e6L; N_BATCH <- 4L; N_CAL <- 2e5L
FAMILIES <- c("gauss", "clayton", "gumbel", "sclayton", "sgumbel", "t3")
TRUE_FAM <- c("gauss", "clayton", "gumbel", "t3")

cop <- function(f, p) switch(f, gauss = normalCopula(p, dim = D), t3 = tCopula(p, dim = D, df = 3),
  clayton = claytonCopula(p, dim = D), gumbel = gumbelCopula(p, dim = D),
  sclayton = rotCopula(claytonCopula(p, dim = D)), sgumbel = rotCopula(gumbelCopula(p, dim = D)))
range_p <- function(f) switch(f, gauss = c(0.001, 0.99), t3 = c(0.001, 0.99), clayton = c(0.01, 30), sclayton = c(0.01, 30), c(1.001, 20))

B_M <- SH[1] / sum(SH); B_S <- sqrt(prod(SH) / (sum(SH)^2 * (sum(SH) + 1)))
margin <- function(u, m) if (m == "normal") stats::qnorm(u) else (stats::qbeta(u, SH[1], SH[2]) - B_M) / B_S

with_seed <- function(s, expr) { old <- if (exists(".Random.seed", .GlobalEnv)) get(".Random.seed", .GlobalEnv) else NULL
  set.seed(s); on.exit(if (!is.null(old)) assign(".Random.seed", old, .GlobalEnv)); expr }
draw_x <- function(f, p, m, n, seed) with_seed(seed, margin(rCopula(n, cop(f, p)), m))
mean_pearson <- function(x) { r <- stats::cor(x); mean(r[upper.tri(r)]) }

## Copula parameter giving mean pairwise Pearson correlation r on margin m
## (common random numbers, so the root is smooth).
calibrate <- function(f, r, m) stats::uniroot(function(p) mean_pearson(draw_x(f, p, m, N_CAL, 11)) - r,
                                              range_p(f), tol = 1e-5)$root

## Means use sum(x) as a control variate, since E[sum(x)] = 0 exactly.
cv_mean <- function(g, s) mean(g) - stats::cov(g, s) / stats::var(s) * mean(s)
contrast <- function(x, link, gamma) {
  s <- rowSums(x); e0 <- ALPHA[[link]] + BETA * s; e1 <- e0 + DELTA + gamma * s
  m <- function(g) cv_mean(g, s)
  switch(link, identity = m(e1) - m(e0),
    logit = stats::qlogis(m(stats::plogis(e1))) - stats::qlogis(m(stats::plogis(e0))),
    log = log(m(exp(e1))) - log(m(exp(e0))),
    cloglog = log(-log(m(exp(-exp(e1))))) - log(-log(m(exp(-exp(e0))))))
}
all_contrasts <- function(x) unlist(lapply(LINKS, function(l) vapply(GAMMAS, function(gm) contrast(x, l, gm), 0)))
LABELS <- as.vector(t(outer(LINKS, GAMMAS, paste, sep = ":")))

## Gaussian copula reconstruction evaluated with n Sobol points under a random
## shift (randomized quasi-Monte Carlo).
qmc_gauss <- function(rho, m, n, seed) {
  u <- with_seed(seed, (randtoolbox::sobol(n, D) + matrix(stats::runif(D), n, D, byrow = TRUE)) %% 1)
  z <- stats::qnorm(u)
  L <- chol(matrix(rho, D, D) + diag(1 - rho, D)); margin(stats::pnorm(z %*% L), m)
}
