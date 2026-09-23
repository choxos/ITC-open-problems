## Figure: bias by mechanism and method at each missingness rate.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
s$mech <- factor(s$mech, c("MCAR", "MAR_x2", "MAR_u", "MAR_y", "MNAR_x1", "MAR_u_armA"),
                 c("MCAR", "on x2", "on u", "on y", "on x1 itself", "on u, arm A only"))
s$method <- factor(s$method, c("complete_case", "ipw", "mi_congenial", "mi_generic"),
                   c("complete case", "observation weighting", "MI, arm-interacted", "MI, no arm terms"))
s$bu <- factor(s$bu, c(0, 0.3), c("u prognostic only", "u also modifies"))
p <- ggplot(s, aes(factor(rate), bias, colour = method, group = method)) +
  geom_hline(yintercept = 0, colour = "grey60") + geom_point(position = position_dodge(0.5), size = 1.4) +
  facet_grid(bu ~ mech) + coord_cartesian(ylim = c(-0.5, 0.3)) +
  labs(x = "Proportion missing", y = "Bias (values below -0.5 clipped)", colour = NULL) +
  theme_bw(base_size = 9) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-bias.png", p, width = 8, height = 4.4, dpi = 200)
