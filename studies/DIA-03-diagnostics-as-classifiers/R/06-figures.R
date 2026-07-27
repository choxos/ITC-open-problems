## Figures.
.f <- grep("^--file=", commandArgs(FALSE), value = TRUE)
STUDY <- if (length(.f)) dirname(dirname(normalizePath(sub("^--file=", "", .f[1])))) else normalizePath(".")
here <- function(...) file.path(STUDY, ...)
suppressPackageStartupMessages(library(ggplot2))
FIG <- here("results", "figures"); dir.create(FIG, recursive = TRUE, showWarnings = FALSE)
rd <- function(f) utils::read.csv(here("results", f), stringsAsFactors = FALSE)

cells <- rd("cells.csv"); disc <- rd("discrimination.csv")
roc <- rd("roc.csv"); op <- rd("operating-points.csv"); dca <- rd("decision-curve.csv")

theme_set(theme_bw(base_size = 10) + theme(panel.grid.minor = element_blank(),
  strip.background = element_rect(fill = "grey93", color = NA),
  legend.position = "bottom"))

NICE <- c(ess = "ESS", ess_pct = "ESS %", cv_w = "CV(w)", max_w = "max weight",
          smd_matched = "balance, matched", smd_pre = "imbalance, pre-weighting",
          maha = "Mahalanobis distance", smd_unmatched = "balance, unmatched",
          bias_hat = "estimated bias (proposed)", orc_cross = "oracle: cross-moment",
          lambda_norm = "||lambda||")

## 1. The central picture. Each point is one cell of the design: what a given
##    effective sample size actually implies for the chance of a material error.
cells$channel <- with(cells, ifelse(omit == 0 & joint == 0, "neither",
                            ifelse(omit > 0 & joint > 0, "both",
                            ifelse(omit > 0, "omitted modifier", "cross-moment"))))
cells$channel <- factor(cells$channel,
                        c("neither", "omitted modifier", "cross-moment", "both"))
p1 <- ggplot(cells, aes(ess, material, color = channel, size = w_deploy)) +
  annotate("rect", xmin = -Inf, xmax = 35, ymin = -Inf, ymax = Inf,
           fill = "grey88", alpha = 0.8) +
  annotate("text", x = 35, y = 1.02, label = "  ESS < 35 fires", hjust = 0,
           size = 3, color = "grey35") +
  geom_point(alpha = 0.85) +
  scale_x_log10(breaks = c(5, 10, 20, 35, 70, 150, 350, 800)) +
  scale_size_continuous(range = c(1, 4.5), guide = "none") +
  scale_color_manual(values = c(neither = "grey45", `omitted modifier` = "#b2182b",
                                `cross-moment` = "#2166ac", both = "#762a83"),
                     name = "bias channel switched on") +
  labs(x = "median effective sample size in the cell (log scale)",
       y = "rate of material error",
       title = "The same effective sample size means different things",
       subtitle = "One point per design cell; point size is its deployment weight. A rule reading only the horizontal axis cannot separate the colors.")
ggsave(file.path(FIG, "fig1-ess-vs-error.png"), p1, width = 8, height = 4.6, dpi = 200)

## 2. ROC curves, against total realized error and against the transport component
##    alone. The second is the fair test: it is the only part of the error a
##    covariate diagnostic could know about.
keep <- c("ess", "max_w", "smd_pre", "maha", "smd_unmatched", "bias_hat", "orc_cross")
r <- roc[roc$diagnostic %in% keep, ]
r$diagnostic <- factor(NICE[r$diagnostic], NICE[keep])
p2 <- ggplot(r, aes(fpr, tpr, color = diagnostic)) +
  geom_abline(slope = 1, intercept = 0, linetype = 3, linewidth = 0.3) +
  geom_line(linewidth = 0.7) +
  facet_wrap(~ target) + coord_fixed() +
  scale_color_brewer(palette = "Dark2", name = NULL) +
  guides(color = guide_legend(nrow = 3)) +
  labs(x = "false-positive rate", y = "true-positive rate",
       title = "Discrimination, weighted by the declared deployment distribution",
       subtitle = "Left: total realized error. Right: the transport component alone, which is the only part a covariate diagnostic can see.")
