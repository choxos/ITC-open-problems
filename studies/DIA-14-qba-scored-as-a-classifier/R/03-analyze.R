## Classification rates by elicitation and method; exact checks; decision.
source("R/00-model.R")
g <- build_grid(); g$bstar <- sapply(seq_len(nrow(g)), function(i) bstar(g[i, ]))
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
d$q[is.na(d$q)] <- -1                                   # zero-anchored region: q not set
rates <- function(z) data.frame(n = nrow(z), excluded = mean(!z$covers), flip = mean(z$flip),
  fr_grid = mean(z$grid[z$flip]), ff_grid = mean(!z$grid[!z$flip]),
  fr_prob = mean(z$prob[z$flip]), ff_prob = mean(!z$prob[!z$flip]),
  fr_none = 1, ff_none = 0, qba_mc_disagree = mean(z$prob != z$prob_mc))
by_cell <- do.call(rbind, lapply(split(d, list(d$cell, d$dir, d$q, d$width), drop = TRUE), function(z)
  cbind(z[1, c("cell", "gu", "p_t", "delta", "bstar", "dir", "q", "width")], rates(z))))
write.csv(by_cell, "results/by-cell.csv", row.names = FALSE)
b <- d[d$bstar != 0, ]
pooled <- do.call(rbind, lapply(split(b, list(b$dir, b$q, b$width), drop = TRUE), function(z) cbind(z[1, c("dir", "q", "width")], rates(z))))
pooled <- pooled[order(pooled$dir, pooled$q, pooled$width), ]
write.csv(pooled, "results/frontier.csv", row.names = FALSE)
oc <- aggregate(oracle_cover ~ cell, data = d[d$dir == "symmetric" & d$q == 0 & d$width == 0.05, ], FUN = mean)
write.csv(merge(g, oc), "results/oracle.csv", row.names = FALSE)

chk_incl <- sum(d$grid & d$flip & d$covers); chk_q0 <- sum(d$grid & d$flip & d$q == 0)
prim <- pooled[pooled$q == 0.1 & pooled$width == 0.15, ]
dom <- any(pooled$fr_prob <= pooled$fr_grid & pooled$ff_prob <= pooled$ff_grid & (pooled$fr_prob < pooled$fr_grid | pooled$ff_prob < pooled$ff_grid))
z0 <- pooled[pooled$dir == "zero", ]
refute_fails <- all(oc$oracle_cover >= 0.93 & oc$oracle_cover <= 0.97) && any(z0$fr_grid > 0.2)
md <- c("# Decision", "",
  sprintf("Exact checks: grid false reassurance with the truth inside the region, %d replicates (must be 0); at q = 0, %d (must be 0).", chk_incl, chk_q0), "",
  sprintf("**Primary (q = 0.1, width 0.15, cells with bias):** P(robust | decision flips at true bias), grid %s; probabilistic %s. P(fragile | no flip), grid %s; probabilistic %s (directions %s).",
          paste(sprintf("%.3f", prim$fr_grid), collapse = "/"), paste(sprintf("%.3f", prim$fr_prob), collapse = "/"),
          paste(sprintf("%.3f", prim$ff_grid), collapse = "/"), paste(sprintf("%.3f", prim$ff_prob), collapse = "/"), paste(prim$dir, collapse = "/")), "",
  sprintf("Probabilistic QBA dominates the grid on both rates in some setting: %s.", dom), "",
  sprintf("**Refuting sentence (oracle recovery plus a width rule is adequate): %s.** Oracle coverage %.3f to %.3f; grid false reassurance under a zero-anchored region %s by width %s.",
          if (refute_fails) "FAILS" else "HOLDS", min(oc$oracle_cover), max(oc$oracle_cover),
          paste(sprintf("%.3f", z0$fr_grid), collapse = ", "), paste(z0$width, collapse = ", ")), "",
  "| direction | q | width | excluded | flip | FR grid | FF grid | FR prob | FF prob | QBA MC disagreement |",
  "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  sprintf("| %s | %s | %.2f | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f |", pooled$dir, ifelse(pooled$q < 0, "-", sprintf("%.1f", pooled$q)), pooled$width,
          pooled$excluded, pooled$flip, pooled$fr_grid, pooled$ff_grid, pooled$fr_prob, pooled$ff_prob, pooled$qba_mc_disagree), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
