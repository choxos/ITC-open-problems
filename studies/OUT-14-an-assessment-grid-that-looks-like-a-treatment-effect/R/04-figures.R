## Figure: bias of each method against the predicted naive bias.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
s$method <- factor(s$method, c("naive", "midpoint", "interval"), c("recorded times as exact", "midpoint", "interval-censored Weibull"))
p <- ggplot(s, aes(predicted, bias, colour = method)) +
  geom_abline(linetype = 2, colour = "grey50") + geom_hline(yintercept = 0, colour = "grey80") +
  geom_errorbar(aes(ymin = bias - 1.96 * mcse, ymax = bias + 1.96 * mcse), width = 0) + geom_point(size = 1.6) +
  labs(x = expression("Predicted naive bias, " * (d[B]/2)*F[B](tau) - (d[A]/2)*F[A](tau) * " (months)"),
       y = "Bias of RMST(24) difference (months)", colour = NULL) +
  theme_bw(base_size = 10) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-bias.png", p, width = 6, height = 4.4, dpi = 200)
