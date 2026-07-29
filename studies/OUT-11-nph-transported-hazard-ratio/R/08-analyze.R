## ---------------------------------------------------------------------------
## E3 analysis. Computes exactly the outcomes registered in protocol section
## 10.1 and nothing else.
##
## The registered primary is ESTIMATION quality compared PAIRED on the
## replicate, not decision quality. That is not a preference: versions 2 and 3
## both made a reimbursement decision primary and both failed. Version 3's rule
## was measured and a constant recommendation that ignores the data outscored
## every estimator, because per-replicate noise (0.70 to 0.87 months) dwarfs the
## decision margins (0.15 to 0.25 months). Decision loss survives here as a
## secondary appendix reported against both constant baselines, and it carries
## its own finding rather than a verdict.
##
## Pairing is the whole reason the registered contrasts are resolvable at 40
## replicates per cell: every estimator sees the same simulated network, so the
## between-replicate variation that swamps an unpaired comparison cancels.
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(survival))
source("R/04-calibrate.R")

ROWS <- c("MAIC-PH", "MAIC-flex", "STC-PH", "STC-flex", "MAIC-Cox",
          "MLNMR-PH", "MLNMR-flex")

## Reads the per-replicate checkpoints written by R/07-run.R and joins the two
## passes on (cell_id, rep). The passes are separate files because they run on
## different core budgets, but they analyze the SAME network: both regenerate it
## from net_seed(cell, rep), which is what keeps every estimator paired on the
## replicate even though nothing is passed between the passes.
##
## A replicate present in only one pass is kept, with the missing estimators
## recorded as NA rather than dropped, so a partially complete run is analyzable
## and a pass that failed is visible instead of silently shrinking the sample.
read_pass <- function(dir, tag) {
  fs <- list.files(dir, pattern = sprintf("^%s-\\d+-rep-\\d+\\.rds$", tag),
                   full.names = TRUE)
  out <- lapply(fs, function(f) { z <- readRDS(f)
    if (inherits(z, "try-error")) NULL else z })
  Filter(Negate(is.null), out)
}

load_cells <- function(dir = "results/cells") {
  fq <- read_pass(dir, "freq"); ml <- read_pass(dir, "mlnmr")
  if (!length(fq) && !length(ml)) stop("no replicate results in ", dir)
  key <- function(z) paste(z$cell$cell_id, z$rep)
  mlk <- setNames(ml, vapply(ml, key, ""))
  fqk <- setNames(fq, vapply(fq, key, ""))
  keys <- union(names(fqk), names(mlk))
  do.call(rbind, lapply(keys, function(k) {
    a <- fqk[[k]]; b <- mlk[[k]]
    cl <- if (!is.null(a)) a$cell else b$cell
    rp <- if (!is.null(a)) a$rep  else b$rep
    fr <- if (!is.null(a)) a$freq else NULL
    frn <- if (!is.null(fr)) names(fr$est) else ROWS[1:5]
    pick <- function(fld, obj) if (isTRUE(obj$ok)) obj[[fld]] else NA_real_
    grab <- function(fld) c(
      if (!is.null(fr)) fr[[fld]] else setNames(rep(NA_real_, 5), frn),
      `MLNMR-PH`   = if (is.null(b)) NA_real_ else pick(fld, b$mlnmr_ph),
      `MLNMR-flex` = if (is.null(b)) NA_real_ else pick(fld, b$mlnmr_flex))
    est <- grab("est"); lo <- grab("lo"); hi <- grab("hi")
    ## Effective degrees of freedom, registered in section 7.2 and recorded by
    ## nothing until round 6. Two different quantities by necessity: an exact
    ## free-parameter count on the maximum-likelihood side, p_WAIC on the
    ## Bayesian side, where a raw count would overstate a shrunk spline's real
    ## freedom by the amount this diagnostic is meant to measure. Both are
    ## carried, and the paper reports them as what they are rather than
    ## differencing them.
    edf <- c(if (!is.null(fr) && !is.null(fr$edf)) fr$edf
             else setNames(rep(NA_real_, length(frn)), frn),
             `MLNMR-PH`   = if (is.null(b) || !isTRUE(b$mlnmr_ph$ok)) NA_real_
                            else as.numeric(b$mlnmr_ph$diag$edf),
             `MLNMR-flex` = if (is.null(b) || !isTRUE(b$mlnmr_flex$ok)) NA_real_
                            else as.numeric(b$mlnmr_flex$diag$edf))
    ## Inner Monte Carlo error of the two interval endpoints, frequentist rows
    ## only; the Bayesian rows carry the posterior MCSE in their own diagnostics.
    mlo <- if (!is.null(fr) && !is.null(fr$mcse_lo)) fr$mcse_lo[, "rmst"]
           else setNames(rep(NA_real_, length(frn)), frn)
    mhi <- if (!is.null(fr) && !is.null(fr$mcse_hi)) fr$mcse_hi[, "rmst"]
           else setNames(rep(NA_real_, length(frn)), frn)
    mcse_lo <- c(mlo, `MLNMR-PH` = NA_real_, `MLNMR-flex` = NA_real_)
    mcse_hi <- c(mhi, `MLNMR-PH` = NA_real_, `MLNMR-flex` = NA_real_)
    truth <- truth_delta(cl$family, cl$beta_b, cl$kappa_b, cl$gamma, TAU, cl$kappa_a)
    data.frame(cell_id = cl$cell_id,
               ## The latent network's identity, which is what the Monte Carlo
               ## error must cluster on now that censoring regimes share one.
               param_id = if (is.null(cl$param_id)) NA_integer_ else cl$param_id,
               arm = cl$arm, family = cl$family,
               kappa_a = cl$kappa_a, kappa_b = cl$kappa_b, gamma = cl$gamma,
               margin = cl$margin, cens = cl$cens, rep = rp, truth = truth,
               estimator = names(est), est = as.numeric(est),
               lo = as.numeric(lo), hi = as.numeric(hi),
               edf = as.numeric(edf),
               mcse_lo = as.numeric(mcse_lo), mcse_hi = as.numeric(mcse_hi),
               ## Sampler pass flag: recorded for every fit, never used to
               ## silently drop one. The primary analysis is repeated on the
               ## all-passed subset and both are reported.
               passed = c(rep(TRUE, length(frn)),
                          !is.null(b) && isTRUE(b$mlnmr_ph$passed),
                          !is.null(b) && isTRUE(b$mlnmr_flex$passed)),
               ## Whether the registered refit escalation fired. Reported
               ## against the 20% budget cap rather than assumed.
               refit = c(rep(FALSE, length(frn)),
                         !is.null(b) && isTRUE(b$mlnmr_ph$refit),
                         !is.null(b) && isTRUE(b$mlnmr_flex$refit)),
               stringsAsFactors = FALSE)
  }))
}

