## ---------------------------------------------------------------------------
## The data-generating mechanism, and the estimand as a functional of the LAW.
##
## The whole study turns on one distinction, so it is implemented explicitly
## rather than left to a formula:
##
##   Delta(F_T) = g( int mu_1(x) dF_T(x) ) - g( int mu_0(x) dF_T(x) )
##
## Under the identity link with additive effect this equals tau_0 + b_EM' xbar_T,
## a function of the MEAN alone. Under logit or cloglog the integral sits inside
## a nonlinear function, so the estimand depends on every moment of F_T. The two
## are computed by the SAME code path, with the link as an argument, so that no
## difference between them can come from anything but the link.
##
##   source("R/01-dgm.R")
## ---------------------------------------------------------------------------

source("R/00-config.R")

## --- links, and the inverse each estimand needs -----------------------------
## `g` maps a probability (or cumulative hazard) to the reported scale; `ginv`
## comes back. The marginal estimand applies g AFTER integrating, which is what
## makes it non-collapsible when g is nonlinear.
link_fns <- function(link) switch(link,
  identity = list(g = function(p) p,
                  ginv = function(e) e,
                  name = "identity"),
  logit    = list(g = function(p) log(p / (1 - p)),
                  ginv = function(e) 1 / (1 + exp(-e)),
                  name = "logit"),
  ## Weibull PH on the cumulative-hazard scale: g(S) = log(-log(S)).
  cloglog  = list(g = function(s) log(-log(s)),
                  ginv = function(e) exp(-exp(e)),
                  name = "cloglog"),
  stop("unregistered link: ", link))

## --- the covariate law ------------------------------------------------------
##
## Three covariates, the first the primary modifier. Each shape family is
## parameterized so the first two moments match across shapes at a given
## overlap, which is what makes the shape arm a test of SHAPE rather than of
## location or scale. Without that, a difference between `mvnorm` and
## `lognormal` would be confounded with a difference in mean.
covariate_law <- function(shape, n, mu, sigma, rho) {
  p <- length(mu)
  R <- matrix(rho, p, p); diag(R) <- 1
  S <- diag(sigma, p) %*% R %*% diag(sigma, p)
  Z <- MASS::mvrnorm(n, rep(0, p), S)
  switch(shape,
    mvnorm = sweep(Z, 2, mu, "+"),
    ## Lognormal matched to the SAME first two moments: if Y = exp(W) with
    ## W ~ N(m, s^2), then E Y = exp(m + s^2/2) and Var Y = (exp(s^2)-1) E[Y]^2.
    ## Solving for (m, s) at the target (mu, sigma) keeps the arm a shape
    ## contrast; the skewness is then whatever that solution implies, which is
    ## the quantity the arm exists to vary.
    lognormal = {
      out <- matrix(0, n, p)
      for (j in seq_len(p)) {
        m_j <- mu[j]; s_j <- sigma[j]
        ## Shift so the marginal is positive before taking logs.
        shift <- m_j - 4 * s_j
        mm <- m_j - shift
        s2 <- log1p((s_j / mm)^2)
        out[, j] <- exp(log(mm) - s2 / 2 + sqrt(s2) * Z[, j] / s_j) + shift
      }
      out
    },
    ## One binary covariate and two normal, the common applied case. The binary
    ## column is thresholded from the correlated Gaussian, so the correlation
    ## structure survives dichotomization in rank if not in Pearson terms; the
    ## realized Pearson correlation is measured in P2 rather than assumed.
    mixed = {
      out <- sweep(Z, 2, mu, "+")
      out[, 1] <- as.numeric(Z[, 1] > 0)
      out
    },
    stop("unregistered covariate shape: ", shape))
}

## --- conditional means, and the two arms ------------------------------------
##
## eta_0(x) is the control-arm linear predictor; tau(x) is the conditional
## treatment effect, linear in x with the modifier coefficients. `k` is MIS-03's
## alignment: it scales how much of the SOURCE modification is shared by the
## TARGET trial's own effect, which is what sets the sign of the omitted
## covariance and therefore whether the status-quo interval is too narrow or too
## wide.
conditional_means <- function(x, pars, link) {
  lf <- link_fns(link)
  eta0 <- as.vector(pars$alpha + x %*% pars$beta_prog)
  tau  <- as.vector(pars$tau0 + x %*% pars$beta_em)
  list(mu0 = lf$ginv(eta0), mu1 = lf$ginv(eta0 + tau), eta0 = eta0, tau = tau)
}

## --- THE ESTIMAND, as a functional of the law -------------------------------
##
## `delta_law` integrates the ARM MEANS over a covariate law and then applies g,
## which is the definition. `delta_sample` does the same with the empirical law
## of a realized sample, which is the finite-target estimand. They differ only in
## which measure they integrate against, so the pair is exact by construction
## rather than by an argument.
delta_from_arm_means <- function(m0, m1, link) {
  lf <- link_fns(link)
  lf$g(m1) - lf$g(m0)
}

delta_sample <- function(x, pars, link) {
  cm <- conditional_means(x, pars, link)
  delta_from_arm_means(mean(cm$mu0), mean(cm$mu1), link)
}

