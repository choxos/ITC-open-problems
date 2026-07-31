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
## ONE DEFINITION OF THE LAW, used by the sampler and by the quadrature.
##
## ROUND 1 OF CRITIQUE, and this is what was underneath the `mixed` arm's lost
## overlap. There were TWO implementations. `shape_map()` carried a comment saying
## it was "used by both the sampler and the quadrature so the two integrate the
## same law", and this function did not call it: its mixed branch thresholded the
## CENTERED draw, `as.numeric(Z[, 1] > 0)`, which ignores mu and therefore gives
## P(X = 1) = 0.5 in the source and the target alike.
##
## So the realized overlap on that covariate was 0.001 against a registered 0.40,
## and, worse, the truth was being computed by integrating a law the sampler never
## drew. Two implementations of one object is how that happens, so there is now
## one: this function draws the correlated Gaussian and hands it to `shape_map()`.
covariate_law <- function(shape, n, mu, sigma, rho) {
  p <- length(mu)
  R <- matrix(rho, p, p); diag(R) <- 1
  S <- diag(sigma, p) %*% R %*% diag(sigma, p)
  Z <- MASS::mvrnorm(n, rep(0, p), S)
  shape_map(sweep(Z, 2, mu, "+"), shape, mu, sigma)
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
## Returns the two ARM MEANS on the response scale, not the contrast. The
## anchored estimand is a difference of contrasts and the unanchored one is a
## difference of single arms, so both are built from these rather than each
## re-integrating the same law.
arm_means_superpopulation_normal <- function(pars, link, mu, sigma, rho, order) {
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
  c(m0 = arm(pars$beta_prog, pars$alpha),
    m1 = arm(pars$beta_prog + pars$beta_em, pars$alpha + pars$tau0))
}

## The superpopulation estimand by Gauss-Hermite quadrature over the TRUE law.
## The order is PROBE P1's output and is never defaulted: OUT-11's integration
## order moved a primary contrast and was caught only because it was measured.
arm_means_superpopulation <- function(pars, link, shape, mu, sigma, rho, order) {
  stopifnot("the quadrature order must come from probe P1" = is.finite(order))
  ## The exact reduction where it applies. P1's order was chosen on the product
  ## rule and is reused here, which is conservative: a one-dimensional integral
  ## needs no more nodes than the same rule needed in three dimensions.
  if (shape == "mvnorm")
    return(arm_means_superpopulation_normal(pars, link, mu, sigma, rho, order))
  stopifnot("the product rule is only affordable to three covariates; the
             non-normal shapes are crossed with the middle level of the other
             factors precisely so this cannot be reached at four"
              = length(mu) <= 3L)
  p <- length(mu)
  ## A product rule over p dimensions. p is 3 and the order is small, so the
  ## node count is order^3 and is affordable; a sparse rule would be a second
  ## approximation to justify.
  ##
  ## PER-COORDINATE RULES. Every coordinate gets Gauss-Hermite except one that
  ## the shape map makes discontinuous, which gets the split rule above. Under
  ## `mixed` that is the first coordinate and only the first; under `lognormal`
  ## the map is smooth and monotone, so nothing changes.
  gh <- gh_rule(order)
  gh_n <- list(x = sqrt(2) * gh$x, w = gh$w / sqrt(pi))   # standard-normal form
  ## The jump is where the covariate crosses BINARY_CUT. `L` is upper triangular
  ## from `chol`, so the first coordinate of `z %*% L` is `z1 * L[1, 1]` and the
  ## crossing is at z1 = (BINARY_CUT - mu[1]) / L[1, 1]. The cut is a constant but
  ## mu differs between source and target, so the split point is NOT always zero
  ## and computing it is not optional.
  Rc <- matrix(rho, p, p); diag(Rc) <- 1
  Lc <- chol(diag(sigma, p) %*% Rc %*% diag(sigma, p))
  sp <- if (shape == "mixed")
          split_normal_rule(order, (BINARY_CUT - mu[1]) / Lc[1, 1]) else NULL
  rules <- lapply(seq_len(p), function(j)
    if (!is.null(sp) && j == 1L) sp else gh_n)

  idx <- as.matrix(expand.grid(lapply(rules, function(r) seq_along(r$x))))
  R <- matrix(rho, p, p); diag(R) <- 1
  L <- chol(diag(sigma, p) %*% R %*% diag(sigma, p))
  z <- vapply(seq_len(p), function(j) rules[[j]]$x[idx[, j]], numeric(nrow(idx)))
  w <- Reduce(`*`, lapply(seq_len(p), function(j) rules[[j]]$w[idx[, j]]))
  xs <- sweep(z %*% L, 2, mu, "+")
  if (shape != "mvnorm") {
    ## For a non-normal law the same nodes are pushed through the shape map, so
    ## the quadrature integrates the TRANSFORMED variable against its own
    ## measure. P1 checks that this is stable to QUAD_TOL on the most skewed law
    ## in the grid, and drops the skew arm if it is not.
    xs <- shape_map(xs, shape, mu, sigma)
  }
  cm <- conditional_means(xs, pars, link)
  c(m0 = sum(w * cm$mu0), m1 = sum(w * cm$mu1))
}

## The contrast, from the arm means.
delta_superpopulation <- function(pars, link, shape, mu, sigma, rho, order) {
  am <- arm_means_superpopulation(pars, link, shape, mu, sigma, rho, order)
  delta_from_arm_means(am[["m0"]], am[["m1"]], link)
}

delta_superpopulation_normal <- function(pars, link, mu, sigma, rho, order) {
  am <- arm_means_superpopulation_normal(pars, link, mu, sigma, rho, order)
  delta_from_arm_means(am[["m0"]], am[["m1"]], link)
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
      ## A FIXED cut, not the covariate's own mean. Thresholding at the mean gave
      ## P(X = 1) = 0.5 in both populations and destroyed the overlap this arm is
      ## supposed to have.
      out[, j] <- as.numeric(x[, j] > BINARY_CUT)
    }
  }
  out
}

