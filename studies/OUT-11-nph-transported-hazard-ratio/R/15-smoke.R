## ---------------------------------------------------------------------------
## Run the WHOLE E3 pipeline once, tiny, before spending 129 hours on it.
##
## Round 5 found that the registered refit escalation could not have executed,
## because the two fitting functions hardcoded the settings it was supposed to
## vary. Reading the same code again found that the registered tail-ESS
## criterion had never been evaluated either: `ess_tail` was filled with the
## bulk value, so the pass rule tested one statistic twice. Both defects sat in
## code that had been reviewed five times and never run end to end.
##
## The pattern is that a registered PROCEDURE fails in a way no amount of
## reading reliably catches, because reading checks whether the code says the
## right thing and running checks whether it does it. So this file runs both
## passes and the analysis on one cell at one replicate, at settings small
## enough to finish in minutes, and asserts the things that must be true of the
## output rather than printing it for inspection.
##
## IT IS NOT A CALIBRATION AND PRODUCES NO REPORTABLE NUMBER. Sample sizes,
## integration order and iteration count are all far below the registered ones,
## so every estimate it produces is meaningless. The only claims it makes are
## structural: that each stage runs, that each field the analysis reads is
## populated, and that the diagnostics the sampler policy binds on are real,
## distinct, finite numbers.
##
##   Rscript R/15-smoke.R
## ---------------------------------------------------------------------------

Sys.setenv(RUN_NOMAIN = "1")
source("R/07-run.R")

SMOKE_DIR <- "results/smoke-cells"
unlink(SMOKE_DIR, recursive = TRUE)
dir.create(SMOKE_DIR, recursive = TRUE, showWarnings = FALSE)

## Shrink everything. These override the locked constants for this process only;
## the run itself sources R/00-config.R fresh.
N_IPD_ARM <- 60L; N_AGD_ARM <- 50L
N_INT     <- 16L
N_ITER    <- 400L
## At least 20, because `mcse_endpoints` refuses to put a standard error on a
## percentile of fewer than 20 values and would return NA, which would make this
## file assert that the registered endpoint error is absent.
N_BOOT    <- 24L
N_CORES_BOOT <- 2L

## One cell, chosen as the hardest one the design contains: both arms
## non-proportional, so the flexible fit has the most to do and the proportional
## fit is the most misspecified. If the pipeline survives this it survives the
## easy cells.
cells <- build_cells(); cells$cell_id <- seq_len(nrow(cells))
hard  <- cells[cells$family == "weibull" & cells$kappa_a > 0 & cells$kappa_b > 0, ]
cell  <- if (nrow(hard)) hard[1, ] else cells[1, ]
cat(sprintf("smoke cell %d: family %s kappa_a %.2f kappa_b %.2f gamma %.2f cens %s\n",
            cell$cell_id, cell$family, cell$kappa_a, cell$kappa_b, cell$gamma,
            cell$cens))

fails <- character(); n_checks <- 0L
ok <- function(label, cond, detail = "") {
  n_checks <<- n_checks + 1L
  if (isTRUE(cond)) cat(sprintf("  PASS  %s\n", label))
  else { cat(sprintf("  FAIL  %s%s\n", label, if (nzchar(detail)) paste0(": ", detail) else ""))
         fails <<- c(fails, label) }
  flush.console()
}

## --- stage 1: the frequentist pass ------------------------------------------
cat("\n=== pass 1: five frequentist rows ===\n")
t0 <- Sys.time()
fq <- try(freq_replicate(cell, 1L), silent = TRUE)
cat(sprintf("elapsed %.1f s\n", as.numeric(difftime(Sys.time(), t0, units = "secs"))))
ok("frequentist replicate returns", !inherits(fq, "try-error"),
   if (inherits(fq, "try-error")) conditionMessage(attr(fq, "condition")) else "")
