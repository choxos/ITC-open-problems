## ---------------------------------------------------------------------------
## Does the diagnostic get BETTER as the answer gets WORSE?
##
## R/02 established that a confounded ecological interaction can contract more
## than a randomized one, and that the knob doing it is the spread between the
## aggregate studies' covariate means. That is suggestive and not yet a result:
## contracting more is only damaging if the estimate is also wrong.
##
## The mechanism, stated so it can fail. Let the causal within-study modification
## be Gamma_W and the across-study association be Gamma_B, which differ because
## nobody randomized a study's case mix. A component seen only in aggregate
## studies is identified by the across-study gradient, so its estimate converges
## on Gamma_B while the estimand is Gamma_W. The bias is then FIXED at
## Gamma_B - Gamma_W and does not depend on the spread, while the variance falls
## as the spread grows. Coverage must therefore collapse as the spread grows,
## in exactly the regime where contraction reports the parameter as best
## identified.
##
## A first version of this reasoning was wrong and is recorded because the error
## is instructive. It modeled confounding as a fixed per-study treatment-effect
## deviation u_s. With two aggregate studies and two unknowns that is absorbed
## exactly, giving bias (u_2 - u_1) / (mu_2 - mu_1), which SHRINKS as the spread
## grows: under that model more spread helps. The systematic-association model
## above is the one that matches what confounding by case mix means, and it is
## the one that predicts the collapse.
##
## Everything is closed form. The posterior is Gaussian, so the posterior mean is
## a known linear function of the data and its sampling distribution is known
## exactly; coverage is a normal probability, not a simulated frequency.
##
##   Rscript R/03-probe-anticorrelation.R
## ---------------------------------------------------------------------------

source("R/00-geometry.R")

e <- function(...) { v <- numeric(4); v[c(...)] <- 1; v }
PBO <- numeric(4)

GAMMA_W <- 0.40      # causal, within-study effect modification
PRIOR_SD <- 1

## The design matrix and the residual precision of every observation, laid out
## once so the truth and the model read the same object.
build <- function(net) {
  S <- max(net$study); K <- K_of(net); p <- S + K + 1 + K
  gh <- gh_rule(32)
  rows <- list(); prec <- numeric(0); which_agd <- logical(0)
  ## Which NET ARM each design row came from. An IPD arm expands to one row per
  ## quadrature node, so a row index is not an arm index, and the first version
  ## of this file indexed the component matrix as though it were.
  arm_id <- integer(0)
  for (i in seq_len(nrow(net))) {
    if (as.logical(net$ipd[i])) {
      ## An IPD arm is n individuals; for a Gaussian likelihood the sufficient
      ## statistics are captured by the quadrature-weighted design, and the
      ## information is what info_identity already computes. For the sampling
      ## distribution we only need arm-level summaries, so the arm is
      ## represented by its quadrature nodes with weights n*w.
      xs <- net$mu[i] + sqrt(2) * net$sd[i] * gh$x
      w  <- gh$w / sqrt(pi)
      for (j in seq_along(xs)) {
        rows[[length(rows) + 1L]] <- design_row(net, i, xs[j], S, K)
        prec <- c(prec, net$n[i] * w[j]); which_agd <- c(which_agd, FALSE)
        arm_id <- c(arm_id, i)
      }
    } else {
      rows[[length(rows) + 1L]] <- design_row(net, i, net$mu[i], S, K)
      prec <- c(prec, net$n[i]); which_agd <- c(which_agd, TRUE)
      arm_id <- c(arm_id, i)
    }
  }
  list(X = do.call(rbind, rows), prec = prec, agd = which_agd, arm = arm_id,
       S = S, K = K, p = p, mu = net$mu, C = C_of(net))
}

## The TRUTH the data are generated from. The model's mean is X %*% theta with a
## single Gamma. The truth differs from it only for the aggregate arms of the
## component that has no individual data: there the modification operating on
## the study's covariate mean is Gamma_B, not Gamma_W.
truth_mean <- function(b, theta, gamma_b, comp) {
  m <- as.vector(b$X %*% theta)
  ## The rows that carry the across-study gradient for `comp`: aggregate rows
  ## whose arm contains that component. Their covariate term uses Gamma_B.
  hit <- b$agd & b$C[b$arm, comp] == 1
  ## `design_row` puts x*c in the interaction block, and for an aggregate row
  ## x is the study mean, so the substitution is (gamma_b - gamma_w) * mu.
  gi <- b$S + b$K + 1 + comp
  m[hit] <- m[hit] + (gamma_b - theta[gi]) * b$X[hit, gi]
  m
}

