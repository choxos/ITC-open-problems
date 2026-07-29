## ---------------------------------------------------------------------------
## Does the geometry actually separate the states CMP-14 names?
##
## The catalog asks for two summaries that discriminate four situations: an
## interaction with strong individual-data information, one with aggregate
## information only, one with weak information, and one with none. Before any
## protocol is written, this checks that they are separable AT ALL from the
## design, on an identity link where everything is exact.
##
## If they are not, there is no study. If they are, the interesting question is
## the fifth state, which the catalog does not name and component methods create:
## an interaction with no arm of its own, identified entirely through additivity.
##
##   Rscript R/01-probe-states.R
## ---------------------------------------------------------------------------

source("R/00-geometry.R")

## Four components. Placebo is the all-zero arm.
e <- function(...) { v <- numeric(4); v[c(...)] <- 1; v }
PBO <- numeric(4)

show <- function(label, net, prior_sd = 1) {
  K <- K_of(net); S <- max(net$study)
  p <- S + K + 1 + K
  P0 <- diag(1 / prior_sd^2, p)
  I_all <- info_identity(net)
  I_ipd <- info_identity(net, ipd_only = TRUE)
  I_agd <- info_identity(net, agd_only = TRUE)
  gi <- gamma_idx(net)
  er <- eff_rank(I_all, P0)
  cat(sprintf("\n=== %s ===\n", label))
  cat(sprintf("  %d studies, %d arms, %d with IPD; parameters %d\n",
              S, nrow(net), sum(net$ipd), p))
  cat(sprintf("  likelihood rank %d of %d; effective rank (data beats prior) %d\n",
              er$rank, p, er$eff_rank))
  ct <- contraction(I_all, P0)[gi]
  ## Per-parameter likelihood information ALONG ITS OWN COORDINATE, split by
  ## source. The conditional precision I[k,k] overstates what is available when
  ## the coordinate is entangled with others, so the marginal version is what is
  ## reported: 1/Var, from the inverse of the full information plus prior.
  marg <- function(I) {
    V <- try(solve(I + P0), silent = TRUE)
    if (inherits(V, "try-error")) return(rep(NA_real_, length(gi)))
    1 / diag(V)[gi] - diag(P0)[gi]
  }
  m_all <- marg(I_all); m_ipd <- marg(I_ipd); m_agd <- marg(I_agd)
  cat("  per-interaction: contraction, then marginal likelihood precision\n")
  cat("    k  contraction   total     from IPD   from AgD\n")
  for (k in seq_len(K))
    cat(sprintf("   %2d      %6.3f  %8.2f   %8.2f   %8.2f\n",
                k, ct[k], m_all[k], m_ipd[k], m_agd[k]))
  invisible(list(contraction = ct, m_all = m_all, m_ipd = m_ipd, m_agd = m_agd,
                 eff = er))
}

## --- state A: strong individual-data information ----------------------------
## Every component appears in an IPD study against placebo, so every Gamma_k is
## identified by within-study covariate variation.
netA <- make_network(list(
  list(ipd = TRUE, mu = 0.0, sd = 1, n = 300, arms = list(PBO, e(1))),
  list(ipd = TRUE, mu = 0.2, sd = 1, n = 300, arms = list(PBO, e(2))),
  list(ipd = TRUE, mu = -0.2, sd = 1, n = 300, arms = list(PBO, e(3))),
  list(ipd = TRUE, mu = 0.1, sd = 1, n = 300, arms = list(PBO, e(4)))))
rA <- show("A: every component has its own IPD trial", netA)

## --- state D: no likelihood information at all ------------------------------
## Component 4 appears in no study. Its Gamma is a prior draw.
netD <- make_network(list(
  list(ipd = TRUE, mu = 0.0, sd = 1, n = 300, arms = list(PBO, e(1))),
  list(ipd = TRUE, mu = 0.2, sd = 1, n = 300, arms = list(PBO, e(2))),
  list(ipd = TRUE, mu = -0.2, sd = 1, n = 300, arms = list(PBO, e(3)))))
