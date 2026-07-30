## ---------------------------------------------------------------------------
## Export every number the protocol quotes, so review/verify-protocol.py can
## assert the document against the code rather than against my typing.
##
## The previous study in this program published an unsupported number six times,
## and every durable fix removed a place where a human-typed number could enter.
## This file is that discipline applied from the first version rather than the
## fourth.
##
## The artifact list is MANDATORY. Round 6 of the previous study found an export
## whose blocks were all guarded by file.exists, so a missing result silently
## removed both a number and its assertions and the verifier still printed a
## clean pass.
##
##   Rscript R/05-export.R
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(jsonlite))
Sys.setenv(ANALYZE_NOMAIN = "1")
source("R/04-analyze.R")
Sys.setenv(E1_NOMAIN = "1")
source("R/03-run-e1.R")

## ROUND 7: results/e1-analysis.rds WAS OUTSIDE THIS LIST. It is the designated
## E1 analysis output, so it could sit unregenerated while every other artifact
## was fresh, which is exactly the staleness this list exists to stop.
## ROUND 9: routes.rds and the E1 aliasing measurement were quoted by the
## document and read by nothing. The verifier HARDCODED the route table's
## expected entries, so the taxonomy the thesis rests on was asserted against a
## constant rather than against the computation that produces it.
REQUIRED <- c("results/e1.rds", "results/e1-analysis.rds",
              "results/state-probe.rds",
              "results/collision-probe.rds", "results/anticorrelation-probe.rds",
              "results/curvature-rank.rds", "results/e2.rds",
              "results/e2-verdict.rds", "results/contraction-gap.rds",
              "results/routes.rds", "results/e1-aliasing.rds",
              "results/truth-counterfactual.rds")
missing <- REQUIRED[!file.exists(REQUIRED)]
if (length(missing))
  stop("the export is missing artifacts the protocol quotes, so the verifier ",
       "would pass by checking fewer things:\n  ",
       paste(missing, collapse = "\n  "))

## EVERY ARTIFACT MUST BE NEWER THAN THE CODE THAT PRODUCES IT.
##
## Round 5 found E2 reported from a run predating the round-4 arm-count change,
## and the route table likewise. Both read `build_state` through
## `build_state_nl`, both were stale, and nothing noticed: the verifier asserts
## the DOCUMENT against the EXPORT and the smoke test asserts the shape of what
## is there, so neither can see that a saved object was produced by code that has
## since changed. That is a whole class of defect and patching the two instances
## would leave it open.
##
## The check is deliberately blunt. Every artifact must be newer than the newest
## file in R/, because everything here sources R/00-config.R and a finer
## dependency graph would be one more thing to keep correct. Blunt means it
## sometimes demands a rerun that was not strictly needed, which costs seconds in
## this study and is the right trade.
## THIS FILE IS EXCLUDED FROM ITS OWN CHECK. Editing the exporter cannot
## invalidate an artifact, because the exporter consumes artifacts rather than
## producing them; including it meant every edit here demanded a full rerun of
## every experiment, which is not a cost worth paying for a check that would
## never catch anything.
code_files <- setdiff(list.files("R", full.names = TRUE), "R/05-export.R")
newest_code <- max(file.info(code_files)$mtime)
ages <- file.info(REQUIRED)$mtime
stale <- REQUIRED[ages < newest_code]
if (length(stale))
  stop("these artifacts predate the code that produces them, so the export ",
       "would certify results the current code does not produce:\n  ",
       paste(sprintf("%s (%s, code changed %s)", stale,
                     format(ages[ages < newest_code], "%H:%M:%S"),
                     format(newest_code, "%H:%M:%S")), collapse = "\n  "),
       "\nRerun R/03-run-e1.R, R/06-nonlinear.R, R/07-run-e2.R and R/08-routes.R.")

d <- load_e1()
out <- list()