## --- primary outcome 4: calibration over time --------------------------------
## Bias and pointwise 95% coverage of the target-standardized survival difference
## at t in T_GRID. Round 6 found this outcome had been registered since version 2
## and produced by nothing: the frequentist path computed the differences and
## discarded them in freq_boot, and the ML-NMR path predicted RMST only.
##
## The truth is the marginal survival difference in the TARGET population under
## the cell's own parameters, computed by quadrature, not simulated.
surv_truth <- function(cl, times = T_GRID) {
  a <- make_arm(cl$family, "tgt", beta = BETA_A,   kappa = cl$kappa_a, gamma = cl$gamma)
  b <- make_arm(cl$family, "tgt", beta = cl$beta_b, kappa = cl$kappa_b, gamma = cl$gamma)
  vapply(times, function(u) surv_marg(u, MU_TGT, SD_X, b) -
                            surv_marg(u, MU_TGT, SD_X, a), 0)
}

load_calibration <- function(dir = "results/cells") {
  fq <- read_pass(dir, "freq"); ml <- read_pass(dir, "mlnmr")
  key <- function(z) paste(z$cell$cell_id, z$rep)
  mlk <- setNames(ml, vapply(ml, key, "")); fqk <- setNames(fq, vapply(fq, key, ""))
  rows <- lapply(union(names(fqk), names(mlk)), function(k) {
    a <- fqk[[k]]; b <- mlk[[k]]
    cl <- if (!is.null(a)) a$cell else b$cell
    rp <- if (!is.null(a)) a$rep  else b$rep
    tr <- surv_truth(cl)
    out <- list()
    if (!is.null(a$freq$surv_est)) {
      m <- a$freq
      for (e in rownames(m$surv_est)) out[[length(out) + 1L]] <- data.frame(
        estimator = e, t = m$t_grid, truth = tr,
        est = as.numeric(m$surv_est[e, ]), lo = as.numeric(m$surv_lo[e, ]),
        hi = as.numeric(m$surv_hi[e, ]), stringsAsFactors = FALSE)
    }
    for (nm2 in c(`MLNMR-PH` = "mlnmr_ph", `MLNMR-flex` = "mlnmr_flex")) {
      z <- b[[nm2]]
      if (is.null(z) || !isTRUE(z$ok) || is.null(z$surv)) next
      out[[length(out) + 1L]] <- data.frame(
        estimator = names(which(c(`MLNMR-PH` = "mlnmr_ph",
                                  `MLNMR-flex` = "mlnmr_flex") == nm2)),
        t = z$surv$t_grid, truth = tr, est = as.numeric(z$surv$est),
        lo = as.numeric(z$surv$lo), hi = as.numeric(z$surv$hi),
        stringsAsFactors = FALSE)
    }
    if (!length(out)) return(NULL)
    cbind(cell_id = cl$cell_id,
          param_id = if (is.null(cl$param_id)) NA_integer_ else cl$param_id,
          arm = cl$arm, cens = cl$cens, rep = rp, do.call(rbind, out))
  })
  do.call(rbind, Filter(Negate(is.null), rows))
}

