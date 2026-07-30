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

N_CAL_REP <- 20L    # replicates per cell, only to fix the source variance
## A cell is worth running when the omitted variance is a large enough share of
## the total that 2000 replicates can resolve the coverage difference it causes.
## Coverage MCSE at 0.95 is 0.005, so a coverage shift of about 0.01 is the
## smallest thing worth claiming; that corresponds to a variance share of roughly
## 4%, which is the registered floor. It is derived here rather than typed.
MIN_OMITTED_SHARE <- 0.04

## The realized grid, built by the rule DESIGN.md section 4 states: the first
## four factors fully crossed within each link, the last three crossed with k and
## nT at the middle level of the others.
build_grid <- function() {
  core <- expand.grid(link = LEVELS$link, nT = LEVELS$nT, k = LEVELS$k,
                      shape = GRID_MIDDLE$shape,
                      corr_assumed = GRID_MIDDLE$corr_assumed,
                      modifier_span = GRID_MIDDLE$modifier_span,
                      KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  extra <- do.call(rbind, lapply(
    c("shape", "corr_assumed", "modifier_span"), function(f) {
      lv <- setdiff(LEVELS[[f]], GRID_MIDDLE[[f]])
      g <- expand.grid(link = LEVELS$link, nT = LEVELS$nT, k = LEVELS$k,
                       shape = GRID_MIDDLE$shape,
                       corr_assumed = GRID_MIDDLE$corr_assumed,
                       modifier_span = GRID_MIDDLE$modifier_span,
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
  pm <- population_means()

  shares <- do.call(rbind, lapply(seq_len(nrow(g)), function(i) {
    r <- g[i, ]
    pars <- make_pars(r$k, modifier_span = r$modifier_span)
    ## The omitted variance, from the estimand gradient. `modifier_span` can
    ## lengthen the covariate vector, so the moments are rebuilt per cell.
    pp <- length(pars$beta_em)
    mu_T <- rep(OVERLAP_SMD, pp); sg <- rep(1, pp)
    Jt <- delta_gradient(mu_T, sg, pars, r$link, r$shape, rho, ord)
    ## The binary index must come from the same law the moments do, or the
    ## reconstruction and the gradient are built on different moment vectors.
    bx <- binary_cols(covariate_law(r$shape, 64L, mu_T, sg, rho))
    Om <- Omega_normal(mu_T, sg, diag(pp) * (1 - rho) + rho, binary = bx)
    Jt <- Jt[c(rep(TRUE, pp), !bx)]
    v_omit <- as.numeric(t(Jt) %*% Om %*% Jt) / r$nT

    ## The retained source variance, from the sandwich on a few replicates.
    vs <- vapply(seq_len(N_CAL_REP), function(q) {
      d <- sample_replicate(LEVELS$nS, r$nT, r$k, r$link, r$shape, rho,
                            modifier_span = r$modifier_span)
      eg <- estimator_gradient(d, r$link)
      if (!isTRUE(eg$ok)) return(NA_real_)
      aI <- as.vector(crossprod(eg$parts$cvec, eg$Ainv))
      as.numeric(aI %*% eg$parts$B %*% aI) / eg$parts$n
    }, 0)
    v_src <- mean(vs, na.rm = TRUE)
    data.frame(cell_id = r$cell_id, link = r$link, nT = r$nT, k = r$k,
               shape = r$shape, corr_assumed = r$corr_assumed,
               modifier_span = r$modifier_span,
               v_omit = v_omit, v_src = v_src,
               share = v_omit / (v_omit + v_src),
               n_ok = sum(is.finite(vs)), stringsAsFactors = FALSE)
  }))

  keep <- is.finite(shares$share) & shares$share >= MIN_OMITTED_SHARE
  n_bad <- sum(!is.finite(shares$share))
  if (n_bad) {
    cat(sprintf("\n%d cells produced no finite share; the first few:\n", n_bad))
    print(head(shares[!is.finite(shares$share),
                      c("link", "nT", "k", "shape", "n_ok")], 6),
          row.names = FALSE)
  }
  cat(sprintf("\nomitted-variance share: %.4f to %.4f\n",
              min(shares$share, na.rm = TRUE), max(shares$share, na.rm = TRUE)))
  cat(sprintf("cells at or above the %.0f%% floor: %d of %d\n",
              100 * MIN_OMITTED_SHARE, sum(keep), nrow(shares)))
  cat("\nshare by link:\n")
  print(round(t(vapply(split(shares$share, shares$link), function(z)
    c(min = min(z, na.rm = TRUE), median = stats::median(z, na.rm = TRUE),
      max = max(z, na.rm = TRUE)), numeric(3))), 4))

  if (any(!keep)) {
    cat("\ncells below the floor, which are dropped rather than run:\n")
    print(head(shares[!keep, c("link", "nT", "k", "shape", "share")], 12),
          row.names = FALSE, digits = 3)
  }

  dir.create("results", showWarnings = FALSE)
  p$N_CELLS <- list(sum(keep))
  p$P2_table <- list(shares)
  p$P2_grid <- list(g[keep, ])
  p$P2_min_share <- list(MIN_OMITTED_SHARE)
  saveRDS(p, PROBE_FILE)
  cat(sprintf("\nregistered cell count: %d\nwritten: %s\n", sum(keep), PROBE_FILE))
}

if (!interactive() && Sys.getenv("P2_NOMAIN") == "") main()
