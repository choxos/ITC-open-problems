## Performance by cell and method, onsets with paired-bootstrap MCSE, controls; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
d$err <- d$est - d$truth

perf <- function(z) { e <- z$err[!is.na(z$err)]; n <- length(e)
  c(n_ok = n, fail = mean(is.na(z$err)), bias = mean(e), mcse = stats::sd(e) / sqrt(n), sd = stats::sd(e), sd_mcse = stats::sd(e) / sqrt(2 * (n - 1)),
    rmse = sqrt(mean(e^2)), coverage = if (all(is.na(z$se))) NA else mean(abs(z$err) <= 1.96 * z$se, na.rm = TRUE),
    ess_frac = stats::median(z$ess, na.rm = TRUE) / (2 * N_ARM), mass_out = stats::median(z$mass_out)) }
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) data.frame(cell = z$cell[1], method = z$method[1], t(perf(z)))))
summ <- merge(g, summ, by = "cell")
ref <- summ[summ$level == 1, c("curvature", "scale", "method", "sd")]; names(ref)[4] <- "sd0"
summ <- merge(summ, ref, by = c("curvature", "scale", "method")); summ$sd_ratio <- summ$sd / summ$sd0
summ <- summ[order(summ$cell, summ$method), ]
write.csv(summ, "results/summary.csv", row.names = FALSE)

## Onsets per scale, curvature and method, from bias and SD by level.
onsets <- function(s, mat = MATERIAL, sdr = SD_RATIO) do.call(rbind, lapply(split(s, list(s$scale, s$curvature, s$method), drop = TRUE), function(z) { z <- z[order(z$d2), ]
  ob <- onset(z$d2, abs(z$bias), mat); ov <- onset(z$d2, z$sd / z$sd[1], sdr)
  data.frame(scale = z$scale[1], curvature = z$curvature[1], method = z$method[1], bias_onset = ob, var_onset = ov, onset = min(ob, ov),
             signature = if (ob == BEYOND && ov == BEYOND) "none" else if (ob < ov) "bias" else if (ov < ob) "variance" else "both") }))
decide <- function(o) { b <- o[o$scale == "binary", ]; on <- function(m, k) b$onset[b$method == m & b$curvature == k]
  c(sep_strong = abs(on("stc", "strong") - on("maic", "strong")), stc_move = on("stc", "moderate") - on("stc", "strong"),
    maic_move = abs(on("maic", "moderate") - on("maic", "strong")), sep_moderate = abs(on("stc", "moderate") - on("maic", "moderate")),
    dr_margin = min(vapply(names(BETA2), function(k) on("dr", k) - max(on("maic", k), on("stc", k)), 0))) }
## DR wins if at every curvature its onset is no more than half a grid step earlier
## than the later of MAIC's and STC's.
os <- onsets(summ); dec <- decide(os)
## Sensitivity, reported and not tested: the separation depends on the threshold pair,
## the movement with curvature much less.
sens <- rbind(bias_0.05 = decide(onsets(summ, 0.05, SD_RATIO)), sd_ratio_1.5 = decide(onsets(summ, MATERIAL, 1.5)), both = decide(onsets(summ, 0.05, 1.5)))

## Paired bootstrap over replicate indices: the same indices in every cell (common random numbers).
set.seed(MASTER_SEED + 1); grp <- split(d, list(d$cell, d$method), drop = TRUE)
bs <- t(replicate(200, { cnt <- tabulate(sample.int(N_SIM, replace = TRUE), N_SIM)
  s <- do.call(rbind, lapply(grp, function(z) { ok <- !is.na(z$err); wz <- cnt[z$rep[ok]]; e <- z$err[ok]; m <- sum(wz * e) / sum(wz)
    data.frame(cell = z$cell[1], method = z$method[1], bias = m, sd = sqrt(sum(wz * (e - m)^2) / (sum(wz) - 1))) }))
  o <- onsets(merge(g, s, by = "cell")); c(decide(o), setNames(o$onset, paste(o$scale, o$curvature, o$method))) }))
os$onset_mcse <- apply(bs[, paste(os$scale, os$curvature, os$method), drop = FALSE], 2, stats::sd)
dmcse <- apply(bs[, names(dec)], 2, stats::sd)
write.csv(os, "results/onsets.csv", row.names = FALSE)

STEP <- D2[2] - D2[1]
verdict <- if (dec[["sep_strong"]] >= STEP && dec[["stc_move"]] >= STEP && dec[["maic_move"]] < STEP) "CONFIRMED: the families fail by different functionals and no single divergence level orders them" else
  if (dec[["sep_strong"]] < STEP && dec[["sep_moderate"]] < STEP) "REFUTED: weighting and outcome-model onsets coincide at both nonlinear curvatures" else
  if (max(dec[["sep_strong"]], dec[["sep_moderate"]]) >= STEP && abs(dec[["stc_move"]]) < STEP) "SEPARATED, MECHANISM WRONG: the outcome-model onset does not move with curvature" else "MIXED: see the onset table"
