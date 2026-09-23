## RMSE by method with and without reconstruction; ranking flips and attribution shares.
source("R/00-model.R")
g <- build_grid_dia()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
M <- c("km_ipd", "weibull_ipd", "km_recon", "weibull_recon", "curve")
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) do.call(rbind, lapply(M, function(m) { e <- z[[m]] - TRUE_RMST
  data.frame(cell = z$cell[1], method = m, bias = mean(e), rmse = sqrt(mean(e^2)), n = nrow(z)) }))))
summ <- merge(g, summ, by = "cell"); write.csv(summ, "results/summary.csv", row.names = FALSE)
w <- stats::reshape(summ[, c("cell", "res", "table", "cens", "method", "rmse")], idvar = c("cell", "res", "table", "cens"), timevar = "method", direction = "wide")
w$best_ipd <- ifelse(w$rmse.km_ipd <= w$rmse.weibull_ipd, "KM", "Weibull"); w$best_recon <- ifelse(w$rmse.km_recon <= w$rmse.weibull_recon, "KM", "Weibull")
w$share_km <- 1 - w$rmse.km_ipd^2 / w$rmse.km_recon^2; w$share_wb <- 1 - w$rmse.weibull_ipd^2 / w$rmse.weibull_recon^2
write.csv(w, "results/ranking.csv", row.names = FALSE)
flips <- sum(w$best_ipd != w$best_recon); shifted <- any(w$rmse.km_recon / w$rmse.km_ipd >= 1.05 | w$rmse.weibull_recon / w$rmse.weibull_ipd >= 1.05)
verdict <- if (flips > 0) "CONFIRMED: reconstruction changed the ranking" else if (shifted) "RANKING PRESERVED, LEVELS SHIFTED" else "REFUTED: ranking and levels preserved"
f3 <- function(x) sprintf("%.3f", x)
md <- c("# Decision", "", sprintf("**Registered primary: %s.** Cells where the better of KM and Weibull differs with and without reconstruction: %d of %d.", verdict, flips, nrow(w)), "",
  sprintf("Share of each method's mean squared error attributable to reconstruction: KM %s to %s; Weibull %s to %s.", f3(min(w$share_km)), f3(max(w$share_km)), f3(min(w$share_wb)), f3(max(w$share_wb))), "",
  "| resolution | risk table | censoring | RMSE KM (true data) | KM (reconstructed) | Weibull (true data) | Weibull (reconstructed) | digitized curve | share KM | share Weibull |",
  "|---|---:|---|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %s | %s | %s | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f |", w$res, ifelse(w$table == 0, "none", "6-monthly"), w$cens, w$rmse.km_ipd, w$rmse.km_recon, w$rmse.weibull_ipd, w$rmse.weibull_recon, w$rmse.curve, w$share_km, w$share_wb), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
