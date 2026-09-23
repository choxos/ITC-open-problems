## Figure: bias of the RMST contrast by source and comparator censoring dependence.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
l <- rbind(data.frame(s[, c("design", "alpha_s", "alpha_t", "prev")], method = "Kaplan-Meier", bias = s$bias),
           data.frame(s[, c("design", "alpha_s", "alpha_t", "prev")], method = "source-side IPCW", bias = s$bias_ipcw))
l$src <- factor(sprintf("source dependence %d", l$alpha_s))
p <- ggplot(l, aes(alpha_t, bias, colour = src, linetype = method)) + geom_hline(yintercept = 0, colour = "grey60") + geom_line() + geom_point(size = 1.3) +
  facet_grid(sprintf("censoring %.0f%%", 100 * prev) ~ design) + scale_x_continuous(breaks = 0:2) +
  labs(x = "Comparator censoring dependence on latent risk", y = "Bias of the RMST difference at 24 months (months)", colour = NULL, linetype = NULL) +
  theme_bw(base_size = 9) + theme(legend.position = "bottom", legend.box = "vertical")
ggsave("manuscript/figures/fig1-bias.png", p, width = 7, height = 5, dpi = 200)
