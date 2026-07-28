## Analysis: the diagnostics scored as classifiers.
##
##   Rscript R/05-analyze.R
##
## Everything here is computed twice, once under the declared deployment weights
## and once with all cells weighted equally. Sensitivity and specificity are not
## properties of a diagnostic; they are properties of a diagnostic under a
## distribution of analyses, and reporting one number without saying which
## distribution produced it is the reason this question has no answer in the
## literature. A conclusion that holds under only one weighting is reported as not
## holding.

.f <- grep("^--file=", commandArgs(FALSE), value = TRUE)
STUDY <- if (length(.f)) {
  dirname(dirname(normalizePath(sub("^--file=", "", .f[1]))))
} else normalizePath(".")
here <- function(...) file.path(STUDY, ...)

source(here("R", "01-dgm.R"))
source(here("R", "00-config.R"))

PILOT <- "--pilot" %in% commandArgs(TRUE)
RES <- here(if (PILOT) "results/pilot" else "results")
raw <- sort(list.files(file.path(RES, "raw"), "^scenario-.*\\.rds$", full.names = TRUE))
stopifnot(length(raw) > 0)
## Two million rows over four estimators, so the diagnostic columns are kept and
## the free-text ones are not.
DROP <- c("why", "error", "warnings", "secs", "n_T", "w_deploy")
res <- do.call(rbind, lapply(raw, function(f) {
  d <- readRDS(f)
  d[, setdiff(names(d), DROP), drop = FALSE]
}))
scen <- build_scenarios()
if (PILOT) {
  ## Exercise every code path on the subset, with the deployment weights
  ## renormalized over the cells present. Nothing from this path is reported.
  scen <- scen[scen$scenario %in% unique(res$scenario), ]
  scen$w_deploy <- scen$w_deploy / sum(scen$w_deploy)
}

## ---------------------------------------------------------------- weighting --
## Each replicate carries weight w_cell / n_replicates_in_cell, so cells enter in
## the declared proportion and replicates within a cell enter equally.
add_weights <- function(d) {
  key <- match(d$scenario, scen$scenario)
  cnt <- table(d$scenario)
  n_in <- as.vector(cnt[match(d$scenario, as.integer(names(cnt)))])
  d$w_deploy <- scen$w_deploy[key] / n_in
  d$w_equal <- (1 / length(cnt)) / n_in
  d
}

## ------------------------------------------------------- the panel and rules --
## Direction: TRUE means a LOW value is the warning.
DIRECTION <- c(ess = TRUE, ess_pct = TRUE, cv_w = FALSE, max_w = FALSE,
               smd_matched = FALSE, smd_pre = FALSE, maha = FALSE,
               smd_unmatched = FALSE, bias_hat = FALSE, orc_cross = FALSE,
               lambda_norm = FALSE)

## Thresholds fixed before the run. Where a convention exists it is used as
## stated rather than retuned: a threshold that has to be retuned for each
## analysis is not a rule, and retuning on the same data that scores it is how a
## diagnostic acquires performance it does not have.
THRESH <- list(
  ess = 35, ess30 = 30, ess_pct = 0.50, cv_w = 1.00, max_w = 0.10,
  smd_matched = 0.10, smd_pre = 0.25, maha = 1.00,
  smd_unmatched = 0.10, bias_hat = 0.10
)

fires <- function(d, nm) {
  th <- THRESH[[nm]]
  v <- d[[if (nm == "ess30") "ess" else nm]]
  if (isTRUE(DIRECTION[[if (nm == "ess30") "ess" else nm]])) v < th else v > th
}

## ------------------------------------------------- weighted operating points --
## Sensitivity under a cell-weighted distribution is a ratio of two weighted
## means, so its Monte Carlo error follows from the delta method on cell-level
## binomial quantities rather than from a single binomial. Treating the design's
## fixed cells as a random sample, which an earlier study in this program did and
## had to withdraw, would be wrong here for the same reason.
ratio_est <- function(cell_num, cell_den, cell_n, w) {
  N <- sum(w * cell_num); D <- sum(w * cell_den)
  r <- N / D
  vn <- cell_num * (1 - cell_num) / cell_n
  vd <- cell_den * (1 - cell_den) / cell_n
  cv <- (cell_num - cell_num * cell_den) / cell_n     # num is a subset of den
  v <- sum(w^2 * (vn - 2 * r * cv + r^2 * vd)) / D^2
  c(est = r, mcse = sqrt(max(v, 0)))
}

## Per-cell counts for one rule, then the weighted sensitivity and specificity.
oper <- function(d, rule, event, wcol) {
  f <- fires(d, rule)
  by <- split(seq_len(nrow(d)), d$scenario)
  cw <- scen$w_deploy[match(as.integer(names(by)), scen$scenario)]
  if (wcol == "equal") cw <- rep(1 / length(by), length(by))
  cw <- cw / sum(cw)
  n <- vapply(by, length, 0L)
  a <- vapply(by, function(i) mean(f[i] & event[i]), 0)
  b <- vapply(by, function(i) mean(event[i]), 0)
  c0 <- vapply(by, function(i) mean(!f[i] & !event[i]), 0)
  d0 <- vapply(by, function(i) mean(!event[i]), 0)
  s <- ratio_est(a, b, n, cw)
  sp <- ratio_est(c0, d0, n, cw)
  c(sensitivity = s[["est"]], sens_mcse = s[["mcse"]],
    specificity = sp[["est"]], spec_mcse = sp[["mcse"]],
    fires = sum(cw * vapply(by, function(i) mean(f[i]), 0)),
    prevalence = sum(cw * b))
}

