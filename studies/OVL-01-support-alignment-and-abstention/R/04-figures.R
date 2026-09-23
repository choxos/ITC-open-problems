## Figure: bias by alignment, modification shape and truncation (strength 0.6), with the
## Kish ESS fraction, identical across alignment and shape, beneath.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv"); s <- s[s$b == 0.6 & s$method != "trimmed_vs_restricted", ]
s$trunc <- factor(ifelse(is.finite(s$c_trunc), sprintf("support truncated at %.1f (ESS/n %.2f)", s$c_trunc, s$ess_frac), sprintf("full support (ESS/n %.2f)", s$ess_frac)))
s$trunc <- factor(sub(" \\(ESS.*", "", s$trunc), c("full support", "support truncated at 1.5", "support truncated at 1.0"))
s$align <- factor(s$align, c("orthogonal", "partial", "full")); s$method <- factor(s$method, c("maic", "gcomp"), c("MAIC", "spline G-computation"))
p <- ggplot(s, aes(align, bias, colour = shape, shape = method, group = interaction(shape, method))) + geom_hline(yintercept = 0, colour = "grey60") +
  geom_line(alpha = 0.6) + geom_point(size = 1.8) + facet_wrap(~trunc) +
  labs(x = "Alignment of the unsupported direction with effect modification", y = "Bias of the target mean difference", colour = "Modification", shape = NULL) +
  theme_bw(base_size = 9) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-bias.png", p, width = 7.5, height = 3.6, dpi = 200)
