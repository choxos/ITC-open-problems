suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv"); s <- s[s$b_eco == 0, ]
l <- rbind(data.frame(s[, c("beta", "xstar", "estimator")], type = "bounded interval", share = s$bounded),
           data.frame(s[, c("beta", "xstar", "estimator")], type = "two half-lines", share = s$exclusive),
           data.frame(s[, c("beta", "xstar", "estimator")], type = "whole line", share = s$whole_line))
l$type <- factor(l$type, c("whole line", "two half-lines", "bounded interval"))
l$est <- ifelse(l$estimator == "within", "individual trial alone", "with aggregate trials")
p <- ggplot(l, aes(factor(beta), share, fill = type)) + geom_col(width = 0.7) + facet_grid(est ~ sprintf("true boundary x* = %.1f", xstar)) +
  scale_fill_manual(values = c("#b2182b", "#ef8a62", "#67a9cf")) +
  labs(x = "Interaction (difference in slope, outcome SD per covariate SD)", y = "Share of 95% Fieller sets", fill = NULL) +
  theme_bw(base_size = 10) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-fieller.png", p, width = 6.5, height = 4.5, dpi = 200)
