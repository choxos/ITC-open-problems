## Figure: bias and coverage by selection rule across DIA-08's scenarios.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
lab <- c(prespecified_stc = "prespecified linear STC", prespecified_maic = "prespecified MAIC on means", min_se = "smallest SE", most_favorable = "most favorable estimate", averaged = "equal-weight average")
s$rule <- factor(lab[s$rule], lab)
l <- rbind(data.frame(rule = s$rule, m = s$m, metric = "bias", value = s$bias), data.frame(rule = s$rule, m = s$m, metric = "coverage", value = s$coverage))
p <- ggplot(l, aes(rule, value, colour = factor(m))) + geom_jitter(width = 0.15, height = 0, size = 1.5) + facet_wrap(~metric, scales = "free_y") +
  labs(x = NULL, y = NULL, colour = "Target covariate mean") + theme_bw(base_size = 9) + theme(axis.text.x = element_text(angle = 25, hjust = 1), legend.position = "bottom")
ggsave("manuscript/figures/fig1-rules.png", p, width = 7.5, height = 4, dpi = 200)
