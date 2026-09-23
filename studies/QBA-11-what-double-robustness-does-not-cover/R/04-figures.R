## Figure: bias against omitted-variable strength for each (weighting, outcome) combination.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
lab <- c(maic_wrong = "MAIC, weights wrong", maic_right = "MAIC, weights right", or_wrong = "outcome model wrong",
         or_right = "outcome model right", dr_both_right = "DR, both right", dr_w_wrong = "DR, weights wrong",
         dr_o_wrong = "DR, outcome wrong", dr_both_wrong = "DR, both wrong")
s$method <- factor(lab[s$method], lab)
s$imbalance <- factor(sprintf("imbalance %.1f", s$imbalance)); s$mu1_t <- factor(sprintf("target mean of x1 %.1f", s$mu1_t))
p <- ggplot(s, aes(gamma, bias, colour = method)) + geom_abline(aes(intercept = 0, slope = as.numeric(sub("imbalance ", "", imbalance))), linetype = 2, colour = "grey50") +
  geom_line(position = position_dodge(0.04)) + geom_point(position = position_dodge(0.04), size = 1.2) + facet_grid(mu1_t ~ imbalance) +
  labs(x = expression("Omitted-variable strength " * gamma), y = "Bias", colour = NULL) + theme_bw(base_size = 9) + theme(legend.position = "right")
ggsave("manuscript/figures/fig1-bias.png", p, width = 8, height = 5, dpi = 200)
