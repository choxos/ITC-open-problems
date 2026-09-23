## Calibration ratios, reconstruction error, pooled coverage, controls; decision.
source("R/00-model.R")
g <- build_grid(); tp <- truth()
d <- do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS))
o <- d[d$method == "oracle", c("cell", "rep", "estimand", "est", "w")]; names(o)[4:5] <- c("theta", "w_or")
d <- merge(d, o, by = c("cell", "rep", "estimand")); d$pop <- tp[d$estimand]
d$tot <- d$w + ifelse(is.na(d$b), 0, (1 + 1 / d$m) * d$b)
vr <- function(z) mean(z$b) * (1 + 1 / mean(z$m)) / stats::var(z$est - z$theta)
set.seed(1)
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method, d$estimand), drop = TRUE), function(z) {
  e <- z$est - z$theta; ens <- !is.na(z$b[1])
  bs <- if (ens) replicate(200, vr(z[sample.int(nrow(z), replace = TRUE), ])) else NA
  data.frame(cell = z$cell[1], method = z$method[1], estimand = z$estimand[1], n_rep = nrow(z),
             err_bias = mean(e), err_mcse = stats::sd(e) / sqrt(nrow(z)), err_rmse = sqrt(mean(e^2)), sd_theta = stats::sd(z$theta),
             ratio_var = if (ens) vr(z) else NA, ratio_mcse = if (ens) stats::sd(bs) else NA,
             ratio_mse = if (ens) mean(z$b) * (1 + 1 / mean(z$m)) / mean(e^2) else NA,
             recon_cov90 = if (ens) mean(abs(e) <= 1.645 * sqrt((1 + 1 / z$m) * z$b)) else NA,
             pop_cov = mean(abs(z$est - z$pop) <= 1.96 * sqrt(z$tot)), width_vs_oracle = mean(sqrt(z$tot)) / mean(sqrt(z$w_or)),
             inflation = if (ens) sqrt(1 + (1 + 1 / mean(z$m)) * mean(z$b) / mean(z$w)) - 1 else NA)
}))
summ <- merge(g, summ, by = "cell"); summ$materiality <- summ$err_rmse / summ$sd_theta
write.csv(summ, "results/summary.csv", row.names = FALSE)

near <- function(r) r >= 0.67 & r <= 1.5; far <- function(r) r < 0.5 | r > 2
pr <- summ[summ$table == 6 & summ$ctrl == "none" & summ$estimand == "rmst24", ]
tv <- pr$ratio_var[pr$method == "variants"]; dv <- pr$ratio_var[pr$method == "draws"]
verdict <- if (all(far(tv)) && all(near(dv))) "CONFIRMED: analyst variants far from one, observation-model draws near one" else
  if (all(near(tv))) "REFUTED: analyst variants already calibrated" else
  if (all(far(tv)) && all(far(dv))) "BOTH FAR FROM ONE: no ensemble here is an imputation" else "MIXED: see the table by cell"
main <- summ[summ$ctrl == "none" & summ$method == "draws", ]
nonuni <- sum(vapply(split(main, main$cell), function(z) max(z$inflation) / max(min(z$inflation), 1e-12) >= 2, TRUE))
sg <- summ[summ$method == "single", ]
nul <- sg[sg$ctrl == "null", ]; pos <- sg[sg$cell == 12 & sg$estimand == "s12", ]
null_ok <- all(nul$materiality[nul$estimand %in% c("rmst24", "s12")] < 0.10)
drops <- tapply(summ$n_rep[summ$method == "oracle" & summ$estimand == "rmst24"], summ$cell[summ$method == "oracle" & summ$estimand == "rmst24"], function(x) N_SIM - x)
f <- function(x) sprintf("%.2f", x)
md <- c("# Decision", "", sprintf("**Registered primary: %s.**", verdict), "",
  sprintf("Variance calibration ratio for RMST at a 6-month risk table (cells %s): analyst variants %s; observation-model draws %s.",
          paste(unique(pr$cell), collapse = ", "), paste(f(tv), collapse = ", "), paste(f(dv), collapse = ", ")), "",
  sprintf("Non-uniformity: largest to smallest width inflation across estimands at least 2 in %d of 12 main cells (registered: non-uniform if at least 7).", nonuni), "",
  sprintf("Null control (single reconstruction RMSE below 10%% of the sampling SD for RMST and 12-month survival): %s; RMSE/SD %s.",
          null_ok, paste(sprintf("%s %.3f", nul$estimand, nul$materiality), collapse = ", ")), "",
  sprintf("Positive control (cell 12, single-reconstruction RMSE at least 25%% of the sampling SD for 12-month survival): %s (%.3f).", pos$materiality >= 0.25, pos$materiality), "",
  sprintf("Replicates dropped per cell: %s.", paste(drops, collapse = ", ")), "",
  "| cell | resolution | table | censoring | estimand | method | error bias | error RMSE / sampling SD | variance ratio (MCSE) | MSE ratio | reconstruction coverage 0.90 | population coverage | width vs oracle |",
  "|---:|---|---:|---|---|---|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %d | %s | %g | %s | %s | %s | %.4f | %.3f | %s | %s | %s | %.3f | %.3f |", summ$cell, summ$res, summ$table, summ$cens, summ$estimand, summ$method,
          summ$err_bias, summ$materiality, ifelse(is.na(summ$ratio_var), "", sprintf("%.2f (%.2f)", summ$ratio_var, summ$ratio_mcse)),
          ifelse(is.na(summ$ratio_mse), "", f(summ$ratio_mse)), ifelse(is.na(summ$recon_cov90), "", sprintf("%.3f", summ$recon_cov90)), summ$pop_cov, summ$width_vs_oracle), "")
writeLines(md, "results/decision.md"); cat(md[1:13], sep = "\n")
