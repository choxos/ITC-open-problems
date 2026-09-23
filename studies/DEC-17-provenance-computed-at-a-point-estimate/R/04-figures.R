suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv"); s <- s[s$spread == "5:1", ]
l <- rbind(data.frame(s[, c("net", "K", "tau")], what = "leading study changes", value = s$lead_study_changes),
           data.frame(s[s$net == "loop", c("net", "K", "tau")], what = "leading comparison changes (loop)", value = s$lead_cmp_changes[s$net == "loop"]))
l$grp <- paste(l$net, l$what)
p <- ggplot(l, aes(K, value, colour = factor(tau), linetype = what)) + geom_line() + geom_point() + facet_wrap(~ net) + scale_x_continuous(breaks = c(4, 8, 16)) +
  labs(x = "Studies in the network (5:1 within-study variance spread)", y = "Share of networks", colour = "True tau", linetype = NULL) + theme_bw(base_size = 10) + theme(legend.position = "bottom", legend.box = "vertical")
ggsave("manuscript/figures/fig1-leading.png", p, width = 6.5, height = 4, dpi = 200)
