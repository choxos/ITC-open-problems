suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
s$surface <- factor(s$surface, c("none", "A", "B", "C"), c("linear", "A: threshold prognostic", "B: hinge modification", "C: x1 x2 modification"))
s$method <- factor(s$method, c("stc", "gam_full", "gam_struct"), c("parametric STC", "GAM, smooth modification", "GAM, linear modification"))
p <- ggplot(s, aes(mu, bias, colour = method)) + geom_hline(yintercept = 0, linetype = 2) +
  geom_pointrange(aes(ymin = bias - 1.96 * mcse, ymax = bias + 1.96 * mcse), position = position_dodge(width = 0.15), size = 0.25) + facet_wrap(~ surface, nrow = 1) +
  scale_x_continuous(breaks = c(0.5, 1, 1.5)) + labs(x = "Target covariate mean (source mean 0)", y = "Bias of the target log odds ratio", colour = NULL) +
  theme_bw(base_size = 9) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-bias.png", p, width = 7.5, height = 3.2, dpi = 200)
