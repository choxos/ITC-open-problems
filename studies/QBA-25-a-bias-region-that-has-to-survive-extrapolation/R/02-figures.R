suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/surface.csv"); s$family <- factor(s$family, c("ph", "waning", "cure"), c("hazard ratio persists", "effect wanes by year 8", "cure model"))
p <- ggplot(s, aes(b, inb / 1000, colour = family)) + geom_hline(yintercept = 0, linetype = 2) + geom_line(linewidth = 0.8) +
  labs(x = "Bias in the reported log hazard ratio, b (reported = true + b)", y = "Incremental net benefit at the reported estimate (thousands)", colour = "Extrapolation") +
  theme_bw(base_size = 10) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-surface.png", p, width = 6, height = 4, dpi = 200)
