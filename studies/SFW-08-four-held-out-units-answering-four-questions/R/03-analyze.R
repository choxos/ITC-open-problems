## PSIS against exact leave-unit-out elpd, Pareto-k, model selection by unit; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", pattern = "^cell", full.names = TRUE), readRDS)), g, by = "cell"); d$err <- d$elpd_psis - d$elpd_exact
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$unit, d$model), drop = TRUE), function(z) { ok <- !is.na(z$err); n <- sum(ok); z <- z[ok, ]
  data.frame(cell = z$cell[1], unit = z$unit[1], model = z$model[1], n = n, fail_rate = 1 - n / (n + sum(!ok)), n_terms = mean(z$n_terms), elpd_exact = mean(z$elpd_exact),
             bias = mean(z$err), mcse = stats::sd(z$err) / sqrt(n), mean_abs_err = mean(abs(z$err)), mcse_abs = stats::sd(abs(z$err)) / sqrt(n),
             any_k07 = mean(z$k_max > 0.7), share_units_k07 = sum(z$n_bad) / sum(z$n_terms),
             abs_err_per_bad_unit = if (sum(z$n_bad)) sum(z$abs_err_bad) / sum(z$n_bad) else NA, abs_err_per_good_unit = sum(z$abs_err_good) / sum(z$n_terms - z$n_bad)) }))
summ <- merge(g, summ, by = "cell"); summ <- summ[order(summ$cell, summ$unit, summ$model), ]; write.csv(summ, "results/summary.csv", row.names = FALSE)

w <- merge(d[d$model == "M1", c("cell", "rep", "unit", "elpd_exact", "elpd_psis")], d[d$model == "M0", c("cell", "rep", "unit", "elpd_exact", "elpd_psis")], by = c("cell", "rep", "unit"))
w$dx <- w$elpd_exact.x - w$elpd_exact.y; w$dp <- w$elpd_psis.x - w$elpd_psis.y; w <- w[stats::complete.cases(w), ]
sel <- do.call(rbind, lapply(split(w, list(w$cell, w$unit), drop = TRUE), function(z) { n <- nrow(z); a <- mean(sign(z$dp) == sign(z$dx))
  data.frame(cell = z$cell[1], unit = z$unit[1], exact_picks_true = mean(z$dx > 0), psis_picks_true = mean(z$dp > 0), sign_agreement = a, mcse_agreement = sqrt(a * (1 - a) / n)) }))
fal <- do.call(rbind, lapply(split(w, w$cell), function(z) { x <- merge(z[z$unit == "pointwise", c("rep", "dx")], z[z$unit == "study", c("rep", "dx")], by = "rep")
  data.frame(cell = z$cell[1], pointwise_study_same_choice = mean(sign(x$dx.x) == sign(x$dx.y))) }))
sel <- merge(merge(g, sel, by = "cell"), fal, by = "cell"); write.csv(sel, "results/selection.csv", row.names = FALSE)

pc <- summ[summ$ipd == 1 & summ$tau == 0.3 & summ$leverage == "one" & summ$unit == "study" & summ$model == "M1", ]
ps <- sel[sel$ipd == 1 & sel$tau == 0.3 & sel$leverage == "one" & sel$unit == "study", ]
verdict <- if (pc$mean_abs_err <= 0.5 && ps$sign_agreement >= 0.95) "PSIS ADEQUATE AT THE STUDY UNIT: the deliverable is the unit convention, with exact refits only where k fails" else
  if (pc$mean_abs_err >= 1 || ps$sign_agreement < 0.90) "EXACT REFIT OR A GROUPED FALLBACK REQUIRED AT THE STUDY UNIT" else "INTERMEDIATE: reported as a near-miss in both directions"
nc <- summ[summ$ipd == 6 & summ$tau == 0 & summ$leverage == "none" & summ$unit == "pointwise" & summ$model == "M1", ]
null_ok <- nc$mean_abs_err < 0.25 && nc$share_units_k07 < 0.01
pos_ok <- pc$any_k07 >= 0.25
immaterial <- all(sel$pointwise_study_same_choice[!duplicated(sel$cell)] >= 0.95)
sc <- summ[summ$unit == "pointwise" & summ$model == "M1" & summ$tau == 0 & summ$leverage == "none", ]
f3 <- function(x) sprintf("%.3f", x)
md <- c("# Decision", "", sprintf("**Registered primary: %s.** Study unit, one IPD study of six, tau 0.3, one influential study, M1: mean |PSIS - exact| per network %s (MCSE %s), bias %s; model-choice sign agreement %s (MCSE %s).",
          verdict, f3(pc$mean_abs_err), f3(pc$mcse_abs), f3(pc$bias), f3(ps$sign_agreement), f3(ps$mcse_agreement)), "",
  sprintf("Null control (all IPD, tau 0, no leverage, pointwise: mean |error| < 0.25 and under 1%% of units with k > 0.7): %s (%s; %s).", if (null_ok) "passes" else "FAILS", f3(nc$mean_abs_err), f3(nc$share_units_k07)), "",
  sprintf("Positive control (primary cell, study unit: some k > 0.7 in at least 25%% of networks): %s (%s).", if (pos_ok) "passes" else "FAILS: the fallback has nothing to fall back from here", f3(pc$any_k07)), "",
  sprintf("Falsifier (pointwise and study-unit exact elpd choose the same model in at least 95%% of networks in every cell): %s; range %s to %s.",
          if (immaterial) "the unit is immaterial for selection on this grid, and the deliverable reduces to a reporting warning" else "does not hold",
          f3(min(fal$pointwise_study_same_choice)), f3(max(fal$pointwise_study_same_choice))), "",
  sprintf("Scale (consequence 1, tau 0, no leverage, M1): pointwise exact elpd %s with %s terms at 1, 3 and 6 IPD studies.", paste(sprintf("%.1f", sc$elpd_exact), collapse = ", "), paste(sprintf("%.0f", sc$n_terms), collapse = ", ")), "",
  "| IPD studies | tau | leverage | unit | model | failed | terms | exact elpd | bias (MCSE) | mean abs error | networks with k > 0.7 | units with k > 0.7 | abs error per k > 0.7 unit | per other unit |",
  "|---:|---:|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %d | %.1f | %s | %s | %s | %.3f | %.0f | %.1f | %.3f (%.3f) | %.3f | %.3f | %.4f | %s | %.4f |", summ$ipd, summ$tau, summ$leverage, summ$unit, summ$model, summ$fail_rate, summ$n_terms,
          summ$elpd_exact, summ$bias, summ$mcse, summ$mean_abs_err, summ$any_k07, summ$share_units_k07, ifelse(is.na(summ$abs_err_per_bad_unit), "", f3(summ$abs_err_per_bad_unit)), summ$abs_err_per_good_unit), "",
  "| IPD studies | tau | leverage | unit | exact picks M1 | PSIS picks M1 | sign agreement (MCSE) | pointwise and study agree |", "|---:|---:|---|---|---:|---:|---:|---:|",
  sprintf("| %d | %.1f | %s | %s | %.3f | %.3f | %.3f (%.3f) | %.3f |", sel$ipd, sel$tau, sel$leverage, sel$unit, sel$exact_picks_true, sel$psis_picks_true, sel$sign_agreement, sel$mcse_agreement, sel$pointwise_study_same_choice), "")
writeLines(md, "results/decision.md"); cat(md[1:11], sep = "\n")
