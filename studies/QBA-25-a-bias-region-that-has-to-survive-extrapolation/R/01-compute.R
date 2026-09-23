## Decision-reversal probabilities by propagation method; cross versus region.
## Writes results/summary.csv, results/surface.csv and results/decision.md.
source("R/00-model.R"); set.seed(20261202)
N <- 4000; th <- stats::rnorm(N, LHR_HAT, SE); bb <- stats::runif(N, -B_MAX, B_MAX); fam <- sample(FAMILIES, N, replace = TRUE)
p_neg <- function(v) mean(v < 0)
point <- vapply(th, function(t) inb(t, "ph", COST_TX), 0)
fam_only <- lapply(FAMILIES, function(f) vapply(th, function(t) inb(t, f, COST_TX), 0))
joint <- mapply(function(t, b, f) inb(t - b, f, COST_TX), th, bb, fam)
joint_f <- lapply(FAMILIES, function(f) mapply(function(t, b) inb(t - b, f, COST_TX), th, bb))
bgrid <- seq(-B_MAX, B_MAX, length.out = 31)
surface <- expand.grid(b = bgrid, family = FAMILIES, stringsAsFactors = FALSE)
surface$inb <- mapply(function(b, f) inb(LHR_HAT - b, f, COST_TX), surface$b, surface$family)
cross <- c(surface$inb[surface$family == "ph"], surface$inb[abs(surface$b) < 1e-12])
res <- data.frame(method = c("point propagation (PH, b = 0)", paste("family", FAMILIES, "(b = 0)"), "joint over b and family", paste("joint over b,", FAMILIES)),
                  p_reversal = c(p_neg(point), vapply(fam_only, p_neg, 0), p_neg(joint), vapply(joint_f, p_neg, 0)),
                  mean_inb = c(mean(point), vapply(fam_only, mean, 0), mean(joint), vapply(joint_f, mean, 0)))
write.csv(res, "results/summary.csv", row.names = FALSE); write.csv(surface, "results/surface.csv", row.names = FALSE)
sc <- data.frame(scenario = c(sprintf("PH, b = %+.2f", c(-B_MAX, B_MAX)), paste(FAMILIES, "b = 0")),
                 inb = c(inb(LHR_HAT + B_MAX, "ph", COST_TX), inb(LHR_HAT - B_MAX, "ph", COST_TX), vapply(FAMILIES, function(f) inb(LHR_HAT, f, COST_TX), 0)))
write.csv(sc, "results/scenarios.csv", row.names = FALSE)
ratio <- res$p_reversal[res$method == "joint over b and family"] / res$p_reversal[1]
md <- c("# Decision", "", sprintf("**Registered primary: %s.** Decision-reversal probability: point propagation %.3f; joint over bias and extrapolation family %.3f (ratio %.2f).",
          if (ratio >= 1.5) "CONFIRMED (point propagation understates reversal)" else "REFUTED", res$p_reversal[1], res$p_reversal[res$method == "joint over b and family"], ratio), "",
  sprintf("Scenario analysis (current guidance): INB %s.", paste(sprintf("%s %.0f", sc$scenario, sc$inb), collapse = "; ")), "",
  sprintf("Cross versus region at the reported estimate: lowest INB on the one-at-a-time cross %.0f, over the joint region %.0f.", min(cross), min(surface$inb)), "",
  sprintf("Treatment cost per year: %.0f (90%% of the PH break-even).", COST_TX), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n"); print(res)
