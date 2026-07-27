## Run the design.
##
##   Rscript R/04-run.R          full design
##   Rscript R/04-run.R --pilot  a small subset, to check the design is usable

.f <- grep("^--file=", commandArgs(FALSE), value = TRUE)
STUDY <- if (length(.f)) {
  dirname(dirname(normalizePath(sub("^--file=", "", .f[1]))))
} else normalizePath(".")
here <- function(...) file.path(STUDY, ...)
stopifnot(file.exists(here("R", "00-config.R")))

source(here("R", "01-dgm.R"))
source(here("R", "02-estimators.R"))
source(here("R", "03-diagnostics.R"))
source(here("R", "00-config.R"))
source(here("..", "_shared", "R", "harness.R"))

PILOT <- "--pilot" %in% commandArgs(TRUE)
OUTDIR <- here(if (PILOT) "results/pilot" else "results")
dir.create(file.path(OUTDIR, "raw"), recursive = TRUE, showWarnings = FALSE)

one_rep <- function(scen, rep_id) {
  rd <- gen_replicate(scen)
  s <- rd$source
  ghat <- source_interactions(s$X, s$A, s$Y)
  ones <- rep(1, s$n)
  zq <- stats::qnorm(1 - (1 - HARM$level) / 2)

  fits <- list(maic = est_maic(rd, CONVERGENCE),
               stc = est_stc(rd),
               unadj = est_unadj(rd))

  rows <- list()
  for (m in names(fits)) {
    f <- fits[[m]]
    if (!isTRUE(f$ok)) {
      rows[[m]] <- data.frame(method = m, fitted = FALSE, why = f$why %||% "fail",
                              stringsAsFactors = FALSE)
      next
    }
    w <- if (m == "maic") f$w else ones
    rx4 <- residual_x4(m, s$X, w, rd$target$mean)
    dg <- diagnostics_for(m, rd, w, rx4, ghat,
                          extra = list(
                            lambda_norm = if (m == "maic") sqrt(sum(f$fit$lambda^2)) else NA_real_,
                            r2 = if (m == "stc") f$r2 else NA_real_,
                            orc_cross = oracle_cross(m, s$X, w, rd$target$mean,
                                                     scen$joint, rd$truth$target_cross)))

    dec <- decompose(f$lin, rd, scen)
    err <- f$est - rd$truth$theta_AC
    se <- if (is.finite(f$var) && f$var > 0) sqrt(f$var) else NA_real_

    ## The anchored contrast, which is what a submission reports.
    est_ab <- f$est - rd$target$theta_BC
    truth_ab <- rd$truth$theta_AC - rd$truth$theta_BC
    se_ab <- if (is.na(se)) NA_real_ else sqrt(f$var + rd$target$var_BC)

    rows[[m]] <- data.frame(
      method = m, fitted = TRUE, why = NA_character_,
      est = f$est, se = se, err = err,
      arm_imbalance = dec[["arm_imbalance"]],
      transport = dec[["transport"]],
      noise = dec[["noise"]],
      covered = !is.na(se) && abs(err) <= zq * se,
      err_anchored = est_ab - truth_ab,
      covered_anchored = !is.na(se_ab) && abs(est_ab - truth_ab) <= zq * se_ab,
      ## A confident claim of superiority that points the wrong way.
      wrong_side = !is.na(se_ab) &&
        stats::pnorm(abs(est_ab) / se_ab) >= HARM$confident &&
        sign(est_ab) != sign(truth_ab),
      as.data.frame(as.list(dg)),
      stringsAsFactors = FALSE)
  }
  do.call(rbind, lapply(rows, function(r) {
    miss <- setdiff(unique(unlist(lapply(rows, names))), names(r))
    for (k in miss) r[[k]] <- NA
    r[unique(unlist(lapply(rows, names)))]
  }))
}

scenarios <- build_scenarios()
n_rep <- N_REP
if (PILOT) {
  ## The corners: both bias channels on and off, both extremes of overlap, both
  ## sample sizes. Enough to check that the material-error rate is not pinned at
  ## zero or one, that MAIC converges, and that a correctly specified MAIC covers
  ## at nominal where it should.
  keep <- with(scenarios, overlap %in% c(0.25, 1.25) & rho4 == 0 &
                 n_arm == 150L & sd_target %in% c(1, 1.25))
  ## Scenario ids are NOT renumbered, so a pilot row still identifies the cell it
  ## came from in the full design and the analysis can be exercised on it.
  scenarios <- scenarios[keep, ]
  n_rep <- 500L
}

res <- run_design(one_rep, scenarios, n_rep = n_rep, master_seed = MASTER_SEED,
                  outdir = OUTDIR)

if (!PILOT) {
  write_provenance(
    OUTDIR, packages = c("stats", "future", "furrr"),
    extra = list(study = "DIA-03 diagnostics as classifiers of realized error",
                 scenarios = nrow(scenarios), replicates_per_scenario = n_rep,
                 methods = 3, master_seed = MASTER_SEED))
}

cat(sprintf("\n%d rows, %d scenarios x %d replicates x 3 methods\n",
            nrow(res), nrow(scenarios), n_rep))
