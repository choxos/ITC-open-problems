# THIS IS ROUND FIVE OF PRE-RUN CRITIQUE, PART G OF 7: feasibility, the integration order, and the frozen run

You are reviewing a protocol revised four times. Round one returned `unsound`,
round two `unsound`, round three `unsound`, round four `unsound`. Nothing has
been run except the analytic experiments, the cheap simulation experiment, and
calibration probes. The expensive benchmark has NOT started.

**Round four's most important lesson is what to look for here.** Three of its
findings were defects introduced while fixing round three: a decision rule
declared replaced that was still registered as primary, a results table still
carrying values produced by code that had been deleted for being wrong, and
replicate counts that contradicted between sections. A fourth was a primary
comparison resting on a premise the same document had already withdrawn.

So the highest-value thing you can do is check whether a claimed fix is actually
present, whether any number is inconsistent with another number, and whether any
registered claim rests on a premise stated as retracted elsewhere. Add
`round4_resolution` to your JSON: a list of
{"finding":"short label","resolved":"yes|partly|no","note":"..."}.

Material that is NEW in this version and has never been critiqued:

* E1 and E2 rebuilt on the **anchored indirect** contrast, each leg under its own
  study's baseline hazard and its own censoring regime, with the two regimes
  crossed independently over a 4x4 grid.
* The finding that leg A's least-false coefficient must be computed under the
  **IPD study's** baseline, because population adjustment reweights patients and
  does not transport a baseline hazard.
* The exact computation of MAIC's marginal-graft structural error, and of STC's
  conditional-transport error.
* A machine-checked protocol: 109 assertions comparing this document against the
  code's own exported values, including whole tables cell by cell.
* A budget computed from measured unit costs rather than typed, with the machine
  contention under which it was measured recorded alongside it.

Reply with JSON only.

## 14. Feasibility, measured, and the run frozen

Every number here is measured on this machine, not extrapolated. Round 2 and round 3 both found the
runtime unauditable, and round 3 additionally found that `N_INT` was still `NA` and that section 14
permitted cutting the replicate count without saying to what. Both are closed here: the
configuration is frozen and `R/07-run.R` refuses to start unless it is.

### Measured unit costs

Every figure is wall clock at the stated concurrency, measured on this machine by
`R/11-measure-production.R`, saved to `results/production-timing.rds`, and turned into the budget by
`R/10-budget.R`. **No budget line in this document is typed.** Two of the last two rounds produced a
fatal finding against a hand-written total that did not follow from the unit costs printed beside
it, and the response is to stop writing them by hand rather than to check them more carefully.

| step | measured |
|---|---|
| **one replicate, both ML-NMR arms, 128 points, production config** | **256.9 s** |
| **one replicate, both ML-NMR arms, 256 points, production config** | **442.0 s** |
| ratio, 256 against 128, measured not extrapolated | 1.72 |
| one flexible fit at 256 points, alone | 255.1 s |
| one bootstrap resample, all five frequentist rows, one core | 0.467 s |
| bootstrap speedup on four cores, measured | 2.10x |

Production configuration is 2 chains, 256 integration points, two replicates in flight for the Stan
pass, and one replicate at a time forking over four cores for the frequentist pass. The two passes
are separate (`PASS=freq` and `PASS=mlnmr` in `R/07-run.R`) because two replicates at two chains
each already saturates four performance cores, and a bootstrap running alongside them oversubscribes.

**Every earlier timing this study recorded was inflated, and the cause is worth stating.** An
earlier probe was still running during what was called a production measurement, and it was not
noticed because the check used to confirm a quiet machine grepped for `Rscript` while the process is
named `R`. On a verified-quiet machine a bootstrap resample costs 0.467 s rather than 0.711 s, and a
flexible fit at 256 points costs 255 s rather than 597 s. The measurement script now records the
load average and its own process count alongside every figure.

### The integration order, raised to 256

Measured **paired within replicate**, which matters: orders are separate MCMC runs, and a first
attempt compared them unpaired at an effective sample size where each posterior mean carried a Monte
Carlo standard error of 0.047 against differences of 0.02 to 0.07. Pooled over every paired
replicate the study has paid for:

| contrast | $n$ | mean | SE | $t$ |
|---|---:|---:|---:|---:|
| 128 minus 64 | 4 | $+0.0398$ | 0.0174 | 2.3 |
| 256 minus 64 | 3 | $+0.0656$ | 0.0072 | **9.1** |
| 256 minus 128 | 5 | $+0.0198$ | 0.0129 | 1.5 |

**`multinma`'s default is `n_int = 64L`, and it is measurably inadequate for this estimand.** The
bias is 0.066 months, comparable to the entire bias of the better estimators in the pilot. This is
reported as a result about the package default, and it extends IDN-05's finding in this same
program, which saw 64 to 256 change 8.3% of its DIC verdicts while recording that 256 was not itself
shown to be converged.

**Version 4 registered 128, and that choice rested on a cost figure that was wrong.** It argued that
"256 in production is about 185 hours, so it was never affordable", from the contended 597 s
single-fit timing. Measured at the production configuration on a quiet machine, 256 costs **1.72
times** 128, not the 4.6 the old figure implied: 103.2 hours of Stan against 60.0.

The accuracy argument then decides it. The increments halve with each doubling, $+0.040$ from 64 to
128 and $+0.020$ from 128 to 256, which is what a converging quadrature sequence looks like and
implies roughly 0.02 months still missing at 128. **That is the same size as the entire measured
bias of the flexible estimator rows** ($-0.043$ to $-0.046$ months in the pilot). At 128 this study
could not have distinguished "the flexible methods are nearly unbiased" from "their bias is the size
of my integration error", which is precisely the comparison it exists to make. **256 is registered**,
and a 512-point arm bounds what remains, which is the thing IDN-05 explicitly could not do for its
own reference order.

### The run, frozen

| | |
|---|---|
| distinct parameter cells | 10 |
| cell-by-censoring conditions | 21 |
| replicates per condition | **40** |
| total replicates | **840 replicates** |
| bootstrap resamples | **500 resamples** |
| integration points | **256** |
| Stan pass | 103.2 h |
| frequentist pass | 25.9 h |
| **main run** | **129.2 h**, about 6.2 h per condition |

Version 4 froze this at 14 conditions, 25 replicates and 250 bootstrap resamples per replicate for 24.1 hours, on wall-clock
grounds it stated plainly. That trade was withdrawn on an instruction to prioritize robustness over
schedule, and three of the four increases are justified by measurement rather than by preference:
the replicate count changes the probability that the coverage rule certifies a calibrated estimator
from 0.733 to 0.953 (section 10.3); the integration order removes a bias the size of the effect being
measured; the third censoring condition takes E3's coverage of E1's range from 45% to 87% and makes
it two-sided (`R/00-config.R`). The resample count is the one raised on judgment, because 500 is
where a percentile interval's endpoints stop carrying visible resampling noise and interval coverage
is a registered primary outcome.

**Checkpointing is per replicate, not per cell.** A condition is now about 6 hours, and this machine
has terminated long-running background jobs repeatedly during this design work, including one that
lost three completed integration replicates. `R/07-run.R` writes each replicate as it finishes and
skips completed ones on restart, so the run proceeds as 840 resumable units.

### Sensitivity arms, which round 3 found missing from the budget

Registered and costed at their own unit prices rather than mentioned. Round 4 found version 4's
integration arm costed at another order's prices, understating it 2.6-fold.

| arm | what it varies | cost |
|---|---|---|
| integration | 512 points, bounding what remains at 256 | 10.6 h |
| prior sensitivity | interaction and auxiliary scales halved and doubled | 6.1 h |
| knot complexity | 2 and 5 internal knots | 6.1 h |
| **total** | | **22.9 h** |

Each runs on the same prespecified subset of two primary cells at 50 replicates. The 512-point line
is priced by extrapolating the measured 1.72 ratio one further doubling and is labeled as an
extrapolation; the arm records its own timings when it runs.