## ---------------------------------------------------------- weighted AUROC ----
## Weighted Mann-Whitney: for each case, the weight of controls it outranks, ties
## counted half. O(n log n) through one sort rather than the O(n^2) pair loop.
wauc <- function(score, event, w) {
  ok <- is.finite(score)
  score <- score[ok]; event <- event[ok]; w <- w[ok]
  if (length(unique(event)) < 2) return(NA_real_)
  o <- order(score)
  s <- score[o]; e <- event[o]; ww <- w[o]
  ctrl <- ww * (!e)
  cum <- cumsum(ctrl)
  ## Control weight strictly below each score, and tied with it. Done with run
  ## boundaries on the sorted vector rather than a split-apply, which on half a
  ## million rows and a hundred bootstrap resamples is the difference between
  ## seconds and half an hour.
  g <- cumsum(c(TRUE, diff(s) != 0))
  end_i <- which(!duplicated(g, fromLast = TRUE))
  tot_end <- cum[end_i]
  tot_start <- c(0, tot_end[-length(tot_end)])
  below <- tot_start[g]
  tied <- (tot_end - tot_start)[g]
  num <- sum(ww[e] * (below[e] + 0.5 * tied[e]))
  W1 <- sum(ww[e]); W0 <- sum(ctrl)
  if (W1 <= 0 || W0 <= 0) return(NA_real_)
  num / (W1 * W0)
}

## Monte Carlo interval for the weighted AUROC by a cell-stratified bootstrap:
## replicates are resampled with replacement within each cell, so the cell weights
## and the design are held fixed and only Monte Carlo variation moves.
wauc_boot <- function(score, event, w, cell, B = 100L, seed = 4L) {
  set.seed(seed)
  idx_by <- split(seq_along(cell), cell)
  out <- numeric(B)
  for (b in seq_len(B)) {
    take <- unlist(lapply(idx_by, function(i) sample(i, length(i), replace = TRUE)),
                   use.names = FALSE)
    out[b] <- wauc(score[take], event[take], w[take])
  }
  stats::sd(out, na.rm = TRUE)
}

## Area under the precision-recall curve, weighted. Reported because at the
## prevalence this design produces, area under the ROC curve overstates how useful
## a warning is: a rule that flags most analyses is not doing work.
wauprc <- function(score, event, w) {
  ok <- is.finite(score)
  score <- score[ok]; event <- event[ok]; w <- w[ok]
  o <- order(-score)
  e <- event[o]; ww <- w[o]
  tp <- cumsum(ww * e); fp <- cumsum(ww * !e)
  rec <- tp / sum(ww * e); prec <- tp / (tp + fp)
  sum(diff(c(0, rec)) * prec)
}

## ------------------------------------------------------------- calibration ----
## A diagnostic is calibrated if a mapping from it to a risk of material error,
## fitted once and locked, tells the truth on data it did not see. The mapping is
## fitted on odd-numbered replicates and evaluated on even-numbered ones, which is
## deterministic and needs no extra seed.
## THE MODEL, STATED. The mapping is a logistic regression of the material-error
## indicator on a single transformed diagnostic: minus the natural logarithm for
## the statistics where a LOW value is the warning, the statistic itself
## otherwise. One linear term, no splines. Peer review asked for this to be stated
## because apparent miscalibration of an unstated model form is uninterpretable.
##
## `fit_i` says which rows train it. Peer review also caught a real defect in the
## first version, which trained on odd-numbered cells and tested on even ones:
## because cells are enumerated with the target dispersion ratio varying fastest,
## that split put every dispersion-1.00 cell in training and every 1.25 cell in
## test, so it measured transport across one factor and called it transport in
## general. It is replaced by leave-one-factor-level-out, which is balanced by
## construction, and by the within-cell replicate split as the optimistic bound.
calib <- function(d, nm, event, w, fit_i) {
  x <- d[[nm]]
  ok <- is.finite(x)
  x <- if (isTRUE(DIRECTION[[nm]])) -log(pmax(x[ok], 1e-6)) else x[ok]
  y <- event[ok]; ww <- w[ok]; fit_i <- fit_i[ok]
  if (sum(fit_i) < 50 || length(unique(y[fit_i])) < 2) return(c(NA, NA, NA))
  m <- stats::glm(y[fit_i] ~ x[fit_i], family = stats::binomial())
  b <- stats::coef(m)
  ## A predictor that is constant to machine precision, which the matched-moment
  ## balance statistic is, gives an unusable slope. Return empty rather than a
  ## number that would read as a calibration result.
  if (length(b) < 2 || any(!is.finite(b))) return(c(NA, NA, NA))
  lp <- b[1] + b[2] * x[!fit_i]
  yv <- y[!fit_i]; wv <- ww[!fit_i]
  if (length(unique(yv)) < 2 || !any(is.finite(lp))) return(c(NA, NA, NA))
  keep <- is.finite(lp)
  lp <- lp[keep]; yv <- yv[keep]; wv <- wv[keep]
  ## Calibration intercept with the slope fixed at one, then the slope.
  ci <- stats::glm(yv ~ offset(lp), family = stats::binomial(), weights = wv)
  cs <- stats::glm(yv ~ lp, family = stats::binomial(), weights = wv)
  p <- stats::plogis(lp)
  ## Integrated calibration error: mean absolute gap between predicted risk and
  ## observed risk within bins of predicted risk. A diagnostic that is constant,
  ## which the matched-moment balance statistic is by construction, produces one
  ## bin; there is nothing to integrate and the entry is left empty rather than
  ## filled with a number that would read as good calibration.
  qs <- unique(stats::quantile(p, seq(0, 1, length.out = 21), na.rm = TRUE))
  if (length(qs) < 3) return(c(unname(stats::coef(ci)[1]), unname(stats::coef(cs)[2]), NA))
  br <- cut(p, qs, include.lowest = TRUE)
  obs <- tapply(yv * wv, br, sum) / tapply(wv, br, sum)
  pre <- tapply(p * wv, br, sum) / tapply(wv, br, sum)
  wt <- tapply(wv, br, sum) / sum(wv)
  ice <- sum(wt * abs(obs - pre), na.rm = TRUE)
  c(unname(stats::coef(ci)[1]), unname(stats::coef(cs)[2]), ice)
}