calibration_table <- function(cal) {
  if (is.null(cal) || !nrow(cal)) return(NULL)
  do.call(rbind, lapply(split(cal, list(cal$estimator, cal$t), drop = TRUE),
    function(g) data.frame(
      estimator = g$estimator[1], t = g$t[1], n = nrow(g),
      bias = mean(g$est - g$truth, na.rm = TRUE),
      mcse = cluster_se(g$est - g$truth, clust_of(g)),
      mcse_indep = sd(g$est - g$truth, na.rm = TRUE) / sqrt(sum(is.finite(g$est))),
      coverage = mean(g$lo <= g$truth & g$truth <= g$hi, na.rm = TRUE),
      cov_se = cluster_se(g$lo <= g$truth & g$truth <= g$hi, clust_of(g)),
      stringsAsFactors = FALSE)))
}

## --- the registered common Cox projection ------------------------------------
## Section 4 registers one prespecified functional applied to every method's
## fitted target curves, "so the constant summaries being compared are the same
## functional of different fits". Round 6 found it applied to nothing: cox_limit
## was only ever called on analytic arms. Each method now reports it, and the
## truth's own projection is computed the same way for comparison.
cox_truth <- function(cl) {
  a <- make_arm(cl$family, "tgt", beta = BETA_A,    kappa = cl$kappa_a, gamma = cl$gamma)
  b <- make_arm(cl$family, "tgt", beta = cl$beta_b, kappa = cl$kappa_b, gamma = cl$gamma)
  cox_limit(a, b, MU_TGT, SD_X, COX_PROJ_RATE, COX_PROJ_TADMIN)
}

load_cox <- function(dir = "results/cells") {
  fq <- read_pass(dir, "freq"); ml <- read_pass(dir, "mlnmr")
  key <- function(z) paste(z$cell$cell_id, z$rep)
  mlk <- setNames(ml, vapply(ml, key, "")); fqk <- setNames(fq, vapply(fq, key, ""))
  rows <- lapply(union(names(fqk), names(mlk)), function(k) {
    a <- fqk[[k]]; b <- mlk[[k]]
    cl <- if (!is.null(a)) a$cell else b$cell
    rp <- if (!is.null(a)) a$rep  else b$rep
    tr <- cox_truth(cl)
    e <- c(if (!is.null(a$freq$cox_est)) a$freq$cox_est else NULL,
           `MLNMR-PH`   = if (is.null(b)) NULL else b$mlnmr_ph$cox_hr,
           `MLNMR-flex` = if (is.null(b)) NULL else b$mlnmr_flex$cox_hr)
    if (!length(e)) return(NULL)
    data.frame(cell_id = cl$cell_id,
               param_id = if (is.null(cl$param_id)) NA_integer_ else cl$param_id,
               rep = rp, estimator = names(e), cox_hr = as.numeric(e),
               truth = tr, stringsAsFactors = FALSE)
  })
  do.call(rbind, Filter(Negate(is.null), rows))
}

cox_table <- function(cx) {
  if (is.null(cx) || !nrow(cx)) return(NULL)
  do.call(rbind, lapply(split(cx, cx$estimator), function(g) data.frame(
    estimator = g$estimator[1], n = sum(is.finite(g$cox_hr)),
    mean_log_hr = mean(g$cox_hr, na.rm = TRUE),
    truth_log_hr = mean(g$truth, na.rm = TRUE),
    bias = mean(g$cox_hr - g$truth, na.rm = TRUE),
    mcse = cluster_se(g$cox_hr - g$truth, paste(g$param_id, g$rep)),
    stringsAsFactors = FALSE)))
}

