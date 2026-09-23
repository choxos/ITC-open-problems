## Figure: bias by detection sensitivity, visiting and method.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
s$method <- factor(s$method, c("naive", "midpoint", "interval"), c("recorded times as exact", "interval midpoint", "interval-censored Weibull"))
s$panel <- sprintf("%s visiting, true difference %.1f months", s$visiting, s$truth)
p <- ggplot(s, aes(se_b, bias, colour = method)) + geom_hline(yintercept = 0, colour = "grey60") + geom_line() + geom_point(size = 1.5) +
  scale_x_reverse(breaks = c(1, 0.85, 0.7)) + facet_wrap(~panel) +
  labs(x = "Per-visit detection sensitivity in the external arm", y = "Bias of the RMST(24) difference (months)", colour = NULL) +
  theme_bw(base_size = 9) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-bias.png", p, width = 7.5, height = 5, dpi = 200)
