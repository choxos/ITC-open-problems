## Figures.
##
##   Rscript R/06-figures.R

.f <- grep("^--file=", commandArgs(FALSE), value = TRUE)
STUDY <- if (length(.f)) {
  dirname(dirname(normalizePath(sub("^--file=", "", .f[1]))))
} else {
  normalizePath(".")
}
here <- function(...) file.path(STUDY, ...)

suppressPackageStartupMessages(library(ggplot2))
FIG <- here("results", "figures")
dir.create(FIG, recursive = TRUE, showWarnings = FALSE)

s_all <- utils::read.csv(here("results", "summary.csv"), stringsAsFactors = FALSE)
## Primary regime: every component has within-trial information. The `no-B-ipd`
## level is a separate near-nonidentified regime with its own figure, because
## pooling it flattens every other panel.
s <- s_all[s_all$ipd != "no-B-ipd", ]

ML <- c("shared-info", "shared-sandwich", "joint-split", "ipd-anchored")
LB <- c("Shared Gamma\n(status quo)", "Shared Gamma\n+ cluster sandwich",
        "Joint split", "IPD anchored")
s$method <- factor(s$method, ML, LB)
s_all$method <- factor(s_all$method, ML, LB)

RHO <- c("rho-1", "rho-0.5", "rho0", "rho0.5", "rho1")
RHO_NUM <- c(-1, -0.5, 0, 0.5, 1)
s$rho <- RHO_NUM[match(s$pattern, RHO)]

theme_set(theme_bw(base_size = 10) +
  theme(panel.grid.minor = element_blank(),
        strip.background = element_rect(fill = "grey93", color = NA),
        legend.position = "bottom"))
BAND <- annotate("rect", xmin = -Inf, xmax = Inf, ymin = 93, ymax = 97,
                 fill = "grey88", alpha = 0.7)

## --- 1. Coverage against discordance. The main result.
d1 <- s[!is.na(s$rho), ]
p1 <- ggplot(d1, aes(rho, 100 * coverage, color = method)) +
  BAND +
  geom_hline(yintercept = 95, linewidth = 0.3) +
  stat_summary(fun = stats::median, geom = "line", linewidth = 0.6) +
  stat_summary(fun = stats::median, geom = "point", size = 1.8) +
  facet_grid(network ~ paste0("n = ", n_arm)) +
  labs(x = expression(rho ~ "=" ~ gamma[B] / gamma[W] ~ ", discordance between within- and across-trial modification"),
       y = "coverage (%)", color = NULL,
       title = "What a shared interaction costs, as the two coefficients diverge",
       subtitle = "Median over IPD availability, prevalence spread and component. Shaded band is 93% to 97%.") +
  guides(color = guide_legend(nrow = 2))
ggsave(file.path(FIG, "fig1-coverage-by-discordance.png"), p1,
       width = 8.5, height = 5.6, dpi = 200)

## --- 2. The mechanism test. Is the pull caused by aggregate data?
##
## If the catalog's mechanism is right, the shared model should be unbiased when
## every trial supplies individual data. This figure is the test.
d2 <- s[s$pattern %in% c("rho0.5", "rho0", "rho-0.5", "rho-1", "between-only") &
          s$method == LB[1], ]
d2$ipd <- factor(d2$ipd, c("all", "six", "four", "four-low", "no-B-ipd"))
p2 <- ggplot(d2, aes(ipd, abs(std_bias), color = pattern)) +
  geom_hline(yintercept = 0.1, linetype = 3, linewidth = 0.3) +
  geom_hline(yintercept = 0.2, linetype = 2, linewidth = 0.3) +
  geom_jitter(width = 0.18, height = 0, size = 1.1, alpha = 0.8) +
  facet_wrap(~ network) +
  labs(x = "trials supplying individual patient data",
       y = "absolute standardized bias of the shared model", color = NULL,
       title = "Is the pull caused by aggregate data?",
       subtitle = "The catalog says yes. If so the left-hand column, where every trial supplies individual data, should sit near zero.")
ggsave(file.path(FIG, "fig2-mechanism.png"), p2, width = 8.5, height = 4.2, dpi = 200)

## --- 3. Negative controls, where the shared model is correctly specified.
d3 <- s[s$pattern %in% c("null", "rho1"), ]
p3 <- ggplot(d3, aes(method, 100 * coverage, color = pattern)) +
  BAND + geom_hline(yintercept = 95, linewidth = 0.3) +
  geom_jitter(width = 0.15, height = 0, size = 1.1, alpha = 0.8) +
  coord_flip() +
  labs(x = NULL, y = "coverage (%)", color = NULL,
       title = "Negative controls",
       subtitle = "At rho = 1 and under no effect modification the shared model is correctly specified, so every method must be nominal.")
ggsave(file.path(FIG, "fig3-controls.png"), p3, width = 8, height = 3.6, dpi = 200)

## --- 4. A component with no within-trial information at all.
d4 <- s_all[s_all$ipd == "no-B-ipd" & s_all$par == "gWB", ]
d4$method <- factor(as.character(d4$method), LB)
p4 <- ggplot(d4, aes(pattern, 100 * coverage, color = method)) +
  BAND + geom_hline(yintercept = 95, linewidth = 0.3) +
  geom_point(position = position_dodge(0.6), size = 1.6) +
  facet_wrap(~ network) +
  coord_flip() +
  labs(x = NULL, y = "coverage (%)", color = NULL,
       title = "When a component has no within-trial information",
       subtitle = "The IPD-anchored method declines to report and so has no point here; the others answer anyway.") +
  guides(color = guide_legend(nrow = 2))
ggsave(file.path(FIG, "fig4-no-ipd-component.png"), p4, width = 8.5, height = 4.4, dpi = 200)

cat("wrote 4 figures to", FIG, "\n")
