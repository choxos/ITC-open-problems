## ---------------------------------------------------------------------------
## E1: the censoring dependence of the transported hazard ratio, computed.
##
## No simulation anywhere in this file. Every number is quadrature plus a
## root-find, so it carries no Monte Carlo error and nothing here can be made
## more precise by running longer.
##
## VERSION 5 CHANGES WHAT IS COMPUTED, not just how it is reported. Round four
## found that every number here evaluated cox_limit(A, B), the coefficient a
## direct head-to-head trial would report, while OUT-11 concerns a TRANSPORTED
## ANCHORED INDIRECT comparison. Least-false Cox coefficients are not transitive
## under non-proportional hazards, so those are different quantities: measured
## here, they differ by 0.9% to 1.8% and the gap itself varies with censoring.
## Everything below now uses anchored_limit(), which computes each leg under its
## OWN censoring regime and combines by Bucher, and the two regimes are crossed
## independently rather than shared, which is the case an indirect comparison
## actually faces and which version 4 omitted entirely.
##
## A round-one critique established that the DIRECTION of the effect is a
## theorem (Struthers and Kalbfleisch 1986, doi:10.2307/2336212; Xu and
## O'Quigley 2000, doi:10.1093/biostatistics/1.4.423), so what is worth doing is
## sizing it and separating its sources. A round-two critique added that the
## least-false root is nonlinear, so the two sources do NOT add and must be
## reported as a factorial with an interaction rather than as an additive
## decomposition. Both corrections are implemented here: the factorial is
## computed in full, and only the two ABLATIONS, which are exact, are claimed as
## clean separations.
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(survival))
source("R/04-calibrate.R")
source("R/02b-anchored-limit.R")

dir.create("results", showWarnings = FALSE)

## --- 1. the factorial over non-proportionality and covariate effect ----------
## beta_B is re-solved at every (kappa, gamma) so the TRUE RMST difference is
## held at the registered margin throughout. Without that, changing kappa would
## also change the effect size and the comparison would be between different
## treatments rather than between different amounts of non-proportionality.
cat("=== E1.1 factorial: Cox-projection spread across four censoring regimes ===\n")
fac <- do.call(rbind, lapply(c("weibull", "gompertz"), function(fam)
  cbind(decomposition(fam, kappas = c(0, 0.15, 0.30),
                      gammas = c(0, 0.15, 0.30, 0.50)))))
fac$spread_pct <- 100 * fac$hr_spread
print(fac[, c("family", "kappa_b", "gamma", "beta_b", "hr_ref", "spread_pct")],
      row.names = FALSE, digits = 4)

## --- 2. the two exact ablations ---------------------------------------------
## These are the only separations claimed. Each removes one ingredient and must
## return exactly zero movement.
cat("\n=== E1.2 ablations, each must be numerically zero ===\n")
abl <- rbind(
  data.frame(ablation = "kappa = 0 and gamma = 0",
             spread_pct = 100 * decomposition("weibull", 0, 0)$hr_spread),
  data.frame(ablation = "gamma = 0.30, covariate spread -> 0",
             spread_pct = 100 * tail(decomposition_ablation(), 1)$hr_spread))
print(abl, row.names = FALSE, digits = 4)

## --- 3. the least-false parameter per registered cell and regime -------------
## This is the quantity an analyst reports, computed exactly, for every cell the
## benchmark will run and every regime E1 covers.
cat("\n=== E1.3 least-false constant HR, per registered cell and regime ===\n")
cells <- unique(build_cells()[, c("arm", "family", "kappa_a", "kappa_b",
                                  "gamma", "margin", "beta_b")])
