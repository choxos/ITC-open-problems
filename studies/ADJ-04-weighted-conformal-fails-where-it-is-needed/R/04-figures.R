suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
s$method <- factor(s$method, c("unweighted", "weighted", "weighted_est"), c("split conformal", "weighted, true ratio", "weighted, estimated ratio"))
l <- rbind(data.frame(s[, c("mu", "method")], what = "coverage, all target patients", value = s$coverage),
           data.frame(s[, c("mu", "method")], what = "coverage beyond the source's range", value = s$coverage_tail),
           data.frame(s[, c("mu", "method")], what = "infinite intervals beyond the range", value = s$tail_infinite))
l$what <- factor(l$what, unique(l$what))
p <- ggplot(l, aes(factor(mu), value, colour = method, group = method)) + geom_hline(data = data.frame(what = unique(l$what)[1:2], y = 0.9), aes(yintercept = y), linetype = 2) +
  geom_point(position = position_dodge(width = 0.4)) + geom_line(position = position_dodge(width = 0.4), alpha = 0.5) + facet_wrap(~ what) +
  labs(x = "Target covariate mean (source mean 0)", y = NULL, colour = NULL) + theme_bw(base_size = 10) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-tail.png", p, width = 7, height = 3.4, dpi = 200)
