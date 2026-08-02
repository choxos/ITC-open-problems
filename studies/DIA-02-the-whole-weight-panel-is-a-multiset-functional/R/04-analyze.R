## ---------------------------------------------------------------------------
## The analysis: every diagnostic scored as a classifier, plus the three controls.
##
##   Rscript R/04-analyze.R
##
## DIRECTION IS DECLARED, NOT FITTED. A diagnostic that predicts error better when
## read upside down is not a diagnostic; it is a coin that happened to land well.
## So each statistic carries the direction a practitioner reads it in, and AUROC is
## computed in that direction. Reading `ess_kish` as "low means trouble" is what
## every report does, so that is how it is scored, and an AUROC below 0.5 for it
## means it is actively misleading rather than merely uninformative.
##
## THE RESTRICTION IS COMPUTED FROM THE CONTROLS, NOT TYPED. Two of the three
## registered controls fail on parts of the grid, for two separate and diagnosable
## reasons (see below). Rather than report a pooled number that averages valid and
## invalid cells together, or hand-pick the cells that survive, this program
## derives the surviving subgrid mechanically from the control outcomes:
##
##   - a dim x overlap stratum is dropped when its NULL control fails there,
##     meaning the estimator's own noise exceeds the material threshold often
##     enough that the label is mostly noise
##   - an omitted_moment level is dropped when the MATCHED-MULTISET control fails
##     there, meaning the manipulation did not produce matched panels and the
##     comparison the study is about did not happen
##
## If the study were rerun with more source records, or with a different balancing
## set, the surviving subgrid would move on its own. Nothing here is a list of
## cells chosen after seeing the primary outcome.
## ---------------------------------------------------------------------------

source("R/00-config.R")

RUN_DIR <- "results/run"

## `sign` is +1 when LARGE values are supposed to indicate trouble, -1 when SMALL
## values are. Every panel member except the concentration measures is read as
## "more is safer", so their sign is -1.
DIAGNOSTICS <- list(
  ## the reported panel: functions of the weight multiset alone
  ess_kish        = list(sign = -1, family = "panel"),
  ess_pct         = list(sign = -1, family = "panel"),
  entropy_eff     = list(sign = -1, family = "panel"),
  max_weight      = list(sign = +1, family = "panel"),
  top_share       = list(sign = +1, family = "panel"),
  ## candidates that read position as well as weight
  balance_omitted = list(sign = +1, family = "geometric"),
  ess_region      = list(sign = -1, family = "geometric"),
  hull_gap        = list(sign = +1, family = "geometric"),
  ot_cost         = list(sign = +1, family = "geometric")
)

PANEL_NAMES <- names(Filter(function(z) z$family == "panel", DIAGNOSTICS))

## How often the estimator may exceed the material threshold with NO support hole
## before the label is judged to be mostly its own noise. Registered in the design
## as the null control; restated here as the number the restriction uses.
NULL_MAX <- 0.02

read_run <- function() {
  fs <- list.files(RUN_DIR, pattern = "^cell-[0-9]+[.]rds$", full.names = TRUE)
  if (!length(fs)) stop("no run output in ", RUN_DIR, "; run Rscript R/03-run.R")
  do.call(rbind, lapply(fs, readRDS))
}

## AUROC by the Mann-Whitney identity, with ties counted at a half. Returns NA
## when one class is empty, which is the honest answer for a cell where nothing
## went wrong: there is no discrimination to measure, not a discrimination of 0.5.
auroc <- function(score, positive) {
  x <- score[positive]; y <- score[!positive]
  if (!length(x) || !length(y)) return(NA_real_)
  r <- rank(c(x, y))
  (sum(r[seq_along(x)]) - length(x) * (length(x) + 1) / 2) /
    (length(x) * length(y))
}

auroc_se <- function(score, positive, B = 400L) {
  n <- length(score)
  if (sum(positive) == 0 || sum(!positive) == 0) return(NA_real_)
  v <- vapply(seq_len(B), function(b) {
    i <- sample.int(n, n, replace = TRUE)
    auroc(score[i], positive[i])
  }, 0)
  stats::sd(v, na.rm = TRUE)
}

## Score every diagnostic on one data frame against one label, in its declared
## direction. Used for both the within-arm primary and the cross-arm test.
score_all <- function(d, label) {
  do.call(rbind, lapply(names(DIAGNOSTICS), function(s) {
    sc <- DIAGNOSTICS[[s]]$sign * d[[s]]
    data.frame(statistic = s, family = DIAGNOSTICS[[s]]$family,
               auroc = auroc(sc, label), se = auroc_se(sc, label),
               stringsAsFactors = FALSE)
  }))
}

