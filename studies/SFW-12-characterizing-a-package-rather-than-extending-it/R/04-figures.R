suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
s$method <- factor(s$method, c("default", "rho_target", "rho_zero", "gamma", "gamma_target"), c("default (normal, IPD correlation)", "normal, target correlation", "normal, independence", "gamma, IPD correlation", "gamma, target correlation"))
s$panel <- sprintf("target copula %s, IPD correlation %.1f", s$target_copula, s$source_rho)
p <- ggplot(s, aes(bias, method)) + geom_vline(xintercept = 0, linetype = 2) + geom_pointrange(aes(xmin = bias - 1.96 * mcse, xmax = bias + 1.96 * mcse), size = 0.25) +
  facet_wrap(~ panel) + labs(x = "Bias of the anchored log odds ratio (95% Monte Carlo interval)", y = NULL) + theme_bw(base_size = 9)
ggsave("manuscript/figures/fig1-bias.png", p, width = 7, height = 4.2, dpi = 200)
