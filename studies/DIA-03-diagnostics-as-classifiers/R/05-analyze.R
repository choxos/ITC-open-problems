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
res <- do.call(rbind, lapply(raw, readRDS))
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
  n_in <- as.vector(table(d$scenario)[as.character(d$scenario)])
  d$w_deploy <- scen$w_deploy[key] / n_in
  d$w_equal <- (1 / nrow(scen)) / n_in
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
  if (wcol == "equal") cw <- rep(1 / nrow(scen), length(by))
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
  ## Control weight strictly below, and tied, for each position.
  g <- match(s, unique(s))
  tot_by <- as.vector(tapply(ctrl, g, sum))
  below <- c(0, cumsum(tot_by))[g]
  tied <- tot_by[g]
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
calib <- function(d, nm, event, w) {
  x <- d[[nm]]
  ok <- is.finite(x)
  x <- if (isTRUE(DIRECTION[[nm]])) -log(pmax(x[ok], 1e-6)) else x[ok]
  y <- event[ok]; ww <- w[ok]; rp <- d$rep[ok]
  fit_i <- rp %% 2L == 1L
  if (sum(fit_i) < 50 || length(unique(y[fit_i])) < 2) return(c(NA, NA, NA))
  m <- stats::glm(y[fit_i] ~ x[fit_i], family = stats::binomial())
  lp <- stats::coef(m)[1] + stats::coef(m)[2] * x[!fit_i]
  yv <- y[!fit_i]; wv <- ww[!fit_i]
  if (length(unique(yv)) < 2) return(c(NA, NA, NA))
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
res <- add_weights(res)
res$material <- abs(res$err) > MATERIAL
res$material10 <- abs(res$err) > 0.10
res$material30 <- abs(res$err) > 0.30
res$big_transport <- abs(res$transport) > MATERIAL
res$big_noise <- abs(res$noise) > MATERIAL
res$noncover <- !res$covered

fit_rate <- vapply(split(res$fitted[res$method == "maic"],
                         res$scenario[res$method == "maic"]), mean, 0)
nonfit_deploy <- sum(scen$w_deploy * (1 - fit_rate[as.character(scen$scenario)]))

M <- res[res$method == "maic" & res$fitted, ]
ALL_D <- c(ROUTINE, PROPOSED, "orc_cross", "lambda_norm")

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

## Same, restricted to the stratum where the bias channel is diagnosable at all.
Md <- M[M$scenario %in% scen$scenario[scen$diagnosable], ]
op_diag <- do.call(rbind, lapply(rules, function(r) {
  a <- oper(Md, r, Md$material, "equal")
  data.frame(rule = r, sens = a[["sensitivity"]], sens_mcse = a[["sens_mcse"]],
             spec = a[["specificity"]], stringsAsFactors = FALSE)
}))

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
    auc_noncover = wauc(s, M$noncover, M$w_deploy),
    auc_10 = wauc(s, M$material10, M$w_deploy),
    auc_30 = wauc(s, M$material30, M$w_deploy),
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
cal <- do.call(rbind, lapply(ALL_D, function(nm) {
  v <- calib(M, nm, M$material, M$w_deploy)
  data.frame(diagnostic = nm, cal_intercept = v[1], cal_slope = v[2],
             ice = v[3], stringsAsFactors = FALSE)
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
    text = sprintf("In the diagnosable stratum, against the transport component, the proposal reaches %.3f and the best routinely reported diagnostic %.3f, a gain of %.3f against a prespecified 0.10.",
                   bh_diag, routine_best_diag, bh_diag - routine_best_diag))
)

## --- the same panel for the other estimators ---------------------------------
other <- do.call(rbind, lapply(c("stc", "unadj"), function(m) {
  z <- add_weights(res[res$method == m & res$fitted, ])
  do.call(rbind, lapply(c("smd_pre", "maha", "smd_unmatched", "bias_hat"), function(nm)
    data.frame(method = m, diagnostic = nm,
               auc_deploy = wauc(sgn(nm, z[[nm]]), abs(z$err) > MATERIAL, z$w_deploy),
               material = sum(z$w_deploy * (abs(z$err) > MATERIAL)) / sum(z$w_deploy),
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
             stringsAsFactors = FALSE)
}))
rownames(cells) <- NULL

## ------------------------------------------------------------- the verdict ---
prev_deploy <- sum(M$w_deploy * M$material) / sum(M$w_deploy)
p <- op[op$rule == "ess", ]
hi <- function(e, s) e + 1.96 * s
lo <- function(e, s) e - 1.96 * s

meets <- function(row) lo(row$sens_deploy, row$sens_mcse) > 0.80 &&
  lo(row$spec_deploy, row$spec_mcse) > 0.50 &&
  row$sens_equal > 0.80 && row$spec_equal > 0.50
any_meets <- any(vapply(seq_len(nrow(op)), function(i) meets(op[i, ]), TRUE))
diag_fail <- op_diag$sens[op_diag$rule == "ess"] < 0.80

verdict <- if (prev_deploy < 0.05 || prev_deploy > 0.95 || nonfit_deploy > 0.10) {
  "uninformative"
} else if (any_meets) {
  "the panel classifies realized error"
} else if (hi(p$sens_deploy, p$sens_mcse) < 0.80 && diag_fail) {
  "the panel does not classify realized error at the thresholds in use"
} else {
  "the panel discriminates but no fixed threshold is defensible"
}

f3 <- function(x) formatC(x, format = "f", digits = 3)
L <- c("# Decision", "",
  sprintf("**Conclusion: %s**", verdict), "",
  sprintf("Prespecified in `protocol.md`. %d cells, %d replicates each, three estimators. MAIC fitted on %s of replicates (deployment-weighted non-fit %s). Material error, meaning |estimate - truth| > %.2f in the transported effect, on %s of fitted MAIC replicates under the deployment weights.",
          nrow(scen), N_REP, f3(mean(res$fitted[res$method == "maic"])),
          f3(nonfit_deploy), MATERIAL, f3(prev_deploy)), "",
  "## Primary: the published rule, and the rest of the panel at fixed thresholds",
  "", "| rule | cut | sensitivity | specificity | fires on | sens (equal wts) | spec (equal wts) |",
  "| --- | ---: | ---: | ---: | ---: | ---: | ---: |",
  sprintf("| %s | %s | %s (%s) | %s (%s) | %s | %s | %s |", op$rule, op$threshold,
          f3(op$sens_deploy), f3(op$sens_mcse), f3(op$spec_deploy), f3(op$spec_mcse),
          f3(op$fires_deploy), f3(op$sens_equal), f3(op$spec_equal)), "",
  "## Discrimination, which separates a bad threshold from a useless statistic",
  "", "| diagnostic | AUROC | AUPRC | vs transport | vs noise | vs non-coverage |",
  "| --- | ---: | ---: | ---: | ---: | ---: |",
  sprintf("| %s | %s (%s) | %s | %s | %s | %s |", disc$diagnostic,
          f3(disc$auc_deploy), f3(disc$auc_mcse), f3(disc$auprc_deploy),
          f3(disc$auc_transport), f3(disc$auc_noise), f3(disc$auc_noncover)), "",
  "## Calibration of a locked mapping, evaluated out of sample", "",
  "| diagnostic | intercept | slope | integrated calibration error |",
  "| --- | ---: | ---: | ---: |",
  sprintf("| %s | %s | %s | %s |", cal$diagnostic, f3(cal$cal_intercept),
          f3(cal$cal_slope), f3(cal$ice)), "",
  "## Decision curve: is acting on the rule better than not?", "",
  "Net benefit relative to flagging nothing. A rule earns its place only above both alternatives.",
  "", paste("| threshold prob | flag none | flag all |",
            paste(rules, collapse = " | "), "|"),
  paste0("| ---: | ---: | ---: |", strrep(" ---: |", length(rules))),
  apply(dca, 1, function(r) paste0("| ", paste(f3(as.numeric(r)), collapse = " | "), " |")),
  "",
  "## The four prespecified mechanism claims", "",
  "| claim | holds | evidence |", "| --- | :---: | --- |",
  sprintf("| %s | %s | %s |", names(MECH),
          vapply(MECH, function(m) if (isTRUE(m$holds)) "yes" else "no", ""),
          vapply(MECH, function(m) m$text, "")), "",
  "## The same statistics for the other estimators", "",
  "| method | diagnostic | AUROC | material error rate |", "| --- | --- | ---: | ---: |",
  sprintf("| %s | %s | %s | %s |", other$method, other$diagnostic,
          f3(other$auc_deploy), f3(other$material)), "")

writeLines(L, file.path(RES, "decision.md"))
utils::write.csv(op, file.path(RES, "operating-points.csv"), row.names = FALSE)
utils::write.csv(op_diag, file.path(RES, "operating-points-diagnosable.csv"), row.names = FALSE)
utils::write.csv(disc, file.path(RES, "discrimination.csv"), row.names = FALSE)
utils::write.csv(cal, file.path(RES, "calibration.csv"), row.names = FALSE)
utils::write.csv(dca, file.path(RES, "decision-curve.csv"), row.names = FALSE)
utils::write.csv(cells, file.path(RES, "cells.csv"), row.names = FALSE)
utils::write.csv(roc, file.path(RES, "roc.csv"), row.names = FALSE)
utils::write.csv(one_stat, file.path(RES, "panel-redundancy.csv"), row.names = FALSE)
saveRDS(MECH, file.path(RES, "mechanism.rds"))
cat(paste(L, collapse = "\n"), "\n")