stat_for <- function(net, gamma_b, comp = 3) {
  b <- build(net)
  P0 <- diag(1 / PRIOR_SD^2, b$p)
  W <- diag(b$prec, nrow(b$X))
  I <- t(b$X) %*% W %*% b$X
  Vpost <- solve(I + P0)
  gi <- b$S + b$K + 1 + comp

  theta <- numeric(b$p)
  theta[b$S + seq_len(b$K)] <- -0.5                     # main effects
  theta[b$S + b$K + 1] <- 0.3                           # prognostic slope
  theta[b$S + b$K + 1 + seq_len(b$K)] <- GAMMA_W        # interactions
  theta[seq_len(b$S)] <- 0                              # study intercepts

  mu_true <- truth_mean(b, theta, gamma_b, comp)
  ## Posterior mean is Vpost X' W y, with prior mean zero. Its sampling
  ## distribution over y ~ N(mu_true, W^{-1}) is Gaussian, exactly.
  A <- Vpost %*% t(b$X) %*% W
  m_exp <- as.vector(A %*% mu_true)[gi]
  ## Var(posterior mean) = A W^{-1} A' with A = Vpost X' W, which simplifies to
  ## Vpost I Vpost. Forming W^{-1} explicitly is what the first version did and
  ## it is singular: the outer Gauss-Hermite weights are order 1e-20, so an IPD
  ## arm's tail nodes carry precision that small and its reciprocal overflows.
  ## The simplification never forms it.
  v_samp <- (Vpost %*% I %*% Vpost)[gi, gi]
  sd_post <- sqrt(Vpost[gi, gi])

  ## Coverage of the equal-tailed 95% credible interval for the causal estimand
  ## Gamma_W, over the sampling distribution of its centre.
  z <- 1.959964
  lo <- (theta[gi] - m_exp - z * sd_post) / sqrt(v_samp)
  hi <- (theta[gi] - m_exp + z * sd_post) / sqrt(v_samp)
  c(contraction = sd_post / PRIOR_SD,
    bias = m_exp - theta[gi],
    post_sd = sd_post,
    coverage = pnorm(hi) - pnorm(lo))
}

stateC <- function(spread, n = 300) make_network(list(
  list(ipd = TRUE,  mu = 0.0, sd = 1, n = 300, arms = list(PBO, e(1))),
  list(ipd = TRUE,  mu = 0.2, sd = 1, n = 300, arms = list(PBO, e(2))),
  list(ipd = FALSE, mu = 0.1 - spread / 2, sd = 1, n = n, arms = list(PBO, e(3))),
  list(ipd = FALSE, mu = 0.1 + spread / 2, sd = 1, n = n, arms = list(PBO, e(3))),
  list(ipd = TRUE,  mu = 0.1, sd = 1, n = 300, arms = list(PBO, e(4)))))

for (gb in c(0.40, 0.55, 0.80)) {
  cat(sprintf("\n=== across-study association Gamma_B = %.2f, causal Gamma_W = %.2f ===\n",
              gb, GAMMA_W))
  cat("  spread   contraction      bias   post SD   coverage\n")
  for (s in c(0.3, 0.6, 1.0, 1.4, 2.0, 3.0)) {
    r <- stat_for(stateC(s), gb)
    cat(sprintf("  %6.1f        %6.4f   %+7.4f    %6.4f     %6.3f\n",
                s, r["contraction"], r["bias"], r["post_sd"], r["coverage"]))
  }
}

cat("\n=== the verdict this probe was written to reach ===\n")
r_lo <- stat_for(stateC(0.3), 0.80); r_hi <- stat_for(stateC(3.0), 0.80)
cat(sprintf("at Gamma_B = 0.80: spread 0.3 gives contraction %.3f and coverage %.3f\n",
            r_lo["contraction"], r_lo["coverage"]))
cat(sprintf("                   spread 3.0 gives contraction %.3f and coverage %.3f\n",
            r_hi["contraction"], r_hi["coverage"]))
inverts <- r_hi["contraction"] < r_lo["contraction"] &&
           r_hi["coverage"] < r_lo["coverage"]
if (inverts) {
  cat("\nCONTRACTION IMPROVES WHILE COVERAGE COLLAPSES. The summary CMP-14 asks\n",
      "for is not merely uninformative about the quality of the evidence; over\n",
      "this knob it moves in the WRONG DIRECTION.\n", sep = "")
} else {
  cat("\nThe two do not move in opposite directions here; the claim must be\n",
      "weakened to non-monotonicity rather than anti-correlation.\n", sep = "")
}

## THE NULL CONTROL, checked rather than assumed. With no discordance the same
## design must stay nominal at every spread, or the collapse above is a property
## of the geometry and not of the confounding.
null_cov <- vapply(c(0.3, 0.6, 1.0, 1.4, 2.0, 3.0),
                   function(s) stat_for(stateC(s), GAMMA_W)["coverage"], 0)
cat(sprintf("\nnull control, Gamma_B = Gamma_W: coverage %.3f to %.3f over the same spreads\n",
            min(null_cov), max(null_cov)))
stopifnot("the null control is not nominal, so the collapse is not caused by discordance"
          = min(null_cov) > 0.94)

saveRDS(list(gamma_w = GAMMA_W, lo = r_lo, hi = r_hi, inverts = inverts,
             null_coverage = null_cov),
        "results/anticorrelation-probe.rds")
cat("\nwritten: results/anticorrelation-probe.rds\n")
