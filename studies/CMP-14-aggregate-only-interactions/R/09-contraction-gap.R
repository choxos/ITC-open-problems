## ---------------------------------------------------------------------------
## HOW FAR IS THE REGISTERED CONTRACTION FROM A LAPLACE CONTRACTION?
##
## The protocol used to say two things about E2's contraction. One was a wrong
## label and one was an admission.
##
## THE LABEL. It called the quantity "contraction of a Laplace approximation".
## It is not. `evaluate_e2` computes the Fisher information at the TRUE
## parameter and forms (I(theta_true) + P0)^{-1}. A Laplace covariance is the
## inverse Hessian of the log posterior at the posterior MODE. Those coincide
## when the information does not depend on the parameter, which is true on an
## identity link and false on the logit link E2 uses, and when the mode equals
## the truth, which a proper prior centred at zero makes false by construction.
##
## THE ADMISSION. It said "the gap is bounded by nothing measured here". That is
## a caveat that can be deleted by measuring it, which is what this file does.
##
## WHICH QUANTITY IS THE RIGHT ONE. The registered one. E2 is an exact
## information calculation with no data and no sampling: evaluating at the truth
## is deterministic, is a property of the design rather than of a realized
## dataset, and is what makes the state comparison clean. Moving to a Laplace
## covariance would make the diagnostic depend on where a prior happens to pull
## the mode, which is the prior's behaviour and not the design's. So the code
## stays and the label is corrected, and this file reports how much the choice
## costs so a reader does not have to take that on trust.
##
## THE EXPECTED-DATA MODE. With no realized data the natural comparator is the
## MAP under data at their expectation under theta_true: the theta solving
##
##      U(theta ; expected data at theta_true)  =  P0 theta
##
## `displacement()` cannot be reused for this, because it recomputes the true
## proportions at whatever theta it is handed and therefore returns zero. The
## score below fixes the data-generating parameter and varies the evaluation
## parameter, which is the whole point.
##
##   Rscript R/09-contraction-gap.R
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(MASS))
Sys.setenv(NL_NOMAIN = "1", E1_NOMAIN = "1", ANALYZE_NOMAIN = "1", E2_NOMAIN = "1")
source("R/07-run-e2.R")

## Score at `theta_eval` when the data sit at their expectation under
## `theta_dgp`. Mirrors `displacement()` row for row; only the two parameters
## are separated.
expected_score <- function(b, theta_eval, theta_dgp) {
  U <- numeric(b$p)
  gh <- gh_rule(64)
  for (i in seq_len(nrow(b$net))) {
    if (as.logical(b$net$ipd[i])) {
      xs <- b$net$mu[i] + sqrt(2) * b$net$sd[i] * gh$x
      w  <- gh$w / sqrt(pi)
      for (j in seq_along(xs)) {
        r <- design_row(b$net, i, xs[j], b$S, b$K)
        p_eval <- expit(sum(r * theta_eval))
        p_dgp  <- expit(sum(r * theta_dgp))
        U <- U + b$net$n[i] * w[j] * (p_dgp - p_eval) * r
      }
    } else {
      pb <- agg_p(theta_eval, b, i)
      g  <- agg_grad(theta_eval, b, i)
      p_dgp <- agg_p(theta_dgp, b, i)
      U <- U + (b$net$n[i] / (pb * (1 - pb))) * g * (p_dgp - pb)
    }
  }
  U
}

## THE OBSERVED HESSIAN, WHICH IS NOT THE FISHER INFORMATION AWAY FROM THE DGP.
##
## Round 7: this file reported `logit_info()` at the mode and called the result a
## Laplace covariance. It is not. For an AGGREGATE arm the log-likelihood is
##
##   l = n [ q log p(theta) + (1 - q) log(1 - p(theta)) ],
##
## with q the arm proportion the data sit at and p(theta) the model's integrated
## arm probability. Differentiating twice,
##
##   -d2l/dtheta2 = n { [p(1-p) + (q-p)(1-2p)] / [p(1-p)]^2 * g g'
##                      - (q-p)/[p(1-p)] * H_p },
##
## where g = dp/dtheta and H_p = d2p/dtheta2. At q = p both correction terms
## vanish and this collapses to the Fisher term n g g'/[p(1-p)], which is what
## `logit_info` supplies. A proper prior MOVES THE MODE, so q - p is nonzero
## there and the omitted terms are exactly what distinguishes a Laplace
## covariance from Fisher-at-mode. Reporting the second while claiming the first
## measured the wrong thing.
##
## INDIVIDUAL-DATA ARMS NEED NO CORRECTION. For a canonical link with
## per-individual Bernoulli data the observed and expected Hessians coincide,
## -d2l/dtheta2 = n w p(1-p) r r', with no residual term. So the correction is an
## aggregate-arm phenomenon, which is the same asymmetry the rest of the study
## turns on.
agg_hess_p <- function(theta, b, i) {
  gh <- gh_rule(64)
  xs <- b$net$mu[i] + sqrt(2) * b$net$sd[i] * gh$x
  w  <- gh$w / sqrt(pi)
  rows <- t(vapply(xs, function(x) design_row(b$net, i, x, b$S, b$K),
                   numeric(b$p)))
  p <- expit(as.vector(rows %*% theta))
  ## d2/deta2 expit(eta) = p(1-p)(1-2p).
  crossprod(rows, rows * (w * p * (1 - p) * (1 - 2 * p)))
}