## ----------------------------------------------------------- decision curve ---
## Net benefit of a rule at threshold probability pt, relative to flagging
## nothing. A rule is worth using only where its curve is above both flag-nothing
## and flag-everything.
net_benefit <- function(fire, event, w, pt) {
  W <- sum(w)
  tp <- sum(w[fire & event]) / W
  fp <- sum(w[fire & !event]) / W
  tp - fp * pt / (1 - pt)
}

## ============================================================== the analysis ==
res$material <- abs(res$err) > MATERIAL
res$material10 <- abs(res$err) > 0.10
res$material30 <- abs(res$err) > 0.30
res$big_transport <- abs(res$transport) > MATERIAL
res$big_noise <- abs(res$noise) > MATERIAL
## Added after peer review. Two reviewers pointed out independently that the
## arm-imbalance term is a function of the realized covariates, the treatment
## assignment and the weights, and of no outcome at all, so it is in principle
## diagnosable from covariates and the manuscript was wrong to group it with the
## outcome noise. It is now scored like the other two.
res$big_arm <- abs(res$arm_imbalance) > MATERIAL
res$noncover <- !res$covered
res$material_anchored <- abs(res$err_anchored) > MATERIAL

fit_rate <- vapply(split(res$fitted[res$method == "maic"],
                         res$scenario[res$method == "maic"]), mean, 0)
nonfit_deploy <- sum(scen$w_deploy * (1 - fit_rate[as.character(scen$scenario)]))

## Weights are attached AFTER subsetting to the analysis set, not before. Attached
## to the full result set they would be divided by the number of rows per cell
## across all four estimators, so once MAIC's non-fitted replicates were dropped a
## cell with a lower fit rate would silently carry less than its declared weight.
M <- add_weights(res[res$method == "maic" & res$fitted, ])
ALL_D <- c(ROUTINE, PROPOSED, "orc_cross", "lambda_norm")

## Which bias channels a cell has switched on. THE PRIMARY RESULTS ARE REPORTED
## WITHIN THESE STRATA, not as a mixture over them.
##
## A critique of the design made the point that decides this: the frequency of
## misspecification across cells is a number the investigators chose, and any
## headline sensitivity computed over a mixture inherits it. Reporting within
## strata removes that dependence completely. The mixture is kept as a secondary,
## with its weights declared, because a reader who wants one number will otherwise
## construct their own.
STRATUM <- c("well specified", "omitted modifier", "cross-moment", "both")
stratum_of <- function(d) factor(ifelse(d$omit == 0 & d$joint == 0, STRATUM[1],
                             ifelse(d$omit > 0 & d$joint > 0, STRATUM[4],
                             ifelse(d$omit > 0, STRATUM[2], STRATUM[3]))), STRATUM)
M$stratum <- stratum_of(M)

## --- primary and the rest of the panel at their fixed thresholds -------------
rules <- c("ess", "ess30", "ess_pct", "cv_w", "max_w", "smd_matched", "smd_pre",
           "maha", "smd_unmatched", "bias_hat")
op <- do.call(rbind, lapply(rules, function(r) {
  a <- oper(M, r, M$material, "deploy")
  b <- oper(M, r, M$material, "equal")
  data.frame(rule = r, threshold = THRESH[[r]],
             sens_deploy = a[["sensitivity"]], sens_mcse = a[["sens_mcse"]],
             spec_deploy = a[["specificity"]], spec_mcse = a[["spec_mcse"]],
             fires_deploy = a[["fires"]],
             sens_equal = b[["sensitivity"]], spec_equal = b[["specificity"]],
             stringsAsFactors = FALSE)
}))

## PRIMARY: the same operating points within each misspecification stratum, with
## cells weighted equally inside a stratum so no investigator-chosen mixture
## enters.
op_str <- do.call(rbind, lapply(STRATUM, function(st) {
  z <- M[M$stratum == st, ]
  do.call(rbind, lapply(rules, function(r) {
    a <- oper(z, r, z$material, "equal")
    data.frame(stratum = st, rule = r,
               sensitivity = a[["sensitivity"]], sens_mcse = a[["sens_mcse"]],
               specificity = a[["specificity"]], spec_mcse = a[["spec_mcse"]],
               prevalence = a[["prevalence"]], fires = a[["fires"]],
               stringsAsFactors = FALSE)
  }))
}))

