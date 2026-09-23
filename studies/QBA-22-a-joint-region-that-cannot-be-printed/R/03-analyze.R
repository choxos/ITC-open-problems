## Continuous summaries scored as classifiers of a decision flip (AUROC, pooled over
## the three-mechanism cells by world); verdict rules' false reassurance and false
## fragility by cell; metric dependence; order dependence of sequential correction
## (exact); controls; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
lost <- sum(is.na(d$flip)); d <- d[!is.na(d$flip), ]
RULES <- c("oat", "box", "ball", "frac"); SUMS <- c(oat = "oat_value", minnorm_inf = "minnorm_inf", minnorm_2 = "minnorm_2", frac = "frac_value")
auroc <- function(s, y) { if (!any(y) || all(y)) return(NA)
  r <- rank(c(s[y], s[!y])); (sum(r[seq_len(sum(y))]) - sum(y) * (sum(y) + 1) / 2) / (sum(y) * sum(!y)) }
sc <- function(z) vapply(SUMS, function(k) auroc(-z[[k]], z$flip), 0)     # smaller summary = more at risk

## Verdict rates by cell, binomial MCSE.
rate <- function(x) c(mean(x), sqrt(mean(x) * (1 - mean(x)) / length(x)))
vr <- do.call(rbind, lapply(split(d, d$cell), function(z) do.call(rbind, lapply(RULES, function(r) {
  a <- rate(z[[r]][z$flip]); b <- rate(!z[[r]][!z$flip])
  data.frame(cell = z$cell[1], rule = r, flip_rate = mean(z$flip), false_reassurance = a[1], fr_mcse = a[2], false_fragility = b[1], ff_mcse = b[2]) }))))
vr <- merge(g, vr, by = "cell"); write.csv(vr, "results/summary.csv", row.names = FALSE)

## Primary: AUROC pooled over the three-mechanism cells, by world; bootstrap within cells.
set.seed(MASTER_SEED + 1)
au <- do.call(rbind, lapply(c("calibrated", "overconfident"), function(w) { z <- d[d$p == 3 & d$world == w, ]; a <- sc(z)
  idx <- split(seq_len(nrow(z)), z$cell)
  b <- t(replicate(200, sc(z[unlist(lapply(idx, function(k) k[sample.int(length(k), replace = TRUE)])), ])))
  best <- names(which.max(a[-1])) ; gp <- a[[best]] - a[["oat"]]
  data.frame(world = w, summary = names(SUMS), auroc = a, se = apply(b, 2, stats::sd),
             minus_oat = a - a[["oat"]], minus_oat_se = apply(b - b[, "oat"], 2, stats::sd)) }))
write.csv(au, "results/auroc.csv", row.names = FALSE)
gap <- vapply(c("calibrated", "overconfident"), function(w) { z <- au[au$world == w & au$summary != "oat", ]; max(z$minus_oat) }, 0)
bestn <- vapply(c("calibrated", "overconfident"), function(w) { z <- au[au$world == w & au$summary != "oat", ]; z$summary[which.max(z$minus_oat)] }, "")
verdict <- if (all(gap <= 0.02)) "HOLDS: the one-at-a-time cross ranks decision flips as well as any joint summary" else
  if (all(gap >= 0.05)) sprintf("FAILS: a joint summary (%s) beats the cross in both worlds", paste(unique(bestn), collapse = ", ")) else
  if (gap[["calibrated"]] >= 0.05) "CONDITIONAL ON CALIBRATION: a joint summary beats the cross only when the elicitation is calibrated" else
  if (gap[["overconfident"]] >= 0.05) "CONDITIONAL ON OVERCONFIDENCE: a joint summary beats the cross only when the true bias exceeds the elicited box" else
  "INTERMEDIATE: gains below the registered 0.05"
