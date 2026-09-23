## Figure: flag rates of the unadjusted and adjusted splits by gap and true inconsistency.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv"); s <- s[s$beta > 0, ]
l <- rbind(data.frame(s[, c("gap", "beta", "iota", "M")], split = "unadjusted", rate = s$flag_unadj),
           data.frame(s[, c("gap", "beta", "iota", "M")], split = "adjusted", rate = s$flag_adj))
l$panel <- sprintf("true inconsistency %+.1f", l$iota)
p <- ggplot(l, aes(gap, rate, colour = split, linetype = factor(beta), shape = factor(M))) + geom_hline(yintercept = 0.05, linetype = 2, colour = "grey50") +
  geom_line(aes(group = interaction(split, beta, M))) + geom_point(size = 1.4) + facet_wrap(~panel) +
  labs(x = "Covariate gap between direct and indirect study sets", y = "Proportion flagged", colour = "Node split", linetype = "Modification", shape = "Studies per comparison") +
  theme_bw(base_size = 8) + theme(legend.position = "bottom", legend.box = "vertical")
ggsave("manuscript/figures/fig1-flags.png", p, width = 7.5, height = 4.2, dpi = 200)