## THE INTEGRAL IS ONE-DIMENSIONAL UNDER NORMALITY, EXACTLY.
##
## Each arm mean is int ginv(eta_a(x)) dF_T(x), and eta_a is LINEAR in x. So the
## integrand depends on x only through the scalar eta_a, and when x is
## multivariate normal so is eta_a. The p-dimensional integral therefore reduces
## to a one-dimensional one over N(a_0 + mu'b, b'S b), with no approximation:
## checked against the product rule at 4.1e-15.
##
## This matters for feasibility, not elegance. The product rule costs order^p,
## which is 110,592 nodes at p = 3 and **5,308,416 at p = 4**, 17.8 s per
## evaluation. The `modifier_span = outside` arm adds a covariate, so a gradient
## there needs 16 evaluations and would cost 285 s per cell. The reduction makes
## it 48 nodes at any p.
##
## It applies only where eta_a is normal, which is the `mvnorm` shape. The
## non-normal shapes keep the product rule, and they are p = 3 by construction
## because the design crosses `modifier_span` with the MIDDLE level of `shape`.
delta_superpopulation_normal <- function(pars, link, mu, sigma, rho, order) {
  lf <- link_fns(link)
  gh <- gh_rule(order)
  w <- gh$w / sqrt(pi)
  p <- length(mu)
  R <- matrix(rho, p, p); diag(R) <- 1
  S <- diag(sigma, p) %*% R %*% diag(sigma, p)
  arm <- function(b, a0) {
    m <- a0 + sum(mu * b)
    s <- sqrt(as.numeric(t(b) %*% S %*% b))
    sum(w * lf$ginv(m + sqrt(2) * s * gh$x))
  }
  m0 <- arm(pars$beta_prog, pars$alpha)
  m1 <- arm(pars$beta_prog + pars$beta_em, pars$alpha + pars$tau0)
  delta_from_arm_means(m0, m1, link)
}

## The superpopulation estimand by Gauss-Hermite quadrature over the TRUE law.
## The order is PROBE P1's output and is never defaulted: OUT-11's integration
## order moved a primary contrast and was caught only because it was measured.
delta_superpopulation <- function(pars, link, shape, mu, sigma, rho, order) {
  stopifnot("the quadrature order must come from probe P1" = is.finite(order))
  ## The exact reduction where it applies. P1's order was chosen on the product
  ## rule and is reused here, which is conservative: a one-dimensional integral
  ## needs no more nodes than the same rule needed in three dimensions.
  if (shape == "mvnorm")
    return(delta_superpopulation_normal(pars, link, mu, sigma, rho, order))
  stopifnot("the product rule is only affordable to three covariates; the
             non-normal shapes are crossed with the middle level of the other
             factors precisely so this cannot be reached at four"
              = length(mu) <= 3L)
  gh <- gh_rule(order)
  p <- length(mu)
  ## A product rule over p dimensions. p is 3 and the order is small, so the
  ## node count is order^3 and is affordable; a sparse rule would be a second
  ## approximation to justify.
  idx <- as.matrix(expand.grid(rep(list(seq_len(order)), p)))
  R <- matrix(rho, p, p); diag(R) <- 1
  L <- chol(diag(sigma, p) %*% R %*% diag(sigma, p))
  z <- sqrt(2) * gh$x[idx]
  dim(z) <- dim(idx)
  w <- apply(matrix(gh$w[idx], nrow(idx), p), 1, prod) / (pi^(p / 2))
  xs <- sweep(z %*% L, 2, mu, "+")
  if (shape != "mvnorm") {
    ## For a non-normal law the same nodes are pushed through the shape map, so
    ## the quadrature integrates the TRANSFORMED variable against its own
    ## measure. P1 checks that this is stable to QUAD_TOL on the most skewed law
    ## in the grid, and drops the skew arm if it is not.
    xs <- shape_map(xs, shape, mu, sigma)
  }
  cm <- conditional_means(xs, pars, link)
  delta_from_arm_means(sum(w * cm$mu0), sum(w * cm$mu1), link)
}

## The deterministic map from a standard-normal draw to each shape family, used
## by both the sampler and the quadrature so the two integrate the same law.
shape_map <- function(x, shape, mu, sigma) {
  if (shape == "mvnorm") return(x)
  p <- ncol(x)
  out <- x
  for (j in seq_len(p)) {
    m_j <- mu[j]; s_j <- sigma[j]
    if (shape == "lognormal") {
      shift <- m_j - 4 * s_j
      mm <- m_j - shift
      s2 <- log1p((s_j / mm)^2)
      out[, j] <- exp(log(mm) - s2 / 2 + sqrt(s2) * (x[, j] - m_j) / s_j) + shift
    } else if (shape == "mixed" && j == 1L) {
      out[, j] <- as.numeric(x[, j] > m_j)
    }
  }
  out
}

## Gauss-Hermite nodes and weights, by the Golub-Welsch eigenvalue method. The
## same routine CMP-14 uses, kept here rather than sourced so this study's
## integration is not silently coupled to another study's edits.
gh_rule <- function(n) {
  i <- seq_len(n - 1); J <- matrix(0, n, n)
  J[cbind(i, i + 1)] <- sqrt(i / 2); J[cbind(i + 1, i)] <- sqrt(i / 2)
  e <- eigen(J, symmetric = TRUE); o <- order(e$values)
  list(x = e$values[o], w = sqrt(pi) * (e$vectors[1, o])^2)
}
