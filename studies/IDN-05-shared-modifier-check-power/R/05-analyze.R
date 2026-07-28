## ---------------------------------------------------------------------------
## Analysis. Reads results/cells/*.rds, writes results/*.csv.
##
##   Rscript R/05-analyze.R
## ---------------------------------------------------------------------------

setwd(normalizePath(file.path(dirname(sub("^--file=", "",
  grep("^--file=", commandArgs(FALSE), value = TRUE)[1])), "..")))
source("R/00-config.R"); source("R/01-dgm.R")
suppressPackageStartupMessages({library(dplyr); library(tidyr)})

RES <- "results"; dir.create(RES, showWarnings = FALSE)
wr <- function(x, nm) { write.csv(x, file.path(RES, paste0(nm, ".csv")), row.names = FALSE); invisible(x) }

## --- load ---------------------------------------------------------------------
load_arm <- function(tag = "") {
  fs <- sort(Sys.glob(file.path("results/cells", sprintf("cell-*%s.rds", tag))))
  if (tag == "") fs <- fs[!grepl("p1\\.rds$", fs)]
  cells <- lapply(fs, readRDS)
  key <- DESIGN[, c("cell", names(FACTORS))]
  list(
    checks = left_join(bind_rows(lapply(cells, `[[`, "checks")), key, by = "cell"),
    est    = left_join(bind_rows(lapply(cells, `[[`, "est")),    key, by = "cell"),
    diag   = left_join(bind_rows(lapply(cells, `[[`, "diag")),   key, by = "cell"),
    fit    = bind_rows(lapply(cells, function(c)
               data.frame(cell = c$scen$cell, n_ok = c$n_ok, n_rep = c$n_rep,
                          n_fail = length(c$failures)))) |> left_join(key, by = "cell"))
}
## Contraction is 1 - sd(posterior)/sd(prior). Until a reviewer found it, the
## denominator was the config constant PRIOR_REG_SD rather than the prior each
## arm was fitted under, so the prior-sensitivity arm, fitted under normal(0, 1),
## had its contraction divided by 2.5. The direction of the reported effect was
## wrong as a result: tightening a prior cannot RAISE 1 - sd(post)/sd(prior).
##
## 02-fit.R now records the prior it used. Fits made before that change stored
## the raw posterior standard deviations, so the repair here is exact algebra on
## what is already on disk and needs no refit. It is written to apply to old and
## new files alike, and it is a no-op once every cell carries `prior_sd`.
fix_contraction <- function(arm, prior_sd) {
  if (is.null(arm)) return(NULL)
  ch <- arm$checks
  if (!"prior_sd" %in% names(ch)) ch$prior_sd <- prior_sd
  ch$contraction_A <- 1 - ch$post_sd_A / ch$prior_sd
  ch$contraction_C <- 1 - ch$post_sd_C / ch$prior_sd
  arm$checks <- ch
  arm
}
A  <- fix_contraction(load_arm(), PRIOR_REG_SD)
P1 <- fix_contraction(tryCatch(load_arm("p1"), error = function(e) NULL),
                      PRIOR_REG_ALT$scale)

## The eight amendment cells at the decision boundary are held out of every
## registered analysis and reported on their own. The deployment mixture was
## registered over the original four drift levels, so including them would both
## change a declared weighting after the fact and leave those cells with no
## weight defined at all.
MAIN_CELLS <- setdiff(DESIGN$cell, BOUNDARY_CELLS)
CH_ALL <- A$checks; ES_ALL <- A$est
CH <- A$checks |> filter(cell %in% MAIN_CELLS)
ES <- A$est    |> filter(cell %in% MAIN_CELLS)

## --- 0. fit success and sampler diagnostics -----------------------------------
wr(A$fit |> mutate(rate = n_ok / n_rep) |> arrange(cell), "fit-success")
wr(A$diag |> group_by(model) |> summarise(
     worst_rhat = max(max_rhat), p_rhat_over_105 = mean(max_rhat > FIT_OK_RHAT),
     worst_ess = min(min_ess), median_worst_ess = median(min_ess),
     p_ess_under_100 = mean(min_ess < FIT_OK_ESS),
     p_any_divergent = mean(divergent > 0),
     p_not_clean = mean(!valid), .groups = "drop"), "sampler-diagnostics")

## The worst diagnostic reached by ANY model, which is the number a reader needs
## and is not the same as the worst reached by the fully relaxed model. The
## manuscript quoted split_all's R-hat of 1.89 as though it were the worst in the
## study; split_x2 reaches further, and quoting the better of the two understated
## the problem. Found while checking a reviewer's arithmetic, not reported by one.
wr(A$diag |> summarise(
     worst_rhat_any_model = max(max_rhat),
     worst_rhat_model = model[which.max(max_rhat)],
     worst_ess_any_model = min(min_ess),
     worst_ess_model = model[which.min(min_ess)],
     ## per REPLICATE, not per fit: the question is how often an analyst would
     ## have been holding at least one unusable fit
     p_replicate_any_fit_bad =
       A$diag |> group_by(cell, rep) |> summarise(bad = any(!valid), .groups = "drop") |>
       pull(bad) |> mean()), "sampler-worst-overall")

## How often each model fails its sampler diagnostics, by cell. This is a RESULT
## about the procedure, not a filter: the fully relaxed model is the one whose
## parameters the thin networks cannot identify, so where it fails to converge is
## where relaxing is not an available option in practice.
wr(A$diag |> group_by(model, n_studies, spread, tau_re, drift) |>
     summarise(p_not_clean = mean(!valid), n = n(), .groups = "drop"),
   "convergence-by-cell")

## How far multinma's copula correlation, estimated from the one individual-level
## study, falls from the truth it is reconstructing.
wr(A$diag |> filter(model == "common") |>
     group_by(n_studies, spread, tau_re) |>
     summarise(mean_abs_cor_error = mean(cor_err, na.rm = TRUE),
               max_abs_cor_error = max(cor_err, na.rm = TRUE),
               true_cor = RHO, n = n(), .groups = "drop"), "correlation-recovery")

