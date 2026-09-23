suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
s$violation <- factor(s$violation, c("po", "bottom", "top"), c("none (proportional odds)", "at the bottom cut-point", "at the top cut-point"))
s$utility <- ifelse(s$utility == "bottom_heavy", "utility increments at the bottom", "utility increments at the top")
s$method <- ifelse(s$method == "po", "proportional odds", "separate cut-point models")
p <- ggplot(s, aes(bias, violation, colour = method)) + geom_vline(xintercept = 0, linetype = 2) +
  geom_pointrange(aes(xmin = bias - 1.96 * mcse, xmax = bias + 1.96 * mcse), position = position_dodge(width = 0.5), size = 0.3) + facet_wrap(~ utility) +
  labs(x = "Bias of the expected-utility difference", y = "Proportional-odds violation", colour = NULL) + theme_bw(base_size = 10) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-bias.png", p, width = 6.5, height = 3.4, dpi = 200)