## --- the registered configuration, straight from R/00-config.R --------------
out$k_comp <- K_COMP; out$target <- TARGET
out$gamma_w <- GAMMA_W
out$states <- STATES
out$spreads <- SPREADS
out$discord <- DISCORD
out$total_n <- TOTAL_N
out$prior_sd_nuisance <- PRIOR_SD_NUISANCE
out$prior_sd <- PRIOR_SD
out$synergy <- SYNERGY
out$contract_ok <- CONTRACT_OK
out$pairs_close_tol <- PAIRS_CLOSE_TOL
out$standing <- as.list(STANDING)
out$eff_ratio_ok <- EFF_RATIO_OK
out$source_ok <- SOURCE_OK
out$cover_bad <- COVER_BAD
out$cover_tol <- COVER_TOL
out$nominal <- NOMINAL
out$diagnostics <- DIAGNOSTICS
out$e2_link <- E2_LINK; out$e2_states <- E2_STATES
out$e2_sd_ratio <- E2_SD_RATIO; out$e2_base_p <- E2_BASE_P
## The tolerance the aliasing guard enforces, so the document and the verifier
## compare against the registered constant instead of against a typed literal.
out$e2_alias_tol <- E2_ALIAS_TOL

## THE ADEMP TRUE VALUES. Coverage is a performance measure against a truth, and
## round 6 found the grid registering the DEPARTURES from the truth (discordance,
## synergy) without ever stating the truth itself, so the failing and nominal sets
## could not be reproduced from the document alone.
##
## ROUND 7: THIS BLOCK WAS TYPED AND ONE ENTRY WAS FALSE. It declared
## `gamma_other = 0` for components 1, 2 and 4, while `theta_true()` assigns
## GAMMA_W to ALL FOUR interaction coordinates. So the verifier certified a truth
## the simulation does not use, and recomputing under the declared zeros moves E1
## coverage by up to 0.44 and reclassifies 11 scenarios. The whole vector is now
## READ OFF `theta_true()` on a built design rather than restated here, which is
## the rule this file exists to enforce and which this block had broken.
._b <- build_design(build_state("ecological", SPREADS[1], TOTAL_N[1]))
._th <- theta_true(._b)
out$true_values <- list(
  study_intercept_e1 = unique(._th[seq_len(._b$S)]),
  delta_main = unique(._th[._b$S + seq_len(._b$K)]),
  beta_prog = ._th[._b$S + ._b$K + 1],
  gamma = ._th[._b$S + ._b$K + 1 + seq_len(._b$K)],
  gamma_target = ._th[gi_of(._b)],
  gamma_all_equal = length(unique(._th[._b$S + ._b$K + 1 + seq_len(._b$K)])) == 1L,
  sigma = SIGMA, sigma_known = TRUE,
  e2_study_intercept = round(log(E2_BASE_P / (1 - E2_BASE_P)), 4))
stopifnot("the registered GAMMA_W is not the target's true value"
            = isTRUE(all.equal(out$true_values$gamma_target, GAMMA_W)))

## THE ALIASING MEASUREMENTS, both arms, from the guards that make them.
al <- readRDS("results/e1-aliasing.rds")
out$e1_alias_bias_gap <- signif(al$bias_gap, 3)
out$e1_alias_pointwise_gap <- signif(al$pointwise_gap, 3)
out$e1_alias_n_bias <- al$n_bias
out$e1_alias_n_pointwise <- al$n_pointwise

## THE ROUTE TABLE, read from the run rather than hardcoded in the verifier.
rt <- readRDS("results/routes.rds")$table
out$routes <- lapply(seq_len(nrow(rt)), function(i) as.list(rt[i, ]))

## E2'S OWN GRID, which the document described only as "a reduced factorial".
out$e2_grid <- list(
  states = E2_STATES, spreads = E2_SPREADS, sd_ratio = E2_SD_RATIO,
  discord = E2_DISCORD, total_n = E2_TOTAL_N, prior_sd = E2_PRIOR_SD,
  synergy = E2_SYNERGY,
  restrictions = c(
    "synergy acts only on additivity",
    "discordance acts only on ecological and curvature",
    "the SD ratio acts only on curvature",
    "curvature runs at the first spread only, since it holds means equal"))

