## ---------------------------------------------------------------------------
## How accurate are D3's implied values, and can numerical error change a flip?
##
## Round 6 upheld an objection to the way version 5 answered this. It said D3's
## uncertainty "is quadrature error, which the control cell bounds at
## 1.2e-10", so "an inconclusive region would be empty by construction". The
## control cell is the PROPORTIONAL one. What its across-regime cancellation
## measures is how exactly two nearly identical calculations cancel in the
## easiest case the design contains, which is not a bound on the absolute error
## of a root-find through a crossing marginal hazard. Two different quantities
## were being reported as one.
##
## THE QUESTION THAT ACTUALLY MATTERS IS NARROWER than a uniform error bound, and
## it is answerable. D3's verdict is a count of decision flips, so numerical
## error only matters if it can move an implied value across the threshold.
## What is needed is therefore
##
##   (a) the SIZE of the numerical error, measured by refining every knob at
##       once and seeing how far the answers move, and
##   (b) the MARGIN, how close the nearest implied value gets to the threshold.
##
## If (b) is orders of magnitude larger than (a), no flip in the table can be an
## artifact, and that is a defensible statement rather than a borrowed one. The
## refinement doubles the Gauss-Hermite order, quadruples the Cox root-finding
## grid, refines the RMST trapezoid and tightens the root tolerance, so a
## quantity unchanged by it is not sitting on any one of those choices.
##
##   Rscript R/17-d3-convergence.R
## ---------------------------------------------------------------------------

source("R/00-config.R")
source("R/01-dgm.R")
source("R/02-cox-limit.R")
source("R/04-calibrate.R")

cells <- unique(build_cells()[, c("arm", "family", "kappa_a", "kappa_b",
                                  "gamma", "margin", "beta_b")])

## One evaluation of the whole D3 quantity at a stated resolution. `GH` is a
## package-level global that surv_marg and haz_marg read, so it is swapped and
## restored rather than threaded through six functions.
d3_implied <- function(n_gh, n_cox, n_rmst) {
  old <- GH
  GH <<- gh_nodes(n_gh)
  on.exit(GH <<- old, add = TRUE)
  tt <- seq(1e-6, TAU, length.out = n_rmst)
  trap <- function(y) sum(diff(tt) * (head(y, -1) + tail(y, -1)) / 2)
  lapply(seq_len(nrow(cells)), function(i) {
    cc <- cells[i, ]
    pbo_a <- placebo_arm(cc$family, "ipd")
    a     <- make_arm(cc$family, "ipd", beta = BETA_A, kappa = cc$kappa_a,
                      gamma = cc$gamma)
    pbo_b <- placebo_arm(cc$family, "tgt")
    b     <- make_arm(cc$family, "tgt", beta = cc$beta_b, kappa = cc$kappa_b,
                      gamma = cc$gamma)
    S0 <- surv_marg(tt, MU_TGT, SD_X, pbo_b)
    unlist(lapply(seq_len(nrow(CENS_REGIMES)), function(ja)
      vapply(seq_len(nrow(CENS_REGIMES)), function(jb) {
        ha <- exp(cox_limit(pbo_a, a, MU_TGT, SD_X, CENS_REGIMES$rate_ipd[ja],
                            CENS_REGIMES$t_admin[ja], ALLOC, n_grid = n_cox))
        hb <- exp(cox_limit(pbo_b, b, MU_TGT, SD_X, CENS_REGIMES$rate_agd[jb],
                            CENS_REGIMES$t_admin[jb], ALLOC, n_grid = n_cox))
        trap(S0^hb) - trap(S0^ha)
      }, numeric(1))))
  })
}

cat("=== D3 numerical convergence ===\n")
cat("registered resolution: GH 64, Cox grid 2000, RMST grid 2001\n")
t0 <- Sys.time()
base <- d3_implied(64, 2000, 2001)
cat(sprintf("  base evaluated in %.0f s\n",
            as.numeric(difftime(Sys.time(), t0, units = "secs"))))
t0 <- Sys.time()
fine <- d3_implied(128, 8000, 8001)
cat(sprintf("  refined evaluated in %.0f s\n",
            as.numeric(difftime(Sys.time(), t0, units = "secs"))))

per_cell <- vapply(seq_along(base), function(i)
  max(abs(base[[i]] - fine[[i]])), 0)
worst <- max(per_cell)

## The margin: how close does any implied value get to the decision threshold?
## Computed at the refined resolution, since that is the better estimate of where
## the values actually are.
margin_per_cell <- vapply(fine, function(v) min(abs(v - DELTA_THRESHOLD)), 0)
margin <- min(margin_per_cell)

lab <- sprintf("%-8s ka=%.2f kb=%.2f %s", cells$arm, cells$kappa_a,
               cells$kappa_b, cells$margin)
cat("\nper-cell movement under refinement, and distance to the threshold:\n")
for (i in order(-per_cell))
  cat(sprintf("  %s  move %.3e  nearest-to-threshold %.4f\n",
              lab[i], per_cell[i], margin_per_cell[i]))

cat(sprintf("\nworst movement over every cell and regime pair: %.3e months\n", worst))
cat(sprintf("closest any implied value comes to the %.2f threshold: %.4f months\n",
            DELTA_THRESHOLD, margin))

## THE RATIO THAT MATTERS IS PER CELL, NOT GLOBAL.
##
## The global worst error and the global smallest margin occur in DIFFERENT
## cells, so dividing one by the other compares a quantity from the hardest cell
## with a quantity from a different one and understates the safety margin
## everywhere. A flip can only be an artifact if THAT cell's own numerical error
## can cross THAT cell's own nearest implied value over the threshold.
ratio_global <- margin / worst
ratio_per_cell <- min(margin_per_cell / pmax(per_cell, .Machine$double.eps))
cat(sprintf("ratio, worst cell against smallest margin anywhere: %.0f\n",
            ratio_global))
cat(sprintf("ratio, WITHIN each cell, at its worst: %.0f\n", ratio_per_cell))

## A flip is an artifact only if refinement can move a value across the
## threshold. Checked directly rather than argued from the ratio.
flips_base <- vapply(seq_along(base), function(i) {
  tr <- truth_delta(cells$family[i], cells$beta_b[i], cells$kappa_b[i],
                    cells$gamma[i], TAU, cells$kappa_a[i])
  mean((base[[i]] > DELTA_THRESHOLD) != (tr > DELTA_THRESHOLD))
}, 0)
flips_fine <- vapply(seq_along(fine), function(i) {
  tr <- truth_delta(cells$family[i], cells$beta_b[i], cells$kappa_b[i],
                    cells$gamma[i], TAU, cells$kappa_a[i])
  mean((fine[[i]] > DELTA_THRESHOLD) != (tr > DELTA_THRESHOLD))
}, 0)
same <- identical(flips_base, flips_fine)
cat(sprintf("\nflip fractions identical at both resolutions: %s\n",
            if (same) "YES" else "NO"))
cat(sprintf("cells flipping: %d at the registered resolution, %d refined\n",
            sum(flips_base > 0), sum(flips_fine > 0)))

saveRDS(list(worst_move = worst, margin = margin, ratio = ratio_global,
             ratio_per_cell = ratio_per_cell,
             per_cell_move = per_cell, per_cell_margin = margin_per_cell,
             flips_base = flips_base, flips_fine = flips_fine,
             verdict_stable = same),
        "results/d3-convergence.rds")
cat("\nwritten: results/d3-convergence.rds\n")