ok("frequentist replicate is not an error stub", !is.null(fq$freq))
if (!is.null(fq$freq)) {
  fr <- fq$freq; ests <- names(fr$est)
  cat(sprintf("  rows returned: %s\n", paste(ests, collapse = ", ")))
  cat(sprintf("  bootstrap resamples usable: %d of %d\n", fr$n_ok, N_BOOT))
  ok("five frequentist rows present", length(ests) == 5,
     sprintf("%d rows", length(ests)))
  ok("every frequentist row has a finite estimate", all(is.finite(fr$est)),
     paste(ests[!is.finite(fr$est)], collapse = ", "))
  ord <- is.finite(fr$lo) & is.finite(fr$hi) & fr$lo < fr$hi
  ok("every frequentist row has an ordered interval", all(ord),
     paste(ests[!ord], collapse = ", "))
  ## A bootstrap that silently discards most resamples still returns an
  ## interval, and that interval is not the registered one.
  ok("bootstrap kept nearly every resample", fr$n_ok >= 0.9 * N_BOOT,
     sprintf("%d of %d", fr$n_ok, N_BOOT))
  ## Round 6 found the registered inner Monte Carlo error unreconstructible:
  ## `freq_boot` discarded the resample draws it is the only source of. Asserted
  ## for every estimator and every quantity, because "the field exists" was true
  ## of `ess_tail` too while it held a copy of the bulk value.
  ok("endpoint Monte Carlo errors are returned",
     !is.null(fr$mcse_lo) && !is.null(fr$mcse_hi))
  if (!is.null(fr$mcse_lo)) {
    ok("endpoint errors cover every estimator and quantity",
       identical(dim(fr$mcse_lo), c(length(ests), length(fr$qty))),
       sprintf("%s against %d x %d", paste(dim(fr$mcse_lo), collapse = "x"),
               length(ests), length(fr$qty)))
    ok("endpoint errors are finite and positive",
       all(is.finite(fr$mcse_lo)) && all(fr$mcse_lo > 0) &&
       all(is.finite(fr$mcse_hi)) && all(fr$mcse_hi > 0))
    ok("the two endpoints carry distinct errors",
       !identical(as.numeric(fr$mcse_lo), as.numeric(fr$mcse_hi)))
  }
  ## Registered in section 7.2, recorded by nothing until round 6.
  ok("every frequentist row records its degrees of freedom",
     !is.null(fr$edf) && length(fr$edf) == 5 && all(is.finite(fr$edf)),
     paste(fr$edf, collapse = ", "))
  ok("the flexible rows have more degrees of freedom than the proportional",
     !is.null(fr$edf) && fr$edf[["MAIC-flex"]] > fr$edf[["MAIC-PH"]] &&
       fr$edf[["STC-flex"]] > fr$edf[["STC-PH"]],
     paste(sprintf("%s=%g", names(fr$edf), fr$edf), collapse = " "))
}
saveRDS(fq, file.path(SMOKE_DIR, "freq-01-rep-001.rds"))

## --- stage 2: the ML-NMR pass -----------------------------------------------
cat("\n=== pass 2: two ML-NMR rows ===\n")
t0 <- Sys.time()
ml <- try(mlnmr_replicate(cell, 1L), silent = TRUE)
cat(sprintf("elapsed %.1f s\n", as.numeric(difftime(Sys.time(), t0, units = "secs"))))
ok("ML-NMR replicate returns", !inherits(ml, "try-error"),
   if (inherits(ml, "try-error")) conditionMessage(attr(ml, "condition")) else "")

