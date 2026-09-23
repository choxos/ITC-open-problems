## Coverage and width by method and study count; minimum study count; decision.
source("R/00-model.R")
g <- build_grid(); tr <- truth()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) { cv <- mean(abs(z$est - tr) <= z$crit * z$se)
  data.frame(cell = z$cell[1], method = z$method[1], bias = mean(z$est - tr), coverage = cv, cov_mcse = sqrt(cv * (1 - cv) / nrow(z)), width = mean(2 * z$crit * z$se)) }))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
band <- function(m) { z <- summ[summ$method == m, ]; ok <- tapply(z$coverage >= 0.93 & z$coverage <= 0.97, z$K, all); ks <- as.integer(names(ok))
  bad <- ks[!ok]; if (length(bad) == 0) min(ks) else if (max(bad) == max(ks)) NA else min(ks[ks > max(bad)]) }
mins <- sapply(c("naive_dl", "naive_hk", "twostep_dl", "twostep_hk"), band)
small <- summ[summ$K <= 4, ]
fails <- any(small$coverage[small$method %in% c("naive_dl", "twostep_dl")] < 0.93)
md <- c("# Decision", "",
  sprintf("**Refuting sentence (population-adjusted intervals are conservative enough at small study counts): %s.** Coverage at two to four trials: naive DerSimonian-Laird %.3f to %.3f, two-step DerSimonian-Laird %.3f to %.3f, two-step Hartung-Knapp %.3f to %.3f.",
          if (fails) "FAILS" else "HOLDS", min(small$coverage[small$method == "naive_dl"]), max(small$coverage[small$method == "naive_dl"]),
          min(small$coverage[small$method == "twostep_dl"]), max(small$coverage[small$method == "twostep_dl"]),
          min(small$coverage[small$method == "twostep_hk"]), max(small$coverage[small$method == "twostep_hk"])), "",
  sprintf("Smallest study count from which coverage stays within 0.93 to 0.97 at every heterogeneity level: %s.",
          paste(sprintf("%s %s", names(mins), ifelse(is.na(mins), "none", mins)), collapse = "; ")), "",
  "| K | tau | method | coverage | width | bias |", "|---:|---:|---|---:|---:|---:|",
  sprintf("| %d | %.1f | %s | %.3f | %.3f | %.3f |", summ$K, summ$tau, summ$method, summ$coverage, summ$width, summ$bias), "")
writeLines(md, "results/decision.md"); cat(md[1:5], sep = "\n")