## Same, restricted to the stratum where the bias channel is diagnosable at all.
Md <- M[M$scenario %in% scen$scenario[scen$diagnosable], ]
op_diag <- do.call(rbind, lapply(rules, function(r) {
  a <- oper(Md, r, Md$material, "equal")
  data.frame(rule = r, sens = a[["sensitivity"]], sens_mcse = a[["sens_mcse"]],
             spec = a[["specificity"]], stringsAsFactors = FALSE)
}))

## Bounds for the replicates on which MAIC had no solution.
##
## Those analyses do not exist, so there is no realized error to classify, and the
## classifier analysis conditions on a fit. The critique's objection stands
## anyway: conditioning on solvability answers a slightly easier question. So the
## sensitivity of the primary rule is bracketed by treating every non-fit as a
## material error the rule caught (an analyst who cannot produce weights does know
## something is wrong) and as one it missed.
nonfit_by_cell <- 1 - fit_rate[as.character(scen$scenario)]
bounds <- local({
  f <- fires(M, "ess")
  by <- split(seq_len(nrow(M)), M$scenario)
  ids <- as.integer(names(by))
  n_fit <- vapply(by, length, 0L)
  n_try <- round(n_fit / pmax(fit_rate[as.character(ids)], 1e-9))
  n_bad <- pmax(n_try - n_fit, 0)
  cw <- rep(1 / length(by), length(by))
  hit <- vapply(by, function(i) sum(f[i] & M$material[i]), 0)
  mat <- vapply(by, function(i) sum(M$material[i]), 0)
  best <- sum(cw * (hit + n_bad) / (n_fit + n_bad)) / sum(cw * (mat + n_bad) / (n_fit + n_bad))
  worst <- sum(cw * hit / (n_fit + n_bad)) / sum(cw * (mat + n_bad) / (n_fit + n_bad))
  c(best = best, worst = worst, n_nonfit = sum(n_bad))
})

## --- discrimination ----------------------------------------------------------
sgn <- function(nm, v) if (isTRUE(DIRECTION[[nm]])) -v else v
disc <- do.call(rbind, lapply(ALL_D, function(nm) {
  s <- sgn(nm, M[[nm]])
  data.frame(
    diagnostic = nm,
    auc_deploy = wauc(s, M$material, M$w_deploy),
    auc_mcse = wauc_boot(s, M$material, M$w_deploy, M$scenario),
    auc_equal = wauc(s, M$material, M$w_equal),
    auprc_deploy = wauprc(s, M$material, M$w_deploy),
    auc_transport = wauc(s, M$big_transport, M$w_deploy),
    auc_noise = wauc(s, M$big_noise, M$w_deploy),
    auc_arm = wauc(s, M$big_arm, M$w_deploy),
    auc_noncover = wauc(s, M$noncover, M$w_deploy),
    auc_anchored = wauc(s, M$material_anchored, M$w_deploy),
    auc_10 = wauc(s, M$material10, M$w_deploy),
    auc_30 = wauc(s, M$material30, M$w_deploy),
    stringsAsFactors = FALSE)
}))

## Discrimination against the transport component, within each misspecification
## stratum. Registered mechanism claim 4 lives here, and peer review was right
## that the two numbers behind it appeared in the abstract and in no table.
disc_str <- do.call(rbind, lapply(STRATUM, function(st) {
  z <- M[M$stratum == st, ]
  data.frame(stratum = st,
             t(vapply(ALL_D, function(nm)
               wauc(sgn(nm, z[[nm]]), z$big_transport, z$w_equal), 0)),
             check.names = FALSE, stringsAsFactors = FALSE)
}))

## The anchored contrast, which is what a submission actually reports. The primary
## reference is the transported source-side effect, because that is the part a
## source-side diagnostic could know about; two reviewers noted that calling the
## design anchored while scoring only that component is not licensed, so the
## anchored analysis is reported alongside rather than left in the protocol.
anch <- do.call(rbind, lapply(rules, function(r) {
  a <- oper(M, r, M$material_anchored, "deploy")
  data.frame(rule = r, sensitivity = a[["sensitivity"]],
             specificity = a[["specificity"]], prevalence = a[["prevalence"]],
             stringsAsFactors = FALSE)
}))

## --- ROC curves, thinned so the tracked artifact stays small ----------------
roc_points <- function(score, event, w, n_out = 300L) {
  ok <- is.finite(score)
  score <- score[ok]; event <- event[ok]; w <- w[ok]
  o <- order(-score)
  e <- event[o]; ww <- w[o]
  tpr <- cumsum(ww * e) / sum(ww * e)
  fpr <- cumsum(ww * !e) / sum(ww * !e)
  i <- unique(c(1L, round(seq(1, length(tpr), length.out = n_out)), length(tpr)))
  data.frame(fpr = c(0, fpr[i]), tpr = c(0, tpr[i]))
}
roc <- do.call(rbind, lapply(ALL_D, function(nm) {
  d <- roc_points(sgn(nm, M[[nm]]), M$material, M$w_deploy)
  d$diagnostic <- nm; d
}))
roc_t <- do.call(rbind, lapply(ALL_D, function(nm) {
  d <- roc_points(sgn(nm, M[[nm]]), M$big_transport, M$w_deploy)
  d$diagnostic <- nm; d
}))
roc$target <- "material error"; roc_t$target <- "transport error"
roc <- rbind(roc, roc_t)

