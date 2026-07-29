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
              "results/collision-probe.rds", "results/anticorrelation-probe.rds")
missing <- REQUIRED[!file.exists(REQUIRED)]
if (length(missing))
  stop("the export is missing artifacts the protocol quotes, so the verifier ",
       "would pass by checking fewer things:\n  ",
       paste(missing, collapse = "\n  "))

d <- load_e1()
out <- list()

## --- the registered configuration, straight from R/00-config.R --------------
out$k_comp <- K_COMP; out$target <- TARGET
out$gamma_w <- GAMMA_W
out$states <- STATES
out$spreads <- SPREADS
out$discord <- DISCORD
out$arm_n <- ARM_N
out$prior_sd <- PRIOR_SD
out$synergy <- SYNERGY
out$contract_ok <- CONTRACT_OK
out$eff_ratio_ok <- EFF_RATIO_OK
out$source_ok <- SOURCE_OK
out$cover_bad <- COVER_BAD
out$nominal <- NOMINAL
out$diagnostics <- DIAGNOSTICS
out$e2_link <- E2_LINK; out$e2_states <- E2_STATES
out$e2_n_rep <- E2_N_REP; out$e2_scenarios <- E2_SCENARIOS

## --- the grid, counted from the grid rather than from memory ----------------
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
tight <- d[d$prior_sd == min(PRIOR_SD) & d$n == min(ARM_N) &
             d$discord == 0 & d$synergy == 0 & d$state != "absent", ]
out$control_tight_max_coverage <- as.list(round(tapply(tight$coverage,
                                                       tight$state, max), 3))
out$control_absent_cover_by_prior <- as.list(round(
  tapply(abs_rows$coverage, abs_rows$prior_sd, max), 3))

## --- the groundwork probes the protocol's section 3 rests on ----------------
cp <- readRDS("results/collision-probe.rds")
out$probe_inverts <- cp$inverts
out$probe_best_ecological <- signif(min(cp$C[, 1]), 4)
out$probe_worst_randomized <- signif(max(cp$E[, 1]), 4)
ac <- readRDS("results/anticorrelation-probe.rds")
out$probe_null_cover_min <- round(min(ac$null_coverage), 3)
out$probe_null_cover_max <- round(max(ac$null_coverage), 3)

writeLines(toJSON(out, auto_unbox = TRUE, digits = 8, null = "null"),
           "results/registered-design.json")
cat("written: results/registered-design.json\n")
cat(sprintf("exported %d top-level keys\n", length(out)))
