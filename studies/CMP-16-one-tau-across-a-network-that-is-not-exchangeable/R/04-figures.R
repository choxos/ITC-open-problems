suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv"); s <- s[s$ratio == 5, ]
s$panel <- ifelse(s$het == "bridging", "bridging subnetwork heterogeneous (5:1)", "other subnetwork heterogeneous (5:1)")
p <- ggplot(s, aes(K, coverage, colour = method)) + geom_hline(yintercept = 0.95, linetype = 2) + geom_line() + geom_point() + facet_wrap(~ panel) +
  scale_x_continuous(breaks = c(3, 6, 12)) + labs(x = "Studies per subnetwork", y = "Coverage of the bridged contrast", colour = NULL) + theme_bw(base_size = 10) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-coverage.png", p, width = 6.5, height = 3.8, dpi = 200)