## --- the grid, counted from the grid rather than from memory ----------------
ns <- attr(d, "nuisance_sensitivity")
out$nuisance_sensitivity <- if (is.null(ns)) NULL else as.list(round(ns, 4))
## The decision flips are what the inertness claim actually needs; the magnitude
## moves above are supporting detail.
out$nuisance_flips <- as.list(attr(d, "nuisance_flips"))
out$nuisance_n_decisions <- attr(d, "nuisance_n_decisions")
out$nuisance_n_undefined <- attr(d, "nuisance_n_undefined")
out$n_scenarios <- nrow(d)
out$n_failed <- sum(d$failed)
out$n_ok <- sum(!d$failed)

## --- coverage and contraction by state --------------------------------------
out$by_state <- lapply(split(d, d$state), function(z) list(
  state = z$state[1], n = nrow(z),
  cover_min = round(min(z$coverage), 3),
  cover_med = round(median(z$coverage), 3),
  cover_max = round(max(z$coverage), 3),
  contract_min = round(min(z$contraction), 4),
  contract_max = round(max(z$contraction), 4)))

## --- primary outcomes -------------------------------------------------------
ov <- overlap_table(d)
out$overlap <- lapply(seq_len(nrow(ov)), function(i) lapply(ov[i, ], function(z)
  if (is.numeric(z)) signif(z, 4) else z))

sp <- state_pairs(d)
sp$contract_gap <- abs(sp$contraction_additivity - sp$contraction_ecological)
sp$cover_gap <- sp$coverage_additivity - sp$coverage_ecological
close <- sp[sp$contract_gap < PAIRS_CLOSE_TOL, ]
out$pairs_total <- nrow(sp)
out$pairs_close <- nrow(close)
out$pairs_close_max_cover_gap <- round(max(abs(close$cover_gap)), 3)
## ROUND 8: how many "close" pairs actually display identically at two decimals,
## which is what the protocol's justification claimed of all of them.
same_disp <- round(sp$contraction_additivity, 2) ==
             round(sp$contraction_ecological, 2)
disp <- sp[same_disp & sp$contract_gap < PAIRS_CLOSE_TOL, ]
out$pairs_close_same_display <- nrow(disp)
out$pairs_close_same_display_max_cover_gap <-
  if (nrow(disp)) round(max(abs(disp$cover_gap)), 3) else NA_real_
worst <- close[which.max(abs(close$cover_gap)), ]
out$pairs_worst_contractions <- c(round(worst$contraction_additivity, 6),
                                  round(worst$contraction_ecological, 6))
out$pairs_worst_displays_same <-
  round(worst$contraction_additivity, 2) == round(worst$contraction_ecological, 2)

out$pairs_close_surv_between <- list(
  additivity = unique(round(close$surv_between_additivity, 3)),
  ecological = unique(round(close$surv_between_ecological, 3)))

## PRIMARY 3 IS THE POOLED CORRELATION, which round 6 found was registered and
## never computed; only the stratified ones existed. Both are exported so the
## document can say whether the two readings agree rather than assert it.
ap <- anticorrelation_pooled(d)
out$anticorrelation_pooled <- lapply(ap[1, ], function(z)
  if (is.numeric(z)) round(z, 4) else z)

an <- anticorrelation(d)
out$anticorrelation <- lapply(seq_len(nrow(an)), function(i)
  lapply(an[i, ], function(z) if (is.numeric(z)) round(z, 4) else z))
out$anticorrelation_strata_agree <-
  all(an$contraction_inverted == ap$contraction_inverted)

wt <- warning_table(d)
out$warnings <- lapply(seq_len(nrow(wt)), function(i)
  lapply(wt[i, ], function(z) if (is.numeric(z)) round(z, 4) else z))

## --- the four controls, exported as the values that made them pass ----------
## A control that is claimed and not exported is a control nothing checks.
abs_rows <- d[d$state == "absent", ]
out$control_absent_min_contraction <- round(min(abs_rows$contraction), 4)
wide <- d$prior_sd >= 0.5
nullr <- d[d$discord == 0 & d$synergy == 0 & wide & d$state != "absent", ]
out$control_null_min_coverage <- round(min(nullr$coverage), 4)
tight <- d[d$prior_sd == min(PRIOR_SD) & d$n == min(TOTAL_N) &
             d$discord == 0 & d$synergy == 0 & d$state != "absent", ]
