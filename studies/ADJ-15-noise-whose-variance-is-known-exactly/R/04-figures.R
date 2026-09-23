## Figure: coverage against the noise share of the propagated variance.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv"); s <- s[is.finite(s$eps), ]
w <- reshape(s[s$method != "non_private", c("cell", "n_t", "eps", "release", "em", "method", "width", "coverage")],
             idvar = c("cell", "n_t", "eps", "release", "em"), timevar = "method", direction = "wide")
w$noise_share <- 1 - (w$width.private_ignored / w$width.private_propagated)^2
l <- rbind(data.frame(w[, c("n_t", "release", "noise_share")], method = "noise ignored", coverage = w$coverage.private_ignored),
           data.frame(w[, c("n_t", "release", "noise_share")], method = "noise propagated", coverage = w$coverage.private_propagated))
l$release <- factor(l$release, c("means", "means_sds"), c("means released", "means and second moments released"))
p <- ggplot(l, aes(noise_share, coverage, colour = method, shape = factor(n_t))) +
  geom_hline(yintercept = 0.95, linetype = 2, colour = "grey50") + geom_point(size = 1.8) +
  facet_wrap(~release) + labs(x = "Share of the propagated variance due to privacy noise", y = "Coverage of the 95% interval",
                              colour = NULL, shape = "target n") +
  theme_bw(base_size = 10) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-coverage.png", p, width = 7, height = 3.8, dpi = 200)
