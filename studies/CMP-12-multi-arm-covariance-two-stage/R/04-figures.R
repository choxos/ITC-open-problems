## Figure: coverage by method for the network d_AB and the trial-alone d_BC.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
a <- s[s$contrast == "AB" & s$method %in% c("split", "fixed", "stacked", "drop"), ]; a$panel <- "network d_AB"
b <- s[s$contrast == "BC" & s$method %in% c("split_trial", "fixed_trial", "stacked_trial"), ]; b$panel <- "trial-alone d_BC"
b$method <- sub("_trial", "", b$method)
x <- rbind(a, b); x$method <- factor(x$method, c("split", "fixed", "stacked", "drop"))
p <- ggplot(x, aes(method, coverage, colour = factor(em))) + geom_hline(yintercept = 0.95, linetype = 2) +
  geom_jitter(width = 0.15, height = 0, size = 1.4) + facet_wrap(~panel) +
  labs(x = NULL, y = "Coverage of the nominal 95% interval", colour = "|modification|") +
  theme_bw(base_size = 10) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-coverage.png", p, width = 7, height = 3.8, dpi = 200)
