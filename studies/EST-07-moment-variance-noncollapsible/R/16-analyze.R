## ---------------------------------------------------------------------------
## The analysis: ADEMP performance measures, and the registered comparisons.
##
##   Rscript R/16-analyze.R
##
## WHY THE MONTE CARLO ERROR IS CLUSTERED. Every method in a cell is computed
## from ONE replicate by `estimate_all()`, so their coverage indicators are
## dependent within a replicate. The MCSE of a single coverage is the usual
## sqrt(c(1-c)/n), but the MCSE of a DIFFERENCE between two methods is not
## sqrt(c1(1-c1)/n + c2(1-c2)/n): that formula assumes independence and would
## overstate the error of a paired contrast, sometimes by a lot, because the two
## methods cover the same replicates most of the time. The paired SE is computed
## from the per-replicate difference of indicators, which is what common random
## numbers bought and what makes the comparison sharp.
##
## The same argument applies across `corr_assumed`, which `CRN_BLOCKS` also
## blocks: cells differing only in that factor share replicate data, so their
## contrast is paired too and is computed by matching on the replicate index.
##
## WHAT IS REPORTED, in ADEMP terms (Morris, White and Crowther 2019):
##   bias        mean(est - truth), with its MCSE
##   coverage    of the nominal interval, with its MCSE
##   width       mean interval width, the cost side of coverage
##   convergence the fraction of replicates that produced an interval at all
## ---------------------------------------------------------------------------

source("R/05-estimators.R")

RUN_DIR <- "results/run"

read_run <- function() {
  fs <- list.files(RUN_DIR, pattern = "^cell-[0-9]+[.]rds$", full.names = TRUE)
  if (!length(fs)) stop("no run output in ", RUN_DIR, "; run Rscript R/15-run.R")
  ## No join: R/15 writes the cell's factors onto every row, so the flat table is
  ## already complete. `cell_id` is checked against the registered grid so a
  ## stale run directory cannot be analyzed as if it were the current design.
  d <- do.call(rbind, lapply(fs, readRDS))
  g <- load_probes()$P2_grid[[1]]
  extra <- setdiff(unique(d$cell_id), g$cell_id)
  if (length(extra))
    stop("the run directory holds cells that are not in the registered grid: ",
         paste(extra, collapse = ", "),
         "\nthe grid changed since the run; rerun or clear ", RUN_DIR)
  d
}

## --- per method, per cell -----------------------------------------------------
##
## `maic_perturb` reports no standard error by construction, so any summary that
## averages `se` must exclude it rather than silently drop it to NA. Width is
## defined for every method and is what the comparison uses.
performance <- function(d) {
  do.call(rbind, lapply(split(d, list(d$cell_id, d$method), drop = TRUE),
                        function(z) {
    ## CONVERGENCE IS AGAINST THE REGISTERED REPLICATE COUNT, not against the rows
    ## that happen to be present. A replicate whose method failed produces NO ROW
    ## at all, so counting `nrow(z)` as the denominator makes a method that failed
    ## half the time look like one that converged always. Round 3 of critique
    ## found exactly that.
    n <- N_REP
    ok <- is.finite(z$width)
    nc <- sum(ok)
    cov <- mean(z$covered[ok])
    bias <- mean(z$error[ok])
    data.frame(cell_id = z$cell_id[1], method = z$method[1],
               ## Carried through so the decision can separate the powered grid
               ## from the ladder, which was retained below the floor and would
               ## dilute any pooled statement about detectable cells.
               ladder = isTRUE(z$ladder[1]), nT = z$nT[1],
               anchored = isTRUE(z$anchored[1]), link = z$link[1],
               n_rep = n, n_conv = nc, convergence = nc / n,
               bias = bias, bias_mcse = stats::sd(z$error[ok]) / sqrt(nc),
               coverage = cov,
               ## The single-coverage MCSE. Valid because it concerns one method.
               cov_mcse = sqrt(cov * (1 - cov) / nc),
               width = mean(z$width[ok]),
               width_mcse = stats::sd(z$width[ok]) / sqrt(nc),
               ## AGAINST THE FINITE-TARGET ESTIMAND. Reported beside the
               ## superpopulation figures rather than instead of them: a method
               ## that covers the finite target but not the superpopulation is
               ## aiming at a different quantity, not merely reporting a narrow
               ## interval, and only the pair distinguishes those.
               coverage_finite = mean(z$covered_finite[ok]),
               bias_finite = mean(z$error_finite[ok]),
               stringsAsFactors = FALSE)
  }))
}

