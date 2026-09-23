## Figure: leave-one-out winner shares by bridge error.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
l <- do.call(rbind, lapply(c("common", "random", "metareg"), function(k) data.frame(s[, c("eta", "gz", "bridge_bias")], model = k, share = s[[k]])))
l$model <- factor(l$model, c("common", "random", "metareg"), c("common effect", "random effects", "meta-regression"))
l$lab <- sprintf("bias %.2f", l$bridge_bias)
p <- ggplot(l, aes(factor(eta), share, fill = model)) + geom_col(position = "stack") + facet_wrap(~sprintf("within-subnetwork covariate slope %.1f", gz)) +
  labs(x = "Design nuisance carried by the bridge (equals the cross-gap bias)", y = "Share of analyses won", fill = NULL) + theme_bw(base_size = 9) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-winners.png", p, width = 7, height = 3.6, dpi = 200)
