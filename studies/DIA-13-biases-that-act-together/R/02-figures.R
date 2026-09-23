## Figure: joint bias against the sum of the single-mechanism biases.
suppressPackageStartupMessages(library(ggplot2))
g <- read.csv("results/surface.csv"); g <- g[(g$gu != 0) + (g$m != 0) + (g$r != 1) >= 2, ]
g$active <- ifelse(g$gu != 0 & g$m != 0 & g$r != 1, "all three", ifelse(g$gu == 0, "misclassification + measurement error",
                   ifelse(g$m == 0, "confounder + measurement error", "confounder + misclassification")))
p <- ggplot(g, aes(sum_marg, b, colour = active)) + geom_abline(linetype = 2, colour = "grey50") + geom_hline(yintercept = 0, colour = "grey85") +
  geom_vline(xintercept = 0, colour = "grey85") + geom_point(size = 2) +
  labs(x = "Sum of the single-mechanism biases", y = "Joint bias (log odds ratio)", colour = "Mechanisms acting") +
  theme_bw(base_size = 9) + theme(legend.position = "right")
ggsave("manuscript/figures/fig1-joint.png", p, width = 7, height = 4, dpi = 200)