## --- THE ANCHORED TRUTH, which is the estimand the methods actually return ---
##
## Round 1 of critique: `delta_superpopulation` returns the transported A-versus-C
## contrast, while every MAIC and STC point estimate returns A-versus-C MINUS the
## target trial's own B-versus-C effect. Nothing in the study constructed the
## matching truth, so bias against the stated estimand could not be computed and
## comparing an indirect estimate with a direct truth would have counted the
## entire B-versus-C effect as bias.
##
## Both estimands the design registers are built here from the same pieces, so
## the pair differs only in which measure the arms are integrated against.
##
##   superpopulation : both contrasts over the TRUE target law
##   finite_target   : both contrasts over the REALIZED target sample
##
## `pars` carries the source trial's modification and `pars_T` the target
## trial's, which is where `k` acts.
## --- THE UNANCHORED ESTIMAND ------------------------------------------------
##
## Added after the probe phase showed the anchored contrast cannot see the effect
## this study is about. In an anchored comparison the target trial's own B versus
## C effect carries about 83% of the interval's variance, so the moment term is
## roughly 1% of it and clears the detectability floor in 3 of 288 cells. Without
## an anchor there is no B-versus-C difference, only the target's single treated
## arm, and the moment term becomes a much larger share of a smaller total.
##
## The estimand is the transported A arm against the target's own B arm, with no
## common comparator to difference away:
##
##   Delta_unanchored(F_T) = g( int mu_A dF_T ) - g( int mu_B dF_T ),
##
## where mu_A uses the SOURCE parameters and mu_B the TARGET ones. It is the same
## integrals the anchored estimand uses, without the two control arms.
truth_unanchored_superpop <- function(pars, pars_T, link, shape, mu, sigma, rho,
                                      order) {
  lf <- link_fns(link)
  a <- arm_means_superpopulation(pars,   link, shape, mu, sigma, rho, order)
  b <- arm_means_superpopulation(pars_T, link, shape, mu, sigma, rho, order)
  lf$g(a[["m1"]]) - lf$g(b[["m1"]])
}

