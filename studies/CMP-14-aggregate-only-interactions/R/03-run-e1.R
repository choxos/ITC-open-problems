## ---------------------------------------------------------------------------
## E1: evaluate every registered scenario. Exact, so this is arithmetic, not a
## simulation, and it finishes in seconds rather than days.
##
##   Rscript R/03-run-e1.R
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(MASS))
source("R/02-diagnostics.R")

## The registered grid, built as a full factorial so that any average over it has
## an explicit and uniform weighting. The primary outcome does not depend on that
## weighting (see R/04-analyze.R), but a summary that did would otherwise be
## reporting the shape of a grid someone chose.
##
## Two restrictions, both structural rather than convenient:
##   - Synergy acts only on arms holding components 1 and 3 together, which no
##     state but `additivity` contains, so it is varied there alone. Carrying it
##     elsewhere would add scenarios that are bit-identical to their synergy = 0
##     twins and inflate every count.
##   - Discordance acts only through aggregate rows carrying the target, which
##     only `ecological` has. Same argument.
build_grid <- function() {
  g <- expand.grid(state = STATES, spread = SPREADS, discord = DISCORD,
                   n = ARM_N, prior_sd = PRIOR_SD, synergy = SYNERGY,
                   KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g <- g[!(g$synergy != 0 & g$state != "additivity"), ]
  g <- g[!(g$discord != 0 & g$state != "ecological"), ]
  rownames(g) <- NULL
  g$scenario <- seq_len(nrow(g))
  g
}

evaluate_one <- function(row) {
  net <- build_state(row$state, row$spread, row$n)
  b   <- build_design(net)
  fit <- exact_fit(b, row$prior_sd, row$discord, row$synergy)
  d   <- all_diagnostics(b, row$prior_sd, fit)
  w   <- warnings_from(d)
  cbind(row, d, setNames(w, paste0("warn_", names(w))),
        data.frame(bias = fit$bias, post_sd = fit$post_sd,
                   samp_sd = fit$samp_sd, coverage = fit$coverage,
                   failed = fit$coverage < COVER_BAD))
}

main <- function() {
  g <- build_grid()
  cat(sprintf("E1: %d registered scenarios\n", nrow(g)))
  res <- do.call(rbind, lapply(seq_len(nrow(g)), function(i) evaluate_one(g[i, ])))
  rownames(res) <- NULL

  ## Guards that would have caught the two defects this design already survived.
  ## The absent state must be a pure prior draw, and the null control must be
  ## nominal, or the whole comparison is measuring something other than what it
  ## claims.
  abs_rows <- res[res$state == "absent", ]
  stopifnot("the absent state is not prior-only; the geometry is wrong"
            = all(abs_rows$contraction > 0.999))
  ## THE NULL CONTROL, and a correction to what it was first written to assert.
  ##
  ## The first version required nominal coverage whenever there is no discordance
  ## and no synergy, and it failed in 54 scenarios, all of them at PRIOR_SD =
  ## 0.1. That is not a defect in the design; it is the tight prior doing exactly
  ## what it was added to do. With a prior four standard deviations from the
  ## truth the posterior mean is dragged to roughly zero in EVERY state,
  ## including the one with its own randomized individual-data trial, so bias is
  ## about -0.41 whatever the evidence structure.
  ##
  ## The two failure mechanisms are therefore separated and each gets its own
  ## control. Conflating them would let a prior-induced failure be reported as
  ## evidence about information states.
  ##
  ##   null control      : no discordance, no synergy, prior not itself the
  ##                       problem. Coverage must be nominal.
  ##   prior-domination  : PRIOR_SD = 0.1, no discordance, no synergy. Coverage
  ##       positive control must collapse in every state alike, which is what
  ##                       shows the mechanism is the prior and not the geometry.
  wide <- res$prior_sd >= 0.5
  null_rows <- res[res$discord == 0 & res$synergy == 0 & wide &
                     res$state != "absent", ]
  bad <- null_rows[null_rows$coverage < 0.94, ]
  if (nrow(bad))
    stop("the null control is not nominal in ", nrow(bad), " scenarios; any ",
         "collapse elsewhere cannot be attributed to confounding")

  ## Measured before being asserted, after two guards written from expectation
  ## rather than from the numbers both failed. At the tight prior the collapse is
  ## strongest at the smallest arm size and the likelihood wins it back as n
  ## grows, which is correct behavior and not something to assert away: at
  ## n = 1000 coverage recovers to 0.94, 0.84 and 0.80. The control is therefore
  ## stated at the smallest arm size, where the prior is unambiguously in charge.
  tight <- res[res$prior_sd == min(PRIOR_SD) & res$n == min(ARM_N) &
                 res$discord == 0 & res$synergy == 0 & res$state != "absent", ]
  by_state <- tapply(tight$coverage, tight$state, max)
  if (any(by_state >= 0.94))
    stop("the tight prior does not dominate in every state at the smallest arm ",
         "size (max coverage ",
         paste(sprintf("%s=%.3f", names(by_state), by_state), collapse = ", "),
         "); the prior-domination control does not hold")

  ## THE POSITIVE CONTROL FOR THE DIAGNOSTICS. With no likelihood information at
  ## all the posterior is the prior, so the answer is right when the prior is
  ## wide and wrong when it is tight and misplaced. Both must occur, or the grid
  ## contains only one kind of prior-driven parameter and the classifier analysis
  ## has nothing to separate.
  a <- res[res$state == "absent", ]
  cov_by_prior <- tapply(a$coverage, a$prior_sd, max)
  if (!(min(cov_by_prior) < 0.01 && max(cov_by_prior) > 0.99))
    stop("the absent state does not contain both a harmless and a harmful ",
         "prior-driven parameter: coverage ",
         paste(sprintf("sd=%s:%.2f", names(cov_by_prior), cov_by_prior),
               collapse = ", "))

  saveRDS(res, "results/e1.rds")
  cat(sprintf("written: results/e1.rds  (%d rows)\n", nrow(res)))
  cat("\ncoverage by state, over the whole grid:\n")
  print(do.call(rbind, lapply(split(res, res$state), function(z) data.frame(
    state = z$state[1], n = nrow(z),
    cover_min = round(min(z$coverage), 3),
    cover_med = round(median(z$coverage), 3),
    cover_max = round(max(z$coverage), 3),
    contract_min = round(min(z$contraction), 4),
    contract_max = round(max(z$contraction), 4)))),
    row.names = FALSE)
}

if (!interactive() && Sys.getenv("E1_NOMAIN") == "") main()