## --- flags --------------------------------------------------------------------
## Every rule in use, applied to every replicate and covariate.
CH <- CH |> mutate(
  flag_dic2  = as.integer(ddic < -2),
  flag_dic5  = as.integer(ddic < -5),
  flag_dic10 = as.integer(ddic < -10),
  flag_post  = post_flag,
  flag_margin = as.integer(p_exceeds_eps > 0.95),
  ## The reading a committee actually wants is not "is the drift nonzero" but "is
  ## it small enough to ignore". That is an equivalence statement, and it is the
  ## only one of these rules that can AFFIRM the assumption rather than merely
  ## fail to contradict it. It is computed from the same posterior.
  affirm_shared = as.integer(1 - p_exceeds_eps > 0.95),
  is_null    = contrast_true == 0)

RULES <- c("flag_dic2", "flag_dic5", "flag_dic10", "flag_post", "flag_margin")

## Both margin readings against the width of the posterior they are computed
## from. With a diffuse posterior P(|gap| > eps) tends to 1 and P(|gap| <= eps)
## tends to 0, so a network that says nothing fires the alarm and can never give
## the all-clear. This table is where that shows up.
wr(CH |> group_by(drift, n_studies, spread, tau_re, xvar) |>
     summarise(post_sd_A = mean(post_sd_A), post_sd_C = mean(post_sd_C),
               p_fires_margin = mean(flag_margin),
               p_affirms_shared = mean(affirm_shared),
               n = n(), .groups = "drop"), "margin-and-equivalence")

wilson <- function(k, n, side = c("two", "upper")) {
  side <- match.arg(side); z <- if (side == "two") 1.959964 else 1.644854
  p <- k / n; d <- 1 + z^2 / n
  c((p + z^2/(2*n) - z*sqrt(p*(1-p)/n + z^2/(4*n^2))) / d,
    (p + z^2/(2*n) + z*sqrt(p*(1-p)/n + z^2/(4*n^2))) / d)
}

## The registered gate is an upper bound on the DEPLOYMENT-WEIGHTED risk. A first
## version reported the Wilson bound on the UNWEIGHTED count beside the weighted
## point estimate, so the interval belonged to a different quantity than the
## number it was printed next to. A reviewer noticed that the published bound
## could not be reconstructed from the stated sample size and was right.
##
## Weights are constant within a cell, so the estimator is a ratio of weighted
## cell means. Writing m_c for the replicates a cell contributes after
## conditioning on a pass, W_c for its deployment weight and p_c for its risk,
##
##     phat = sum_c W_c m_c pbar_c / sum_c W_c m_c,
##     var(phat) = sum_c (W_c m_c / S)^2 * p_c (1 - p_c) / m_c,   S = sum_c W_c m_c
##
## with p_c estimated by pbar_c. Replicates are independent within and across
## cells, so this is exact up to plugging in pbar_c, and it is NOT the unweighted
## binomial variance: conditioning on a pass leaves cells contributing unequal
## m_c, which is what makes the weighted and unweighted intervals differ.
## One-sided, because the registered rule is one-sided.
weighted_upper <- function(y, cell, w, side = c("upper", "two")) {
  side <- match.arg(side); z <- if (side == "upper") 1.644854 else 1.959964
  s <- split(seq_along(y), cell)
  m <- vapply(s, length, 1L)
  pb <- vapply(s, function(i) mean(y[i]), 0)
  W <- vapply(s, function(i) w[i][1], 0)
  a <- W * m; a <- a / sum(a)
  p <- sum(a * pb)
  se <- sqrt(sum(a^2 * pb * (1 - pb) / m))
  c(max(0, p - z * se), min(1, p + z * se), se, p)
}

## --- 1. power and type I error -------------------------------------------------
detect <- CH |>
  pivot_longer(all_of(RULES), names_to = "rule", values_to = "flag") |>
  group_by(rule, xvar, drift, n_studies, spread, tau_re) |>
  summarise(n = n(), k = sum(flag), rate = k / n,
            lo = wilson(sum(flag), n())[1], hi = wilson(sum(flag), n())[2],
            .groups = "drop")
wr(detect, "detection-by-cell")

## Type I error is NOMINAL only under the global null. Under drift, a
## treatment-specific x2 term can absorb x1 misspecification through the
## covariate correlation, so that case is misattribution and is reported apart.
wr(detect |> filter(drift == 0) |>
     group_by(rule, xvar) |> summarise(
       n = sum(n), rate = sum(k) / sum(n),
       lo = wilson(sum(k), sum(n))[1], hi = wilson(sum(k), sum(n))[2],
       .groups = "drop"), "type1-global-null")

## Split by heterogeneity, because a reviewer asked whether the interval rule's
## excess is selection (it cannot be: one contrast per covariate, nothing chosen)
## or a second specification error leaking in. If the excess is confined to the
## tau_re = 0.15 cells it is a fixed-effect model reading random-effect data; if
## it is present at tau_re = 0 it is the credible interval failing to be a
## confidence interval in a network this thin.
wr(detect |> filter(drift == 0) |>
     group_by(rule, xvar, tau_re) |> summarise(
       n = sum(n), rate = sum(k) / sum(n),
       lo = wilson(sum(k), sum(n))[1], hi = wilson(sum(k), sum(n))[2],
       .groups = "drop"), "type1-by-heterogeneity")
wr(detect |> filter(drift > 0, xvar == "x2") |>
     group_by(rule, drift) |> summarise(
       n = sum(n), rate = sum(k) / sum(n), .groups = "drop"), "misattribution")

## Pooled over strata, which is the level at which the rate is resolvable. A
## reviewer pointed out that quoting the largest of eight cell estimates, each
## with a standard error of about 0.065, as an upper bound on power is not
## legitimate. The pooled rate has a standard error near 0.01 and carries an
## interval.
##
## The amendment arm at drift 0.15 is pooled INTO this table, tagged as an
## amendment, rather than left only in a stratified table of its own. The
## manuscript quotes the pooled amendment rate beside the pooled null rate, and
## while that row lived elsewhere the inline lookup silently returned nothing and
## the sentence rendered with an empty bracket. Two reviewers reported the blank.
## Keeping every drift level in one table is what makes the lookup total.
CH_POOL <- CH_ALL |> filter(xvar == "x1") |>
  mutate(flag_dic2  = as.integer(ddic < -2),
         flag_dic5  = as.integer(ddic < -5),
         flag_dic10 = as.integer(ddic < -10),
         flag_post  = post_flag,
         flag_margin = as.integer(p_exceeds_eps > 0.95))
