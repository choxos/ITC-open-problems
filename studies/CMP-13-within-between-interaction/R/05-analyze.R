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

sh <- summ[summ$method == "shared-info", ]
sp <- summ[summ$method == "joint-split", ]
an <- summ[summ$method == "ipd-anchored", ]

controls <- function(d) d[d$pattern %in% c("rho1", "null"), ]
disc <- c("rho0.5", "rho0", "rho-0.5", "rho-1", "between-only")

gates <- list(
  convergence = mean(summ$failed > 0.05) <= 0.10,
  denominators = all(abs(summ$coverage - summ$coverage_uncond) <= 0.01, na.rm = TRUE),
  shared_controls = all(inband(controls(sh)$coverage)),
  split_controls  = all(inband(controls(sp)$coverage))
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

## The catalog's mechanism claim, tested on the all-IPD scenarios only.
allipd <- sh[sh$ipd == "all" & sh$pattern %in% disc, ]
sb <- abs(allipd$std_bias)
mech <- if (all(sb < 0.10, na.rm = TRUE)) {
  "supported: with every trial supplying individual data the shared model is unbiased"
} else if (mean(sb > 0.20, na.rm = TRUE) >= 0.5) {
  "refuted: the conflation is a property of the parameterization, not of aggregate data"
} else {
  "neither: bias under full individual data is real but below the refutation threshold"
}

fmt <- function(x, d = 3) formatC(x, format = "f", digits = d)

## Coverage by discordance, the headline table.
tab <- do.call(rbind, lapply(c("rho1", "rho0.5", "rho0", "rho-0.5", "rho-1",
                               "null", "between-only", "nonlinear"), function(pt) {
  r <- function(m) {
    x <- summ[summ$method == m & summ$pattern == pt, ]
    sprintf("%s to %s", fmt(min(x$coverage, na.rm = TRUE)),
            fmt(max(x$coverage, na.rm = TRUE)))
  }
  data.frame(pattern = pt, shared = r("shared-info"),
             sandwich = r("shared-sandwich"), split = r("joint-split"),
             anchored = r("ipd-anchored"), stringsAsFactors = FALSE)
}))

L <- c(
  "# Decision", "",
  sprintf("**Conclusion: %s**", conclusion), "",
  sprintf("**Catalog mechanism claim: %s**", mech), "",
  sprintf("Prespecified in `protocol.md` section 7. %d scenarios, %d replicates each.",
          length(unique(summ$scenario)), N_REP), "",
  "## Gates", "", "| gate | pass |", "| --- | --- |",
  sprintf("| %s | %s |", names(gates), ifelse(unlist(gates), "yes", "NO")), "",
  "## Coverage range by discordance, over all other factors", "",
  "| pattern | shared | shared+sandwich | joint split | IPD anchored |",
  "| --- | --- | --- | --- | --- |",
  sprintf("| %s | %s | %s | %s | %s |", tab$pattern, tab$shared, tab$sandwich,
          tab$split, tab$anchored), "",
  "## The mechanism test: all 12 trials supply individual data", "",
  sprintf("Absolute standardized bias of the shared model across %d discordant scenario-components: median %s, max %s.",
          nrow(allipd), fmt(stats::median(sb, na.rm = TRUE), 2), fmt(max(sb, na.rm = TRUE), 2)),
  sprintf("Fraction above 0.20: %s.", fmt(mean(sb > 0.20, na.rm = TRUE), 2)), "",
  "## A component with no within-trial information", "",
  sprintf("Under `no-B-ipd`, the IPD-anchored method declined to report component B in %s of replicates.",
          fmt(mean(an$declined[an$ipd == "no-B-ipd" & an$par == "gWB"]), 2)),
  local({
    ## What the other methods reported for the same component, where the
    ## anchored method refused. mean(est) = bias + truth.
    pick <- function(d) d[d$ipd == "no-B-ipd" & d$par == "gWB" &
                            d$pattern == "between-only", ]
    a <- pick(sh); b <- pick(sp)
    sprintf(paste("In the `between-only` pattern the true within-trial interaction for that",
                  "component is 0. Where the anchored method declined, the shared model",
                  "reported a mean of %s (coverage %s) and the joint split %s (coverage %s)."),
            fmt(mean(a$bias + a$truth)), fmt(mean(a$coverage)),
            fmt(mean(b$bias + b$truth)), fmt(mean(b$coverage)))
  }), "",
  "## Ten worst shared-model coverages", "",
  "| network | pattern | ipd | n | spread | par | coverage | MCSE | split | anchored |",
  "| --- | --- | --- | ---: | --- | --- | ---: | ---: | ---: | ---: |")

w <- sh[order(sh$coverage), ][1:10, ]
key <- function(d, r) {
  x <- d[d$scenario == r$scenario & d$par == r$par, ]
  if (!nrow(x)) "-" else fmt(x$coverage[1])
}
for (i in seq_len(nrow(w))) {
  r <- w[i, ]
  L <- c(L, sprintf("| %s | %s | %s | %d | %s | %s | %s | %s | %s | %s |",
                    r$network, r$pattern, r$ipd, r$n_arm, r$spread, r$par,
                    fmt(r$coverage), fmt(r$coverage_mcse), key(sp, r), key(an, r)))
}

writeLines(L, here("results", "decision.md"))
cat(paste(L, collapse = "\n"), "\n")
