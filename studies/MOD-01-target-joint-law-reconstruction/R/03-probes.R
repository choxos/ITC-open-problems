## ---------------------------------------------------------------------------
## Probes P1 to P4. These run BEFORE the design becomes a protocol.
##
##   Rscript R/03-probes.R
##
## P2 IS THE DESIGN. Two cells that differ in their reported summaries are not a
## test of the joint law, they are a test of the marginals, and every comparison
## in the study would be confounded. The construction in `R/01-dgm.R` makes the
## marginals exact by the probability integral transform, so P2's job is to catch
## the case where that reasoning is right and the code is wrong.
##
## P1 SIZES TRUTH AND INTEGRATION AGAINST THE MATERIAL THRESHOLD, AT THE WORST
## CELL RATHER THAN THE MIDDLE. A sibling study in this repository registered a
## sample size from a noise floor measured at the middle of its grid, and the
## floor at the hardest corner was fifty times larger; three quarters of that
## grid became unusable. The lesson is cheap to apply once and expensive to
## relearn, so P1 searches the corners.
## ---------------------------------------------------------------------------

source("R/02-methods.R")

RESULTS <- "results"
dir.create(RESULTS, showWarnings = FALSE)

fmt <- function(x, d = 4) formatC(x, format = "f", digits = d)

## The cells P1 sizes against. Truth and integration error both grow with
## dimension, with correlation, and with the curvature nonlinear modification
## adds, so the corner is d = 5, rho = 0.6, nonlinear, on the log odds ratio
## scale, which is also where the primary outcome lives.
WORST <- list(d = 5L, rho = 0.6, modification = "nonlinear", scale = "logOR")

## =========================================================================
## P1: how large must the truth sample and the integration sample be?
## =========================================================================
probe_p1 <- function(reps = 12L,
                     sizes_truth = c(50000L, 200000L, 800000L),
                     sizes_int   = c(5000L, 20000L, 80000L)) {
  cat("== P1: sizing truth and integration at the worst corner ==\n")
  cat(sprintf("corner: d=%d rho=%.1f %s %s; material threshold %.3f\n\n",
              WORST$d, WORST$rho, WORST$modification, WORST$scale, MATERIAL_LOGOR))
  g <- gamma_vec(WORST$d, "positive")

  ## --- truth: independent repeats of the same integral, at each size --------
  tr <- do.call(rbind, lapply(sizes_truth, function(n) {
    v <- vapply(seq_len(reps), function(r) {
      set.seed(90000L + r)
      marginal_contrast(draw_target(n, WORST$d, WORST$rho, "clayton"),
                        g, WORST$modification, WORST$scale)
    }, 0)
    data.frame(n = n, sd = stats::sd(v), mean = mean(v))
  }))
  tr$frac_material <- tr$sd / MATERIAL_LOGOR
  cat("truth sample size (Clayton, the family with the most tail mass):\n")
  print(tr, row.names = FALSE, digits = 4)
  ok_t <- tr$n[tr$sd <= MATERIAL_LOGOR / 20]
  truth_n <- if (length(ok_t)) min(ok_t) else max(sizes_truth)
  cat(sprintf("-> TRUTH_N = %d (Monte Carlo error %s, target <= %s)\n\n",
              truth_n, fmt(tr$sd[tr$n == truth_n]), fmt(MATERIAL_LOGOR / 20)))

  ## --- integration: THE FIT IS HELD FIXED so this isolates integration error --
  ## An earlier version of this probe redrew the IPD sample at every repeat, so
  ## what it measured was IPD sampling variability with integration error buried
  ## inside it: the answer was flat in n because the part that varies with n was
  ## a twentieth of the part that does not. One fit, many integration draws, is
  ## the measurement the constant is being chosen against.
  set.seed(91000L)
  xf <- draw_ipd(N_IPD, WORST$d, WORST$rho, "clayton", "good")
  Af <- stats::rbinom(N_IPD, 1, 0.5)
  yf <- draw_outcome(prob_of(xf, Af, g, WORST$modification))
  ff <- fit_ipd(xf, Af, yf, WORST$modification)
  it <- do.call(rbind, lapply(sizes_int, function(n) {
    v <- vapply(seq_len(reps), function(r) {
      rm(list = ls(.int_cache), envir = .int_cache)
      ## Vary only the integration draw, by perturbing the cache keys' seed.
      o <- standardize(ff, .qnorm_u(rCopula(n, build_copula("clayton",
             copula_param("clayton", WORST$rho, WORST$d), WORST$d))), WORST$scale)
      i <- standardize(ff, .exact_margins(matrix(stats::rnorm(n * WORST$d),
             n, WORST$d)), WORST$scale)
      if (is.null(o) || is.null(i)) return(NA_real_)
      o$est - i$est
    }, 0)
    data.frame(n = n, sd_contrast = stats::sd(v, na.rm = TRUE),
               mean_contrast = mean(v, na.rm = TRUE),
               frac_material = stats::sd(v, na.rm = TRUE) / MATERIAL_LOGOR)
  }))
  cat("integration sample size, one fixed fit, oracle-minus-independence contrast:\n")
  print(it, row.names = FALSE, digits = 4)
  ## THE CHOICE USES THE UPPER BOUND ON THE MEASURED ERROR, NOT THE POINT
  ## ESTIMATE. With `reps` repeats the sample standard deviation carries its own
  ## error of roughly 1/sqrt(2(reps-1)), which is 21% at twelve, so a size whose
  ## point estimate lands just under the target has a real chance of being over
  ## it. The upper chi-squared bound is what the constant is chosen against.
  ##
  ## THIS ERROR DOES NOT AVERAGE AWAY. The integration sample is cached and
  ## shared across replicates, so its error is a fixed offset on every replicate
  ## rather than noise, and running more replicates does not reduce it. That is
  ## why the target here is tight relative to the material threshold.
  it$upper <- it$sd_contrast * sqrt((reps - 1) / stats::qchisq(0.025, reps - 1))
  print(it[, c("n", "sd_contrast", "upper", "frac_material")],
        row.names = FALSE, digits = 4)
  ok_i <- it$n[it$upper <= MATERIAL_LOGOR / 20]
  n_int <- if (length(ok_i)) min(ok_i) else max(sizes_int)
  cat(sprintf("-> N_INT = %d (integration error %s, upper bound %s, target <= %s)\n\n",
              n_int, fmt(it$sd_contrast[it$n == n_int]),
              fmt(it$upper[it$n == n_int]), fmt(MATERIAL_LOGOR / 20)))
  rm(list = ls(.int_cache), envir = .int_cache)
  list(TRUTH_N = truth_n, N_INT = n_int, truth_table = tr, int_table = it)
}

