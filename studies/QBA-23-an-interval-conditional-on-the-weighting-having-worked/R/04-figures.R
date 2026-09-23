## Figure: resample failure share and interval coverage along the assumed target mean.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
l <- rbind(data.frame(s[, c("n", "m")], quantity = "resamples failed", value = s$resample_failure),
           data.frame(s[, c("n", "m")], quantity = "coverage given the original fit succeeded", value = s$coverage_given_success),
           data.frame(s[, c("n", "m")], quantity = "coverage counting failed fits as no interval", value = s$coverage_unconditional))
p <- ggplot(l, aes(m, value, colour = quantity)) + geom_hline(yintercept = 0.95, linetype = 2, colour = "grey50") + geom_line() + geom_point(size = 1.5) +
  facet_wrap(~sprintf("%d patients", n)) + labs(x = "Assumed target mean of x (source SD 1)", y = NULL, colour = NULL) + theme_bw(base_size = 9) + theme(legend.position = "bottom", legend.direction = "vertical")
ggsave("manuscript/figures/fig1-failure.png", p, width = 7, height = 4.2, dpi = 200)
