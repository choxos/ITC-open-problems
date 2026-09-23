## Figure: coverage of the correct and naive analyses by the number of single-arm studies.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
l <- rbind(data.frame(s[, c("M", "n_c")], analysis = "shared arm modeled", coverage = s$cov_right), data.frame(s[, c("M", "n_c")], analysis = "entered as independent", coverage = s$cov_naive))
p <- ggplot(l, aes(M, coverage, colour = analysis, linetype = factor(n_c))) + geom_hline(yintercept = 0.95, linetype = 2, colour = "grey50") +
  geom_line() + geom_point(size = 1.6) + scale_x_continuous(breaks = c(1, 2, 4, 8)) +
  labs(x = "Single-arm studies matched to the same comparator arm", y = "Coverage of A versus C", colour = NULL, linetype = "Comparator arm size") +
  theme_bw(base_size = 9) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-coverage.png", p, width = 6, height = 3.8, dpi = 200)
