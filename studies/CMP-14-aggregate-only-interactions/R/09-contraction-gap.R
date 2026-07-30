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

## Newton on F(theta) = U_expected(theta) - P0 theta, whose Jacobian is
## -(I(theta) + P0). Started at the truth, which is where the registered
## calculation stops.
find_map <- function(b, th_true, P0, tol = 1e-10, maxit = 50L) {
  th <- th_true
  for (it in seq_len(maxit)) {
    Fv <- expected_score(b, th, th_true) - as.vector(P0 %*% th)
    if (max(abs(Fv)) < tol) return(list(theta = th, iter = it, converged = TRUE))
    J <- logit_info(b, th)$total + P0
    th <- th + as.vector(solve(J, Fv))
  }
  list(theta = th, iter = maxit, converged = FALSE)
}

gap_for <- function(row) {
  net <- build_state_nl(row$state, row$spread, row$sd_ratio, row$n)
  b <- build_design(net)
  th <- theta_true_nl(b)
  gi <- gi_of(b)
  P0 <- prior_precision(b, row$prior_sd)

  ## Registered: information at the truth.
  sd_reg <- sqrt(solve(logit_info(b, th)$total + P0)[gi, gi])

  ## Laplace analogue: information at the expected-data mode.
  m <- find_map(b, th, P0)
  sd_lap <- sqrt(solve(logit_info(b, m$theta)$total + P0)[gi, gi])

  data.frame(state = row$state, prior_sd = row$prior_sd, n = row$n,
             spread = row$spread, sd_ratio = row$sd_ratio,
             contraction_registered = sd_reg / row$prior_sd,
             contraction_laplace = sd_lap / row$prior_sd,
             mode_shift = abs(m$theta[gi] - th[gi]),
             converged = m$converged)
}

main <- function() {
  grid <- build_grid_e2()
  ## The gap is a property of the approximation, not of misspecification, so it
  ## is measured where the model is correctly specified. Misspecified rows carry
  ## a displaced mode for a second reason and would confound the two.
  grid <- grid[grid$discord == 0 & grid$synergy == 0, ]
  res <- do.call(rbind, lapply(seq_len(nrow(grid)),
                               function(i) gap_for(grid[i, ])))
  res$abs_gap <- abs(res$contraction_registered - res$contraction_laplace)
  res$rel_gap <- res$abs_gap / res$contraction_registered

  stopifnot("some expected-data mode did not converge" = all(res$converged))

  cat("=== registered contraction against its Laplace analogue ===\n")
  cat(sprintf("scenarios: %d (correctly specified only)\n", nrow(res)))
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
