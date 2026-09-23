suppressPackageStartupMessages(library(ggplot2))
source("R/00-model.R"); g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
d$panel <- sprintf("missingness 30%% and %.0f%%, integration route %s", 100 * d$miss2, ifelse(d$route_b, "on", "off"))
p <- ggplot(d, aes(slope)) + geom_histogram(bins = 40, fill = "grey60", colour = "white") + geom_vline(xintercept = 0, linetype = 2) + facet_wrap(~ panel) +
  labs(x = "Slope of the estimate against the MNAR shift (log odds ratio per unit shift)", y = "Replicates") + theme_bw(base_size = 9)
ggsave("manuscript/figures/fig1-slopes.png", p, width = 6.5, height = 4, dpi = 200)
cat(sprintf("share of replicates with positive slope: %s\n", paste(round(tapply(d$slope > 0, d$cell, mean), 3), collapse = ", ")))
cat(sprintf("slope SD: %s\n", paste(round(tapply(d$slope, d$cell, sd), 3), collapse = ", ")))
