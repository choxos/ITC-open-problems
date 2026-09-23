## Figure: pass probability and coverage given a pass, by ecological bias.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
s <- s[s$policy %in% c("half_sA", "test_05"), ]
s$config <- paste0("K = ", s$K, ", dispersion ", s$disp)
s$policy <- factor(s$policy, c("half_sA", "test_05"), c("half-SE rule", "5% test on the difference"))
long <- rbind(data.frame(s[, c("delta", "config", "policy")], what = "P(pool)", value = s$pass),
              data.frame(s[, c("delta", "config", "policy")], what = "coverage given pooled", value = s$cond_cover_pass))
p <- ggplot(long, aes(delta, value, colour = config, linetype = policy)) + geom_line() + geom_point(size = 1) +
  facet_wrap(~what, scales = "free_y") + labs(x = "Ecological bias (delta)", y = NULL, colour = NULL, linetype = NULL) +
  theme_bw(base_size = 10) + theme(legend.position = "bottom", legend.box = "vertical")
ggsave("manuscript/figures/fig1-rule.png", p, width = 7.5, height = 4.5, dpi = 200)
