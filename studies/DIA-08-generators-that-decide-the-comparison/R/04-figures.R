## Figure: RMSE and bias by method under each departure and overlap.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv"); s <- s[s$law == "normal" & s$departure != "none", ]
lab <- c(unadjusted = "unadjusted", maic_means = "MAIC means", maic_means_sds = "MAIC means and SDs", stc_linear = "STC linear", stc_flexible = "STC quadratic")
s$method <- factor(lab[s$method], lab); s$departure <- factor(s$departure, c("linear", "threshold", "interaction", "quadratic"))
l <- rbind(data.frame(s[, c("departure", "m", "method")], metric = "RMSE", value = s$rmse), data.frame(s[, c("departure", "m", "method")], metric = "bias", value = s$bias))
p <- ggplot(l, aes(departure, value, colour = method, group = method)) + geom_hline(yintercept = 0, colour = "grey80") + geom_line() + geom_point(size = 1.3) +
  facet_grid(metric ~ sprintf("target mean %.1f", m), scales = "free_y") + labs(x = "Effect-modification structure", y = NULL, colour = NULL) +
  theme_bw(base_size = 8) + theme(legend.position = "bottom", axis.text.x = element_text(angle = 30, hjust = 1))
ggsave("manuscript/figures/fig1-rmse.png", p, width = 8, height = 4.6, dpi = 200)
