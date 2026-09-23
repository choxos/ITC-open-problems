## Per network: holdout slope against its own no-drift null, power at DRIFT, the
## naive raw-slope test's size, same-era calibration; the registered decision.
source("R/00-model.R")
g <- build_grid()
res <- lapply(sprintf("results/run/cell-%02d.rds", g$cell), readRDS)
failed <- vapply(res, function(r) !is.null(r$error), TRUE)
sims <- function(n, type) { m <- do.call(rbind, lapply(res[!failed & g$net == n & g$type == type], `[[`, "s")); m[stats::complete.cases(m[, c("S", "p_raw")]), , drop = FALSE] }
set.seed(3); q <- function(v, p) unname(stats::quantile(v, p, na.rm = TRUE))
summ <- do.call(rbind, lapply(names(NETS), function(n) { rr <- res[[which(g$net == n & g$type == "real")]]; s <- rr$s; nl <- sims(n, "null"); ps <- sims(n, "pos")
  q95 <- stats::quantile(nl[, "S"], 0.95); pw <- mean(ps[, "S"] > q95); p <- mean(nl[, "S"] >= s[["S"]]); nr <- mean(nl[, "p_raw"] < 0.05)
  data.frame(net = n, studies = length(unique(NETS[[n]]$study)), years = paste(range(NETS[[n]]$year), collapse = " to "),
             units_est = s[["n_est"]], units_nonest = s[["n_nonest"]], units_fitfail = s[["n_fitfail"]],
             S = s[["S"]], null_q95 = unname(q95), q95_mcse = stats::sd(replicate(200, stats::quantile(sample(nl[, "S"], replace = TRUE), 0.95))),
             p_value = p, p_mcse = sqrt(p * (1 - p) / nrow(nl)), detected = s[["S"]] > q95, power = pw, power_mcse = sqrt(pw * (1 - pw) / nrow(ps)), informative = pw >= 0.5,
             S_raw = s[["S_raw"]], p_raw_real = s[["p_raw"]], naive_size = nr, naive_size_mcse = sqrt(nr * (1 - nr) / nrow(nl)),
             same_era_z2 = s[["same_era"]], same_era_n = s[["n_same"]], same_era_lo = q(nl[, "same_era"], 0.025), same_era_hi = q(nl[, "same_era"], 0.975),
             same_era_ok = if (s[["n_same"]] < 5) NA else s[["same_era"]] >= q(nl[, "same_era"], 0.025) & s[["same_era"]] <= q(nl[, "same_era"], 0.975),
             drift_per_decade = rr$drift[["drift"]], drift_se = rr$drift[["se"]], n_null = nrow(nl), n_pos = nrow(ps)) }))
write.csv(summ, "results/summary.csv", row.names = FALSE)
D <- summ$net[summ$detected]; I <- summ$net[summ$informative]
verdict <- if (length(D)) sprintf("DRIFT ESTABLISHED for %s", paste(D, collapse = ", ")) else
  if (length(I) >= 2) "REFUTING SENTENCE HOLDS on these networks: no drift beyond sampling error and heterogeneity where the design could detect it" else
  "UNINFORMATIVE: fewer than 2 networks can detect the registered drift"
c2 <- sum(summ$naive_size >= 0.10)
md <- c("# Decision", "", sprintf("**Registered primary: %s.**", verdict), "",
  sprintf("Drift detected (slope of z2 on gap above its own no-drift null's 95th percentile) in: %s. Informative (power at %.2f per year at least 0.5): %s.",
          if (length(D)) paste(D, collapse = ", ") else "none", DRIFT, if (length(I)) paste(I, collapse = ", ") else "none"), "",
  sprintf("Consequence 2 (the naive one-sided test of the raw slope of e2 on gap rejects at least 10%% of no-drift replicates in at least 3 of %d networks): %s (%d).", nrow(summ), c2 >= 3, c2), "",
  sprintf("Same-era null control (real mean z2 at gap <= 2 years inside the central 95%% of its own no-drift null; not assessed below 5 same-era holdouts): %s.",
          paste(sprintf("%s %.2f in %.2f to %.2f, n %d (%s)", summ$net, summ$same_era_z2, summ$same_era_lo, summ$same_era_hi, summ$same_era_n, ifelse(is.na(summ$same_era_ok), "not assessed", summ$same_era_ok)), collapse = "; ")), "",
  sprintf("Failed cells: %d. Non-estimable holdouts are counted, not scored.", sum(failed)), "",
  "| network | studies | years | holdouts scored | non-estimable | slope z2 | null 95th (MCSE) | p (MCSE) | power (MCSE) | raw slope e2 | naive p, real | naive size (MCSE) | same-era z2 | drift per decade (SE) |",
  "|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %s | %d | %s | %d | %d | %.4f | %.4f (%.4f) | %.3f (%.3f) | %.2f (%.2f) | %.4f | %.3f | %.2f (%.2f) | %.2f | %.3f (%.3f) |", summ$net, summ$studies, summ$years, summ$units_est, summ$units_nonest,
          summ$S, summ$null_q95, summ$q95_mcse, summ$p_value, summ$p_mcse, summ$power, summ$power_mcse, summ$S_raw, summ$p_raw_real, summ$naive_size, summ$naive_size_mcse, summ$same_era_z2, summ$drift_per_decade, summ$drift_se), "")
writeLines(md, "results/decision.md"); cat(md[1:11], sep = "\n")
