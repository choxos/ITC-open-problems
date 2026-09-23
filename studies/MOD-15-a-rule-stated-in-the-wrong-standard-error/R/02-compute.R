## The registered computation: exact operating characteristics of each pooling
## policy over the grid. Writes results/summary.csv.
source("R/00-model.R")
g <- build_grid()
pol <- c("never_pool", "always_pool", names(rules))
res <- do.call(rbind, lapply(seq_len(nrow(g)), function(i) {
  cc <- g[i, ]; s <- ses(cc$K, cc$disp, cc$n)
  do.call(rbind, lapply(pol, function(p) {
    o <- if (p %in% names(rules)) oc(s[["sW"]], s[["sA"]], s[["sd_d"]], cc$delta, rules[[p]])
         else oc(s[["sW"]], s[["sA"]], s[["sd_d"]], cc$delta, NULL, policy = p)
    data.frame(cell = cc$cell, K = cc$K, disp = cc$disp, delta = cc$delta, sW = s[["sW"]], sA = s[["sA"]],
               ratio = s[["sW"]] / s[["sA"]], policy = p, t(o))
  }))
}))
write.csv(res, "results/summary.csv", row.names = FALSE)
cat("written results/summary.csv:", nrow(res), "rows\n")