if (!inherits(ml, "try-error")) for (arm in c("mlnmr_ph", "mlnmr_flex")) {
  z <- ml[[arm]]
  cat(sprintf("  %s: ok=%s refit=%s\n", arm, isTRUE(z$ok), isTRUE(z$refit)))
  ok(sprintf("%s fitted", arm), isTRUE(z$ok), if (!isTRUE(z$ok)) z$err else "")
  if (isTRUE(z$ok)) {
    d <- z$diag
    cat(sprintf("    rhat %.4f  ess_bulk %.0f  ess_tail %.0f  mcse %.4f  div %d  td %d\n",
                d$rhat, d$ess_bulk, d$ess_tail, d$mcse, d$divergent, d$treedepth))
    ok(sprintf("%s estimate finite", arm), is.finite(z$est))
    ok(sprintf("%s interval ordered", arm),
       is.finite(z$lo) && is.finite(z$hi) && z$lo < z$hi)
    ## THE POINT OF THIS FILE. ess_tail was a copy of ess_bulk for the whole of
    ## versions 1 to 5, which made the registered tail criterion a no-op. Two
    ## independent Monte Carlo statistics on the same chains are essentially
    ## never bit-identical, so equality here means the copy is back.
    ok(sprintf("%s tail ESS is a distinct statistic", arm),
       is.finite(d$ess_tail) && !identical(d$ess_tail, d$ess_bulk),
       sprintf("bulk %.6f tail %.6f", d$ess_bulk, d$ess_tail))
    ok(sprintf("%s all five pass criteria are finite", arm),
       all(is.finite(c(d$rhat, d$ess_bulk, d$ess_tail, d$divergent, d$treedepth))))
    ok(sprintf("%s global ESS recorded", arm), is.finite(d$glob_ess))
    ## Registered in section 7.2 and recorded by nothing until round 6. p_WAIC
    ## is a sum of per-observation posterior variances, so a positive finite
    ## value is the only shape that means the log-likelihood was actually read.
    ok(sprintf("%s effective degrees of freedom recorded", arm),
       is.finite(d$edf) && d$edf > 0, sprintf("edf = %s", format(d$edf)))
  }
}
saveRDS(ml, file.path(SMOKE_DIR, "mlnmr-01-rep-001.rds"))

## --- stage 3: a second replicate, so every paired statistic is defined -------
## One replicate makes every within-replicate paired contrast a single number
## with no standard deviation, which would let the analysis pass by being
## degenerate rather than by working. Two is the smallest count at which the
## paired contrasts, the Monte Carlo errors and the coverage tables all compute
## on real inputs.
cat("\n=== stage 3: a second replicate ===\n")
for (r in 2L) {
  f2 <- try(freq_replicate(cell, r), silent = TRUE)
  m2 <- try(mlnmr_replicate(cell, r), silent = TRUE)
  ok(sprintf("replicate %d frequentist pass", r), !inherits(f2, "try-error"))
  ok(sprintf("replicate %d ML-NMR pass", r), !inherits(m2, "try-error"))
  saveRDS(f2, file.path(SMOKE_DIR, sprintf("freq-01-rep-%03d.rds", r)))
  saveRDS(m2, file.path(SMOKE_DIR, sprintf("mlnmr-01-rep-%03d.rds", r)))
}

## --- stage 3b: the sensitivity pass ------------------------------------------
## Round 6 found the three registered sensitivity arms unable to run at all: no
## cells named, no driver, and the knot count and prior scales hardcoded inside
## the fitting functions. Reading found that; only running proves it is fixed.
##
## Every REGISTERED SETTING is exercised, one replicate each, with the
## integration order overridden down to smoke scale. The point is not the values,
## which are meaningless at these sizes, but that each setting reaches the
## fitting functions and comes back different from the production setting.
cat("\n=== stage 3b: the sensitivity arms ===\n")
sc <- try(sens_cells(cells), silent = TRUE)
ok("the registered sensitivity subset resolves", !inherits(sc, "try-error"),
   if (inherits(sc, "try-error")) conditionMessage(attr(sc, "condition")) else "")
