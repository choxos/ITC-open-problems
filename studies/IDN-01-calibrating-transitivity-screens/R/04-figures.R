## Figure: detection by any screen against the absolute bias of the network estimate.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
s$mech <- factor(s$mech, c("none", "measured_em", "unmeasured_em", "loop_break", "drift"),
                 c("no violation", "measured modifier (adjusted)", "unmeasured, loop-consistent", "loop break", "study drift"))
p <- ggplot(s, aes(abs(bias), any, colour = mech, shape = factor(M))) +
  geom_hline(yintercept = mean(s$any[s$mech == "no violation"]), linetype = 2, colour = "grey50") + geom_point(size = 2.2) +
  labs(x = "Absolute bias of the B versus C network estimate", y = "Proportion flagged by at least one screen", colour = NULL, shape = "Studies per comparison") +
  theme_bw(base_size = 9) + theme(legend.position = "right")
ggsave("manuscript/figures/fig1-detection.png", p, width = 7.5, height = 4, dpi = 200)
