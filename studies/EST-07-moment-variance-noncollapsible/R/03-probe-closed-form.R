## ---------------------------------------------------------------------------
## PROBE P3: does the ported gradient equal the one the estimand needs?
##
## THIS PROBE CAN END THE STUDY, and that is why it runs before anything else is
## built. The expected headline is that non-collapsibility breaks the published
## target-summary variance estimators. Those estimators propagate the gradient of
## the ESTIMATOR with respect to the reported moments; what the variance of the
## ESTIMAND requires is the gradient of the estimand. This probe computes both.
##
##   Identity link : they must coincide, and both must equal beta_EM. If they do
##                   not, the implementation is wrong and nothing downstream is
##                   evidence about anything.
##   Curved links  : if they coincide anyway, PREDICTION 2 IS FALSE, the ports
##                   are fine, and the expected headline is withdrawn here rather
##                   than after 2000 replicates in each of the grid's cells.
##
## The identity-link half is the check MIS-03 makes possible: it is the only case
## where the right answer is known in closed form, and two of this program's
## fatal findings were estimators that behaved plausibly and were implemented
## wrongly.
##
##   Rscript R/03-probe-closed-form.R
## ---------------------------------------------------------------------------

source("R/04-maic.R")

## THE REPLICATE COUNT AND THE CRITERION ARE BOTH DERIVED FROM THE MEASURED
## NOISE FLOOR, not typed. The first version of this probe compared the two
## gradients against an absolute 1e-3 and reported the identity-link half as a
## FAILURE. It was not: the per-replicate SD of each J component is 0.07 to 0.10,
## so at 40 replicates the standard error of the mean is 0.012, and 1e-3 sat ten
## times below the noise. Measured at 199 replicates the gap is 0.06 to 1.90
## standard errors, which is agreement.
##
## A threshold asserted rather than derived from the noise floor is the single
## most common defect this programme has found, and it very nearly went into a
## protocol here as evidence that correct code was wrong.
N_PROBE_REP <- 200L
NS_PROBE    <- 2000L    # large, so the estimator gradient is near its limit
NT_PROBE    <- 2000L
## THE IDENTITY-LINK CHECK IS A CONVERGENCE TEST, NOT A POINT COMPARISON.
##
## A second wrong version of this probe asked whether the two gradients agree
## within 3 standard errors at one source size, and reported FALSE at z = 3.49.
## They do not agree exactly at finite nS and they should not: the estimator
## gradient is a nonlinear function of the data, through A^{-1}, so it carries an
## O(1/n) finite-sample bias. A point comparison cannot tell that from a wrong
## implementation. Whether the gap SHRINKS AS THE SOURCE GROWS can.
##
## Measured on the identity link at k = 0.25 over 200 replicates:
##
##     nS =  500 -> 0.01288
##     nS = 2000 -> 0.00746
##     nS = 8000 -> 0.00216   (within one Monte Carlo SE of zero)
##
## So the implementation is right and the residual at the registered nS = 500 is
## a real finite-sample bias of about 0.013 against a beta_EM of 0.6, roughly 2%.
## That is disclosed rather than buried, and it is an order of magnitude below
## the 19% to 34% curvature effect the study is about.
IDENTITY_NS <- c(500L, 2000L, 8000L)
## The gap must fall by at least this factor from the smallest to the largest
## source size. A wrong implementation produces a gap that does not move.
CONVERGENCE_FACTOR <- 3

