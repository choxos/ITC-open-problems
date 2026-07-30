## ---------------------------------------------------------------------------
## PROBE P4: the measured unit cost, and the only budget total this study will
## quote.
##
## DESIGN.md section 11 refuses to name a total before this runs: "A budget total
## that does not follow from a measured unit cost has produced two fatal findings
## in this program and both were quoted the same way." So the number below is
## computed from a timed run at production settings and is never typed.
##
## The line item to watch is the perturbation interval, which multiplies its arm
## by `N_PERTURB` resamples. DESIGN.md section 11 names it as "the line item
## OUT-11 called cheap without measuring and which then dominated its run".
##
##   Rscript R/10-budget.R
## ---------------------------------------------------------------------------

source("R/05-estimators.R")

N_TIME_REP <- 12L   # timed replicates per configuration

main <- function() {
  p <- load_probes()
  stopifnot("probes P1 and P2 must run first" =
              !is.null(p) && is.finite(p$QUAD_ORDER[[1]]) &&
              is.finite(p$N_CELLS[[1]]))
  grid <- p$P2_grid[[1]]
  n_cells <- p$N_CELLS[[1]]

  ## Cost varies most with the source size, because the weight fit and every
  ## resample scale with it. Timing the cheapest and dearest source bounds the
  ## total rather than pretending one figure covers the grid.
  cfgs <- expand.grid(nS = LEVELS$nS, link = c("logit", "cloglog"),
                      stringsAsFactors = FALSE)
  set.seed(MASTER_SEED)

  res <- do.call(rbind, lapply(seq_len(nrow(cfgs)), function(i) {
    cf <- cfgs[i, ]
    t_all <- t_nopert <- numeric(N_TIME_REP)
    for (r in seq_len(N_TIME_REP)) {
      d <- sample_replicate(cf$nS, 300L, 0.25, cf$link, "mvnorm", 0.3)
      t0 <- proc.time(); invisible(estimate_all(d, cf$link, "borrowed"))
      t_all[r] <- (proc.time() - t0)[["elapsed"]]
      ## The same replicate without the resampling arm, so the perturbation
      ## interval's share is measured rather than inferred by subtraction from a
      ## different draw.
      t0 <- proc.time()
      invisible(maic_all_no_perturb(d, cf$link, "borrowed"))
      invisible(stc_estimate(d, cf$link))
      t_nopert[r] <- (proc.time() - t0)[["elapsed"]]
    }
    data.frame(nS = cf$nS, link = cf$link,
               sec_per_rep = mean(t_all),
               sec_without_perturb = mean(t_nopert),
               perturb_share = 1 - mean(t_nopert) / mean(t_all),
               stringsAsFactors = FALSE)
  }))

  cat("=== P4: measured unit cost at production settings ===\n")
  print(res, row.names = FALSE, digits = 4)

  ## The grid's own composition decides the total: each cell runs N_REP
  ## replicates at its own source size.
  per_ns <- tapply(res$sec_per_rep, res$nS, mean)
  cell_ns <- table(grid$nS)
  total_sec <- sum(vapply(names(cell_ns), function(k)
    as.numeric(cell_ns[[k]]) * N_REP * per_ns[[k]], 0))

  cat(sprintf("\ncells: %d, replicates per cell: %d\n", n_cells, N_REP))
  cat("cells by source size:\n"); print(cell_ns)
  cat(sprintf("\nMAIC and STC arms: %.1f core-hours\n", total_sec / 3600))
  cat(sprintf("perturbation interval is %.0f%% to %.0f%% of that\n",
              100 * min(res$perturb_share), 100 * max(res$perturb_share)))
  cat("\nML-NMR is NOT in this total. It needs Stan, its cost dominates, and\n",
      "DESIGN.md section 11 names it as the reason the grid is restricted\n",
      "rather than fully crossed. It is budgeted separately once its per-fit\n",
      "cost is measured, and no total covering it is quoted until then.\n",
      sep = "")

  p$SEC_PER_REP <- list(mean(res$sec_per_rep))
  p$P4_table <- list(res)
  p$P4_core_hours_maic_stc <- list(total_sec / 3600)
  saveRDS(p, PROBE_FILE)
  cat(sprintf("\nwritten: %s\n", PROBE_FILE))
}

## The MAIC variants without the resampling arm, so its cost is isolated on the
## same replicate rather than across draws.
maic_all_no_perturb <- function(rep_data, link, corr_setting, level = 0.95) {
  old <- N_PERTURB
  assign("N_PERTURB", 0L, envir = globalenv())
  on.exit(assign("N_PERTURB", old, envir = globalenv()), add = TRUE)
  s <- rep_data$source; tr <- rep_data$target_reported
  eg <- estimator_gradient(rep_data, link)
  if (!isTRUE(eg$ok)) return(invisible(NULL))
  sp <- eg$parts
  aI <- as.vector(crossprod(sp$cvec, eg$Ainv))
  V_S <- as.numeric(aI %*% sp$B %*% aI) / sp$n
  R_use <- assumed_R(corr_setting, rep_data, ncol(s$x))
  Om <- Omega_normal(tr$mean, tr$sd, R_use, binary = tr$binary)
  invisible(as.numeric(eg$J %*% Om %*% eg$J) / tr$nT + V_S)
}

if (!interactive() && Sys.getenv("P4_NOMAIN") == "") main()
