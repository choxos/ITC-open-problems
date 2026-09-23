## Figure: coverage by method and number of aggregate trials.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
lab <- c(naive_dl = "per-trial contrasts, DerSimonian-Laird", naive_hk = "per-trial contrasts, Hartung-Knapp", twostep_dl = "two-step, DerSimonian-Laird", twostep_hk = "two-step, Hartung-Knapp")
s$method <- factor(lab[s$method], lab)
p <- ggplot(s, aes(K, coverage, colour = method)) + annotate("rect", xmin = -Inf, xmax = Inf, ymin = 0.93, ymax = 0.97, alpha = 0.12) +
  geom_line() + geom_point(size = 1.4) + facet_wrap(~sprintf("heterogeneity SD %.1f", tau)) + scale_x_continuous(breaks = c(2, 3, 4, 6, 8, 12)) +
  labs(x = "Aggregate trials", y = "Coverage of the 95% interval", colour = NULL) + theme_bw(base_size = 9) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-coverage.png", p, width = 8, height = 3.8, dpi = 200)