## --- primary outcome 1: deployment-weighted mean ABSOLUTE cell bias ----------
## Absolute and per-cell, because a pooled signed bias lets cells cancel, which
## round two identified and which the pilot then demonstrated.
##
## AND CORRECTED FOR ITS OWN MONTE CARLO FLOOR, which round five found and which
## is large enough to matter. A cell mean over n replicates with per-replicate SD
## sigma has standard error sigma/sqrt(n); at the registered sigma = 0.75 and
## n = 40 that is 0.119 months, and the expected ABSOLUTE value of a mean whose
## true bias is exactly zero is sigma sqrt(2/pi)/sqrt(n) = 0.095 months. Taking
## absolute values before averaging turns noise into apparent bias, and 0.095 is
## larger than the entire measured bias of the flexible rows in the pilot
## (0.043 to 0.046). Uncorrected, the statistic would report every estimator as
## biased and would rank them partly on their variance.
##
## The correction is the standard one: E[b_hat^2] = mu^2 + se^2, so mu^2 is
## estimated by b_hat^2 - se^2, floored at zero. Both the raw and the corrected
## statistic are reported, along with the floor itself, so the size of the
## adjustment is visible rather than buried.
bias_table <- function(d) {
  per <- do.call(rbind, lapply(split(d, list(d$estimator, d$cell_id), drop = TRUE),
    function(g) data.frame(estimator = g$estimator[1], cell_id = g$cell_id[1],
                           param_id = g$param_id[1],
                           bias = mean(g$est - g$truth),
                           se = sd(g$est - g$truth) / sqrt(sum(is.finite(g$est))),
                           stringsAsFactors = FALSE)))
  ## THE CORRECTION IS EXACT ON THE SQUARED SCALE AND NOT AFTER THE SQUARE ROOT.
  ##
  ## Round 5 found that mean absolute cell bias is inflated by its own Monte
  ## Carlo noise and version 5 answered with sqrt(max(0, b^2 - se^2)). Round 6
  ## found that this does not remove the floor: subtracting se^2 debiases b^2,
  ## but the square root is concave, so the result still has a positive
  ## expectation when the true bias is zero. Simulated at 4,000,000 draws under
  ## the protocol's own planning model, that expectation is 0.3431 se against a
  ## claimed 0.3426, which at se = 0.75/sqrt(40) leaves 0.0407 months. The
  ## flexible rows' pilot biases are 0.043 to 0.046. The "corrected" statistic
  ## was therefore still roughly the size of the effects it had to resolve, and
  ## would still have ranked estimators partly by their variance.
  ##
  ## E[b^2] = mu^2 + se^2 exactly, so b^2 - se^2 is an exactly unbiased estimate
  ## of mu^2 whatever mu is. The registered statistic is therefore the mean of
  ## that over cells: it is unbiased, it keeps the per-cell absolute treatment
  ## that stops cells cancelling, and it has no floor to correct. It can go
  ## negative when the true bias is near zero, which is a feature: a statistic
  ## that cannot go below zero cannot be unbiased at zero, and truncating it is
  ## what reintroduced the floor.
  ##
  ## The square root is reported alongside for interpretability, on the pooled
  ## value rather than per cell, and is explicitly a back-transform rather than
  ## the registered quantity.
  per$sq_debiased <- per$bias^2 - per$se^2
  out <- do.call(rbind, lapply(split(per, per$estimator), function(g) {
    msq <- mean(g$sq_debiased)
    data.frame(estimator = g$estimator[1],
               mean_sq_bias_debiased = msq,
               mean_abs_bias_backtransformed = sqrt(max(0, msq)),
               ## Reported so the size of what was removed stays visible.
               mean_abs_bias_raw = mean(abs(g$bias)),
               mc_floor_raw = mean(g$se) * sqrt(2 / pi),
               mc_floor_v5_correction = 0.3431 * mean(g$se),
               ## Cluster-aware across cells sharing a latent network.
               se_sq = cluster_se(g$sq_debiased,
                                  if (is.null(g$param_id)) NULL else g$param_id),
               stringsAsFactors = FALSE) }))
  rmse <- aggregate(cbind(rmse = (est - truth)^2) ~ estimator, d,
                    function(z) sqrt(mean(z)))
  merge(out, rmse, by = "estimator")
}

## --- primary outcome 2: coverage, with an explicit inconclusive verdict ------
## MONTE CARLO ERROR UNDER CLUSTERING ON THE LATENT NETWORK.
##
## Round 6 raised this as a direct consequence of the round-6 fix that gave E3
## genuine common random numbers across censoring regimes. Sharing one latent
## network across a parameter cell's two or three censoring conditions is what
## makes the censoring comparison paired, and it also means the 840
## condition-by-replicate rows are NOT 840 independent observations: they are
## 400 (parameter cell, replicate) blocks, with within-block covariance that an
## independent-binomial standard error ignores entirely.
##
## The direction is not knowable in advance. Positive within-block correlation
## inflates the true variance and the naive interval is too narrow; the pairing
## that the same seeding buys makes some contrasts more precise, not less. So it
## is estimated rather than assumed, with a cluster-robust sandwich over
## (param_id, rep). Both are reported, so the size of the correction is visible.
cluster_se <- function(y, cluster) {
  y <- as.numeric(y); ok <- is.finite(y)
  y <- y[ok]; cluster <- cluster[ok]
  n <- length(y)
  if (n < 2) return(NA_real_)
  if (is.null(cluster) || length(unique(cluster)) < 2)
    return(stats::sd(y) / sqrt(n))
  s <- vapply(split(y - mean(y), cluster), sum, 0)
  g <- length(s)
  sqrt(sum(s^2) * g / ((g - 1) * n^2))
}

## The block a row belongs to: one latent network, reused across the censoring
## regimes of its parameter cell.
clust_of <- function(d)
  if (is.null(d$param_id)) NULL else paste(d$param_id, d$rep)

coverage_table <- function(d, lo_ok = 0.90, hi_ok = 0.98) {
  cv <- aggregate(cbind(cov = truth >= lo & truth <= hi) ~ estimator, d, mean)
  n  <- aggregate(cbind(n = est) ~ estimator, d, length)
  m  <- merge(cv, n, by = "estimator")
  m$se_indep <- sqrt(m$cov * (1 - m$cov) / m$n)
  ## Cluster-robust is the registered one; the independent figure is kept beside
  ## it because the whole point is to show what the old assumption cost.
  m$se <- vapply(m$estimator, function(e) { g <- d[d$estimator == e, ]
    cluster_se(g$truth >= g$lo & g$truth <= g$hi, clust_of(g)) }, 0)
  m$se[!is.finite(m$se)] <- m$se_indep[!is.finite(m$se)]
  m$se_ratio <- m$se / m$se_indep
  m$ci_lo <- pmax(0, m$cov - 1.96 * m$se); m$ci_hi <- pmin(1, m$cov + 1.96 * m$se)
  m$verdict <- ifelse(m$ci_lo >= lo_ok & m$ci_hi <= hi_ok, "calibrated",
               ifelse(m$ci_hi < lo_ok | m$ci_lo > hi_ok, "miscalibrated",
                      "inconclusive"))
  m
}

