## Figure: bias by method and assay scenario.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
lab <- c(maic_naive = "MAIC on X*", maic_prev_only = "MAIC, prevalence corrected only", maic_corrected = "MAIC, latent-prevalence weights",
         stc_naive = "STC on X*", stc_outcome_only = "STC, outcome model corrected only", stc_corrected = "STC, fully corrected")
s$method <- factor(lab[s$method], lab)
s$assay <- factor(s$assay, c("same_good", "same_poor", "source_worse", "target_worse"), c("same, good", "same, poor", "source worse", "target worse"))
p <- ggplot(s, aes(assay, bias, colour = method)) + geom_hline(yintercept = 0, colour = "grey60") +
  geom_pointrange(aes(ymin = bias - 1.96 * mcse, ymax = bias + 1.96 * mcse), position = position_dodge(0.7), size = 0.25) +
  facet_wrap(~sprintf("modification %.1f", b)) + labs(x = "Assay (source and target)", y = "Bias of the target log odds ratio", colour = NULL) +
  theme_bw(base_size = 8) + theme(legend.position = "bottom", axis.text.x = element_text(angle = 20, hjust = 1))
ggsave("manuscript/figures/fig1-bias.png", p, width = 7.5, height = 4, dpi = 200)
