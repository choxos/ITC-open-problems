suppressPackageStartupMessages(library(ggplot2))
r <- read.csv("results/reversal.csv"); r <- r[r$beta > 0 & r$sep > 0 & r$sets == "common", ]
p <- ggplot(r, aes(factor(sep), p_reversal, colour = position, shape = sizes)) + geom_point(size = 2, position = position_dodge(0.4)) +
  facet_wrap(~paste("beta =", beta)) + labs(x = "Separation of the two populations (SD)", y = "P(the two sponsors' estimates have opposite signs)", colour = "Zero-effect point", shape = "Trial sizes") +
  theme_bw(base_size = 10) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-reversal.png", p, width = 7.5, height = 3.8, dpi = 200)
