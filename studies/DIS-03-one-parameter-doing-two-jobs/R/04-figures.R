## Figure: bias of the bridge with and without design adjustment.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv"); s <- s[s$K == 10, ]
l <- rbind(data.frame(s[, c("eta", "overlap", "drift")], method = "exchangeable baselines", bias = s$bias_exch),
           data.frame(s[, c("eta", "overlap", "drift")], method = "adjusted for the design covariate", bias = s$bias_adj))
l$panel <- sprintf("overlap %.2f, prognostic drift %.1f", l$overlap, l$drift)
p <- ggplot(l[is.finite(l$bias), ], aes(eta, bias, colour = method)) + geom_abline(linetype = 3, colour = "grey60") + geom_hline(yintercept = 0, colour = "grey70") +
  geom_line() + geom_point(size = 1.6) + facet_wrap(~panel) +
  labs(x = "Design nuisance on the baseline (log odds)", y = "Bias of the cross-gap contrast", colour = NULL) + theme_bw(base_size = 9) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-bias.png", p, width = 7, height = 5, dpi = 200)