truth_unanchored_finite <- function(pars, pars_T, x, link) {
  lf <- link_fns(link)
  lf$g(mean(conditional_means(x, pars,   link)$mu1)) -
  lf$g(mean(conditional_means(x, pars_T, link)$mu1))
}

## --- THE MOMENT-MATCHED CONTRAST -------------------------------------------
##
## The quantity prediction 1 says the methods actually target, added because a
## reviewer pointed out that neither registered estimand is it.
##
## MAIC reweights the source until the weighted covariate moments equal the
## reported ones. What it converges to is therefore the contrast under a law
## carrying the TARGET'S REPORTED MOMENTS and the analyst's assumed shape, a
## Gaussian copula, rather than under the target's actual law. Prediction 1 is
## that those two differ and that the gap is a bias rather than a variance.
##
## Reporting coverage against all three separates the mechanism completely:
##   superpopulation   the estimand anyone actually wants
##   moment_matched    what a moment-matching method converges to
##   finite_target     the realized target sample, which is neither
## A method covering the moment-matched contrast well and the superpopulation one
## badly is not reporting the wrong width; it is answering a different question,
## which is the claim stated rather than a claim about variance.
truth_moment_matched <- function(pars, pars_T, link, mean_T, sd_T, R, order,
                                 anchored = TRUE) {
  p <- length(mean_T)
  ## The reconstruction is a Gaussian copula on the reported moments, so `rho` is
  ## read off the assumed correlation matrix; a single off-diagonal suffices
  ## because `delta_superpopulation` builds an exchangeable matrix from it.
  rho <- if (p > 1) mean(R[lower.tri(R)]) else 0
  if (anchored)
    truth_anchored_superpop(pars, pars_T, link, "mvnorm", mean_T, sd_T, rho,
                            order)
  else
    truth_unanchored_superpop(pars, pars_T, link, "mvnorm", mean_T, sd_T, rho,
                              order)
}

truth_anchored_superpop <- function(pars, pars_T, link, shape, mu, sigma, rho,
                                    order) {
  delta_superpopulation(pars,   link, shape, mu, sigma, rho, order) -
  delta_superpopulation(pars_T, link, shape, mu, sigma, rho, order)
}

truth_anchored_finite <- function(pars, pars_T, x, link) {
  delta_sample(x, pars, link) - delta_sample(x, pars_T, link)
}

## Gauss-Hermite nodes and weights, by the Golub-Welsch eigenvalue method. The
## same routine CMP-14 uses, kept here rather than sourced so this study's
## integration is not silently coupled to another study's edits.
## --- the binary covariate's threshold and its overlap -----------------------
##
## ROUND 1 OF CRITIQUE: the `mixed` arm did not preserve the registered overlap,
## and the way it failed switched the arm off.
##
## `shape_map` used to threshold at the covariate's OWN population mean, so the
## source cut at 0 and the target cut at OVERLAP_SMD, and both gave
## P(X = 1) = 0.5. Measured realized SMD on that covariate: +0.001 against a
## registered 0.40. Since `beta_em[1]` carries the effect modification, the
## modifier was perfectly balanced between source and target throughout the mixed
## shape, MAIC had nothing to correct, and a third of the shape factor tested
## nothing.
##
## THE CUT MUST BE THE SAME CONSTANT IN BOTH POPULATIONS, or there is no
## imbalance to create. Fixing the cut is necessary but not sufficient: a binary
## variable's SMD is bounded given the latent shift, and at a shift of 0.40 the
## best any cut achieves is about 0.321, reached at c = 0.20. So the binary
## covariate also needs its own latent shift, solved so that its REALIZED
## standardized difference is the registered one.
##
## `binary_latent_shift()` solves it with the cut at half the shift, which is the
## symmetric choice and the one that maximizes the achievable difference.
binary_smd <- function(d, cut) {
  p_s <- 1 - stats::pnorm(cut)
  p_t <- 1 - stats::pnorm(cut - d)
  (p_t - p_s) / sqrt((p_s * (1 - p_s) + p_t * (1 - p_t)) / 2)
}

