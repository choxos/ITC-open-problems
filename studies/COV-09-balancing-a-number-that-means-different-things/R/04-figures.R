## Figure: naive bias against the closed form; corrected bias by instrument pair.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
s$scen <- factor(s$scen, c("same", "same_shifted", "target_offset", "target_slope", "target_both"),
                 c("same", "same, shifted", "target offset", "target slope", "target offset and slope"))
d <- s[s$method %in% c("naive", "reliability_corrected") & s$beta > 0, ]
d$method <- factor(d$method, c("naive", "reliability_corrected"), c("naive MAIC", "reliability-corrected MAIC"))
p <- ggplot(d, aes(predicted, bias, colour = scen, shape = factor(rel))) +
  geom_abline(linetype = 2, colour = "grey50") + geom_hline(yintercept = 0, colour = "grey80") +
  geom_point(size = 1.8) + facet_wrap(~method) +
  labs(x = "Closed-form bias of naive MAIC", y = "Simulated bias", colour = "Instruments", shape = "Source reliability") +
  theme_bw(base_size = 10) + theme(legend.position = "bottom", legend.box = "vertical")
ggsave("manuscript/figures/fig1-bias.png", p, width = 7, height = 4.6, dpi = 200)
