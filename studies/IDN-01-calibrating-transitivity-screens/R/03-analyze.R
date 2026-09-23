## Detection by screen and mechanism, estimator bias, mechanism identification; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
d$f_dis <- d$p_dissim < ALPHA; d$f_inc <- d$p_incons < ALPHA; d$f_het <- d$p_het < ALPHA; d$f_any <- d$f_dis | d$f_inc | d$f_het
## Mechanism read from the pattern of flags (the only reading the screens support).
d$called <- ifelse(!d$f_any, "none", ifelse(d$f_dis, "measured_em", ifelse(d$f_inc, "loop_break", "drift")))
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) { e <- z$est - z$truth; n <- nrow(z)
  data.frame(cell = z$cell[1], bias = mean(e), mcse = stats::sd(e) / sqrt(n), coverage = mean(abs(e) <= 1.96 * z$se),
             dissim = mean(z$f_dis), incons = mean(z$f_inc), het = mean(z$f_het), any = mean(z$f_any),
             called_right = mean(z$called == z$mech[1] | (z$mech[1] == "unmeasured_em" & z$called == "none"))) }))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
null_any <- summ$any[summ$mech == "none"]
um <- summ[summ$mech == "unmeasured_em" & summ$V == 0.4, ]
fails <- all(um$any <= max(null_any) + 0.05) && all(abs(um$bias) > 0.1)
conf <- table(d$mech, d$called)
write.csv(as.data.frame.matrix(conf), "results/confusion.csv")
md <- c("# Decision", "",
  sprintf("**Refuting sentence (the screens together detect the violations that bias the target contrast): %s.** Loop-consistent unmeasured modification, violation 0.4: any-screen detection %s against %s under no violation; bias %s.",
          if (fails) "FAILS" else "HOLDS", paste(sprintf("%.3f", um$any), collapse = ", "), paste(sprintf("%.3f", null_any), collapse = ", "),
          paste(sprintf("%.3f", um$bias), collapse = ", ")), "",
  "| mechanism | V | studies per comparison | bias | coverage | dissimilarity | inconsistency | heterogeneity | any | pattern read correctly |",
  "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %s | %.1f | %d | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f |", summ$mech, summ$V, summ$M, summ$bias, summ$coverage,
          summ$dissim, summ$incons, summ$het, summ$any, summ$called_right), "",
  "Mechanism against the pattern of flags (rows true, columns called), all cells pooled:", "",
  paste("|", paste(c("", colnames(conf)), collapse = " | "), "|"), paste(rep("|---", ncol(conf) + 1), collapse = ""),
  sapply(rownames(conf), function(r) paste("|", paste(c(r, conf[r, ]), collapse = " | "), "|")), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