netD$c4 <- 0
rD <- show("D: component 4 appears nowhere", netD)

## --- state C: between-study information only --------------------------------
## Component 3 appears only in AGGREGATE studies. On an identity link its
## interaction is identified only by the contrast between studies with different
## covariate means, which is the confounded ecological route.
netC <- make_network(list(
  list(ipd = TRUE,  mu = 0.0, sd = 1, n = 300, arms = list(PBO, e(1))),
  list(ipd = TRUE,  mu = 0.2, sd = 1, n = 300, arms = list(PBO, e(2))),
  list(ipd = FALSE, mu = -0.6, sd = 1, n = 300, arms = list(PBO, e(3))),
  list(ipd = FALSE, mu = 0.8, sd = 1, n = 300, arms = list(PBO, e(3))),
  list(ipd = TRUE,  mu = 0.1, sd = 1, n = 300, arms = list(PBO, e(4)))))
rC <- show("C: component 3 only in aggregate studies, two covariate means", netC)

## The same network with the two aggregate studies at the SAME covariate mean:
## the between-study contrast vanishes and component 3 should collapse toward
## state D even though it has arms and patients.
netC0 <- make_network(list(
  list(ipd = TRUE,  mu = 0.0, sd = 1, n = 300, arms = list(PBO, e(1))),
  list(ipd = TRUE,  mu = 0.2, sd = 1, n = 300, arms = list(PBO, e(2))),
  list(ipd = FALSE, mu = 0.1, sd = 1, n = 300, arms = list(PBO, e(3))),
  list(ipd = FALSE, mu = 0.1, sd = 1, n = 300, arms = list(PBO, e(3))),
  list(ipd = TRUE,  mu = 0.1, sd = 1, n = 300, arms = list(PBO, e(4)))))
rC0 <- show("C0: same, but both aggregate studies at one covariate mean", netC0)

## --- state E: identified ENTIRELY through additivity ------------------------
## The state the catalog does not name and component methods create. Component 3
## never appears alone anywhere. It appears only inside the combination 1+3, in
## an IPD study that also has an arm for 1 alone. The slope difference between
## those two arms is exactly Gamma_3, so the parameter has strong, within-study,
## randomized information; it just has no arm of its own.
netE <- make_network(list(
  list(ipd = TRUE, mu = 0.0, sd = 1, n = 300, arms = list(PBO, e(1), e(1, 3))),
  list(ipd = TRUE, mu = 0.2, sd = 1, n = 300, arms = list(PBO, e(2))),
  list(ipd = TRUE, mu = 0.1, sd = 1, n = 300, arms = list(PBO, e(4)))))
rE <- show("E: component 3 only ever inside the combination 1+3", netE)

cat("\n\n=== what separates, and what does not ===\n")
cat(sprintf("state A, component 3 : contraction %.3f, likelihood precision %.1f\n",
            rA$contraction[3], rA$m_all[3]))
cat(sprintf("state E, component 3 : contraction %.3f, likelihood precision %.1f\n",
            rE$contraction[3], rE$m_all[3]))
cat(sprintf("state C, component 3 : contraction %.3f, likelihood precision %.1f\n",
            rC$contraction[3], rC$m_all[3]))
cat(sprintf("state C0, component 3: contraction %.3f, likelihood precision %.1f\n",
            rC0$contraction[3], rC0$m_all[3]))
cat(sprintf("state D, component 4 : contraction %.3f, likelihood precision %.1f\n",
            rD$contraction[4], rD$m_all[4]))

cat("\nTHE QUESTION THIS DECIDES: if A and E are indistinguishable on both\n")
cat("summaries, then the two diagnostics CMP-14 asks for cannot tell an analyst\n")
cat("whether a component's interaction rests on its own randomized evidence or\n")
cat("entirely on the additivity assumption, and that is the study.\n")

saveRDS(list(A = rA, C = rC, C0 = rC0, D = rD, E = rE),
        "results/state-probe.rds")
cat("\nwritten: results/state-probe.rds\n")