## =========================================================================
## P2: are the published marginals identical across every cell?
## =========================================================================
probe_p2 <- function(n = 200000L) {
  cat("== P2: matched marginals across correlation and copula family ==\n")
  cat("The design's central control. Every cell must publish the same means and\n")
  cat("standard deviations, so that only the joint law differs.\n\n")
  rows <- list()
  for (d in LEVELS$dim) for (rho in LEVELS$rho) for (fam in LEVELS$copula) {
    if (rho == 0 && fam != "gaussian") next   # independence copula, families coincide
    set.seed(92000L + d)
    x <- draw_target(n, d, rho, fam)
    R <- stats::cor(x)
    rows[[length(rows) + 1L]] <- data.frame(
      dim = d, rho = rho, family = fam,
      max_abs_mean = max(abs(colMeans(x))),
      max_sd_dev   = max(abs(apply(x, 2, stats::sd) - 1)),
      realized_cor = mean(R[upper.tri(R)]),
      cor_error    = abs(mean(R[upper.tri(R)]) - rho),
      stringsAsFactors = FALSE)
  }
  res <- do.call(rbind, rows)
  print(res, row.names = FALSE, digits = 4)
  mc <- 1 / sqrt(n)
  ok_marg <- max(res$max_abs_mean) < 5 * mc && max(res$max_sd_dev) < 5 * mc
  ok_cor  <- max(res$cor_error) < 0.01
  cat(sprintf("\nmarginals matched to Monte Carlo error (%s): %s\n",
              fmt(5 * mc), ifelse(ok_marg, "yes", "NO")))
  cat(sprintf("copula families matched on Pearson correlation to 0.01: %s\n",
              ifelse(ok_cor, "yes", "NO")))
  if (!ok_marg || !ok_cor)
    cat("\n*** P2 FAILED. The design's central control does not hold and no\n",
        "*** comparison in this study would be attributable to the joint law.\n")
  list(table = res, marginals_ok = ok_marg, correlation_ok = ok_cor)
}