### Failure handling

A fit failing the sampler policy is refit once at doubled iterations with `adapt_delta = 0.99`; a
fit failing twice is recorded as a failure, not dropped, and the primary analysis is repeated on the
subset where every fit passed.

**The refit escalation is capped and costed**, which round 4 found it was not. Version 4 described
the contingency and gave it no budget line, which is exactly the unfrozen contingency the freeze
exists to eliminate. The registered cap is **20% of fits**, at doubled iterations, which is
**41.3 hours** at the frozen configuration and is included in the total below. The rate is not
assumed to be 20%: the integration probe returned 45 divergent transitions on one replicate and 0 to
8 on the rest, so the observed rate is reported. If it exceeds the cap, the excess fits are recorded
as failures and the all-passed subset analysis carries them, rather than the budget being revised
mid-run.

### The total

| | |
|---|---|
| main run | 129.2 h |
| sensitivity arms | 22.9 h |
| refit escalation, at its registered cap | 41.3 h |
| **total** | **193.3 h** |

About eight days of compute, stated plainly rather than presented as a headline number with the arms
and contingencies excluded. Round 3 found version 3 quoting a total that omitted arms it had just
registered; that is not repeated. The main run is the part that must complete; the arms and the
refit cap are separately resumable and separately reportable.

# THE BUDGET, COMPUTED RATHER THAN TYPED, VERBATIM

Two of the last two rounds produced a fatal finding against a hand-written total
that did not follow from the unit costs beside it. This file is the response.

