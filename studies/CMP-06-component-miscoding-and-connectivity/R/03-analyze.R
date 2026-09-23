## Estimability, bias and coverage by method; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) { e <- z$det_estimable == 1; m <- z$n_miscoded > 0 & e
  data.frame(cell = z$cell[1], nonestimable = mean(!e), det_cover = mean(z$det_cover[e]), det_cover_miscoded = if (any(m)) mean(z$det_cover[m]) else NA,
             det_bias_miscoded = if (any(m)) mean(z$det_bias[m]) else NA, det_width = mean(z$det_width[e]),
             sens_cover = mean(z$sens_cover), sens_bounded = mean(z$sens_bounded), prob_cover = mean(z$prob_cover), prob_bounded = mean(z$prob_bounded),
             prob_width = mean(z$prob_width[z$prob_bounded]), n = nrow(z)) }))
summ <- merge(g, summ, by = "cell"); write.csv(summ, "results/summary.csv", row.names = FALSE)
ch <- summ[summ$type == "changing" & summ$p > 0, ]
confirmed <- any(ch$det_cover < 0.90 & ch$prob_cover >= 0.93)
refuted <- all(ch$det_cover >= 0.93 & ch$prob_cover >= 0.93)
nul <- summ[summ$p == 0, ]; pres <- summ[summ$type == "preserving", ]; pos <- summ[summ$type == "changing" & summ$p == 0.3, ]
f3 <- function(x) sprintf("%.3f", x)
md <- c("# Decision", "", sprintf("**Registered primary (connectivity-changing miscoding): %s.** Deterministic coverage given estimability %s; probabilistic coding %s.",
          if (confirmed) "CONFIRMED" else if (refuted) "REFUTED for inference" else "MIXED", paste(f3(ch$det_cover), collapse = ", "), paste(f3(ch$prob_cover), collapse = ", ")), "",
  sprintf("Null control (no miscoding: deterministic coverage 0.93 to 0.97): %s (%s).", nul$det_cover >= 0.93 & nul$det_cover <= 0.97, f3(nul$det_cover)), "",
  sprintf("Second null control (connectivity-preserving miscoding leaves inference approximately nominal, 0.93 or more): %s (%s).", all(pres$det_cover >= 0.93), paste(f3(pres$det_cover), collapse = ", ")), "",
  sprintf("Positive control (connectivity-changing at p = 0.3: target non-estimable in a substantial fraction, at least 5%%): %s (%s).", pos$nonestimable >= 0.05, f3(pos$nonestimable)), "",
  "| type | p | non-estimable | deterministic coverage | given a miscoding | bias given a miscoding | sensitivity coverage | sensitivity bounded | probabilistic coverage | probabilistic bounded |",
  "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %s | %.2f | %.3f | %.3f | %s | %s | %.3f | %.3f | %.3f | %.3f |", summ$type, summ$p, summ$nonestimable, summ$det_cover, ifelse(is.na(summ$det_cover_miscoded), "", f3(summ$det_cover_miscoded)),
          ifelse(is.na(summ$det_bias_miscoded), "", f3(summ$det_bias_miscoded)), summ$sens_cover, summ$sens_bounded, summ$prob_cover, summ$prob_bounded), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