wr(CH_POOL |>
     pivot_longer(all_of(RULES), names_to = "rule", values_to = "flag") |>
     group_by(rule, drift) |>
     summarise(arm = if (first(drift) == 0.15) "amendment" else "registered",
               n = n(), k = sum(flag), rate = k / n,
               lo = wilson(sum(flag), n())[1], hi = wilson(sum(flag), n())[2],
               .groups = "drop") |>
     relocate(arm, .after = drift), "power-pooled")

wr(detect |> filter(xvar == "x1", drift > 0) |>
     group_by(rule, drift, n_studies, spread, tau_re) |>
     summarise(power = sum(k)/sum(n), lo = wilson(sum(k), sum(n))[1],
               hi = wilson(sum(k), sum(n))[2], .groups = "drop"), "power")

## --- 2. material error, and what a pass licenses -------------------------------
## The check fires for a replicate if it fires on ANY covariate, which is how an
## analyst reads it. If it does not fire, the analyst keeps the restriction, so
## the estimate whose error matters is the shared-interaction fit.
## "The check fired" has two readings and they are not the same rule. An analyst
## reading a panel fires if ANY covariate fires; but a firing on the innocent
## covariate removes a replicate from the pass set without repairing anything,
## which can make the conditional risk look better because the check fired
## uselessly. Both are computed.
rep_flag <- CH |> group_by(cell, rep) |>
  summarise(across(all_of(RULES), ~ as.integer(any(.x == 1))), .groups = "drop")
rep_flag_x1 <- CH |> filter(xvar == "x1") |> group_by(cell, rep) |>
  summarise(across(all_of(RULES), ~ as.integer(.x == 1)), .groups = "drop")

## Two senses of "materially wrong", and both are reported, because they answer
## different questions and only one of them is the check's job.
##
##   material         the REALIZED error of this replicate exceeds the threshold.
##                    This is what a pass licenses in practice, and it contains
##                    sampling noise the check was never built to detect.
##   material_systematic
##                    the cell's SYSTEMATIC contrast error exceeds the threshold,
##                    which is a function of the drift and the displacement alone.
##                    This is the part the check could in principle see, and
##                    scoring against it is the fair test of the procedure.
##
## The pre-run critique made this point: a perfect detector of interaction
## violations can fail a rule written against realized error, because at zero
## drift the shared-interaction fit still misses by more than the threshold
## through ordinary estimation error. Reporting only the first would have blamed
## the check for noise; reporting only the second would have overstated what a
## pass is worth to a committee.
COMMON <- ES |> filter(model == "common") |>
  select(cell, rep, shift, err_rd, rd_CA, rd_CA_true) |>
  mutate(material = as.integer(abs(err_rd) > MATERIAL),
         material_systematic = as.integer(abs(rd_CA_true) > MATERIAL))

## How much of the realized error is systematic and how much is noise, per cell.
wr(ES |> filter(model == "common") |>
     group_by(drift, shift, n_studies, spread, tau_re) |>
     summarise(systematic_bias = mean(err_rd), noise_sd = sd(err_rd),
               rmse = sqrt(mean(err_rd^2)),
               p_material_realized = mean(abs(err_rd) > MATERIAL),
               p_material_if_no_noise = as.integer(abs(first(rd_CA_true)) > MATERIAL),
               n = n(), .groups = "drop"), "error-decomposition")

PASS <- left_join(COMMON, rep_flag, by = c("cell", "rep")) |>
  left_join(DESIGN[, c("cell", names(FACTORS))], by = "cell")

## M1: the check's output cannot depend on the target, so the pass rate computed
## within each displacement must be IDENTICAL. Any departure is a coding error.
m1_identity <- PASS |> group_by(shift) |>
  summarise(pass_rate_dic5 = mean(flag_dic5 == 0), .groups = "drop") |>
  mutate(max_abs_dev = max(abs(pass_rate_dic5 - pass_rate_dic5[1])))
wr(m1_identity, "m1-bookkeeping-identity")

## P(material error | the check passed), by displacement, deployment-weighted
DES_MAIN <- DESIGN |> filter(cell %in% MAIN_CELLS)
dw <- DES_MAIN |> mutate(w = deploy_weight(DES_MAIN)) |> select(cell, w)

## The weights themselves, written out. Two reviewers asked for them and the
## round-one response claimed they had been restated in the results when they had
## not been. They are a declared judgment, not an estimate, so a reader has to be
## able to see them and reweight.
wr(DES_MAIN |> mutate(w = deploy_weight(DES_MAIN)) |>
     select(cell, drift, n_studies, spread, tau_re, w) |> arrange(cell),
   "deployment-weights")
pass_risk <- PASS |> left_join(dw, by = "cell") |>
  pivot_longer(all_of(RULES), names_to = "rule", values_to = "flag") |>
  filter(flag == 0) |>
  group_by(rule, shift) |>
  summarise(n = n(), n_cells = n_distinct(cell), k = sum(material),
            risk_unweighted = k / n,
            risk_deployed = weighted.mean(material, w),
            ## The registered gate is on the weighted risk, so its bound must be
            ## the weighted one. The unweighted Wilson bound is kept beside it
            ## because the first version of this study reported that number as
            ## though it bounded the weighted estimate.
            hi95 = weighted_upper(material, cell, w)[2],
            se_deployed = weighted_upper(material, cell, w)[3],
            hi95_unweighted_wilson = wilson(sum(material), n(), "upper")[2],
            ## The same, against the part the check could in principle detect.
            ## NOTE the systematic indicator is a deterministic function of the
            ## cell's drift and the displacement, so it does not vary within a
            ## cell and its within-cell sampling variance is exactly zero. The
            ## bound below therefore equals the point estimate by construction.
            ## That is not a suspiciously tight interval: it says all remaining
            ## uncertainty lives in the deployment weights, which are declared
            ## rather than estimated. Reported so the equality is not read as a
            ## bug, and the unweighted Wilson bound is kept for comparison.
            k_sys = sum(material_systematic),
            risk_sys_unweighted = k_sys / n,
            risk_sys_deployed = weighted.mean(material_systematic, w),
            hi95_sys = weighted_upper(material_systematic, cell, w)[2],
            se_sys_deployed = weighted_upper(material_systematic, cell, w)[3],
            hi95_sys_unweighted_wilson =
              wilson(sum(material_systematic), n(), "upper")[2],
            .groups = "drop")

