## All interaction locations x magnitudes x models. Writes results/regimens.csv and results/decision.md.
source("R/00-model.R")
LOC <- list(`A+B (co-administered)` = "A+B", `C+D (never co-administered)` = "C+D", `A+B and C+D` = c("A+B", "C+D"), `all six pairs` = PAIRS)
out <- do.call(rbind, lapply(names(LOC), function(l) do.call(rbind, lapply(c(0.1, 0.2, 0.3), function(m) {
  iota <- stats::setNames(rep(-m / if (length(LOC[[l]]) > 2) 2 else 1, length(LOC[[l]])), LOC[[l]])
  rbind(data.frame(location = l, magnitude = m, model = "additive", evaluate(iota)),
        data.frame(location = l, magnitude = m, model = "interactions for co-administered pairs", evaluate(iota, OBS_PAIRS))) }))))
write.csv(out, "results/regimens.csv", row.names = FALSE)
auroc <- function(s, y) { if (all(y) || !any(y)) return(NA); r <- rank(c(s[y], s[!y])); ny <- sum(y); (sum(r[seq_len(ny)]) - ny * (ny + 1) / 2) / (ny * sum(!y)) }
add <- out[out$model == "additive", ]; dn <- add[!add$administered, ]
fails <- any(dn$magnitude == 0.2 & dn$coverage < 0.90)
au <- auroc(dn$rho, dn$coverage < 0.90)
md <- c("# Decision", "", sprintf("**Registered primary: %s.** Additive fit, synergy 0.2: de novo regimens (never administered, reported estimable) with coverage below 0.90: %d of %d; lowest coverage %.3f.",
          if (fails) "CONFIRMED" else "REFUTED", sum(dn$magnitude == 0.2 & dn$coverage < 0.90), sum(dn$magnitude == 0.2), min(dn$coverage[dn$magnitude == 0.2])), "",
  sprintf("rho as a predictor of undercoverage among de novo regimens under the additive fit: AUROC %.2f.", au), "",
  sprintf("Leakage: with the interaction only on A+B, administered regimen B+C and de novo B+D (no interaction of their own) biased by %.3f and %.3f at synergy 0.2.",
          add$bias[add$location == "A+B (co-administered)" & add$magnitude == 0.2 & add$regimen == "B+C"], add$bias[add$location == "A+B (co-administered)" & add$magnitude == 0.2 & add$regimen == "B+D"]), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
