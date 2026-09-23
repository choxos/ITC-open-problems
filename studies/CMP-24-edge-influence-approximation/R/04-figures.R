suppressPackageStartupMessages(library(ggplot2))
source("R/00-model.R")
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), build_grid(), by = "cell")
d$tau <- factor(sprintf("true tau %.1f", d$tau)); d$K <- factor(sprintf("%d studies", d$K))
p <- ggplot(d, aes(K, rho_importance, fill = multi)) + geom_hline(yintercept = 0.9, linetype = 2) +
  geom_boxplot(outlier.size = 0.3, linewidth = 0.3) + facet_wrap(~ tau, nrow = 1) +
  labs(x = NULL, y = "Spearman: diagonal influence vs variance importance", fill = NULL) +
  theme_bw(base_size = 9) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-spearman.png", p, width = 7, height = 3.2, dpi = 200)
