## Coverage and width of the bridged contrast by heterogeneity model; decision.
source("R/00-model.R")
g <- build_grid(); truth <- sum(THETA)
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) { e <- z$est - truth; cv <- mean(abs(e) <= z$crit * z$se)
  data.frame(cell = z$cell[1], method = z$method[1], n = nrow(z), bias = mean(e), coverage = cv, cov_mcse = sqrt(cv * (1 - cv) / nrow(z)),
             width = mean(2 * z$crit * z$se), se_ratio = mean(z$se) / stats::sd(z$est), tau_shared = mean(z$tau_shared), tau1 = mean(z$tau1), tau2 = mean(z$tau2)) }))
summ <- merge(g, summ, by = "cell"); write.csv(summ, "results/summary.csv", row.names = FALSE)
pr <- summ[summ$het == "other" & summ$ratio > 1, ]
sh <- pr[pr$method == "shared", ]; sk <- pr[pr$method == "shrunk", ]
verdict <- if (any(sh$coverage < 0.90 & sk$coverage >= 0.93)) "CONFIRMED" else if (all(summ$coverage[summ$method == "shared"] >= 0.93)) "SHARED TAU DEFENSIBLE" else "MIXED"
st <- summ[summ$method == "stratified", ]
f3 <- function(x) sprintf("%.3f", x)
md <- c("# Decision", "", sprintf("**Registered primary: %s.** Shared-tau coverage where the non-bridging subnetwork is the heterogeneous one: %s; shrunk stratified: %s.",
          verdict, paste(f3(sh$coverage), collapse = ", "), paste(f3(sk$coverage), collapse = ", ")), "",
  sprintf("Stratified (unshrunk) coverage by studies per subnetwork: 3: %s; 6: %s; 12: %s.", paste(f3(range(st$coverage[st$K == 3])), collapse = " to "),
          paste(f3(range(st$coverage[st$K == 6])), collapse = " to "), paste(f3(range(st$coverage[st$K == 12])), collapse = " to ")), "",
  "| tau ratio | heterogeneous subnetwork | studies each | method | coverage | width | SE ratio | mean tau estimates (shared; 1; 2) |", "|---:|---|---:|---|---:|---:|---:|---|",
  sprintf("| %g | %s | %d | %s | %.3f | %.3f | %.2f | %.3f; %.3f; %.3f |", summ$ratio, summ$het, summ$K, summ$method, summ$coverage, summ$width, summ$se_ratio, summ$tau_shared, summ$tau1, summ$tau2), "")
writeLines(md, "results/decision.md"); cat(md[1:5], sep = "\n")