## --- calibration -------------------------------------------------------------
## Leave-one-factor-level-out folds: hold out every cell at one level of one
## factor, train on the rest. Fourteen folds, balanced across everything else by
## construction.
FOLDS <- do.call(c, lapply(names(LEVELS), function(f)
  lapply(LEVELS[[f]], function(l) list(factor = f, level = l))))

cal_folds <- do.call(rbind, lapply(ALL_D, function(nm)
  do.call(rbind, lapply(FOLDS, function(fd) {
    v <- calib(M, nm, M$material, M$w_deploy, M[[fd$factor]] != fd$level)
    data.frame(diagnostic = nm, factor = fd$factor, level = fd$level,
               cal_intercept = v[1], cal_slope = v[2], ice = v[3],
               stringsAsFactors = FALSE)
  }))))

cal <- do.call(rbind, lapply(ALL_D, function(nm) {
  out <- cal_folds[cal_folds$diagnostic == nm, ]
  b <- calib(M, nm, M$material, M$w_deploy, M$rep %% 2L == 1L)
  data.frame(diagnostic = nm,
             cal_intercept = stats::median(out$cal_intercept, na.rm = TRUE),
             cal_slope = stats::median(out$cal_slope, na.rm = TRUE),
             ice = stats::median(out$ice, na.rm = TRUE),
             ice_worst = max(out$ice, na.rm = TRUE),
             ice_same_cells = b[3], slope_same_cells = b[2],
             stringsAsFactors = FALSE)
}))

## --- decision curve ----------------------------------------------------------
PT <- c(0.10, 0.20, 0.30, 0.40, 0.50)
dca <- do.call(rbind, lapply(PT, function(pt) {
  prev <- sum(M$w_deploy * M$material) / sum(M$w_deploy)
  all_nb <- prev - (1 - prev) * pt / (1 - pt)
  r <- vapply(rules, function(rl)
    net_benefit(fires(M, rl), M$material, M$w_deploy, pt), 0)
  data.frame(pt = pt, flag_none = 0, flag_all = all_nb,
             as.data.frame(as.list(r)), stringsAsFactors = FALSE)
}))

## --- systematic transport bias, at the level of a cell -----------------------
##
## Added in round two of review. The per-replicate transport term is the REALIZED
## effect-modifier component of one analysis: it contains finite-sample source
## composition and allocation variation as well as the systematic part. A reviewer
## objected, correctly, that scoring diagnostics against it does not establish
## anything about systematic bias, which is a property of a cell rather than of a
## replicate. So the systematic part is estimated directly as the Monte Carlo mean
## of the transport term within a cell, and the diagnostics are scored against it
## with the cell as the unit. 128 cells is a small sample and the areas under the
## curve below carry correspondingly wide uncertainty; they are reported because
## the alternative is to leave the question unanswered.
cell_sys <- do.call(rbind, lapply(split(M, M$scenario), function(z) {
  s <- scen[scen$scenario == z$scenario[1], ]
  d <- data.frame(scenario = z$scenario[1], w_deploy = s$w_deploy,
                  bias = mean(z$transport),
                  bias_mcse = stats::sd(z$transport) / sqrt(nrow(z)),
                  stringsAsFactors = FALSE)
  for (nm in ALL_D) d[[nm]] <- stats::median(z[[nm]])
  d
}))
cell_sys$material_bias <- abs(cell_sys$bias) > MATERIAL
sys_disc <- data.frame(
  diagnostic = ALL_D,
  auc_systematic = vapply(ALL_D, function(nm)
    wauc(sgn(nm, cell_sys[[nm]]), cell_sys$material_bias,
         rep(1, nrow(cell_sys))), 0),
  spearman = vapply(ALL_D, function(nm)
    suppressWarnings(stats::cor(sgn(nm, cell_sys[[nm]]), abs(cell_sys$bias),
                                method = "spearman")), 0),
  stringsAsFactors = FALSE)

## --- the four prespecified mechanism claims ----------------------------------
## The unit is the cell the rule flags, not a fixed numeric band. Among the
## analyses ESS < 35 warns about, how much does the actual risk of material error
## vary? If a threshold were calibrated that risk would be roughly constant; if it
## varies widely the number means different things in different analyses, which is
## what "the threshold is not transportable" means operationally.
cell_flag <- vapply(split(M$ess < 35, M$scenario), mean, 0)
cell_mat <- vapply(split(M$material, M$scenario), mean, 0)
cell_ess <- vapply(split(M$ess, M$scenario), stats::median, 0)
in_band <- cell_flag >= 0.5
band_span <- if (sum(in_band) >= 2) range(cell_mat[in_band]) else c(NA, NA)
quiet_span <- if (sum(cell_flag <= 0.01) >= 2) range(cell_mat[cell_flag <= 0.01]) else c(NA, NA)

ess_gap <- disc$auc_noise[disc$diagnostic == "ess"] -
  disc$auc_transport[disc$diagnostic == "ess"]

