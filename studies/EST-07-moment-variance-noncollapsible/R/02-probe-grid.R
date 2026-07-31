## ---------------------------------------------------------------------------
## PROBE P2: the realized grid, and which of its cells are worth running.
##
## DESIGN.md section 10 asks this probe for two things: the cell count, and the
## analytic omitted-variance fraction in each cell. Cells where the predicted
## omission is **below Monte Carlo resolution** are dropped rather than run,
## because a cell whose effect cannot be distinguished from zero at the
## registered replicate count consumes budget and returns nothing.
##
## The omitted fraction is computable without simulating anything, now that the
## gradient is available: the omitted variance is J' Omega J / nT with J the
## ESTIMAND gradient, and the retained source variance comes from the sandwich.
## A handful of replicates per cell fixes the latter; no cell needs its full
## 2000 to decide whether it is worth 2000.
##
## WHAT COULD CHANGE: the grid. Any cell dropped here is named, with the fraction
## that dropped it, in DESIGN.md's after-a-number table.
##
##   Rscript R/02-probe-grid.R
## ---------------------------------------------------------------------------

source("R/04-maic.R")

## Replicates per cell. Raised from 20 when the gate's denominator grew to the
## whole variance: the cross term is a covariance across replicates and 20 draws
## cannot estimate one.
N_CAL_REP <- 120L

## THE FLOOR IS SOLVED FROM THE CRITERION, not asserted to follow from it.
##
## Round 1 of critique: the floor was 0.04 and the sentence beside it said that
## followed from wanting to resolve a 0.01 coverage shift. It does not. Omitting a
## fraction f of the variance reports an SE of sqrt(1-f) times the truth, so
## coverage becomes 2 * Phi(1.96 * sqrt(1-f)) - 1. At f = 0.04 that is 0.9452, a
## shift of 0.0048, which is ONE Monte Carlo SE rather than the two the criterion
## asks for. The 0.01 shift needs f = 0.079.
##
## So the number was derived, and derived wrongly, which is worse than typing it:
## a typed number invites checking and a derived one does not. It is solved here
## by root-finding on the stated criterion, so the floor and the sentence cannot
## drift apart again.
MIN_COVERAGE_SHIFT <- 0.01

omitted_share_for_shift <- function(shift, nominal = NOMINAL) {
  z <- stats::qnorm(1 - (1 - nominal) / 2)
  f <- function(fr) (nominal - (2 * stats::pnorm(z * sqrt(1 - fr)) - 1)) - shift
  stats::uniroot(f, c(1e-6, 0.9))$root
}

MIN_OMITTED_SHARE <- omitted_share_for_shift(MIN_COVERAGE_SHIFT)

