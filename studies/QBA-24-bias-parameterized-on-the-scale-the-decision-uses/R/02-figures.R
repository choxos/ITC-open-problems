## Figure: change in RMST against the bias hazard ratio by baseline shape, with the linear prediction.
suppressPackageStartupMessages(library(ggplot2))
g <- read.csv("results/delta.csv"); g$panel <- sprintf("survival at 24 months %.1f", g$s_tau)
p <- ggplot(g, aes(hr, delta, colour = shape)) + geom_line() + geom_point(size = 1.4) + geom_line(aes(y = linear), linetype = 2) +
  facet_wrap(~panel, scales = "free_y") + labs(x = "Bias hazard ratio", y = "Change in RMST at 24 months (months)", colour = "Baseline hazard") +
  theme_bw(base_size = 9) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-delta.png", p, width = 7.5, height = 3.4, dpi = 200)