## The same quantity restricted to the sixteen cells with NO treatment-effect
## heterogeneity. In the tau_re = 0.15 cells the truth is defined at a random
## effect of zero while a fixed-effect model estimates a function of the realized
## studies, so part of the error charged to the check there is an estimand
## mismatch and not the check's doing. A reviewer said in round one that this
## should be separated and in round two that the paper claimed to have done so
## without doing it. These are the numbers the claim needs.
pass_risk_tau0 <- PASS |> filter(tau_re == 0) |> left_join(dw, by = "cell") |>
  pivot_longer(all_of(RULES), names_to = "rule", values_to = "flag") |>
  filter(flag == 0) |>
  group_by(rule, shift) |>
  summarise(n = n(), n_cells = n_distinct(cell),
            risk_deployed = weighted.mean(material, w),
            hi95 = weighted_upper(material, cell, w)[2],
            risk_sys_deployed = weighted.mean(material_systematic, w),
            hi95_sys = weighted_upper(material_systematic, cell, w)[2],
            .groups = "drop")
wr(pass_risk_tau0, "pass-risk-tau0")
wr(pass_risk, "pass-risk-by-shift")

wr(PASS |> pivot_longer(all_of(RULES), names_to = "rule", values_to = "flag") |>
     filter(flag == 0) |>
     group_by(rule, shift, drift, n_studies, spread, tau_re) |>
     summarise(n = n(), risk = mean(material), .groups = "drop"), "pass-risk-by-cell")

## Sensitivity: the same quantity on the subset where all four fits converged
## cleanly, so the effect of keeping the difficult replicates is visible.
clean <- A$diag |> group_by(cell, rep) |>
  summarise(all_clean = all(valid), .groups = "drop")
wr(PASS |> left_join(clean, by = c("cell", "rep")) |> left_join(dw, by = "cell") |>
     pivot_longer(all_of(RULES), names_to = "rule", values_to = "flag") |>
     filter(flag == 0) |> group_by(rule, shift, all_clean) |>
     summarise(n = n(), risk_deployed = weighted.mean(material, w),
               risk_sys_deployed = weighted.mean(material_systematic, w),
               .groups = "drop"), "pass-risk-clean-subset")

## An oracle reference for the verdict. The registered gate asks whether
## P(material error | passed) is below 0.10, and a second pre-run critique showed
## that no procedure can clear it on the realized scale: estimation error alone
## puts a correctly specified fit over the threshold in roughly half of the thin
## networks, so a PERFECT check fails a gate it deserves to pass. The gate is
## therefore also reported against what the best available model achieves on the
## same replicates. The oracle is the model that matches the truth: the shared
## fit where the interactions really are shared, the split fit where they are not.
oracle <- ES |>
  mutate(is_oracle = (drift == 0 & model == "common") |
                     (drift > 0  & model == "split_x1")) |>
  filter(is_oracle) |>
  transmute(cell, rep, shift, oracle_material = as.integer(abs(err_rd) > MATERIAL))

wr(PASS |> left_join(oracle, by = c("cell", "rep", "shift")) |>
     left_join(dw, by = "cell") |>
     filter(flag_dic5 == 0) |> group_by(shift) |>
     summarise(n = n(),
               passed_rate = weighted.mean(material, w),
               oracle_rate = weighted.mean(oracle_material, w),
               .groups = "drop") |>
     mutate(excess_over_oracle = passed_rate - oracle_rate), "verdict-vs-oracle")

## The same headline under uniform cell weights, so the reader can see how much
## of it is the declared deployment mixture and how much is the design.
wr(PASS |> pivot_longer(all_of(RULES), names_to = "rule", values_to = "flag") |>
     filter(flag == 0) |> group_by(rule, shift) |>
     summarise(n = n(), risk_uniform = mean(material),
               risk_sys_uniform = mean(material_systematic), .groups = "drop"),
   "pass-risk-uniform-weights")

## M1 on the realized scale is bounded below by the noise floor, so the rise is
## reported as floor plus excess rather than as a bare difference.
wr(pass_risk |> filter(rule == "flag_dic5") |>
     mutate(floor = risk_deployed[shift == 0],
            excess = risk_deployed - risk_deployed[shift == 0]) |>
     select(shift, risk_deployed, floor, excess,
            risk_sys_deployed), "m1-floor-and-excess")

## The verdict under the narrower reading of "the check fired": only the covariate
## that actually drifts.
wr(COMMON |> left_join(rep_flag_x1, by = c("cell", "rep")) |>
     left_join(dw, by = "cell") |> filter(flag_dic5 == 0) |>
     group_by(shift) |> summarise(n = n(),
       risk_deployed = weighted.mean(material, w),
       risk_sys_deployed = weighted.mean(material_systematic, w),
       .groups = "drop"), "verdict-x1-only")

## the prespecified verdict
## The registered verdict is on realized error, and it is reported alongside the
## fair-test version so a reader can see which of the two the check fails on.
verdict <- pass_risk |> filter(rule == "flag_dic5", shift == 1.0) |>
  mutate(threshold = VERDICT_PASS_RISK,
         passes = hi95 < VERDICT_PASS_RISK,
         passes_systematic_only = hi95_sys < VERDICT_PASS_RISK)
wr(verdict, "verdict")

