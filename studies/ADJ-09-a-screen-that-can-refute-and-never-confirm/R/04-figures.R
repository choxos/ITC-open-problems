## Figure: abstention by screen scale, drift and number of trials.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv"); s <- s[s$ctrl == "none", ]
s$scen <- factor(ifelse(s$drift == "none", "valid bridge", sprintf("%s, %.2f", sub("_", " ", sub("observed_and_gap", "visible drift", sub("gap_only", "gap-only drift", s$drift))), s$size)),
                 c("valid bridge", "visible drift, 0.15", "visible drift, 0.30", "gap-only drift, 0.15", "gap-only drift, 0.30"))
l <- rbind(data.frame(s[, c("K", "G", "scen")], scale = "marginal", abstain = s$abst_marg),
           data.frame(s[, c("K", "G", "scen")], scale = "conditional", abstain = s$abst_cond),
           data.frame(s[, c("K", "G", "scen")], scale = "standardized", abstain = s$abst_std))
l$panel <- sprintf("K = %d trials, prognostic G = %.1f", l$K, l$G)
p <- ggplot(l, aes(scen, abstain, fill = scale)) + geom_col(position = position_dodge(0.8), width = 0.75) +
  geom_hline(yintercept = 0.10, linetype = 2, colour = "grey40") + facet_wrap(~panel, ncol = 2) +
  labs(x = NULL, y = "Proportion of analyses abstaining", fill = "Screen on") + theme_bw(base_size = 9) +
  theme(axis.text.x = element_text(angle = 30, hjust = 1), legend.position = "bottom")
ggsave("manuscript/figures/fig1-abstain.png", p, width = 7.5, height = 5.5, dpi = 200)
