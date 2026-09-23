suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv"); s <- s[s$method == "pca", ]
s$dir <- ifelse(s$dir == "high", "modifier on a high-variance direction", "modifier on a low-variance direction")
p <- ggplot(s, aes(k, bias, colour = factor(shift), group = factor(shift))) + geom_hline(yintercept = 0, linetype = 2) + geom_line() + geom_point() +
  geom_text(aes(label = sprintf("%.0f%%", 100 * recon)), vjust = -0.8, size = 2.6, colour = "grey30", data = s[s$shift == 0.5, ]) +
  facet_wrap(~ dir) + scale_x_continuous(breaks = c(2, 5, 10)) +
  labs(x = "Principal components kept (labels: covariate variance reconstructed)", y = "Bias of the transported effect", colour = "Target shift (SD)") +
  theme_bw(base_size = 10) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-bias.png", p, width = 6.5, height = 3.6, dpi = 200)
