suppressPackageStartupMessages(library(ggplot2))
a <- readRDS("results/analysis.rds"); g <- a$gap
g$scale <- factor(g$scale, c("logOR", "riskdiff"), c("log odds ratio", "risk difference"))
g$sign <- factor(g$gamma_sign, c("positive", "mixed"), c("all positive", "mixed"))
p <- ggplot(g, aes(indep_gap, indep_minus_oracle, colour = modification, shape = sign)) +
  geom_hline(yintercept = 0, linetype = 2) +
  geom_point(size = 1.2, alpha = 0.8) + facet_wrap(~ scale, scales = "free_y") +
  labs(x = "Covariance term dropped by independence (sum over i != j of gamma_i gamma_j Sigma_ij)",
       y = "Independence minus true joint law", colour = "modification", shape = "sign pattern") +
  theme_bw(base_size = 8) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-gap.png", p, width = 7, height = 3.4, dpi = 200)
