suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/regimens.csv"); s <- s[s$magnitude == 0.2, ]
s$reg <- factor(paste0(s$regimen, ifelse(s$administered, " (administered)", "")), levels = rev(unique(paste0(s$regimen, ifelse(s$administered, " (administered)", "")))))
s$location <- factor(s$location, unique(s$location))
p <- ggplot(s, aes(location, reg, fill = coverage)) + geom_tile(colour = "white") + geom_text(aes(label = sprintf("%.2f", coverage)), size = 2.4) +
  facet_wrap(~ model) + scale_fill_gradient(low = "#b2182b", high = "white", limits = c(0, 0.95)) +
  labs(x = "Where the synergy (0.2) is", y = NULL, fill = "Coverage") + theme_bw(base_size = 9) + theme(axis.text.x = element_text(angle = 25, hjust = 1))
ggsave("manuscript/figures/fig1-coverage.png", p, width = 7, height = 4.2, dpi = 200)
