suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
s <- s[s$ctrl == "none" & s$method %in% c("variants", "draws"), ]
s$estimand <- factor(s$estimand, c("rmst24", "s12", "s48"), c("RMST to 24 months", "survival at 12 months", "Weibull survival at 48 months"))
s$method <- factor(s$method, c("variants", "draws"), c("analyst variants", "observation-model draws"))
s$design <- factor(sprintf("%s, %s, %s", s$res, ifelse(s$table == 0, "no table", paste0(s$table, "-month table")), s$cens))
p <- ggplot(s, aes(ratio_var, design, colour = method)) +
  annotate("rect", xmin = 0.67, xmax = 1.5, ymin = -Inf, ymax = Inf, alpha = 0.15) + geom_vline(xintercept = 1, linetype = 2) +
  geom_pointrange(aes(xmin = ratio_var / exp(1.96 * ratio_mcse / ratio_var), xmax = ratio_var * exp(1.96 * ratio_mcse / ratio_var)), size = 0.2) +
  scale_x_log10() + facet_wrap(~ estimand, nrow = 1) +
  labs(x = "Variance calibration ratio (log scale; 1 = calibrated, band 0.67 to 1.5)", y = NULL, colour = NULL) +
  theme_bw(base_size = 8) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-ratio.png", p, width = 7.5, height = 3.6, dpi = 200)
