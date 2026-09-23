suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
l <- do.call(rbind, lapply(c("aic", "bic", "lrt"), function(c0) data.frame(s[, c("m", "ratio")], criterion = toupper(c0), sep = s[[paste0(c0, "_sep")]])))
l$criterion[l$criterion == "LRT"] <- "likelihood-ratio test"
p <- ggplot(l, aes(m, sep, colour = factor(ratio))) + geom_line() + geom_point() + facet_wrap(~ criterion) + scale_x_log10(breaks = c(2, 3, 5, 8, 12, 20, 40)) +
  labs(x = "Studies per class", y = "Share choosing separate variances", colour = "True variance ratio") + theme_bw(base_size = 10) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-selection.png", p, width = 7, height = 3.6, dpi = 200)