## --- paired contrasts between methods, within a cell --------------------------
##
## THE POINT OF THE STUDY IS HERE. `maic_fixed` treats the reported moments as
## constants; `maic_entropy` adds the moment term; `maic_xcov` adds the
## covariance probe P6 found no published method carries. The three differences
## say, in order: how much the moment term buys, how much the cross term buys,
## and what is left for identification to explain.
paired_contrast <- function(d, a, b) {
  do.call(rbind, lapply(split(d, d$cell_id), function(z) {
    za <- z[z$method == a, ]; zb <- z[z$method == b, ]
    m <- merge(za[, c("rep", "covered", "width")],
               zb[, c("rep", "covered", "width")], by = "rep",
               suffixes = c("_a", "_b"))
    m <- m[is.finite(m$width_a) & is.finite(m$width_b), ]
    if (!nrow(m)) return(NULL)
    dc <- as.numeric(m$covered_a) - as.numeric(m$covered_b)
    dw <- m$width_a - m$width_b
    data.frame(cell_id = z$cell_id[1], a = a, b = b, n_pair = nrow(m),
               cov_diff = mean(dc),
               ## PAIRED, from the per-replicate difference. An unpaired formula
               ## would assume the two methods saw different data; they did not.
               cov_diff_mcse = stats::sd(dc) / sqrt(nrow(m)),
               width_diff = mean(dw),
               width_diff_mcse = stats::sd(dw) / sqrt(nrow(m)),
               stringsAsFactors = FALSE)
  }))
}

## --- paired contrasts ACROSS the correlation setting --------------------------
##
## `CRN_BLOCKS` names `corr_assumed`, so cells differing only in it were drawn
## from identical data and their contrast is paired at the replicate level, in
## exactly the way two methods within a cell are. Round 3 of critique found this
## comparison neither paired nor pooled: the study blocked the factor and then
## analyzed it as though the two arms were independent samples, which throws away
## the precision the blocking bought and overstates the error of the contrast.
##
## Cells are matched on every factor EXCEPT the correlation setting, then on the
## replicate index within the matched pair.
corr_contrast <- function(d, method, a = "borrowed", b = "true") {
  keys <- c("link", "nT", "nS", "k", "shape", "modifier_span", "anchored",
            "baseline_shift")
  keys <- intersect(keys, names(d))
  d <- d[d$method == method, ]
  grp <- interaction(d[, keys], drop = TRUE)
  do.call(rbind, lapply(split(d, grp), function(z) {
    za <- z[z$corr_assumed == a, ]; zb <- z[z$corr_assumed == b, ]
    if (!nrow(za) || !nrow(zb)) return(NULL)
    m <- merge(za[, c("rep", "covered", "width")],
               zb[, c("rep", "covered", "width")], by = "rep",
               suffixes = c("_a", "_b"))
    m <- m[is.finite(m$width_a) & is.finite(m$width_b), ]
    if (!nrow(m)) return(NULL)
    dc <- as.numeric(m$covered_a) - as.numeric(m$covered_b)
    data.frame(method = method, a = a, b = b, cell_id = za$cell_id[1],
               n_pair = nrow(m), cov_diff = mean(dc),
               cov_diff_mcse = stats::sd(dc) / sqrt(nrow(m)),
               width_diff = mean(m$width_a - m$width_b),
               stringsAsFactors = FALSE)
  }))
}