## --- the registered contrasts, paired on the replicate ----------------------
## A paired difference between two estimators computed on the same networks.
## Its standard error is the SD of the within-replicate difference, which is far
## smaller than either estimator's own SD, and that is what makes these
## resolvable at this budget.
## cell_id identifies a cell-by-censoring ROW; param_id identifies the latent
## network shared across that cell's censoring regimes. The reshape below keeps
## cell_id, so the map is needed to recover the cluster.
paired_contrast <- function(d, a, b) {
  ## ONE ROW PER REGISTERED OUTCOME, NOT ONE ROW.
  ##
  ## Round 6 found that this function computed a paired difference in
  ## per-replicate ABSOLUTE ERROR, |est - truth|, and that this is none of the
  ## four registered primary outcomes: it mixes bias and variance, so a
  ## lower-variance estimator can beat a lower-bias one and the result would have
  ## been reported as a bias finding. Meanwhile bias, RMSE and coverage received
  ## no paired intervals at all, although the protocol says pairing is what makes
  ## the design resolvable at 40 replicates.
  ##
  ## Every registered outcome now gets its own paired contrast, on its own scale,
  ## with a cluster-aware standard error. The absolute-error contrast is kept
  ## because it is a legitimate summary and was what previous versions reported,
  ## but it is labeled as what it is and is not one of the four.
  w <- reshape(d[d$estimator %in% c(a, b),
                 c("cell_id", "param_id", "rep", "estimator", "est", "truth",
                   "lo", "hi")],
               idvar = c("cell_id", "param_id", "rep"), timevar = "estimator",
               direction = "wide")
  ea <- w[[paste0("est.", a)]]; eb <- w[[paste0("est.", b)]]
  tr <- w[[paste0("truth.", a)]]
  cl <- paste(w$param_id, w$rep)

  row <- function(outcome, dd, clu, note = "") {
    ok <- is.finite(dd); dd <- dd[ok]; clu <- clu[ok]
    if (!length(dd)) return(NULL)
    se_i <- stats::sd(dd) / sqrt(length(dd))
    se <- cluster_se(dd, clu); if (!is.finite(se)) se <- se_i
    data.frame(worse = a, better = b, outcome = outcome, n = length(dd),
               diff = mean(dd), se = se, se_indep = se_i,
               ci_lo = mean(dd) - 1.96 * se, ci_hi = mean(dd) + 1.96 * se,
               note = note, stringsAsFactors = FALSE)
  }

  ## Outcome 2, RMSE, on the squared scale where the paired difference is a
  ## proper estimate of the difference in mean squared error. Positive means b is
  ## better, matching the sign convention of every other row here.
  out <- list(row("mean_squared_error", (ea - tr)^2 - (eb - tr)^2, cl))

  ## Outcome 3, coverage of the nominal 95% interval, paired on the replicate.
  la <- w[[paste0("lo.", a)]]; ha <- w[[paste0("hi.", a)]]
  lb <- w[[paste0("lo.", b)]]; hb <- w[[paste0("hi.", b)]]
  cov_a <- as.numeric(la <= tr & tr <= ha); cov_b <- as.numeric(lb <= tr & tr <= hb)
  out[[length(out) + 1L]] <- row("coverage", cov_b - cov_a, cl)

  ## Outcome 1, bias, on the squared scale where its Monte Carlo correction is
  ## exact. This is a per-CELL aggregate, so it is paired on the cell and
  ## clustered on the latent network, and its resolution is set by the number of
  ## cells rather than by the replicate count.
  per <- do.call(rbind, lapply(split(seq_len(nrow(w)), w$cell_id), function(i) {
    n <- length(i)
    ba <- mean(ea[i] - tr[i]); sa <- stats::sd(ea[i] - tr[i]) / sqrt(n)
    bb <- mean(eb[i] - tr[i]); sb <- stats::sd(eb[i] - tr[i]) / sqrt(n)
    data.frame(param_id = w$param_id[i][1],
               d = (ba^2 - sa^2) - (bb^2 - sb^2))
  }))
  if (!is.null(per) && nrow(per) >= 2)
    out[[length(out) + 1L]] <- row("squared_bias", per$d, per$param_id,
                                   "per cell, not per replicate")

  ## Kept, and labeled. Not one of the four registered outcomes.
  out[[length(out) + 1L]] <- row("mean_absolute_error",
                                 abs(ea - tr) - abs(eb - tr), cl,
                                 "descriptive; mixes bias and variance")
  do.call(rbind, Filter(Negate(is.null), out))
}

