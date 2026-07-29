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
  ## 50 replicates TOTAL across the two-cell subset, 25 per cell. Round 5 found
  ## the protocol prose reading as 100 against this 50; the prose is corrected.
  n_sens <- N_SENS
  ## No typed fallback. Round 5 pointed out that a hardcoded `else 1.72` in a file
  ## whose stated purpose is that no number is typed is exactly the thing the
  ## file exists to prevent, and every other input here hard-stops when
  ## unmeasured. This one does too.
  if (is.null(timing$ratio_256_128) || is.na(timing$ratio_256_128))
    stop("the 256/128 cost ratio is unmeasured; the 512-point arm cannot be ",
         "priced. Run R/11-measure-production.R.")

  ## THE ARMS ARE PRICED PER FIT SET, FROM THE TABLE THAT RUNS THEM.
  ##
  ## Round 6 found this file pricing one 50-replicate fit set for "halved and
  ## doubled" priors and one for "2 and 5" knots, when each of those is plainly
  ## two settings and therefore two fit sets. That understated the sensitivity
  ## program by more than twelve hours, and no amount of care in reading the
  ## prose would have caught it, because the prose and the arithmetic were in
  ## different files with nothing connecting them.
  ##
  ## SENS_SETTINGS is now that connection: one row per fit set, iterated by
  ## R/07-run.R and multiplied here. The count cannot diverge between what runs
  ## and what is priced, because there is only one count.
  ##
  ## The frequentist column is new for the same reason. The protocol registers
  ## the complexity arm "for both bases", so the knot settings rerun the
  ## Royston-Parmar rows and their bootstrap; that half had no budget line at
  ## all.
  boot_per_rep <- n_boot * timing$boot_resample_secs / speedup
  sens_unit <- function(s) {
    stan <- per_rep * switch(s$cost, prod = 1, int512 = timing$ratio_256_128,
                             stop("unpriced sensitivity cost class: ", s$cost))
    stan + if (isTRUE(s$freq)) boot_per_rep else 0
  }
  ## Rounded PER SETTING, then summed, for the reason given at `r` below: the
  ## per-setting costs are what the protocol prints, so the arm subtotals and the
  ## grand total have to be sums of those printed values. Rounding at the end
  ## instead puts 6.1 + 6.1 = 12.3 in a registered table.
  sens <- SENS_SETTINGS
  sens$hours <- round(vapply(seq_len(nrow(sens)),
                             function(i) n_sens * sens_unit(sens[i, ]) / 3600, 0), 1)
  arm_h <- tapply(sens$hours, sens$arm, sum)
  arm_512_h   <- unname(arm_h["integration"])
  arm_prior_h <- unname(arm_h["prior"])
  arm_knots_h <- unname(arm_h["knots"])

  ## Refit escalation: a fit failing the sampler policy is refit ONCE at doubled
  ## iterations and adapt_delta 0.99, then recorded either way. Capped so the
  ## contingency has a number instead of a promise. The observed failure rate in
  ## the probe was 3 of 16 fits, so the cap is set above it and the cost of
  ## hitting the cap is stated rather than discovered mid-run.
  refit_rate_cap <- 0.20
  refit_h <- reps * 2 * refit_rate_cap * 2 * per_rep / 2 / 3600

  ## EVERY TOTAL IS A SUM OF THE ROUNDED COMPONENTS, NOT A ROUNDED SUM.
  ##
  ## Round 6 found the printed arms table showing 10.6 + 6.1 + 6.1 against a
  ## total of 22.9. Both numbers were right in their own terms, which is the
  ## problem: the components were rounded for printing and the total was rounded
  ## from the unrounded sum. A reader checking a registered budget by adding up
  ## its own column is doing exactly the thing that has caught two fatal errors
  ## in this protocol, and a table that does not add up punishes them for it.
  ## The tenth of an hour lost to rounding is worth less than the column
  ## reconciling.
  r <- function(x) round(x, 1)
  stan_r <- r(stan_h); boot_r <- r(boot_h); refit_r <- r(refit_h)
  ## Already rounded per setting above, so these are sums of printed values.
  a512_r <- arm_512_h; aprior_r <- arm_prior_h; aknots_r <- arm_knots_h
  arms_r <- sum(sens$hours)
  main_r <- stan_r + boot_r

  list(n_cells = n_cells, n_rep = n_rep, n_boot = n_boot, n_replicates = reps,
       stan_h = stan_r, boot_h = boot_r,
       main_total_h = main_r,
       refit_cap_h = refit_r,
       arm_512_h = a512_r,
       arm_prior_h = aprior_r,
       arm_knots_h = aknots_r,
       arms_total_h = arms_r,
       n_sens = n_sens, n_sens_settings = nrow(sens),
       ## The per-setting costs travel WITH the settings they price, so a
       ## reordering of one cannot silently misalign the other.
       sens_table = transform(sens, hours = r(hours)),
       grand_total_h = main_r + refit_r + arms_r,
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
