## Coverage of the downstream contrast by route, reconstruction materiality,
## precision survival (calibrated and delivered by the draws), at-risk mechanism,
## controls; decision.
source("R/00-model.R")
g <- build_grid(); key <- c("cell", "rep", "route", "estimand")
d <- do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS))
tr <- do.call(rbind, lapply(seq_len(nrow(g)), function(i) data.frame(cell = g$cell[i], estimand = EST_C, truth = truth(g[i, ]))))
o <- d[d$method == "oracle", c(key, "est")]; names(o)[5] <- "theta"
d <- merge(merge(d, o, by = key), tr, by = c("cell", "estimand")); d$truth[d$route == "arm"] <- S_pop(T_EXT)
ens <- !is.na(d$b)
d$tot <- d$w + ifelse(ens, (1 + 1 / d$m) * d$b, 0)
d$q <- ifelse(ens, stats::qt(0.975, (d$m - 1) * (1 + d$w / pmax((1 + 1 / d$m) * d$b, 1e-300))^2), stats::qnorm(0.975))
mat <- function(z) sqrt(mean((z$est - z$theta)^2)) / stats::sd(z$theta)
set.seed(1)
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$route, d$method, d$estimand), drop = TRUE), function(z) {
  e <- z$est - z$truth; n <- nrow(z); cv <- mean(abs(e) <= z$q * sqrt(z$tot)); rec <- z$method[1] != "oracle"
  data.frame(cell = z$cell[1], route = z$route[1], method = z$method[1], estimand = z$estimand[1], n_rep = n, bias = mean(e), mcse = stats::sd(e) / sqrt(n),
             coverage = cv, cov_mcse = sqrt(cv * (1 - cv) / n), width = mean(2 * z$q * sqrt(z$tot)), rmse = sqrt(mean(e^2)),
             recon_rmse = if (rec) sqrt(mean((z$est - z$theta)^2)) else NA, materiality = if (rec) mat(z) else NA, mat_mcse = if (rec) stats::sd(replicate(200, mat(z[sample.int(n, replace = TRUE), ]))) else NA,
             m = mean(z$m)) }))
summ <- merge(g, summ, by = "cell")
wd <- function(m) summ$width[match(paste(summ$cell, summ$route, summ$estimand, m), paste(summ$cell, summ$route, summ$estimand, summ$method))]
summ$width_vs_oracle <- summ$width / wd("oracle")
## Precision survival: the share of the single reconstruction's interval width that
## survives honest propagation, calibrated from the true error (1 / sqrt(1 + materiality^2))
## and as the draws deliver it (single width over draws width).
summ$ps_calibrated <- ifelse(summ$method == "single", 1 / sqrt(1 + summ$materiality^2), NA)
summ$ps_draws <- ifelse(summ$method == "single", wd("single") / wd("draws"), NA)
summ <- summ[order(summ$cell, summ$route, summ$estimand, summ$method), ]; write.csv(summ, "results/summary.csv", row.names = FALSE)

f <- function(x) sprintf("%.3f", x); nominal <- function(x) x >= 0.93 & x <= 0.97
at <- function(cells, r, m, e) summ[summ$cell %in% cells & summ$route == r & summ$method == m & summ$estimand == e, ]
prim <- g$cell[g$ctrl == "none" & g$n == 250L]
rule <- function(r, e) { sg <- at(prim, r, "single", e); dw <- at(prim, r, "draws", e); or <- at(prim, r, "oracle", e)
  lo <- sg$coverage < 0.925
  v <- if (!all(or$coverage >= 0.921 & or$coverage <= 0.979)) "NOT ASSESSABLE: the oracle is more than 3 MCSE off nominal in a primary cell" else
    if (any(lo)) paste0("PROPAGATION NEEDED; the draws ", if (all(nominal(dw$coverage[lo]))) "repair it" else "do not repair it") else
    if (all(sg$coverage <= 0.975)) "REFUTING SENTENCE HOLDS: a single reconstruction covers 0.925 to 0.975 in every primary cell" else "MIXED: see the table by cell"
  list(v = v, line = sprintf("coverage oracle %s, single %s, draws %s; materiality %s; precision survival calibrated %s, delivered by the draws %s",
    paste(f(or$coverage), collapse = ", "), paste(f(sg$coverage), collapse = ", "), paste(f(dw$coverage), collapse = ", "), paste(f(sg$materiality), collapse = ", "),
    paste(f(sg$ps_calibrated), collapse = ", "), paste(f(sg$ps_draws), collapse = ", "))) }
