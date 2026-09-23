suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
s$prior <- factor(s$method, c("flat", "eb_ridge", "hier_normal", "spike_slab", "median_model"),
                  c("flat", "empirical-Bayes ridge", "hierarchical normal", "spike-and-slab average", "median-probability model"))
s$scen <- sprintf("%s, %d per arm", ifelse(s$pattern == "one_strong", "one strong modifier", "three moderate modifiers"), s$n)
p <- ggplot(s, aes(coverage, prior)) + geom_vline(xintercept = 0.95, linetype = 2) + geom_vline(xintercept = 0.93, linetype = 3) +
  geom_pointrange(aes(xmin = coverage - 1.96 * cov_mcse, xmax = coverage + 1.96 * cov_mcse), size = 0.25) +
  facet_wrap(~ scen) + labs(x = "Coverage of 95% posterior interval (95% Monte Carlo interval)", y = NULL) + theme_bw(base_size = 10)
ggsave("manuscript/figures/fig1-coverage.png", p, width = 6.5, height = 4, dpi = 200)
