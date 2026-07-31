## ---------------------------------------------------------------------------
## Export every number the protocol will quote, before the protocol exists.
##
## CMP-14 spent thirteen rounds of critique and roughly a third of its findings
## were one defect: a number typed into the document instead of read from the
## code. The fix that finally worked was this file plus a verifier, and both were
## added late. Here they come BEFORE the document, so there is no window in which
## a number can be typed.
##
## THE PROBE OUTPUTS ARE MANDATORY. `probes_done()` stops the export if any probe
## has not run, because a protocol quoting a placeholder is worse than one
## quoting nothing.
##
##   Rscript R/12-export.R
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(jsonlite))
source("R/05-estimators.R")

## Every artifact the export reads, listed rather than discovered, so a missing
## one stops the run instead of silently removing a number and its assertion.
REQUIRED <- c("results/probes.rds")

main <- function() {
  missing <- REQUIRED[!file.exists(REQUIRED)]
  if (length(missing))
    stop("the export is missing artifacts the protocol will quote:\n  ",
         paste(missing, collapse = "\n  "))

  ## EVERY ARTIFACT MUST BE NEWER THAN THE CODE THAT PRODUCES IT. CMP-14 found
  ## E2 reported from a run predating an arm-count change, and nothing noticed
  ## because the verifier checked the document against the export and the smoke
  ## test checked the shape of what was there. This file is excluded from its own
  ## check for the reason CMP-14 settled on: it consumes artifacts rather than
  ## producing them, so editing it cannot invalidate one.
  code <- setdiff(list.files("R", full.names = TRUE), "R/12-export.R")
  newest <- max(file.info(code)$mtime)
  ages <- file.info(REQUIRED)$mtime
  stale <- REQUIRED[ages < newest]
  if (length(stale))
    stop("these artifacts predate the code that produces them:\n  ",
         paste(stale, collapse = "\n  "),
         "\nRerun the probes in R/01, R/02, R/03, R/10 and R/11.")

  p <- load_probes()
  probes_done(need = c("QUAD_ORDER", "N_CELLS", "P3_MAX_REL_ERR", "SEC_PER_REP"))

  out <- list()

  ## --- the registered configuration, straight from R/00-config.R ------------
  out$links <- LINKS
  out$estimands <- ESTIMANDS
  out$levels <- lapply(LEVELS, function(z) z)
  out$grid_middle <- GRID_MIDDLE
  out$n_covariate <- N_COVARIATE
  out$overlap_smd <- OVERLAP_SMD
  out$n_rep <- N_REP
  out$coverage_mcse_target <- COVERAGE_MCSE_TARGET
  ## The error the registered replicate count DELIVERS, which is what any claim
  ## about resolving a coverage difference is judged against. The target above is
  ## a design input and is not the same number.
  out$coverage_mcse_at_n <- signif(COVERAGE_MCSE_AT_N, 4)
  out$nominal <- NOMINAL
  out$cover_band <- COVER_BAND
  out$quad_tol <- QUAD_TOL
  out$n_perturb <- N_PERTURB
  out$crn_blocks <- CRN_BLOCKS

  ## --- P1: the integration order, and what forced it ------------------------
  out$quad_order <- p$QUAD_ORDER[[1]]
  p1 <- p$P1_table[[1]]
  out$p1_by_cell <- lapply(seq_len(nrow(p1)), function(i) as.list(p1[i, ]))
  ## Figures the protocol quotes about the reduction, DERIVED rather than typed.
  ## Round 1 found the generator typing 5,308,416, the order range and the
  ## agreement tolerance, while the document claimed no number was typed.
  out$nodes_product_3d <- p$QUAD_ORDER[[1]]^3
  out$nodes_product_4d <- p$QUAD_ORDER[[1]]^4
  out$continuous_order_range <- {
    z <- p$P1_table[[1]]
    o <- z$stable_order[z$shape != "mixed"]
    list(min = min(o, na.rm = TRUE), max = max(o, na.rm = TRUE))
  }
  ## The reduction's agreement with the product rule, measured here rather than
  ## remembered from a console session.
  out$reduction_agreement <- {
    pars <- list(alpha = -0.8, beta_prog = c(0.4, 0.3, 0.2),
                 tau0 = 0.5, beta_em = c(0.6, 0, 0))
    mu <- rep(OVERLAP_SMD, 3); sg <- rep(1, 3); rho <- 0.3
    ord <- p$QUAD_ORDER[[1]]
    a <- delta_superpopulation_normal(pars, "logit", mu, sg, rho, ord)
    b <- local({
      f <- get("delta_superpopulation")
      ## Force the product path by calling it on a shape that does not reduce,
      ## with an identical law: `lognormal` differs, so the product rule is
      ## exercised through the internal branch instead.
      gh <- gh_rule(ord); pnum <- 3
      idx <- as.matrix(expand.grid(rep(list(seq_len(ord)), pnum)))
      R <- matrix(rho, pnum, pnum); diag(R) <- 1
      L <- chol(diag(sg, pnum) %*% R %*% diag(sg, pnum))
      z <- sqrt(2) * gh$x[idx]; dim(z) <- dim(idx)
      w <- apply(matrix(gh$w[idx], nrow(idx), pnum), 1, prod) / (pi^(pnum / 2))
      xs <- sweep(z %*% L, 2, mu, "+")
      cm <- conditional_means(xs, pars, "logit")
      delta_from_arm_means(sum(w * cm$mu0), sum(w * cm$mu1), "logit")
    })
    signif(abs(a - b), 3)
  }

  ## The independent Monte Carlo check, so the protocol quotes a measurement.
  if (!is.null(p$P1_mc_check)) {
    mc <- p$P1_mc_check[[1]]
    out$p1_mc_check <- list(link = mc$link, shape = mc$shape, order = mc$order,
                            quad = signif(mc$quad, 8), mc = signif(mc$mc, 8),
                            mc_se = signif(mc$mc_se, 3), z = signif(mc$z, 3),
                            ok = mc$ok)
  }

  out$p1_forced_by <- {
    w <- p1[which.max(p1$stable_order), ]
    list(link = w$link, shape = w$shape, order = w$stable_order)
  }

  ## --- P2: the grid, and the cells it dropped -------------------------------
  out$n_cells <- p$N_CELLS[[1]]
  out$min_omitted_share <- p$P2_min_share[[1]]
  ## The criterion the floor was solved from, so the protocol can state the
  ## derivation rather than assert it.
  out$min_coverage_shift <- p$P2_min_shift[[1]]
  ## P6: the cross-covariance no published method carries.
  out$p6_ok <- p$P6_ok[[1]]
  out$p6_worst_share <- signif(p$P6_worst_share[[1]], 3)
  p6 <- p$P6_table[[1]]
  out$p6_by_cell <- lapply(seq_len(nrow(p6)), function(i)
    lapply(p6[i, ], function(z) if (is.numeric(z)) signif(z, 4) else z))
  p2 <- p$P2_table[[1]]
  out$n_cells_realized <- nrow(p2)
  ## The growth-ladder cells, retained below the floor so prediction 1 can be
  ## tested at target sizes where the effect is small by construction.
  if (!is.null(p2$ladder))
    out$n_ladder <- sum(p2$ladder &
                        p2$cell_id %in% p$P2_grid[[1]]$cell_id, na.rm = TRUE)
  out$omitted_share_by_link <- lapply(split(p2$share, p2$link), function(z)
    list(min = signif(min(z, na.rm = TRUE), 3),
         median = signif(stats::median(z, na.rm = TRUE), 3),
         max = signif(max(z, na.rm = TRUE), 3)))
  out$cells_by_source <- as.list(table(p$P2_grid[[1]]$nS))

  ## --- P3: the study's central defect, measured -----------------------------
  p3 <- p$P3_table[[1]]
  out$p3_identity_ok <- p$P3_identity_ok[[1]]
  out$p3_headline_survives <- p$P3_headline_survives[[1]]
  out$p3_max_rel_err <- signif(p$P3_MAX_REL_ERR[[1]], 3)
  cur <- p3[p3$link != "identity", ]
  out$p3_variance_ratio <- list(min = signif(min(cur$v_ratio), 4),
                                max = signif(max(cur$v_ratio), 4))
  out$p3_by_link <- lapply(split(cur, cur$link), function(z)
    list(link = z$link[1],
         max_rel_gap = signif(max(z$rel_gap), 3),
         v_ratio_min = signif(min(z$v_ratio), 4),
         v_ratio_max = signif(max(z$v_ratio), 4),
         ## Which direction the ported interval errs, which differs by link and
         ## is the finding no part of the design predicted.
         direction = if (min(z$v_ratio) > 1) "anti-conservative"
                     else if (max(z$v_ratio) < 1) "conservative"
                     else "mixed"))
  out$p3_identity_convergence <-
    lapply(seq_len(nrow(p$P3_identity_convergence[[1]])), function(i)
      as.list(p$P3_identity_convergence[[1]][i, ]))

  ## --- P7: the null control, in the only form that is true ------------------
  if (!is.null(p$P7_table)) {
    p7 <- p$P7_table[[1]]
    out$p7_ok <- p$P7_ok[[1]]
    out$p7_by_link <- lapply(seq_len(nrow(p7)), function(i)
      lapply(p7[i, ], function(z) if (is.numeric(z)) signif(z, 4) else z))
  }

  ## The gate's variance decomposition, so the protocol can show that the
  ## denominator is the whole variance rather than assert it.
  if (!is.null(p2$v_bc)) {
    out$gate_terms <- list(
      v_omit  = signif(stats::median(p2$v_omit, na.rm = TRUE), 4),
      v_src   = signif(stats::median(p2$v_src, na.rm = TRUE), 4),
      v_bc    = signif(stats::median(p2$v_bc, na.rm = TRUE), 4),
      v_cross = signif(stats::median(p2$v_cross, na.rm = TRUE), 4))
  }

  ## --- P4 and P5: the budget, and the constant that governs it --------------
  out$sec_per_rep <- signif(p$SEC_PER_REP[[1]], 3)
  p4 <- p$P4_table[[1]]
  out$p4_by_config <- lapply(seq_len(nrow(p4)), function(i)
    lapply(p4[i, ], function(z) if (is.numeric(z)) signif(z, 4) else z))
  out$perturb_share <- list(min = signif(min(p4$perturb_share), 3),
                            max = signif(max(p4$perturb_share), 3))
  ## THE MEASUREMENT IS AT WHATEVER N_PERTURB IS REGISTERED NOW, not at the value
  ## it once had. An earlier version of this block named the field
  ## `core_hours_at_200` and then scaled it by 50/200 again, reporting 4.65 for a
  ## study that costs 18.6: it discounted a measurement that already carried the
  ## discount. The field is named for what it is, and the comparison figure is
  ## labelled as the historical one it is.
  out$core_hours <- signif(p$P4_core_hours_maic_stc[[1]], 4)
  out$core_hours_n_perturb <- N_PERTURB
  if (!is.null(p$N_PERTURB_NEEDED)) {
    out$n_perturb_needed <- p$N_PERTURB_NEEDED[[1]]
    out$p5_spread <- signif(p$P5_spread[[1]], 4)
    p5 <- p$P5_table[[1]]
    out$p5_by_b <- lapply(seq_len(nrow(p5)), function(i)
      lapply(p5[i, ], function(z) if (is.numeric(z)) signif(z, 4) else z))
    ## The saving the derived constant bought, from the two MEASUREMENTS rather
    ## than from scaling one of them. 102.6 core-hours was measured at the typed
    ## 200 before P5 ran; it is carried as a historical figure and is the only
    ## number here that is not recomputed on every export.
    ## THE COST WENT UP, NOT DOWN, and the field is named for that. 102.6
    ## core-hours was measured when B was typed at 200 and the grid was smaller;
    ## sizing B honestly took it to 800 and the corrected mixed arm added cells.
    ## An earlier version of this block computed a "saving" from those two
    ## figures, which after the resizing evaluated to -124 percent: a saving of
    ## minus one hundred and twenty four percent is not a saving, and a document
    ## that phrases it as one is telling the reader the opposite of what happened.
    out$core_hours_at_typed_200 <- 102.6
    out$budget_change_pct <-
      signif(100 * (out$core_hours / out$core_hours_at_typed_200 - 1), 3)
  }

  dir.create("results", showWarnings = FALSE)
  writeLines(toJSON(out, auto_unbox = TRUE, digits = 8, null = "null"),
             "results/registered-design.json")
  cat("written: results/registered-design.json\n")
  cat(sprintf("exported %d top-level keys\n", length(out)))
}

if (!interactive() && Sys.getenv("EXPORT_NOMAIN") == "") main()
