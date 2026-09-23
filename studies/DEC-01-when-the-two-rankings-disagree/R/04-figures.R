## Figure: wrong-decision probability against RMSE in poor-overlap cells, near threshold.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/scored.csv"); s <- s[s$c == 1 & abs(s$d) == 0.1 & s$shift == 0.6 & s$ratio == 0.5, ]
av <- aggregate(cbind(wrong, rmse) ~ cell + method, data = s, FUN = mean); av$side <- "averaged over both sides"
s$side <- ifelse(s$d < 0, "threshold 0.1 below the truth", "threshold 0.1 above the truth")
l <- rbind(s[, c("cell", "method", "wrong", "rmse", "side")], av[, c("cell", "method", "wrong", "rmse", "side")])
l$side <- factor(l$side, c("threshold 0.1 below the truth", "threshold 0.1 above the truth", "averaged over both sides"))
lab <- c(unadjusted = "unadjusted", maic_means = "MAIC means", maic_meanvar = "MAIC means and variances", maic_index = "MAIC index variance", gcomp = "G-computation")
l$method <- factor(lab[l$method], lab)
p <- ggplot(l, aes(rmse, wrong, colour = method)) + geom_point(size = 1.6) + facet_wrap(~side) +
  labs(x = "RMSE of the log odds ratio", y = "Wrong-decision probability", colour = NULL) + theme_bw(base_size = 9) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-decision.png", p, width = 8, height = 3.6, dpi = 200)