main <- function() {
  p <- load_probes()
  stopifnot("probe P1 has not run, so there is no quadrature order" =
              !is.null(p) && is.finite(p$QUAD_ORDER[[1]]))
  ord <- p$QUAD_ORDER[[1]]

  grid <- expand.grid(link = LINKS, k = LEVELS$k, stringsAsFactors = FALSE)
  set.seed(MASTER_SEED)

  res <- do.call(rbind, lapply(seq_len(nrow(grid)), function(i) {
    lk <- grid$link[i]; k <- grid$k[i]
    pars <- make_pars(k)
    pm <- population_means()
    sigma <- rep(1, N_COVARIATE); rho <- 0.3

    ## The estimand gradient, at the target population's own moments. It has no
    ## sampling error: it is a property of the DGM, not of a dataset.
    Jt <- delta_gradient(pm$target, sigma, pars, lk, "mvnorm", rho, ord)

    ## The estimator gradient, averaged over replicates so that what is compared
    ## is its limit rather than one noisy draw.
    Js <- matrix(NA_real_, N_PROBE_REP, length(Jt))
    for (r in seq_len(N_PROBE_REP)) {
      d <- sample_replicate(NS_PROBE, NT_PROBE, k, lk, "mvnorm", rho)
      eg <- estimator_gradient(d, lk)
      if (isTRUE(eg$ok)) Js[r, ] <- eg$J
    }
    Js <- Js[stats::complete.cases(Js), , drop = FALSE]
    Jhat <- colMeans(Js)
    n_ok <- nrow(Js)
    ## The Monte Carlo error of the comparison itself, which is what any claim
    ## about the two gradients has to be measured against.
    Jse <- apply(Js, 2, stats::sd) / sqrt(n_ok)
    z_gap <- max(abs(Jhat - Jt) / Jse)

    ## The consequence, which is what the study is about: the ported variance
    ## uses Jhat where the estimand needs Jt, so its error is the difference of
    ## the two quadratic forms in the same Omega.
    Om <- Omega_normal(pm$target, sigma, diag(N_COVARIATE) * (1 - rho) + rho)
    v_ported <- as.numeric(t(Jhat) %*% Om %*% Jhat) / NT_PROBE
    v_true   <- as.numeric(t(Jt)   %*% Om %*% Jt)   / NT_PROBE

    data.frame(link = lk, k = k, n_ok = n_ok,
               max_abs_gap = max(abs(Jhat - Jt)),
               max_se = max(Jse), z_gap = z_gap,
               rel_gap = max(abs(Jhat - Jt)) / max(abs(Jt)),
               beta_em_gap = max(abs(Jt[seq_len(N_COVARIATE)] - pars$beta_em)),
               v_ported = v_ported, v_true = v_true,
               v_ratio = v_ported / v_true,
               stringsAsFactors = FALSE)
  }))

  cat("=== P3: the ported gradient against the gradient the estimand needs ===\n\n")
  print(res, row.names = FALSE, digits = 4)

  ident <- res[res$link == "identity", ]
  curved <- res[res$link != "identity", ]

  cat("\n--- the half where the answer is known: does the gap converge? ---\n")
  pars0 <- make_pars(0.25); pm0 <- population_means()
  sig0 <- rep(1, N_COVARIATE); rho0 <- 0.3
  Jt0 <- delta_gradient(pm0$target, sig0, pars0, "identity", "mvnorm", rho0, ord)
  conv <- vapply(IDENTITY_NS, function(nS) {
    set.seed(MASTER_SEED + nS)
    Jm <- matrix(NA_real_, N_PROBE_REP, length(Jt0))
    for (r in seq_len(N_PROBE_REP)) {
      d <- sample_replicate(nS, 4000L, 0.25, "identity", "mvnorm", rho0)
      eg <- estimator_gradient(d, "identity")
      if (isTRUE(eg$ok)) Jm[r, ] <- eg$J
    }
    Jm <- Jm[stats::complete.cases(Jm), , drop = FALSE]
    max(abs(colMeans(Jm) - Jt0))
  }, 0)
  for (i in seq_along(IDENTITY_NS))
    cat(sprintf("  nS = %5d  max|E J_hat - J_true| = %.5f\n",
                IDENTITY_NS[i], conv[i]))
  ok_ident <- conv[1] / conv[length(conv)] >= CONVERGENCE_FACTOR
  cat(sprintf("the gap falls by at least %dx as the source grows: %s (%.1fx)\n",
              CONVERGENCE_FACTOR, ok_ident, conv[1] / conv[length(conv)]))
  if (!ok_ident)
    cat("  A GAP THAT DOES NOT SHRINK IS AN IMPLEMENTATION ERROR, not a finding:\n",
        "  under the identity link both gradients must equal beta_EM in the limit.\n",
        sep = "")

  cat("\n--- the half that can end the study ---\n")
  cat(sprintf("curved links: worst relative gap %.4f (%.1f SE), variance ratio %.4f to %.4f\n",
              max(curved$rel_gap), max(curved$z_gap),
              min(curved$v_ratio), max(curved$v_ratio)))
  headline_survives <- max(abs(curved$v_ratio - 1)) > 0.05
  cat(sprintf("the ported variance is off by more than 5%% somewhere: %s\n",
              headline_survives))
  if (!headline_survives)
    cat("\nPREDICTION 2 IS FALSE AT THESE SETTINGS. The ports carry the right\n",
        "gradient on a curved link, the catalog's porting claim survives, and\n",
        "DESIGN.md section 5's registered outcome applies: the study says so.\n",
        sep = "")

  dir.create("results", showWarnings = FALSE)
  p$P3_MAX_REL_ERR <- list(max(curved$rel_gap))
  p$P3_table <- list(res)
  p$P3_identity_ok <- list(ok_ident)
  p$P3_identity_convergence <- list(data.frame(nS = IDENTITY_NS, gap = conv))
  p$P3_headline_survives <- list(headline_survives)
  saveRDS(p, PROBE_FILE)
  cat("\nwritten: ", PROBE_FILE, "\n", sep = "")
}

if (!interactive() && Sys.getenv("P3_NOMAIN") == "") main()
