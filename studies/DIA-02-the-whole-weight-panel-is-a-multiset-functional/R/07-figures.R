## ---------------------------------------------------------------------------
## Figures for the manuscript, drawn from results/analysis.rds and the per-cell
## run files. Nothing here computes a number the manuscript quotes; the
## manuscript reads analysis.rds itself.
##
##   Rscript R/07-figures.R
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(ggplot2))

a   <- readRDS("results/analysis.rds")
fp  <- readRDS("results/floor-probe.rds")
out <- "manuscript/figures"
dir.create(out, recursive = TRUE, showWarnings = FALSE)

## Figure 1: the two readings side by side. Within-arm AUROC is the registered
## primary; cross-arm separation is the second null control read as a number.
m <- merge(a$primary[, c("statistic", "family", "auroc", "se")],
           a$cross[, c("statistic", "separation", "se")],
           by = "statistic", suffixes = c("_within", "_cross"))
long <- rbind(
  data.frame(statistic = m$statistic, family = m$family,
             reading = "Within the high-modification arm (registered primary)",
             value = m$auroc, se = m$se_within),
  data.frame(statistic = m$statistic, family = m$family,
             reading = "Across the two hole placements (second null control)",
             value = m$separation, se = m$se_cross))
long$reading <- factor(long$reading, levels = unique(long$reading))
long$statistic <- factor(long$statistic,
                         levels = m$statistic[order(m$separation)])
p1 <- ggplot(long, aes(value, statistic, colour = family)) +
  geom_vline(xintercept = 0.5, linetype = 2, colour = "grey50") +
  geom_errorbar(aes(xmin = value - 1.96 * se, xmax = value + 1.96 * se),
                width = 0.2, orientation = "y") +
  geom_point(size = 2) +
  facet_wrap(~reading, ncol = 2) +
  scale_colour_manual(values = c(panel = "#b2182b", geometric = "#2166ac")) +
  labs(x = "AUROC (left) or separation, max(AUROC, 1 - AUROC) (right)",
       y = NULL, colour = "Family") +
  theme_bw(base_size = 10) + theme(legend.position = "bottom")
ggsave(file.path(out, "fig1-two-readings.png"), p1, width = 8, height = 4,
       dpi = 200)

## Figure 2: the null control by stratum, and what source size would rescue the
## strata it removed.
fp$stratum <- paste0("dim", fp$dim, "/", fp$overlap)
fp$upper <- vapply(seq_len(nrow(fp)), function(i)
  stats::binom.test(round(fp$p_material[i] * fp$n_ok[i]), fp$n_ok[i])$conf.int[2], 0)
p2 <- ggplot(fp, aes(n_source, p_material, colour = stratum)) +
  geom_hline(yintercept = 0.02, linetype = 2) +
  geom_line() + geom_point() +
  geom_errorbar(aes(ymin = p_material, ymax = upper), width = 0.03) +
  scale_x_log10(breaks = unique(fp$n_source)) +
  labs(x = "Source records (log scale)",
       y = "P(|error| > 0.03) with no support hole",
       colour = NULL) +
  theme_bw(base_size = 10) + theme(legend.position = "bottom")
ggsave(file.path(out, "fig2-null-floor.png"), p2, width = 6, height = 4, dpi = 200)

## Figure 3: the manipulation. Bias by hole placement on the surviving subgrid.
arm <- a$arm
arm$hole <- factor(arm$hole, levels = c("none", "low_modification",
                                        "high_modification"))
p3 <- ggplot(arm, aes(hole, bias, fill = modification)) +
  geom_col(position = position_dodge(0.8), width = 0.7) +
  geom_hline(yintercept = 0) +
  labs(x = "Support hole", y = "Bias in the marginal risk difference",
       fill = "Effect modification") +
  theme_bw(base_size = 10) + theme(legend.position = "bottom")
ggsave(file.path(out, "fig3-manipulation.png"), p3, width = 6, height = 4, dpi = 200)

cat("written:", paste(list.files(out), collapse = ", "), "\n")
