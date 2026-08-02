## ---------------------------------------------------------------------------
## The methods, and a correction to DESIGN.md section 5 that implementation forced.
##
## SECTION 5 LISTS MAXIMUM ENTROPY AND INDEPENDENCE AS TWO ARMS. THEY ARE ONE.
## The maximum-entropy law subject only to fixed marginals is the product of those
## marginals: differential entropy satisfies H(f) <= sum_i H(f_i) with equality if
## and only if the coordinates are independent, so "least committed law consistent
## with the reported marginals" and "independence" name the same distribution.
## Adding a covariance constraint gives the Gaussian law, which is the borrowed
## correlation arm. So the two reconstructions the design lists are not two
## heuristics to be compared; they are the maximum-entropy solutions under the two
## information sets an analyst can actually have:
##
##   marginals only                 -> independence
##   marginals plus a covariance    -> Gaussian
##
## That is a simplification rather than a loss. It also means the study cannot
## report "maximum entropy beat independence", and any result claiming so would be
## an arithmetic error rather than a finding.
##
## UNCERTAINTY IS BY DELTA METHOD, NOT BOOTSTRAP. The reported marginals are exact
## here by design, so the only sampling uncertainty is in the IPD model fit, and
## the standardized contrast is a smooth function of the fitted coefficients whose
## gradient is available in closed form. That is exact at the model, costs one
## matrix product instead of hundreds of refits, and leaves nothing for a
## bootstrap's own Monte Carlo error to contaminate. EST-07 and MIS-03 own
## uncertainty in the reported moments, which is switched off here.
##
##   source("R/02-methods.R")
## ---------------------------------------------------------------------------

source("R/01-dgm.R")

## --- the fitted model -------------------------------------------------------
##
## Correctly specified in the IPD trial: MOD-02 owns misspecification. The design
## matrix carries prognostic main effects and the modification terms the truth
## uses, so any error the study reports is reconstruction error and not a
## structural mistake in the outcome model.
design_matrix <- function(x, arm, modification) {
  d <- ncol(x)
  z <- cbind(1, x, arm, arm * x[, 1])
  nm <- c("(Intercept)", paste0("x", seq_len(d)), "A", "A:x1")
  if (identical(modification, "nonlinear")) {
    z <- cbind(z, arm * x[, 1]^2)
    nm <- c(nm, "A:x1sq")
  }
  colnames(z) <- nm
  z
}

fit_ipd <- function(x, arm, y, modification) {
  Z <- design_matrix(x, arm, modification)
  f <- try(stats::glm.fit(Z, y, family = stats::binomial()), silent = TRUE)
  if (inherits(f, "try-error") || !f$converged) return(NULL)
  ## Model-based covariance from the IRLS weights; the model is correct here, so
  ## this is the efficient variance and a sandwich would only add noise.
  W <- f$weights
  XtWX <- crossprod(Z * sqrt(W))
  V <- try(chol2inv(chol(XtWX)), silent = TRUE)
  if (inherits(V, "try-error")) return(NULL)
  list(beta = f$coefficients, V = V, modification = modification)
}

## --- standardization over a law, with its delta-method variance --------------
##
## `xs` is an integration sample from whatever law the method believes the target
## has. The oracle passes the true law, independence passes a product law, the
## borrowed arm passes a Gaussian law with the IPD correlation matrix. Everything
## else about the three is identical, which is what makes their differences
## attributable to the reconstruction and to nothing else.
standardize <- function(fit, xs, scale) {
  Z1 <- design_matrix(xs, 1L, fit$modification)
  Z0 <- design_matrix(xs, 0L, fit$modification)
  e1 <- stats::plogis(as.vector(Z1 %*% fit$beta))
  e0 <- stats::plogis(as.vector(Z0 %*% fit$beta))
  p1 <- mean(e1); p0 <- mean(e0)
  if (p1 <= 0 || p1 >= 1 || p0 <= 0 || p0 >= 1) return(NULL)

  ## d pbar / d beta, averaged over the integration sample.
  g1 <- as.vector(crossprod(Z1, e1 * (1 - e1))) / nrow(Z1)
  g0 <- as.vector(crossprod(Z0, e0 * (1 - e0))) / nrow(Z0)

  if (identical(scale, "logOR")) {
    est  <- log(p1 / (1 - p1)) - log(p0 / (1 - p0))
    grad <- g1 / (p1 * (1 - p1)) - g0 / (p0 * (1 - p0))
  } else {
    est  <- p1 - p0
    grad <- g1 - g0
  }
  se <- sqrt(max(as.vector(t(grad) %*% fit$V %*% grad), 0))
  list(est = est, se = se)
}

## --- the integration samples each method believes in ------------------------
##
## Cached per law and reused across replicates at a fixed seed, so the numerical
## integration error is a FIXED OFFSET rather than replicate-to-replicate noise.
## That matters for the null control: two methods integrating the same law must
## agree exactly, and they cannot if each redraws its own points.
.int_cache <- new.env(parent = emptyenv())

## A deterministic seed from the law's key, so a cached sample is reproducible
## and two different laws never silently share one. Position-weighted over the
## key's bytes, reduced modulo a prime well inside integer range.
.key_seed <- function(key) {
  b <- utils::head(as.integer(charToRaw(key)), 64L)
  as.integer(MASTER_SEED %% 1000L +
             sum(b * seq_along(b)) %% 2000000011L %% 100000000L)
}

