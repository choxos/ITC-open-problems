## Figure: coverage of the true residual bias by each benchmark rule.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
l <- do.call(rbind, lapply(c(plain = "plain", sqrt_q = "times sqrt(q)", oracle = "times sqrt(q(1 + (q - 1) rho))", linear = "times q"), function(k) NULL))
rules <- c(plain = "plain", sqrt_q = "times sqrt(q)", oracle = "oracle correlation-adjusted", linear = "times q")
l <- do.call(rbind, lapply(names(rules), function(k) data.frame(s[, c("q", "rho", "s")], rule = rules[[k]], coverage = s[[k]])))
l$rule <- factor(l$rule, rules); l$strength <- factor(sprintf("each omitted variable %.1f x the strongest measured", l$s))
p <- ggplot(l, aes(q, coverage, colour = rule, shape = factor(rho))) + geom_line(aes(group = interaction(rule, rho)), alpha = 0.5) + geom_point(size = 1.6) +
  facet_wrap(~strength) + scale_x_continuous(breaks = c(1, 3, 6)) +
  labs(x = "Number of omitted variables", y = "Share of analyses whose benchmark covers the true bias", colour = NULL, shape = "Correlation") +
  theme_bw(base_size = 8) + theme(legend.position = "bottom", legend.box = "vertical")
ggsave("manuscript/figures/fig1-coverage.png", p, width = 8, height = 3.9, dpi = 200)