## --- 3. M2, identification asymmetry -------------------------------------------
## Contraction is measured against THIS study's prior, normal(0, 2.5), which is
## not multinma's default of normal(scale = 10). Under a wider prior the same
## likelihood would show more contraction, so the registered 0.20 threshold is
## prior-relative. The ratio of posterior standard deviations is free of the
## prior in the limit where the data dominate and is reported beside it, because
## a second pre-run critique pointed out that M2's fate would otherwise be
## decided by a modelling choice rather than by the network.
wr(CH |> filter(xvar == "x1") |>
     group_by(n_studies, spread, tau_re) |>
     summarise(contraction_A = mean(contraction_A),
               contraction_C = mean(contraction_C),
               gap = mean(contraction_A - contraction_C),
               post_sd_A = mean(post_sd_A), post_sd_C = mean(post_sd_C),
               sd_ratio_C_over_A = mean(post_sd_C / post_sd_A),
               ## What the NETWORK alone says about the interaction contrast,
               ## with the prior removed. Treating the posterior as the normal
               ## combination of prior and likelihood, the data's own standard
               ## error is 1/sqrt(1/sd_post^2 - 1/sd_prior^2), the prior variance
               ## of the contrast being twice the prior variance of a coefficient.
               ## Compared against EPS = 0.1531, this is what the evidence itself
               ## can resolve, free of the prior we happened to choose.
               ##
               ## The median is taken, not the mean, and the fraction of
               ## replicates in which the posterior is NO TIGHTER than the prior
               ## is reported beside it. In those replicates the quantity is not
               ## merely large, it is undefined: the network contributed nothing
               ## about the contrast at all, and averaging a reciprocal over them
               ## would report a number where there is no information.
               post_sd_contrast = median(diff_sd),
               data_only_se_contrast = median(ifelse(
                 diff_sd^2 >= 2 * PRIOR_REG_SD^2, NA_real_,
                 1 / sqrt(1 / diff_sd^2 - 1 / (2 * PRIOR_REG_SD^2))), na.rm = TRUE),
               p_no_tighter_than_prior = mean(diff_sd^2 >= 2 * PRIOR_REG_SD^2),
               .groups = "drop"), "m2-contraction")

## --- 4. M3 and M4, the two readings ---------------------------------------------
## Both poolings, labelled. The manuscript previously quoted the two-covariate
## gap beside a table showing the one-covariate rates, and two reviewers reported
## the mismatch in successive rounds. Neither number was wrong; the text never
## said which it was.
wr(bind_rows(
     CH |> filter(drift == 0) |>
       summarise(pooling = "both covariates", dic5 = mean(flag_dic5),
                 post = mean(flag_post),
                 gap = abs(mean(flag_dic5) - mean(flag_post)), n = n()),
     CH |> filter(drift == 0, xvar == "x1") |>
       summarise(pooling = "drifting covariate only", dic5 = mean(flag_dic5),
                 post = mean(flag_post),
                 gap = abs(mean(flag_dic5) - mean(flag_post)), n = n())),
   "m3-null-rules")

## M4's denominator is covariate-CHECKS, and the two checks inside a replicate
## share a fitted network, so they are correlated and a binomial interval on 3200
## is anti-conservative. A reviewer worked this out from the interval width. The
## clustered interval below averages within a replicate first, which is the exact
## cluster-robust estimate at equal cluster size, and is the one reported.
m4_cl <- CH |> group_by(cell, rep) |>
  summarise(d = mean(flag_dic5 != flag_post), .groups = "drop")
wr(CH |> summarise(
     disagree = mean(flag_dic5 != flag_post),
     dic_only = mean(flag_dic5 == 1 & flag_post == 0),
     post_only = mean(flag_dic5 == 0 & flag_post == 1), n = n()) |>
   mutate(n_replicates = nrow(m4_cl),
          se_naive = sqrt(disagree * (1 - disagree) / n),
          se_clustered = sd(m4_cl$d) / sqrt(nrow(m4_cl)),
          lo = disagree - 1.959964 * se_clustered,
          hi = disagree + 1.959964 * se_clustered), "m4-disagreement")
wr(CH |> group_by(xvar, drift) |>
     summarise(disagree = mean(flag_dic5 != flag_post), n = n(), .groups = "drop"),
   "m4-disagreement-by-cell")

## --- 5. continuous scores as classifiers ---------------------------------------
## Weighted AUROC by run boundaries on the sorted score. `cum` MUST accumulate
## the CONTROL weight only: the numerator needs, for each case, the control
## weight ranked below it. Accumulating total weight instead is a real error that
## a first draft of this file contained; it was caught by the brute-force check
## below, which is why the check exists and is run rather than described.
wauc <- function(score, label, w = NULL) {
  keep <- is.finite(score) & !is.na(label)
  score <- score[keep]; label <- label[keep]
  w <- if (is.null(w)) rep(1, length(score)) else w[keep]
  if (length(unique(label)) < 2) return(NA_real_)
  o <- order(score); score <- score[o]; label <- label[o]; w <- w[o]
  pos  <- label == 1
  ctrl <- w * !pos
  cum  <- cumsum(ctrl)
  g <- cumsum(c(TRUE, diff(score) != 0))
  end_i <- which(!duplicated(g, fromLast = TRUE))
  tot_end <- cum[end_i]; tot_start <- c(0, tot_end[-length(tot_end)])
  below <- tot_start[g]; tied <- (tot_end - tot_start)[g]
  W1 <- sum(w[pos]); W0 <- sum(ctrl)
  if (W1 <= 0 || W0 <= 0) return(NA_real_)
  sum(w[pos] * (below[pos] + 0.5 * tied[pos])) / (W1 * W0)
}

## Run at analysis time, not once by hand: agreement with the definition on
## random cases including heavy ties.
verify_wauc <- function(n_case = 300, tol = 1e-12) {
  brute <- function(s, l, w) {
    p <- which(l == 1); q <- which(l == 0)
    num <- sum(outer(s[p], s[q], ">") * outer(w[p], w[q])) +
      0.5 * sum(outer(s[p], s[q], "==") * outer(w[p], w[q]))
    num / (sum(w[p]) * sum(w[q]))
  }
  set.seed(11); worst <- 0
  for (t in seq_len(n_case)) {
    n <- sample(20:150, 1)
    s <- switch((t %% 3) + 1, rnorm(n), round(rnorm(n), 1),
                sample(c(rep(0, round(n * 0.9)), rnorm(n - round(n * 0.9)))))
    l <- rbinom(n, 1, 0.4); w <- runif(n, 0.1, 3)
    if (length(unique(l)) < 2) next
    worst <- max(worst, abs(wauc(s, l, w) - brute(s, l, w)))
  }
  if (worst > tol) stop(sprintf("wauc disagrees with the definition by %.3g", worst))
  worst
}
WAUC_ERR <- verify_wauc()
cat(sprintf("wauc agrees with the definition to %.1e\n", WAUC_ERR))
## Written out rather than only printed, so the manuscript quotes the number this
## run produced instead of one transcribed from a console log.
wr(data.frame(max_abs_error = WAUC_ERR, n_random_cases = 300,
              tolerance = 1e-12), "wauc-verification")