out$control_tight_max_coverage <- as.list(round(tapply(tight$coverage,
                                                       tight$state, max), 3))
out$control_absent_cover_by_prior <- as.list(round(
  tapply(abs_rows$coverage, abs_rows$prior_sd, max), 3))

## --- THE CONTROL JUSTIFICATIONS, which are numbers the protocol prints in
## --- prose and which nothing asserted until round 2 found one of them stale.
## The protocol quoted tight-prior recovery as "0.94, 0.84 and 0.80"; recomputed
## after the patient budget was equalized it is 0.938, 0.875 and 0.798, and no
## scenario rounds to 0.84. The figure came from the pre-budget-fix run and
## survived because the provenance claim did not cover control justifications.
tight_big <- d[d$prior_sd == min(PRIOR_SD) & d$n == max(TOTAL_N) &
                 d$discord == 0 & d$synergy == 0 & d$state != "absent", ]
out$control_tight_recovery <- as.list(round(
  tapply(tight_big$coverage, tight_big$state, max), 3))
tight_sm <- d[d$prior_sd == min(PRIOR_SD) & d$n == min(TOTAL_N) &
                d$discord == 0 & d$synergy == 0, ]
out$control_tight_bias <- as.list(round(tapply(tight_sm$bias, tight_sm$state, mean), 3))
over <- nullr[nullr$coverage > NOMINAL + COVER_TOL, ]
out$control_null_n_over <- nrow(over)
out$control_null_over_range <- if (nrow(over)) round(range(over$coverage), 3) else NA
out$control_null_over_states <- unique(over$state)
out$control_null_worst_shrinkage <- if (nrow(over)) c(
  post_sd = round(max(over$post_sd), 3),
  samp_sd = round(over$samp_sd[which.max(over$post_sd)], 3)) else NA

## --- the groundwork probes the protocol's section 3 rests on ----------------
cp <- readRDS("results/collision-probe.rds")
out$probe_inverts <- cp$inverts
out$probe_best_ecological <- signif(min(cp$C[, 1]), 4)
out$probe_worst_randomized <- signif(max(cp$E[, 1]), 4)
ac <- readRDS("results/anticorrelation-probe.rds")
out$probe_null_cover_min <- round(min(ac$null_coverage), 3)
out$probe_null_cover_max <- round(max(ac$null_coverage), 3)

## --- how far the registered contraction sits from a Laplace one -------------
## The protocol used to call E2's contraction a Laplace approximation, which it
## is not, and then say the gap was "bounded by nothing measured here". The label
## is corrected and the bound is now a number rather than a caveat.
cg <- readRDS("results/contraction-gap.rds")
out$contraction_gap <- list(
  n_scenarios = cg$n_scenarios,
  max_abs = round(cg$max_abs, 4),
  median_abs = round(cg$median_abs, 5),
  max_rel_pct = round(100 * cg$max_rel, 2),
  ## Round 8: "effective rank is unaffected" was asserted and is false.
  eff_rank_changed = cg$eff_rank_changed,
  eff_rank_warn_flips = cg$eff_rank_warn_flips)

## --- E2's curvature mechanism, checked rather than asserted -----------------
cr <- readRDS("results/curvature-rank.rds")
out$curvature_rank <- list(
  holds = cr$holds,
  equal_sd_logit_estimable = cr$check[["1"]]$logit_estimable,
  equal_sd_identity_estimable = cr$check[["1"]]$identity_estimable,
  unequal_sd_logit_estimable = cr$check[["2"]]$logit_estimable,
  unequal_sd_identity_estimable = cr$check[["2"]]$identity_estimable,
  ## Round 5: the guard was documented as needing equal baselines and left
  ## testing only the equal-baseline case, so this records both halves.
  equal_sd_needs_equal_baseline = isTRUE(cr$equal_sd_needs_equal_baseline),
  unequal_baseline_equal_sd_estimable =
    isTRUE(cr$check_unequal_baseline[["1"]]$logit_estimable))