observed_hessian <- function(b, theta_eval, theta_dgp) {
  H <- matrix(0, b$p, b$p)
  gh <- gh_rule(64)
  for (i in seq_len(nrow(b$net))) {
    if (as.logical(b$net$ipd[i])) {
      xs <- b$net$mu[i] + sqrt(2) * b$net$sd[i] * gh$x
      w  <- gh$w / sqrt(pi)
      rows <- t(vapply(xs, function(x) design_row(b$net, i, x, b$S, b$K),
                       numeric(b$p)))
      p <- expit(as.vector(rows %*% theta_eval))
      H <- H + b$net$n[i] * crossprod(rows, rows * (w * p * (1 - p)))
    } else {
      p  <- agg_p(theta_eval, b, i)
      g  <- agg_grad(theta_eval, b, i)
      Hp <- agg_hess_p(theta_eval, b, i)
      q  <- agg_p(theta_dgp, b, i)
      v  <- p * (1 - p)
      H <- H + b$net$n[i] * (((v + (q - p) * (1 - 2 * p)) / v^2) * tcrossprod(g)
                             - ((q - p) / v) * Hp)
    }
  }
  H
}

## Newton on F(theta) = U_expected(theta) - P0 theta, whose Jacobian is
## -(H(theta) + P0) with H the OBSERVED Hessian above. Using the Fisher
## information instead is Fisher scoring: it converges to the same root, because
## the SCORE is exact either way, but it is not the curvature a Laplace
## approximation inverts. Started at the data-generating parameter, which is
## where the registered calculation stops.
find_map <- function(b, th_true, P0, tol = 1e-10, maxit = 50L) {
  th <- th_true
  for (it in seq_len(maxit)) {
    Fv <- expected_score(b, th, th_true) - as.vector(P0 %*% th)
    if (max(abs(Fv)) < tol) return(list(theta = th, iter = it, converged = TRUE))
    J <- observed_hessian(b, th, th_true) + P0
    th <- th + as.vector(solve(J, Fv))
  }
  list(theta = th, iter = maxit, converged = FALSE)
}

gap_for <- function(row) {
  net <- build_state_nl(row$state, row$spread, row$sd_ratio, row$n)
  b <- build_design(net)
  gi <- gi_of(b)
  ## The parameter the data come from, which under a departure is the aliased
  ## theta* rather than theta_true. Round 6 established that the two departures
  ## are exactly a shift of this coordinate, so the expected-data mode is a
  ## well-posed object on every scenario rather than only on the undisturbed ones.
  th <- theta_true_nl(b)
  th[gi] <- th[gi] + row$discord + row$synergy
  P0 <- prior_precision(b, row$prior_sd)

  ## Registered: information at the truth.
  sd_reg <- sqrt(solve(logit_info(b, th)$total + P0)[gi, gi])

  ## Laplace analogue: the OBSERVED Hessian of the log posterior at the
  ## expected-data mode, which is what a Laplace approximation inverts. Using
  ## logit_info() here gave Fisher-at-mode and was reported as Laplace.
  m <- find_map(b, th, P0)
  H_obs <- observed_hessian(b, m$theta, th)
  sd_lap <- sqrt(solve(H_obs + P0)[gi, gi])
  ## How much the correction terms mattered, so the change is measured rather
  ## than asserted: the same quantity under the Fisher approximation this
  ## replaced.
  sd_fisher <- sqrt(solve(logit_info(b, m$theta)$total + P0)[gi, gi])

  data.frame(state = row$state, prior_sd = row$prior_sd, n = row$n,
             spread = row$spread, sd_ratio = row$sd_ratio,
             contraction_registered = sd_reg / row$prior_sd,
             contraction_laplace = sd_lap / row$prior_sd,
             contraction_fisher_at_mode = sd_fisher / row$prior_sd,
             mode_shift = abs(m$theta[gi] - th[gi]),
             converged = m$converged)
}

main <- function() {
  ## EVERY scenario, not just the undisturbed ones. The earlier restriction was
  ## justified by the claim that a departure displaces the mode "for a second
  ## reason"; round 6 showed there is no second reason, because the departure is
  ## exactly a relabelling of one coordinate and the model is correct at theta*.
  grid <- build_grid_e2()
  res <- do.call(rbind, lapply(seq_len(nrow(grid)),
                               function(i) gap_for(grid[i, ])))
  res$abs_gap <- abs(res$contraction_registered - res$contraction_laplace)
  res$rel_gap <- res$abs_gap / res$contraction_registered

  stopifnot("some expected-data mode did not converge" = all(res$converged))

  cat("=== registered contraction against its Laplace analogue ===\n")
  cat(sprintf("scenarios: %d (the whole E2 grid)\n", nrow(res)))
  cat(sprintf("absolute gap: max %.6f, median %.6f\n",
              max(res$abs_gap), stats::median(res$abs_gap)))
  cat(sprintf("relative gap: max %.4f%%, median %.4f%%\n",
              100 * max(res$rel_gap), 100 * stats::median(res$rel_gap)))
  cat("\nworst five:\n")
  print(head(res[order(-res$abs_gap),
                 c("state", "prior_sd", "n", "contraction_registered",
                   "contraction_laplace", "abs_gap")], 5), row.names = FALSE)

  cat("\nby prior SD, where the prior pulls the mode hardest:\n")
  agg <- aggregate(abs_gap ~ prior_sd, res, max)
  print(agg, row.names = FALSE)

  saveRDS(list(table = res,
               max_abs = max(res$abs_gap), median_abs = stats::median(res$abs_gap),
               max_rel = max(res$rel_gap), n_scenarios = nrow(res)),
          "results/contraction-gap.rds")
  cat("\nwritten: results/contraction-gap.rds\n")
}

if (!interactive() && Sys.getenv("GAP_NOMAIN") == "") main()
