## Detectors of infeasibility, consequences, decision.
## Writes results/summary.csv, results/detectors.csv, results/decision.md.
source("R/00-model.R")
g <- build_grid()
d <- do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS))
d <- merge(d, g, by = "cell")
d$infeas <- d$feasible == 0
d$cover <- abs(d$err) <= 1.96 * d$se
auroc <- function(s, y) { r <- rank(c(s[y], s[!y])); ny <- sum(y)
  (sum(r[seq_len(ny)]) - ny * (ny + 1) / 2) / (ny * sum(!y)) }
det <- data.frame(detector = c("ESS (low)", "max weight", "residual imbalance", "optimizer non-convergence"),
  auroc = c(auroc(-d$ess, d$infeas), auroc(d$max_w, d$infeas), auroc(d$resid, d$infeas),
            auroc(as.numeric(d$conv != 0), d$infeas)))
n <- 2 * N_ARM
flag <- d$ess < 0.10 * n
det$flag_infeasible <- c(mean(flag[d$infeas]), NA, mean(d$resid[d$infeas] > 1e-3), mean(d$conv[d$infeas] != 0))
det$flag_feasible <- c(mean(flag[!d$infeas]), NA, mean(d$resid[!d$infeas] > 1e-3), mean(d$conv[!d$infeas] != 0))
write.csv(det, "results/detectors.csv", row.names = FALSE)

summ <- do.call(rbind, lapply(split(d, d$cell), function(z) {
  f <- z$feasible == 1
  data.frame(cell = z$cell[1], s = z$s[1], p_infeasible = mean(!f),
             silent = if (any(!f)) mean(z$conv[!f] == 0) else NA,
             ess_med_feas = if (any(f)) stats::median(z$ess[f]) else NA,
             ess_med_infeas = if (any(!f)) stats::median(z$ess[!f]) else NA,
             bias_feas = if (any(f)) mean(z$err[f], na.rm = TRUE) else NA,
             bias_infeas = if (any(!f)) mean(z$err[!f], na.rm = TRUE) else NA,
             cover_feas = if (any(f)) mean(z$cover[f], na.rm = TRUE) else NA,
             cover_infeas = if (any(!f)) mean(z$cover[!f], na.rm = TRUE) else NA,
             resid_max_feas = if (any(f)) max(z$resid[f]) else NA,
             resid_min_infeas = if (any(!f)) min(z$resid[!f]) else NA)
}))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)

e <- det[det$detector == "ESS (low)", ]
holds <- e$auroc >= 0.95 && e$flag_infeasible >= 0.95 && e$flag_feasible <= 0.20
easy <- summ[summ$shift == "easy", ]
c_easy <- all(easy$p_infeasible == 0) && all(easy$resid_max_feas < 1e-4)
md <- c("# Decision", "", sprintf("**Refuting sentence (ESS conventions catch infeasibility): %s.**",
  if (holds) "HOLDS" else "FAILS"), "",
  "| detector | AUROC for infeasibility | flags infeasible | flags feasible |", "|---|---:|---:|---:|",
  sprintf("| %s | %.3f | %s | %s |", det$detector, det$auroc,
          ifelse(is.na(det$flag_infeasible), "", sprintf("%.3f", det$flag_infeasible)),
          ifelse(is.na(det$flag_feasible), "", sprintf("%.3f", det$flag_feasible))), "",
  "ESS flags use ESS below 10% of n; residual flags use residual above 1e-3; optimizer flags use a nonzero convergence code.", "",
  sprintf("Infeasible replicates the optimizer reported as converged: %.1f%%.", 100 * mean(d$conv[d$infeas] == 0)), "",
  sprintf("Easy-shift control (all feasible, residual below 1e-4): %s.", c_easy), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
