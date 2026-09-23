## Figure: false reassurance against false fragility by method and elicitation.
suppressPackageStartupMessages(library(ggplot2))
f <- read.csv("results/frontier.csv")
f$elic <- ifelse(f$dir == "zero", "region centered at zero bias", sprintf("%s error, exclusion %.1f", f$dir, f$q))
l <- rbind(data.frame(f[, c("dir", "q", "width", "elic")], method = "deterministic grid", FR = f$fr_grid, FF = f$ff_grid),
           data.frame(f[, c("dir", "q", "width", "elic")], method = "probabilistic QBA", FR = f$fr_prob, FF = f$ff_prob))
l$dir <- factor(l$dir, c("symmetric", "understated", "zero"), c("symmetric elicitation error", "error toward zero bias", "region centered at zero"))
p <- ggplot(l, aes(FF, FR, colour = method, shape = factor(width))) + geom_point(size = 2) + facet_wrap(~dir) +
  labs(x = "False fragility, P(fragile | true bias does not flip the decision)", y = "False reassurance, P(robust | it does)",
       colour = NULL, shape = "Region half-width") + theme_bw(base_size = 9) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-frontier.png", p, width = 8, height = 3.8, dpi = 200)
