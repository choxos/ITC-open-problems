suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv"); s <- s[s$tau_s == 0, ]
s$set <- paste0(ifelse(s$shift > 0, "poor overlap", "good overlap"), ", ", ifelse(s$index == "all", "index with all covariates", "index without x1"))
l <- rbind(data.frame(s[, c("mult", "set")], measure = "P(network connected)", value = s$connected),
           data.frame(s[, c("mult", "set")], measure = "bias of A vs B (truth -0.2)", value = s$bias),
           data.frame(s[, c("mult", "set")], measure = "coverage of 95% interval", value = s$coverage))
l$measure <- factor(l$measure, unique(l$measure))
p <- ggplot(l, aes(mult, value, colour = set)) + geom_line() + geom_point(size = 1.2) + facet_wrap(~ measure, scales = "free_y") +
  scale_x_log10(breaks = c(1, 2, 3, 5, 10, 20)) + labs(x = "Admission threshold (multiples of the within-trial arm distance)", y = NULL, colour = NULL) +
  theme_bw(base_size = 10) + theme(legend.position = "bottom") + guides(colour = guide_legend(nrow = 2))
ggsave("manuscript/figures/fig1-threshold.png", p, width = 7, height = 3.6, dpi = 200)
