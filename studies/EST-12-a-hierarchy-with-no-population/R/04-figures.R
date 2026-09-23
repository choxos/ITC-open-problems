## Figure: rank movement across targets (estimated and true) against movement across replicates.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
s$moves <- ifelse(s$true_across > 0, "true ranking changes across targets", "true ranking does not change")
p <- ggplot(s, aes(across_replicates, across_targets, colour = moves, shape = factor(M))) + geom_abline(linetype = 2, colour = "grey50") +
  geom_point(size = 2.2) + labs(x = "Rank movement across replicates at one target", y = "Rank movement across targets within a replicate",
  colour = NULL, shape = "Trials per comparison") + theme_bw(base_size = 9) + theme(legend.position = "bottom", legend.box = "vertical")
ggsave("manuscript/figures/fig1-movement.png", p, width = 6, height = 4.6, dpi = 200)
