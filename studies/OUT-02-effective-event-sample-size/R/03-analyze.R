## Diagnostics as predictors of failure, the registered direction check, controls.
## Writes results/summary.csv and results/decision.md.
source("R/00-model.R")
g <- build_grid()
d <- do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS))
d <- merge(d, g, by = "cell")
d$fail <- d$ok == 0 | abs(d$est - d$truth) > 1.96 * d$se
d$fail[is.na(d$fail)] <- TRUE

summ <- do.call(rbind, lapply(split(d, d$cell), function(z) {
  ok <- z$ok == 1; e <- z$est[ok] - z$truth[ok]; n <- sum(ok)
  cv <- mean(abs(e) <= 1.96 * z$se[ok])
  data.frame(cell = z$cell[1], no_est = mean(!ok), bias = mean(e), mcse = stats::sd(e) / sqrt(n),
             coverage = cv, cov_mcse = sqrt(cv * (1 - cv) / n), fail = mean(z$fail),
             med_ratio = stats::median(z$eess_pop / z$essp_pop), med_eess = stats::median(z$eess),
             med_essp = stats::median(z$essp), med_ess = stats::median(z$ess))
}))
summ <- merge(summ, g, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)

auroc <- function(s, y) { r <- rank(c(s[y], s[!y])); ny <- sum(y)
  (sum(r[seq_len(ny)]) - ny * (ny + 1) / 2) / (ny * sum(!y)) }
## Low values read as risk, so score = -diagnostic.
set.seed(1)
bs <- replicate(200, { i <- sample.int(nrow(d), replace = TRUE); z <- d[i, ]
  c(auroc(-z$eess, z$fail), auroc(-z$essp, z$fail), auroc(-z$ess, z$fail)) })
a <- c(eess = auroc(-d$eess, d$fail), essp = auroc(-d$essp, d$fail), ess = auroc(-d$ess, d$fail))
dd <- a[["eess"]] - a[["essp"]]; dd_se <- stats::sd(bs[1, ] - bs[2, ])
verdict <- if (dd >= 0.05) "CONFIRMED" else if (abs(dd) <= 0.02) "REFUTED" else "BORDERLINE"

al <- summ[summ$direction == "aligned", ]; mi <- summ[summ$direction == "misaligned", ]
ind <- summ[summ$direction == "independent", ]
dir_ok <- all(al$med_ratio < 1) && all(mi$med_ratio > 1)
c_ind <- all(abs(ind$med_ratio - 1) <= 0.05)
nc <- summ[summ$shift == 0.3 & summ$risk == 0.10 & summ$n == 1000, ]
c_null <- all(nc$coverage >= 0.93 & nc$coverage <= 0.97)
r2 <- function(x) summary(stats::lm(summ$fail ~ log(pmax(x, 1e-3))))$r.squared

md <- c("# Decision", "", sprintf("**Registered primary: %s.**", verdict), "",
  sprintf("Per-replicate AUROC for failure (no estimate or non-coverage), pooled over %d replicates: EESS %.3f, ESS x p-hat %.3f, ESS %.3f. Difference EESS minus ESS x p-hat %.3f (bootstrap SE %.3f).",
          nrow(d), a[["eess"]], a[["essp"]], a[["ess"]], dd, dd_se), "",
  sprintf("Registered direction: median EESS/(ESS p) below 1 in all aligned cells and above 1 in all misaligned cells: %s. Ranges: aligned %.3f to %.3f; misaligned %.3f to %.3f; independent %.3f to %.3f.",
          dir_ok, min(al$med_ratio), max(al$med_ratio), min(mi$med_ratio), max(mi$med_ratio),
          min(ind$med_ratio), max(ind$med_ratio)), "",
  sprintf("Cell-level failure rate explained by log median diagnostic, R^2: EESS %.3f, ESS x p-hat %.3f, ESS %.3f.",
          r2(summ$med_eess), r2(summ$med_essp), r2(summ$med_ess)), "",
  sprintf("Controls: independent direction ratio within 0.05 of 1: %s; null coverage in band: %s.", c_ind, c_null), "")
write.csv(data.frame(diagnostic = c("EESS", "ESS x p-hat", "ESS"), auroc = c(a[["eess"]], a[["essp"]], a[["ess"]]), diff_se = c(dd_se, NA, NA)), "results/auroc.csv", row.names = FALSE)
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
