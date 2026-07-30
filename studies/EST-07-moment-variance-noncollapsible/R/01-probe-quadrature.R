## ---------------------------------------------------------------------------
## PROBE P1: the order at which the true estimand stops moving.
##
## The superpopulation estimand has no closed form under a curved link, so it is
## defined BY this quadrature. That makes the order part of the definition of
## truth rather than a numerical detail, and it is measured on the hardest case
## in the grid rather than assumed adequate on the easiest.
##
## OUT-11 chose an integration order without measuring it, and the order moved a
## primary contrast; it was caught only because a later round measured it. This
## probe exists so that cannot happen here.
##
## WHAT COULD CHANGE: if no order reaches QUAD_TOL on the most skewed law, the
## lognormal arm is dropped from the design and DESIGN.md section 9 records the
## number that dropped it.
##
##   Rscript R/01-probe-quadrature.R
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(MASS))
source("R/01-dgm.R")

## The hardest case the grid contains: the most curved link, the most skewed
## covariate law, and effect modification at full strength so the integrand
## varies as much as the design allows.
hard_pars <- function() list(
  alpha = -0.8, beta_prog = c(0.4, 0.3, 0.2),
  tau0 = 0.5, beta_em = c(0.6, 0.0, 0.0))

MU    <- c(0.5, 0.2, 0.0)
SIGMA <- c(1.0, 1.0, 1.0)
RHO   <- 0.3
ORDERS <- c(8L, 12L, 16L, 24L, 32L, 48L, 64L)

main <- function() {
  pars <- hard_pars()
  grid <- expand.grid(link = LINKS, shape = LEVELS$shape,
                      stringsAsFactors = FALSE)
  res <- do.call(rbind, lapply(seq_len(nrow(grid)), function(i) {
    lk <- grid$link[i]; sh <- grid$shape[i]
    vals <- vapply(ORDERS, function(o)
      delta_superpopulation(pars, lk, sh, MU, SIGMA, RHO, o), 0)
    ## The reference is the highest order run. "Stable" means every order at or
    ## above the reported one differs from it by less than QUAD_TOL, not merely
    ## that consecutive orders agree: two coarse rules can agree with each other
    ## and both be wrong.
    ref <- vals[length(vals)]
    dev <- abs(vals - ref)
    ok <- which(vapply(seq_along(ORDERS), function(j)
      all(dev[j:length(dev)] < QUAD_TOL), TRUE))
    data.frame(link = lk, shape = sh,
               stable_order = if (length(ok)) ORDERS[min(ok)] else NA_integer_,
               dev_at_16 = dev[ORDERS == 16L],
               dev_at_32 = dev[ORDERS == 32L],
               ref = ref, stringsAsFactors = FALSE)
  }))

  cat("=== P1: quadrature order at which the estimand is stable to",
      format(QUAD_TOL), "===\n")
  print(res, row.names = FALSE, digits = 6)

  unstable <- res[is.na(res$stable_order), ]
  if (nrow(unstable)) {
    cat("\nNO STABLE ORDER for:\n")
    print(unstable[, c("link", "shape")], row.names = FALSE)
    cat("DESIGN.md section 10 says the affected covariate arm is dropped and\n",
        "the number that dropped it is recorded. That is a design change and\n",
        "it is not made silently here.\n", sep = "")
  }

  ## The registered order is the largest requirement over the whole grid: one
  ## order for the study, so no cell integrates more coarsely than another and a
  ## between-cell difference cannot come from the rule.
  order_needed <- if (all(is.na(res$stable_order))) NA_integer_ else
    max(res$stable_order, na.rm = TRUE)
  cat(sprintf("\nregistered quadrature order: %s\n",
              ifelse(is.na(order_needed), "NONE", order_needed)))
  cat(sprintf("node count at that order, 3 covariates: %s\n",
              ifelse(is.na(order_needed), "n/a", format(order_needed^3))))

  dir.create("results", showWarnings = FALSE)
  p <- load_probes(); if (is.null(p)) p <- list()
  p$QUAD_ORDER <- list(order_needed)
  p$P1_table <- list(res)
  saveRDS(p, PROBE_FILE)
  cat("written: ", PROBE_FILE, "\n", sep = "")
}

if (!interactive() && Sys.getenv("P1_NOMAIN") == "") main()