p0 <- rule("joint_study", "s48"); p1 <- rule("joint_common", "s48"); p2 <- rule("km", "s30")
nc <- summ[summ$ctrl == "null" & summ$method == "single", ]
null_ok <- all(nc$materiality[nc$estimand %in% c("loghr", "rmst24", "s12")] < 0.10) && all(nc$width_vs_oracle >= 0.95 & nc$width_vs_oracle <= 1.05)
ne <- summ[summ$ctrl == "null_effect", ]; null2_ok <- all(abs(ne$bias) <= 3 * ne$mcse)
arm <- at(prim, "arm", "single", "s48"); pos_ok <- all(arm$materiality >= 0.10)
dil <- at(prim, "joint_study", "single", "s48")$materiality / arm$materiality
big <- at(g$cell[g$ctrl == "large"], "joint_study", "single", "s48")
## Tail falsifier on the absolute reconstruction error (Kaplan-Meier route, where the
## estimands are estimated separately); on the joint routes every estimand shares one
## parametric channel, so only the ratio of 48 to 12-month materiality is reported.
k12 <- at(prim, "km", "single", "s12"); k30 <- at(prim, "km", "single", "s30"); not_tail <- any(k12$recon_rmse >= k30$recon_rmse)
jr <- at(prim, "joint_study", "single", "s48")$materiality / at(prim, "joint_study", "single", "s12")$materiality
## Mechanism check: relative RMS error of the single reconstruction's number at risk in study 2.
nr <- d[d$route == "km" & d$estimand == "s30", ]; nv <- c("cell", "rep", "nr_early", "nr_late")
nr <- merge(nr[nr$method == "single", nv], nr[nr$method == "oracle", nv], by = c("cell", "rep"), suffixes = c("", "_o"))
rel <- do.call(rbind, lapply(split(nr, nr$cell), function(z) data.frame(cell = z$cell[1],
  early = sqrt(mean((z$nr_early - z$nr_early_o)^2)) / mean(z$nr_early_o), late = sqrt(mean((z$nr_late - z$nr_late_o)^2)) / mean(z$nr_late_o))))
mech <- all(rel$late[rel$cell %in% prim] > rel$early[rel$cell %in% prim])
drops <- vapply(g$cell, function(k) N_SIM - length(unique(d$rep[d$cell == k])), 0)
md <- c("# Decision", "", sprintf("**Registered primary (48-month survival difference, joint likelihood with study-specific shapes): %s.**", p0$v), "",
  sprintf("Primary cells %s (coarse figure, %d per arm; risk table %s; censoring %s): %s.", paste(prim, collapse = ", "), g$n[prim[1]], paste(g$table[prim], collapse = ", "), paste(g$cens[prim], collapse = ", "), p0$line), "",
  sprintf("Registered secondary, 48 months with a common shape: %s. %s.", p1$v, p1$line), "",
  sprintf("Registered secondary, 30 months on the anchored Kaplan-Meier route: %s. %s.", p2$v, p2$line), "",
  sprintf("Null control (fine figure, monthly table: single materiality below 0.10 for the log hazard ratio, RMST and 12-month estimands on every route, width within 5%% of the oracle for every route and estimand): %s; materiality %s.",
          null_ok, paste(sprintf("%s %s %s", nc$route, nc$estimand, f(nc$materiality)), collapse = ", ")), "",
  sprintf("Second null control (no effect: every route, method and estimand unbiased within 3 MCSE): %s.", null2_ok), "",
  sprintf("Positive control (upstream: study 2's control arm alone, Weibull survival at 48 months, single materiality at least 0.10 in every primary cell): %s (%s). Downstream over upstream materiality, the dilution: %s.",
          pos_ok, paste(f(arm$materiality), collapse = ", "), paste(f(dil), collapse = ", ")), "",
  sprintf("Large trial (cell %d, %d per arm, no table, clustered): primary estimand single coverage %s, materiality %s.", big$cell, big$n, f(big$coverage), f(big$materiality)), "",
  sprintf("Mechanism check (single reconstruction's relative RMS error in study 2's number at risk larger at %g than at %g months in every primary cell): %s; by cell %s.", T_NR[2], T_NR[1], mech,
          paste(sprintf("%d: %.3f and %.3f", rel$cell, rel$early, rel$late), collapse = "; ")), "",
  sprintf("Tail falsifier (Kaplan-Meier route: absolute reconstruction RMSE at 12 months at least that at %g months in a primary cell): %s; %s against %s.", T_LATE, not_tail,
          paste(sprintf("%.4f", k12$recon_rmse), collapse = ", "), paste(sprintf("%.4f", k30$recon_rmse), collapse = ", ")), "",
  sprintf("Joint route, 48 over 12-month materiality (registered expectation 0.8 to 1.25, one shared parametric channel): %s; within %s.", paste(f(jr), collapse = ", "), all(jr >= 0.8 & jr <= 1.25)), "",
  sprintf("Replicates dropped per cell: %s. Mean ensemble size: %s.", paste(drops, collapse = ", "),
          paste(sprintf("%.1f", summ$m[summ$method == "draws" & summ$route == "km" & summ$estimand == "s30"]), collapse = ", ")), "",
  "| cell | table | censoring | n per arm | effect | route | estimand | method | bias | MCSE | coverage | width / oracle | materiality (MCSE) | precision survival calibrated | by draws |",
  "|---:|---:|---|---:|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %d | %g | %s | %d | %s | %s | %s | %s | %.4f | %.4f | %.3f | %.3f | %s | %s | %s |", summ$cell, summ$table, summ$cens, summ$n, summ$effect, summ$route, summ$estimand, summ$method,
          summ$bias, summ$mcse, summ$coverage, summ$width_vs_oracle, ifelse(is.na(summ$materiality), "", sprintf("%.3f (%.3f)", summ$materiality, summ$mat_mcse)),
          ifelse(is.na(summ$ps_calibrated), "", f(summ$ps_calibrated)), ifelse(is.na(summ$ps_draws), "", f(summ$ps_draws))), "")
writeLines(md, "results/decision.md"); cat(md[1:27], sep = "\n")
