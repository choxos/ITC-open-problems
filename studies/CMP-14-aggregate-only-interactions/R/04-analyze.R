## ---------------------------------------------------------------------------
## The registered outcomes.
##
## A NOTE ON WHAT THE UNIT OF ANALYSIS IS, because it is unusual and it changes
## what the primary outcome can be.
##
## In a conjugate Gaussian model the posterior covariance is (I + P0)^{-1}, which
## contains no data. Prior-to-posterior contraction and effective likelihood rank
## are therefore functions of the DESIGN alone: two analysts with the same
## network and different datasets get the same value. There is consequently no
## replicate-level variation in these diagnostics to average over, and the unit
## of analysis is the SCENARIO.
##
## That has a consequence for how the primary outcome may be defined. Any
## sensitivity or specificity computed over a grid is a weighted average over
## scenarios someone chose, so it reports the shape of the grid as much as the
## behavior of the diagnostic. The primary outcome is therefore an EXISTENCE
## claim, which no weighting can move:
##
##   if one value of a diagnostic is compatible with both a covered and a badly
##   failing scenario, then no threshold on that diagnostic separates them, and
##   that conclusion holds whatever the grid contains.
##
## Threshold-based sensitivity and specificity are reported too, at the
## registered thresholds, because that is how such a summary would be used. They
## are secondary and are labeled as grid-weighted.
## ---------------------------------------------------------------------------

source("R/00-config.R")

load_e1 <- function(path = "results/e1.rds") {
  if (!file.exists(path)) stop("run R/03-run-e1.R first")
  readRDS(path)
}

## --- PRIMARY 1: can any threshold separate covered from failed? -------------
##
## For each diagnostic, bin scenarios by its value and report, per bin, the range
## of coverage. The claim "no threshold works" is established by a single bin
## containing both a nominal scenario and a failing one. Reported as the
## OVERLAP: the best (lowest-risk) diagnostic value at which some scenario still
## fails, against the worst value at which some scenario is still fine.
##
## THE COMPARISON IS AGAINST NOMINAL SCENARIOS, NOT MERELY NON-FAILING ONES.
## Round 1 found the first version contrasting `failed` with `!failed`, which
## lumps a scenario covering at 0.91 in with one covering at 0.950. An overlap
## established against a 0.91 scenario is not evidence that a threshold cannot
## separate the good from the bad, because 0.91 is not good. Scenarios between
## COVER_BAD and nominal are neither and are excluded from both sides.
overlap_table <- function(d) {
  ## ROUND 3: "nominal" was one-sided, so a scenario covering at 1.000 counted as
  ## nominal and sat on the good side of primary 1. Gross overcoverage is not
  ## nominal; it is a different failure, and the absent state under a wide prior
  ## produces it by having no likelihood information at all. Nominal is now a
  ## two-sided band and the over-covering scenarios join the intermediate ones in
  ## belonging to neither side.
  nominal <- abs(d$coverage - NOMINAL) <= COVER_TOL
  d <- d[d$failed | nominal, ]
  stats <- list(
    contraction  = d$contraction,
    target_ratio = d$target_ratio,
    eff_rank     = d$eff_rank,
    surv_between = ifelse(is.na(d$surv_between), 0, d$surv_between),
    ## Round 4: the estimability screen was among the registered diagnostics and
    ## appeared in no outcome, so the one rule `cpaic` already ships controlled
    ## nothing. It is binary, so "overlaps" means both of its values occur among
    ## failing scenarios and among nominal ones, which is the same existence claim
    ## the continuous statistics are judged by.
    rank_screen = as.numeric(d$estimable))
  ## For each statistic, the direction in which "looks safe" points.
  ## Finding 7 of round 1: the whole-model effective rank was computed and never
  ## analyzed, so one of the two summaries CMP-14 actually asks for was absent
  ## from every reported outcome. It is included here in both forms.
  safe_low <- c(contraction = TRUE, target_ratio = FALSE, eff_rank = FALSE,
                surv_between = FALSE, rank_screen = FALSE)
  do.call(rbind, lapply(names(stats), function(nm) {
    v <- stats[[nm]]; fail <- d$failed
    if (safe_low[[nm]]) {
      ## Lower looks safer. The overlap exists if some FAILING scenario has a
      ## value at or below some NOMINAL scenario's value.
      worst_ok  <- max(v[!fail])          # the least reassuring covered scenario
      best_fail <- min(v[fail])           # the most reassuring failing scenario
      overlaps  <- best_fail <= worst_ok
    } else {
      worst_ok  <- min(v[!fail])
      best_fail <- max(v[fail])
      overlaps  <- best_fail >= worst_ok
    }
    ## ROUND 7: A POST HOC ROW MUST CARRY ITS STANDING IN THE DATA, not only in
    ## the prose. The protocol says every outcome reporting the candidate says so
    ## on the row; the exported schema had no such field, so `surv_between` was
    ## packaged identically to the summaries CMP-14 asks for.
    data.frame(statistic = nm, standing = STANDING[[nm]],
               safe_is_low = safe_low[[nm]],
               n_failed = sum(fail), n_nominal = sum(!fail),
               most_reassuring_failure = best_fail,
               least_reassuring_success = worst_ok,
               overlaps = overlaps,
               ## The share of the COMPARISON SET that falls in the overlapping
               ## region. Round 2 found this called "the fraction of the grid"
               ## while its denominator is the retained scenarios, the failing
               ## ones plus the nominal ones, with the intermediate band already
               ## removed. The two differ and the name now says which it is.
               n_compared = length(v),
               unclassifiable_of_compared = if (!overlaps) 0 else
                 mean(if (safe_low[[nm]]) v >= best_fail & v <= worst_ok
                      else v <= best_fail & v >= worst_ok),
               stringsAsFactors = FALSE)
  }))
}

