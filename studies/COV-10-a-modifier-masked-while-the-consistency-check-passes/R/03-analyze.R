## Pooled interaction, checks' power, selection and target bias; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) { e <- z$est_sel - z$truth; n <- nrow(z)
  data.frame(cell = z$cell[1], bC = mean(z$bC), sd_bC = stats::sd(z$bC), mean_se_bC = mean(z$se_bC), select = mean(z$p_int < ALPHA),
             int_cons = mean(z$p_int_cons < ALPHA), eff_cons = mean(z$p_eff_cons < ALPHA),
             bias_sel = mean(e), mcse_sel = stats::sd(e) / sqrt(n), cov_sel = mean(abs(e) <= 1.96 * z$se_sel),
             bias_ac = mean(z$est_ac - z$truth), cov_ac = mean(abs(z$est_ac - z$truth) <= 1.96 * z$se_ac)) }))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
inc <- summ[summ$scen != "consistent" & summ$loop == 0, ]
blind <- all(inc$eff_cons <= 0.10 + 3 * sqrt(0.09 / N_SIM) + 0.01)
part <- summ[summ$scen == "partial", ]
fails <- any(abs(part$bias_sel) > 3 * part$mcse_sel & abs(part$bias_sel) > 0.1)
md <- c("# Decision", "",
  sprintf("**Effect-consistency check blind to interaction inconsistency: %s.** Flag rate %.3f to %.3f in interaction-inconsistent cells without effect inconsistency.",
          if (blind) "CONFIRMED" else "NOT CONFIRMED", min(inc$eff_cons), max(inc$eff_cons)), "",
  sprintf("**Refuting sentence (cancellation is a knife-edge curiosity): %s.** Partly opposing interactions: target bias after selection %.3f to %.3f.",
          if (fails) "FAILS" else "HOLDS", min(part$bias_sel), max(part$bias_sel)), "",
  sprintf("Interaction-consistency check power in inconsistent cells: %.3f to %.3f.", min(inc$int_cons), max(inc$int_cons)), "",
  "| scenario | covariate SD | studies per comparison | effect loop | pooled b_C | its SD across replicates | mean model SE | selected | interaction check | effect check | target bias | coverage | AC-path bias |",
  "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %s | %.1f | %d | %.1f | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f |", summ$scen, summ$sdx, summ$M, summ$loop, summ$bC, summ$sd_bC,
          summ$mean_se_bC, summ$select, summ$int_cons, summ$eff_cons, summ$bias_sel, summ$cov_sel, summ$bias_ac), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
