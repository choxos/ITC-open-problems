## Discrepancies with bootstrap SEs, controls and the registered decision.
source("R/00-model.R")
g <- build_grid()
res <- lapply(sprintf("results/run/cell-%02d.rds", g$unit), readRDS)
failed <- vapply(res, function(r) !is.null(r$error), TRUE)
summ <- do.call(rbind, lapply(res[!failed], function(r) { u <- r$unit; ok <- stats::complete.cases(r$boot)
  se <- apply(r$boot[ok, , drop = FALSE], 2, rse)
  data.frame(unit = u$unit, kind = u$kind, S = u$S, M = u$M, A = u$A, stat = names(r$point), value = unname(r$point), se = unname(se),
             z = unname(r$point / se), se_mcse = unname(1.16 * se / sqrt(sum(ok))), boot_ok = sum(ok), boot_zero = unname(apply(abs(r$boot[ok, , drop = FALSE]), 2, max) < 1e-8),
             nS = r$n[["S"]], nM = r$n[["M"]]) }))
write.csv(summ, "results/summary.csv", row.names = FALSE)
Z <- function(k, s) { v <- summ[summ$unit == k & summ$stat == s, ]; if (nrow(v)) v$z else NA_real_ }
V <- function(k, s) { v <- summ[summ$unit == k & summ$stat == s, ]; if (nrow(v)) v$value else NA_real_ }
main <- g$unit[g$kind == "main" & !failed]
disc <- function(m) vapply(main, function(k) abs(Z(k, paste0("rel_", m))) <= 1.96 && max(abs(Z(k, paste0("armA_", m))), abs(Z(k, paste0("armC_", m)))) > 2.24, TRUE)
agree <- vapply(main, function(k) abs(Z(k, "rel_maic")) <= 1.96, TRUE); d_maic <- disc("maic")
self <- g$unit[g$kind == "self" & !failed]
null1 <- all(vapply(self, function(k) { v <- summ[summ$unit == k & summ$stat %in% c("rel_bucher", "armA_bucher", "armC_bucher"), ]; all(abs(v$value) < 1e-8 & v$boot_zero) }, TRUE))
null1m <- all(vapply(self, function(k) abs(Z(k, "rel_maic")) <= 1.96, TRUE))
posu <- g$unit[g$kind == "pos" & !failed]
pos <- vapply(posu, function(k) abs(Z(k, "rel_maic")) <= 1.96 && max(abs(Z(k, "armA_maic")), abs(Z(k, "armC_maic"))) > 2.24, TRUE)
verdict <- if (sum(d_maic) >= 2) "CONFIRMED: relative agreement does not certify the arm-level predictions" else
  if (sum(d_maic) == 0 && sum(agree) >= 4) { if (any(pos)) "REFUTED: where the relative effect agrees, the arm-level predictions agree" else
    "NO DISCORDANCE DETECTED, NOT REFUTED: the positive control failed, so the arm-level check has no demonstrated power here" } else "INCONCLUSIVE"
flip <- vapply(main, function(k) (abs(Z(k, "rel_stc_cond")) > 1.96) != (abs(Z(k, "rel_stc_cond_vs_marg")) > 1.96), TRUE)
f2 <- function(x) sprintf("%.2f", x)
tab <- do.call(rbind, lapply(c(main, self, posu), function(k) { u <- g[g$unit == k, ]
  sprintf("| %d | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |", k, u$kind, u$S, u$M, u$A,
    f2(V(k, "ref_marg")), f2(V(k, "est_maic")), f2(Z(k, "rel_bucher")), f2(Z(k, "rel_maic")), f2(Z(k, "rel_stc_marg")), f2(Z(k, "rel_stc_cond")),
    f2(Z(k, "armA_maic")), f2(Z(k, "armC_maic")), f2(V(k, "gap_logor")), f2(Z(k, "gap_rd")), f2(V(k, "ess"))) }))
md <- c("# Decision", "", sprintf("**Registered primary: %s.**", verdict), "",
  sprintf("MAIC, %d main units: relative agreement (|z| <= 1.96) in %d; discordant (relative agrees, an arm-level |z| > 2.24) in %d (units %s). Registered: confirmed if at least 2 discordant; refuted if none, at least 4 agree and the positive control passes.",
          length(main), sum(agree), sum(d_maic), if (any(d_maic)) paste(main[d_maic], collapse = ", ") else "none"), "",
  sprintf("Discordant units for the other marginal methods: Bucher %d, STC marginal %d.", sum(disc("bucher")), sum(disc("stc_marg"))), "",
  sprintf("Null control (self units: Bucher reproduces the reference and both arms exactly in every bootstrap draw): %s. MAIC |z| <= 1.96 in every self unit: %s.", null1, null1m), "",
  sprintf("Positive control (baseline shift of %g logit in the masked trial: MAIC discordant in at least one of %d units): %s (relative z %s; arm A z %s; arm PBO z %s).",
          DELTA, length(posu), any(pos), paste(f2(vapply(posu, function(k) Z(k, "rel_maic"), 0)), collapse = ", "),
          paste(f2(vapply(posu, function(k) Z(k, "armA_maic"), 0)), collapse = ", "), paste(f2(vapply(posu, function(k) Z(k, "armC_maic"), 0)), collapse = ", ")), "",
  sprintf("Estimand pairing: STC conditional's verdict changes between its own reference and the marginal one in %d of %d main units; log OR collapsibility gap %s.",
          sum(flip), length(main), paste(f2(vapply(main, function(k) V(k, "gap_logor"), 0)), collapse = ", ")), "",
  sprintf("Failed units: %d. Bootstrap draws failed: %d. Bootstrap SE (interquartile range / 1.349) relative MCSE: %.3f.", sum(failed), sum(N_BOOT - unique(summ[, c("unit", "boot_ok")])$boot_ok), 1.16 / sqrt(N_BOOT)), "",
  "| unit | kind | S | M | A | reference log OR | MAIC log OR | z Bucher | z MAIC | z STC marg | z STC cond | z arm A (MAIC) | z arm PBO (MAIC) | log OR gap | z RD gap (descriptive) | ESS share |",
  "|---:|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|", tab, "")
writeLines(md, "results/decision.md"); cat(md[1:15], sep = "\n")
