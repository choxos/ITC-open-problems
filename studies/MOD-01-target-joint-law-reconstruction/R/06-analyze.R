## ---------------------------------------------------------------------------
## The analysis: every method's bias, coverage and width, plus the three things
## the design registered beyond them.
##
##   Rscript R/06-analyze.R
##
## THE CONTRASTS ARE PAIRED AND THE MONTE CARLO ERROR SAYS SO. Every method
## standardizes the same fitted model over a different law, and every Gaussian law
## is a linear map of one shared base sample, so a method-to-method difference
## carries neither IPD sampling noise nor integration noise of its own. Computing
## its error as if the two arms were independent would overstate it by roughly the
## ratio of the common variance to the differential variance, which here is large.
## Differences are therefore computed per replicate and summarized afterwards.
##
## THREE REGISTERED OUTCOMES BEYOND BIAS AND COVERAGE:
##
##   the mechanism check   section 2 says the reconstruction error is a linear
##                         function of one scalar, gamma' (Sigma_hat - Sigma)
##                         gamma. Regressing observed bias on it tests the
##                         account rather than the conclusion, and a poor fit
##                         means the study reports that instead of a mechanism.
##   the bound             the same scalar gives an error an analyst can compute
##                         from published data. Whether it contains the realized
##                         bias is measured, because a bound someone can evaluate
##                         is worth more than a method they cannot run.
##   the falsifier         section 2 predicts positive covariances cancel under a
##                         mixed sign pattern, so independence should be FINE
##                         there despite strong correlation. If it is biased
##                         there too, the cancellation account is wrong and most
##                         of the practical recommendation goes with it.
## ---------------------------------------------------------------------------

## Sourced for `independence_gap()` and `gamma_vec()`, so the bound the analysis
## reports is computed by the same function the run used rather than by a second
## copy of the algebra that could drift from it.
source("R/01-dgm.R")

RUN_DIR <- "results/run"

METHODS <- c(stc_means = "conventional STC at target means",
             gcomp_oracle = "g-computation, true joint law",
             gcomp_indep = "g-computation, independence",
             gcomp_borrowed = "g-computation, borrowed correlation")

CELL_KEYS <- c("dim", "scale", "modification", "gamma_sign", "rho", "copula",
               "overlap")

read_run <- function() {
  fs <- list.files(RUN_DIR, pattern = "^cell-[0-9]+[.]rds$", full.names = TRUE)
  if (!length(fs)) stop("no run output in ", RUN_DIR, "; run Rscript R/04-run.R")
  do.call(rbind, lapply(fs, readRDS))
}

mcse_mean <- function(v) stats::sd(v) / sqrt(length(v))
mcse_prop <- function(p, n) sqrt(p * (1 - p) / n)

## Per-cell performance for one method.
perf_one <- function(z, m) {
  e <- z[[paste0(m, "_est")]]; tr <- z$truth
  cov <- z[[paste0(m, "_cover")]]; w <- z[[paste0(m, "_width")]]
  data.frame(method = m, n = nrow(z),
             bias = mean(e - tr), bias_mcse = mcse_mean(e - tr),
             rmse = sqrt(mean((e - tr)^2)),
             coverage = mean(cov), cover_mcse = mcse_prop(mean(cov), nrow(z)),
             width = mean(w), stringsAsFactors = FALSE)
}