main <- function() {
  probes_done()
  d <- read_run()
  cat(sprintf("read %d rows over %d cells and %d methods\n",
              nrow(d), length(unique(d$cell_id)), length(unique(d$method))))

  perf <- performance(d)
  ## The registered band. Both ends are failures: an interval that is too wide is
  ## as wrong as one that is too narrow, and reporting only undercoverage would
  ## make a conservative method look correct.
  ## The band is derived from the number of cells actually analyzed, so a run
  ## covering more cells is judged against a proportionately wider band and the
  ## expected count of spurious failures stays inside its registered budget.
  band <- cover_band(length(unique(perf$cell_id)))
  perf$in_band <- perf$coverage >= band[1] & perf$coverage <= band[2]
  cat(sprintf("coverage band for %d cells: [%.3f, %.3f]\n",
              length(unique(perf$cell_id)), band[1], band[2]))

  cat("\n=== coverage by method, over cells ===\n")
  by_m <- do.call(rbind, lapply(split(perf, perf$method), function(z)
    data.frame(method = z$method[1], cells = nrow(z),
               min = min(z$coverage), median = stats::median(z$coverage),
               max = max(z$coverage), in_band = sum(z$in_band),
               cov_finite = stats::median(z$coverage_finite),
               mean_width = mean(z$width), stringsAsFactors = FALSE)))
  print(by_m, row.names = FALSE, digits = 4)

  ## The three registered contrasts, in the order their mechanisms stack.
  ## THE PAIRED TEST CONTAINS ONLY THE ARMS THAT SHARE A POINT ESTIMATE.
  ## `maic_fixed`, `maic_entropy`, `maic_oracle` and `maic_xcov` come off one fit,
  ## so a difference between them is a difference of intervals and nothing else.
  ## Round 3 of critique found `maic_perturb` in this list while the protocol said
  ## it was excluded from it: it reports percentile limits from its own
  ## resampling, is not centered on the shared estimate, and has no standard
  ## error, so a paired coverage difference against it confounds the interval with
  ## the procedure. It is reported separately, and so is STC, which fits a
  ## different model entirely.
  contrasts <- list(c("maic_entropy", "maic_fixed"),
                    c("maic_xcov",    "maic_entropy"),
                    c("maic_oracle",  "maic_entropy"))
  cs <- do.call(rbind, lapply(contrasts, function(p) paired_contrast(d, p[1], p[2])))

  ## Reported, not tested against the shared-fit arms.
  aside <- do.call(rbind, lapply(list(c("maic_perturb", "maic_entropy"),
                                      c("stc", "maic_entropy")),
                                 function(p) paired_contrast(d, p[1], p[2])))
  if (!is.null(aside)) aside$paired_test <- FALSE

  cat("\n=== paired contrasts, pooled over cells ===\n")
  pooled <- do.call(rbind, lapply(split(cs, list(cs$a, cs$b), drop = TRUE),
                                  function(z)
    data.frame(a = z$a[1], b = z$b[1], cells = nrow(z),
               mean_cov_diff = mean(z$cov_diff),
               ## Across cells the contrasts are independent, so the pooled MCSE
               ## combines the within-cell paired errors rather than recomputing
               ## anything from raw indicators.
               pooled_mcse = sqrt(sum(z$cov_diff_mcse^2)) / nrow(z),
               mean_width_diff = mean(z$width_diff),
               stringsAsFactors = FALSE)))
  print(pooled, row.names = FALSE, digits = 4)

  ## --- THE REGISTERED DECISION, evaluated rather than described ------------
  ##
  ## Round 3: the protocol stated a conclusion the software could not reach. The
  ## rule is applied here, on the powered grid only, with the growth ladder
  ## reported separately because it was retained BELOW the detectability floor and
  ## would dilute any pooled statement.
  pow <- perf[!perf$ladder, ]
  lad <- perf[perf$ladder, ]
  ent <- pow[pow$method == "maic_entropy", ]
  decision <- list(
    n_cells_powered = length(unique(pow$cell_id)),
    entropy_in_band = sum(ent$in_band),
    entropy_cells   = nrow(ent),
    ## The registered branch: does adding the moment term restore nominal
    ## coverage across the powered grid?
    verdict = if (nrow(ent) && all(ent$in_band))
                "moment term suffices in these conditions"
              else if (nrow(ent) && any(ent$in_band))
                "moment term closes part of the deficit and not all"
              else "moment term does not restore nominal coverage",
    ## Prediction 1, on the ladder: does the deficit close as the target grows?
    ladder_by_nT = if (nrow(lad))
      tapply(lad$coverage[lad$method == "maic_entropy"],
             lad$nT[lad$method == "maic_entropy"], mean) else NULL)
  cat("\n=== registered decision ===\n")
  cat(sprintf("entropy arm inside the band in %d of %d powered cells: %s\n",
              decision$entropy_in_band, decision$entropy_cells,
              decision$verdict))
  if (!is.null(decision$ladder_by_nT)) {
    cat("prediction 1, entropy coverage along the growth ladder:\n")
    print(round(decision$ladder_by_nT, 4))
  }

  ## The correlation-setting contrast, paired and pooled the same way.
  cc <- do.call(rbind, lapply(c("maic_entropy", "maic_xcov"), function(mth)
    corr_contrast(d, mth)))
  if (!is.null(cc) && nrow(cc)) {
    cat("\n=== assumed correlation: borrowed against true, paired ===\n")
    ccp <- do.call(rbind, lapply(split(cc, cc$method), function(z)
      data.frame(method = z$method[1], cells = nrow(z),
                 mean_cov_diff = mean(z$cov_diff),
                 pooled_mcse = sqrt(sum(z$cov_diff_mcse^2)) / nrow(z),
                 mean_width_diff = mean(z$width_diff),
                 stringsAsFactors = FALSE)))
    print(ccp, row.names = FALSE, digits = 4)
  } else {
    cat("\nno cell pair differs only in the assumed correlation; the",
        "contrast is not estimable on this grid\n")
    ccp <- NULL
  }

  dir.create("results", showWarnings = FALSE)
  saveRDS(list(performance = perf, contrasts = cs, aside = aside,
               corr_contrast = cc, corr_pooled = ccp,
               by_method = by_m, pooled = pooled, decision = decision),
          "results/analysis.rds")
  cat("\nwritten: results/analysis.rds\n")
}

if (!interactive() && Sys.getenv("ANALYZE_NOMAIN") == "") main()
