suppressPackageStartupMessages(library(ggplot2))
e <- read.csv("results/errors.csv"); g <- e[e$recon == "gauss" & e$truth_family != "gauss" & e$link %in% c("logit", "cloglog"), ]
g$cell <- sprintf("%s margins, r %.1f, gamma %.2f", g$margin, g$r, g$gamma)
g$link <- factor(g$link, c("logit", "cloglog"), c("logit (log odds ratio)", "complementary log-log (log cumulative hazard ratio)"))
g$truth_family <- factor(g$truth_family, c("clayton", "gumbel", "t3"), c("Clayton (lower tail)", "Gumbel (upper tail)", "t, 3 df (both tails)"))
p <- ggplot(g, aes(error, cell, colour = truth_family)) + geom_vline(xintercept = c(-0.02, 0.02), linetype = 3) + geom_vline(xintercept = 0) +
  geom_point(size = 1.8) + facet_wrap(~ link) + labs(x = "Error of the calibrated Gaussian reconstruction", y = NULL, colour = "True copula") +
  theme_bw(base_size = 9) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-errors.png", p, width = 7, height = 3.8, dpi = 200)