if (!inherits(sc, "try-error")) {
  cat(sprintf("  subset: %s\n", paste(sprintf("cell %d (kb=%.2f)", sc$cell_id,
                                              sc$kappa_b), collapse = ", ")))
  ok("the subset is the registered size", nrow(sc) == nrow(SENS_CELLS))
  scell <- sc[1, ]
  seen <- list()
  for (i in seq_len(nrow(SENS_SETTINGS))) {
    s <- SENS_SETTINGS[i, ]
    s$n_int <- if (s$n_int > N_INT) 2L * N_INT else N_INT   # smoke scale
    ## The knot arm's bootstrap is the expensive half and is exercised on one
    ## setting only; the other knot setting still runs its Stan half.
    if (isTRUE(s$freq) && length(Filter(function(z) isTRUE(z$freq_ran), seen)))
      s$freq <- FALSE
    t0 <- Sys.time()
    z <- try(sens_replicate(scell, 1L, s), silent = TRUE)
    el <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
    ok(sprintf("setting %s runs", s$setting), !inherits(z, "try-error"),
       if (inherits(z, "try-error")) conditionMessage(attr(z, "condition")) else "")
    if (inherits(z, "try-error")) next
    cat(sprintf("  %-15s n_int=%3d knots=%d prior=%.1f  %5.1f s  est=%s\n",
                s$setting, s$n_int, s$n_knots, s$prior_mult, el,
                format(z$mlnmr_flex$est, digits = 4)))
    ok(sprintf("setting %s fits both ML-NMR arms", s$setting),
       isTRUE(z$mlnmr_ph$ok) && isTRUE(z$mlnmr_flex$ok))
    ## THE SETTING REACHED THE FIT. A driver that silently ignored its argument
    ## would pass every check above; this one it cannot.
    ok(sprintf("setting %s reaches the fitting functions", s$setting),
       isTRUE(z$mlnmr_flex$ok) &&
         identical(z$mlnmr_flex$diag$n_knots, s$n_knots) &&
         identical(z$mlnmr_flex$diag$prior_mult, s$prior_mult),
       sprintf("fit recorded knots=%s prior=%s",
               format(z$mlnmr_flex$diag$n_knots),
               format(z$mlnmr_flex$diag$prior_mult)))
    if (isTRUE(s$freq)) {
      ok(sprintf("setting %s reruns the frequentist rows", s$setting),
         !is.null(z$freq) && identical(z$freq$n_knots, s$n_knots),
         if (is.null(z$freq)) "no bootstrap returned"
         else sprintf("bootstrap ran at k=%s", format(z$freq$n_knots)))
      ## The four spline rows only. MAIC-Cox fits a Cox model with one
      ## coefficient and has no knots to vary, so requiring it to move would be
      ## asserting something false.
      rp <- c("MAIC-PH", "MAIC-flex", "STC-PH", "STC-flex")
      ok(sprintf("setting %s changes the Royston-Parmar degrees of freedom",
                 s$setting),
         !is.null(z$freq) && all(z$freq$edf[rp] != fq$freq$edf[rp]),
         if (is.null(z$freq)) "no bootstrap returned"
         else paste(sprintf("%s %g vs %g", rp, z$freq$edf[rp], fq$freq$edf[rp]),
                    collapse = "  "))
    }
    seen[[s$setting]] <- list(est = z$mlnmr_flex$est, freq_ran = isTRUE(s$freq))
    saveRDS(z, file.path(SMOKE_DIR, sprintf("sens-%s-01-rep-001.rds", s$setting)))
  }
  ## Two settings that differ must not produce bit-identical answers. That is the
  ## check a driver ignoring its arguments actually fails.
  ests <- vapply(seen, function(z) z$est, 0)
  ok("distinct settings give distinct answers",
     length(unique(ests)) == length(ests),
     paste(sprintf("%s=%.6f", names(ests), ests), collapse = "  "))
}

## --- stage 4: the analysis reads what the run wrote --------------------------
## A field the run never populates would surface here as an all-NA column rather
## than an error, so the join is checked column by column, and every registered
## table is then computed rather than only the loader.
cat("\n=== stage 4: the analysis layer ===\n")
Sys.setenv(ANALYZE_NOMAIN = "1")
src <- readLines("R/08-analyze.R")
eval(parse(text = paste(src, collapse = "\n")), envir = environment())
d <- try(load_cells(SMOKE_DIR), silent = TRUE)
ok("analysis loads the run output", !inherits(d, "try-error"),
   if (inherits(d, "try-error")) conditionMessage(attr(d, "condition")) else "")
