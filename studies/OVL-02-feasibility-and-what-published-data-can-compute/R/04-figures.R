suppressPackageStartupMessages(library(ggplot2))
sh <- read.csv("results/shifts.csv")
d <- do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS))
d$status <- ifelse(d$feasible == 1, "feasible", "infeasible")
d$dimlab <- paste("dimension", ifelse(d$cell %in% seq(1, 24, 2), 3, 8))
p <- ggplot(d, aes(ess, resid, colour = status)) + geom_point(size = 0.5, alpha = 0.3) +
  scale_x_log10() + scale_y_log10() + geom_hline(yintercept = 1e-3, linetype = 2) + geom_vline(xintercept = 40, linetype = 3) +
  labs(x = "ESS of the returned weights (log)", y = "Residual imbalance (log)", colour = NULL) +
  theme_bw(base_size = 10) + theme(legend.position = "bottom") + guides(colour = guide_legend(override.aes = list(size = 2, alpha = 1)))
ggsave("manuscript/figures/fig1-detectors.png", p, width = 6, height = 4.2, dpi = 200)