## PRIMARY 1: THE QUESTION THE CATALOG ENTRY ACTUALLY ASKS.
##
## OUT-11 asks whether a general-likelihood survival ML-NMR recovers the target
## estimand where proportional-hazards MAIC and STC do not. That is a comparison
## between the recommended method and what practitioners currently do, and it is
## deliberately UNMATCHED on flexibility: the flexibility difference is the
## treatment, not a confounder.
##
## Version 5 did not register it at all. Round 4 found that the across-row
## contrasts rested on a "matched flexibility" premise round 2 had withdrawn, and
## the response demoted every across-row contrast to descriptive, which removed
## the study's own question along with the unsupportable ones. Round 5 caught
## that. The withdrawn premise applies to MATCHED comparisons and has no bearing
## on these two, which are unmatched on purpose.
## A CONTRAST SET CAN BE EMPTY, AND A PARTIAL RUN MUST STILL ANALYZE.
##
## `paired_contrast` returns NULL when one of its two estimators has no finite
## estimate anywhere, which is exactly what a resumable run looks like while one
## pass is still going: the frequentist checkpoints exist and the ML-NMR ones do
## not. `transform(NULL, standing = ...)` then fails with "arguments imply
## differing number of rows: 0, 1", so the whole production analysis died on real
## partial output. The smoke test did not catch it because it always populated
## both passes.
##
## `load_cells` promises in its own comment that "a partially complete run is
## analyzable and a pass that failed is visible instead of silently shrinking the
## sample". This is what makes that true rather than aspirational.
stack_contrasts <- function(parts, standing) {
  z <- do.call(rbind, Filter(Negate(is.null), parts))
  if (is.null(z) || !nrow(z))
    return(data.frame(worse = character(), better = character(),
                      outcome = character(), n = integer(), diff = numeric(),
                      se = numeric(), se_indep = numeric(), ci_lo = numeric(),
                      ci_hi = numeric(), note = character(),
                      standing = character(), stringsAsFactors = FALSE))
  transform(z, standing = standing)
}

practice_contrasts <- function(d) stack_contrasts(list(
  paired_contrast(d, "MAIC-PH", "MLNMR-flex"),
  paired_contrast(d, "STC-PH",  "MLNMR-flex")), "primary-entry")

## PRIMARY 2: flexible versus proportional, within a row. Both members share an
## implementation, a weighting or regression step and a code path, so only the
## survival-model restriction differs. This isolates the mechanism; primary 1
## measures the practical consequence.
primary_contrasts <- function(d) stack_contrasts(list(
  paired_contrast(d, "MAIC-PH",  "MAIC-flex"),
  paired_contrast(d, "STC-PH",   "STC-flex"),
  paired_contrast(d, "MLNMR-PH", "MLNMR-flex")), "primary-within")

## DESCRIPTIVE: method family across rows AT MATCHED FLEXIBILITY. Version 4
## registered these as primary on a premise round 2 had already withdrawn, since
## a 3-knot Royston-Parmar spline and a 3-knot M-spline do not carry the same
## effective flexibility. Round 4 caught the contradiction. They are reported
## with the measured flexibility gap alongside, never as a method-family verdict.
descriptive_contrasts <- function(d) stack_contrasts(list(
  paired_contrast(d, "MAIC-flex", "MLNMR-flex"),
  paired_contrast(d, "STC-flex",  "MLNMR-flex"),
  paired_contrast(d, "MAIC-PH",   "MLNMR-PH")), "descriptive")

registered_contrasts <- function(d)
  rbind(practice_contrasts(d), primary_contrasts(d), descriptive_contrasts(d))

## --- secondary appendix: decision loss against constant baselines -----------
##
## REPORTED UNDER TWO WEIGHTINGS, BECAUSE ONE OF THEM IS A DESIGN ARTIFACT.
##
## Round 5 found that the "a constant rule beats every estimator" finding was
## computed on the six-cell pilot mixture and does not carry to the frozen
## design, which has 19 recommend conditions against 2 decline. Under uniform
## weights an always-recommend rule is then almost free by construction
## (loss 0.0143, against 0.0500 on the pilot mixture), so the comparison measures
## the scenario distribution rather than the estimators.
##
## Both weightings are therefore reported: `uniform` over the registered
## conditions, and `balanced`, which gives the recommend and decline groups equal
## total weight so a constant rule cannot win on mixture alone. The finding that
## survives both is the one worth reporting.
##
## What is NOT mixture-dependent, and is the actual argument for demoting
## decision quality, is that per-replicate noise (0.70 to 0.87 months) dwarfs the
## decision margins (0.15 to 0.25 months). That holds under any weighting.
decision_appendix <- function(d, thr = DELTA_THRESHOLD) {
  d$cons <- abs(d$truth - thr)
  d$wrong <- ifelse(d$truth > thr, d$est <= thr, d$est > thr)
  per <- aggregate(cbind(loss = wrong * cons) ~ estimator + cell_id, d, mean)
  cells <- unique(d[, c("cell_id", "truth")])
  cells$cons <- abs(cells$truth - thr)
  cells$rec <- cells$truth > thr
  ## Balanced weights: each group carries total weight 1/2.
  w <- ifelse(cells$rec, 0.5 / sum(cells$rec), 0.5 / sum(!cells$rec))
  names(w) <- cells$cell_id
  wmean <- function(x, id) sum(x * w[as.character(id)])

  est_rows <- do.call(rbind, lapply(split(per, per$estimator), function(g)
    data.frame(estimator = g$estimator[1],
               loss_uniform = mean(g$loss),
               loss_balanced = wmean(g$loss, g$cell_id),
               stringsAsFactors = FALSE)))
  base <- function(nm, lo) data.frame(estimator = nm,
    loss_uniform = mean(lo), loss_balanced = sum(lo * w), stringsAsFactors = FALSE)
  rbind(est_rows,
        base("ALWAYS-recommend", ifelse(cells$rec, 0, cells$cons)),
        base("NEVER-recommend",  ifelse(cells$rec, cells$cons, 0)))
}

