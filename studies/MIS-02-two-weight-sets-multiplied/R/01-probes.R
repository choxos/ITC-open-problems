## P1 truths, P3 weight-correlation construction, P4 unit cost. Writes results/probes.md.
source("R/00-model.R"); g <- build_grid(); g$truth <- vapply(seq_len(nrow(g)), function(i) truth(g[i, ]), 0)
set.seed(21)
p3 <- do.call(rbind, lapply(seq_len(nrow(g)), function(i) { cc <- g[i, ]
  z <- t(replicate(30, { d <- draw(cc); wp <- part_w(d, cc); wc <- ipcw(d, FORM_OK); o <- wc > 0
    c(cens = mean(d$status == 0 & d$time < TAU), cor = if (sd(wc[o]) > 0) cor(wp[o], wc[o]) else NA,
      ess_part = ess(wp), ess_cens_obs = ess(wc[o]), ess_prod = ess(wp * wc), n_obs = sum(o)) }))
  data.frame(cell = i, t(colMeans(z, na.rm = TRUE))) }))
tm <- system.time(one_rep(g[4, ]))
out <- c("# Probes", "", "Truths (target RMST difference to 24 months) and weight structure, 30 replicates per cell.", "",
  "| cell | censored before 24 (declared) | target x1 mean | kappa | control | truth | censored (observed) | cor(w_part, w_cens) | ESS part | ESS cens among uncensored | ESS product | uncensored n |",
  "|---:|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %d | %.2f | %.1f | %.1f | %s | %.3f | %.3f | %.2f | %.0f | %.0f | %.0f | %.0f |", g$cell, g$cens, g$mu_t, g$kappa, g$ctrl, g$truth,
          p3$cens, p3$cor, p3$ess_part, p3$ess_cens_obs, p3$ess_prod, p3$n_obs), "",
  sprintf("Unit cost with %d bootstrap resamples: %.1f s elapsed (%.1f s CPU) per replicate on a shared machine; %d cells x %d replicates is about %.1f CPU hours.",
          N_BOOT, tm[["elapsed"]], tm[["user.self"]], nrow(g), N_SIM, nrow(g) * N_SIM * tm[["user.self"]] / 3600))
writeLines(out, "results/probes.md"); cat(out, sep = "\n")
