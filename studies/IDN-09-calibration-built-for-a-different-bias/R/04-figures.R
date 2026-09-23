## Figure: bias of naive and calibrated contrasts with a population shift, by control strength.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv"); s <- s[s$shift > 0, ]
l <- rbind(data.frame(s[, c("g_n", "beta")], method = "naive MAIC", bias = s$bias_naive), data.frame(s[, c("g_n", "beta")], method = "calibrated by the negative control", bias = s$bias_cal))
l$beta <- factor(l$beta, c(0, 0.5), c("no modification by V", "V modifies A's effect (0.5)"))
p <- ggplot(l, aes(g_n, bias, colour = method)) + geom_hline(yintercept = 0, colour = "grey60") + geom_vline(xintercept = 0.5, linetype = 3, colour = "grey50") +
  geom_line() + geom_point(size = 1.6) + facet_wrap(~beta) +
  labs(x = "Prognostic effect of V on the negative-control outcome (primary: 0.5)", y = "Bias of the primary log odds ratio", colour = NULL) +
  theme_bw(base_size = 9) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-bias.png", p, width = 7, height = 3.6, dpi = 200)
