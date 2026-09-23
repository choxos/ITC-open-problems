## Bias and coverage by selection mechanism; influence diagnostic; decision.
source("R/00-model.R")
g <- build_grid(); tt <- DELTA + BETA * X_T
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) { n <- nrow(z)
  data.frame(cell = z$cell[1], bias_beta_within = mean(z$beta_within) - BETA, mcse_bw = stats::sd(z$beta_within) / sqrt(n),
             cov_beta_within = mean(abs(z$beta_within - BETA) <= 1.96 * z$se_within), bias_beta_comb = mean(z$beta_comb) - BETA,
             bias_target_within = mean(z$target_within) - tt, bias_target_comb = mean(z$target_comb) - tt,
             rmse_target_within = sqrt(mean((z$target_within - tt)^2)), rmse_target_comb = sqrt(mean((z$target_comb - tt)^2)),
             influence = mean(z$influence, na.rm = TRUE), n_ipd = mean(z$n_ipd)) }))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
obs <- summ[summ$s_lat == 0, ]; lat <- summ[summ$s_lat > 0, ]
fails <- any(abs(lat$bias_beta_within) > 3 * lat$mcse_bw & abs(lat$bias_beta_within) > 0.05)
cr <- stats::cor(summ$influence, abs(summ$bias_target_comb))
md <- c("# Decision", "",
  sprintf("**Refuting sentence (availability is ignorable given observed trial variables): %s** as a claim about what can happen. Selection on observed trial variables only: within-trial interaction bias %.3f to %.3f. Selection on the latent interaction: %.3f to %.3f.",
          if (fails) "FAILS" else "HOLDS", min(obs$bias_beta_within), max(obs$bias_beta_within), min(lat$bias_beta_within), max(lat$bias_beta_within)), "",
  sprintf("Combining with aggregate trials reduced the latent-selection bias to %.3f to %.3f.", min(lat$bias_beta_comb), max(lat$bias_beta_comb)), "",
  sprintf("Leave-IPD-out influence: %.3f to %.3f across cells; correlation with the combined estimator's absolute bias %.2f.", min(summ$influence), max(summ$influence), cr), "",
  "| IPD share | observed selection | latent selection | IPD trials | beta bias, within | coverage, within | beta bias, combined | target bias, within | target bias, combined | influence |",
  "|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %.2f | %.1f | %.0f | %.1f | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f |", summ$share, summ$s_obs, summ$s_lat, summ$n_ipd, summ$bias_beta_within, summ$cov_beta_within,
          summ$bias_beta_comb, summ$bias_target_within, summ$bias_target_comb, summ$influence), "")
writeLines(md, "results/decision.md"); cat(md[1:7], sep = "\n")