## --- PRIMARY 2: the two states the component structure creates --------------
##
## The sharpest comparison in the study, and the one CMU-02 could not make:
## a component interaction identified through additivity from randomized
## within-study evidence, against one identified only by the between-study
## gradient. Restricted to scenarios where nothing else differs: no synergy, and
## matched on spread, TOTAL PATIENT BUDGET and prior scale.
##
## THE MATCHING IS ON THE BUDGET, NOT ON ARM SIZE, and it cannot be on both.
## Round 2 pointed out that the two states have twelve and ten arms, so equal
## totals mean per-arm sizes of n/12 and n/10. That is unavoidable: the states
## differ in structure, which is the whole comparison, and structure determines
## how many arms a fixed budget is spread over. Matching per-arm size instead
## would give `additivity` 20% more patients, which is exactly the defect round 1
## found. The budget is the quantity an investigator controls, so it is the one
## held fixed, and the per-arm consequence is stated rather than hidden.
state_pairs <- function(d) {
  key <- function(z) paste(z$spread, z$n, z$prior_sd)
  a <- d[d$state == "additivity" & d$synergy == 0, ]
  c_ <- d[d$state == "ecological", ]
  out <- do.call(rbind, lapply(split(c_, key(c_)), function(g) {
    m <- a[key(a) == key(g)[1], ]
    if (!nrow(m)) return(NULL)
    do.call(rbind, lapply(seq_len(nrow(g)), function(i) data.frame(
      spread = g$spread[i], n = g$n[i], prior_sd = g$prior_sd[i],
      discord = g$discord[i],
      contraction_additivity = m$contraction[1],
      contraction_ecological = g$contraction[i],
      surv_between_additivity = m$surv_between[1],
      surv_between_ecological = ifelse(is.na(g$surv_between[i]), 0,
                                       g$surv_between[i]),
      coverage_additivity = m$coverage[1],
      coverage_ecological = g$coverage[i],
      stringsAsFactors = FALSE)))
  }))
  rownames(out) <- NULL
  out
}

