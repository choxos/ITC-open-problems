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

REQUIRED <- c("results/e1.rds", "results/state-probe.rds",
              "results/collision-probe.rds", "results/anticorrelation-probe.rds",
              "results/curvature-rank.rds", "results/e2.rds",
              "results/e2-verdict.rds")
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
newest_code <- max(file.info(list.files("R", full.names = TRUE))$mtime)
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
out$eff_ratio_ok <- EFF_RATIO_OK
out$source_ok <- SOURCE_OK
out$cover_bad <- COVER_BAD
out$cover_tol <- COVER_TOL
out$nominal <- NOMINAL
out$diagnostics <- DIAGNOSTICS
out$e2_link <- E2_LINK; out$e2_states <- E2_STATES
out$e2_sd_ratio <- E2_SD_RATIO; out$e2_base_p <- E2_BASE_P

## --- the grid, counted from the grid rather than from memory ----------------
ns <- attr(d, "nuisance_sensitivity")
out$nuisance_sensitivity <- if (is.null(ns)) NULL else as.list(round(ns, 4))
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
close <- sp[sp$contract_gap < 0.02, ]
out$pairs_total <- nrow(sp)
out$pairs_close <- nrow(close)
out$pairs_close_max_cover_gap <- round(max(abs(close$cover_gap)), 3)
out$pairs_close_share_within <- list(
  additivity = unique(round(close$share_within_additivity, 3)),
  ecological = unique(round(close$share_within_ecological, 3)))

an <- anticorrelation(d)
out$anticorrelation <- lapply(seq_len(nrow(an)), function(i)
  lapply(an[i, ], function(z) if (is.numeric(z)) round(z, 4) else z))

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

## --- E2's curvature mechanism, checked rather than asserted -----------------
cr <- readRDS("results/curvature-rank.rds")
out$curvature_rank <- list(
  holds = cr$holds,
  equal_sd_logit_estimable = cr$check[["1"]]$logit_estimable,
  equal_sd_identity_estimable = cr$check[["1"]]$identity_estimable,
  unequal_sd_logit_estimable = cr$check[["2"]]$logit_estimable,
  unequal_sd_identity_estimable = cr$check[["2"]]$identity_estimable)

## --- E2, run after its rules were committed ---------------------------------
e2 <- readRDS("results/e2.rds"); ev <- readRDS("results/e2-verdict.rds")
out$e2_n_scenarios <- nrow(e2)
out$e2_rules <- lapply(seq_len(nrow(ev$rules)), function(i)
  list(rule = ev$rules$rule[i], separates = ev$rules$separates[i]))
out$e2_withdraw_e1 <- ev$withdraw_e1
out$e2_share_curv_separates <- ev$share_curv_separates
out$e2_share_curv_curvature <- ev$share_curv_curvature
out$e2_share_curv_ecological <- ev$share_curv_ecological
out$e2_curvature_share <- ev$curvature_share
out$e2_ecological_share <- ev$ecological_share
out$e2_by_state <- lapply(split(e2, e2$state), function(z) list(
  state = z$state[1], n = nrow(z),
  cover_min = round(min(z$coverage), 3), cover_max = round(max(z$coverage), 3),
  contract_min = round(min(z$contraction), 4),
  contract_max = round(max(z$contraction), 4),
  share_within = if (all(is.na(z$share_within))) NA_real_ else
    unique(round(z$share_within[!is.na(z$share_within)], 3))))

writeLines(toJSON(out, auto_unbox = TRUE, digits = 8, null = "null"),
           "results/registered-design.json")
cat("written: results/registered-design.json\n")
cat(sprintf("exported %d top-level keys\n", length(out)))
