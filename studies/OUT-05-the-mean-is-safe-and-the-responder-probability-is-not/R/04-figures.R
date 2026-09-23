## Figure: responder-contrast bias by method, floor mass, skew and threshold (SD ratio 2).
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv"); s <- s[s$ratio == 2, ]
lab <- c(normal_pooled = "normal, pooled SD", normal_arm_sd = "normal, arm SDs", tobit = "Tobit, arm scales", logistic_responder = "logistic on the responder indicator")
s$method <- factor(lab[s$method], lab)
l <- rbind(data.frame(s[, c("method", "skew", "floor_mass", "m")], threshold = "threshold at the median", bias = s$bias_near),
           data.frame(s[, c("method", "skew", "floor_mass", "m")], threshold = "threshold at the 90th percentile", bias = s$bias_tail))
l$skew <- factor(ifelse(l$skew == "none", "normal errors", "skewed errors"))
p <- ggplot(l, aes(floor_mass, bias, colour = method, shape = factor(m))) + geom_hline(yintercept = 0, colour = "grey60") +
  geom_point(size = 1.6, position = position_dodge(0.03)) + facet_grid(threshold ~ skew) +
  labs(x = "Floor mass in the source control arm", y = "Bias of the responder-probability difference", colour = NULL, shape = "Target shift") +
  theme_bw(base_size = 8) + theme(legend.position = "bottom", legend.box = "vertical")
ggsave("manuscript/figures/fig1-responder.png", p, width = 7, height = 5, dpi = 200)
