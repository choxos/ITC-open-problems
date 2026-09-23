## Figure for the manuscript: contraction against coverage on E1, by cause.
##
##   Rscript R/13-figures.R

suppressPackageStartupMessages(library(ggplot2))
e <- readRDS("results/e1.rds")
e$cause <- ifelse(e$prior_sd == 0.1, "prior SD 0.1",
                  ifelse(e$discord > 0 | e$synergy > 0,
                         "route biased (discordance or synergy)", "correctly specified"))
dir.create("manuscript/figures", recursive = TRUE, showWarnings = FALSE)
p <- ggplot(e, aes(contraction, coverage, colour = state)) +
  annotate("rect", xmin = -Inf, xmax = Inf, ymin = 0.94, ymax = 0.96,
           alpha = 0.15) +
  geom_hline(yintercept = 0.90, linetype = 2) +
  geom_vline(xintercept = 0.50, linetype = 3) +
  geom_point(size = 1.4, alpha = 0.8) +
  facet_wrap(~cause, ncol = 3) +
  labs(x = "Contraction (posterior SD / prior SD, target interaction)",
       y = "Coverage of the nominal 95% interval", colour = "Information state") +
  theme_bw(base_size = 10) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-contraction-coverage.png", p, width = 9,
       height = 3.8, dpi = 200)
cat("written: manuscript/figures/fig1-contraction-coverage.png\n")
