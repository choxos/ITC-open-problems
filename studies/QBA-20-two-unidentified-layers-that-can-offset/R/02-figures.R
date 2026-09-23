suppressPackageStartupMessages(library(ggplot2))
source("R/00-model.R"); s <- read.csv("results/summary.csv"); g <- read.csv("results/grid.csv")
z <- g[g$scale == 1 & abs(g$b - 1) < 1e-9, ]; z$mu_u <- z$a * RANGE[["mu_u"]]; z$d_i <- z$c * RANGE[["d_i"]]
e1 <- s$one_lo[s$scale == 1]
p <- ggplot(z, aes(mu_u, d_i, fill = bias)) + geom_raster(interpolate = TRUE) +
  geom_contour(aes(z = bias), breaks = ANALYST, colour = "black", linewidth = 0.6) +
  geom_contour(aes(z = bias), breaks = e1, colour = "black", linetype = 2, linewidth = 0.4) +
  scale_fill_gradient2(low = "#b2182b", mid = "white", high = "#2166ac", midpoint = 0) +
  labs(x = expression("Omitted-modifier mean in the target, " * mu[u]), y = expression("Component-by-modifier drift, " * d[i]), fill = "Bias") +
  theme_bw(base_size = 10)
ggsave("manuscript/figures/fig1-joint.png", p, width = 5.5, height = 4.2, dpi = 200)