ggsave(file.path(FIG, "fig2-roc.png"), p2, width = 8, height = 5.4, dpi = 200)

## 3. What each diagnostic is actually measuring.
d <- disc[disc$diagnostic %in% keep, ]
long <- do.call(rbind, lapply(c("auc_noise", "auc_transport", "auc_deploy"), function(v)
  data.frame(diagnostic = NICE[d$diagnostic], component = v, auc = d[[v]])))
long$component <- factor(long$component, c("auc_noise", "auc_transport", "auc_deploy"),
                         c("outcome noise", "transport error", "total realized error"))
long$diagnostic <- factor(long$diagnostic, NICE[keep])
p3 <- ggplot(long, aes(diagnostic, auc, fill = component)) +
  geom_hline(yintercept = 0.5, linetype = 3, linewidth = 0.3) +
  geom_col(position = position_dodge(width = 0.8), width = 0.75) +
  coord_flip(ylim = c(0.4, 1)) +
  scale_fill_manual(values = c("#4393c3", "#b2182b", "grey40"), name = NULL) +
  labs(x = NULL, y = "area under the ROC curve",
       title = "Each diagnostic against each component of the error",
       subtitle = "Effective sample size is a variance statistic. It reads the noise channel, not the transport channel.")
ggsave(file.path(FIG, "fig3-components.png"), p3, width = 8, height = 4.4, dpi = 200)

## 4. Operational calibration: how often the rule fires in a cell against how
##    often that cell is actually wrong. A calibrated rule would climb the
##    diagonal; a rule that fires on the wrong axis will not.
p4 <- ggplot(cells, aes(fires_ess35, material, color = channel, size = w_deploy)) +
  geom_abline(slope = 1, intercept = 0, linetype = 3, linewidth = 0.3) +
  geom_point(alpha = 0.85) +
  scale_size_continuous(range = c(1, 4.5), guide = "none") +
  scale_color_manual(values = c(neither = "grey45", `omitted modifier` = "#b2182b",
                                `cross-moment` = "#2166ac", both = "#762a83"),
                     name = "bias channel switched on") +
  coord_fixed(xlim = c(0, 1), ylim = c(0, 1)) +
  labs(x = "rate at which ESS < 35 fires in the cell",
       y = "rate of material error in the cell",
       title = "Where the warning fires against where the error is",
       subtitle = "Points above the diagonal are analyses that are wrong and not flagged; points below are flagged and sound.")
ggsave(file.path(FIG, "fig4-calibration.png"), p4, width = 6.4, height = 5.4, dpi = 200)

## 5. Decision curve. A rule earns its place only above both alternatives.
rules <- setdiff(names(dca), c("pt", "flag_none", "flag_all"))
dl <- do.call(rbind, lapply(c("flag_all", rules), function(v)
  data.frame(pt = dca$pt, rule = v, nb = dca[[v]])))
dl <- dl[dl$rule %in% c("flag_all", "ess", "ess_pct", "smd_pre", "bias_hat"), ]
dl$rule <- factor(dl$rule, c("flag_all", "ess", "ess_pct", "smd_pre", "bias_hat"),
                  c("flag everything", "ESS < 35", "ESS < 50%",
                    "pre-weighting imbalance > 0.25", "estimated bias > 0.10"))
p5 <- ggplot(dl, aes(pt, nb, color = rule)) +
  geom_hline(yintercept = 0, linetype = 2, linewidth = 0.4) +
  geom_line(linewidth = 0.7) + geom_point(size = 1.4) +
  scale_color_brewer(palette = "Set1", name = NULL) +
  guides(color = guide_legend(nrow = 2)) +
  labs(x = "threshold probability at which an analyst would act",
       y = "net benefit",
       title = "Is acting on the warning better than not acting?",
       subtitle = "The dashed line is flagging nothing. A rule is worth using only above it and above flagging everything.")
ggsave(file.path(FIG, "fig5-decision-curve.png"), p5, width = 7, height = 4.6, dpi = 200)

cat("figures written to", FIG, "\n")