## --- PRIMARY 3: does the summary move against the answer? -------------------
##
## READ THE SIGN CAREFULLY; the obvious reading is backwards. For contraction,
## LOW is the reassuring value: a posterior much narrower than its prior is what
## an analyst takes as evidence the likelihood did the work. So a POSITIVE rank
## correlation between contraction and coverage means that as the diagnostic
## becomes more reassuring the answer gets worse. Positive is the failure.
##
## This is the exact shape of error that has cost this program three fatal
## findings: a real measurement compared against the wrong reference, or its sign
## misread. The column is named for what it means rather than for what it is.
## ROUND 6: THE REGISTERED CORRELATION WAS NEVER COMPUTED. The protocol registers
## ONE rank correlation "within the confounded family"; this function only ever
## reported it separately at each discordance level. Stratified and pooled rank
## correlations can differ in magnitude and in sign, so the registered primary
## output was absent while three stratified ones stood in for it. The pooled
## value is now the primary and the stratified ones are reported beside it, which
## also shows whether the two readings agree.
anticorrelation_pooled <- function(d) {
  g <- d[d$state == "ecological" & d$discord > 0, ]
  rho <- suppressWarnings(cor(g$contraction, g$coverage, method = "spearman"))
  data.frame(n_scenarios = nrow(g), n_discord_levels = length(unique(g$discord)),
             rho_contraction_vs_coverage = rho,
             contraction_inverted = isTRUE(rho > 0),
             stringsAsFactors = FALSE)
}

anticorrelation <- function(d) {
  do.call(rbind, lapply(split(d[d$state == "ecological" & d$discord > 0, ],
                              d$discord[d$state == "ecological" & d$discord > 0]),
    function(g) data.frame(
      discord = g$discord[1], n_scenarios = nrow(g),
      ## Positive = INVERTED, because low contraction is the reassuring value.
      rho_contraction_vs_coverage =
        suppressWarnings(cor(g$contraction, g$coverage, method = "spearman")),
      contraction_inverted =
        isTRUE(suppressWarnings(cor(g$contraction, g$coverage,
                                    method = "spearman")) > 0),
      ## The source-share statistic is CONSTANT at zero across this whole family:
      ## every one of these scenarios draws all its information from the
      ## between-study gradient. A correlation is undefined for a constant, and
      ## reporting NA without saying why would read as a failure to compute. It
      ## is not: a statistic that takes the same alarming value on every member
      ## of a family that is uniformly wrong has classified the family correctly,
      ## and has no variation left to correlate.
      surv_between_is_constant =
        length(unique(ifelse(is.na(g$surv_between), 0, g$surv_between))) == 1,
      surv_between_value = mean(ifelse(is.na(g$surv_between), 0, g$surv_between)),
      stringsAsFactors = FALSE)))
}

## --- SECONDARY: the registered thresholds, as warning rules -----------------
## Grid-weighted and labeled as such.
## ROUND 6: THE DENOMINATOR WAS `!failed`, WHICH IS NOT THE SUCCESS CLASS.
## `failed` is one-sided, coverage < COVER_BAD, while the document calls gross
## overcoverage "a different failure" and primary 1 excludes it from both sides.
## So an over-covering scenario was excluded from primary 1 and simultaneously
## counted as a SUCCESS in the false-alarm denominator here, which made the two
## outcomes use incompatible classes. The three classes are now named once and
## used everywhere: `failed`, `nominal`, and a middle band belonging to neither.
## The false-alarm rate is now conditioned on `nominal`, the same success class
## primary 1 compares against.
classes <- function(d) {
  nominal <- abs(d$coverage - NOMINAL) <= COVER_TOL
  list(failed = d$failed, nominal = nominal,
       neither = !d$failed & !nominal)
}