## The realized grid, built by the rule DESIGN.md section 4 states: the first
## four factors fully crossed within each link, the last three crossed with k and
## nT at the middle level of the others.
build_grid <- function() {
  ## THE CORE IS CROSSED WITH BOTH ARMS. `anchored` is not a one-at-a-time
  ## variation around a middle: the probe phase showed the anchored and unanchored
  ## settings differ by an order of magnitude in what the moment term is a share
  ## of, so every core cell is run both ways and the two are compared directly.
  core <- expand.grid(link = LEVELS$link, nT = LEVELS$nT, nS = LEVELS$nS,
                      k = LEVELS$k, shape = GRID_MIDDLE$shape,
                      corr_assumed = GRID_MIDDLE$corr_assumed,
                      modifier_span = GRID_MIDDLE$modifier_span,
                      anchored = LEVELS$anchored,
                      baseline_shift = LEVELS$baseline_shift,
                      KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  extra <- do.call(rbind, lapply(
    c("shape", "corr_assumed", "modifier_span"), function(f) {
      lv <- setdiff(LEVELS[[f]], GRID_MIDDLE[[f]])
      g <- expand.grid(link = LEVELS$link, nT = LEVELS$nT,
                       nS = GRID_MIDDLE$nS, k = LEVELS$k,
                       shape = GRID_MIDDLE$shape,
                       corr_assumed = GRID_MIDDLE$corr_assumed,
                       modifier_span = GRID_MIDDLE$modifier_span,
                       anchored = LEVELS$anchored,
                       baseline_shift = GRID_MIDDLE$baseline_shift,
                       lvl = lv, KEEP.OUT.ATTRS = FALSE,
                       stringsAsFactors = FALSE)
      g[[f]] <- g$lvl; g$lvl <- NULL
      g
    }))
  g <- unique(rbind(core, extra))
  rownames(g) <- NULL
  g$cell_id <- seq_len(nrow(g))
  g
}

main <- function() {
  p <- load_probes()
  stopifnot("probe P1 has not run" = !is.null(p) && is.finite(p$QUAD_ORDER[[1]]))
  ord <- p$QUAD_ORDER[[1]]

  g <- build_grid()
  cat(sprintf("=== P2: realized grid ===\nfully realized cells: %d\n", nrow(g)))
  print(table(g$link, g$shape))

  set.seed(MASTER_SEED)
  sigma <- rep(1, N_COVARIATE); rho <- 0.3
  shares <- do.call(rbind, lapply(seq_len(nrow(g)), function(i) {
    r <- g[i, ]
    pars <- make_pars(r$k, modifier_span = r$modifier_span)
    ## The omitted variance, from the estimand gradient. `modifier_span` can
    ## lengthen the covariate vector, so the moments are rebuilt per cell.
    pp <- length(pars$beta_em)
    ## THE TARGET MEANS COME FROM `population_means()`, not from repeating the
    ## registered SMD. Under `mixed` the binary covariate needs a different latent
    ## shift to realize the same overlap, and building the vector by hand here is
    ## exactly how this probe would go on measuring a cell the sampler does not
    ## produce.

    ## THE DENOMINATOR IS THE WHOLE VARIANCE OF THE ANCHORED CONTRAST, and round 2
    ## of critique is why. The gate used v_omit / (v_omit + v_src), which leaves
    ## out the target trial's own variance and its covariance with the reported
    ## moments, both of which are in the interval. The floor is solved from a
    ## COVERAGE shift, and coverage responds to a fraction of the TOTAL variance,
    ## so screening on a partial denominator screens on a different quantity than
    ## the one the criterion is about. Every term is now collected from the same
    ## calibration replicates.
    parts <- lapply(seq_len(N_CAL_REP), function(q) {
      d <- sample_replicate(r$nS, r$nT, r$k, r$link, r$shape, rho,
                            modifier_span = r$modifier_span,
                            baseline_shift = r$baseline_shift,
                            anchored = r$anchored)
      eg <- estimator_gradient(d, r$link)
      if (!isTRUE(eg$ok)) return(NULL)
      ## Every term is the ARM'S OWN: the unanchored contrast has a different
      ## gradient, a different target quantity and a much smaller target
      ## variance, and mixing them would measure neither setting.
      an <- isTRUE(r$anchored)
      aI <- if (an) eg$aI else eg$aI_un
      list(v_src = as.numeric(aI %*% eg$parts$B %*% aI) / eg$parts$n,
           v_bc  = if (an) d$target_reported$var_theta_BC
                   else d$target_reported$var_g_mu_B,
           m     = d$target_reported$m,
           tb    = if (an) d$target_reported$theta_BC
                   else d$target_reported$g_mu_B,
           J     = if (an) eg$J else eg$J_un,
           ## The reported summaries, carried so Omega is built over exactly the
           ## covariates the estimator's gradient is indexed by. Building it from
           ## the full covariate vector made it non-conformable under the
           ## `outside` arm, where one covariate is never reported.
           mean  = d$target_reported$mean, sd = d$target_reported$sd,
           bin   = d$target_reported$binary)
    })
    parts <- parts[!vapply(parts, is.null, TRUE)]
    n_ok <- length(parts)
    if (n_ok < 10L)
      return(data.frame(cell_id = r$cell_id, link = r$link, nT = r$nT,
                        nS = r$nS, k = r$k, shape = r$shape,
                        corr_assumed = r$corr_assumed,
                        modifier_span = r$modifier_span, anchored = r$anchored,
                        baseline_shift = r$baseline_shift,
                        v_omit = NA_real_, v_src = NA_real_, v_bc = NA_real_,
                        v_cross = NA_real_, share = NA_real_, n_ok = n_ok,
                        stringsAsFactors = FALSE))
    v_src <- mean(vapply(parts, function(z) z$v_src, 0))
    ## The target trial's own variance, shared by every method.
    v_bc <- mean(vapply(parts, function(z) z$v_bc, 0))
    ## The cross term probe P6 found no published method carries. Estimated from
    ## these same replicates rather than from the R/14 calibration, because that
    ## calibration is keyed on the grid this probe is still deciding.
    M <- do.call(rbind, lapply(parts, function(z) z$m))
    tb <- vapply(parts, function(z) z$tb, 0)
    Jbar <- colMeans(do.call(rbind, lapply(parts, function(z) z$J)))
    ## THE OMITTED VARIANCE USES THE ESTIMATOR GRADIENT, not the estimand's.
    ##
    ## Round 2 of critique named both halves of this and the first repair fixed
    ## only the denominator. The numerator went on using `delta_gradient()`, the
    ## gradient of the estimand along a parametric family of covariate laws, which
    ## belonged to the second prediction and was withdrawn with it. What the
    ## published methods actually omit is J' Omega J / nT with J the gradient of
    ## THE ESTIMATOR, which is what `maic_entropy` adds and what an interval
    ## therefore misses when it is left out.
    ##
    ## The difference is not cosmetic. On the estimand gradient no curved-link
    ## cell in 528 cleared the floor and the whole registered grid collapsed onto
    ## the collapsible link, which would have been read as the study's premise
    ## being inverted. On the estimator gradient the curved links clear it.
    p1 <- parts[[1]]
    pr <- length(p1$mean)
    Om <- Omega_normal(p1$mean, p1$sd, diag(pr) * (1 - rho) + rho,
                       binary = p1$bin)
    v_omit <- as.numeric(t(Jbar) %*% Om %*% Jbar) / r$nT
    v_cross <- -2 * as.numeric(crossprod(Jbar, as.vector(stats::cov(M, tb))))
    total <- v_omit + v_src + v_bc + v_cross
    data.frame(cell_id = r$cell_id, link = r$link, nT = r$nT, nS = r$nS, k = r$k,
               shape = r$shape, corr_assumed = r$corr_assumed,
               modifier_span = r$modifier_span, anchored = r$anchored,
               baseline_shift = r$baseline_shift,
               v_omit = v_omit, v_src = v_src, v_bc = v_bc, v_cross = v_cross,
               share = if (is.finite(total) && total > 0) v_omit / total
                       else NA_real_,
               n_ok = n_ok, stringsAsFactors = FALSE)
  }))

  keep <- is.finite(shares$share) & shares$share >= MIN_OMITTED_SHARE
  n_bad <- sum(!is.finite(shares$share))
  if (n_bad) {
    cat(sprintf("\n%d cells produced no finite share; the first few:\n", n_bad))
    print(head(shares[!is.finite(shares$share),
                      c("link", "nT", "nS", "k", "shape", "n_ok")], 6),
          row.names = FALSE)
  }
  cat(sprintf("\nomitted-variance share: %.4f to %.4f\n",
              min(shares$share, na.rm = TRUE), max(shares$share, na.rm = TRUE)))
  cat(sprintf("floor solved from a %.3f coverage shift: %.4f\n",
              MIN_COVERAGE_SHIFT, MIN_OMITTED_SHARE))
  cat(sprintf("cells at or above it: %d of %d\n", sum(keep), nrow(shares)))
  cat("\nshare by link:\n")
  print(round(t(vapply(split(shares$share, shares$link), function(z)
    c(min = min(z, na.rm = TRUE), median = stats::median(z, na.rm = TRUE),
      max = max(z, na.rm = TRUE)), numeric(3))), 4))

  if (any(!keep)) {
    cat("\ncells below the floor, which are dropped rather than run:\n")
    print(head(shares[!keep, c("link", "nT", "nS", "k", "shape", "share")], 12),
          row.names = FALSE, digits = 3)
  }

  dir.create("results", showWarnings = FALSE)
  p$N_CELLS <- list(sum(keep))
  p$P2_table <- list(shares)
  p$P2_grid <- list(g[keep, ])
  p$P2_min_share <- list(MIN_OMITTED_SHARE)
  p$P2_min_shift <- list(MIN_COVERAGE_SHIFT)
  saveRDS(p, PROBE_FILE)
  cat(sprintf("\nregistered cell count: %d\nwritten: %s\n", sum(keep), PROBE_FILE))
}

if (!interactive() && Sys.getenv("P2_NOMAIN") == "") main()