## Hanley and McNeil's standard error, which is the interval that goes with the
## statistic this study registered. These AUROCs were computed from the first run
## onward and then never reported; two reviewers asked for them by name and a
## third recorded the omission as an undisclosed protocol deviation. They are
## reported now, with intervals, at every level the protocol named.
auc_se <- function(a, n1, n0) {
  if (!is.finite(a) || n1 < 2 || n0 < 2) return(NA_real_)
  q1 <- a / (2 - a); q2 <- 2 * a^2 / (1 + a)
  sqrt((a * (1 - a) + (n1 - 1) * (q1 - a^2) + (n0 - 1) * (q2 - a^2)) / (n1 * n0))
}
auc_row <- function(score, label, nm) {
  a <- wauc(score, label)
  n1 <- sum(label == 1, na.rm = TRUE); n0 <- sum(label == 0, na.rm = TRUE)
  s <- auc_se(a, n1, n0)
  data.frame(score = nm, auc = a, se = s, n_pos = n1, n_neg = n0,
             lo = max(0, a - 1.959964 * s), hi = min(1, a + 1.959964 * s))
}

score_tbl <- CH |> select(cell, rep, xvar, ddic, p_direction, p_exceeds_eps) |>
  filter(xvar == "x1") |>
  left_join(PASS |> select(cell, rep, shift, material), by = c("cell", "rep"))
wr(bind_rows(lapply(sort(unique(score_tbl$shift)), function(s) {
     d <- score_tbl |> filter(shift == s)
     cbind(shift = s, bind_rows(auc_row(-d$ddic, d$material, "negddic"),
                                auc_row(d$p_direction, d$material, "pdir"),
                                auc_row(d$p_exceeds_eps, d$material, "margin")))
   })), "auroc-vs-material")

## also against the check's OWN hypothesis, which is what it is designed for.
## Pooled over strata as well as stratified, because the per-stratum estimate on
## 600 checks is noisy and the pooled one is the resolvable quantity.
wr(CH |> group_by(n_studies, spread, tau_re) |>
     summarise(auc_negddic = wauc(-ddic, as.integer(contrast_true > 0)),
               auc_pdir = wauc(p_direction, as.integer(contrast_true > 0)),
               n = n(), .groups = "drop"), "auroc-vs-drift")

wr(bind_rows(lapply(sort(unique(CH$drift[CH$drift > 0])), function(d) {
     ## one violation level against the global null, which is the comparison the
     ## check is actually asked to make
     x <- CH |> filter(xvar == "x1", drift %in% c(0, d))
     cbind(drift = d, bind_rows(
       auc_row(-x$ddic, as.integer(x$drift == d), "negddic"),
       auc_row(x$p_direction, as.integer(x$drift == d), "pdir")))
   })), "auroc-vs-drift-pooled")

## --- 6. strategies ---------------------------------------------------------------
## check_then_relax uses EXACTLY the covariates that flagged, which the complete
## lattice makes available.
per_cov <- CH |> select(cell, rep, xvar, flag_dic5) |>
  pivot_wider(names_from = xvar, values_from = flag_dic5,
              names_prefix = "f_")
choice <- per_cov |> mutate(model_chosen = case_when(
  f_x1 == 0 & f_x2 == 0 ~ "common",
  f_x1 == 1 & f_x2 == 0 ~ "split_x1",
  f_x1 == 0 & f_x2 == 1 ~ "split_x2",
  TRUE ~ "split_all"))

strat <- bind_rows(
  ES |> filter(model == "common")    |> mutate(strategy = "always_common"),
  ES |> filter(model == "split_all") |> mutate(strategy = "always_relaxed"),
  ES |> inner_join(choice |> select(cell, rep, model_chosen), by = c("cell", "rep")) |>
    filter(model == model_chosen) |> mutate(strategy = "check_then_relax"))

reversal <- function(est, truth) ifelse(truth == 0, NA, as.integer(sign(est) != sign(truth)))
wr(strat |> group_by(strategy, shift, drift, n_studies, spread, tau_re) |>
     summarise(bias = mean(err_rd), rmse = sqrt(mean(err_rd^2)),
               p_material = mean(abs(err_rd) > MATERIAL),
               reversal = mean(reversal(rd_CA, rd_CA_true), na.rm = TRUE),
               n = n(), .groups = "drop"), "strategy-by-cell")

wr(strat |> left_join(dw, by = "cell") |> group_by(strategy, shift) |>
     summarise(bias = weighted.mean(err_rd, w),
               rmse = sqrt(weighted.mean(err_rd^2, w)),
               p_material = weighted.mean(abs(err_rd) > MATERIAL, w),
               reversal = weighted.mean(reversal(rd_CA, rd_CA_true), w, na.rm = TRUE),
               .groups = "drop"), "strategy-deployed")

## Strategy differences are PAIRED: the three strategies are scored on the same
## replicate, so the difference has a much smaller standard error than the
## difference of two independent rates. A reviewer asked for paired intervals and
## for the comparison restricted to replicates where every fit converged, since
## retaining a relaxed fit with R-hat 1.89 can make relaxing look worse for a
## reason that has nothing to do with the strategy.
strat_wide <- strat |> select(cell, rep, shift, strategy, err_rd) |>
  pivot_wider(names_from = strategy, values_from = err_rd) |>
  left_join(clean, by = c("cell", "rep")) |> left_join(dw, by = "cell")