if (!inherits(d, "try-error")) {
  cat(sprintf("  loaded %d rows, %d estimators: %s\n", nrow(d),
              length(unique(d$estimator)), paste(unique(d$estimator), collapse = ", ")))
  ok("all seven estimators reach the analysis", length(unique(d$estimator)) == 7,
     sprintf("%d found", length(unique(d$estimator))))
  allna <- names(d)[vapply(d, function(z) all(is.na(z)), logical(1))]
  ok("no analysis column is entirely missing", length(allna) == 0,
     paste(allna, collapse = ", "))

  ## Every registered output table, computed. A table that errors on a
  ## degenerate input is a table that will error at 03:00 in hour ninety of the
  ## run, and the run is checkpointed but the analysis is not.
  ## Registered primary outcome 4, which nothing produced until round 6. The
  ## smoke test asserts it exists for every estimator at every registered time,
  ## since "the code runs" was true of the old version too.
  cal <- try(load_calibration(SMOKE_DIR), silent = TRUE)
  ok("calibration data load", !inherits(cal, "try-error") && !is.null(cal),
     if (inherits(cal, "try-error")) conditionMessage(attr(cal, "condition")) else "")
  if (!inherits(cal, "try-error") && !is.null(cal)) {
    ct <- try(calibration_table(cal), silent = TRUE)
    ok("calibration table computes", !inherits(ct, "try-error"),
       if (inherits(ct, "try-error")) conditionMessage(attr(ct, "condition")) else "")
    if (!inherits(ct, "try-error")) {
      cat(sprintf("    calibration: %d estimator-time rows, times %s\n",
                  nrow(ct), paste(sort(unique(ct$t)), collapse = ", ")))
      ok("all seven estimators have survival differences",
         length(unique(ct$estimator)) == 7,
         paste(setdiff(ROWS, unique(ct$estimator)), collapse = ", "))
      ok("every registered time is present",
         setequal(unique(ct$t), T_GRID),
         paste(setdiff(T_GRID, unique(ct$t)), collapse = ", "))
      ok("calibration estimates are finite", all(is.finite(ct$bias)))
      ok("calibration coverage is a probability",
         all(ct$coverage >= 0 & ct$coverage <= 1))
    }
  }
  ## The registered common Cox projection, which round 6 found applied to
  ## nothing. Asserted for all seven rows because the registration says every
  ## method's fitted curves go through the same functional.
  cx <- try(load_cox(SMOKE_DIR), silent = TRUE)
  ok("Cox projection data load", !inherits(cx, "try-error") && !is.null(cx),
     if (inherits(cx, "try-error")) conditionMessage(attr(cx, "condition")) else "")
  if (!inherits(cx, "try-error") && !is.null(cx)) {
    ctab <- try(cox_table(cx), silent = TRUE)
    ok("Cox projection table computes", !inherits(ctab, "try-error"))
    if (!inherits(ctab, "try-error")) {
      fin <- ctab$estimator[is.finite(ctab$mean_log_hr)]
      cat(sprintf("    cox projection: %s\n",
                  paste(sprintf("%s %+.3f", ctab$estimator, ctab$mean_log_hr),
                        collapse = "  ")))
      ok("all seven estimators have a Cox projection",
         setequal(fin, ROWS), paste(setdiff(ROWS, fin), collapse = ", "))
    }
  }
  for (nm in c("bias_table", "coverage_table", "registered_contrasts",
               "decision_appendix")) {
    z <- try(get(nm)(d), silent = TRUE)
    ok(sprintf("%s computes", nm), !inherits(z, "try-error"),
       if (inherits(z, "try-error")) conditionMessage(attr(z, "condition")) else "")
    if (!inherits(z, "try-error") && is.data.frame(z))
      cat(sprintf("    %s: %d rows x %d cols\n", nm, nrow(z), ncol(z)))
  }
}

## --- stage 5: THE PRODUCTION ANALYSIS, END TO END ----------------------------
## Stage 4 calls the table functions individually, which is how round 6 found two
## registered outcomes that had a working table function and no caller: the smoke
## test was exercising the parts while production omitted the whole. This stage
## runs `main()` itself, so a table nothing calls is a table that does not appear
## in the output, and the output is what gets asserted.
cat("\n=== stage 5: the production analysis, end to end ===\n")
out <- try(capture.output(main(SMOKE_DIR)), silent = TRUE)
ok("the production analysis runs end to end", !inherits(out, "try-error"),
   if (inherits(out, "try-error")) conditionMessage(attr(out, "condition")) else "")
