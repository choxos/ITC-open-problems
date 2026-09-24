## P3 tempering implementation (second null control), smoke run of every arm, unit cost.
## Writes results/probes.md.   nice -n 19 Rscript R/01-probes.R
source("R/00-model.R"); g <- build_grid(); out <- c("# Probes", "")

## P3: flat Gaussian model (tau fixed at 0, prior SD 1e3, no covariate). Tempering at
## eta = 0.5 must leave the posterior mean unchanged and double the variance.
set.seed(3); d <- list(x = rep(0, 8), s = stats::runif(8, 0.1, 0.3), ipd = rep(FALSE, 8), v = rep(1, 8), b = rep(NA, 8))
d$y <- stats::rnorm(8, 0.2, d$s)
f1 <- fit_re(d, 1, 0, prior_sd = 1e3, tau_grid = 0, xT = 0); f5 <- fit_re(d, 0.5, 0, prior_sd = 1e3, tau_grid = 0, xT = 0)
p3_shift <- abs(f5[["mean_est"]] - f1[["mean_est"]]) / f1[["mean_sd"]]; p3_var <- (f5[["mean_sd"]] / f1[["mean_sd"]])^2
out <- c(out, "## P3 flat-model tempering (second null control)", "",
  sprintf("- mean shift at eta 0.5: %.1e posterior SD; variance ratio %.6f (exact: 0 and 2)", p3_shift, p3_var), "")
stopifnot(p3_shift < 1e-6, abs(p3_var - 2) < 1e-6)

## Smoke: one replicate in every cell type, timed; every arm must return finite values.
set.seed(5); tm <- numeric(0); sm <- NULL
for (i in c(1, 3, 10, 12)) { cc <- g[i, ]
  t0 <- proc.time()[["user.self"]]; r <- one_rep(cc); tm[as.character(i)] <- proc.time()[["user.self"]] - t0
  stopifnot(all(is.finite(as.matrix(r[, c("pred_lo", "pred_hi", "logscore", "mean_est", "mean_sd")]))))
  sm <- rbind(sm, data.frame(cell = i, r[, c("arm", "pred_lo", "pred_hi", "logscore", "mean_est", "K", "psame", "tau", "ipd_share")], thetaT = r$thetaT)) }
f2 <- function(x) ifelse(is.na(x), "", sprintf("%.2f", x))
out <- c(out, "## Smoke run (one replicate per listed cell)", "",
  "| cell | arm | predictive 95% | log score | mean contrast | K | co-clustering | tau | IPD share |", "|---:|---|---|---:|---:|---:|---:|---:|---:|",
  sprintf("| %d | %s | %.2f to %.2f | %.2f | %.3f | %s | %s | %s | %s |", sm$cell, sm$arm, sm$pred_lo, sm$pred_hi, sm$logscore, sm$mean_est,
          f2(sm$K), f2(sm$psame), f2(sm$tau), f2(sm$ipd_share)), "",
  sprintf("- prior-dependence ratio (co-clustering) per smoke cell: %s", paste(vapply(split(sm, sm$cell), function(z) sprintf("cell %d %.2f", z$cell[1],
    (z$psame[z$arm == "dplo_1"] - z$psame[z$arm == "dphi_1"]) / (prior_same(A_DP[1]) - prior_same(A_DP[3]))), ""), collapse = ", ")), "")

## Null-control check on a handful of replicates: one cluster, 12 studies, half IPD.
set.seed(7); nc <- g[g$het == "one" & g$J == 12 & g$ipd == "half", ]
nr <- do.call(rbind, lapply(1:6, function(k) one_rep(nc)))
dl <- tapply(nr$logscore, nr$arm, mean)
out <- c(out, "## Null control, 6 replicates (one cluster, 12 studies, half IPD)", "",
  sprintf("- mean log score: %s; dp minus re %.3f (registered: within 0.05 at 400 replicates)",
          paste(sprintf("%s %.3f", names(dl), dl), collapse = ", "), dl[["dp_1"]] - dl[["re_1"]]), "")

## Unit cost and total.
cpu <- mean(tm); tot <- nrow(g) * N_SIM * cpu / 3600
out <- c(out, "## Unit cost", "",
  sprintf("- CPU per replicate (7 fits): %s s for cells %s", paste(sprintf("%.1f", tm), collapse = ", "), paste(names(tm), collapse = ", ")),
  sprintf("- total CPU for %d cells x %d replicates: about %.1f hours (user time, measured under load average %.0f; an upper bound)",
          nrow(g), N_SIM, tot, as.numeric(strsplit(system("sysctl -n vm.loadavg", intern = TRUE), " ")[[1]][2])), "")
writeLines(out, "results/probes.md"); cat(out, sep = "\n")
