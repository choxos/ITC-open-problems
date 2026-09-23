suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
l <- rbind(data.frame(s[, c("n", "shift", "prev", "dim", "alloc")], plan = "nominal n", ratio = s$ratio_nominal),
           data.frame(s[, c("n", "shift", "prev", "dim", "alloc")], plan = "Kish ESS", ratio = s$ratio_kish),
           data.frame(s[, c("n", "shift", "prev", "dim", "alloc")], plan = "influence function", ratio = s$ratio_influence))
l$plan <- factor(l$plan, c("nominal n", "Kish ESS", "influence function"))
p <- ggplot(l, aes(factor(shift), ratio, colour = plan)) + geom_hline(yintercept = 1, linetype = 2) + geom_hline(yintercept = c(0.9, 1.1), linetype = 3) +
  geom_point(position = position_dodge(0.5), size = 1.1, alpha = 0.8) + facet_grid(prev ~ n, labeller = label_both) +
  labs(x = "Target shift (Mahalanobis)", y = "Planned SE / achieved SD", colour = NULL) +
  theme_bw(base_size = 10) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-plans.png", p, width = 7, height = 4.6, dpi = 200)