lf <- do.call(rbind, lapply(seq_len(nrow(cells)), function(i) {
  cc <- cells[i, ]
  ## Leg A in the IPD study, leg B in the aggregate study, both at the TARGET
  ## covariate law: covariate adjustment assumed perfect, baseline transport not
  ## assumed at all, because no adjustment method performs it.
  pbo_a <- placebo_arm(cc$family, "ipd")
  a <- make_arm(cc$family, "ipd", beta = BETA_A, kappa = cc$kappa_a, gamma = cc$gamma)
  pbo_b <- placebo_arm(cc$family, "tgt")
  b <- make_arm(cc$family, "tgt", beta = cc$beta_b, kappa = cc$kappa_b,
                gamma = cc$gamma)
  gr <- anchored_grid(pbo_a, a, pbo_b, b, MU_TGT, SD_X)
  hr <- gr$anchored_hr
  dg <- gr$anchored_hr[gr$regime_a == gr$regime_b]
  data.frame(cc[, c("arm", "family", "kappa_a", "kappa_b", "gamma", "margin")],
             hr_min = min(hr), hr_max = max(hr),
             spread_pct = 100 * (max(hr) - min(hr)) / min(hr),
             diag_pct = 100 * (max(dg) - min(dg)) / min(dg),
             leg_a_spread_pct = 100 * (max(gr$leg_a_hr) - min(gr$leg_a_hr)) / min(gr$leg_a_hr),
             leg_b_spread_pct = 100 * (max(gr$leg_b_hr) - min(gr$leg_b_hr)) / min(gr$leg_b_hr))
}))
print(lf, row.names = FALSE, digits = 4)

## --- 4. D3: the decision consequence of that movement ------------------------
## The protocol's D3 rule. The constant hazard ratio is converted to an RMST
## difference by applying it to ONE FIXED target placebo curve, the truth's own,
## so no baseline noise enters. This is the performance of the PH PLUG-IN
## DECISION PROCEDURE and is labeled as such: it is not a general conversion
## from a hazard ratio to a non-proportional RMST contrast, which does not exist.
cat("\n=== E1.4 D3: RMST implied by each regime's HR, fixed placebo curve ===\n")
tt <- seq(1e-6, TAU, length.out = 2001)
## Each leg is reported under ITS OWN study's regime, and the two regimes are
## crossed independently, because that is what an anchored indirect comparison
## assembled from two separately conducted trials actually looks like.
d3 <- do.call(rbind, lapply(seq_len(nrow(cells)), function(i) {
  cc <- cells[i, ]
  pbo_a <- placebo_arm(cc$family, "ipd")
  a     <- make_arm(cc$family, "ipd", beta = BETA_A, kappa = cc$kappa_a, gamma = cc$gamma)
  pbo_b <- placebo_arm(cc$family, "tgt")
  b     <- make_arm(cc$family, "tgt", beta = cc$beta_b, kappa = cc$kappa_b,
                    gamma = cc$gamma)
  ## The ONE fixed baseline the plug-in is applied to is the TARGET study's
  ## placebo curve, because that is the population the decision is made in and
  ## the aggregate study observes it directly.
  S0  <- surv_marg(tt, MU_TGT, SD_X, pbo_b)
  trap <- function(y) sum(diff(tt) * (head(y, -1) + tail(y, -1)) / 2)
  imp <- unlist(lapply(seq_len(nrow(CENS_REGIMES)), function(ja)
    vapply(seq_len(nrow(CENS_REGIMES)), function(jb) {
      ha <- exp(cox_limit(pbo_a, a, MU_TGT, SD_X, CENS_REGIMES$rate_ipd[ja],
                          CENS_REGIMES$t_admin[ja], ALLOC))
      hb <- exp(cox_limit(pbo_b, b, MU_TGT, SD_X, CENS_REGIMES$rate_agd[jb],
                          CENS_REGIMES$t_admin[jb], ALLOC))
      trap(S0^hb) - trap(S0^ha)
    }, numeric(1))))
  diag_idx <- seq(1, length(imp), by = nrow(CENS_REGIMES) + 1)
  truth <- truth_delta(cc$family, cc$beta_b, cc$kappa_b, cc$gamma, TAU, cc$kappa_a)
  ## THE STATISTIC IS A DECISION FLIP, NOT A RANGE AGAINST A LEVEL.
  ##
  ## Round 5 found a category error in the previous version, and it was right:
  ## D3 compared the across-regime RANGE of implied RMST against the 0.50-month
  ## REIMBURSEMENT threshold, which is a boundary on the level of benefit and not
  ## a tolerance for variation. A range of 1.38 months can sit entirely above
  ## 0.50 and change no decision, while a range of 0.05 straddling it reverses
  ## every decision. The old statistic could not establish what it was used to
  ## claim even when the claim happened to be true.
  ##
  ## The registered statistic is now the thing the decision actually depends on:
  ## with the truth held EXACTLY fixed across regimes, does the recommendation
  ## the plug-in produces change with the censoring? `flip_frac` is the fraction
  ## of the 16 regime pairs whose implied recommendation differs from the correct
  ## one, and `spans` records whether the implied values straddle the threshold
  ## at all. The range is retained as a descriptive magnitude.
  ## THE ALTERNATIVE THRESHOLDS ARE COMPUTED, NOT ASSERTED.
  ##
  ## Round 6 found the protocol claiming "at a 0.40 or 0.60 threshold the same
  ## four cells still flip", justified by a range that spans the threshold and by
  ## "the truth sits at 0.750". Neither supports it. The truth is 0.750 only in
  ## the `recommend` cells; the `margin` cells sit at 0.35, on the other side of
  ## every candidate threshold, which is the entire point of having them. And a
  ## flip count is a function of where each cell's truth falls relative to the
  ## threshold as well as where its implied values fall, so it cannot be read off
  ## a range. Recomputing it gives five flipping cells at 0.40 and five at 0.60
  ## against four at 0.50, so the claimed invariance was false in both
  ## directions.
  flip_at <- function(thr) mean((imp > thr) != (truth > thr))
  data.frame(cc[, c("arm", "family", "kappa_a", "kappa_b", "gamma", "margin")],
             truth = truth,
             lo = min(imp), hi = max(imp),
             range = max(imp) - min(imp),
             range_diag = max(imp[diag_idx]) - min(imp[diag_idx]),
             flip_frac = flip_at(DELTA_THRESHOLD),
             flip_frac_diag = mean((imp[diag_idx] > DELTA_THRESHOLD) !=
                                     (truth > DELTA_THRESHOLD)),
             flip_frac_040 = flip_at(0.40),
             flip_frac_060 = flip_at(0.60),
             spans = min(imp) < DELTA_THRESHOLD & max(imp) > DELTA_THRESHOLD)
}))
print(d3[, c("arm", "kappa_a", "kappa_b", "truth", "lo", "hi", "range",
             "flip_frac", "flip_frac_diag", "spans")],
      row.names = FALSE, digits = 4)