## Null control on the methods without a regularization bias; the forest's is reported.
nul <- summ[summ$level == 1 & summ$method != "rf", ]; null_ok <- all(abs(nul$bias) <= 0.05) && all(nul$coverage[nul$method %in% c("maic", "stc")] >= 0.93 & nul$coverage[nul$method %in% c("maic", "stc")] <= 0.97)
rf0 <- summ$bias[summ$level == 1 & summ$method == "rf"]
lin <- summ[summ$curvature == "linear", ]
pos_ok <- all(abs(lin$bias[lin$method == "stc"]) <= 0.03) && all(lin$sd_ratio[lin$method == "maic" & lin$level == length(D2)] >= SD_RATIO)
f2 <- function(x) sprintf("%.2f", x)
md <- c("# Decision", "", sprintf("**Registered primary (binary scale): %s.**", verdict), "",
  sprintf("Onset separation at strong curvature |STC - MAIC| %s (MCSE %s; registered at least %.1f). STC onset moved %s from moderate to strong curvature (MCSE %s; at least %.1f); MAIC onset moved %s (MCSE %s; less than %.1f). Separation at moderate curvature %s (MCSE %s).",
          f2(dec[["sep_strong"]]), f2(dmcse[["sep_strong"]]), STEP, f2(dec[["stc_move"]]), f2(dmcse[["stc_move"]]), STEP, f2(dec[["maic_move"]]), f2(dmcse[["maic_move"]]), STEP,
          f2(dec[["sep_moderate"]]), f2(dmcse[["sep_moderate"]])), "",
  sprintf("Threshold sensitivity (not tested; separation at strong, STC movement, MAIC movement): %s.",
          paste(sprintf("%s %s, %s, %s", rownames(sens), f2(sens[, "sep_strong"]), f2(sens[, "stc_move"]), f2(sens[, "maic_move"])), collapse = "; ")), "",
  sprintf("Comparator that can win: DR onset minus the later of MAIC's and STC's, smallest over curvature, %s (MCSE %s); DR wins if at least %.1f: %s.",
          f2(dec[["dr_margin"]]), f2(dmcse[["dr_margin"]]), -STEP / 2, dec[["dr_margin"]] >= -STEP / 2), "",
  sprintf("Null control (complete overlap: |bias| at most 0.05 for unadjusted, MAIC, STC and DR; MAIC and STC coverage 0.93 to 0.97): %s; largest |bias| %.3f, coverage %.3f to %.3f. Forest bias at complete overlap %.3f to %.3f (reported).",
          null_ok, max(abs(nul$bias)), min(nul$coverage, na.rm = TRUE), max(nul$coverage, na.rm = TRUE), min(rf0), max(rf0)), "",
  sprintf("Positive control (linear curvature: STC |bias| at most 0.03 at every level; MAIC SD ratio at least 2 at the top level): %s.", pos_ok), "",
  sprintf("Failed estimates: %d of %d (by method: %s).", sum(is.na(d$err)), nrow(d), paste(sprintf("%s %d", names(tapply(is.na(d$err), d$method, sum)), tapply(is.na(d$err), d$method, sum)), collapse = ", ")), "",
  sprintf("## Onsets in log(1 + chi^2) (%.1f = not reached)", BEYOND), "",
  "| scale | curvature | method | bias onset | variance onset | onset (MCSE) | signature |", "|---|---|---|---:|---:|---:|---|",
  sprintf("| %s | %s | %s | %.2f | %.2f | %.2f (%.2f) | %s |", os$scale, os$curvature, os$method, os$bias_onset, os$var_onset, os$onset, os$onset_mcse, os$signature), "",
  "## By cell and method", "",
  "| scale | curvature | log(1+chi2) | method | bias (MCSE) | SD | SD ratio | RMSE | coverage | ESS/n | target mass beyond source | failed |",
  "|---|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %s | %s | %.1f | %s | %.3f (%.3f) | %.3f | %.2f | %.3f | %s | %.3f | %.3f | %.3f |", summ$scale, summ$curvature, summ$d2, summ$method, summ$bias, summ$mcse,
          summ$sd, summ$sd_ratio, summ$rmse, ifelse(is.na(summ$coverage), "", sprintf("%.3f", summ$coverage)), summ$ess_frac, summ$mass_out, summ$fail), "")
writeLines(md, "results/decision.md"); cat(md[1:13], sep = "\n")