## `dir` is an argument so R/15-smoke.R can run THIS function rather than a
## hand-picked subset of the tables it calls. Round 6 found two registered
## outputs missing from production while both of their table functions existed
## and passed the smoke test in isolation: the smoke test was calling the parts,
## not the whole, so a table nothing called still looked healthy.
main <- function(dir = "results/cells") {
  d <- load_cells(dir)
  cat(sprintf("loaded %d estimator-replicate rows over %d cells\n\n",
              nrow(d), length(unique(d$cell_id))))
  ## A partial run is legitimate (the passes are resumable and the smoke test is
  ## deliberately tiny), so completeness is reported rather than required, and
  ## the checks below that only make sense on a complete run say so.
  complete <- length(unique(d$cell_id)) == nrow(build_cells())
  if (!complete)
    cat("NOTE: this is a PARTIAL run. Condition-count assertions are relaxed.\n\n")
  cat("=== primary 1: bias and RMSE ===\n");        print(bias_table(d), row.names = FALSE, digits = 4)
  cat("\n=== primary 2: coverage, all 21 conditions ===\n")
  print(coverage_table(d), row.names = FALSE, digits = 4)
  ## THE NINE-CONDITION RESTRICTION, WHICH WAS REGISTERED AND NEVER PRODUCED.
  ##
  ## Section 10.1 registers that the primary-arm restriction "is reported
  ## alongside it and is never substituted for it". Round 6 found production
  ## calling coverage_table once on all 21 conditions and never filtering, so one
  ## of the two prespecified summaries did not exist. The guard against choosing
  ## the favorable pool after seeing results only works if BOTH are printed, so
  ## this is printed unconditionally and the row count is asserted rather than
  ## assumed.
  prim <- d[d$arm == "primary", ]
  n_prim <- length(unique(prim$cell_id))
  n_prim_design <- sum(build_cells()$arm == "primary")
  if (complete && n_prim != n_prim_design)
    stop("the primary-arm coverage restriction should cover ", n_prim_design,
         " conditions, found ", n_prim)
  cat(sprintf("\n=== primary 2, restricted: the %d primary conditions ===\n", n_prim))
  cat("Reported ALONGSIDE the 21-condition table above, never in place of it.\n")
  if (nrow(prim)) print(coverage_table(prim), row.names = FALSE, digits = 4)
  else cat("(no primary-arm conditions in this run)\n")
  cat("\n=== PRIMARY 1: the catalog entry's question, flexible ML-NMR vs PH practice ===\n")
  print(practice_contrasts(d), row.names = FALSE, digits = 4)
  cat("\n=== PRIMARY 2: flexible vs proportional, within a row ===\n")
  print(primary_contrasts(d), row.names = FALSE, digits = 4)
  cat("\n=== DESCRIPTIVE contrasts: across rows. NOT a method-family verdict;\n")
  cat("    the matched-flexibility premise was withdrawn in round 2. ===\n")
  print(descriptive_contrasts(d), row.names = FALSE, digits = 4)
  ## Registered primary outcome 4. Round 6 found that load_calibration and
  ## calibration_table existed and main() never called them, so the outcome was
  ## implemented and still absent from the production analysis.
  cat("\n=== primary 4: calibration over time ===\n")
  cal <- try(load_calibration(dir), silent = TRUE)
  if (inherits(cal, "try-error") || is.null(cal)) {
    stop("registered primary outcome 4 could not be assembled: ",
         if (inherits(cal, "try-error")) conditionMessage(attr(cal, "condition"))
         else "no survival differences in the checkpoints")
  }
  ct <- calibration_table(cal)
  print(ct, row.names = FALSE, digits = 4)
  ## The completeness guard binds on a COMPLETE run. On a partial one, which the
  ## resumable design makes a normal state, a missing estimator means its pass
  ## has not finished rather than that the outcome is unproducible, and stopping
  ## would make the very partial analysis `load_cells` promises impossible.
  miss <- setdiff(ROWS, unique(ct$estimator))
  if (length(miss) && complete)
    stop("primary outcome 4 is missing estimators: ", paste(miss, collapse = ", "))
  if (length(miss))
    cat(sprintf("NOTE: partial run; outcome 4 has no rows yet for %s\n",
                paste(miss, collapse = ", ")))
  saveRDS(list(long = cal, table = ct), "results/e3-calibration.rds")

  cat("\n=== the registered common Cox projection, same functional per method ===\n")
  cx <- load_cox(dir); ctab <- cox_table(cx)
  print(ctab, row.names = FALSE, digits = 4)
  miss <- setdiff(ROWS, ctab$estimator[is.finite(ctab$mean_log_hr)])
  if (length(miss) && complete)
    stop("the registered Cox projection is missing estimators: ",
         paste(miss, collapse = ", "))
  if (length(miss))
    cat(sprintf("NOTE: partial run; the Cox projection has no rows yet for %s\n",
                paste(miss, collapse = ", ")))
  saveRDS(list(long = cx, table = ctab), "results/e3-cox.rds")

  cat("\n=== secondary: decision loss ===\n");      print(decision_appendix(d), row.names = FALSE, digits = 4)
  cat("\n=== sampler failures and refit escalation, recorded not dropped ===\n")
  print(merge(aggregate(cbind(fail_rate = !passed) ~ estimator, d, mean),
              aggregate(cbind(refit_rate = refit) ~ estimator, d, mean),
              by = "estimator"), row.names = FALSE, digits = 3)
  cat(sprintf("registered refit cap: 0.20; observed over ML-NMR rows: %.3f\n",
              mean(d$refit[grepl("^MLNMR", d$estimator)])))
  ## Effective degrees of freedom, section 7.2, so the paper reports how far
  ## apart the flexibilities actually were rather than assuming they matched.
  ## The two families are on different scales by construction (exact parameter
  ## count against p_WAIC), so they are printed side by side and never
  ## differenced.
  cat("\n=== effective degrees of freedom per estimator ===\n")
  cat("ML-NMR rows are p_WAIC; Royston-Parmar rows are exact parameter counts.\n")
  cat("Different scales by construction: compare within a family, not across.\n")
  print(aggregate(cbind(edf_mean = edf) ~ estimator, d, mean, na.rm = TRUE),
        row.names = FALSE, digits = 4)

  ## Inner Monte Carlo error of the percentile-interval endpoints, section 7.2,
  ## reported against the interval widths it is meant to be small relative to.
  cat("\n=== inner Monte Carlo error of the bootstrap interval endpoints ===\n")
  fq <- d[is.finite(d$mcse_lo), ]
  if (nrow(fq)) {
    fq$width <- fq$hi - fq$lo
    e <- aggregate(cbind(mcse_lo, mcse_hi, width) ~ estimator, fq, mean)
    e$pct_of_width <- round(100 * (e$mcse_lo + e$mcse_hi) / 2 / e$width, 2)
    print(e, row.names = FALSE, digits = 4)
  } else cat("(no bootstrap endpoint errors recorded)\n")

  ## THE ALL-PASSED SUBSET REPEATS EVERY REGISTERED OUTCOME.
  ##
  ## Section 14 registers that "the primary analysis is repeated on the subset
  ## where every fit passed". Round 6 found this rerunning `bias_table` alone,
  ## which leaves coverage, calibration over time, the Cox projection and every
  ## registered paired contrast unexamined precisely when fits are failing. A
  ## failure-sensitivity analysis that covers one of five outcomes is not one.
  cat("\n=== every primary outcome repeated on the all-passed subset ===\n")
  keep <- unique(d[!d$passed, c("cell_id", "rep")])
  drop_key <- if (nrow(keep)) paste(keep$cell_id, keep$rep) else character()
  ok <- if (length(drop_key)) d[!paste(d$cell_id, d$rep) %in% drop_key, ] else d
  cat(sprintf("(%d of %d replicate-cells retained)\n",
              length(unique(paste(ok$cell_id, ok$rep))),
              length(unique(paste(d$cell_id, d$rep)))))
  if (!nrow(ok)) {
    cat("no replicate has every fit passing; the subset analysis is empty and\n")
    cat("that fact is the result, not a reason to relax the policy.\n")
  } else {
    cat("\n-- primary 1: bias and RMSE --\n")
    print(bias_table(ok), row.names = FALSE, digits = 4)
    cat("\n-- primary 2: coverage --\n")
    print(coverage_table(ok), row.names = FALSE, digits = 4)
    cat("\n-- primary 1 contrast: flexible ML-NMR vs PH practice --\n")
    print(practice_contrasts(ok), row.names = FALSE, digits = 4)
    cat("\n-- primary 2 contrast: flexible vs proportional within a row --\n")
    print(primary_contrasts(ok), row.names = FALSE, digits = 4)
    ## The calibration and Cox rows are keyed on the same (cell_id, rep), so the
    ## same subset applies to them without recomputing which replicates passed.
    cal_ok <- cal[!paste(cal$cell_id, cal$rep) %in% drop_key, ]
    cat("\n-- primary 4: calibration over time --\n")
    print(calibration_table(cal_ok), row.names = FALSE, digits = 4)
    cx_ok <- cx[!paste(cx$cell_id, cx$rep) %in% drop_key, ]
    cat("\n-- the common Cox projection --\n")
    print(cox_table(cx_ok), row.names = FALSE, digits = 4)
    cat("\n-- secondary: decision loss --\n")
    print(decision_appendix(ok), row.names = FALSE, digits = 4)
  }
  saveRDS(d, "results/e3-long.rds")
}

if (!interactive() && Sys.getenv("ANALYZE_NOMAIN") == "") main()
