## Per network: cut statistics against their own bridge-true null, power against
## separation-driven baselines, the published cut table; the registered decision.
source("R/00-model.R")
CUTS <- readRDS("results/run/cuts.rds"); g <- build_grid(); g <- g[vapply(CUTS[g$net], length, 0L) >= MIN_CUTS, ]
res <- lapply(sprintf("results/run/cell-%02d.rds", g$cell), readRDS)
failed <- vapply(res, function(r) !is.null(r$error), TRUE)
sims <- function(n, type) { m <- do.call(rbind, lapply(res[!failed & g$net == n & g$type == type], `[[`, "s")); m[is.finite(m[, "T_var"]), , drop = FALSE] }
cuts <- do.call(rbind, lapply(unique(g$net), function(n) { sc <- res[[which(g$net == n & g$type == "real")]]$sc
  cbind(net = n, side1 = vapply(CUTS[[n]], function(k) paste(k$side1, collapse = " + "), ""), sc) }))
write.csv(cuts, "results/cuts.csv", row.names = FALSE)
q <- function(v, p) unname(stats::quantile(v, p, na.rm = TRUE)); pm <- function(p, n) sqrt(p * (1 - p) / n)
summ <- do.call(rbind, lapply(unique(g$net), function(n) { s <- res[[which(g$net == n & g$type == "real")]]$s; nl <- sims(n, "null"); ps <- sims(n, "pos"); sc <- cuts[cuts$net == n, ]
  qv <- q(nl[, "T_var"], 0.95); qp <- q(nl[, "T_pop"], 0.975); qd <- q(nl[, "T_des"], 0.975)
  sep_hit <- function(m) (is.finite(m[, "T_pop"]) & m[, "T_pop"] > qp) | m[, "T_des"] > qd
  data.frame(net = n, cuts = length(CUTS[[n]]), scored = s[["n_ok"]], T_var = s[["T_var"]], null_q95_var = qv, p_var = mean(nl[, "T_var"] >= s[["T_var"]]),
             T_pop = s[["T_pop"]], null_q975_pop = qp, T_des = s[["T_des"]], null_q975_des = qd,
             cut_dependent = s[["T_var"]] > qv, separation_predicts = isTRUE(s[["T_pop"]] > qp) || s[["T_des"]] > qd,
             power_sep = mean(sep_hit(ps)), power_var = mean(ps[, "T_var"] > qv), null_rej = mean(nl[, "rej"]), null_rej_mcse = stats::sd(nl[, "rej"]) / sqrt(nrow(nl)),
             real_rej = s[["rej"]], mean_abs_z_rb = mean(abs(sc$z_rb), na.rm = TRUE), mean_abs_z_rbx = mean(abs(sc$z_rbx), na.rm = TRUE),
             zero_df_share = mean(sc$df1 == 0 | sc$df2 == 0), n_null = nrow(nl), n_pos = nrow(ps)) }))
summ$p_var_mcse <- pm(summ$p_var, summ$n_null); summ$power_sep_mcse <- pm(summ$power_sep, summ$n_pos)
write.csv(summ, "results/summary.csv", row.names = FALSE)
a <- summ[summ$net == "af", ]
verdict <- if (a$separation_predicts) "SEPARATION PREDICTS RECOVERY: a deletion benchmark is evidence only for gaps at the separation its cuts span" else
  if (a$cut_dependent) "CUT-DEPENDENT, NOT PREDICTED BY THE MEASURED SEPARATIONS" else
  if (a$power_sep >= 0.8) "REFUTING SENTENCE HOLDS: recovery does not depend on the cut here" else "INCONCLUSIVE: neither detected and the design lacks power"
md <- c("# Decision", "", sprintf("**Registered primary (af): %s.**", verdict), "",
  sprintf("af, %d cuts: variance of z across cuts %.3f against the bridge-true null's 95th percentile %.3f (p %.3f, MCSE %.3f); slope of |e| on population separation %.3f (null 97.5th %.3f), on design separation %.3f (null 97.5th %.3f).",
          a$scored, a$T_var, a$null_q95_var, a$p_var, a$p_var_mcse, a$T_pop, a$null_q975_pop, a$T_des, a$null_q975_des), "",
  sprintf("Positive control (baselines shifted %.1f logit per SD of the first separation covariate; separation test power at least 0.8): af %.2f (MCSE %.2f); %s.", GAMMA, a$power_sep, a$power_sep_mcse,
          paste(sprintf("%s %.2f", summ$net[summ$net != "af"], summ$power_sep[summ$net != "af"]), collapse = ", ")), "",
  sprintf("Null control (bridge true: mean share of cuts with |z| > 1.96 at most 0.08, else per-cut z is not read as a z): %s.", paste(sprintf("%s %.3f (%s)", summ$net, summ$null_rej, summ$null_rej <= 0.08), collapse = ", ")), "",
  sprintf("Secondary networks (design separation only): %s.", paste(sprintf("%s cut-dependent %s, separation predicts %s", summ$net[summ$net != "af"], summ$cut_dependent[summ$net != "af"], summ$separation_predicts[summ$net != "af"]), collapse = "; ")), "",
  sprintf("Adjusted bridge (baselines regressed on the separations), mean |z| against the exchangeable bridge: %s.", paste(sprintf("%s %.2f vs %.2f", summ$net, summ$mean_abs_z_rbx, summ$mean_abs_z_rb), collapse = ", ")), "",
  sprintf("Cuts leaving a side with zero heterogeneity degrees of freedom, where any fit-based check is vacuous: %s.", paste(sprintf("%s %.2f", summ$net, summ$zero_df_share), collapse = ", ")), "",
  sprintf("Failed cells: %d.", sum(failed)), "",
  "| network | cuts | var z | null 95th | slope pop | slope design | cut-dependent | separation predicts | power | null rejection | real rejection |", "|---|---:|---:|---:|---:|---:|---|---|---:|---:|---:|",
  sprintf("| %s | %d | %.3f | %.3f | %.3f | %.3f | %s | %s | %.2f | %.3f | %.3f |", summ$net, summ$scored, summ$T_var, summ$null_q95_var, summ$T_pop, summ$T_des, summ$cut_dependent, summ$separation_predicts, summ$power_sep, summ$null_rej, summ$real_rej), "")
writeLines(md, "results/decision.md"); cat(md[1:15], sep = "\n")
