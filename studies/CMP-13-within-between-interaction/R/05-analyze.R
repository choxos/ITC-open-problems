## Analyze the run and evaluate the prespecified rules.
##
##   Rscript R/05-analyze.R
##
## Writes results/summary.csv, results/decision.md.

.f <- grep("^--file=", commandArgs(FALSE), value = TRUE)
STUDY <- if (length(.f)) {
  dirname(dirname(normalizePath(sub("^--file=", "", .f[1]))))
} else {
  normalizePath(".")
}
here <- function(...) file.path(STUDY, ...)

source(here("R", "01-dgm.R"))
source(here("R", "00-config.R"))
source(here("..", "_shared", "R", "performance.R"))

raw <- sort(list.files(here("results", "raw"), "^scenario-.*\\.rds$", full.names = TRUE))
stopifnot(length(raw) > 0)
res <- do.call(rbind, lapply(raw, readRDS))

## Truth for the primary estimand depends only on the pattern.
res$truth <- vapply(seq_len(nrow(res)), function(i)
  TRUTH[[res$pattern[i]]]$gW[[substr(res$par[i], 3, 3)]], numeric(1))

KEY <- c("scenario", "network", "pattern", "ipd", "n_arm", "spread")

## Two denominators, as the protocol requires.
##
## `conditional` summarizes over replicates that produced an interval.
## `unconditional` counts a replicate that failed to produce one as
## non-coverage, so a method cannot look good by failing on its hard replicates.
## Declining to report is counted separately: it is a design feature of one
## method, not a failure, and conflating the two would make the method that
## refuses to guess look like the one that crashed.
summ <- do.call(rbind, lapply(
  split(res, res[c("scenario", "method", "par")], drop = TRUE),
  function(x) {
    n_att <- nrow(x)
    n_declined <- sum(x$not_estimable %in% TRUE)
    n_failed <- sum(!is.na(x$fail))
    usable <- x[is.finite(x$est), , drop = FALSE]
    base <- performance_summary(
      est = usable$est, se = usable$se, lower = usable$lower, upper = usable$upper,
      truth = x$truth[1], n_attempted = n_att - n_declined, null = 0,
      extra = c(as.list(x[1, KEY]),
                list(method = x$method[1], par = x$par[1],
                     declined = n_declined / n_att,
                     failed = n_failed / n_att,
                     width = mean(usable$upper - usable$lower))))
    ## Unconditional coverage: failures count as misses, declines excluded from
    ## the denominator because the method never claimed an answer.
    denom <- n_att - n_declined
    hits <- sum(is.finite(usable$lower) &
                  usable$lower <= x$truth[1] & x$truth[1] <= usable$upper)
    base$coverage_uncond <- if (denom > 0) hits / denom else NA_real_
    base
  }))
rownames(summ) <- NULL
summ$cov_err_pp <- 100 * (summ$coverage - 0.95)
summ$std_bias <- summ$bias / summ$empse
summ <- summ[order(summ$scenario, summ$method, summ$par), ]
utils::write.csv(summ, here("results", "summary.csv"), row.names = FALSE)

## ----------------------------------------------------------------- the rules
inband <- function(x) x >= 0.93 & x <= 0.97
excl95 <- function(cov, mcse) abs(cov - 0.95) > 1.96 * mcse

## AMENDMENT, 2026-07-28, recorded in protocol.md section 10.
##
## The analysis splits into two regimes on an EX ANTE factor level, not on an
## observed outcome. `no-B-ipd` is the scheme in which a component appears in no
## individual-data arm, so its within-trial interaction has no within-trial
## information anywhere. There the shared and joint models are near-unidentified
## for that component: they fail to return an interval on 56% of replicates
## against 0.2% elsewhere, their model standard errors run three to ten times
## their empirical ones, and coverage tends to one because the intervals are
## enormous. Pooling that regime with the rest makes the negative controls fail
## and tells the reader nothing about either.
##
## This is a different move from the amendment in study 1 of this program, and
## the difference is the point: there the restriction was chosen by the observed
## coverage of a method, which is selection on an outcome; here it is a level of
## a factor fixed before the run. Both regimes are reported in full.
PRIMARY <- res_ipd <- c("all", "six", "four", "four-low")
prim <- summ[summ$ipd %in% PRIMARY, ]
naive <- summ[summ$ipd == "no-B-ipd", ]

