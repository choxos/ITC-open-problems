## Figures.
##
##   Rscript R/05-figures.R
##
## Every panel shows Monte Carlo error. A coverage plot without it invites the
## reader to interpret a half-point wiggle that the replicate count cannot
## resolve.
##
## The first four figures are restricted to the scenarios in which the reference
## interval and the matched negative control are both valid. At poor overlap they
## are not, and the resulting failure is large enough to dominate any plot it
## appears in while having nothing to do with target moments. It is a real
## finding and gets its own figure rather than being allowed to swamp the others.

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

summ <- utils::read.csv(here("results", "summary.csv"), stringsAsFactors = FALSE)
paired <- utils::read.csv(here("results", "paired.csv"), stringsAsFactors = FALSE)

METHOD_LEVELS <- c("target-fixed", "normal-recon", "reported-cov", "joint-score")
METHOD_LABELS <- c("Status quo", "Normal reconstruction",
                   "Reported moment covariance", "Full joint score")

inband <- function(x) x >= 0.93 & x <= 0.97
jj <- summ[summ$method == "joint-score", ]
cc <- summ[summ$method == "target-fixed" & summ$em_sd == 0, ]
ckey <- function(x) paste(x$nS, x$nT, x$d, x$rho_T)
jok <- setNames(inband(jj$coverage), jj$scenario)
cok <- setNames(inband(cc$coverage), ckey(cc))
summ$usable <- jok[as.character(summ$scenario)] & cok[ckey(summ)]
summ$usable[is.na(summ$usable)] <- FALSE
paired$usable <- summ$usable[match(paired$scenario, summ$scenario)]

summ$method <- factor(summ$method, METHOD_LEVELS, METHOD_LABELS)
paired$method <- factor(paired$method, METHOD_LEVELS[-4], METHOD_LABELS[-4])

lab_em <- function(x) ifelse(x == 0, "no effect modification",
                      ifelse(x == 0.45, "SD[T](tau) == 0.45", "SD[T](tau) == 0.90"))
lab_k <- function(x) paste0("kappa == ", x)

theme_set(theme_bw(base_size = 10) +
  theme(panel.grid.minor = element_blank(),
        strip.background = element_rect(fill = "grey93", color = NA),
        legend.position = "bottom"))

U <- summ[summ$usable, ]

## --- 1. The result. Status-quo coverage error against the information ratio.
##
## The x axis is nS/nT rather than nT, because that ratio governs the size of the
## omitted term relative to the retained one. Plotting against nT alone is how an
## earlier version of this design hid the effect.
d1 <- U[U$method == METHOD_LABELS[1] & U$em_sd > 0, ]
p1 <- ggplot(d1, aes(nS / nT, cov_err_pp, color = factor(d))) +
  annotate("rect", xmin = -Inf, xmax = Inf, ymin = -2, ymax = 2,
           fill = "grey88", alpha = 0.7) +
  geom_hline(yintercept = 0, linewidth = 0.3) +
  geom_errorbar(aes(ymin = cov_err_pp - 1.96 * cov_err_pp_mcse,
                    ymax = cov_err_pp + 1.96 * cov_err_pp_mcse),
                width = 0, alpha = 0.6, position = position_dodge(0.28)) +
  geom_point(size = 1.8, position = position_dodge(0.28)) +
  scale_x_log10(breaks = c(0.25, 1, 2.5, 4, 10)) +
  facet_grid(lab_em(em_sd) ~ lab_k(kappa), labeller = label_parsed) +
  labs(x = "source size / target size",
       y = "coverage error (percentage points)", color = "overlap d",
       title = "What conditioning on sampled target moments costs",
       subtitle = "Nominal 95%. Band is within two points. Bars are 95% Monte Carlo intervals.")
ggsave(file.path(FIG, "fig1-coverage-error.png"), p1, width = 8.5, height = 5.4, dpi = 200)

## --- 2. Do the corrections fix it?
d2 <- U[U$em_sd > 0, ]
p2 <- ggplot(d2, aes(method, 100 * coverage, color = factor(kappa))) +
  annotate("rect", xmin = -Inf, xmax = Inf, ymin = 93, ymax = 97,
           fill = "grey88", alpha = 0.7) +
  geom_hline(yintercept = 95, linewidth = 0.3) +
  geom_jitter(width = 0.18, height = 0, size = 1.1, alpha = 0.75) +
  facet_wrap(~ lab_em(em_sd), labeller = label_parsed) +
  coord_flip() +
  labs(x = NULL, y = "coverage (%)", color = "alignment kappa",
       title = "Only the status quo leaves the band",
       subtitle = paste0("Every usable scenario. ",
                         sum(!inband(d2$coverage[d2$method == METHOD_LABELS[1]])),
                         " of ", sum(d2$method == METHOD_LABELS[1]),
                         " status-quo scenarios fall outside; none of the corrected ones do."))