## Both losses, because they do not agree and the disagreement is the finding.
## On absolute error check-then-relax wins at every displacement; on squared
## error the ordering against the restricted model flips at displacement 0. A
## reviewer found that flip in the study's own RMSE column while the manuscript
## claimed superiority "at every displacement". Reporting one loss and asserting
## the other is how that happened, so both are computed here and the squared-error
## difference is no longer discarded.
## Weighted mean of a paired difference and its standard error, with weights
## constant within a cell. Same structure as weighted_upper: average within a
## cell, then combine cells.
wmean_se <- function(x, cell, w) {
  s <- split(seq_along(x), cell)
  m  <- vapply(s, length, 1L)
  mu <- vapply(s, function(i) mean(x[i]), 0)
  v  <- vapply(s, function(i) if (length(i) > 1) var(x[i]) else 0, 0)
  W  <- vapply(s, function(i) w[i][1], 0)
  a <- W * m; a <- a / sum(a)
  c(sum(a * mu), sqrt(sum(a^2 * v / m)))
}

## Both losses AND both weightings, because they do not all agree and the
## disagreements are the finding. On unweighted absolute error check-then-relax
## wins everywhere; on DEPLOYMENT-WEIGHTED squared error the restricted model
## wins at displacement 0. An earlier draft reported an unweighted paired
## difference beside a deployment-weighted RMSE table and read them as one
## result. They are two.
paired <- function(d, a, b) {
  ok <- is.finite(d[[a]]) & is.finite(d[[b]])
  d <- d[ok, ]
  x  <- abs(d[[a]]) - abs(d[[b]])
  sq <- d[[a]]^2 - d[[b]]^2
  z <- 1.959964
  wx  <- wmean_se(x,  d$cell, d$w)
  wsq <- wmean_se(sq, d$cell, d$w)
  data.frame(comparison = paste(a, "minus", b), n = length(x),
             mean_abs_error_diff = mean(x),
             se = sd(x) / sqrt(length(x)),
             lo = mean(x) - z * sd(x) / sqrt(length(x)),
             hi = mean(x) + z * sd(x) / sqrt(length(x)),
             mean_sq_error_diff = mean(sq),
             se_sq = sd(sq) / sqrt(length(sq)),
             lo_sq = mean(sq) - z * sd(sq) / sqrt(length(sq)),
             hi_sq = mean(sq) + z * sd(sq) / sqrt(length(sq)),
             w_abs_diff = wx[1], w_abs_lo = wx[1] - z * wx[2],
             w_abs_hi = wx[1] + z * wx[2],
             w_sq_diff = wsq[1], w_sq_lo = wsq[1] - z * wsq[2],
             w_sq_hi = wsq[1] + z * wsq[2])
}
wr(do.call(rbind, lapply(TARGET_SHIFT, function(sh) {
  d <- strat_wide |> filter(shift == sh)
  cbind(shift = sh, subset = "all",
        rbind(paired(d, "check_then_relax", "always_common"),
              paired(d, "check_then_relax", "always_relaxed")))
})), "strategy-paired")

## and restricted to the sixteen cells where the estimand is unambiguous
strat_wide_tau0 <- strat_wide |>
  left_join(DESIGN[, c("cell", "tau_re")], by = "cell") |> filter(tau_re == 0)
wr(do.call(rbind, lapply(TARGET_SHIFT, function(sh) {
  d <- strat_wide_tau0 |> filter(shift == sh)
  cbind(shift = sh, subset = "tau_re = 0",
        rbind(paired(d, "check_then_relax", "always_common"),
              paired(d, "check_then_relax", "always_relaxed")))
})), "strategy-paired-tau0")

wr(do.call(rbind, lapply(TARGET_SHIFT, function(sh) {
  d <- strat_wide |> filter(shift == sh, all_clean)
  cbind(shift = sh, subset = "converged only",
        rbind(paired(d, "check_then_relax", "always_common"),
              paired(d, "check_then_relax", "always_relaxed")))
})), "strategy-paired-clean")

wr(strat |> inner_join(clean, by = c("cell", "rep")) |> filter(all_clean) |>
     left_join(dw, by = "cell") |> group_by(strategy, shift) |>
     summarise(n = n(), rmse = sqrt(weighted.mean(err_rd^2, w)),
               p_material = weighted.mean(abs(err_rd) > MATERIAL, w),
               .groups = "drop"), "strategy-deployed-clean")

## --- 7. net benefit -------------------------------------------------------------
## The action is to distrust the adjusted estimate and commission individual data.
## t is the probability of material error at which that cost is worth paying.
nb <- function(flag, material, w, t) {
  tp <- weighted.mean(flag == 1 & material == 1, w)
  fp <- weighted.mean(flag == 1 & material == 0, w)
  tp - fp * t / (1 - t)
}
NBD <- PASS |> left_join(dw, by = "cell") |> filter(shift == 1.0)
wr(do.call(rbind, lapply(NB_THRESHOLDS, function(t) {
  prev <- weighted.mean(NBD$material, NBD$w)
  data.frame(threshold = t,
             distrust_all = prev - (1 - prev) * t / (1 - t),
             distrust_none = 0,
             dic2 = nb(NBD$flag_dic2, NBD$material, NBD$w, t),
             dic5 = nb(NBD$flag_dic5, NBD$material, NBD$w, t),
             dic10 = nb(NBD$flag_dic10, NBD$material, NBD$w, t),
             posterior = nb(NBD$flag_post, NBD$material, NBD$w, t),
             margin = nb(NBD$flag_margin, NBD$material, NBD$w, t))
})), "net-benefit")

## --- 8. calibration, leave one factor level out ---------------------------------
## Folds are FACTOR LEVELS, never cell indices, and all four displacements from
## one simulated dataset stay together because the fold is chosen on (cell, rep).
CAL <- PASS |> filter(shift == 1.0) |>
  left_join(CH |> filter(xvar == "x1") |> select(cell, rep, ddic, p_direction),
            by = c("cell", "rep"))

FOLDS <- do.call(c, lapply(names(FACTORS), function(f)
  lapply(FACTORS[[f]], function(l) list(factor = f, level = l))))

