## Figure: SE of each route and the estimate's spread along the sweep, with ESS.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
l <- rbind(data.frame(s[, c("rho", "p")], quantity = "reported SE, STC", value = s$se_stc), data.frame(s[, c("rho", "p")], quantity = "reported SE, MAIC", value = s$se_maic),
           data.frame(s[, c("rho", "p")], quantity = "empirical SD, MAIC", value = s$emp_sd_maic))
p <- ggplot(l, aes(p, value, colour = quantity)) + geom_line() + geom_point(size = 1.4) + facet_wrap(~sprintf("dependence of U on x: %.1f", rho)) +
  labs(x = "Assumed target prevalence of the unmeasured covariate", y = "Log odds scale", colour = NULL) + theme_bw(base_size = 9) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-se.png", p, width = 7, height = 3.6, dpi = 200)