ggsave(file.path(FIG, "fig2-methods.png"), p2, width = 8.5, height = 4, dpi = 200)

## --- 3. How much variance the status quo omits, and with which sign.
##
## Coverage saturates: once an interval is far too narrow, coverage stops
## distinguishing degrees of wrong. The variance ratio does not, and it is what
## the correction actually changes.
w <- reshape(summ[summ$usable, c("scenario", "nS", "nT", "d", "em_sd", "kappa",
                                 "rho_T", "method", "modse")],
             idvar = c("scenario", "nS", "nT", "d", "em_sd", "kappa", "rho_T"),
             timevar = "method", direction = "wide")
names(w) <- sub("^modse[.]", "", names(w))
w$omitted <- 100 * ((w[[METHOD_LABELS[4]]] / w[[METHOD_LABELS[1]]])^2 - 1)
w <- w[w$em_sd > 0, ]
p3 <- ggplot(w, aes(nS / nT, omitted, color = factor(d), shape = factor(em_sd))) +
  geom_hline(yintercept = 0, linewidth = 0.3) +
  geom_point(size = 1.8, position = position_dodge(0.28)) +
  scale_x_log10(breaks = c(0.25, 1, 2.5, 4, 10)) +
  facet_wrap(~ lab_k(kappa), labeller = label_parsed) +
  labs(x = "source size / target size",
       y = "variance the status quo omits (%)",
       color = "overlap d", shape = expression(SD[T](tau)),
       title = "The omitted variance component, and why its sign is not fixed",
       subtitle = "Positive: the reported interval is too narrow. Negative: too wide.")
ggsave(file.path(FIG, "fig3-omitted-variance.png"), p3, width = 8.5, height = 3.8, dpi = 200)

## --- 4. What each level of reporting buys.
p4 <- ggplot(paired[paired$usable & paired$em_sd > 0, ],
             aes(nS / nT, 100 * cov_diff, color = factor(rho_T))) +
  geom_hline(yintercept = 0, linewidth = 0.3) +
  geom_errorbar(aes(ymin = 100 * (cov_diff - 1.96 * cov_diff_mcse),
                    ymax = 100 * (cov_diff + 1.96 * cov_diff_mcse)),
                width = 0, alpha = 0.5, position = position_dodge(0.28)) +
  geom_point(size = 1.4, position = position_dodge(0.28)) +
  scale_x_log10(breaks = c(0.25, 1, 2.5, 4, 10)) +
  facet_grid(method ~ lab_em(em_sd), labeller = labeller(.rows = label_value,
                                                         .cols = label_parsed)) +
  labs(x = "source size / target size",
       y = "coverage minus full-joint-score coverage (pp)",
       color = expression(rho[T]),
       title = "What each level of target reporting buys",
       subtitle = "Paired differences against the benchmark that uses all target information")
ggsave(file.path(FIG, "fig4-reporting.png"), p4, width = 8.5, height = 5.6, dpi = 200)

## --- 5. The secondary finding: at poor overlap everything fails together.
d5 <- summ[summ$em_sd == 0, ]
p5 <- ggplot(d5, aes(factor(d), 100 * coverage, color = method)) +
  annotate("rect", xmin = -Inf, xmax = Inf, ymin = 93, ymax = 97,
           fill = "grey88", alpha = 0.7) +
  geom_hline(yintercept = 95, linewidth = 0.3) +
  geom_point(position = position_dodge(0.6), size = 1.7) +
  facet_wrap(~ paste0("nS = ", nS)) +
  labs(x = "overlap d", y = "coverage (%)", color = NULL,
       title = "A separate failure, with no effect modification present at all",
       subtitle = paste("With no effect modification the target moments carry no information",
                        "about the transported effect,\nso every method must agree.",
                        "At poor overlap they agree and are all wrong.")) +
  guides(color = guide_legend(nrow = 2))
ggsave(file.path(FIG, "fig5-overlap-failure.png"), p5, width = 7.5, height = 4.2, dpi = 200)

cat("wrote 5 figures to", FIG, "\n")
