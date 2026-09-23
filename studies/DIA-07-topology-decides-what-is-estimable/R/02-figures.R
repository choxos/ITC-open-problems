suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
s$config <- factor(paste0(s$topology, ": ", ifelse(s$ipd_edge == "none", "no IPD", paste("IPD on", s$ipd_edge))), levels = rev(unique(paste0(s$topology, ": ", ifelse(s$ipd_edge == "none", "no IPD", paste("IPD on", s$ipd_edge))))))
s$Gl <- factor(sprintf("G = %.2f", s$G))
p <- ggplot(s, aes(decision_error, config, colour = Gl)) + geom_point(size = 1.8) + facet_wrap(~ sprintf("target covariate mean %.1f", M_T)) +
  labs(x = "Decision error (sign of the D-versus-A estimate differs from the truth)", y = NULL, colour = "Modification") + theme_bw(base_size = 9) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-decision.png", p, width = 7, height = 4.6, dpi = 200)