## THE STUDY-BY-STUDY MAP, exported because a reviewer could not tell from the
## document whether own-IPD background, aggregate-only target and a fixed
## twelve-arm geometry are jointly satisfiable. They are, and this is how.
am <- cr$arm_map
out$arm_map <- lapply(seq_len(nrow(am)), function(i) as.list(am[i, ]))
out$arm_map_background <- unique(am$arms[am$role == "background"])
out$arm_map_n_background_arms <- sum(am$n_arms[am$role == "background"])
out$arm_map_n_target_arms <-
  sum(am$n_arms[am$role == "target"]) / length(unique(am$state))

## --- E2, run after its rules were committed ---------------------------------
e2 <- readRDS("results/e2.rds"); ev <- readRDS("results/e2-verdict.rds")
out$e2_n_scenarios <- nrow(e2)
out$e2_rules <- lapply(seq_len(nrow(ev$rules)), function(i)
  list(rule = ev$rules$rule[i], standing = ev$rules$standing[i],
       separates = ev$rules$separates[i]))
out$e2_any_state_separation <- ev$any_state_separation
out$e2_surv_sd_curvature <- ev$surv_sd_curvature
out$e2_surv_sd_ecological <- ev$surv_sd_ecological
## The candidate's E2 outputs, each carrying the standing the protocol promises
## every occurrence would carry.
out$e2_candidate_standing <- ev$candidate_standing
## Each candidate measurement is exported as a labeled object rather than as a
## bare number beside a detached standing field, so the standing travels with the
## value wherever it is read.
._cand <- function(x) list(standing = ev$candidate_standing, value = x)
out$e2_curvature_surv <- ._cand(ev$curvature_surv)
out$e2_ecological_surv <- ._cand(ev$ecological_surv)
out$e2_surv_sd_curvature <- ._cand(ev$surv_sd_curvature)
out$e2_surv_sd_ecological <- ._cand(ev$surv_sd_ecological)
out$e2_surv_sd_separates <- ._cand(ev$surv_sd_separates)
out$e2_by_state <- lapply(split(e2, e2$state), function(z) list(
  state = z$state[1], n = nrow(z),
  ## Every exported row carrying a candidate value carries its standing.
  candidate_standing = z$candidate_standing[1],
  cover_min = round(min(z$coverage), 3), cover_max = round(max(z$coverage), 3),
  contract_min = round(min(z$contraction), 4),
  contract_max = round(max(z$contraction), 4),
  surv_between = if (all(is.na(z$surv_between))) NA_real_ else
    unique(round(z$surv_between[!is.na(z$surv_between)], 3))))

## E2_BASE_P is the conditional placebo risk at x = 0, not the arm prevalence.
## On the logit link the arm value integrates the covariate distribution, so it
## varies by state and equals E2_BASE_P nowhere. The document states the range
## and the curvature state's two target values, and both come from here rather
## than being typed, because the finding that produced this block was a number
## stated from memory that the code disagreed with.
## NO E2 SCENARIO IS MISSPECIFIED. Both departures are exactly a shift of the
## target coefficient, so the fitted model reproduces the truth at theta* and
## coverage is defined everywhere. These are the numbers that claim carries: the
## count of aliased scenarios, the shift, and the worst reproduction gap over the
## whole grid, measured pointwise in the covariate.
stopifnot("an E2 scenario has no coverage after the aliasing result"
            = !any(is.na(e2$coverage)))
## PRIMARY 2 ON E2. Round 9: section 8 affirms primary 2 runs on E2 and no result
## line existed for it, while section 7's 0.951 is E1's and E2's grid cannot
## produce E1's 54 pairs. The same rule is applied to E2's own grid.
sp2 <- state_pairs(e2)
if (nrow(sp2)) {
  sp2$contract_gap <- abs(sp2$contraction_additivity - sp2$contraction_ecological)
  sp2$cover_gap <- sp2$coverage_additivity - sp2$coverage_ecological
  cl2 <- sp2[sp2$contract_gap < PAIRS_CLOSE_TOL, ]
  out$e2_pairs_total <- nrow(sp2)
  out$e2_pairs_close <- nrow(cl2)
  ## Signif, not round: the E2 gap is 1.3e-4 and rounding to three decimals
  ## printed it as 0, which round 10 read as "no result" rather than "a result
  ## that is essentially zero". Those are different claims.
  out$e2_pairs_close_max_cover_gap <-
    if (nrow(cl2)) signif(max(abs(cl2$cover_gap)), 4) else NA_real_
  ## ROUND 11: WHETHER THE RETAINED PAIRS CARRY THE MECHANISM. Primary 2 prices a
  ## randomized route against a CONFOUNDED one, and a pair at discordance zero is
  ## the unconfounded null control. E2's single close pair is one of those, so its
  ## gap describes the control rather than the contrast, and the cross-arm
  ## reproduction question cannot be answered from it.
  out$e2_pairs_close_discord <- sort(unique(cl2$discord))
  out$e2_pairs_close_n_confounded <- sum(cl2$discord > 0)
  out$e1_pairs_close_n_confounded <- sum(close$discord > 0)
} else {
  out$e2_pairs_total <- 0L; out$e2_pairs_close <- 0L
  out$e2_pairs_close_max_cover_gap <- NA_real_
}

