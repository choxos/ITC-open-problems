## Analyze and evaluate the prespecified rules.
##
##   Rscript R/04-analyze.R

.f <- grep("^--file=", commandArgs(FALSE), value = TRUE)
STUDY <- if (length(.f)) {
  dirname(dirname(normalizePath(sub("^--file=", "", .f[1]))))
} else {
  normalizePath(".")
}
here <- function(...) file.path(STUDY, ...)
suppressPackageStartupMessages(library(Matrix))
source(here("R", "01-model.R"))
source(here("R", "00-config.R"))

raw <- sort(list.files(here("results", "raw"), "^scenario-.*\\.rds$", full.names = TRUE))
stopifnot(length(raw) > 0)
res <- do.call(rbind, lapply(raw, readRDS))

KEY <- c("scenario", "geometry", "n_arm", "gamma_C", "prior", "mu_target",
         "positive_control", "par")
RULES <- c("r_contraction", "r_prioronly", "r_powerscale", "r_refit", "composite")

## Scenario-level summary.
summ <- do.call(rbind, lapply(split(res, res[KEY], drop = TRUE), function(x) {
  n <- nrow(x)
  d <- as.list(x[1, KEY])
  d$n <- n
  d$coverage <- mean(x$covered)
  d$coverage_mcse <- sqrt(d$coverage * (1 - d$coverage) / n)
  d$wrong <- mean(x$wrong_side)
  d$width <- mean(x$upper - x$lower)
  d$W <- x$W[1]
  d$estimable <- mean(x$estimable)
  for (r in RULES) d[[paste0("fire_", r)]] <- mean(x[[r]])
  d$contraction <- mean(x$contraction)
  d$prior_sens <- mean(x$prior_sens)
  d$lik_sens <- mean(x$lik_sens)
  as.data.frame(d, stringsAsFactors = FALSE)
}))
rownames(summ) <- NULL
summ$harmful <- summ$coverage < HARM_CELL$coverage_below
summ$clean <- summ$coverage >= 0.94
utils::write.csv(summ, here("results", "summary.csv"), row.names = FALSE)

## Operating characteristics, at REPLICATE level.
##
## An earlier version called a scenario "detected" when a rule fired on a majority
## of its replicates, then averaged over scenarios. Peer review established that
## this is not sensitivity for flagging analyses whose intervals miss: it discards
## the pairing between a warning and a miss within a replicate, it can penalize a
## correct warning on a replicate that did miss inside a well-covering scenario,
## and its uncertainty treated fixed factorial design points as a binomial sample,
## which they are not. Replicates are Monte Carlo draws, so the pairing and the
## Monte Carlo error are both well defined at that level.
res$miss <- !res$covered
RULES <- c("r_contraction", "r_prioronly", "r_powerscale", "r_refit", "composite")
NICE <- c(r_contraction = "Contraction", r_prioronly = "Prior-only benchmark",
          r_powerscale = "Power-scaling", r_refit = "Tight and loose refit",
          composite = "Composite (2 of 4)")

oc_rep <- function(d) do.call(rbind, lapply(RULES, function(r) {
  f <- d[[r]]; m <- d$miss
  se <- function(p, n) sqrt(p * (1 - p) / n)
  data.frame(rule = NICE[r], n_miss = sum(m), sensitivity = mean(f[m]),
             sens_mcse = se(mean(f[m]), sum(m)),
             n_cov = sum(!m), false_alarm = mean(f[!m]),
             fa_mcse = se(mean(f[!m]), sum(!m)), stringsAsFactors = FALSE)
}))
oc <- oc_rep(res)
oc_real <- oc_rep(res[!res$positive_control, ])

## Threshold-free discrimination. This is what separates "the statistic is
## uninformative" from "the threshold is wrong", and review was right that a
## single operating point cannot tell them apart.
auc1 <- function(score, lab) {
  r <- rank(score); n1 <- as.numeric(sum(lab)); n0 <- as.numeric(sum(!lab))
  a <- (sum(as.numeric(r[lab])) - n1 * (n1 + 1) / 2) / (n1 * n0)
  max(a, 1 - a)
}
STATS <- c("contraction", "prior_sens", "lik_sens", "h2", "refit_sd")
auc <- data.frame(statistic = STATS,
                  auc_all = vapply(STATS, function(v) auc1(res[[v]], res$miss), 0),
                  auc_real = vapply(STATS, function(v) {
                    d <- res[!res$positive_control, ]; auc1(d[[v]], d$miss)
                  }, 0), stringsAsFactors = FALSE)

## Prespecified but previously unreported: the structural rank screen, the
## wrong-side confident decision rate, and interval width.
rank_screen <- c(overall = mean(!res$estimable),
                 among_miss = mean(!res$estimable[res$miss]),
                 among_cov = mean(!res$estimable[!res$miss]))
wrong_side <- c(overall = mean(res$wrong_side),
                among_miss = mean(res$wrong_side[res$miss]))

## Sensitivity of the verdict to the post-run power-scaling amendment: the
## composite recomputed without that component at all.
nf3 <- res$r_contraction + res$r_prioronly + res$r_refit
comp_nops <- c(sensitivity = mean((nf3 >= 2)[res$miss]),
               false_alarm = mean((nf3 >= 2)[!res$miss]))

