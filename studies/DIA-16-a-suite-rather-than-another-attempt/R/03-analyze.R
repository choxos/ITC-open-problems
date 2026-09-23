## Discrepancies with bootstrap SEs, the suite's ground truth, controls and the registered decision.
source("R/00-model.R")
g <- build_grid()
res <- lapply(sprintf("results/run/cell-%02d.rds", g$unit), readRDS)
failed <- vapply(res, function(r) !is.null(r$error), TRUE)
summ <- do.call(rbind, lapply(res[!failed], function(r) { ok <- stats::complete.cases(r$boot); se <- apply(r$boot[ok, , drop = FALSE], 2, rse); p <- r$point
  data.frame(r$unit, ref = p[["ref"]], se_ref = se[["ref"]], est_naive = p[["est_naive"]], se_naive = se[["est_naive"]], est_maic = p[["est_maic"]], se_maic = se[["est_maic"]],
             d_naive = p[["d_naive"]], z_naive = p[["d_naive"]] / se[["d_naive"]], d_maic = p[["d_maic"]], z_maic = p[["d_maic"]] / se[["d_maic"]],
             z_mcse = abs(p[["d_maic"]] / se[["d_maic"]]) * 1.16 / sqrt(sum(ok)), ess = p[["ess"]], bal = p[["bal"]], sep = p[["sep"]], boot_ok = sum(ok), nS = r$nS, nM = r$nM) }))
write.csv(summ, "results/summary.csv", row.names = FALSE)
pub <- do.call(rbind, lapply(res[!failed], function(r) { p <- r$published; x <- p[-(1:2)]
  data.frame(r$unit, n_B = p[["nB"]], events_B = p[["eventsB"]], published_means = paste(sprintf("%s=%.4g", names(x), x), collapse = "; "), ref = r$point[["ref"]], se_ref = rse(r$boot[, "ref"])) }))
write.csv(pub[pub$kind == "main", ], "results/suite.csv", row.names = FALSE)

nl <- do.call(rbind, lapply(list.files("results/run", "^null-", full.names = TRUE), function(f) readRDS(f)$z)); nl <- nl[stats::complete.cases(nl), , drop = FALSE]
rej <- colMeans(abs(nl) > 1.96); rej_mcse <- sqrt(rej * (1 - rej) / nrow(nl))
## If the half-split null rejects MAIC above 0.08, the threshold becomes the null's 95th percentile of |z|.
crit <- if (rej[["d_maic"]] > 0.08) unname(stats::quantile(abs(nl[, "d_maic"]), 0.95)) else 1.96
m <- summ[summ$kind == "main", ]; pd <- mean(abs(m$z_maic) > crit); pd196 <- mean(abs(m$z_maic) > 1.96)
s <- summ[summ$kind == "shift", ]; pos <- any(abs(s$z_naive) > 1.96)
verdict <- if (pd >= 0.20) "NOT DECISION-GRADE: the matching bridge disagrees with the randomized result beyond sampling error in at least 20% of deletions" else
  if (pd <= 0.10) { if (pos) "CONSISTENT WITH SAMPLING ERROR: disagreement in at most 10% of deletions" else
    "NO EXCESS DISAGREEMENT DETECTED, NOT CONSISTENT: the positive control failed, so the suite contains no demonstrated hard case" } else "INTERMEDIATE"
sp <- function(a, b) suppressWarnings(stats::cor(abs(a), b, method = "spearman"))
rho <- c(sep = sp(m$d_maic, m$sep), ess = sp(m$d_maic, m$ess)); flat <- all(abs(rho) < 0.2)
rho_z <- c(sep = sp(m$z_maic, m$sep), ess = sp(m$z_maic, m$ess))
dec <- abs(m$ref / m$se_ref) > 1.96; agree_dec <- sign(m$est_maic) == sign(m$ref) & abs(m$est_maic / m$se_maic) > 1.96
near <- sum(abs(abs(m$z_maic) - 1.96) < 2 * m$z_mcse)
f2 <- function(x) sprintf("%.2f", x)
md <- c("# Decision", "", sprintf("**Registered primary: %s.**", verdict), "",
  sprintf("MAIC bridge, %d main deletion units (%s): |z| > %.2f in %.3f (%d units; %d within two MCSE of 1.96); at 1.96 %.3f. Naive bridge at 1.96: %.3f. Registered: not decision-grade if at least 0.20; consistent with sampling error if at most 0.10 and the positive control passes; threshold 1.96 unless the half-split null rejects MAIC above 0.08, then its 95th percentile of |z|.",
          nrow(m), paste(sprintf("%s %d", names(table(m$net)), table(m$net)), collapse = ", "), crit, pd, sum(abs(m$z_maic) > crit), near, pd196, mean(abs(m$z_naive) > 1.96)), "",
  sprintf("Within tolerance (|discrepancy| <= log 1.5): MAIC %.3f, naive %.3f. Decision agreement where the reference excludes zero (%d units): MAIC %.3f.",
          mean(abs(m$d_maic) <= TOL), mean(abs(m$d_naive) <= TOL), sum(dec), mean(agree_dec[dec])), "",
  sprintf("Stratification (Spearman of |MAIC discrepancy| with separation, with effective sample share): %s, %s. Falsifier (stratification uninformative, both below 0.2 in absolute value): %s. Descriptive, |z| in place of |discrepancy|: %s, %s.",
          f2(rho[["sep"]]), f2(rho[["ess"]]), flat, f2(rho_z[["sep"]]), f2(rho_z[["ess"]])), "",
  sprintf("By network, MAIC share |z| > 1.96: %s.", paste(sprintf("%s %.3f", names(tapply(m$z_maic, m$net, length)), tapply(abs(m$z_maic) > 1.96, m$net, mean)), collapse = ", ")), "",
  sprintf("Null control (half splits, %d analyses): rejection naive %.3f (MCSE %.3f), MAIC %.3f (MCSE %.3f); registered pass if both at most 0.08: %s.",
          nrow(nl), rej[["d_naive"]], rej_mcse[["d_naive"]], rej[["d_maic"]], rej_mcse[["d_maic"]], all(rej <= 0.08)), "",
  sprintf("Positive control (prognostic subgroup: naive |z| > 1.96 in at least one of %d units): %s; naive z %s, MAIC z %s.", nrow(s), pos, paste(f2(s$z_naive), collapse = ", "), paste(f2(s$z_maic), collapse = ", ")), "",
  sprintf("Failed units: %d. Failed bootstrap draws: %d.", sum(failed), sum(N_BOOT - summ$boot_ok)), "",
  "| unit | net | S | M | A | B | reference | naive z | MAIC z | MAIC discrepancy | separation | ESS share |", "|---:|---|---|---|---|---|---:|---:|---:|---:|---:|---:|",
  sprintf("| %d | %s | %s | %s | %s | %s | %.2f | %.2f | %.2f | %.2f | %.2f | %.2f |", summ$unit, summ$net, summ$S, summ$M, summ$A, summ$B, summ$ref, summ$z_naive, summ$z_maic, summ$d_maic, summ$sep, summ$ess), "")
writeLines(md, "results/decision.md"); cat(md[1:19], sep = "\n")