## PRIMARY 3 ON E2, which the protocol implied was computable there without ever
## giving it an N or a value. E2's confounded family is 8 scenarios against E1's
## 144, so the two are different analyses and the document has to say which
## number belongs to which arm.
ap2 <- anticorrelation_pooled(e2)
out$e2_anticorrelation_pooled <- lapply(ap2[1, ], function(z)
  if (is.numeric(z)) round(z, 4) else z)

## ROUND 8: E1'S ACTUAL CONCLUSION, TESTED ON E2. The registered withdrawal rule
## asks whether the diagnostics separate the information STATES, which is a real
## proposition but is not one of E1's three primaries. E1's conclusion is
## primary 1: no threshold on any summary separates failing coverage from
## nominal. That is now computable on E2, because coverage exists on all 72
## scenarios, so the same overlap test runs on the same statistics.
e2ov <- overlap_table(e2)
out$e2_overlap <- lapply(seq_len(nrow(e2ov)), function(i)
  lapply(e2ov[i, ], function(z) if (is.numeric(z)) signif(z, 4) else z))
out$e2_overlap_all <- all(e2ov$overlaps)

## THE GRID'S SHAPE, PER STATE, so "72" and the 8/12/8 departure split are
## answerable from the export rather than by hand. Round 9's third reviewer
## disputed both and was wrong about both, having halved four of five states and
## applied the SD-ratio factor to a state the restriction removes it from.
## THE SECONDARY OUTCOMES ON E2, which round 10 found were computed for E1 only
## while section 7 presents them in a section covering both arms. The same five
## registered rules, the same three-class denominators.
e2w <- cbind(e2, setNames(warnings_from(e2),
                          paste0("warn_", names(warnings_from(e2)))))
e2wt <- warning_table(e2w)
out$e2_warnings <- lapply(seq_len(nrow(e2wt)), function(i)
  lapply(e2wt[i, ], function(z) if (is.numeric(z)) round(z, 4) else z))

## THE COUNTERFACTUAL that justifies the round-7 truth-table repair, computed by
## R/10-truth-counterfactual.R rather than quoted from a reviewer.
tc <- readRDS("results/truth-counterfactual.rds")
out$truth_cf_max_coverage_change <- round(tc$max_coverage_change, 4)
out$truth_cf_n_reclassified <- tc$n_reclassified
out$truth_cf_n_scenarios <- tc$n_scenarios

out$e2_by_state_n <- as.list(table(e2$state))
out$e2_departure_split <- as.list(table(e2$state[e2$aliased]))

out$e2_n_aliased <- sum(e2$aliased)
out$e2_alias_shifts <- sort(unique(e2$alias_shift[e2$aliased]))
out$e2_alias_gap_max <- signif(max(e2$alias_gap), 3)
out$e2_n_covered <- sum(!is.na(e2$coverage))

out$pbo_prev_min <- round(ev$pbo_prev_min, 4)
out$pbo_prev_max <- round(ev$pbo_prev_max, 4)
out$curv_pbo_prev <- round(ev$curv_pbo_prev, 4)

writeLines(toJSON(out, auto_unbox = TRUE, digits = 8, null = "null"),
           "results/registered-design.json")
cat("written: results/registered-design.json\n")
cat(sprintf("exported %d top-level keys\n", length(out)))