warning_table <- function(d) {
  cl <- classes(d)
  ## Same standing field as the overlap table, for the same reason.
  std <- function(nm) if (nm %in% names(STANDING)) STANDING[[nm]] else
    STANDING[["source_survival"]]
  cols <- grep("^warn_", names(d), value = TRUE)
  do.call(rbind, lapply(cols, function(cn) {
    w <- d[[cn]]
    data.frame(rule = sub("^warn_", "", cn),
               standing = std(sub("^warn_", "", cn)),
               sensitivity = mean(w[cl$failed]),
               false_alarm = mean(w[cl$nominal]),
               youden = mean(w[cl$failed]) - mean(w[cl$nominal]),
               n_failed = sum(cl$failed), n_nominal = sum(cl$nominal),
               n_neither = sum(cl$neither),
               ## What the old denominator would have given, kept so the change
               ## is visible rather than silent.
               false_alarm_vs_not_failed = mean(w[!cl$failed]),
               stringsAsFactors = FALSE)
  }))
}

main <- function() {
  d <- load_e1()
  cat(sprintf("E1: %d scenarios, %d failing at coverage < %.2f\n\n",
              nrow(d), sum(d$failed), COVER_BAD))

  cat("=== PRIMARY 1: can a threshold separate covered from failed? ===\n")
  print(overlap_table(d), row.names = FALSE, digits = 4)

  cat("\n=== PRIMARY 2: additivity against ecological, matched ===\n")
  sp <- state_pairs(d)
  cat(sprintf("%d matched pairs\n", nrow(sp)))
  ## The decisive rows: where the two states have essentially the same
  ## contraction and different coverage.
  sp$contract_gap <- abs(sp$contraction_additivity - sp$contraction_ecological)
  sp$cover_gap <- sp$coverage_additivity - sp$coverage_ecological
  close <- sp[sp$contract_gap < PAIRS_CLOSE_TOL, ]
  cat(sprintf("pairs whose contraction differs by less than %.2f: %d\n",
              PAIRS_CLOSE_TOL,
              nrow(close)))
  if (nrow(close)) {
    cat(sprintf("  their coverage differs by up to %.3f\n", max(abs(close$cover_gap))))
    print(head(close[order(-abs(close$cover_gap)),
                     c("spread", "n", "prior_sd", "discord",
                       "contraction_additivity", "contraction_ecological",
                       "surv_between_additivity", "surv_between_ecological",
                       "coverage_additivity", "coverage_ecological")], 8),
          row.names = FALSE, digits = 4)
  }

  cat("\n=== PRIMARY 3: does contraction move against coverage? ===\n")
  ## ROUND 7: THE POOLED VALUE IS THE REGISTERED ONE AND ONLY THE EXPORTER HAD
  ## IT. This path printed and saved the stratified correlations alone, so the
  ## designated E1 analysis output did not contain primary 3 and rerunning the
  ## normal analysis would still have produced only the strata. The pooled value
  ## is printed first because it is the registered one.
  cat("pooled over the confounded family, which is the registered primary:\n")
  print(anticorrelation_pooled(d), row.names = FALSE, digits = 4)
  cat("by discordance level, reported beside it so the two readings can be\n",
      "compared rather than assumed to agree:\n", sep = "")
  print(anticorrelation(d), row.names = FALSE, digits = 4)

  cat("\n=== SECONDARY: registered thresholds as warning rules (grid-weighted) ===\n")
  print(warning_table(d), row.names = FALSE, digits = 4)

  saveRDS(list(overlap = overlap_table(d), pairs = sp,
               anti_pooled = anticorrelation_pooled(d),
               anti = anticorrelation(d), warn = warning_table(d),
               pairs_close_tol = PAIRS_CLOSE_TOL),
          "results/e1-analysis.rds")
  cat("\nwritten: results/e1-analysis.rds\n")
}

if (!interactive() && Sys.getenv("ANALYZE_NOMAIN") == "") main()