routine_best_all <- max(disc$auc_deploy[disc$diagnostic %in% ROUTINE], na.rm = TRUE)
bh_diag <- wauc(Md$bias_hat, Md$big_transport, Md$w_deploy)
routine_best_diag <- max(vapply(ROUTINE, function(nm)
  wauc(sgn(nm, Md[[nm]]), Md$big_transport, Md$w_deploy), 0), na.rm = TRUE)

## Algebra says the first three are one statistic. Checked within a fixed source
## size, where ESS and ESS-as-a-percentage are monotone in each other.
one_stat <- do.call(rbind, lapply(sort(unique(M$n_arm)), function(n) {
  z <- M[M$n_arm == n, ]
  data.frame(n_arm = n,
             ess = wauc(-z$ess, z$material, z$w_deploy),
             ess_pct = wauc(-z$ess_pct, z$material, z$w_deploy),
             cv_w = wauc(z$cv_w, z$material, z$w_deploy),
             smd_matched_max = max(z$smd_matched), stringsAsFactors = FALSE)
}))

MECH <- list(
  variance_not_bias = list(
    holds = isTRUE(ess_gap >= 0.10),
    text = sprintf("Effective sample size discriminates outcome noise at AUROC %.3f and transport error at %.3f, a gap of %.3f against a prespecified 0.10.",
                   disc$auc_noise[disc$diagnostic == "ess"],
                   disc$auc_transport[disc$diagnostic == "ess"], ess_gap)),
  threshold_not_transportable = list(
    holds = isTRUE(diff(band_span) >= 0.30),
    text = sprintf("Across the %d cells the rule flags on most replicates, the material-error rate runs from %.3f to %.3f, a span of %.3f against a prespecified 0.30. Across the %d cells it is silent on, the rate runs from %.3f to %.3f.",
                   sum(in_band), band_span[1], band_span[2], diff(band_span),
                   sum(cell_flag <= 0.01), quiet_span[1], quiet_span[2])),
  panel_is_one_statistic = list(
    holds = all(abs(one_stat$ess - one_stat$ess_pct) < 1e-9) &&
      all(abs(one_stat$ess - one_stat$cv_w) < 1e-9),
    text = sprintf("Within a fixed source size the three agree to %.1e in AUROC, and the matched-moment balance statistic never exceeds %.1e.",
                   max(abs(c(one_stat$ess - one_stat$ess_pct,
                             one_stat$ess - one_stat$cv_w))),
                   max(one_stat$smd_matched_max))),
  bias_hat_helps = list(
    holds = isTRUE(bh_diag - routine_best_diag >= 0.10),
    proposed = bh_diag, routine = routine_best_diag,
    text = sprintf("In the diagnosable stratum, against the transport component, the proposal reaches %.3f and the best routinely reported diagnostic %.3f, a gain of %.3f against a prespecified 0.10.",
                   bh_diag, routine_best_diag, bh_diag - routine_best_diag))
)

## --- the same panel for the other estimators ---------------------------------
other <- do.call(rbind, lapply(c("maic_mean", "stc", "unadj"), function(m) {
  z <- add_weights(res[res$method == m & res$fitted, ])
  nms <- if (m == "maic_mean") c("ess", "smd_pre", "maha", "smd_unmatched", "bias_hat")
         else c("smd_pre", "maha", "smd_unmatched", "bias_hat")
  do.call(rbind, lapply(nms, function(nm)
    data.frame(method = m, diagnostic = nm,
               auc_deploy = wauc(sgn(nm, z[[nm]]), abs(z$err) > MATERIAL, z$w_deploy),
               auc_transport = wauc(sgn(nm, z[[nm]]), abs(z$transport) > MATERIAL, z$w_deploy),
               material = sum(z$w_deploy * (abs(z$err) > MATERIAL)) / sum(z$w_deploy),
               median_ess = stats::median(z$ess),
               coverage = mean(z$covered),
               stringsAsFactors = FALSE)))
}))

## --- per-cell summary --------------------------------------------------------
cells <- do.call(rbind, lapply(split(M, M$scenario), function(z) {
  s <- scen[scen$scenario == z$scenario[1], ]
  data.frame(s[, c("scenario", "omit", "joint", "overlap", "n_arm", "rho4",
                   "sd_target", "well_specified", "diagnosable", "w_deploy")],
             n = nrow(z), fit_rate = fit_rate[[as.character(z$scenario[1])]],
             material = mean(z$material), coverage = mean(z$covered),
             bias = mean(z$err), transport = mean(z$transport),
             ess = median(z$ess), fires_ess35 = mean(z$ess < 35),
             fires_bias_hat = mean(z$bias_hat > THRESH$bias_hat),
             ## Marginal outcome standard deviation in the target, so the material
             ## threshold can be stated on the right scale. Peer review pointed
             ## out that 0.20 is a fifth of the RESIDUAL standard deviation, not
             ## of the outcome standard deviation, which also includes the
             ## prognostic index and the treatment-effect heterogeneity.
             sd_outcome = sqrt(as.numeric(crossprod(
               BETA_PROG, cov_matrix(RHO_12_TARGET, s$rho4, s$sd_target) %*%
                 BETA_PROG)) + SIGMA^2),
             stringsAsFactors = FALSE)
}))
rownames(cells) <- NULL