## Largest relative difference in each panel member between the two support arms,
## within a set of cells. This is section 8's second null control: at matched
## multisets these are algebraic identities, so a difference means the arms were
## not matched rather than that the algebra failed.
panel_residual <- function(d) {
  cmp <- d[d$hole %in% c("low_modification", "high_modification"), ]
  if (!nrow(cmp)) return(NULL)
  keys <- c("dim", "overlap", "omitted_moment", "modification")
  inv <- do.call(rbind, lapply(split(cmp, cmp[keys]), function(z) {
    a <- z[z$hole == "high_modification", ]; b <- z[z$hole == "low_modification", ]
    if (!nrow(a) || !nrow(b)) return(NULL)
    do.call(rbind, lapply(c(PANEL_NAMES, "ess_region", "hull_gap", "ot_cost"),
      function(s) data.frame(
        statistic = s, family = DIAGNOSTICS[[s]]$family,
        omitted_moment = z$omitted_moment[1],
        rel_diff = abs(mean(a[[s]]) - mean(b[[s]])) /
                   max(abs(mean(b[[s]])), 1e-12),
        stringsAsFactors = FALSE)))
  }))
  if (is.null(inv) || !nrow(inv)) return(NULL)
  r <- do.call(rbind, lapply(split(inv, list(inv$statistic, inv$omitted_moment)),
    function(z) if (!nrow(z)) NULL else
      data.frame(statistic = z$statistic[1], family = z$family[1],
                 omitted_moment = z$omitted_moment[1],
                 max_rel_diff = max(z$rel_diff), stringsAsFactors = FALSE)))
  r[order(r$omitted_moment, r$family, r$max_rel_diff), ]
}