if (!inherits(out, "try-error")) {
  txt <- paste(out, collapse = "\n")
  ## Every registered section must be PRESENT IN THE OUTPUT, which is a stronger
  ## claim than "its function exists".
  for (sec in c("primary 1: bias and RMSE",
                "primary 2: coverage, all 21 conditions",
                "primary 2, restricted",
                "PRIMARY 1: the catalog entry's question",
                "PRIMARY 2: flexible vs proportional",
                "primary 4: calibration over time",
                "registered common Cox projection",
                "effective degrees of freedom per estimator",
                "inner Monte Carlo error of the bootstrap interval endpoints",
                "secondary: decision loss",
                "sampler failures and refit escalation",
                "every primary outcome repeated on the all-passed subset"))
    ok(sprintf("production output contains: %s", sec), grepl(sec, txt, fixed = TRUE))
  ## The all-passed subset must repeat every outcome, not just bias. Round 6
  ## found it rerunning `bias_table` alone.
  tail_txt <- substring(txt, regexpr("all-passed subset", txt))
  for (sub in c("primary 1: bias and RMSE", "primary 2: coverage",
                "primary 4: calibration over time", "common Cox projection",
                "secondary: decision loss"))
    ok(sprintf("all-passed subset repeats: %s", sub),
       grepl(sub, tail_txt, fixed = TRUE))
  writeLines(out, file.path(SMOKE_DIR, "analysis-output.txt"))
  cat(sprintf("  full analysis output written to %s\n",
              file.path(SMOKE_DIR, "analysis-output.txt")))
}

## --- stage 6: A PARTIAL RUN, WHICH IS A NORMAL STATE AND WAS UNTESTED --------
##
## The run is checkpointed per replicate and resumable, so "one pass finished and
## the other still going" is what the output looks like for most of the run's
## life, and `load_cells` promises in its own comment that such a run is
## analyzable. It was not. Every earlier stage of this file populated BOTH passes,
## so the production analysis was never once exercised on the shape its own
## design guarantees, and on real partial output it died with "arguments imply
## differing number of rows: 0, 1": `paired_contrast` returns NULL when one of
## its estimators has no finite estimate anywhere, and `transform(NULL, ...)`
## fails.
##
## This stage runs the analysis with the ML-NMR checkpoints hidden.
cat("\n=== stage 6: the analysis on a partial run, ML-NMR pass absent ===\n")
PART_DIR <- file.path(SMOKE_DIR, "partial")
dir.create(PART_DIR, showWarnings = FALSE)
file.copy(list.files(SMOKE_DIR, "^freq-.*\\.rds$", full.names = TRUE), PART_DIR,
          overwrite = TRUE)
pout <- try(capture.output(main(PART_DIR)), silent = TRUE)
ok("the analysis survives a missing pass", !inherits(pout, "try-error"),
   if (inherits(pout, "try-error")) conditionMessage(attr(pout, "condition")) else "")
if (!inherits(pout, "try-error")) {
  ptxt <- paste(pout, collapse = "\n")
  ok("it says the run is partial", grepl("PARTIAL run", ptxt, fixed = TRUE))
  ok("it notes which estimators are not there yet",
     grepl("partial run; outcome 4 has no rows yet", ptxt, fixed = TRUE))
  for (sec in c("primary 1: bias and RMSE", "primary 2: coverage, all 21 conditions",
                "PRIMARY 1: the catalog entry's question",
                "primary 4: calibration over time",
                "every primary outcome repeated on the all-passed subset"))
    ok(sprintf("partial run still emits: %s", sec),
       grepl(sec, ptxt, fixed = TRUE))
}

cat(sprintf("\n%s\n", strrep("-", 70)))
if (length(fails)) {
  cat(sprintf("SMOKE TEST FAILED: %d of %d checks\n", length(fails), n_checks))
  for (f in fails) cat("  ", f, "\n")
  quit(status = 1)
}
cat(sprintf("SMOKE TEST PASSED: %d checks. Every stage runs and every field the\n",
            n_checks))
cat("analysis reads is\n")
cat("populated. This says nothing about whether any number is correct.\n")
