## ---------------------------------------------------------------------------
## The two exact null controls, run separately from the grid because neither is a
## cell of it.
##
##   Rscript R/05-controls.R
##
## Both are identities, not expectations, which is what makes them worth running:
## a failure here is an implementation fault and not a finding, and it invalidates
## every number the grid produces.
##
##   Control A, d = 1. With one covariate there is no off-diagonal, so the joint
##   law IS the marginal and every reconstruction coincides with the truth by
##   definition. Any disagreement between methods is a bug.
##
##   Control B, rho = 0. The true law is the independence law, so the oracle and
##   the independence reconstruction integrate the same distribution and must
##   agree to the integration error P1 sized. This also checks that all three
##   copula families collapse onto each other there, since each reduces to the
##   independence copula.
##
## DESIGN.md section 8 previously registered a THIRD control, that the
## risk-difference scale makes the reconstruction exactly irrelevant. It does
## not, the design records why, and this program measures the size of the effect
## that control wrongly assumed away rather than pretending it is zero.
## ---------------------------------------------------------------------------

source("R/02-methods.R")

fmt <- function(x, d = 5) formatC(x, format = "f", digits = d)

## Tolerance for an identity: the integration error P1 measured, with headroom.
## Registered as a multiple of that error rather than as a bare number, so it
## moves with the constant it is really about.
IDENTITY_TOL <- function() max(3 * MATERIAL_LOGOR / 20, 1e-6)

one_fit <- function(d, rho, family, modification, sign_pattern, seed) {
  set.seed(seed)
  g <- gamma_vec(d, sign_pattern)
  x <- draw_ipd(N_IPD, d, rho, family, "good")
  A <- stats::rbinom(N_IPD, 1, 0.5)
  y <- draw_outcome(prob_of(x, A, g, modification))
  f <- fit_ipd(x, A, y, modification)
  list(fit = f, x = x, gamma = g)
}

control_A <- function(reps = 40L) {
  cat("== Control A (exact): d = 1, no off-diagonal to reconstruct ==\n")
  rows <- list()
  for (scale in LEVELS$scale) for (modification in LEVELS$modification) {
    dif <- vapply(seq_len(reps), function(r) {
      z <- one_fit(1L, 0, "gaussian", modification, "positive", 60000L + r)
      if (is.null(z$fit)) return(NA_real_)
      o <- standardize(z$fit, law_oracle(1L, 0, "gaussian", N_INT), scale)
      i <- standardize(z$fit, law_independence(1L, N_INT), scale)
      b <- standardize(z$fit, law_gaussian(stats::cor(z$x), N_INT), scale)
      if (is.null(o) || is.null(i) || is.null(b)) return(NA_real_)
      max(abs(c(o$est - i$est, o$est - b$est)))
    }, 0)
    rows[[length(rows) + 1L]] <- data.frame(
      scale = scale, modification = modification,
      max_disagreement = max(dif, na.rm = TRUE),
      mean_disagreement = mean(dif, na.rm = TRUE), stringsAsFactors = FALSE)
  }
  res <- do.call(rbind, rows)
  print(res, row.names = FALSE, digits = 4)
  tol <- IDENTITY_TOL()
  ok <- max(res$max_disagreement) <= tol
  cat(sprintf("\nlargest disagreement %s against tolerance %s: %s\n",
              fmt(max(res$max_disagreement)), fmt(tol),
              ifelse(ok, "PASS", "**FAIL**")))
  list(table = res, ok = ok, tol = tol)
}

control_B <- function(reps = 40L) {
  cat("\n== Control B (exact to integration error): rho = 0 ==\n")
  rows <- list()
  for (d in LEVELS$dim) for (scale in LEVELS$scale) {
    dif <- vapply(seq_len(reps), function(r) {
      z <- one_fit(d, 0, "gaussian", "nonlinear", "positive", 61000L + r)
      if (is.null(z$fit)) return(NA_real_)
      o <- standardize(z$fit, law_oracle(d, 0, "gaussian", N_INT), scale)
      i <- standardize(z$fit, law_independence(d, N_INT), scale)
      if (is.null(o) || is.null(i)) return(NA_real_)
      abs(o$est - i$est)
    }, 0)
    rows[[length(rows) + 1L]] <- data.frame(
      dim = d, scale = scale, max_disagreement = max(dif, na.rm = TRUE),
      mean_disagreement = mean(dif, na.rm = TRUE), stringsAsFactors = FALSE)
  }
  res <- do.call(rbind, rows)
  print(res, row.names = FALSE, digits = 4)

  ## The three families must also coincide at rho = 0.
  fam <- vapply(LEVELS$copula, function(f) {
    set.seed(62000L)
    marginal_contrast(draw_target(100000L, 5L, 0, f), gamma_vec(5L, "positive"),
                      "nonlinear", "logOR")
  }, 0)
  cat(sprintf("\ncopula families at rho = 0 (must coincide): %s\n",
              paste(sprintf("%s %s", names(fam), fmt(fam, 4)), collapse = " | ")))
  fam_spread <- max(fam) - min(fam)

  tol <- IDENTITY_TOL()
  ok <- max(res$max_disagreement) <= tol && fam_spread <= tol
  cat(sprintf("largest disagreement %s, family spread %s, tolerance %s: %s\n",
              fmt(max(res$max_disagreement)), fmt(fam_spread), fmt(tol),
              ifelse(ok, "PASS", "**FAIL**")))
  list(table = res, family_spread = fam_spread, ok = ok)
}

## The withdrawn control, measured rather than assumed. DESIGN.md section 8 said
## the reconstruction is exactly irrelevant on a collapsible scale; it is not,
## and the study reports how much smaller the effect is instead of how absent.
scale_ratio <- function(n = 400000L) {
  cat("\n== The withdrawn control, measured: how much smaller is the ")
  cat("collapsible scale? ==\n")
  rows <- list()
  for (d in LEVELS$dim) for (modification in LEVELS$modification)
    for (sign_pattern in LEVELS$gamma_sign) {
      g <- gamma_vec(d, sign_pattern)
      set.seed(63000L); x0 <- draw_target(n, d, 0, "gaussian")
      set.seed(63001L); x6 <- draw_target(n, d, 0.6, "gaussian")
      e <- vapply(LEVELS$scale, function(s)
        marginal_contrast(x6, g, modification, s) -
        marginal_contrast(x0, g, modification, s), 0)
      rows[[length(rows) + 1L]] <- data.frame(
        dim = d, modification = modification, gamma_sign = sign_pattern,
        shift_logOR = e[["logOR"]], shift_riskdiff = e[["riskdiff"]],
        ratio = abs(e[["riskdiff"]]) / max(abs(e[["logOR"]]), 1e-12),
        stringsAsFactors = FALSE)
    }
  res <- do.call(rbind, rows)
  print(res, row.names = FALSE, digits = 4)
  cat(sprintf("\nrisk difference carries %.0f%% to %.0f%% of the log odds ratio's\n",
              100 * min(res$ratio), 100 * max(res$ratio)))
  cat("reconstruction shift. The withdrawn control assumed zero.\n")
  list(table = res)
}

main <- function() {
  probes_done(c("TRUTH_N", "N_INT"))
  a <- control_A(); b <- control_B(); s <- scale_ratio()
  dir.create("results", showWarnings = FALSE)
  saveRDS(list(A = a, B = b, scale_ratio = s, both_ok = a$ok && b$ok),
          "results/controls.rds")
  cat(sprintf("\nboth exact controls pass: %s\n", a$ok && b$ok))
  cat("written: results/controls.rds\n")
}

if (!interactive()) main()
