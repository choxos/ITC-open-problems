## The split-chain check as a classifier of material residual contrast error; controls; decision.
source("R/00-model.R")
g <- build_grid(); bind <- function(l) { cols <- unique(unlist(lapply(l, names))); do.call(rbind, lapply(l, function(z) { z[setdiff(cols, names(z))] <- NA; z[cols] })) }
raw <- bind(lapply(list.files("results/run", full.names = TRUE), readRDS)); fails <- tapply(!is.na(raw$error), raw$cell, sum)
d <- merge(raw[is.na(raw$error), ], g, by = "cell")
ds <- dstar(n_set = 400); DSTAR <- ds$dstar
d$material <- abs(d$r) >= MATERIAL
d$fire <- pmax(d$shift_q, d$shift_lp) >= DSTAR
d$fire_prefix <- abs(d$r_prefix) >= MATERIAL
f2 <- function(x) sprintf("%.2f", x); f3 <- function(x) sprintf("%.3f", x)

## Sensitivity and false-alarm rate with a dataset-clustered bootstrap MCSE.
oc <- function(z, flag) { set.seed(1)
  cnt <- t(vapply(split(z, z$rep), function(y) c(sum(y$material & y[[flag]]), sum(y$material), sum(!y$material & y[[flag]]), sum(!y$material)), numeric(4)))
  est <- function(m) c(sens = sum(m[, 1]) / sum(m[, 2]), fpr = sum(m[, 3]) / sum(m[, 4]))
  bs <- replicate(1000, est(cnt[sample.int(nrow(cnt), replace = TRUE), , drop = FALSE]))
  c(est(cnt), sens_mcse = stats::sd(bs[1, ], na.rm = TRUE), fpr_mcse = stats::sd(bs[2, ], na.rm = TRUE), n_material = sum(z$material), n = nrow(z)) }
main <- d[d$kind == "main", ]
tab <- do.call(rbind, lapply(split(main, main$cell), function(z) data.frame(cell = z$cell[1], lik = z$lik[1], S = z$S[1],
  t(oc(z, "fire")), prefix_sens = oc(z, "fire_prefix")[["sens"]], prefix_fpr = oc(z, "fire_prefix")[["fpr"]],
  rho_arm = stats::cor(z$arm_err_max, abs(z$r), method = "spearman"), ref_stable = mean(abs(z$r[z$Q == 512]) <= 0.05))))
byq <- do.call(rbind, lapply(split(main, list(main$cell, main$Q), drop = TRUE), function(z) data.frame(cell = z$cell[1], lik = z$lik[1], S = z$S[1], Q = z$Q[1],
  med_abs_r = stats::median(abs(z$r)), material = mean(z$material), fire = mean(z$fire), fire_prefix = mean(z$fire_prefix), med_shift = stats::median(pmax(z$shift_q, z$shift_lp)))))
byq <- byq[order(byq$cell, byq$Q), ]; write.csv(tab, "results/summary.csv", row.names = FALSE); write.csv(byq, "results/by-Q.csv", row.names = FALSE)

## Registered primary: M-spline, 12 aggregate studies, pooled over Q.
pc <- tab[tab$lik == "mspline" & tab$S == 12, ]
val <- d[d$kind == "validate", ]; agree <- mean(val$fire == val$real_fired)
verdict <- if (agree < 0.8) "NOT EVALUABLE BY EMULATION: the emulated check disagrees with the real check in more than 20% of validation fits" else
  if (pc$n_material < 20) "NOT EVALUABLE: fewer than 20 material (dataset, Q) pairs in the primary cell" else
  if (pc$sens < 0.5) "CONFIRMED: the split-chain check misses most material residual contrast error" else
  if (pc$sens >= 0.9) "REFUTED: the split-chain check flags material residual contrast error" else "MIXED: see the table"
nul <- d[d$kind == "null", ]; null_ok <- max(abs(nul$r)) <= 0.01 && max(nul$shift_q, na.rm = TRUE) <= 0.01
pmain <- main[main$lik == "mspline" & main$S == 12 & main$Q == 16, ]; pos <- mean(pmain$material)
md <- c("# Decision", "", sprintf("**Registered primary: %s.**", verdict), "",
  sprintf("Primary cell (M-spline, 12 aggregate studies, 5 covariates): sensitivity of the split-chain check to material residual contrast error (|r| >= %.2f SD) %s (MCSE %s) over %d material of %d (dataset, Q) pairs; false-alarm rate %s (MCSE %s). At Q 64: material in %s of datasets, check fires in %s.",
          MATERIAL, f3(pc$sens), f3(pc$sens_mcse), pc$n_material, pc$n, f3(pc$fpr), f3(pc$fpr_mcse),
          f2(byq$material[byq$cell == pc$cell & byq$Q == 64]), f2(byq$fire[byq$cell == pc$cell & byq$Q == 64])), "",
  sprintf("Firing threshold DSTAR = %s posterior SD (multinma's rules on 400 sets of ideal chains per shift). Emulator validation: agreement with the real check %s over %d fits (registered: at least 0.8).",
          f3(DSTAR), f2(agree), nrow(val)), "",
  sprintf("Candidate check, Laplace prefix difference |c(Q) - c(Q/2)| >= %.2f SD, primary cell: sensitivity %s, false-alarm rate %s.", MATERIAL, f3(pc$prefix_sens), f3(pc$prefix_fpr)), "",
  sprintf("Positive control (primary cell, Q 16 material in at least half of datasets): %s (%s).", pos >= 0.5, f2(pos)), "",
  sprintf("Null control (published covariate SDs zero: every |r| and every shift at most 0.01): %s (largest |r| %.1e).", null_ok, max(abs(nul$r))), "",
  sprintf("Reference stability (|r(512)| at most 0.05 SD in at least 95%% of datasets): %s.", paste(sprintf("cell %d %s", tab$cell, f2(tab$ref_stable)), collapse = ", ")), "",
  sprintf("Falsifier for consequence 2 (Spearman of the largest per-arm log-likelihood error with |r| at least 0.9, so a scalar summary suffices): %s (%s).",
          pc$rho_arm >= 0.9, f2(pc$rho_arm)), "",
  sprintf("Failed datasets per cell: %s.", paste(sprintf("%s: %d", names(fails), fails), collapse = ", ")), "",
  "| cell | baseline | S | Q | median abs r | share material | share check fires | share prefix fires | median largest shift |", "|---:|---|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %d | %s | %d | %d | %.3f | %.2f | %.2f | %.2f | %.3f |", byq$cell, byq$lik, byq$S, byq$Q, byq$med_abs_r, byq$material, byq$fire, byq$fire_prefix, byq$med_shift), "")
writeLines(md, "results/decision.md"); cat(md[1:19], sep = "\n")
