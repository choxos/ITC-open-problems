## Bias, coverage, reversal and the comparison set against the threshold; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$mult), drop = TRUE), function(z) { c <- z$n_adm > 0; e <- z$est[c] - TRUE_AB
  data.frame(cell = z$cell[1], mult = z$mult[1], unit = z$unit[1], connected = mean(c), n_adm = mean(z$n_adm), n_adm_given = if (any(c)) mean(z$n_adm[c]) else NA,
             bias = if (sum(c) > 1) mean(e) else NA, mcse = if (sum(c) > 1) stats::sd(e) / sqrt(sum(c)) else NA,
             rmse = if (any(c)) sqrt(mean(e^2)) else NA, coverage = if (any(c)) mean(abs(e) <= 1.96 * z$se[c]) else NA,
             reversal = if (any(c)) mean(z$est[c] > 0) else NA, excludes_truth = if (any(c)) mean(abs(e) > 1.96 * z$se[c]) else NA) }))
summ <- merge(g, summ, by = "cell"); summ <- summ[order(summ$cell, summ$mult), ]
write.csv(summ, "results/summary.csv", row.names = FALSE)
poor <- summ[summ$shift > 0 & summ$connected >= 0.2, ]
rng <- tapply(poor$bias, poor$cell, function(b) max(b) - min(b))
holds <- all(rng < 0.02)
md <- c("# Decision", "", sprintf("**Refuting sentence (bias is flat over the thresholds anyone would use): %s.** Range of the bridged contrast's bias across thresholds at which the network is connected in at least 20%% of replicates, poor-overlap cells: %s.",
          if (holds) "HOLDS" else "FAILS", paste(sprintf("%.3f", rng), collapse = ", ")), "",
  "| gap shift | index | study-level SD | threshold (x within-trial) | connected | pairs admitted | bias | MCSE | RMSE | coverage | sign reversal |",
  "|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %.1f | %s | %.1f | %g | %.3f | %.1f | %s | %s | %s | %s | %s |", summ$shift, summ$index, summ$tau_s, summ$mult, summ$connected, summ$n_adm,
          ifelse(is.na(summ$bias), "", sprintf("%.3f", summ$bias)), ifelse(is.na(summ$mcse), "", sprintf("%.3f", summ$mcse)), ifelse(is.na(summ$rmse), "", sprintf("%.3f", summ$rmse)),
          ifelse(is.na(summ$coverage), "", sprintf("%.3f", summ$coverage)), ifelse(is.na(summ$reversal), "", sprintf("%.3f", summ$reversal))), "")
writeLines(md, "results/decision.md"); cat(md[1:3], sep = "\n")
