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

## Operating characteristics.
##
## Sensitivity is the share of harmful scenarios in which the rule fires on a
## majority of replicates; a rule that fires on 5% of replicates in a broken
## scenario has not warned anybody. The false-warning rate is the same for clean
## scenarios. Both are macro-averaged over scenarios, so a rule cannot win by
## doing well only where scenarios are numerous.
fires <- function(v) v >= 0.5
oc <- do.call(rbind, lapply(RULES, function(r) {
  f <- fires(summ[[paste0("fire_", r)]])
  h <- summ$harmful; c0 <- summ$clean
  sens <- mean(f[h]); fwr <- mean(f[c0])
  data.frame(rule = r,
             n_harmful = sum(h), sensitivity = sens,
             sens_mcse = sqrt(sens * (1 - sens) / max(sum(h), 1)),
             n_clean = sum(c0), false_warning = fwr,
             fwr_mcse = sqrt(fwr * (1 - fwr) / max(sum(c0), 1)),
             stringsAsFactors = FALSE)
}))

## The same restricted to scenarios that are not positive controls, which is
## where the gate lives: sensitivity estimated only inside engineered failures
## would say nothing about anything else.
oc_real <- do.call(rbind, lapply(RULES, function(r) {
  s <- summ[!summ$positive_control, ]
  f <- fires(s[[paste0("fire_", r)]])
  h <- s$harmful; c0 <- s$clean
  data.frame(rule = r, n_harmful = sum(h),
             sensitivity = if (sum(h)) mean(f[h]) else NA_real_,
             n_clean = sum(c0),
             false_warning = if (sum(c0)) mean(f[c0]) else NA_real_,
             stringsAsFactors = FALSE)
}))

comp <- oc[oc$rule == "composite", ]
n_harm_real <- sum(summ$harmful & !summ$positive_control)
lo <- function(p, s) p - 1.96 * s
hi <- function(p, s) p + 1.96 * s

conclusion <- if (n_harm_real < 4) {
  "uninformative"
} else if (lo(comp$sensitivity, comp$sens_mcse) > 0.80 &&
           hi(comp$false_warning, comp$fwr_mcse) < 0.20) {
  "diagnostics work"
} else if (hi(comp$sensitivity, comp$sens_mcse) < 0.50 ||
           lo(comp$false_warning, comp$fwr_mcse) > 0.50) {
  "diagnostics fail"
} else {
  "diagnostics discriminate but cannot be relied on unattended"
}

f3 <- function(x) formatC(x, format = "f", digits = 3)
NICE <- c(r_contraction = "Contraction", r_prioronly = "Prior-only benchmark",
          r_powerscale = "Power-scaling", r_refit = "Tight and loose refit",
          composite = "Composite (2 of 4)")

L <- c("# Decision", "",
  sprintf("**Conclusion: %s**", conclusion), "",
  sprintf("Prespecified in `protocol.md` section 7. %d scenarios, %d replicates each, two contrasts.",
          nrow(build_scenarios()), N_REP), "",
  sprintf("Harmful scenarios (coverage below 0.90): **%d of %d**, of which %d are outside the engineered positive controls.",
          sum(summ$harmful), nrow(summ), n_harm_real), "",
  "## Operating characteristics, all scenarios", "",
  "| rule | sensitivity | false-warning rate |", "| --- | ---: | ---: |",
  sprintf("| %s | %s (%s) | %s (%s) |", NICE[oc$rule], f3(oc$sensitivity),
          f3(oc$sens_mcse), f3(oc$false_warning), f3(oc$fwr_mcse)), "",
  "## Excluding the engineered positive controls", "",
  "| rule | harmful n | sensitivity | clean n | false-warning rate |",
  "| --- | ---: | ---: | ---: | ---: |",
  sprintf("| %s | %d | %s | %d | %s |", NICE[oc_real$rule], oc_real$n_harmful,
          f3(oc_real$sensitivity), oc_real$n_clean, f3(oc_real$false_warning)), "",
  "## Where coverage fails", "",
  "| geometry | prior | gamma_C | mu | n | coverage | composite fires | contraction |",
  "| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |")
h <- summ[summ$harmful, ]
h <- h[order(h$coverage), ][seq_len(min(12, nrow(h))), ]
L <- c(L, sprintf("| %s | %s | %.2f | %.2f | %d | %s | %s | %s |",
                  h$geometry, h$prior, h$gamma_C, h$mu_target, h$n_arm,
                  f3(h$coverage), f3(h$fire_composite), f3(h$contraction)))
L <- c(L, "", "## The accidentally-correct prior", "",
  sprintf("Where the truth agrees with the zero-centered prior (gamma_C = 0), coverage is %s to %s and the composite fires in %s of scenarios. A prior-driven analysis is right there for the wrong reason, and a diagnostic that stays silent has not earned credit.",
          f3(min(summ$coverage[summ$gamma_C == 0])), f3(max(summ$coverage[summ$gamma_C == 0])),
          f3(mean(fires(summ$fire_composite[summ$gamma_C == 0])))), "")

writeLines(L, here("results", "decision.md"))
utils::write.csv(oc, here("results", "operating-characteristics.csv"), row.names = FALSE)
cat(paste(L, collapse = "\n"), "\n")