## ------------------------------------------------------------- the verdict ---
prev_deploy <- sum(M$w_deploy * M$material) / sum(M$w_deploy)
p <- op[op$rule == "ess", ]
hi <- function(e, s) e + 1.96 * s
lo <- function(e, s) e - 1.96 * s

## A rule works only if it works in EVERY stratum: it must catch material error
## where the bias channels are on, and it must not fire indiscriminately where
## they are off. Requiring it stratum by stratum is what keeps an
## investigator-chosen mixture of misspecification frequencies out of the verdict.
meets_everywhere <- function(rl) {
  z <- op_str[op_str$rule == rl, ]
  nrow(z) == length(STRATUM) &&
    all(lo(z$sensitivity, z$sens_mcse) > 0.80) &&
    all(lo(z$specificity, z$spec_mcse) > 0.50)
}
any_meets <- any(vapply(rules, meets_everywhere, TRUE))
## The stratum with an omitted modifier is where a diagnostic has both something
## to find and the information to find it. A failure there is the one that counts.
ess_omit <- op_str[op_str$rule == "ess" & op_str$stratum == "omitted modifier", ]

verdict <- if (prev_deploy < 0.05 || prev_deploy > 0.95 || nonfit_deploy > 0.10) {
  "uninformative"
} else if (any_meets) {
  "the panel classifies realized error"
} else if (hi(ess_omit$sensitivity, ess_omit$sens_mcse) < 0.80) {
  "the panel does not classify realized error at the thresholds in use"
} else {
  "the panel discriminates but no fixed threshold is defensible"
}

f3 <- function(x) formatC(x, format = "f", digits = 3)
L <- c("# Decision", "",
  sprintf("**Conclusion: %s**", verdict), "",
  sprintf("Prespecified in `protocol.md`. %d cells, %d replicates each, %d estimators. MAIC fitted on %s of replicates (deployment-weighted non-fit %s). Material error, meaning |estimate - truth| > %.2f in the transported effect, on %s of fitted MAIC replicates under the deployment weights.",
          nrow(scen), max(res$rep), length(unique(res$method)),
          f3(mean(res$fitted[res$method == "maic"])),
          f3(nonfit_deploy), MATERIAL, f3(prev_deploy)), "",
  "## Primary: operating points WITHIN each misspecification stratum", "",
  "Cells are weighted equally inside a stratum, so no chosen mixture of misspecification frequencies enters the headline.",
  "", "| stratum | rule | prevalence | sensitivity | specificity | fires on |",
  "| --- | --- | ---: | ---: | ---: | ---: |",
  sprintf("| %s | %s | %s | %s (%s) | %s (%s) | %s |", op_str$stratum, op_str$rule,
          f3(op_str$prevalence), f3(op_str$sensitivity), f3(op_str$sens_mcse),
          f3(op_str$specificity), f3(op_str$spec_mcse), f3(op_str$fires)), "",
  "## Secondary: the same rules over the declared mixture", "",
  "| rule | cut | sensitivity | specificity | fires on | sens (equal wts) | spec (equal wts) |",
  "| --- | ---: | ---: | ---: | ---: | ---: | ---: |",
  sprintf("| %s | %s | %s (%s) | %s (%s) | %s | %s | %s |", op$rule, op$threshold,
          f3(op$sens_deploy), f3(op$sens_mcse), f3(op$spec_deploy), f3(op$spec_mcse),
          f3(op$fires_deploy), f3(op$sens_equal), f3(op$spec_equal)), "",
  sprintf("Replicates on which MAIC had no solution: %s. Bracketing the primary rule's sensitivity by counting every one of them as a caught failure, then as a missed one, gives %s and %s.",
          format(bounds[["n_nonfit"]], big.mark = ","),
          f3(bounds[["best"]]), f3(bounds[["worst"]])), "",
  "## Discrimination, which separates a bad threshold from a useless statistic",
  "", "| diagnostic | AUROC | AUPRC | vs transport | vs noise | vs non-coverage |",
  "| --- | ---: | ---: | ---: | ---: | ---: |",
  sprintf("| %s | %s (%s) | %s | %s | %s | %s |", disc$diagnostic,
          f3(disc$auc_deploy), f3(disc$auc_mcse), f3(disc$auprc_deploy),
          f3(disc$auc_transport), f3(disc$auc_noise), f3(disc$auc_noncover)), "",
  "### All three error components, equal cell weights, and the other thresholds", "",
  "| diagnostic | vs arm imbalance | vs transport | vs noise | AUROC (equal wts) | material 0.10 | material 0.30 | anchored contrast |",
  "| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |",
  sprintf("| %s | %s | %s | %s | %s | %s | %s | %s |", disc$diagnostic,
          f3(disc$auc_arm), f3(disc$auc_transport), f3(disc$auc_noise),
          f3(disc$auc_equal), f3(disc$auc_10), f3(disc$auc_30),
          f3(disc$auc_anchored)), "",
  "### Discrimination against the transport component, by stratum", "",
  paste("| diagnostic |", paste(disc_str$stratum, collapse = " | "), "|"),
  paste0("| --- |", strrep(" ---: |", nrow(disc_str))),
  vapply(ALL_D, function(nm) sprintf("| %s | %s |", nm,
    paste(f3(disc_str[[nm]]), collapse = " | ")), ""), "",
  "### The anchored contrast, which is what a submission reports", "",
  "| rule | sensitivity | specificity | prevalence |", "| --- | ---: | ---: | ---: |",
  sprintf("| %s | %s | %s | %s |", anch$rule, f3(anch$sensitivity),
          f3(anch$specificity), f3(anch$prevalence)), "",
  "## Calibration of a locked mapping", "",
  "Leave-one-factor-level-out: fourteen folds, each holding out every cell at one level of one factor. Median over folds, with the worst fold, and the within-cell replicate split as the optimistic bound. A logistic model on one transformed diagnostic; no splines.",
  "", "| diagnostic | intercept | slope | calibration error (median) | worst fold | same-cell |",
  "| --- | ---: | ---: | ---: | ---: | ---: |",
  sprintf("| %s | %s | %s | %s | %s | %s |", cal$diagnostic, f3(cal$cal_intercept),
          f3(cal$cal_slope), f3(cal$ice), f3(cal$ice_worst),
          f3(cal$ice_same_cells)), "",
  "## Decision curve: is acting on the rule better than not?", "",
  "Net benefit relative to flagging nothing. A rule earns its place only above both alternatives.",
  "", paste("| threshold prob | flag none | flag all |",
            paste(rules, collapse = " | "), "|"),
  paste0("| ---: | ---: | ---: |", strrep(" ---: |", length(rules))),
  apply(dca, 1, function(r) paste0("| ", paste(f3(as.numeric(r)), collapse = " | "), " |")),
  "",
  "## Systematic transport bias, with the cell as the unit", "",
  sprintf("%d of %d cells have a systematic transport bias above %.2f.",
          sum(cell_sys$material_bias), nrow(cell_sys), MATERIAL), "",
  "| diagnostic | AUROC vs systematic bias | Spearman with |bias| |",
  "| --- | ---: | ---: |",
  sprintf("| %s | %s | %s |", sys_disc$diagnostic, f3(sys_disc$auc_systematic),
          f3(sys_disc$spearman)), "",
  "## The four prespecified mechanism claims", "",
  "| claim | holds | evidence |", "| --- | :---: | --- |",
  sprintf("| %s | %s | %s |", names(MECH),
          vapply(MECH, function(m) if (isTRUE(m$holds)) "yes" else "no", ""),
          vapply(MECH, function(m) m$text, "")), "",
  "## The same statistics for the other estimators", "",
  "| method | diagnostic | AUROC | vs transport | material error rate | median ESS | coverage |",
  "| --- | --- | ---: | ---: | ---: | ---: | ---: |",
  sprintf("| %s | %s | %s | %s | %s | %s | %s |", other$method, other$diagnostic,
          f3(other$auc_deploy), f3(other$auc_transport), f3(other$material),
          f3(other$median_ess), f3(other$coverage)), "")

