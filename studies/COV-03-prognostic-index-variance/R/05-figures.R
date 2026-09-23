## Figure: bias and RMSE by method in the primary cells.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
p <- s[s$design == "anchored" & s$em == "none" & s$ratio %in% c(0.5, 2) & s$var_T %in% c(1, 4), ]
p$scen <- sprintf("Var %g, shift %.1f", p$var_T, p$shift)
p$ratio <- factor(p$ratio, c(0.5, 2), c("source index variance half the target's", "source index variance twice the target's"))
p$method <- factor(p$method, c("unadjusted", "maic_means", "maic_meanvar", "maic_index", "gcomp"),
                   c("unadjusted", "MAIC means", "MAIC means and variances", "MAIC index variance", "G-computation"))
l <- rbind(data.frame(p[, c("scen", "ratio", "method")], metric = "bias", value = p$bias, lo = p$bias - 1.96 * p$mcse, hi = p$bias + 1.96 * p$mcse),
           data.frame(p[, c("scen", "ratio", "method")], metric = "RMSE", value = p$rmse, lo = NA, hi = NA))
g <- ggplot(l, aes(scen, value, colour = method)) + geom_hline(yintercept = 0, colour = "grey70") +
  geom_errorbar(aes(ymin = lo, ymax = hi), width = 0, position = position_dodge(0.6), na.rm = TRUE) +
  geom_point(position = position_dodge(0.6), size = 1.4) + facet_grid(metric ~ ratio, scales = "free_y") +
  labs(x = NULL, y = NULL, colour = NULL) + theme_bw(base_size = 9) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "bottom")
ggsave("manuscript/figures/fig1-primary.png", g, width = 8, height = 5, dpi = 200)
