## Prediction error of each planning quantity; decision.
source("R/00-model.R")
g <- build_grid()
r <- lapply(list.files("results/run", full.names = TRUE), readRDS)
summ <- do.call(rbind, lapply(r, function(z) {
  e <- z$est[is.finite(z$est)]; n <- length(e); s <- stats::sd(e)
  ## MCSE of an SD: s / sqrt(2 (n - 1))
  data.frame(cell = z$cell, achieved = s, achieved_mcse = s / sqrt(2 * (n - 1)), n_ok = n, t(z$plan))
}))
summ <- merge(g, summ, by = "cell")
for (m in c("se_nominal", "se_kish", "se_influence")) summ[[paste0("ratio_", sub("se_", "", m))]] <- summ[[m]] / summ$achieved
write.csv(summ, "results/summary.csv", row.names = FALSE)
w10 <- function(x) mean(abs(x - 1) <= 0.10)
md <- c("# Decision", "",
  sprintf("**Refuting sentence (Kish-adjusted n predicts achieved precision within 10%% in at least 90%% of cells): %s** (%.0f%% of cells).",
          if (w10(summ$ratio_kish) >= 0.9) "HOLDS" else "FAILS", 100 * w10(summ$ratio_kish)), "",
  "| planning quantity | cells within 10% | median ratio planned/achieved | range |", "|---|---:|---:|---|",
  sprintf("| %s | %.0f%% | %.3f | %s |", c("nominal n", "Kish ESS", "influence function"),
          100 * c(w10(summ$ratio_nominal), w10(summ$ratio_kish), w10(summ$ratio_influence)),
          c(stats::median(summ$ratio_nominal), stats::median(summ$ratio_kish), stats::median(summ$ratio_influence)),
          sprintf("%.3f to %.3f", c(min(summ$ratio_nominal), min(summ$ratio_kish), min(summ$ratio_influence)),
                  c(max(summ$ratio_nominal), max(summ$ratio_kish), max(summ$ratio_influence)))), "",
  sprintf("Direction of the Kish error (DESIGN.md predicted pessimism, planned SE above achieved): pessimistic in %.0f%% of cells.",
          100 * mean(summ$ratio_kish > 1)), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
