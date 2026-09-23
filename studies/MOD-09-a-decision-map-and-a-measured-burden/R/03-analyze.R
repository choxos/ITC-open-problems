## Map (paired MSE comparison), controls, analytic terms, burden; decision.
source("R/00-model.R")
g <- build_grid(); tr <- do.call(rbind, lapply(seq_len(nrow(g)), function(i) data.frame(cell = g$cell[i], t(truth(g[i, ])))))
d <- merge(do.call(rbind, lapply(list.files("results/run", pattern = "^cell", full.names = TRUE), readRDS)), tr, by = "cell"); d$e <- d$est - d$truth
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) { ok <- !is.na(z$est); n <- sum(ok); e <- z$e[ok]; cv <- abs(e) <= 1.96 * z$se[ok]
  data.frame(cell = z$cell[1], method = z$method[1], n = n, fail_rate = mean(!ok), truth = z$truth[1], gap_bias = z$gap_bias[1], aggregation_bias = z$aggregation_bias[1],
             bias = mean(e), mcse = stats::sd(e) / sqrt(n), coverage = mean(cv), mcse_cov = sqrt(mean(cv) * (1 - mean(cv)) / n), emp_sd = stats::sd(e), mean_se = mean(z$se[ok]),
             rmse = sqrt(mean(e^2)), ess = mean(z$ess[ok]), cpu_s = mean(z$sec[ok])) }))
summ <- merge(g, summ, by = "cell"); summ <- summ[order(summ$cell, summ$method), ]; write.csv(summ, "results/summary.csv", row.names = FALSE)

## Paired MSE differences (common random numbers: the same datasets for every method).
pw <- function(a, b) do.call(rbind, lapply(split(d, d$cell), function(z) { x <- merge(z[z$method == a, c("rep", "e")], z[z$method == b, c("rep", "e")], by = "rep")
  x <- x[stats::complete.cases(x), ]; dm <- x$e.x^2 - x$e.y^2
  data.frame(cell = z$cell[1], pair = paste(a, "-", b), mse_diff = mean(dm), mcse = stats::sd(dm) / sqrt(nrow(x)),
             winner = if (mean(dm) > 2 * stats::sd(dm) / sqrt(nrow(x))) b else if (mean(dm) < -2 * stats::sd(dm) / sqrt(nrow(x))) a else "tie") }))
map <- merge(g, rbind(pw("maic", "mlnmr"), pw("stc", "mlnmr")), by = "cell"); write.csv(map, "results/map.csv", row.names = FALSE)

mm <- map[map$pair == "maic - mlnmr", ]; sh <- mm[mm$em == "shared", ]; vi <- mm[mm$em == "violated", ]
key <- function(z) paste(z$gap, z$overlap, z$info); vi <- vi[match(key(sh), key(vi)), ]
verdict <- if (all(sh$winner == "mlnmr")) "NO BOUNDARY: ML-NMR better in every shared-modification cell" else
  if (!any(sh$winner == "mlnmr")) "NO BOUNDARY: MAIC competitive in every shared-modification cell (the adoption gap is rational here)" else "A MAP EXISTS: the winner changes with the pre-fitting factors"
flips <- sum(sh$winner == "mlnmr" & vi$winner != "mlnmr"); falsified <- any(sh$winner == "mlnmr") && flips >= ceiling(sum(sh$winner == "mlnmr") / 2)
nl <- summ[summ$em == "none", ]; null_ok <- all(abs(nl$bias) <= 3 * nl$mcse + 0.01 & nl$coverage >= 0.925 & nl$coverage <= 0.975)
pos <- mm[mm$gap == "high" & mm$overlap == "poor" & mm$info == "joint" & mm$em == "shared", ]
bf <- list.files("results/run", pattern = "^burden", full.names = TRUE)
bu <- if (length(bf)) merge(do.call(rbind, lapply(bf, readRDS)), d[d$method == "mlnmr", c("cell", "rep", "est", "se")], by = c("cell", "rep"), suffixes = c("_stan", "_ml")) else NULL
f3 <- function(x) sprintf("%.3f", x)
md <- c("# Decision", "", sprintf("**Registered primary: %s.** ML-NMR against MAIC by paired MSE (2 MCSE), shared-modification cells: ML-NMR wins %d, MAIC wins %d, ties %d of %d.",
          verdict, sum(sh$winner == "mlnmr"), sum(sh$winner == "maic"), sum(sh$winner == "tie"), nrow(sh)), "",
  sprintf("Falsifier (shared modification violated): ML-NMR's win is lost in %d of the %d cells it won; the map %s.", flips, sum(sh$winner == "mlnmr"),
          if (falsified) "DEPENDS ON AN ASSUMPTION THE ANALYST CANNOT CHECK, so no pre-fitting criterion is registered" else "survives"), "",
  sprintf("Null control (no modification, all populations equal; |bias| <= 3 MCSE + 0.01 and coverage 0.925 to 0.975 for every method): %s.", if (null_ok) "passes" else "FAILS"), "",
  sprintf("Positive control (high gap, poor overlap, joint target law, shared modification; ML-NMR must win against MAIC): %s (MSE difference %s, MCSE %s).",
          if (pos$winner == "mlnmr") "passes" else "FAILS: the method's advantage is unreachable here", f3(pos$mse_diff), f3(pos$mcse)), "",
  if (!is.null(bu)) c(sprintf("Burden, multinma under the fixed protocol (%d fits): median %.0f CPU s per fit against %.3f (MAIC), %.3f (STC), %.3f (ML-NMR by maximum likelihood); any divergence %.2f; refit %.2f; max Rhat above 1.01 %.2f; integration-check warnings %.2f; failed %d.",
      sum(!is.na(bu$cpu)), stats::median(bu$cpu, na.rm = TRUE), mean(summ$cpu_s[summ$method == "maic"]), mean(summ$cpu_s[summ$method == "stc"]), mean(summ$cpu_s[summ$method == "mlnmr"]),
      mean(bu$divergent > 0, na.rm = TRUE), mean(bu$refit, na.rm = TRUE), mean(bu$max_rhat > 1.01, na.rm = TRUE), mean(bu$int_check_warning, na.rm = TRUE), sum(!is.na(bu$error))),
    sprintf("multinma posterior mean within 0.25 posterior SD of the maximum-likelihood estimate: %.2f of fits.", mean(abs(bu$est_stan - bu$est_ml) <= 0.25 * bu$sd, na.rm = TRUE)), "") else "Burden subsample not run.",
  "| gap | overlap | target information | modification | method | failed | truth | gap term | aggregation term | bias (MCSE) | coverage | empirical SD | mean SE | RMSE | ESS |",
  "|---|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %s | %s | %s | %s | %s | %.3f | %.3f | %.3f | %.3f | %.3f (%.3f) | %.3f | %.3f | %.3f | %.3f | %s |", summ$gap, summ$overlap, summ$info, summ$em, summ$method, summ$fail_rate,
          summ$truth, summ$gap_bias, summ$aggregation_bias, summ$bias, summ$mcse, summ$coverage, summ$emp_sd, summ$mean_se, summ$rmse, ifelse(is.na(summ$ess), "", sprintf("%.0f", summ$ess))), "",
  "| gap | overlap | target information | modification | pair | MSE difference (MCSE) | winner |", "|---|---|---|---|---|---:|---|",
  sprintf("| %s | %s | %s | %s | %s | %.4f (%.4f) | %s |", map$gap, map$overlap, map$info, map$em, map$pair, map$mse_diff, map$mcse, map$winner), "")
writeLines(md, "results/decision.md"); cat(md[1:11], sep = "\n")
