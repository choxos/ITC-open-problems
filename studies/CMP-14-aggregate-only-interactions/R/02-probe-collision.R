## ---------------------------------------------------------------------------
## Is the collision between states E and C generic, or did I engineer it?
##
## R/01-probe-states.R found that a component interaction identified entirely
## through additivity from RANDOMIZED within-study evidence (state E) and one
## identified entirely by the CONFOUNDED between-study covariate gradient (state
## C) have essentially the same prior-to-posterior contraction, 0.081 against
## 0.082, and the same marginal likelihood precision, 150 against 147.
##
## That is either a real property of the two summaries or a coincidence of the
## arm sizes and covariate means I happened to type. The previous study in this
## program reported an artifact as a settled finding twice, so this is checked
## before anything is written down.
##
## THE CLAIM UNDER TEST is not that the two are always equal, which would be an
## engineered coincidence and is not needed. It is the weaker and more damaging
## statement: the two summaries are not MONOTONE in the causal quality of the
## evidence, so no threshold on either can separate the states. Demonstrated if
## the ecological state can be made to contract MORE than the randomized one by
## moving a quantity that has nothing to do with whether the evidence is
## confounded.
##
##   Rscript R/02-probe-collision.R
## ---------------------------------------------------------------------------

source("R/00-geometry.R")

e <- function(...) { v <- numeric(4); v[c(...)] <- 1; v }
PBO <- numeric(4)

## Component 3's contraction and marginal likelihood precision under each state,
## as a function of one knob per state.
stat3 <- function(net, prior_sd = 1) {
  K <- K_of(net); S <- max(net$study); p <- S + K + 1 + K
  P0 <- diag(1 / prior_sd^2, p)
  I <- info_identity(net)
  V <- solve(I + P0)
  gi <- gamma_idx(net)[3]
  c(contraction = sqrt(V[gi, gi] / (prior_sd^2)),
    precision = 1 / V[gi, gi] - 1 / prior_sd^2)
}

## State E: component 3 rides on additivity inside 1+3, in an IPD study. The
## knob is the arm size of that study, which is what an analyst would vary.
stateE <- function(n) make_network(list(
  list(ipd = TRUE, mu = 0.0, sd = 1, n = n,   arms = list(PBO, e(1), e(1, 3))),
  list(ipd = TRUE, mu = 0.2, sd = 1, n = 300, arms = list(PBO, e(2))),
  list(ipd = TRUE, mu = 0.1, sd = 1, n = 300, arms = list(PBO, e(4)))))

## State C: component 3 appears only in two aggregate studies. The knob is the
## SPREAD between their covariate means, which is the strength of the ecological
## gradient and has nothing whatever to do with whether it is confounded.
stateC <- function(spread, n = 300) make_network(list(
  list(ipd = TRUE,  mu = 0.0, sd = 1, n = 300, arms = list(PBO, e(1))),
  list(ipd = TRUE,  mu = 0.2, sd = 1, n = 300, arms = list(PBO, e(2))),
  list(ipd = FALSE, mu = 0.1 - spread / 2, sd = 1, n = n, arms = list(PBO, e(3))),
  list(ipd = FALSE, mu = 0.1 + spread / 2, sd = 1, n = n, arms = list(PBO, e(3))),
  list(ipd = TRUE,  mu = 0.1, sd = 1, n = 300, arms = list(PBO, e(4)))))

cat("=== state E: randomized, routed through additivity ===\n")
cat("      n   contraction   precision\n")
E <- t(vapply(c(50, 100, 200, 300, 600, 1200), function(n) stat3(stateE(n)), c(0, 0)))
for (i in seq_len(nrow(E)))
  cat(sprintf("  %5d        %6.4f    %8.2f\n",
              c(50, 100, 200, 300, 600, 1200)[i], E[i, 1], E[i, 2]))

cat("\n=== state C: ecological, confounded by construction ===\n")
cat("  spread   contraction   precision\n")
sp <- c(0.1, 0.3, 0.6, 1.0, 1.4, 2.0, 3.0)
C <- t(vapply(sp, function(s) stat3(stateC(s)), c(0, 0)))
for (i in seq_along(sp))
  cat(sprintf("  %6.1f        %6.4f    %8.2f\n", sp[i], C[i, 1], C[i, 2]))

cat("\n=== the overlap ===\n")
cat(sprintf("state E ranges over contraction %.4f to %.4f\n",
            min(E[, 1]), max(E[, 1])))
cat(sprintf("state C ranges over contraction %.4f to %.4f\n",
            min(C[, 1]), max(C[, 1])))
ov <- max(min(E[, 1]), min(C[, 1])) <= min(max(E[, 1]), max(C[, 1]))
cat(sprintf("the ranges %s\n", if (ov) "OVERLAP" else "are disjoint"))

## The decisive comparison: is there a confounded configuration that contracts
## MORE than a randomized one? If so, no threshold works, and it is not a matter
## of picking a better cut point.
best_C <- min(C[, 1]); worst_E <- max(E[, 1])
cat(sprintf("\nbest-contracting ECOLOGICAL state:  %.4f\n", best_C))
cat(sprintf("worst-contracting RANDOMIZED state: %.4f\n", worst_E))
if (best_C < worst_E) {
  cat("\nA CONFOUNDED interaction contracts MORE than a randomized one.\n")
  cat("No threshold on contraction can order these two states, so the summary\n")
  cat("CMP-14 asks for cannot answer the question an analyst has, which is not\n")
  cat("'did the likelihood contribute' but 'should I believe it'.\n")
} else {
  cat("\nThe states do not invert over the ranges examined. The collision in\n")
  cat("R/01 was configuration-specific and the claim must be weakened.\n")
}

saveRDS(list(E = E, C = C, n_grid = c(50, 100, 200, 300, 600, 1200),
             spread_grid = sp, inverts = best_C < worst_E),
        "results/collision-probe.rds")
cat("\nwritten: results/collision-probe.rds\n")
