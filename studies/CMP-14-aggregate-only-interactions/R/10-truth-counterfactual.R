## ---------------------------------------------------------------------------
## WHAT THE WRONG TRUTH TABLE WOULD HAVE COST, computed rather than quoted.
##
## Round 6 added an ADEMP true-values table and typed into it that components 1,
## 2 and 4 have zero effect modification. `theta_true()` has never done that: it
## assigns GAMMA_W to all four interaction coordinates. Round 7 found the error
## and the protocol has since carried two numbers as evidence that it mattered,
## "up to 0.44 of coverage" and "11 reclassified scenarios", both of which were
## quoted from a reviewer rather than computed here. Round 10 pointed out that
## the provenance paragraph claims every quoted quantity is exported, and these
## two were not.
##
## So they are computed. The counterfactual re-runs the whole E1 grid under the
## truth the document WRONGLY declared, zero modification on the three background
## components, and reports how far coverage moves and how many scenarios change
## their failure label.
##
##   Rscript R/10-truth-counterfactual.R
## ---------------------------------------------------------------------------

Sys.setenv(E1_NOMAIN = "1")
source("R/03-run-e1.R")

## The declared-but-false truth: GAMMA_W on the target only. The REAL function is
## captured here rather than looked up at call time, because the counterfactual
## installs this one under that name and a lookup would recurse into itself.
theta_true_real <- theta_true
theta_true_declared <- function(b) {
  th <- theta_true_real(b)
  th[b$S + b$K + 1 + seq_len(b$K)] <- 0
  th[gi_of(b)] <- GAMMA_W
  th
}

main <- function() {
  g <- build_grid()
  real <- readRDS("results/e1.rds")
  cf <- do.call(rbind, lapply(seq_len(nrow(g)), function(i) {
    row <- g[i, ]
    b <- build_design(build_state(row$state, row$spread, row$n))
    ## Swap the truth for the declared one, keeping everything else identical.
    ## `mean_true` and `exact_fit` both read `theta_true` from the global, so the
    ## swap changes what generates the data AND what the interval must cover,
    ## which is exactly the counterfactual: the study as it would have been if the
    ## declared table had been the truth.
    assign("theta_true", theta_true_declared, envir = globalenv())
    on.exit(assign("theta_true", theta_true_real, envir = globalenv()),
            add = TRUE)
    fit <- exact_fit(b, row$prior_sd, row$discord, row$synergy)
    data.frame(scenario = row$scenario, coverage = fit$coverage,
               failed = fit$coverage < COVER_BAD)
  }))
  stopifnot("the counterfactual grid does not line up with the real one"
              = nrow(cf) == nrow(real) && all(cf$scenario == real$scenario))
  d_cov <- abs(cf$coverage - real$coverage)
  n_reclass <- sum(cf$failed != real$failed)
  cat(sprintf("max |coverage change| under the declared truth: %.6f\n", max(d_cov)))
  cat(sprintf("scenarios changing their failure label: %d of %d\n",
              n_reclass, nrow(cf)))
  saveRDS(list(max_coverage_change = max(d_cov),
               median_coverage_change = stats::median(d_cov),
               n_reclassified = n_reclass, n_scenarios = nrow(cf)),
          "results/truth-counterfactual.rds")
  cat("written: results/truth-counterfactual.rds\n")
}

if (!interactive() && Sys.getenv("CF_NOMAIN") == "") main()