binary_latent_shift <- function(smd = OVERLAP_SMD) {
  f <- function(d) binary_smd(d, d / 2) - smd
  stats::uniroot(f, c(1e-6, 6))$root
}

## Registered once, from the registered overlap, so the sampler and the
## quadrature cannot cut at different places.
BINARY_SHIFT <- binary_latent_shift()
BINARY_CUT   <- BINARY_SHIFT / 2

## --- the rule for a coordinate the shape map makes DISCONTINUOUS -------------
##
## ROUND 1 OF CRITIQUE, and it started as "order 48 is not stable at the
## registered tolerance". It was not, and the reason was structural rather than a
## matter of buying more nodes.
##
## The `mixed` shape turns the first covariate into a binary one by
## `as.numeric(x[, 1] > mu[1])`, a STEP FUNCTION. Gauss-Hermite is built on
## polynomial exactness, so on a discontinuous integrand it loses its exponential
## convergence and falls back to roughly 1/n: measured deviations of 5.078e-04,
## 3.034e-04, 2.019e-04, 1.007e-04 and 5.031e-05 at orders 32, 48, 64, 96 and 128.
## Chasing a 1e-04 tolerance down that curve needs an order whose cube the product
## rule cannot afford, and the reference used to certify it would need to be
## higher still.
##
## The jump is at a KNOWN place. `L` is upper triangular from `chol`, so the first
## coordinate of `z %*% L` is `z[, 1] * L[1, 1]` and the covariate crosses its
## threshold exactly at z1 = 0. So the integral can be split there and each half
## integrated with a rule that is exact for smooth integrands, which restores
## exponential convergence and makes the binary covariate exact rather than
## approximated.
##
## The substitution is u = Phi(z), which turns the normal integral into a plain
## integral over (0, 1) with the jump at u = 1/2, and Gauss-Legendre runs on
## (0, 1/2) and (1/2, 1) separately.
gl_rule <- function(n) {
  i <- seq_len(n - 1); b <- i / sqrt(4 * i^2 - 1)
  J <- matrix(0, n, n)
  J[cbind(i, i + 1)] <- b; J[cbind(i + 1, i)] <- b
  e <- eigen(J, symmetric = TRUE); o <- order(e$values)
  list(x = e$values[o], w = 2 * (e$vectors[1, o])^2)
}

## Nodes and weights that integrate a function against the STANDARD NORMAL
## measure, exactly as `gh_rule` does after its sqrt(2) and sqrt(pi) scaling, but
## split at zero so a jump there costs nothing.
split_normal_rule <- function(n, at = 0) {
  gl <- gl_rule(n)
  ## The jump is at `at` on the standard-normal scale, which is u0 = Phi(at) after
  ## the substitution. Gauss-Legendre runs on (0, u0) and (u0, 1), so the split
  ## follows the jump wherever the population puts it rather than assuming it sits
  ## at the median.
  u0 <- stats::pnorm(at)
  u0 <- min(max(u0, 1e-12), 1 - 1e-12)
  lo <- u0 / 2 + (u0 / 2) * gl$x
  hi <- (1 + u0) / 2 + ((1 - u0) / 2) * gl$x
  list(x = stats::qnorm(c(lo, hi)),
       w = c((u0 / 2) * gl$w, ((1 - u0) / 2) * gl$w))
}

gh_rule <- function(n) {
  i <- seq_len(n - 1); J <- matrix(0, n, n)
  J[cbind(i, i + 1)] <- sqrt(i / 2); J[cbind(i + 1, i)] <- sqrt(i / 2)
  e <- eigen(J, symmetric = TRUE); o <- order(e$values)
  list(x = e$values[o], w = sqrt(pi) * (e$vectors[1, o])^2)
}
