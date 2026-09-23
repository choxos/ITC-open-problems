suppressPackageStartupMessages(library(ggplot2))
r <- read.csv("results/summary.csv"); r <- r[r$spread == 1 & r$S != 2, ]
r$panel <- sprintf("%d aggregate trial%s, ecological term %.1f", r$S, ifelse(r$S == 1, "", "s"), r$E)
p <- ggplot(r, aes(D, coverage, colour = model)) + geom_hline(yintercept = 0.95, linetype = 2) + geom_line() + geom_point() + facet_wrap(~ panel, nrow = 1) +
  labs(x = "Discordance between the two treatments' interactions", y = "Coverage of 95% credible interval", colour = NULL) + theme_bw(base_size = 9) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-coverage.png", p, width = 7.5, height = 3.2, dpi = 200)