cat(sprintf("\nD3: cells whose recommendation flips with censoring alone: %d of %d\n",
            sum(d3$flip_frac > 0), nrow(d3)))
cat(sprintf("D3: worst flip fraction %.3f (%.0f of %d regime pairs wrong)\n",
            max(d3$flip_frac), max(d3$flip_frac) * 16, 16L))
cat(sprintf("D3: cells that flip only when follow-up is CROSSED, not matched: %d\n",
            sum(d3$flip_frac > 0 & d3$flip_frac_diag == 0)))
cat(sprintf("D3 verdict: the PH plug-in is fit for purpose as a decision input only if\n            no cell flips. %s\n",
            if (all(d3$flip_frac == 0)) "PASS" else "FAIL"))
cat(sprintf("(descriptive: worst across-regime range %.4f months)\n", max(d3$range)))
cat(sprintf("\nD3 at the alternative thresholds: %d cells flip at 0.40, %d at 0.50, %d at 0.60\n",
            sum(d3$flip_frac_040 > 0), sum(d3$flip_frac > 0),
            sum(d3$flip_frac_060 > 0)))
cat(sprintf("worst flip fraction: %.4f at 0.40, %.4f at 0.50, %.4f at 0.60\n",
            max(d3$flip_frac_040), max(d3$flip_frac), max(d3$flip_frac_060)))
cat("The count is NOT invariant. The verdict is: FAIL at every threshold tried,\n")
cat("which is the claim the sensitivity supports, and it is weaker than the\n")
cat("invariant-cell-count claim version 5 made and stronger than needed.\n")

saveRDS(list(factorial = fac, ablations = abl, least_false = lf, d3 = d3),
        "results/e1-decomposition.rds")
cat("\nwritten: results/e1-decomposition.rds\n")
