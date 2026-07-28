## ---------------------------------------------------------------------------
## Figures. Reads results/*.csv, writes manuscript/figures/*.png.
##
##   Rscript R/06-figures.R
## ---------------------------------------------------------------------------

setwd(normalizePath(file.path(dirname(sub("^--file=", "",
  grep("^--file=", commandArgs(FALSE), value = TRUE)[1])), "..")))
source("R/00-config.R")
suppressPackageStartupMessages({library(ggplot2); library(dplyr); library(tidyr)})

FIG <- "manuscript/figures"; dir.create(FIG, recursive = TRUE, showWarnings = FALSE)
rd  <- function(n) read.csv(file.path("results", paste0(n, ".csv")))
sv  <- function(p, n, w = 7, h = 4.4)
  ggsave(file.path(FIG, paste0(n, ".png")), p, width = w, height = h, dpi = 200)

th <- theme_minimal(base_size = 11) +
  theme(panel.grid.minor = element_blank(),
        strip.text = element_text(face = "bold", size = 9),
        legend.position = "bottom")

RULE_LAB <- c(flag_dic2 = "DIC < -2", flag_dic5 = "DIC < -5", flag_dic10 = "DIC < -10",
              flag_post = "95% interval excludes 0", flag_margin = "P(|gap| > eps) > 0.95")

## --- 1. power against the drift the check exists to find -----------------------
pw <- rd("power") |>
  mutate(rule = factor(RULE_LAB[rule], levels = RULE_LAB),
         net = paste0(n_studies, " studies"),
         het = ifelse(tau_re == 0, "no heterogeneity", "heterogeneity 0.15"))
sv(ggplot(pw, aes(drift, power, colour = rule, group = rule)) +
     geom_hline(yintercept = 0.8, linetype = 3, colour = "grey40") +
     geom_line() + geom_point(size = 1.2) +
     geom_ribbon(aes(ymin = lo, ymax = hi, fill = rule), alpha = 0.10, colour = NA) +
     facet_grid(het ~ net + spread, labeller = label_both) +
     scale_y_continuous(limits = c(0, 1)) +
     labs(x = expression(paste("true interaction contrast  ", gamma[A] - gamma[C])),
          y = "probability the check fires", colour = NULL, fill = NULL) + th,
   "power", w = 9, h = 5.5)

## --- 2. what a pass licenses ---------------------------------------------------
pr <- rd("pass-risk-by-shift") |> filter(rule == "flag_dic5")
sv(ggplot(pr, aes(factor(shift), risk_deployed)) +
     geom_col(fill = "grey30", width = 0.6) +
     geom_errorbar(aes(ymin = risk_deployed, ymax = hi95), width = 0.15) +
     geom_hline(yintercept = VERDICT_PASS_RISK, linetype = 2, colour = "firebrick") +
     labs(x = "target displacement along the drifting covariate (SDs)",
          y = "P(material error | the check did not fire)",
          caption = "dashed line: the registered threshold. Bars: deployment-weighted; whiskers to the upper 95% bound.") + th,
   "pass-risk")

## --- 3. the decoupling ----------------------------------------------------------
m1 <- rd("m1-bookkeeping-identity")
d3 <- pr |> transmute(shift, value = risk_deployed, what = "P(material error | passed)") |>
  bind_rows(m1 |> transmute(shift, value = pass_rate_dic5, what = "P(the check passes)"))
sv(ggplot(d3, aes(shift, value, colour = what)) +
     geom_line(linewidth = 0.9) + geom_point(size = 2) +
     scale_y_continuous(limits = c(0, 1)) +
     labs(x = "target displacement (SDs)", y = NULL, colour = NULL,
          caption = "The check reads only the network, so its pass rate is identical at every displacement by construction.") + th,
   "decoupling")

## --- 4. identification: did the data say anything? ------------------------------
m2 <- rd("m2-contraction") |>
  pivot_longer(c(contraction_A, contraction_C), names_to = "trt", values_to = "contraction") |>
  mutate(trt = ifelse(grepl("_A$", trt), "A (individual data)", "C (aggregate only)"),
         net = paste0(n_studies, " studies"),
         het = ifelse(tau_re == 0, "no heterogeneity", "heterogeneity 0.15"))
sv(ggplot(m2, aes(factor(spread), contraction, fill = trt)) +
     geom_col(position = "dodge", width = 0.7) +
     facet_grid(het ~ net) +
     scale_y_continuous(limits = c(0, 1)) +
     labs(x = "between-study covariate spread", y = "prior-posterior contraction",
          fill = NULL,
          caption = "0 means the posterior is the prior. Contraction is measured on the treatment-specific interaction for the drifting covariate.") + th,
   "contraction", h = 5)

## --- 5. strategies ---------------------------------------------------------------
st <- rd("strategy-deployed") |>
  mutate(strategy = recode(strategy, always_common = "impose the restriction",
                           always_relaxed = "relax everything",
                           check_then_relax = "check, then relax what fired"))
sv(ggplot(st, aes(shift, rmse, colour = strategy)) +
     geom_line(linewidth = 0.9) + geom_point(size = 2) +
     labs(x = "target displacement (SDs)",
          y = "RMSE of the C versus A risk difference", colour = NULL) + th,
   "strategies")

## --- 6. decision curve -----------------------------------------------------------
nb <- rd("net-benefit") |>
  pivot_longer(-threshold, names_to = "rule", values_to = "nb") |>
  mutate(rule = recode(rule, distrust_all = "distrust every analysis",
                       distrust_none = "distrust none", dic2 = "DIC < -2",
                       dic5 = "DIC < -5", dic10 = "DIC < -10",
                       posterior = "95% interval", margin = "margin rule"))
sv(ggplot(nb, aes(threshold, nb, colour = rule)) +
     geom_line(linewidth = 0.8) +
     labs(x = "action threshold: P(material error) at which commissioning individual data is worth it",
          y = "net benefit", colour = NULL) + th,
   "decision-curve", h = 4.8)

## --- 7. calibration ---------------------------------------------------------------
cl <- rd("calibration-lofo") |> filter(score == "ddic")
sv(ggplot(cl, aes(paste(factor, level), abs_error)) +
     geom_col(fill = "grey30", width = 0.65) + coord_flip() +
     labs(x = "held-out level", y = "absolute error in predicted P(material error)",
          caption = "A mapping fitted everywhere else, applied to a setting it has not seen.") + th,
   "calibration")

cat("figures written to", FIG, "\n")
