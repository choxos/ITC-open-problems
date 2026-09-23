## ---------------------------------------------------------------------------
## DEC-02: which analysis choice flips a decision, re-scored on DIA-08's stored
## replicates (16 scenarios x 2000; per replicate the estimate of the target
## marginal log OR, B versus A, from five methods).
## Decision: adopt B when the estimate is below tau, tau = truth + d, d in
## {-0.1, 0.1} (near) and {-0.3, 0.3} (far). Within one decision question, a
## choice flips the decision when its two options disagree:
##   family     MAIC on means against linear STC
##   form       linear against quadratic STC
##   moments    MAIC on means against MAIC on means and SDs
##   adjust     unadjusted against linear STC
## Across questions, the target population changes the true decision itself:
## reported as the change in the true effect across target means 0.3, 0.8, 1.2.
## ---------------------------------------------------------------------------
SRC <- "../DIA-08-generators-that-decide-the-comparison"
g <- unique(read.csv(file.path(SRC, "results/summary.csv"))[, c("cell", "departure", "m", "law")])
pairs <- list(family = c("maic_means", "stc_linear"), form = c("stc_linear", "stc_flexible"), moments = c("maic_means", "maic_means_sds"), adjust = c("unadjusted", "stc_linear"))
D <- c(-0.3, -0.1, 0.1, 0.3)
score <- function(f) { z <- readRDS(f); w <- reshape(z[, c("rep", "method", "est")], idvar = "rep", timevar = "method", direction = "wide"); tr <- z$truth[1]
  do.call(rbind, lapply(D, function(dd) { tau <- tr + dd; right <- tr < tau
    do.call(rbind, lapply(names(pairs), function(k) { a <- w[[paste0("est.", pairs[[k]][1])]] < tau; b <- w[[paste0("est.", pairs[[k]][2])]] < tau
      data.frame(cell = z$cell[1], d = dd, choice = k, flip = mean(a != b, na.rm = TRUE), wrong_first = mean(a != right, na.rm = TRUE), wrong_second = mean(b != right, na.rm = TRUE)) })) })) }
s <- merge(g, do.call(rbind, lapply(list.files(file.path(SRC, "results/run"), full.names = TRUE), score)), by = "cell")
write.csv(s, "results/flips.csv", row.names = FALSE)
near <- s[abs(s$d) == 0.1, ]
rank <- aggregate(flip ~ choice, near, mean); rank <- rank[order(-rank$flip), ]
dom <- rank$flip[1] >= 3 * rank$flip[2]
tt <- aggregate(truth ~ m + departure, data = merge(g, unique(do.call(rbind, lapply(list.files(file.path(SRC, "results/run"), full.names = TRUE), function(f) { z <- readRDS(f); data.frame(cell = z$cell[1], truth = z$truth[1]) }))), by = "cell")[g$law == "normal", ], FUN = mean)
md <- c("# Decision", "",
  sprintf("**Refuting sentence (one choice dominates so heavily that a ranking is uninformative): %s.** Mean flip rate near the threshold: %s.",
          if (dom) "HOLDS" else "FAILS", paste(sprintf("%s %.3f", rank$choice, rank$flip), collapse = "; ")), "",
  "Across decision questions, the true effect by target covariate mean (normal covariates):", "",
  "| departure | target mean | true log OR |", "|---|---:|---:|", sprintf("| %s | %.1f | %.3f |", tt$departure, tt$m, tt$truth), "",
  "| departure | target mean | law | threshold offset | choice | flip rate | wrong, first option | wrong, second option |", "|---|---:|---|---:|---|---:|---:|---:|",
  sprintf("| %s | %.1f | %s | %+.1f | %s | %.3f | %.3f | %.3f |", s$departure, s$m, s$law, s$d, s$choice, s$flip, s$wrong_first, s$wrong_second), "")
writeLines(md, "results/decision.md"); cat(md[1:3], sep = "\n")