integration_sample <- function(key, gen, n) {
  z <- .int_cache[[key]]
  if (!is.null(z)) return(z)
  old <- if (exists(".Random.seed", .GlobalEnv))
           get(".Random.seed", .GlobalEnv) else NULL
  set.seed(.key_seed(key))
  z <- gen(n)
  if (!is.null(old)) assign(".Random.seed", old, .GlobalEnv)
  .int_cache[[key]] <- z
  z
}

## A RECONSTRUCTED law is built from marginals the analyst was given, and those
## are exact here by design, so its integration sample is forced to the reported
## mean and standard deviation exactly. Otherwise two reconstructions would differ
## partly through their samples' incidental marginal wobble, and the study would
## be attributing to dependence what is really Monte Carlo error in a mean. The
## ORACLE gets no such treatment: it integrates the true law, and forcing its
## marginals would change the law it is supposed to represent.
.exact_margins <- function(s)
  sweep(sweep(s, 2, colMeans(s), "-"), 2, apply(s, 2, stats::sd), "/")

## The true target law: the ceiling. Isolates reconstruction from everything else.
law_oracle <- function(d, rho, family, n)
  integration_sample(sprintf("oracle|%d|%.3f|%s", d, rho, family),
                     function(k) draw_target(k, d, rho, family), n)

## ONE STANDARD NORMAL BASE SAMPLE PER DIMENSION, SHARED BY EVERY GAUSSIAN LAW.
## Each of them is then a linear map of the same points, so the numerical
## integration error is common to all of them and largely cancels in the
## method-to-method contrasts the study reports. It also keeps the borrowed
## correlation arm affordable: its matrix is re-estimated every replicate, so
## caching a sample per matrix would store one integration sample per replicate.
base_normal <- function(d, n)
  integration_sample(sprintf("base|%d", d),
                     function(k) .exact_margins(matrix(stats::rnorm(k * d), k, d)), n)

## Independence, which is the maximum-entropy law given the reported marginals.
law_independence <- function(d, n) base_normal(d, n)

## A Gaussian law with a supplied correlation matrix: the maximum-entropy law
## given the reported marginals plus a covariance. The correlation is borrowed
## from the IPD trial, which is what implementations do. Not cached, because the
## matrix is a per-replicate quantity; the transform is one matrix product.
law_gaussian <- function(R, n) {
  d <- nrow(R)
  ## Nearest positive semi-definite by eigenvalue flooring, since a correlation
  ## matrix estimated in a finite sample and then reused need not stay PD.
  e <- eigen((R + t(R)) / 2, symmetric = TRUE)
  L <- e$vectors %*% diag(sqrt(pmax(e$values, 1e-8)), d) %*% t(e$vectors)
  .exact_margins(base_normal(d, n) %*% L)
}

## --- the reconstruction interval --------------------------------------------
##
## The contrast over every law consistent with the reported marginals and a
## DECLARED correlation range. This is the honest output when the dependence is
## unknown, and it is judged two-sided: an interval that covers by spanning
## implausible laws is not a result, so its width is reported beside its coverage.
##
## The set is explored over exchangeable correlation matrices across the declared
## range. That is a restriction and it is named: a non-exchangeable matrix inside
## the same range could push the contrast further, so the width reported here is a
## LOWER bound on the width an exhaustive search would produce, which makes the
## coverage reported here an optimistic reading of the method rather than a
## flattering one of its width.
RECON_GRID <- 9L

reconstruction_interval <- function(fit, d, scale, n_int) {
  rr <- seq(RECON_RHO_RANGE[1], RECON_RHO_RANGE[2], length.out = RECON_GRID)
  ## An exchangeable correlation matrix is positive definite only above
  ## -1/(d-1); anything below is not a covariance matrix and is dropped rather
  ## than floored, since flooring would silently change the declared range.
  rr <- rr[rr > -1 / (d - 1) + 1e-6]
  out <- lapply(rr, function(r) {
    R <- matrix(r, d, d); diag(R) <- 1
    s <- standardize(fit, law_gaussian(R, n_int), scale)
    if (is.null(s)) return(NULL)
    c(lo = s$est - stats::qnorm(1 - (1 - NOMINAL) / 2) * s$se,
      hi = s$est + stats::qnorm(1 - (1 - NOMINAL) / 2) * s$se, est = s$est)
  })
  out <- do.call(rbind, Filter(Negate(is.null), out))
  if (is.null(out) || !nrow(out)) return(NULL)
  list(est = stats::median(out[, "est"]),
       lo = min(out[, "lo"]), hi = max(out[, "hi"]))
}

## --- conventional STC at target means ---------------------------------------
##
## The plug-in: evaluate the fitted conditional model at the target's mean
## covariate vector. Carried as a labeled reference point only. The catalog is
## blunt that this mismatch is closed, and rebuilding it would be a weak study;
## it appears here so the reconstruction error can be read against the size of the
## error the field has already solved.
stc_at_means <- function(fit, d, scale) {
  xbar <- matrix(0, 1, d)   # target marginals are standard normal by construction
  Z1 <- design_matrix(xbar, 1L, fit$modification)
  Z0 <- design_matrix(xbar, 0L, fit$modification)
  p1 <- stats::plogis(as.vector(Z1 %*% fit$beta))
  p0 <- stats::plogis(as.vector(Z0 %*% fit$beta))
  est <- if (identical(scale, "logOR"))
    log(p1 / (1 - p1)) - log(p0 / (1 - p0)) else p1 - p0
  grad <- if (identical(scale, "logOR"))
    as.vector(Z1) - as.vector(Z0)
  else
    as.vector(Z1) * p1 * (1 - p1) - as.vector(Z0) * p0 * (1 - p0)
  list(est = est,
       se = sqrt(max(as.vector(t(grad) %*% fit$V %*% grad), 0)))
}
