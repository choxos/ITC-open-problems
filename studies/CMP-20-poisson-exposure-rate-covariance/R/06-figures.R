suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv"); m <- s[s$arm == "main" & s$method != "sensitivity", ]
m$method <- factor(m$method, c("unweighted", "weighted", "borrowed"), c("unweighted moments", "exposure-weighted moments", "borrowed exposure slope"))
m$n_lab <- paste(m$n_arm, "per arm")
p1 <- ggplot(m, aes(predicted, bias, colour = method)) + geom_abline(linetype = 2) + geom_point(size = 1, alpha = 0.7) +
  labs(x = "Predicted bias from the identity", y = "Observed bias (log rate ratio)", colour = NULL) + theme_bw(base_size = 10) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-identity.png", p1, width = 5.5, height = 4.2, dpi = 200)
p2 <- ggplot(m, aes(predicted, coverage, colour = method)) + geom_hline(yintercept = 0.95, linetype = 2) + geom_hline(yintercept = 0.9, linetype = 3) + geom_point(size = 1, alpha = 0.7) +
  facet_wrap(~ n_lab) + labs(x = "Predicted bias from the identity", y = "Coverage of 95% interval", colour = NULL) + theme_bw(base_size = 10) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig2-coverage.png", p2, width = 6.5, height = 3.8, dpi = 200)
