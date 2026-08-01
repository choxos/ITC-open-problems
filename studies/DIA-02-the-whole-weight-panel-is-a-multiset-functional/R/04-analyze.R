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

## Clustered on the replicate: every diagnostic sees the same replicates, so the
## error of a DIFFERENCE between two diagnostics is paired and much smaller than
## the error of either alone. The bootstrap resamples replicates, not rows.
auroc_se <- function(score, positive, B = 200L) {
  n <- length(score)
  if (sum(positive) == 0 || sum(!positive) == 0) return(NA_real_)
  v <- vapply(seq_len(B), function(b) {
    i <- sample.int(n, n, replace = TRUE)
    auroc(score[i], positive[i])
  }, 0)
  stats::sd(v, na.rm = TRUE)
}

main <- function() {
  d <- read_run()
  cat(sprintf("read %d replicates over %d cells\n", nrow(d),
              length(unique(d$cell_id))))

  ## --- CONTROL 1: the null ---------------------------------------------------
  ## With no hole, material error must be rare. If it is common the threshold sits
  ## below the estimator's own noise and every AUROC below is measuring that noise.
  none <- d[d$hole == "none", ]
  null_rate <- mean(none$material)
  cat(sprintf("\nnull control: material error with no hole = %.4f over %d replicates\n",
              null_rate, nrow(none)))

  ## --- CONTROL 2: the matched multiset, checked at precision ------------------
  ## Section 2 as a measurement. At matched multisets every panel member must agree
  ## between the two hole arms; a difference means the manipulation did not happen.
  cmp <- d[d$hole %in% c("low_modification", "high_modification"), ]
  keys <- c("dim", "overlap", "omitted_moment", "modification")
  panel_names <- names(Filter(function(z) z$family == "panel", DIAGNOSTICS))
  inv <- do.call(rbind, lapply(split(cmp, cmp[keys]), function(z) {
    a <- z[z$hole == "high_modification", ]; b <- z[z$hole == "low_modification", ]
    if (!nrow(a) || !nrow(b)) return(NULL)
    do.call(rbind, lapply(c(panel_names, "ess_region", "hull_gap", "ot_cost"),
      function(s) data.frame(
        statistic = s, family = DIAGNOSTICS[[s]]$family,
        high = mean(a[[s]]), low = mean(b[[s]]),
        rel_diff = abs(mean(a[[s]]) - mean(b[[s]])) /
                   max(abs(mean(b[[s]])), 1e-12),
        stringsAsFactors = FALSE)))
  }))
  if (is.null(inv) || !nrow(inv)) {
    cat("\nmatched-multiset control: no cell pair with both hole arms yet\n")
    inv_s <- NULL; panel_matched <- NA
  } else {
  inv_s <- do.call(rbind, lapply(split(inv, inv$statistic), function(z)
    data.frame(statistic = z$statistic[1], family = z$family[1],
               max_rel_diff = max(z$rel_diff), stringsAsFactors = FALSE)))
  inv_s <- inv_s[order(inv_s$family, inv_s$max_rel_diff), ]
  cat(sprintf("\nmatched-multiset control (tolerance %.2f):\n", PANEL_MATCH_TOL))
  print(inv_s, row.names = FALSE, digits = 3)
  panel_matched <- all(inv_s$max_rel_diff[inv_s$family == "panel"] <=
                       PANEL_MATCH_TOL)
  cat(sprintf("panel matched across support arms: %s\n", panel_matched))
  }

  ## --- CONTROL 3: the positive -----------------------------------------------
  pos <- tapply(d$material, list(d$hole, d$modification), mean)
  cat("\npositive control, P(material error):\n"); print(round(pos, 4))

  ## --- PRIMARY: AUROC in the high-modification arm ---------------------------
  ## Scored where the hole sits in a high-modification region, which is the arm
  ## the decision rule names.
  hi <- d[d$hole == "high_modification", ]
  if (!nrow(hi) || sum(hi$material) == 0) {
    cat("\nPRIMARY: no high-modification replicates with material error yet\n")
    prim <- NULL
  } else {
  prim <- do.call(rbind, lapply(names(DIAGNOSTICS), function(s) {
    sc <- DIAGNOSTICS[[s]]$sign * hi[[s]]
    data.frame(statistic = s, family = DIAGNOSTICS[[s]]$family,
               auroc = auroc(sc, hi$material),
               se = auroc_se(sc, hi$material),
               stringsAsFactors = FALSE)
  }))
  prim <- prim[order(-prim$auroc), ]
  cat("\nPRIMARY: AUROC against material error, high-modification hole\n")
  print(prim, row.names = FALSE, digits = 3)
  }

  ## --- the comparability defect, quantified ----------------------------------
  ## Three ESS definitions on identical data. The complaint is that two analyses
  ## can report incomparable numbers; its size has never been measured.
  sp <- with(d, pmax(ess_def_kish, ess_def_cv, ess_def_entropy) /
                pmax(pmin(ess_def_kish, ess_def_cv, ess_def_entropy), 1e-12))
  cat(sprintf("\nESS-definition spread on identical data: median %.2fx, 90th pct %.2fx, max %.2fx\n",
              stats::median(sp), stats::quantile(sp, 0.9), max(sp)))

  dir.create("results", showWarnings = FALSE)
  saveRDS(list(primary = prim, invariance = inv_s, null_rate = null_rate,
               positive = pos, panel_matched = panel_matched,
               ess_spread = c(median = stats::median(sp),
                              p90 = unname(stats::quantile(sp, 0.9)),
                              max = max(sp))),
          "results/analysis.rds")
  cat("\nwritten: results/analysis.rds\n")
}

if (!interactive() && Sys.getenv("ANALYZE_NOMAIN") == "") main()
