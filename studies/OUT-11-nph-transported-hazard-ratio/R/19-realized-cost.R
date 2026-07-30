## ---------------------------------------------------------------------------
## What the run ACTUALLY costs, read off the checkpoints it is writing.
##
## Budget arithmetic has produced three separate fatal findings in this protocol,
## and every fix so far has been to the arithmetic. None of them checks the
## budget against the run, because until now there was no run. This does.
##
## THE INSTRUMENT CHANGED, AND WHY.
##
## The first version read per-replicate wall clock off the gaps between
## checkpoint modification times, trimming gaps too large to be one replicate.
## That instrument cannot distinguish a slow replicate from a starved one, and
## this machine starves them. Two separate episodes proved it. An arm was once
## projected at 1.93x its budget from two replicates and corrected to 1.13-1.15x
## once contention from concurrent probes was excluded. Later, ten copies of the
## runner were alive at once after a sequence of relaunches and a foreground
## probe whose timeout orphaned its forks; load average reached 37 on eight
## cores and a replicate costing about two minutes of its own time took
## twenty-five.
##
## Neither episode is visible in a timestamp gap. And inferring contention from
## the gaps themselves cannot work: when most gaps are contended, the median is
## contended too and there is nothing to compare it against.
##
## A SYSTEM LOAD AVERAGE IS ALSO THE WRONG INSTRUMENT, which was the first
## attempted fix and it was wrong. This machine's baseline load, from the
## desktop, the browser and the file-system event daemon, sits above its core
## count with no simulation running at all, so a rule excluding gaps recorded
## above the core count would exclude every gap and report nothing.
##
## What matters is not what else the machine is doing; it is whether THIS
## replicate got the cores it asked for. `proc.time()` accumulates the CPU of the
## R process and its forked children, so R/07-run.R records elapsed and consumed
## CPU per replicate and the ratio answers that directly. A replicate that
## consumed 3.9 core-seconds per elapsed second while asking for 4 cores measured
## this job's cost. One that consumed 0.4 measured the queue.
##
##   Rscript R/19-realized-cost.R
## ---------------------------------------------------------------------------

source("R/00-config.R")
Sys.setenv(BUDGET_NOMAIN = "1"); source("R/10-budget.R")

b <- budget()
DIR <- "results/cells"

## A replicate counts as unstarved when it obtained at least this share of the
## parallelism it requested. Not tuned: 0.75 is the point below which a four-core
## bootstrap is effectively running on three, which is a different machine from
## the one the budget was measured on.
EFFICIENCY_MIN <- 0.75

costs_for <- function(tag) {
  fs <- list.files(DIR, pattern = sprintf("^%s-\\d+-rep-\\d+\\.rds$", tag),
                   full.names = TRUE)
  if (!length(fs)) return(NULL)
  rows <- lapply(fs, function(f) {
    z <- try(readRDS(f), silent = TRUE)
    if (inherits(z, "try-error") || is.null(z$cost)) return(NULL)
    data.frame(elapsed = z$cost$elapsed, cpu = z$cost$cpu,
               cores = z$cost$cores_requested)
  })
  rows <- do.call(rbind, rows)
  n_all <- length(fs)
  if (is.null(rows)) return(list(n = n_all, n_used = 0L, unstamped = n_all,
                                 starved = 0L, median = NA_real_,
                                 mean = NA_real_, eff_median = NA_real_))
  rows$efficiency <- rows$cpu / (rows$elapsed * rows$cores)
  ok <- is.finite(rows$efficiency) & rows$efficiency >= EFFICIENCY_MIN
  list(n = n_all, n_used = sum(ok), unstamped = n_all - nrow(rows),
       starved = sum(!ok),
       median = if (any(ok)) stats::median(rows$elapsed[ok]) else NA_real_,
       mean = if (any(ok)) mean(rows$elapsed[ok]) else NA_real_,
       eff_median = stats::median(rows$efficiency, na.rm = TRUE))
}

## The budgeted per-replicate wall clock for each pass, from the same object the
## protocol's runtime tables are generated from.
budgeted <- c(freq  = b$boot_h * 3600 / b$n_replicates,
              mlnmr = b$stan_h * 3600 / b$n_replicates)

cat("=== realized against budgeted per-replicate wall clock ===\n")
cat(sprintf("    a replicate counts only if it obtained >= %.0f%% of the\n",
            100 * EFFICIENCY_MIN))
cat("    parallelism it requested; a starved replicate measured the queue\n\n")
out <- list()
for (tag in c("freq", "mlnmr")) {
  g <- costs_for(tag)
  if (is.null(g)) {
    cat(sprintf("  %-6s no checkpoints yet\n", tag)); next
  }
  if (!g$n_used) {
    cat(sprintf("  %-6s %4d done, NO usable replicate: %d starved, %d unstamped\n",
                tag, g$n, g$starved, g$unstamped))
    cat(sprintf("         median efficiency %.2f\n", g$eff_median))
    cat("         An unmeasured cost is reported as unmeasured. It is NOT\n")
    cat("         estimated from starved replicates, which is what produced\n")
    cat("         this study's 1.93x projection.\n")
    out[[tag]] <- g
    next
  }
  ratio <- g$median / budgeted[[tag]]
  cat(sprintf("  %-6s %4d done  median %6.1f s  budgeted %6.1f s  ratio %.2f\n",
              tag, g$n, g$median, budgeted[[tag]], ratio))
  cat(sprintf("         %d used, %d starved, %d unstamped; median efficiency %.2f\n",
              g$n_used, g$starved, g$unstamped, g$eff_median))
  cat(sprintf("         projected pass: %5.1f h against a budgeted %5.1f h\n",
              g$median * b$n_replicates / 3600,
              budgeted[[tag]] * b$n_replicates / 3600))
  out[[tag]] <- c(g, list(budgeted = budgeted[[tag]], ratio = ratio,
                          projected_h = g$median * b$n_replicates / 3600))
}

usable <- Filter(function(z) !is.null(z$projected_h), out)
if (length(usable)) {
  proj <- sum(vapply(usable, function(z) z$projected_h, 0))
  book <- sum(budgeted[names(usable)] * b$n_replicates / 3600)
  cat(sprintf("\n  passes measured so far: %5.1f h projected against %5.1f h budgeted (%.2fx)\n",
              proj, book, proj / book))
}
if (length(out)) {
  cat("\nThe budget is NOT revised from this. It is the registered figure and the\n")
  cat("realized cost is reported beside it, the same rule the refit rate follows:\n")
  cat("a run costing more than its estimate is a fact about the estimate, and\n")
  cat("editing the estimate afterwards would destroy the only evidence of that.\n")
  cat("\nWALL CLOCK TO COMPLETION IS A DIFFERENT NUMBER and is not reported here.\n")
  cat("The figures above are what a replicate costs when it has the machine. How\n")
  cat("long the run takes on a machine that is also doing something else is a\n")
  cat("scheduling fact, not a property of the study.\n")
  saveRDS(list(realized = out, budget = b, efficiency_min = EFFICIENCY_MIN,
               measured_at = format(Sys.time())),
          "results/realized-cost.rds")
  cat("\nwritten: results/realized-cost.rds\n")
}
