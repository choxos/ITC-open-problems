suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv"); s <- s[s$beta == 0.8, ]
s$method <- factor(s$method, c("normal", "lognormal", "sample_exact"), c("normal (Wan et al.)", "quantile-matched lognormal", "target's own sample"))
p <- ggplot(s, aes(skew, bias, colour = method, linetype = factor(n_t))) + geom_hline(yintercept = 0, colour = "grey60") +
  geom_line() + geom_point(size = 1) + facet_grid(link ~ summary, scales = "free_y") +
  labs(x = "Skewness (log-SD of the lognormal)", y = "Bias in the target contrast", colour = NULL, linetype = "target n") +
  theme_bw(base_size = 10) + theme(legend.position = "bottom", legend.box = "vertical")
ggsave("manuscript/figures/fig1-bias.png", p, width = 7, height = 5, dpi = 200)
