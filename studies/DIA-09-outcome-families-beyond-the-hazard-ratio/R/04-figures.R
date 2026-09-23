## Figure: bias of A's cumulative incidence and of the difference by competing-hazard ratio.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv"); s <- s[s$estimand != "hr", ]
s$method <- factor(sub("_A$", "", s$method), c("maic", "stc", "stc_recal"), c("MAIC", "cause-specific STC", "STC, competing hazard recalibrated"))
s$estimand <- factor(s$estimand, c("A", "diff"), c("cumulative incidence under A", "difference, A minus C"))
s$panel <- sprintf("modification %.1f, target mean %.1f", s$b, s$m_t)
p <- ggplot(s, aes(k_t, bias, colour = method)) + geom_hline(yintercept = 0, colour = "grey60") + geom_line() + geom_point(size = 1.4) +
  scale_x_continuous(trans = "log2", breaks = c(0.5, 1, 2, 4)) + facet_grid(estimand ~ panel) +
  labs(x = "Target competing hazard relative to the source (not explained by the covariate)", y = "Bias at 2 years", colour = NULL) +
  theme_bw(base_size = 8) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-bias.png", p, width = 8, height = 4.4, dpi = 200)
