## Predictive performance, prior dependence of the clustering, tempering decomposition; decision.
source("R/00-model.R")
g <- build_grid(); raw <- do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS))
fails <- tapply(!is.na(raw$error), raw$cell, function(x) length(unique(raw$rep[x])))
d <- merge(raw[is.na(raw$error), ], g, by = "cell")
mc <- function(x) stats::sd(x) / sqrt(length(x)); f3 <- function(x) sprintf("%.3f", x)

## Per cell and arm.
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$arm), drop = TRUE), function(z) {
  cv <- mean(z$pred_lo <= z$thetaT & z$thetaT <= z$pred_hi); e <- z$mean_est - z$truth
  data.frame(cell = z$cell[1], arm = z$arm[1], n = nrow(z), pred_cov = cv, pred_cov_mcse = sqrt(cv * (1 - cv) / nrow(z)),
             pred_width = mean(z$pred_hi - z$pred_lo), logscore = mean(z$logscore), logscore_mcse = mc(z$logscore),
             mean_bias = mean(e), mean_bias_mcse = mc(e), mean_cov = mean(abs(e) <= 1.96 * z$mean_sd),
             K = mean(z$K), tau = mean(z$tau), ipd_share = mean(z$ipd_share)) }))
summ <- merge(g, summ, by = "cell"); write.csv(summ, "results/summary.csv", row.names = FALSE)

## Per replicate: paired log-score gains, prior-dependence ratio, tempering shifts.
w <- function(v) stats::setNames(d[[v]], paste(d$cell, d$rep, d$arm))
key <- unique(d[, c("cell", "rep", "J")]); k <- function(a) paste(key$cell, key$rep, a)
ls <- w("logscore"); K <- w("K"); PS <- w("psame"); me <- w("mean_est"); ms <- w("mean_sd"); ta <- w("tau"); ip <- w("ipd_share")
key$gain_dp <- ls[k("dp_1")] - ls[k("re_1")]; key$gain_t <- ls[k("t_1")] - ls[k("re_1")]; key$dp_vs_t <- ls[k("dp_1")] - ls[k("t_1")]
key$r_prior <- (PS[k("dplo_1")] - PS[k("dphi_1")]) / (prior_same(A_DP[1]) - prior_same(A_DP[3]))
key$r_K <- (K[k("dphi_1")] - K[k("dplo_1")]) / (mapply(prior_K, A_DP[3], key$J) - mapply(prior_K, A_DP[1], key$J))
for (m in c("re", "dp")) { key[[paste0("shift_", m)]] <- abs(me[k(paste0(m, "_0.5"))] - me[k(paste0(m, "_1"))]) / ms[k(paste0(m, "_1"))]
  key[[paste0("width_", m)]] <- ms[k(paste0(m, "_0.5"))] / ms[k(paste0(m, "_1"))] }
key$tau_ratio <- ta[k("re_0.5")] / ta[k("re_1")]; key$ipd_1 <- ip[k("re_1")]; key$ipd_0.5 <- ip[k("re_0.5")]
key$dK <- K[k("dp_0.5")] - K[k("dp_1")]
set.seed(1); bmed <- function(x) c(stats::median(x), stats::sd(replicate(200, stats::median(sample(x, replace = TRUE)))))
per <- do.call(rbind, lapply(split(key, key$cell), function(z) data.frame(cell = z$cell[1],
  gain_dp = mean(z$gain_dp), gain_dp_mcse = mc(z$gain_dp), gain_t = mean(z$gain_t), dp_vs_t = mean(z$dp_vs_t),
  r_prior = mean(z$r_prior), r_prior_mcse = mc(z$r_prior), r_K = mean(z$r_K),
  shift_re = bmed(z$shift_re)[1], shift_re_mcse = bmed(z$shift_re)[2], shift_dp = bmed(z$shift_dp)[1],
  width_re = stats::median(z$width_re), width_dp = stats::median(z$width_dp), tau_ratio = stats::median(z$tau_ratio, na.rm = TRUE),
  ipd_1 = mean(z$ipd_1), ipd_0.5 = mean(z$ipd_0.5), dK = mean(z$dK))))
per <- merge(g, per, by = "cell"); write.csv(per, "results/per-cell.csv", row.names = FALSE)

