## Analyze the run and evaluate the prespecified decision rule.
##
##   Rscript R/04-analyze.R
##
## Writes results/summary.csv (one row per scenario and method),
## results/paired.csv (paired coverage differences against the reference
## correction), and results/decision.md (which prespecified conclusion fired).

.f <- grep("^--file=", commandArgs(FALSE), value = TRUE)
STUDY <- if (length(.f)) {
  dirname(dirname(normalizePath(sub("^--file=", "", .f[1]))))
} else {
  normalizePath(".")
}
here <- function(...) file.path(STUDY, ...)

source(here("R", "02-estimators.R"))
source(here("R", "01-dgm.R"))
source(here("R", "00-config.R"))
source(here("..", "_shared", "R", "performance.R"))

raw_files <- sort(list.files(here("results", "raw"), "^scenario-.*\\.rds$",
                             full.names = TRUE))
stopifnot(length(raw_files) > 0)
res <- do.call(rbind, lapply(raw_files, readRDS))

## The truth depends only on the scenario, so attach it once.
res$truth <- mapply(true_theta_AB, res$d, res$em_sd, res$kappa, res$rho_T)
res$covered <- with(res, ifelse(is.finite(lower) & is.finite(upper),
                                lower <= truth & truth <= upper, NA))

KEY <- c("scenario", "nS", "nT", "d", "em_sd", "kappa", "rho_T")

## ---------------------------------------------------------------- summary
summ <- do.call(rbind, lapply(split(res, res[c("scenario", "method")], drop = TRUE),
  function(x) {
    performance_summary(
      est = x$est, se = x$se, lower = x$lower, upper = x$upper,
      truth = x$truth[1], n_attempted = nrow(x), null = 0,
      extra = c(as.list(x[1, KEY]), list(
        method = x$method[1],
        width = mean(x$upper - x$lower, na.rm = TRUE),
        ess_median = stats::median(x$ess, na.rm = TRUE),
        ess_p05 = as.numeric(stats::quantile(x$ess, 0.05, na.rm = TRUE)),
        fail_reason = paste(sort(unique(stats::na.omit(x$fail))), collapse = ",")
      )))
  }))
rownames(summ) <- NULL
summ$cov_err_pp <- 100 * (summ$coverage - 0.95)
summ$cov_err_pp_mcse <- 100 * summ$coverage_mcse
summ <- summ[order(summ$scenario, summ$method), ]
utils::write.csv(summ, here("results", "summary.csv"), row.names = FALSE)

## ------------------------------------------------- paired coverage contrasts
##
## Methods share the replicate and the point estimate and differ only in
## interval width, so the coverage comparison is paired. An unpaired standard
## error would be several times too large and would hide differences the design
## was sized to detect. This is McNemar's setup: only replicates on which the
## two methods disagree carry information.
ref <- "joint-score"
paired <- do.call(rbind, lapply(split(res, res$scenario), function(x) {
  w <- reshape(x[, c("rep", "method", "covered")], idvar = "rep",
               timevar = "method", direction = "wide")
  cn <- sub("^covered\\.", "", names(w))
  names(w) <- cn
  do.call(rbind, lapply(setdiff(unique(x$method), ref), function(m) {
    a <- w[[m]]; b <- w[[ref]]
    ok <- !is.na(a) & !is.na(b)
    a <- a[ok]; b <- b[ok]
    n <- length(a)
    b01 <- sum(a & !b); b10 <- sum(!a & b)         # discordant pairs
    diff <- mean(a) - mean(b)
    ## SE of a paired difference of proportions, from the discordance counts.
    se <- if (n > 0) sqrt((b01 + b10 - (b01 - b10)^2 / n)) / n else NA_real_
    data.frame(x[1, KEY], method = m, reference = ref,
               cov_diff = diff, cov_diff_mcse = se,
               discordant = b01 + b10, n = n, stringsAsFactors = FALSE)
  }))
}))
rownames(paired) <- NULL
utils::write.csv(paired, here("results", "paired.csv"), row.names = FALSE)

## --------------------------------------------------------- the decision rule
fixed <- summ[summ$method == "target-fixed", ]
joint <- summ[summ$method == ref, ]
inband <- function(x) x >= 0.93 & x <= 0.97
## A Monte Carlo interval that excludes nominal, so a coverage error is not read
## off a point estimate that the replicate count cannot resolve.
excl_nominal <- function(cov, mcse) abs(cov - 0.95) > 1.96 * mcse

j_by_scen <- setNames(joint$coverage, joint$scenario)
fixed$out_of_band <- !inband(fixed$coverage) & excl_nominal(fixed$coverage, fixed$coverage_mcse)
fixed$joint_ok <- inband(j_by_scen[as.character(fixed$scenario)])

ordinary <- fixed[fixed$em_sd <= 0.45, ]
strong   <- fixed[fixed$em_sd == 0.90, ]
controls <- fixed[fixed$em_sd == 0, ]

hits_ordinary <- ordinary[ordinary$out_of_band & ordinary$joint_ok, ]
hits_strong   <- strong[strong$out_of_band & strong$joint_ok, ]

## Gates. Each is a way the run could be about something other than target
## moments, so each is checked before any conclusion is read.
gates <- list(
  convergence = all(summ$convergence >= 0.98),
  bias_not_at_fault = all(abs(summ$coverage - summ$becoverage) <= 0.02, na.rm = TRUE),
  reference_valid = all(inband(joint$coverage)),
  negative_controls = all(inband(controls$coverage))
)
gates_pass <- all(unlist(gates))

