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

## THE REFERENCE IS OUTSIDE THE GRID, and round 1 of critique is why.
##
## This probe used to take its reference from the highest order it ran, which
## makes that order's deviation zero by construction and reduces "48 is stable"
## to "48 agrees with 64". Two coarse rules can agree with each other and both be
## wrong, which the header even said, and the code then did it anyway.
##
## Measured against an independent order 192, the registered order 48 deviates by
## 3.034e-04 on the cloglog mixed cell, THREE TIMES the registered 1e-04
## tolerance, and order 64 deviates by 2.019e-04. The self-referential reference
## hid a failure of the study's own criterion.
##
## Those deviations fell like 1/n rather than exponentially, which is what
## Gauss-Hermite does on an integrand that is not smooth: the `mixed` shape makes
## the first covariate a step function. That is now fixed at the source. R/01-dgm
## splits the integral at the jump, which is at a known point, and integrates each
## side with a rule that is exact for smooth integrands. `split_normal_rule()`
## returns 2n nodes for that one coordinate, so a `mixed` cell costs twice a
## `lognormal` cell at the same order.
##
## The split rule is validated against independent Monte Carlo rather than against
## itself: at order 48 it sits 0.80 Monte Carlo standard errors from a 4e7-draw
## estimate, so it converges to the right answer and not merely to a stable one.
REF_ORDER <- 128L

main <- function() {
  pars <- hard_pars()
  grid <- expand.grid(link = LINKS, shape = LEVELS$shape,
                      stringsAsFactors = FALSE)
  res <- do.call(rbind, lapply(seq_len(nrow(grid)), function(i) {
    lk <- grid$link[i]; sh <- grid$shape[i]
    vals <- vapply(ORDERS, function(o)
      delta_superpopulation(pars, lk, sh, MU, SIGMA, RHO, o), 0)
    ## "Stable" means every order at or above the reported one differs from an
    ## INDEPENDENT reference by less than QUAD_TOL. Independent is the whole
    ## point: no order in the grid can be its own yardstick.
    ref <- delta_superpopulation(pars, lk, sh, MU, SIGMA, RHO, REF_ORDER)
    dev <- abs(vals - ref)
    ok <- which(vapply(seq_along(ORDERS), function(j)
      all(dev[j:length(dev)] < QUAD_TOL), TRUE))
    data.frame(link = lk, shape = sh,
               stable_order = if (length(ok)) ORDERS[min(ok)] else NA_integer_,
               dev_at_16 = dev[ORDERS == 16L],
               dev_at_32 = dev[ORDERS == 32L],
               dev_at_48 = dev[ORDERS == 48L],
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
  ## The node count differs by shape now that the normal case reduces to one
  ## dimension exactly. Reporting only the product-rule figure would overstate
  ## the cost of every cell that uses the reduction, which is most of them.
  cat(sprintf("nodes at that order: %s for the mvnorm reduction, %s for the
  product rule the non-normal shapes still use\n",
              ifelse(is.na(order_needed), "n/a", format(order_needed)),
              ifelse(is.na(order_needed), "n/a", format(order_needed^3,
                                                        big.mark = ","))))

  dir.create("results", showWarnings = FALSE)
  p <- load_probes(); if (is.null(p)) p <- list()
  p$QUAD_ORDER <- list(order_needed)
  p$P1_table <- list(res)
  saveRDS(p, PROBE_FILE)
  cat("written: ", PROBE_FILE, "\n", sep = "")
}

if (!interactive() && Sys.getenv("P1_NOMAIN") == "") main()
