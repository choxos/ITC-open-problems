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
overlap_table <- function(d) {
  stats <- list(
    contraction  = d$contraction,
    target_ratio = d$target_ratio,
    share_within = ifelse(is.na(d$share_within), 0, d$share_within))
  ## For each statistic, the direction in which "looks safe" points.
  safe_low <- c(contraction = TRUE, target_ratio = FALSE, share_within = FALSE)
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
    data.frame(statistic = nm, safe_is_low = safe_low[[nm]],
               most_reassuring_failure = best_fail,
               least_reassuring_success = worst_ok,
               overlaps = overlaps,
               ## The share of scenarios that fall in the overlapping region,
               ## which is how much of the grid a threshold cannot classify.
               unclassifiable = if (!overlaps) 0 else
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
## matched on spread, arm size and prior scale.
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
      share_within_additivity = m$share_within[1],
      share_within_ecological = ifelse(is.na(g$share_within[i]), 0,
                                       g$share_within[i]),
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
      share_within_is_constant =
        length(unique(ifelse(is.na(g$share_within), 0, g$share_within))) == 1,
      share_within_value = mean(ifelse(is.na(g$share_within), 0, g$share_within)),
      stringsAsFactors = FALSE)))
}

## --- SECONDARY: the registered thresholds, as warning rules -----------------
## Grid-weighted and labeled as such.
warning_table <- function(d) {
  cols <- grep("^warn_", names(d), value = TRUE)
  do.call(rbind, lapply(cols, function(cn) {
    w <- d[[cn]]
    data.frame(rule = sub("^warn_", "", cn),
               sensitivity = mean(w[d$failed]),
               false_alarm = mean(w[!d$failed]),
               youden = mean(w[d$failed]) - mean(w[!d$failed]),
               n_failed = sum(d$failed), n_ok = sum(!d$failed),
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
  close <- sp[sp$contract_gap < 0.02, ]
  cat(sprintf("pairs whose contraction differs by less than 0.02: %d\n",
              nrow(close)))
  if (nrow(close)) {
    cat(sprintf("  their coverage differs by up to %.3f\n", max(abs(close$cover_gap))))
    print(head(close[order(-abs(close$cover_gap)),
                     c("spread", "n", "prior_sd", "discord",
                       "contraction_additivity", "contraction_ecological",
                       "share_within_additivity", "share_within_ecological",
                       "coverage_additivity", "coverage_ecological")], 8),
          row.names = FALSE, digits = 4)
  }

  cat("\n=== PRIMARY 3: does contraction move against coverage? ===\n")
  print(anticorrelation(d), row.names = FALSE, digits = 4)

  cat("\n=== SECONDARY: registered thresholds as warning rules (grid-weighted) ===\n")
  print(warning_table(d), row.names = FALSE, digits = 4)

  saveRDS(list(overlap = overlap_table(d), pairs = sp,
               anti = anticorrelation(d), warn = warning_table(d)),
          "results/e1-analysis.rds")
  cat("\nwritten: results/e1-analysis.rds\n")
}

if (!interactive() && Sys.getenv("ANALYZE_NOMAIN") == "") main()