```r
## ---------------------------------------------------------------------------
## The runtime budget, COMPUTED from measured unit costs rather than typed.
##
## Budget arithmetic has now produced two separate fatal findings in this
## protocol, and both were the same failure: a total written by hand that did not
## follow from the unit costs printed three lines above it.
##
##   Round 3: the 500-resample bootstrap was called "cheap" without measurement
##            and turned out to dominate the run.
##   Round 4: the frozen bootstrap line said 2.0 h while the protocol's own unit
##            cost implied about 16 h. Measuring showed the unit cost was ALSO
##            wrong (0.711 s, not 0.658 s) and that the 6.4 h figure it replaced
##            implied 62 resamples per replicate rather than 500. Separately, the
##            Stan line claimed 227 s for BOTH arms of a replicate while a single
##            flexible fit at the production integration order measured 296 s.
##
## No amount of care fixes that class of error, and a reviewer catching it twice
## is not a process. So every line of the budget is derived here from timings
## measured on this machine, written to results/production-timing.rds by
## R/11-measure-production.R and to the registered design JSON by
## R/09-export-design.R, and asserted against the protocol by
## review/verify-protocol.py.
##
## Every figure below is WALL CLOCK at the stated concurrency, not core time,
## because wall clock is what the run has to fit into.
## ---------------------------------------------------------------------------

source("R/00-config.R")

## Unit costs. Defaults are the pooled probe measurements (R/probe-pool.R); the
## production replicate cost is read from a direct measurement when one exists,
## and is NOT guessed from the single-fit timings, since round 4 showed that
## guess was off by a factor of two in the optimistic direction.
budget <- function(timing = NULL,
                   n_cells = NULL, n_rep = N_REP, n_boot = N_BOOT) {
  if (is.null(timing) && file.exists("results/production-timing.rds"))
    timing <- readRDS("results/production-timing.rds")
  if (is.null(n_cells)) {
    suppressWarnings(suppressMessages(source("R/04-calibrate.R", local = TRUE)))
    n_cells <- nrow(build_cells())
  }
  need <- c("stan_replicate_secs", "boot_resample_secs", "flex_fit_256_secs")
  miss <- setdiff(need, names(timing))
  if (length(miss))
    stop("unmeasured budget inputs: ", paste(miss, collapse = ", "),
         ". Run R/11-measure-production.R before quoting a runtime.")

  ## THE PRODUCTION UNIT COST MUST MATCH THE REGISTERED INTEGRATION ORDER.
  ## Version 4 registered 128 and this function hardcoded the 128 measurement,
  ## so raising N_INT to 256 would have silently kept quoting the cheaper run.
  ## The cost is selected by N_INT, and an order with no measurement is an
  ## error rather than a fallback.
  per_rep <- switch(as.character(N_INT),
                    "128" = timing$stan_replicate_secs,
                    "256" = timing$stan_replicate_256_secs,
                    NULL)
  if (is.null(per_rep) || is.na(per_rep))
    stop("no measured production cost for N_INT = ", N_INT,
         ". Measure it before quoting a runtime.")

  reps <- n_cells * n_rep
  stan_h <- reps * per_rep / 3600
  ## The frequentist pass forks over N_CORES_BOOT, so wall clock is core time
  ## divided by the measured speedup, which is measured rather than assumed to
  ## be the core count.
  speedup <- if (!is.null(timing$boot_speedup)) timing$boot_speedup else 1
  boot_h <- reps * n_boot * timing$boot_resample_secs / speedup / 3600

  ## Sensitivity arms, each costed at ITS OWN unit price. Round 4 found an arm
  ## costed at another order's prices, which understated it 2.6-fold.
  ##
  ## With 256 registered as production, the integration arm is now 512, which
  ## bounds what is still missing at 256 rather than re-testing a choice already
  ## made. It is priced by extrapolating the MEASURED 256/128 ratio of 1.72 one
  ## further doubling, and that extrapolation is labeled as one: it is a budget
  ## line, not a result, and the arm records its own timings when it runs.
  n_sens <- 50
  ratio <- if (!is.null(timing$ratio_256_128)) timing$ratio_256_128 else 1.72
  arm_512_h <- n_sens * per_rep * ratio / 3600
  arm_prior_h <- n_sens * per_rep / 3600
  arm_knots_h <- n_sens * per_rep / 3600

  ## Refit escalation: a fit failing the sampler policy is refit ONCE at doubled
  ## iterations and adapt_delta 0.99, then recorded either way. Capped so the
  ## contingency has a number instead of a promise. The observed failure rate in
  ## the probe was 3 of 16 fits, so the cap is set above it and the cost of
  ## hitting the cap is stated rather than discovered mid-run.
  refit_rate_cap <- 0.20
  refit_h <- reps * 2 * refit_rate_cap * 2 * per_rep / 2 / 3600

  list(n_cells = n_cells, n_rep = n_rep, n_boot = n_boot, n_replicates = reps,
       stan_h = round(stan_h, 1), boot_h = round(boot_h, 1),
       main_total_h = round(stan_h + boot_h, 1),
       refit_cap_h = round(refit_h, 1),
       arm_512_h = round(arm_512_h, 1),
       arm_prior_h = round(arm_prior_h, 1),
       arm_knots_h = round(arm_knots_h, 1),
       arms_total_h = round(arm_512_h + arm_prior_h + arm_knots_h, 1),
       grand_total_h = round(stan_h + boot_h + refit_h +
                             arm_512_h + arm_prior_h + arm_knots_h, 1),
       per_cell_h = round((stan_h + boot_h) / n_cells, 1),
       ## What the SUPERSEDED order would have cost, kept so the change of
       ## registered order is auditable rather than asserted.
       n_int = as.integer(N_INT),
       alt_128_total_h = round(reps * timing$stan_replicate_secs / 3600 + boot_h, 1),
       ratio_256_128 = timing$ratio_256_128,
       unit = timing)
}

if (!interactive() && Sys.getenv("BUDGET_NOMAIN") == "") {
  b <- budget()
  cat("=== runtime budget, computed from measured unit costs ===\n")
  for (k in setdiff(names(b), "unit"))
    cat(sprintf("  %-16s %s\n", k, format(b[[k]])))
  cat("\n=== unit costs it rests on ===\n")
  for (k in names(b$unit)) cat(sprintf("  %-22s %s\n", k, format(b$unit[[k]])))
  saveRDS(b, "results/budget.rds")
  cat("\nwritten: results/budget.rds\n")
}
```
