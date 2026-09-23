## Figures: bias against its prediction, and the random-imbalance RMSE ratio.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
imp <- s[s$kappa != "random" & s$method %in% c("pooled", "separate"), ]
p1 <- ggplot(imp, aes(predicted, bias, colour = method, shape = corr)) +
  geom_abline(linetype = 2, colour = "grey50") +
  geom_errorbar(aes(ymin = bias - 1.96 * mcse, ymax = bias + 1.96 * mcse), width = 0) +
  geom_point(size = 1.8) +
  labs(x = "Predicted bias (section 2)", y = "Simulated bias", colour = "Matching", shape = "(rho_S, rho_T)") +
  theme_bw(base_size = 10) + theme(legend.position = "bottom", legend.box = "vertical")
ggsave("manuscript/figures/fig1-bias.png", p1, width = 6.5, height = 5, dpi = 200)
