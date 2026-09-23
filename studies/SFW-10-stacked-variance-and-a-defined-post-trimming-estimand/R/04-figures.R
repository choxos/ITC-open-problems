suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv"); u <- s[s$trim == "none", ]
l <- do.call(rbind, lapply(c("se_fixed", "se_ess", "se_stack", "se_stack_hc1"), function(m)
  data.frame(u[, c("shift", "prev", "em", "align", "ess")], estimator = m, coverage = u[[paste0("cov_", m)]])))
l$estimator <- factor(l$estimator, c("se_fixed", "se_ess", "se_stack", "se_stack_hc1"), c("fixed-weight sandwich", "ESS-based", "stacked", "stacked, n/(n-k)"))
p <- ggplot(l, aes(ess, coverage, colour = estimator)) + geom_hline(yintercept = c(0.93, 0.95, 0.97), linetype = c(3, 2, 3)[c(1, 2, 3)]) +
  geom_point(size = 1.4, alpha = 0.8) + scale_x_log10() + labs(x = "Mean ESS (log scale)", y = "Coverage", colour = NULL) +
  theme_bw(base_size = 10) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-coverage.png", p, width = 6.5, height = 4, dpi = 200)
