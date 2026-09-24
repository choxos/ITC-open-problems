suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv"); cp <- read.csv("results/corrected-point.csv")
s <- s[s$ctrl == "none" & s$method %in% c("part_km", "tada", "tada_miss"), c("cell", "cens", "mu_t", "kappa", "method", "bias", "mcse")]
cp <- cp[cp$ctrl == "none", ]
s <- rbind(s, data.frame(cell = cp$cell, cens = cp$cens, mu_t = cp$mu_t, kappa = cp$kappa, method = "tada_corrected", bias = cp$bias_tada, mcse = cp$mcse_tada))
s$method <- factor(s$method, c("part_km", "tada_miss", "tada", "tada_corrected"),
  c("participation-weighted KM", "TADA, censoring model without x1", "TADA as registered", "TADA, censoring model on [0, 24) (post hoc)"))
s$panel <- sprintf("%s censored, %s overlap", paste0(100 * s$cens, "%"), ifelse(s$mu_t > 1, "poor", "good"))
s$corr <- ifelse(s$kappa > 0, "positive", "negative")
p <- ggplot(s, aes(corr, bias, colour = method)) + geom_hline(yintercept = 0, linetype = 2) +
  geom_pointrange(aes(ymin = bias - 1.96 * mcse, ymax = bias + 1.96 * mcse), position = position_dodge(width = 0.6), size = 0.2) +
  facet_wrap(~ panel, nrow = 1) + labs(x = "Correlation of participation and censoring weights", y = "Bias of target RMST difference (months)", colour = NULL) +
  theme_bw(base_size = 8) + theme(legend.position = "bottom") + guides(colour = guide_legend(nrow = 2))
ggsave("manuscript/figures/fig1-bias.png", p, width = 7.5, height = 3.4, dpi = 200)