main <- function() {
  d <- read_run()
  cat(sprintf("read %d replicates over %d cells\n\n", nrow(d),
              length(unique(d$cell_id))))

  ## --- per-cell performance --------------------------------------------------
  perf <- do.call(rbind, lapply(split(d, d$cell_id), function(z) {
    base <- z[1, CELL_KEYS]
    rows <- do.call(rbind, lapply(names(METHODS), function(m) perf_one(z, m)))
    ## The reconstruction interval has no standard error of its own; it is a set,
    ## and it is judged on coverage and width together as section 7 requires.
    rows <- rbind(rows, data.frame(
      method = "recon_interval", n = nrow(z),
      bias = mean(z$recon_est - z$truth), bias_mcse = mcse_mean(z$recon_est - z$truth),
      rmse = sqrt(mean((z$recon_est - z$truth)^2)),
      coverage = mean(z$recon_cover),
      cover_mcse = mcse_prop(mean(z$recon_cover), nrow(z)),
      width = mean(z$recon_width), stringsAsFactors = FALSE))
    cbind(base[rep(1, nrow(rows)), , drop = FALSE], rows)
  }))
  rownames(perf) <- NULL

  ## --- the paired contrast that the study is really about --------------------
  ## Independence minus oracle, per replicate, so its error is paired.
  gap <- do.call(rbind, lapply(split(d, d$cell_id), function(z) {
    g_ind <- z$gcomp_indep_est - z$gcomp_oracle_est
    g_bor <- z$gcomp_borrowed_est - z$gcomp_oracle_est
    g_stc <- z$stc_means_est - z$gcomp_oracle_est
    cbind(z[1, CELL_KEYS],
          data.frame(n = nrow(z),
                     indep_minus_oracle = mean(g_ind), indep_mcse = mcse_mean(g_ind),
                     borrowed_minus_oracle = mean(g_bor), borrowed_mcse = mcse_mean(g_bor),
                     stc_minus_oracle = mean(g_stc), stc_mcse = mcse_mean(g_stc),
                     indep_gap = z$indep_gap[1], stringsAsFactors = FALSE))
  }))
  rownames(gap) <- NULL

  ## --- REGISTERED PRIMARY ----------------------------------------------------
  ## Section 7: bias under the independence reconstruction, on the log odds ratio,
  ## in nonlinear-modification cells with all-positive gamma and correlation 0.6.
  prim <- perf[perf$scale == "logOR" & perf$modification == "nonlinear" &
               perf$gamma_sign == "positive" & perf$rho == 0.6, ]
  cat("=== REGISTERED PRIMARY: log OR, nonlinear, positive gamma, rho = 0.6 ===\n")
  ps <- do.call(rbind, lapply(split(prim, prim$method), function(z)
    data.frame(method = z$method[1], cells = nrow(z),
               mean_bias = mean(z$bias), worst_bias = z$bias[which.max(abs(z$bias))],
               mean_coverage = mean(z$coverage), mean_width = mean(z$width),
               stringsAsFactors = FALSE)))
  ps <- ps[order(abs(ps$mean_bias)), ]
  print(ps, row.names = FALSE, digits = 4)

  ## --- THE FALSIFIER ---------------------------------------------------------
  cat("\n=== FALSIFIER: does the mixed sign pattern cancel the error? ===\n")
  cat("Section 2 predicts independence is FINE under mixed signs despite strong\n")
  cat("correlation. If it is biased there too, the cancellation account is wrong.\n\n")
  fals <- do.call(rbind, lapply(
    split(gap[gap$scale == "logOR" & gap$rho == 0.6, ],
          gap[gap$scale == "logOR" & gap$rho == 0.6, c("gamma_sign", "modification")]),
    function(z) if (!nrow(z)) NULL else data.frame(
      gamma_sign = z$gamma_sign[1], modification = z$modification[1],
      cells = nrow(z), indep_gap_scalar = z$indep_gap[1],
      mean_indep_minus_oracle = mean(z$indep_minus_oracle),
      worst = z$indep_minus_oracle[which.max(abs(z$indep_minus_oracle))],
      stringsAsFactors = FALSE)))
  print(fals, row.names = FALSE, digits = 4)

  ## --- THE MECHANISM CHECK ---------------------------------------------------
  cat("\n=== MECHANISM: is the error linear in section 2's scalar? ===\n")
  mech <- do.call(rbind, lapply(
    split(gap, gap[c("scale", "modification", "dim")]), function(z) {
      if (nrow(z) < 3 || length(unique(z$indep_gap)) < 2) return(NULL)
      f <- stats::lm(indep_minus_oracle ~ indep_gap, data = z)
      data.frame(scale = z$scale[1], modification = z$modification[1],
                 dim = z$dim[1], cells = nrow(z),
                 slope = unname(stats::coef(f)[2]),
                 r2 = summary(f)$r.squared, stringsAsFactors = FALSE)
    }))
  print(mech, row.names = FALSE, digits = 4)
  cat("\nSection 2 predicts a single slope per block and a high R-squared. A poor\n")
  cat("fit means the second-order expansion is not what drives the error at these\n")
  cat("strengths, and the study reports that rather than the mechanism.\n")

  ## --- THE BOUND -------------------------------------------------------------
  ## Section 2 consequence 1: an analyst who knows the sign pattern of gamma and
  ## asserts a correlation range can evaluate the independence error without any
  ## new method. The bound is the largest and smallest such error over the
  ## declared range, and its coverage of the realized gap is measured.
  cat("\n=== THE BOUND an analyst can compute from published data ===\n")
  bounds <- do.call(rbind, lapply(seq_len(nrow(gap)), function(i) {
    z <- gap[i, ]
    g <- gamma_vec(z$dim, z$gamma_sign)
    ## The gap the bound predicts, over the declared correlation range.
    cand <- vapply(seq(RECON_RHO_RANGE[1], RECON_RHO_RANGE[2], length.out = 25),
      function(r) {
        if (r <= -1 / (z$dim - 1)) return(NA_real_)
        R <- matrix(r, z$dim, z$dim); diag(R) <- 1
        -independence_gap(g, R)
      }, 0)
    cand <- cand[is.finite(cand)]
    data.frame(cell = i, scale = z$scale, modification = z$modification,
               realized = z$indep_minus_oracle,
               scalar_lo = min(cand), scalar_hi = max(cand),
               stringsAsFactors = FALSE)
  }))
  ## The bound is on the SCALAR, and turning it into a bound on the contrast
  ## needs the proportionality constant the mechanism check estimates. So the
  ## bound is reported as: does the realized gap lie between the scalar bounds
  ## scaled by the fitted slope for that block?
  bounds <- merge(bounds,
                  mech[, c("scale", "modification", "slope")],
                  by = c("scale", "modification"), all.x = TRUE)
  bounds$lo <- pmin(bounds$scalar_lo, bounds$scalar_hi) * abs(bounds$slope) *
               -sign(bounds$slope)
  bounds$hi <- pmax(bounds$scalar_lo, bounds$scalar_hi) * abs(bounds$slope) *
               -sign(bounds$slope)
  bounds$contains <- bounds$realized >= pmin(bounds$lo, bounds$hi) &
                     bounds$realized <= pmax(bounds$lo, bounds$hi)
  cat(sprintf("realized gap inside the computable bound in %d of %d cells (%.3f)\n",
              sum(bounds$contains, na.rm = TRUE), sum(!is.na(bounds$contains)),
              mean(bounds$contains, na.rm = TRUE)))
  cat("The bound uses the fitted proportionality from the mechanism block, so it\n")
  cat("is an in-sample assessment of the bound's SHAPE, not of a constant an\n")
  cat("analyst would have to supply independently. That limit is reported.\n")

  ## --- the withdrawn control, as a prediction --------------------------------
  cat("\n=== SCALE: is the collapsible scale's error materially smaller? ===\n")
  sc <- do.call(rbind, lapply(split(gap, gap$scale), function(z)
    data.frame(scale = z$scale[1], cells = nrow(z),
               mean_abs_gap = mean(abs(z$indep_minus_oracle)),
               worst_abs_gap = max(abs(z$indep_minus_oracle)),
               stringsAsFactors = FALSE)))
  print(sc, row.names = FALSE, digits = 4)

  ## --- copula family beyond the correlation matrix ---------------------------
  cat("\n=== PREDICTION 4: does the copula family matter beyond correlation? ===\n")
  cat("All three families are matched on Pearson correlation, so the borrowed\n")
  cat("correlation arm has the right second moment and the wrong family.\n\n")
  cf <- do.call(rbind, lapply(
    split(gap[gap$rho > 0, ], gap[gap$rho > 0, c("copula", "modification", "scale")]),
    function(z) if (!nrow(z)) NULL else data.frame(
      copula = z$copula[1], modification = z$modification[1], scale = z$scale[1],
      cells = nrow(z), mean_borrowed_gap = mean(z$borrowed_minus_oracle),
      stringsAsFactors = FALSE)))
  cf <- cf[order(cf$scale, cf$modification, cf$copula), ]
  print(cf, row.names = FALSE, digits = 4)

  dir.create("results", showWarnings = FALSE)
  saveRDS(list(perf = perf, gap = gap, primary = ps, falsifier = fals,
               mechanism = mech, bounds = bounds, scale_effect = sc,
               copula_effect = cf,
               n_rep = N_REP, n_cells = length(unique(d$cell_id))),
          "results/analysis.rds")
  cat("\nwritten: results/analysis.rds\n")
}

if (!interactive() && Sys.getenv("ANALYZE_NOMAIN") == "") main()
