suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
s$method <- factor(s$method, c("two_stage_marg", "two_stage_cond", "transported"), c("two-stage, marginal IPD edges", "two-stage, conditional IPD edges", "all edges transported"))
p <- ggplot(s, aes(pred_b1, bias, colour = method, shape = scale)) + geom_abline(linetype = 2) + geom_hline(yintercept = 0, colour = "grey60") + geom_point(size = 1.8, alpha = 0.8) +
  labs(x = expression("Predicted " * b[1] * " (aggregate edges' precision share x population difference)"), y = "Observed bias", colour = NULL, shape = NULL) +
  theme_bw(base_size = 10) + theme(legend.position = "bottom", legend.box = "vertical")
ggsave("manuscript/figures/fig1-b1.png", p, width = 6, height = 4.6, dpi = 200)
