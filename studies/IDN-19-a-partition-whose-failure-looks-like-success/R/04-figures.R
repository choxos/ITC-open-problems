suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
s$scen <- sprintf("C differs from B by %.1f; D differs from B by %.2f", s$sep, s$het)
s$partition <- factor(s$partition, c("BCD", "BD_C", "B_CD"), c("{BCD}", "{BD}{C}", "{B}{CD}"))
p <- ggplot(s, aes(bias, scen, colour = partition)) + geom_vline(xintercept = 0, linetype = 2) +
  geom_errorbarh(aes(xmin = bias - 1.96 * se, xmax = bias + 1.96 * se), height = 0, position = position_dodge(width = 0.6), alpha = 0.5) +
  geom_point(position = position_dodge(width = 0.6), size = 1.6) +
  labs(x = "Bias of the D-versus-A target contrast (bar: plus or minus 1.96 SE)", y = NULL, colour = "Partition") + theme_bw(base_size = 9) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-partitions.png", p, width = 7, height = 3.8, dpi = 200)
