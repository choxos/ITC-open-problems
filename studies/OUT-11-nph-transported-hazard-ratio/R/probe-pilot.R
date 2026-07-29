## Pilot rerun after round three. Two changes make the earlier numbers void:
## STC now integrates over the target law with the correct Gauss-Hermite
## weights, and it transports the CONDITIONAL model rather than a marginal
## log-cumulative-hazard graft.
##
## The decision metric changes too. The excess-recommendation-error rule was
## fatally flawed: it subtracted a floor computed from each estimator's own
## variance, so as sigma grows both the raw error and the floor tend to 0.5 and
## an arbitrarily noisy estimator scores zero excess and passes. Efficiency is a
## method property and must not be divided out.
##
## The replacement is EXPECTED DECISION LOSS in RMST months: acting on the
## estimate, the loss is |truth - threshold| when the recommendation is wrong
## and zero when it is right. It retains bias and variance, it is in the units
## of the decision model, and it is compared against two external baselines that
## require no tuning: always-recommend and never-recommend.
Sys.setenv(PROBE_NOMAIN = "1")
source("R/probe-integration.R"); source("R/03-estimators.R")

CELLS <- list(
  list(nm = "control k=0 g=0", kb = 0,    g = 0,   bb = -0.42233, tr = 0.75),
  list(nm = "prim k=0",        kb = 0,    g = 0.3, bb = -0.41398, tr = 0.75),
  list(nm = "prim k=.15",      kb = 0.15, g = 0.3, bb = -0.27062, tr = 0.75),
  list(nm = "prim k=.30",      kb = 0.30, g = 0.3, bb = -0.14306, tr = 0.75),
  list(nm = "marg k=0",        kb = 0,    g = 0.3, bb = -0.32552, tr = 0.35),
  list(nm = "marg k=.30",      kb = 0.30, g = 0.3, bb = -0.05049, tr = 0.35))

NR <- as.integer(Sys.getenv("PILOT_REPS", "60"))
q  <- target_quad(); verify_quad(q)
out <- list()
for (cc in CELLS) {
  R <- do.call(rbind, lapply(seq_len(NR), function(r) {
    d <- sim_network(SEED + 1000 * r, kappa_b = cc$kb, gamma = cc$g, beta_b = cc$bb)
    v <- try(freq_all(d, q = q), silent = TRUE)
    if (inherits(v, "try-error")) return(NULL)
    vapply(v, function(z) z$rmst_diff, 0)
  }))
  cons <- abs(cc$tr - DELTA_THRESHOLD)            # months at stake in this cell
  wrong <- function(e) if (cc$tr > DELTA_THRESHOLD) e <= DELTA_THRESHOLD else e > DELTA_THRESHOLD
  cat(sprintf("\n%-16s truth %.2f  n=%d  at stake %.2f mo\n", cc$nm, cc$tr, nrow(R), cons))
  for (k in colnames(R)) {
    err  <- mean(vapply(R[, k], wrong, logical(1)))
    loss <- err * cons
    fl   <- if (cc$tr > DELTA_THRESHOLD) pnorm((DELTA_THRESHOLD - cc$tr) / sd(R[, k]))
            else 1 - pnorm((DELTA_THRESHOLD - cc$tr) / sd(R[, k]))
    cat(sprintf("  %-10s bias %+.3f  sd %.3f  err %.3f  loss %.4f  (noise floor loss %.4f)\n",
                k, mean(R[, k]) - cc$tr, sd(R[, k]), err, loss, fl * cons))
  }
  ## External baselines, no tuning: always recommend, never recommend.
  cat(sprintf("  %-10s loss %.4f    %-10s loss %.4f\n",
              "ALWAYS-rec", if (cc$tr > DELTA_THRESHOLD) 0 else cons,
              "NEVER-rec",  if (cc$tr > DELTA_THRESHOLD) cons else 0))
  out[[cc$nm]] <- list(est = R, truth = cc$tr, cons = cons)
}
saveRDS(out, "results/freq-pilot-v2.rds")

cat("\n=== deployment-weighted expected decision loss, months ===\n")
nm <- colnames(out[[1]]$est)
tab <- sapply(nm, function(k) mean(sapply(out, function(o) {
  wrong <- if (o$truth > DELTA_THRESHOLD) o$est[, k] <= DELTA_THRESHOLD else o$est[, k] > DELTA_THRESHOLD
  mean(wrong) * o$cons })))
base_always <- mean(sapply(out, function(o) if (o$truth > DELTA_THRESHOLD) 0 else o$cons))
base_never  <- mean(sapply(out, function(o) if (o$truth > DELTA_THRESHOLD) o$cons else 0))
print(round(sort(tab), 4))
cat(sprintf("\nbaselines: always-recommend %.4f   never-recommend %.4f\n", base_always, base_never))
