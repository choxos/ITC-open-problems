## Figure: flip rate by analysis choice, threshold distance and target mean.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/flips.csv"); s <- s[s$law == "normal", ]
s$choice <- factor(s$choice, c("adjust", "family", "form", "moments"), c("unadjusted vs linear STC", "MAIC means vs linear STC", "linear vs quadratic STC", "MAIC means vs means and SDs"))
s$dist <- factor(ifelse(abs(s$d) == 0.1, "threshold 0.1 from the truth", "threshold 0.3 from the truth"))
p <- ggplot(s, aes(choice, flip, colour = factor(m))) + geom_jitter(width = 0.15, height = 0, size = 1.3) + facet_wrap(~dist) +
  labs(x = NULL, y = "Share of analyses where the two options disagree", colour = "Target covariate mean") + theme_bw(base_size = 9) +
  theme(axis.text.x = element_text(angle = 25, hjust = 1), legend.position = "bottom")
ggsave("manuscript/figures/fig1-flips.png", p, width = 7.5, height = 4.2, dpi = 200)