main <- function() {
  d <- read_run()
  cat(sprintf("read %d replicates over %d cells\n", nrow(d),
              length(unique(d$cell_id))))

  ## --- CONTROL 1: the null, per stratum --------------------------------------
  ## With no hole, material error must be rare. Where it is common the threshold
  ## sits below the estimator's own noise and every AUROC there measures noise.
  none <- d[d$hole == "none", ]
  none$stratum <- paste0("dim", none$dim, "/", none$overlap)
  null_by <- tapply(none$material, none$stratum, mean)
  null_rate <- mean(none$material)
  cat(sprintf("\n=== CONTROL 1 (null): pooled %.4f over %d replicates, need <= %.2f\n",
              null_rate, nrow(none), NULL_MAX))
  print(round(null_by, 4))
  ok_strata <- names(null_by)[null_by <= NULL_MAX]
  cat(sprintf("strata passing: %s\n", paste(ok_strata, collapse = ", ")))

  ## --- CONTROL 2: the matched multiset, per balancing set --------------------
  inv_all <- panel_residual(d)
  cat(sprintf("\n=== CONTROL 2 (matched multiset), tolerance %.2f\n", PANEL_MATCH_TOL))
  print(inv_all, row.names = FALSE, digits = 3)
  ok_om <- vapply(LEVELS$omitted_moment, function(om) {
    z <- inv_all[inv_all$omitted_moment == om & inv_all$family == "panel", ]
    nrow(z) > 0 && all(z$max_rel_diff <= PANEL_MATCH_TOL)
  }, TRUE)
  cat(sprintf("balancing sets passing: %s\n",
              paste(LEVELS$omitted_moment[ok_om], collapse = ", ")))

  ## --- CONTROL 3: the positive -----------------------------------------------
  pos <- tapply(d$material, list(d$hole, d$modification), mean)
  cat("\n=== CONTROL 3 (positive): P(material error), full grid\n")
  print(round(pos, 4))

  ## --- the subgrid the controls leave standing -------------------------------
  d$stratum <- paste0("dim", d$dim, "/", d$overlap)
  keep <- d$stratum %in% ok_strata &
          d$omitted_moment %in% LEVELS$omitted_moment[ok_om]
  v <- d[keep, ]
  cat(sprintf("\n=== control-passing subgrid: %d of %d cells, %d replicates\n",
              length(unique(v$cell_id)), length(unique(d$cell_id)), nrow(v)))
  if (!nrow(v)) stop("no cell passes both controls; there is nothing to score")

  ## The manipulation, measured on the surviving cells. Bias is the quantity the
  ## proposition is about: a hole in a prognostic coordinate should cost nothing.
  arm <- do.call(rbind, lapply(split(v, list(v$hole, v$modification)), function(z) {
    if (!nrow(z)) return(NULL)
    data.frame(hole = z$hole[1], modification = z$modification[1], n = nrow(z),
               bias = mean(z$est - z$truth), mae = mean(z$abs_error),
               p_material = mean(z$material),
               mod_share = mean(z$mod_share), stringsAsFactors = FALSE)
  }))
  cat("\n=== the manipulation, on the control-passing subgrid\n")
  print(arm, row.names = FALSE, digits = 3)

  ## --- PRIMARY (registered): within-arm AUROC --------------------------------
  ## Section 7's outcome: in the high-modification arm, does a diagnostic predict
  ## which REPLICATE errs? Within a fixed configuration the error is dominated by
  ## sampling variability, so this asks a variance question, not a location one.
  hi <- v[v$hole == "high_modification", ]
  prim <- NULL
  if (nrow(hi) && sum(hi$material) > 0) {
    prim <- score_all(hi, hi$material)
    prim <- prim[order(-prim$auroc), ]
    cat(sprintf("\n=== PRIMARY (registered): within high-modification arm, %d reps, %d material\n",
                nrow(hi), sum(hi$material)))
    print(prim, row.names = FALSE, digits = 3)
  } else cat("\nPRIMARY: no high-modification replicates with material error\n")

  ## --- CROSS-ARM: section 8's second null control, read as discrimination -----
  ## The two arms remove identical mass at an identical threshold and differ only
  ## in WHICH coordinate carries the hole. One is unbiased, the other is not. Can
  ## a diagnostic tell them apart? This is the proposition stated directly, and it
  ## is the design's own invariance control turned into a number rather than a
  ## pass/fail. It is NOT the registered primary and is reported as distinct.
  ca <- v[v$hole %in% c("low_modification", "high_modification"), ]
  cross <- NULL
  if (nrow(ca)) {
    lab <- ca$hole == "high_modification"
    cross <- do.call(rbind, lapply(names(DIAGNOSTICS), function(s) {
      ## Undirected: the question is whether the arms are separable at all, so a
      ## statistic that runs the other way still counts as seeing the difference.
      a <- auroc(ca[[s]], lab)
      data.frame(statistic = s, family = DIAGNOSTICS[[s]]$family,
                 auroc = a, separation = max(a, 1 - a),
                 se = auroc_se(ca[[s]], lab), stringsAsFactors = FALSE)
    }))
    cross <- cross[order(-cross$separation), ]
    cat(sprintf("\n=== CROSS-ARM: separating the two hole placements, %d reps\n", nrow(ca)))
    print(cross, row.names = FALSE, digits = 3)
  }

  ## --- SENSITIVITY: does the restriction's boundary matter? ------------------
  ## The null control is a hard cut, so a stratum whose rate sits just above it is
  ## excluded on a difference of a few Monte Carlo standard errors. If the answer
  ## moved when such a stratum is added back, the cut would be doing the work
  ## rather than the data. This recomputes the cross-arm reading with every
  ## stratum whose null rate is within twice the threshold, and reports both.
  border <- names(null_by)[null_by > NULL_MAX & null_by <= 2 * NULL_MAX]
  sens <- NULL
  if (length(border) && !is.null(cross)) {
    w <- d[(d$stratum %in% c(ok_strata, border)) &
           d$omitted_moment %in% LEVELS$omitted_moment[ok_om] &
           d$hole %in% c("low_modification", "high_modification"), ]
    lw <- w$hole == "high_modification"
    sens <- do.call(rbind, lapply(names(DIAGNOSTICS), function(s) {
      a <- auroc(w[[s]], lw)
      data.frame(statistic = s, family = DIAGNOSTICS[[s]]$family,
                 separation = max(a, 1 - a), stringsAsFactors = FALSE)
    }))
    cat(sprintf("\n=== SENSITIVITY: adding borderline stratum/strata %s (%d reps)\n",
                paste(border, collapse = ", "), nrow(w)))
    cmpm <- merge(cross[, c("statistic", "family", "separation")],
                  sens[, c("statistic", "separation")], by = "statistic",
                  suffixes = c("_kept", "_plus_borderline"))
    print(cmpm[order(-cmpm$separation_kept), ], row.names = FALSE, digits = 4)
  }

  ## --- the comparability defect, quantified ----------------------------------
  sp <- with(d, pmax(ess_def_kish, ess_def_cv, ess_def_entropy) /
                pmax(pmin(ess_def_kish, ess_def_cv, ess_def_entropy), 1e-12))
  cat(sprintf("\nESS-definition spread on identical data: median %.2fx, 90th pct %.2fx, max %.2fx\n",
              stats::median(sp), stats::quantile(sp, 0.9), max(sp)))

  dir.create("results", showWarnings = FALSE)
  saveRDS(list(primary = prim, cross = cross, arm = arm,
               sensitivity = sens, borderline = border,
               invariance = inv_all, null_rate = null_rate, null_by = null_by,
               ok_strata = ok_strata, ok_om = LEVELS$omitted_moment[ok_om],
               n_cells_all = length(unique(d$cell_id)),
               n_cells_kept = length(unique(v$cell_id)),
               n_rep_kept = nrow(v), positive = pos,
               ess_spread = c(median = stats::median(sp),
                              p90 = unname(stats::quantile(sp, 0.9)),
                              max = max(sp))),
          "results/analysis.rds")
  cat("\nwritten: results/analysis.rds\n")
}

if (!interactive() && Sys.getenv("ANALYZE_NOMAIN") == "") main()