## Metric dependence: Euclidean against L-infinity min-norm.
z3 <- d[d$p == 3, ]
mdep <- c(auroc_gap = max(abs(au$auroc[au$summary == "minnorm_2"] - au$auroc[au$summary == "minnorm_inf"])), disagree = mean(z3$ball != z3$box))
## Exact identity: under the calibrated world gamma* lies in the box, so the box verdict
## can never be falsely reassuring (DIA-14's identity). The ball is a strict subset of
## the box, so its false reassurance there is reported with the metric dependence.
cal <- vr[vr$world == "calibrated", ]
idn <- max(cal$false_reassurance[cal$rule == "box"], na.rm = TRUE)
ballfr <- max(cal$false_reassurance[cal$rule == "ball"], na.rm = TRUE)
## Positive control: the cross-versus-region gap is reachable in decision terms.
gapx <- mean(z3$oat & !z3$box)
## Order dependence of sequential single-bias correction, exact, on a coarse grid.
corr <- function(th, G) { dd <- stats::uniroot(function(x) L_lim(x, G) - th, c(-6, 6), tol = 1e-10)$root
  stats::qlogis(risk(MX_T, P_T, G[1, 1], dd)) - stats::qlogis(risk(MX_T, P_T, G[1, 1], 0)) }
perm <- list(1:3, c(1, 3, 2), c(2, 1, 3), c(2, 3, 1), c(3, 1, 2), c(3, 2, 1))
OG <- as.matrix(expand.grid(g_u = seq(-1, 1, 0.5), m = c(0, 0.1, 0.2), q = c(0, 0.2, 0.4)))
od <- do.call(rbind, lapply(c(-0.3, -0.1, 0.1, 0.3), function(th) do.call(rbind, lapply(seq_len(nrow(OG)), function(i) { gm <- OG[i, ]
  sq <- vapply(perm, function(pp) { v <- th; for (j in pp) { e <- rbind(c(0, 0, 0)); e[1, j] <- gm[j]; v <- corr(v, e) }; v }, 0)
  data.frame(theta = th, spread = max(sq) - min(sq), dec_split = length(unique(sign(sq))) > 1, vs_joint = max(abs(sq - corr(th, rbind(gm))))) }))))
f3 <- function(x) sprintf("%.3f", x)
md <- c("# Decision", "", sprintf("**Registered primary (three mechanisms): %s.**", verdict), "",
  sprintf("Best joint summary minus the one-at-a-time cross, AUROC for a decision flip: calibrated world %s (%s), overconfident world %s (%s); registered: holds if at most 0.02 in both, fails if at least 0.05 in both.",
          f3(gap[["calibrated"]]), bestn[["calibrated"]], f3(gap[["overconfident"]]), bestn[["overconfident"]]), "",
  sprintf("Metric dependence: largest |AUROC Euclidean - L-infinity min-norm| %s; ball and box verdicts disagree on %s of three-mechanism analyses (registered: metric-dependent if at least 0.02 or at least 0.10).",
          f3(mdep[["auroc_gap"]]), f3(mdep[["disagree"]])), "",
  sprintf("Identity check: largest false reassurance of the box rule under the calibrated world %s (must be 0). Ball rule, same cells: %s.", f3(idn), f3(ballfr)), "",
  sprintf("Positive control (three mechanisms: cross robust while the box is fragile in at least 0.02 of analyses): %s (%s).", gapx >= 0.02, f3(gapx)), "",
  sprintf("Order dependence (exact, %d bias vectors x 4 estimates): largest spread over six orders %s; decision differs between orders in %s of them; largest |sequential - joint| %s.",
          nrow(OG), f3(max(od$spread)), f3(mean(od$dec_split)), f3(max(od$vs_joint))), "",
  sprintf("Replicates lost: %d.", lost), "",
  "| world | summary | AUROC (SE) | minus cross (SE) |", "|---|---|---:|---:|",
  sprintf("| %s | %s | %.3f (%.3f) | %.3f (%.3f) |", au$world, au$summary, au$auroc, au$se, au$minus_oat, au$minus_oat_se), "",
  "| mechanisms | dependence | world | d | rule | flip rate | false reassurance (MCSE) | false fragility (MCSE) |", "|---:|---|---|---:|---|---:|---:|---:|",
  sprintf("| %d | %s | %s | %.1f | %s | %.3f | %.3f (%.3f) | %.3f (%.3f) |", vr$p, vr$dependence, vr$world, vr$d, vr$rule, vr$flip_rate,
          vr$false_reassurance, vr$fr_mcse, vr$false_fragility, vr$ff_mcse), "")
writeLines(md, "results/decision.md"); cat(md[1:13], sep = "\n")
