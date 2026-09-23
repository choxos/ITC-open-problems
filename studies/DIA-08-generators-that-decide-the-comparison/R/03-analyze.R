## Performance by method and cell; rank correlation of RMSE orderings; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
d$e <- d$est - d$truth
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) {
  cv <- mean(abs(z$e) <= 1.96 * z$se)
  data.frame(cell = z$cell[1], method = z$method[1], n = nrow(z), bias = mean(z$e), mcse = stats::sd(z$e) / sqrt(nrow(z)),
             rmse = sqrt(mean(z$e^2)), coverage = cv) }))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
ms <- sort(unique(d$method))
rmse_vec <- function(z) sapply(ms, function(m) sqrt(mean(z$e[z$method == m]^2)))
## Paired bootstrap over replicates for the rank correlation between two cells.
rho <- function(c1, c2, B = 200) {
  z1 <- d[d$cell == c1, ]; z2 <- d[d$cell == c2, ]
  r0 <- stats::cor(rmse_vec(z1), rmse_vec(z2), method = "spearman")
  set.seed(c1 * 100 + c2); reps <- intersect(unique(z1$rep), unique(z2$rep))
  bs <- replicate(B, { k <- sample(reps, replace = TRUE)
    stats::cor(rmse_vec(z1[z1$rep %in% k, ]), rmse_vec(z2[z2$rep %in% k, ]), method = "spearman") })
  c(rho = r0, se = stats::sd(bs), p_below_09 = mean(bs < 0.9)) }
pairs <- do.call(rbind, lapply(c(0.3, 0.8, 1.2), function(m) {
  ref <- g$cell[g$departure == "linear" & g$law == "normal" & g$m == m]
  alt <- g[(g$departure != "linear" & g$departure != "none" & g$law == "normal" | g$law == "skewed") & g$m == m, ]
  do.call(rbind, lapply(seq_len(nrow(alt)), function(i) data.frame(m = m, against = paste(alt$departure[i], alt$law[i]), t(rho(ref, alt$cell[i]))))) }))
write.csv(pairs, "results/rank-correlation.csv", row.names = FALSE)
ord <- do.call(rbind, lapply(split(summ, summ$cell), function(z) data.frame(cell = z$cell[1], departure = z$departure[1], m = z$m[1], law = z$law[1],
  order = paste(z$method[order(z$rmse)], collapse = " < "))))
dep <- pairs[!grepl("skewed", pairs$against), ]; poor <- dep[dep$m == 1.2, ]
verdict <- if (all(dep$rho >= 0.9)) "REFUTED (orderings survive every departure)" else
  if (any(poor$rho <= 0.5)) "CONFIRMED (the generator decides the ordering)" else "PARTIAL (some reordering, no reversal)"
md <- c("# Decision", "", sprintf("**Registered rule: %s.**", verdict), "",
  "| target mean | ordering under linear against | Spearman rho | bootstrap SE | P(rho < 0.9) |", "|---:|---|---:|---:|---:|",
  sprintf("| %.1f | %s | %.2f | %.2f | %.2f |", pairs$m, pairs$against, pairs$rho, pairs$se, pairs$p_below_09), "",
  "| departure | target mean | law | RMSE order, best first |", "|---|---:|---|---|",
  sprintf("| %s | %.1f | %s | %s |", ord$departure, ord$m, ord$law, ord$order), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