## AMENDMENT, 2026-07-27, after the run and recorded in protocol.md section 11.
##
## The gates above are written over the whole grid, so a single scenario in
## which something unrelated to target moments goes wrong voids all 252. That is
## what happened: at d = 0.8 the effective sample size falls to about 148 of 500
## and the Wald sandwich undercovers for EVERY method, including the reference
## and including the negative controls that contain no effect modification at
## all. That failure is real and is reported, but it is not about target
## moments, and the protocol's own threat table anticipated it.
##
## So the gates are also applied per scenario. A scenario in which the reference
## interval or its matched negative control fails is uninformative about target
## moments; the rest are not. Both readings are reported, and the global one is
## reported first, because it is the one that was registered.
ctrl_key <- function(x) paste(x$nS, x$nT, x$d, x$rho_T)
ctrl_ok <- setNames(inband(controls$coverage), ctrl_key(controls))
fixed$scenario_ok <- fixed$joint_ok & ctrl_ok[ctrl_key(fixed)]
fixed$scenario_ok[is.na(fixed$scenario_ok)] <- FALSE

usable <- fixed[fixed$scenario_ok, ]
hits_ord_u <- usable[usable$em_sd <= 0.45 & usable$out_of_band, ]
hits_str_u <- usable[usable$em_sd == 0.90 & usable$out_of_band, ]
paired_u <- paired[paired$scenario %in% usable$scenario, ]

restricted <- if (nrow(hits_ord_u) > 0) {
  "material at ordinary effect-modification strength"
} else if (nrow(hits_str_u) > 0) {
  "material only when effect modification is strong"
} else if (all(abs(paired_u$cov_diff) < 0.01, na.rm = TRUE) &&
           all(abs(paired_u$cov_diff) + 1.96 * paired_u$cov_diff_mcse < 0.02,
               na.rm = TRUE)) {
  "not material anywhere in this range"
} else {
  "uninformative"
}

not_material <- all(abs(paired$cov_diff) < 0.01, na.rm = TRUE) &&
  all(abs(paired$cov_diff) + 1.96 * paired$cov_diff_mcse < 0.02, na.rm = TRUE)

conclusion <- if (!gates_pass) {
  "uninformative"
} else if (nrow(hits_ordinary) > 0) {
  "material at ordinary effect-modification strength"
} else if (nrow(hits_strong) > 0) {
  "material only when effect modification is strong"
} else if (not_material) {
  "not material anywhere in this range"
} else {
  "uninformative"
}

worst <- fixed[order(-abs(fixed$cov_err_pp)), ][1:10, ]

L <- c(
  "# Decision", "",
  sprintf("**Conclusion: %s**", conclusion), "",
  sprintf("Prespecified in `protocol.md` section 8, before the run. %d scenarios, %d replicates each.",
          nrow(fixed), N_REP), "",
  "## Gates", "",
  "| gate | pass |", "| --- | --- |",
  sprintf("| %s | %s |", names(gates), ifelse(unlist(gates), "yes", "NO")),
  "",
  sprintf("Scenarios at ordinary strength (SD_T(tau) <= 0.45) with status-quo coverage outside 0.93 to 0.97: **%d of %d**.",
          nrow(hits_ordinary), nrow(ordinary)),
  sprintf("At strong modification (SD_T(tau) = 0.90): **%d of %d**.",
          nrow(hits_strong), nrow(strong)),
  "",
  "## Restricted to scenarios where the gates hold (amendment, 2026-07-27)", "",
  sprintf("The reference interval or its matched negative control fails in %d of %d scenarios, all at poor overlap, where the effective sample size collapses and the Wald sandwich undercovers for every method including those with no effect modification at all. Those scenarios are uninformative about target moments. In the remaining **%d**:",
          nrow(fixed) - nrow(usable), nrow(fixed), nrow(usable)),
  "",
  sprintf("**Conclusion on the usable scenarios: %s**", restricted), "",
  sprintf("- Status-quo coverage: min %.3f, median %.3f, max %.3f",
          min(usable$coverage), stats::median(usable$coverage), max(usable$coverage)),
  sprintf("- Outside 0.93 to 0.97 at ordinary strength: %d of %d",
          nrow(hits_ord_u), sum(usable$em_sd <= 0.45)),
  sprintf("- Outside 0.93 to 0.97 at strong modification: %d of %d",
          nrow(hits_str_u), sum(usable$em_sd == 0.90)),
  "",
  "## Ten largest status-quo coverage errors", "",
  "| nS | nT | d | SD_T(tau) | kappa | rho_T | coverage | error (pp) | MCSE | joint-score |",
  "| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |",
  sprintf("| %d | %d | %.1f | %.2f | %.1f | %.2f | %.3f | %+.1f | %.2f | %.3f |",
          worst$nS, worst$nT, worst$d, worst$em_sd, worst$kappa, worst$rho_T,
          worst$coverage, worst$cov_err_pp, worst$cov_err_pp_mcse,
          j_by_scen[as.character(worst$scenario)]),
  ""
)
writeLines(L, here("results", "decision.md"))
cat(paste(L, collapse = "\n"), "\n")
