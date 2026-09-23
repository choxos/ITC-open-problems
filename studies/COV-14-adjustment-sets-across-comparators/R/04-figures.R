## Figure: probability of a wrong top rank, intersection against maximal, per cell.
suppressPackageStartupMessages(library(ggplot2))
p <- read.csv("results/ranking.csv"); p <- p[p$pattern != "complete" & p$strength > 0, ]
p$pattern <- factor(p$pattern, c("fawsitt", "random", "adversarial"), c("Fawsitt-like", "random", "strongest covariate missing for the top comparator"))
g <- ggplot(p, aes(p_top_max, p_top_int, colour = pattern, shape = similarity)) +
  geom_abline(linetype = 2, colour = "grey50") + geom_point(size = 2) +
  coord_equal(xlim = c(0, 1), ylim = c(0, 1)) +
  labs(x = "P(wrong top rank), maximal sets", y = "P(wrong top rank), intersection set", colour = "Reporting pattern", shape = "Comparator populations") +
  theme_bw(base_size = 10) + theme(legend.position = "right")
ggsave("manuscript/figures/fig1-rank.png", g, width = 7.5, height = 4.6, dpi = 200)
