suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
s$scen <- sprintf("weights %s, outcome %s", s$weights, s$outcome)
l <- rbind(data.frame(s[, c("scen", "m1_t")], estimator = "drMAIC MAIC", bias = s$bias_maic, mcse = s$mcse_maic),
           data.frame(s[, c("scen", "m1_t")], estimator = "drMAIC doubly robust", bias = s$bias_dr, mcse = s$mcse_maic),
           data.frame(s[, c("scen", "m1_t")], estimator = "correct augmentation", bias = s$bias_aug, mcse = s$mcse_aug))
l$estimator <- factor(l$estimator, c("drMAIC MAIC", "drMAIC doubly robust", "correct augmentation"))
p <- ggplot(l, aes(bias, scen, colour = estimator)) + geom_vline(xintercept = 0, linetype = 2) +
  geom_pointrange(aes(xmin = bias - 1.96 * mcse, xmax = bias + 1.96 * mcse), position = position_dodge(width = 0.6), size = 0.25) +
  facet_wrap(~ sprintf("target x1 mean %.1f", m1_t)) + labs(x = "Bias, log odds ratio (95% Monte Carlo interval)", y = NULL, colour = NULL) +
  theme_bw(base_size = 10) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-bias.png", p, width = 7, height = 3.6, dpi = 200)