sh <- prim[prim$method == "shared-info", ]
sw <- prim[prim$method == "shared-sandwich", ]
sp <- prim[prim$method == "joint-split", ]
an <- prim[prim$method == "ipd-anchored", ]

controls <- function(d) d[d$pattern %in% c("rho1", "null"), ]
disc <- c("rho0.5", "rho0", "rho-0.5", "rho-1", "between-only")

## The cluster-robust comparator is judged on its own controls before it is used
## as a comparator at all.
sandwich_valid <- all(inband(controls(sw)$coverage))

gates <- list(
  convergence = mean(prim$failed > 0.05) <= 0.10,
  denominators = all(abs(prim$coverage - prim$coverage_uncond) <= 0.01, na.rm = TRUE),
  shared_controls = all(inband(controls(sh)$coverage)),
  split_controls  = all(inband(controls(sp)$coverage)),
  anchored_controls = all(inband(controls(an)$coverage))
)
gates_pass <- all(unlist(gates))

mild <- sh[sh$pattern == "rho0.5" & sh$n_arm == 400, ]
mild_hit <- mild[mild$coverage < 0.90 & excl95(mild$coverage, mild$coverage_mcse), ]
strong <- sh[sh$pattern %in% c("rho0", "rho-1"), ]
strong_hit <- strong[strong$coverage < 0.90 & excl95(strong$coverage, strong$coverage_mcse), ]
allrho <- sh[sh$pattern %in% c("rho1", "rho0.5", "rho0", "rho-0.5", "rho-1"), ]

conclusion <- if (!gates_pass) {
  "uninformative"
} else if (nrow(mild_hit) > 0) {
  "material at mild discordance"
} else if (nrow(strong_hit) > 0) {
  "material only at strong discordance"
} else if (all(inband(allrho$coverage)) &&
           stats::median(abs(sh$std_bias[sh$pattern %in% disc]), na.rm = TRUE) < 0.10) {
  "not material"
} else {
  "uninformative"
}

## The catalog's mechanism claim, tested only where every trial supplies IPD.
allipd <- sh[sh$ipd == "all" & sh$pattern %in% disc, ]
sb <- abs(allipd$std_bias)
mech <- if (all(sb < 0.10, na.rm = TRUE)) {
  "supported: with every trial supplying individual data the shared model is unbiased"
} else if (mean(sb > 0.20, na.rm = TRUE) >= 0.5) {
  "refuted: the conflation is a property of the parameterization, not of aggregate data"
} else {
  "not supported, and short of the prespecified refutation threshold"
}

fmt <- function(x, d = 3) formatC(x, format = "f", digits = d)

## Coverage by discordance, over the primary regime.
tab <- do.call(rbind, lapply(c("rho1", "rho0.5", "rho0", "rho-0.5", "rho-1",
                               "null", "between-only", "nonlinear"), function(pt) {
  r <- function(m) {
    x <- prim[prim$method == m & prim$pattern == pt, ]
    sprintf("%s to %s", fmt(min(x$coverage, na.rm = TRUE)),
            fmt(max(x$coverage, na.rm = TRUE)))
  }
  data.frame(pattern = pt, shared = r("shared-info"),
             sandwich = r("shared-sandwich"), split = r("joint-split"),
             anchored = r("ipd-anchored"), stringsAsFactors = FALSE)
}))

nb <- function(m, p, col = "coverage") {
  x <- naive[naive$method == m & naive$par == "gWB" & naive$pattern == p, ]
  if (!nrow(x)) NA_real_ else mean(x[[col]], na.rm = TRUE)
}

