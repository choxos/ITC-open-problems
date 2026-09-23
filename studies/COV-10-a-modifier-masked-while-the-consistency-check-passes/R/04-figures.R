## Figure: flag rates of the interaction and effect consistency checks.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv"); s <- s[s$loop == 0, ]
l <- rbind(data.frame(s[, c("scen", "sdx", "M")], check = "interaction consistency", rate = s$int_cons),
           data.frame(s[, c("scen", "sdx", "M")], check = "effect consistency", rate = s$eff_cons))
l$scen <- factor(l$scen, c("consistent", "partial", "cancelling"), c("consistent interactions", "partly opposing", "cancelling"))
p <- ggplot(l, aes(M, rate, colour = check)) + geom_hline(yintercept = 0.10, linetype = 2, colour = "grey50") + geom_line() + geom_point(size = 1.4) +
  facet_grid(sprintf("covariate SD %.1f", sdx) ~ scen) + scale_x_continuous(breaks = c(2, 4, 8)) +
  labs(x = "Studies per comparison", y = "Proportion flagged", colour = NULL) + theme_bw(base_size = 9) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-checks.png", p, width = 7.5, height = 4.4, dpi = 200)
