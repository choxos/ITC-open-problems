## Figure: rejection rate by violation size for each rule and configuration.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
l <- rbind(data.frame(s[, c("v", "tau", "s", "held")], rule = "full variance", rate = s$full),
           data.frame(s[, c("v", "tau", "s", "held")], rule = "naive variance", rate = s$naive),
           data.frame(s[, c("v", "tau", "s", "held")], rule = "reduced-network target", rate = s$wrong_target))
l$panel <- sprintf("%s trial withheld, spread %d, tau %.1f", ifelse(l$held == 3, "central", "peripheral"), l$s, l$tau)
p <- ggplot(l, aes(v, rate, colour = rule)) + geom_hline(yintercept = 0.05, linetype = 2, colour = "grey50") + geom_line() + geom_point(size = 1.2) +
  facet_wrap(~panel, ncol = 4) + labs(x = "Transport violation in the withheld trial", y = "Proportion flagged", colour = NULL) +
  theme_bw(base_size = 8) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-power.png", p, width = 8, height = 4.6, dpi = 200)
