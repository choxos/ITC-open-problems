## Figure: coverage by selection rule and sample size.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
lab <- c(all = "all six interactions", oracle = "true modifiers (oracle)", none = "no interactions", significance = "p < 0.2, naive interval",
         significance_boot = "p < 0.2, whole-procedure bootstrap", lasso = "lasso (lambda 1se)")
s$rule <- factor(lab[s$rule], lab); s$panel <- sprintf("%d true modifier%s", s$n_mod, ifelse(s$n_mod > 1, "s", ""))
p <- ggplot(s, aes(n, coverage, colour = rule)) + geom_hline(yintercept = 0.95, linetype = 2, colour = "grey50") + geom_line() + geom_point(size = 1.5) +
  scale_x_log10(breaks = c(100, 300, 1000)) + facet_wrap(~panel) + labs(x = "Patients per arm", y = "Coverage of the 95% interval", colour = NULL) +
  theme_bw(base_size = 9) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-coverage.png", p, width = 7.5, height = 4, dpi = 200)
