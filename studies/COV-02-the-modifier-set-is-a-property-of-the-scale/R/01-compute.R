## Compute the scale-specific sets for every scenario; summary and decision.
source("R/00-model.R")
g <- build_grid()
res <- do.call(rbind, lapply(seq_len(nrow(g)), function(i) cbind(g[i, ], sets(g[i, ]))))
write.csv(res, "results/sets.csv", row.names = FALSE)
w <- reshape(res[, c("scen", "m", "k", "g", "mu", "scale", "n_prog_in")], idvar = c("scen", "m", "k", "g", "mu"), timevar = "scale", direction = "wide")
nested <- mean(w$n_prog_in.lor >= w$n_prog_in.rd)
differ <- mean(w$n_prog_in.lor != w$n_prog_in.rd | w$n_prog_in.lor != w$n_prog_in.clor | w$n_prog_in.rd != w$n_prog_in.clor)
md <- c("# Decision", "",
  sprintf("**Refuting sentence (the sets coincide on every scale a decision would use): %s.** Prognostic non-modifiers that matter (omission changes the contrast by more than %.0f%%) differ between scales in %.0f%% of scenarios.",
          if (differ >= 0.5) "FAILS" else "HOLDS", 100 * THRESH, 100 * differ), "",
  sprintf("DESIGN.md's nesting prediction (the marginal odds ratio set contains the risk difference set): holds in %.0f%% of scenarios.", 100 * nested), "",
  "| modifiers | prognostic non-modifiers | prognostic strength | imbalance | scale | contrast | modifiers that matter | prognostic that matter | largest relative change from one prognostic variable |",
  "|---:|---:|---:|---:|---|---:|---:|---:|---:|",
  sprintf("| %d | %d | %.1f | %.1f | %s | %.3f | %d | %d | %.3f |", res$m, res$k, res$g, res$mu, res$scale, res$contrast, res$n_mod_in, res$n_prog_in, res$max_rel_prog), "")
writeLines(md, "results/decision.md"); cat(md[1:5], sep = "\n")
