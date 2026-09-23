suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
l <- rbind(data.frame(s[, c("direction", "risk", "fail")], diagnostic = "EESS", value = s$med_eess),
           data.frame(s[, c("direction", "risk", "fail")], diagnostic = "ESS x p-hat", value = s$med_essp),
           data.frame(s[, c("direction", "risk", "fail")], diagnostic = "ESS", value = s$med_ess))
p <- ggplot(l, aes(value, fail, colour = direction)) + geom_point(size = 1.3) + scale_x_log10() + facet_wrap(~diagnostic, scales = "free_x") +
  labs(x = "Cell median of the diagnostic (log)", y = "Failure rate (no estimate or non-coverage)", colour = "Weights concentrate") +
  theme_bw(base_size = 10) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-diagnostics.png", p, width = 7.5, height = 3.8, dpi = 200)
