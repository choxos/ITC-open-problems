## Figures: rate-ratio coverage under overdispersion; absolute-rate bias under differing zero fractions.
suppressPackageStartupMessages(library(ggplot2))
s <- read.csv("results/summary.csv")
lab <- c(poisson = "Poisson", poisson_sandwich = "Poisson, sandwich", negbin = "negative binomial", zip = "zero-inflated Poisson", zip_calibrated = "zero-inflated, recalibrated")
s$method <- factor(lab[s$method], lab)
A <- s[s$part == "A", ]; A$disp <- factor(ifelse(is.finite(A$theta), paste0("NB size ", A$theta), "Poisson"), c("Poisson", "NB size 2", "NB size 0.7"))
A$b <- factor(A$b, c(0, 0.4), c("no modification", "modification 0.4"))
p1 <- ggplot(A, aes(disp, cover_rr, colour = method)) + geom_hline(yintercept = 0.95, linetype = 2, colour = "grey50") +
  geom_point(position = position_dodge(0.5), size = 1.6) + facet_wrap(~b) +
  labs(x = "Outcome dispersion", y = "Coverage, log rate ratio", colour = NULL) + theme_bw(base_size = 9) + theme(legend.position = "bottom")
ggsave("manuscript/figures/fig1-dispersion.png", p1, width = 7, height = 3.6, dpi = 200)
B <- s[s$part == "B", ]; B$zeros <- sprintf("source %.1f, target %.1f", B$pi_s, B$pi_t)
B$b <- factor(B$b, c(0, 0.4), c("no modification", "modification 0.4"))
p2 <- ggplot(B, aes(zeros, bias_rate, colour = method)) + geom_hline(yintercept = 0, colour = "grey60") +
  geom_point(position = position_dodge(0.5), size = 1.6) + facet_wrap(~b) +
  labs(x = "Structural-zero fraction", y = "Bias, log rate of A in the target", colour = NULL) + theme_bw(base_size = 9) +
  theme(legend.position = "bottom", axis.text.x = element_text(angle = 20, hjust = 1))
ggsave("manuscript/figures/fig2-zeros.png", p2, width = 7, height = 3.8, dpi = 200)
