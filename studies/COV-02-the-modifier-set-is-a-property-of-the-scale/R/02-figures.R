## Figure: largest relative change in the target contrast from leaving one prognostic
## non-modifier unbalanced, by scale and scenario.
suppressPackageStartupMessages(library(ggplot2))
r <- read.csv("results/sets.csv")
r$scale <- factor(r$scale, c("rd", "lrr", "lor", "clor"), c("risk difference", "log risk ratio", "marginal log odds ratio", "conditional log odds ratio"))
r$panel <- sprintf("imbalance %.1f, prognostic strength %.1f", r$mu, r$g)
r <- r[r$scale != "conditional log odds ratio", ]
p <- ggplot(r, aes(factor(m), max_rel_prog, colour = scale, shape = factor(k))) + geom_hline(yintercept = 0.05, linetype = 2, colour = "grey40") +
  geom_point(size = 1.8, position = position_dodge(0.5)) + facet_wrap(~panel) + scale_y_log10() +
  labs(x = "Conditional modifiers", y = "Largest relative change from one prognostic variable (log scale)", colour = NULL, shape = "Prognostic non-modifiers") +
  theme_bw(base_size = 8) + theme(legend.position = "bottom", legend.box = "vertical")
ggsave("manuscript/figures/fig1-change.png", p, width = 7.5, height = 5, dpi = 200)
