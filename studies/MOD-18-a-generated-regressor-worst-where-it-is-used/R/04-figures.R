## Figure: widening ratio by risk percentile and cohort size.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
p <- ggplot(s, aes(factor(percentile), widening, colour = factor(n_p), shape = factor(drift))) + geom_hline(yintercept = 1, colour = "grey60") +
  geom_point(size = 2, position = position_dodge(0.4)) + labs(x = "Risk percentile", y = "Propagated SE / plug-in SE", colour = "Prognostic cohort size", shape = "Calibration drift") +
  theme_bw(base_size = 9) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-widening.png", p, width = 6, height = 3.8, dpi = 200)
