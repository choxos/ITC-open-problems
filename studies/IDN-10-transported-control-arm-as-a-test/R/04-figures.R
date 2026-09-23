## Figure: the check's alarm rate against the contrast's bias, one point per cell.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
s$lab <- paste0("u ", s$mu_u, ", v ", s$mu_v)
p <- ggplot(s, aes(bias, alarm, colour = factor(mu_u), shape = factor(mu_v))) +
  geom_hline(yintercept = 0.05, linetype = 2, colour = "grey50") + geom_vline(xintercept = 0, colour = "grey80") +
  geom_point(size = 2.4) + facet_wrap(~paste("target n =", n_t)) +
  labs(x = "Bias of the anchored log odds ratio", y = "Check alarm rate (|z| > 1.96)",
       colour = "Prognostic shift u", shape = "Modifier shift v") +
  theme_bw(base_size = 10) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-check.png", p, width = 7, height = 3.8, dpi = 200)