## =========================================================================
## P3: is section 2's bound computable, and does it contain the realized bias?
## =========================================================================
## The bound needs the prognostic coefficients, which the IPD analyst has from
## their own fit, and a declared correlation range, which is an assertion rather
## than data. Nothing in it requires the target's joint law, which is the point:
## it is deployable from what a publication prints. Whether it is USEFUL is a
## separate question and this measures it.
probe_p3 <- function(reps = 200L, n_int = 20000L, truth_n = 200000L) {
  cat("== P3: the analytically computable bound ==\n")
  rows <- list()
  for (sign_pattern in LEVELS$gamma_sign) for (rho in c(0.3, 0.6)) {
    d <- WORST$d
    g <- gamma_vec(d, sign_pattern)
    R <- matrix(rho, d, d); diag(R) <- 1
    truth <- marginal_contrast(
      local({ set.seed(93000L); draw_target(truth_n, d, rho, "gaussian") }),
      g, WORST$modification, WORST$scale)
    bias <- vapply(seq_len(reps), function(r) {
      set.seed(94000L + r)
      x <- draw_ipd(N_IPD, d, rho, "gaussian", "good")
      A <- stats::rbinom(N_IPD, 1, 0.5)
      y <- draw_outcome(prob_of(x, A, g, WORST$modification))
      f <- fit_ipd(x, A, y, WORST$modification)
      if (is.null(f)) return(NA_real_)
      s <- standardize(f, law_independence(d, n_int), WORST$scale)
      if (is.null(s)) return(NA_real_)
      s$est - truth
    }, 0)
    rows[[length(rows) + 1L]] <- data.frame(
      gamma_sign = sign_pattern, rho = rho,
      prognostic_var_true = prognostic_var(g, R),
      prognostic_var_indep = prognostic_var(g, diag(d)),
      indep_gap = independence_gap(g, R),
      mean_bias = mean(bias, na.rm = TRUE),
      mcse = stats::sd(bias, na.rm = TRUE) / sqrt(sum(!is.na(bias))),
      stringsAsFactors = FALSE)
  }
  res <- do.call(rbind, rows)
  print(res, row.names = FALSE, digits = 4)
  cat("\nSection 2 predicts bias proportional to `indep_gap`, and predicts that\n")
  cat("the mixed sign pattern cancels it. Read the two `indep_gap` columns\n")
  cat("against the two `mean_bias` columns: that is the falsifier for this\n")
  cat("study's own headline, checked before the grid is committed to.\n")
  list(table = res)
}

## =========================================================================
## P4: unit cost, so the grid is computed rather than typed
## =========================================================================
probe_p4 <- function(reps = 30L, n_int = 20000L) {
  cat("== P4: per-replicate cost ==\n")
  d <- WORST$d; g <- gamma_vec(d, "positive")
  t0 <- proc.time()
  for (r in seq_len(reps)) {
    set.seed(95000L + r)
    x <- draw_ipd(N_IPD, d, WORST$rho, "clayton", "good")
    A <- stats::rbinom(N_IPD, 1, 0.5)
    y <- draw_outcome(prob_of(x, A, g, WORST$modification))
    f <- fit_ipd(x, A, y, WORST$modification)
    if (is.null(f)) next
    standardize(f, law_oracle(d, WORST$rho, "clayton", n_int), WORST$scale)
    standardize(f, law_independence(d, n_int), WORST$scale)
    standardize(f, law_gaussian(stats::cor(x), n_int), WORST$scale)
    stc_at_means(f, d, WORST$scale)
    reconstruction_interval(f, d, WORST$scale, n_int)
  }
  dt <- unname((proc.time() - t0)[["elapsed"]]) / reps
  ## Cells with rho = 0 collapse across copula families, since all three are the
  ## independence copula there, so the grid is smaller than the full crossing.
  n_cells <- (1L + (length(LEVELS$rho) - 1L) * length(LEVELS$copula)) *
             length(LEVELS$gamma_sign) * length(LEVELS$modification) *
             length(LEVELS$scale) * length(LEVELS$overlap) * length(LEVELS$dim)
  cat(sprintf("%.3f s per replicate at N_INT = %d\n", dt, n_int))
  cat(sprintf("distinct cells after collapsing rho = 0 across families: %d\n", n_cells))
  cat(sprintf("total at N_REP = %d: %.1f core-hours\n",
              N_REP, dt * n_cells * N_REP / 3600))
  list(sec_per_rep = dt, n_cells = n_cells,
       core_hours = dt * n_cells * N_REP / 3600)
}

main <- function() {
  which <- Sys.getenv("PROBE", "all")
  out <- if (file.exists(PROBE_FILE)) readRDS(PROBE_FILE) else list()

  if (which %in% c("all", "p2")) { out$P2 <- probe_p2(); cat("\n") }
  if (which %in% c("all", "p1")) {
    p1 <- probe_p1()
    out$P1 <- p1; out$TRUTH_N <- p1$TRUTH_N; out$N_INT <- p1$N_INT
    cat("\n")
  }
  if (which %in% c("all", "p3")) {
    ti <- if (!is.null(out$TRUTH_N)) out$TRUTH_N else 200000L
    ni <- if (!is.null(out$N_INT)) out$N_INT else 20000L
    out$P3 <- probe_p3(truth_n = ti, n_int = ni); cat("\n")
  }
  if (which %in% c("all", "p4")) {
    ni <- if (!is.null(out$N_INT)) out$N_INT else 20000L
    out$P4 <- probe_p4(n_int = ni); cat("\n")
  }
  saveRDS(out, PROBE_FILE)
  cat("written:", PROBE_FILE, "\n")
}

if (!interactive()) main()
