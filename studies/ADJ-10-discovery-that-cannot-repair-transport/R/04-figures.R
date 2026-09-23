suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
s$analysis <- paste(s$method, ifelse(s$penalty == "min", "minimum CV", "one SE"), sep = ", ")
s$conf_lab <- ifelse(s$conf > 0, "study-level confounding", "no confounding")
s$mod <- paste(s$M, ifelse(s$M == 1, "true modifier", "true modifiers"))
p <- ggplot(s, aes(K, x10, colour = analysis, linetype = conf_lab)) + geom_line() + geom_point(size = 1.3) +
  facet_wrap(~ mod) + scale_x_continuous(breaks = c(3, 6, 12)) +
  labs(x = "Number of trials (2400 patients in total)", y = "Share of analyses selecting x10", colour = NULL, linetype = NULL) +
  theme_bw(base_size = 10) + theme(legend.position = "bottom", legend.box = "vertical")
ggsave("manuscript/figures/fig1-x10.png", p, width = 6.5, height = 4.2, dpi = 200)