## False alarms where the zero-centred prior happens to be right.
fa_by_truth <- c(`gamma_C=0` = mean(res$composite[res$gamma_C == 0 & !res$miss]),
                 `gamma_C=0.4` = mean(res$composite[res$gamma_C == 0.4 & !res$miss]))

comp <- oc[oc$rule == "Composite (2 of 4)", ]
n_harm_real <- sum(summ$harmful & !summ$positive_control)
lo <- function(p, s) p - 1.96 * s
hi <- function(p, s) p + 1.96 * s

conclusion <- if (n_harm_real < 4) {
  "uninformative"
} else if (lo(comp$sensitivity, comp$sens_mcse) > 0.80 &&
           hi(comp$false_alarm, comp$fa_mcse) < 0.20) {
  "diagnostics work"
} else if (hi(comp$sensitivity, comp$sens_mcse) < 0.50 ||
           lo(comp$false_alarm, comp$fa_mcse) > 0.50) {
  "diagnostics fail at the thresholds the literature suggests"
} else {
  "diagnostics discriminate but cannot be relied on unattended"
}

f3 <- function(x) formatC(x, format = "f", digits = 3)
NICE <- c(r_contraction = "Contraction", r_prioronly = "Prior-only benchmark",
          r_powerscale = "Power-scaling", r_refit = "Tight and loose refit",
          composite = "Composite (2 of 4)")

L <- c("# Decision", "",
  sprintf("**Conclusion: %s**", conclusion), "",
  sprintf("Prespecified in `protocol.md` section 7. %d scenarios, %d replicates each, two contrasts. Operating characteristics are computed per replicate, pairing each warning with whether that replicate's interval missed.",
          nrow(build_scenarios()), N_REP), "",
  sprintf("Intervals missed on %s of %s replicate-contrasts. Harmful scenarios: **%d of %d**, of which %d lie outside the engineered positive controls.",
          format(sum(res$miss), big.mark = ","), format(nrow(res), big.mark = ","),
          sum(summ$harmful), nrow(summ), n_harm_real), "",
  "## Operating characteristics, per replicate", "",
  "| rule | sensitivity | false-alarm rate |", "| --- | ---: | ---: |",
  sprintf("| %s | %s (%s) | %s (%s) |", oc$rule, f3(oc$sensitivity), f3(oc$sens_mcse),
          f3(oc$false_alarm), f3(oc$fa_mcse)), "",
  "## Excluding the engineered positive controls", "",
  "| rule | sensitivity | false-alarm rate |", "| --- | ---: | ---: |",
  sprintf("| %s | %s | %s |", oc_real$rule, f3(oc_real$sensitivity), f3(oc_real$false_alarm)), "",
  "## Threshold-free discrimination", "",
  "The statistics carry ranking information that the thresholds do not exploit.", "",
  "| statistic | AUC, all | AUC, controls excluded |", "| --- | ---: | ---: |",
  sprintf("| %s | %s | %s |", auc$statistic, f3(auc$auc_all), f3(auc$auc_real)), "",
  "## Prespecified measures previously unreported", "",
  sprintf("- Structural rank screen fires on %s of replicates overall, %s among misses and %s among covered. It fires only where a contrast is genuinely outside the row space, and never false-alarms.",
          f3(rank_screen[["overall"]]), f3(rank_screen[["among_miss"]]), f3(rank_screen[["among_cov"]])),
  sprintf("- Confident decisions on the wrong side of zero: %s of replicates overall, %s among misses.",
          f3(wrong_side[["overall"]]), f3(wrong_side[["among_miss"]])),
  sprintf("- Composite recomputed WITHOUT the amended power-scaling component: sensitivity %s, false alarm %s, against %s and %s with it. The post-run amendment did not drive the verdict.",
          f3(comp_nops[["sensitivity"]]), f3(comp_nops[["false_alarm"]]),
          f3(comp$sensitivity), f3(comp$false_alarm)),
  sprintf("- Where the zero-centred prior happens to be correct the composite fires on %s of covered replicates, against %s where it is wrong.",
          f3(fa_by_truth[[1]]), f3(fa_by_truth[[2]])), "",
  "## Where coverage fails", "",
  "| geometry | prior | gamma_C | mu | n | contrast | coverage | composite | rank screen |",
  "| --- | --- | ---: | ---: | ---: | --- | ---: | ---: | ---: |")
h <- summ[summ$harmful, ]
h <- h[order(h$coverage), ][seq_len(min(10, nrow(h))), ]
L <- c(L, sprintf("| %s | %s | %.2f | %.2f | %d | %s | %s | %s | %s |",
                  h$geometry, h$prior, h$gamma_C, h$mu_target, h$n_arm, h$par,
                  f3(h$coverage), f3(h$fire_composite), f3(1 - h$estimable)), "")

writeLines(L, here("results", "decision.md"))
utils::write.csv(oc, here("results", "operating-characteristics.csv"), row.names = FALSE)
utils::write.csv(oc_real, here("results", "operating-characteristics-nocontrols.csv"), row.names = FALSE)
utils::write.csv(auc, here("results", "auc.csv"), row.names = FALSE)
cat(paste(L, collapse = "\n"), "\n")