writeLines(L, file.path(RES, "decision.md"))
utils::write.csv(op, file.path(RES, "operating-points.csv"), row.names = FALSE)
utils::write.csv(op_str, file.path(RES, "operating-points-by-stratum.csv"), row.names = FALSE)
utils::write.csv(op_diag, file.path(RES, "operating-points-diagnosable.csv"), row.names = FALSE)
utils::write.csv(other, file.path(RES, "other-estimators.csv"), row.names = FALSE)
utils::write.csv(disc, file.path(RES, "discrimination.csv"), row.names = FALSE)
utils::write.csv(cal, file.path(RES, "calibration.csv"), row.names = FALSE)
utils::write.csv(cal_folds, file.path(RES, "calibration-folds.csv"), row.names = FALSE)
utils::write.csv(sys_disc, file.path(RES, "systematic-bias.csv"), row.names = FALSE)
utils::write.csv(cell_sys[, c("scenario", "bias", "bias_mcse", "material_bias",
                              "ess", "smd_pre", "smd_unmatched", "bias_hat")],
                 file.path(RES, "cell-systematic-bias.csv"), row.names = FALSE)
utils::write.csv(dca, file.path(RES, "decision-curve.csv"), row.names = FALSE)
utils::write.csv(cells, file.path(RES, "cells.csv"), row.names = FALSE)
utils::write.csv(roc, file.path(RES, "roc.csv"), row.names = FALSE)
utils::write.csv(disc_str, file.path(RES, "discrimination-by-stratum.csv"), row.names = FALSE)
utils::write.csv(anch, file.path(RES, "anchored-operating-points.csv"), row.names = FALSE)
utils::write.csv(
  data.frame(method = c("maic", "maic_mean", "stc", "unadj"),
             coverage = vapply(c("maic", "maic_mean", "stc", "unadj"), function(m)
               mean(res$covered[res$method == m & res$fitted]), 0),
             coverage_anchored = vapply(c("maic", "maic_mean", "stc", "unadj"), function(m)
               mean(res$covered_anchored[res$method == m & res$fitted]), 0),
             fitted = vapply(c("maic", "maic_mean", "stc", "unadj"), function(m)
               mean(res$fitted[res$method == m]), 0)),
  file.path(RES, "coverage.csv"), row.names = FALSE)
utils::write.csv(one_stat, file.path(RES, "panel-redundancy.csv"), row.names = FALSE)
saveRDS(MECH, file.path(RES, "mechanism.rds"))
cat(paste(L, collapse = "\n"), "\n")
