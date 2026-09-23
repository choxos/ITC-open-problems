## Figure: interaction bias by latent selection and IPD share, within and combined, with influence.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
l <- rbind(data.frame(s[, c("share", "s_obs", "s_lat")], estimator = "IPD trials only (within-trial)", bias = s$bias_beta_within),
           data.frame(s[, c("share", "s_obs", "s_lat")], estimator = "combined with aggregate trials", bias = s$bias_beta_comb))
l$obs <- factor(ifelse(l$s_obs > 0, "selection also on an observed trial variable", "no selection on observed variables"))
p <- ggplot(l, aes(s_lat, bias, colour = estimator, linetype = factor(share))) + geom_hline(yintercept = 0, colour = "grey60") + geom_line() + geom_point(size = 1.4) +
  facet_wrap(~obs) + scale_x_continuous(breaks = 0:2) + labs(x = "Selection on the trial's latent interaction", y = "Bias of the interaction estimate", colour = NULL, linetype = "IPD share") +
  theme_bw(base_size = 9) + theme(legend.position = "bottom", legend.box = "vertical")
ggsave("manuscript/figures/fig1-bias.png", p, width = 7, height = 4.2, dpi = 200)
