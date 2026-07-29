## ---------------------------------------------------------------------------
## What the run ACTUALLY costs, read off the checkpoints it is writing.
##
## Budget arithmetic has produced three separate fatal findings in this protocol,
## and every fix so far has been to the arithmetic. None of them checks the
## budget against the run, because until now there was no run. This does.
##
## The instrument is the checkpoint files' modification times. Consecutive
## replicates within a pass differ by exactly the wall clock that replicate took,
## with no instrumentation inside the fitting code and no startup cost included.
## Gaps spanning a pause, a kill or a resume are excluded by trimming, since a
## machine that terminated the job overnight would otherwise report one replicate
## costing nine hours.
##
##   Rscript R/19-realized-cost.R
## ---------------------------------------------------------------------------

source("R/00-config.R")
Sys.setenv(BUDGET_NOMAIN = "1"); source("R/10-budget.R")

b <- budget()
DIR <- "results/cells"

gaps_for <- function(tag) {
  fs <- list.files(DIR, pattern = sprintf("^%s-\\d+-rep-\\d+\\.rds$", tag),
                   full.names = TRUE)
  if (length(fs) < 3) return(NULL)
  m <- sort(file.info(fs)$mtime)
  g <- as.numeric(diff(m), units = "secs")
  ## Trim gaps that cannot be one replicate. A resume after a kill shows up as a
  ## single enormous gap and would otherwise dominate the mean; a gap at or below
  ## zero is two files written in the same second by different workers.
  keep <- g > 0 & g < stats::quantile(g, 0.95) * 5
  list(n = length(fs), n_gaps = sum(keep), median = stats::median(g[keep]),
       mean = mean(g[keep]), dropped = sum(!keep))
}

## The budgeted per-replicate wall clock for each pass, from the same object the
## protocol's runtime tables are generated from.
budgeted <- c(freq  = b$boot_h * 3600 / b$n_replicates,
              mlnmr = b$stan_h * 3600 / b$n_replicates)

cat("=== realized against budgeted per-replicate wall clock ===\n")
out <- list()
for (tag in c("freq", "mlnmr")) {
  g <- gaps_for(tag)
  if (is.null(g)) {
    cat(sprintf("  %-6s not enough checkpoints yet\n", tag))
    next
  }
  ratio <- g$median / budgeted[[tag]]
  cat(sprintf("  %-6s %4d done  median %6.1f s  budgeted %6.1f s  ratio %.2f",
              tag, g$n, g$median, budgeted[[tag]], ratio))
  cat(sprintf("  (%d gaps used, %d dropped)\n", g$n_gaps, g$dropped))
  cat(sprintf("         projected pass: %5.1f h against a budgeted %5.1f h\n",
              g$median * b$n_replicates / 3600,
              budgeted[[tag]] * b$n_replicates / 3600))
  out[[tag]] <- c(g, list(budgeted = budgeted[[tag]], ratio = ratio,
                          projected_h = g$median * b$n_replicates / 3600))
}

if (length(out)) {
  proj <- sum(vapply(out, function(z) z$projected_h, 0))
  book <- sum(budgeted[names(out)] * b$n_replicates / 3600)
  cat(sprintf("\n  passes measured so far: %5.1f h projected against %5.1f h budgeted (%.2fx)\n",
              proj, book, proj / book))
  cat("\nThe budget is NOT revised from this. It is the registered figure and the\n")
  cat("realized cost is reported beside it, the same rule the refit rate follows:\n")
  cat("a run costing more than its estimate is a fact about the estimate, and\n")
  cat("editing the estimate afterwards would destroy the only evidence of that.\n")
  saveRDS(list(realized = out, budget = b, measured_at = format(Sys.time())),
          "results/realized-cost.rds")
  cat("\nwritten: results/realized-cost.rds\n")
}