## Registered primary: three clusters, small separation, 6 studies, one IPD study.
pc <- per[per$het == "small" & per$J == 6 & per$ipd == "one", ]
covdp <- summ$pred_cov[summ$cell == pc$cell & summ$arm == "dp_1"]
gain_ok <- pc$gain_dp >= 0.05 && pc$gain_dp > 2 * pc$gain_dp_mcse
verdict <- if (gain_ok && covdp >= 0.93 && covdp <= 0.97 && pc$r_prior <= 0.5) "EXTENSION ESTABLISHED: the mixture predicts better and its clustering is data-driven" else
  if (!gain_ok && pc$r_prior >= 0.5) "REFUTING SENTENCE HOLDS: no predictive gain and the clustering restates the concentration parameter" else "MIXED: see the table"
cov_ok <- function(cell, arm) { v <- summ$pred_cov[summ$cell == cell & summ$arm == arm]; v >= 0.93 && v <= 0.97 }
nc <- per[per$het == "one" & per$J == 12 & per$ipd == "half", ]; pcx <- per[per$het == "large" & per$J == 12 & per$ipd == "half", ]
null_ok <- abs(nc$gain_dp) <= 0.05 && cov_ok(nc$cell, "dp_1") && cov_ok(nc$cell, "re_1")
pos_ok <- pcx$r_prior <= 0.5 && pcx$gain_dp >= 0.05
tp <- per[per$J == 6 & per$ipd == "half", ]
temper <- if (all(tp$shift_re >= 0.1)) "LOCATION MOVES MATERIALLY in every 6-study half-IPD cell" else
  if (all(tp$shift_re < 0.1)) "TECHNICALLY RIGHT, PRACTICALLY IMMATERIAL: median location shift below 0.1 SD in every 6-study half-IPD cell" else "MIXED across heterogeneity levels"
md <- c("# Decision", "", sprintf("**Registered primary: %s.**", verdict), "",
  sprintf("Primary cell %d (three clusters, small separation, 6 studies, one IPD study): log-score gain of the mixture over random effects %s (MCSE %s); mixture predictive coverage %s; prior-dependence ratio %s (MCSE %s).",
          pc$cell, f3(pc$gain_dp), f3(pc$gain_dp_mcse), f3(covdp), f3(pc$r_prior), f3(pc$r_prior_mcse)), "",
  sprintf("Heavy-tailed comparator in the primary cell: gain over random effects %s; mixture minus heavy-tailed %s.", f3(pc$gain_t), f3(pc$dp_vs_t)), "",
  sprintf("Null control (one cluster, 12 studies, half IPD: gain within 0.05, both coverages 0.93 to 0.97): %s (gain %s).", null_ok, f3(nc$gain_dp)), "",
  sprintf("Positive control (three well-separated clusters, 12 studies, half IPD: prior-dependence ratio at most 0.5 and gain at least 0.05): %s (ratio %s, gain %s).", pos_ok, f3(pcx$r_prior), f3(pcx$gain_dp)), "",
  sprintf("Tempering (registered secondary, eta 0.5 against 1, random effects): %s. Median standardized location shift %s; median width ratio %s against 1.414 for a flat model.",
          temper, paste(f3(tp$shift_re), collapse = ", "), paste(f3(tp$width_re), collapse = ", ")), "",
  sprintf("Failed replicates per cell: %s.", paste(sprintf("%s: %d", names(fails), fails), collapse = ", ")), "",
  "| cell | clusters | studies | IPD | gain dp | gain t | prior-dependence ratio (co-clustering) | same, on K | location shift re (dp) | width ratio re (dp) | tau ratio | IPD share eta 1 to 0.5 | change in K |",
  "|---:|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---|---:|",
  sprintf("| %d | %s | %d | %s | %.3f | %.3f | %.2f | %.2f | %.3f (%.3f) | %.3f (%.3f) | %.2f | %.2f to %.2f | %.2f |", per$cell, per$het, per$J, per$ipd, per$gain_dp, per$gain_t,
          per$r_prior, per$r_K, per$shift_re, per$shift_dp, per$width_re, per$width_dp, per$tau_ratio, per$ipd_1, per$ipd_0.5, per$dK), "",
  "| cell | arm | predictive coverage | width | log score | mean-contrast bias | mean-contrast coverage | K |", "|---:|---|---:|---:|---:|---:|---:|---:|",
  sprintf("| %d | %s | %.3f | %.2f | %.3f | %.3f | %.3f | %s |", summ$cell, summ$arm, summ$pred_cov, summ$pred_width, summ$logscore, summ$mean_bias, summ$mean_cov,
          ifelse(is.na(summ$K), "", sprintf("%.2f", summ$K))), "")
writeLines(md, "results/decision.md"); cat(md[1:15], sep = "\n")