calib <- do.call(rbind, lapply(FOLDS, function(fd) {
  te <- CAL[[fd$factor]] == fd$level
  do.call(rbind, lapply(c("ddic", "p_direction"), function(sc) {
    tr <- CAL[!te, ]; ts <- CAL[te, ]
    if (length(unique(tr$material)) < 2 || !nrow(ts)) return(NULL)
    m <- glm(material ~ ., data = data.frame(material = tr$material, s = tr[[sc]]),
             family = binomial())
    p <- predict(m, newdata = data.frame(s = ts[[sc]]), type = "response")
    ## also a mapping that KNOWS the displacement, to show what the check
    ## would need in order to transport
    data.frame(factor = fd$factor, level = as.character(fd$level), score = sc,
               n_test = nrow(ts), observed = mean(ts$material),
               predicted = mean(p), abs_error = abs(mean(p) - mean(ts$material)))
  }))
}))
wr(calib, "calibration-lofo")

CAL_S <- PASS |> left_join(CH |> filter(xvar == "x1") |> select(cell, rep, ddic),
                           by = c("cell", "rep"))
calib_s <- do.call(rbind, lapply(FOLDS, function(fd) {
  te <- CAL_S[[fd$factor]] == fd$level
  tr <- CAL_S[!te, ]; ts <- CAL_S[te, ]
  if (length(unique(tr$material)) < 2 || !nrow(ts)) return(NULL)
  m0 <- glm(material ~ ddic, data = tr, family = binomial())
  m1 <- glm(material ~ ddic + shift, data = tr, family = binomial())
  p0 <- predict(m0, ts, type = "response"); p1 <- predict(m1, ts, type = "response")
  ## Calibration IN THE LARGE (mean predicted against mean observed) is the
  ## registered metric, and it is nearly blind to a predictor whose distribution
  ## is the same in training and test: all four displacements appear on both
  ## sides of every fold, so adding one cannot move the average prediction much.
  ## A reviewer pointed out that this does NOT show displacement is uninformative,
  ## which is what two earlier drafts concluded from it. Held-out discrimination
  ## is what answers that question, so it is computed here beside the registered
  ## metric rather than substituted for it.
  data.frame(factor = fd$factor, level = as.character(fd$level),
             blind = abs(mean(p0) - mean(ts$material)),
             knows_shift = abs(mean(p1) - mean(ts$material)),
             auc_blind = wauc(p0, ts$material),
             auc_knows_shift = wauc(p1, ts$material),
             coef_shift = unname(coef(m1)["shift"]),
             n_test = nrow(ts))
}))
wr(calib_s, "calibration-target-blind-vs-not")

## --- 9. prior sensitivity ---------------------------------------------------------
## What this arm actually contains. The protocol registered eight cells at 100
## replicates; a reviewer showed the published fit count could not come from
## that, and counting here is how the shortfall was established. Recorded as
## data so the manuscript never has to derive it from a group size again.
if (!is.null(P1) && nrow(P1$checks)) {
  wr(P1$checks |> group_by(cell) |>
       summarise(replicates = n_distinct(rep), .groups = "drop") |>
       summarise(cells = n(), replicates_per_cell = paste(sort(unique(replicates)),
                                                          collapse = "/"),
                 replicates_total = sum(replicates),
                 models_per_replicate = length(FIT_SPLITS),
                 fits_total = sum(replicates) * length(FIT_SPLITS),
                 registered_cells = 8, registered_replicates_per_cell = 100),
     "prior-sensitivity-accounting")
}
if (!is.null(P1) && nrow(P1$checks)) {
  cmp <- bind_rows(
    CH |> filter(cell %in% unique(P1$checks$cell)) |> mutate(prior = "normal(0, 2.5)"),
    P1$checks |> mutate(flag_dic5 = as.integer(ddic < -5), prior = "normal(0, 1)"))
  wr(cmp |> mutate(prior_sd = ifelse(prior == "normal(0, 1)", 1, PRIOR_REG_SD)) |>
       group_by(prior, xvar, drift) |>
       summarise(flag_rate = mean(flag_dic5), contraction_C = mean(contraction_C),
                 post_sd_contrast = median(diff_sd),
                 ## the same prior-free quantity under each prior. If the two
                 ## agree, the posterior really is prior plus likelihood and the
                 ## likelihood is what it is.
                 data_only_se = median(ifelse(
                   diff_sd^2 >= 2 * first(prior_sd)^2, NA_real_,
                   1 / sqrt(1 / diff_sd^2 - 1 / (2 * first(prior_sd)^2))), na.rm = TRUE),
                 n = n(), .groups = "drop"),
     "prior-sensitivity")
}

## --- 10. the amendment cells, reported on their own ----------------------------
## Drift 0.15 is exactly one EPS: the interaction contrast at which the target
## estimate becomes materially wrong at displacement 1. This is the region the
## registered grid skipped, and it is where a check that is worth running has to
## work.
if (length(intersect(BOUNDARY_CELLS, unique(CH_ALL$cell)))) {
  BC <- CH_ALL |> filter(cell %in% BOUNDARY_CELLS) |>
    mutate(flag_dic5 = as.integer(ddic < -5), flag_dic2 = as.integer(ddic < -2),
           flag_post = post_flag,
           flag_margin = as.integer(p_exceeds_eps > 0.95),
           affirm_shared = as.integer(1 - p_exceeds_eps > 0.95))
  wr(BC |> filter(xvar == "x1") |>
       group_by(n_studies, spread, tau_re) |>
       summarise(dic5 = mean(flag_dic5), dic2 = mean(flag_dic2),
                 post = mean(flag_post), margin = mean(flag_margin),
                 affirm = mean(affirm_shared),
                 post_sd_contrast = mean(diff_sd),
                 sd_ratio_C_over_A = mean(post_sd_C / post_sd_A),
                 n = n(), .groups = "drop"), "boundary-detection")

  BE <- ES_ALL |> filter(cell %in% BOUNDARY_CELLS, model == "common")
  wr(BE |> group_by(shift, n_studies, spread, tau_re) |>
       summarise(bias = mean(err_rd), rmse = sqrt(mean(err_rd^2)),
                 p_material = mean(abs(err_rd) > MATERIAL),
                 true_rd = first(rd_CA_true), n = n(), .groups = "drop"),
     "boundary-error")
}

cat("analysis written to", RES, "\n")