L <- c(
  "# Decision", "",
  sprintf("**Conclusion: %s**", conclusion), "",
  sprintf("**Catalog mechanism claim: %s**", mech), "",
  sprintf("Prespecified in `protocol.md` section 7. %d scenarios, %d replicates each, split into a primary regime of %d scenarios in which every component has within-trial information, and %d scenarios in which one component has none. The split is on a factor level fixed before the run, not on an observed outcome.",
          length(unique(summ$scenario)), N_REP,
          length(unique(prim$scenario)), length(unique(naive$scenario))), "",
  "## Gates, primary regime", "", "| gate | pass |", "| --- | --- |",
  sprintf("| %s | %s |", names(gates), ifelse(unlist(gates), "yes", "NO")), "",
  sprintf("The cluster-robust comparator fails its own negative controls in %d of %d control scenarios (coverage %s to %s), so it is reported but not used as the status quo.",
          sum(!inband(controls(sw)$coverage)), nrow(controls(sw)),
          fmt(min(controls(sw)$coverage)), fmt(max(controls(sw)$coverage))), "",
  "## Coverage by discordance, primary regime", "",
  "| discordance | shared | shared + cluster sandwich | joint split | IPD anchored |",
  "| --- | --- | --- | --- | --- |",
  sprintf("| %s | %s | %s | %s | %s |", tab$pattern, tab$shared, tab$sandwich,
          tab$split, tab$anchored), "",
  "## The mechanism test: all 12 trials supply individual data", "",
  sprintf("CMP-13 says aggregate studies cause the pull. Across %d discordant scenario-components with complete individual data, absolute standardized bias of the shared model has median %s and maximum %s, %s of them exceed 0.20, and coverage falls as low as %s.",
          nrow(allipd), fmt(stats::median(sb), 2), fmt(max(sb), 2),
          fmt(mean(sb > 0.20), 2), fmt(min(allipd$coverage))), "",
  "The prespecified support threshold required absolute standardized bias below 0.10 everywhere, which fails. The prespecified refutation threshold required more than half above 0.20, which is not quite met. The claim is therefore not supported, and the direction of the evidence is that the conflation is a property of the parameterization rather than of the data type.", "",
  "## A component with no within-trial information", "",
  sprintf("The IPD-anchored method declined to report that component in %s of replicates. The shared and joint models are near-unidentified there: they fail to return an interval on %s of replicates against %s elsewhere.",
          fmt(mean(naive$declined[naive$method == "ipd-anchored" & naive$par == "gWB"]), 2),
          fmt(mean(naive$failed[naive$par == "gWB" & naive$method != "ipd-anchored"]), 3),
          fmt(mean(prim$failed), 3)), "",
  sprintf("In the `between-only` pattern the true within-trial interaction for that component is 0. The shared model reported a mean of %s with coverage %s; the joint split reported %s with coverage %s, its intervals so wide that coverage approaches one.",
          fmt(nb("shared-info", "between-only", "bias")), fmt(nb("shared-info", "between-only")),
          fmt(nb("joint-split", "between-only", "bias")), fmt(nb("joint-split", "between-only"))), "",
  "## Ten worst shared-model coverages, primary regime", "",
  "| network | pattern | ipd | n | spread | par | coverage | MCSE | split | anchored |",
  "| --- | --- | --- | ---: | --- | --- | ---: | ---: | ---: | ---: |")

w <- sh[order(sh$coverage), ][1:10, ]
key <- function(d, r) {
  x <- d[d$scenario == r$scenario & d$par == r$par, ]
  if (!nrow(x) || !is.finite(x$coverage[1])) "-" else fmt(x$coverage[1])
}
for (i in seq_len(nrow(w))) {
  r <- w[i, ]
  L <- c(L, sprintf("| %s | %s | %s | %d | %s | %s | %s | %s | %s | %s |",
                    r$network, r$pattern, r$ipd, r$n_arm, r$spread, r$par,
                    fmt(r$coverage), fmt(r$coverage_mcse), key(sp, r), key(an, r)))
}

writeLines(L, here("results", "decision.md"))
cat(paste(L, collapse = "\n"), "\n")
