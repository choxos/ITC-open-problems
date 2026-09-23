## Coverage of the boundary, Fieller set types, regret, map calibration; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$estimator), drop = TRUE), function(z) { n <- nrow(z); b <- z$f_type == "bounded"
  data.frame(cell = z$cell[1], estimator = z$estimator[1], median_beta_z = stats::median(z$beta_z), between_share = mean(z$between_share),
             delta_cov = mean(z$delta_cover), delta_mcse = sqrt(mean(z$delta_cover) * (1 - mean(z$delta_cover)) / n),
             fieller_cov = mean(z$f_cover), bounded = mean(b), whole_line = mean(z$f_type == "whole_line"), exclusive = mean(z$f_type == "exclusive"),
             fieller_cov_bounded = if (any(b)) mean(z$f_cover[b]) else NA, median_bounded_width = if (any(b)) stats::median(z$f_width[b]) else NA,
             median_abs_error = stats::median(abs(z$xhat - z$xstar)), regret = mean(z$regret), regret_share = mean(z$regret) / z$value[1],
             false_certain = mean(z$false_certain), brier = mean(z$brier)) }))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
inb <- function(x) x >= 0.93 & x <= 0.97
mod <- summ[summ$beta == 0.15, ]
refuted <- all(inb(summ$delta_cov)) && all(1 - mod$bounded < 0.05)
nc <- summ[summ$b_eco == 0 & summ$beta == 0.3, ]; null_ok <- all(inb(nc$delta_cov) & inb(nc$fieller_cov) & nc$false_certain <= 0.025 + 0.01)
pc <- summ[summ$beta == 0.05 & summ$estimator == "within", ]; pos_ok <- all(1 - pc$bounded >= 0.5)
eco <- summ[summ$b_eco > 0, ]; eco0 <- summ[summ$b_eco == 0, ]
f3 <- function(x) sprintf("%.3f", x); rg <- function(x) paste(f3(min(x)), "to", f3(max(x)))
md <- c("# Decision", "", sprintf("**Refuting sentence (the boundary is well determined, so a point cut-point is harmless): %s.**", if (refuted) "HOLDS" else "FAILS"), "",
  sprintf("Delta-method coverage of x*: %s over all cells and estimators. Fieller sets unbounded at moderate interaction (0.15): within %s, combined %s.",
          rg(summ$delta_cov), rg(1 - mod$bounded[mod$estimator == "within"]), rg(1 - mod$bounded[mod$estimator == "combined"])), "",
  sprintf("Null control (no ecological term, interaction 0.3: delta and Fieller coverage 0.93 to 0.97 and false certainty at most 0.035): %s.", null_ok), "",
  sprintf("Positive control (interaction 0.05, within: Fieller unbounded in at least half of replicates): %s (%s).", pos_ok, rg(1 - pc$bounded)), "",
  sprintf("Ecological term: combined-estimator Fieller coverage %s with it and %s without; within-estimator %s with it.",
          rg(eco$fieller_cov[eco$estimator == "combined"]), rg(eco0$fieller_cov[eco0$estimator == "combined"]), rg(eco$fieller_cov[eco$estimator == "within"])), "",
  "| interaction | x* | ecological term | estimator | median z of interaction | between share | delta coverage | Fieller coverage | bounded | whole line | exclusive | median bounded width | regret share | false certainty |",
  "|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %.2f | %.1f | %.1f | %s | %.1f | %.2f | %.3f | %.3f | %.3f | %.3f | %.3f | %.2f | %.3f | %.3f |", summ$beta, summ$xstar, summ$b_eco, summ$estimator, summ$median_beta_z,
          summ$between_share, summ$delta_cov, summ$fieller_cov, summ$bounded, summ$whole_line, summ$exclusive, summ$median_bounded_width, summ$regret_share, summ$false_certain), "")
writeLines(md, "results/decision.md"); cat(md[1:11], sep = "\n")
