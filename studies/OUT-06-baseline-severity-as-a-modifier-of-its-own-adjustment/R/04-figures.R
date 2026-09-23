## Figure: mean endpoint-minus-change difference by method, design and shift.
suppressPackageStartupMessages(library(ggplot2))
d <- read.csv("results/differences.csv")
d$label <- paste0("beta = ", d$beta, ", b = ", d$b)
p <- ggplot(d, aes(shift, diff, colour = method, shape = label)) +
  geom_abline(slope = 1, intercept = 0, linetype = 3, colour = "grey50") +
  geom_hline(yintercept = 0, colour = "grey70") +
  geom_point(position = position_dodge(width = 0.12), size = 1.8) +
  facet_wrap(~design) +
  labs(x = "Target baseline shift (SD)", y = "Mean endpoint minus change estimate",
       colour = "Method", shape = NULL) +
  theme_bw(base_size = 10) + theme(legend.position = "bottom", legend.box = "vertical")
ggsave("manuscript/figures/fig1-difference.png", p, width = 7, height = 4.2, dpi = 200)
