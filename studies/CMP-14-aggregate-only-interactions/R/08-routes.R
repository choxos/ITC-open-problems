## ---------------------------------------------------------------------------
## WHICH between-study differences identify a component interaction, and on which
## links. This file replaces a claim round 4 destroyed.
##
## WHAT WAS CLAIMED AND WHY IT WAS WRONG. Sections 2 and 7 said the between-study
## contrast in covariate VARIANCES is the route that exists only on a nonlinear
## link, and registered a guard asserting that equal SDs identify nothing. Round 4
## found the guard passing only because `theta_true_nl` sets every study intercept
## to the same value. Give the two aggregate studies different baseline risks and
## the information matrix goes from rank 13 to rank 14 and the target becomes
## estimable with equal SDs. The claim that variance is the unique nonlinear
## aggregate route was false, and it was verified under a restriction nobody had
## registered.
##
## WHAT IS TRUE, AND IT IS MORE GENERAL. On a curved link, ANY between-study
## heterogeneity in a nuisance parameter becomes a source of identification for the
## interaction, because the curvature makes the aggregate arm mean depend on the
## whole covariate distribution and on where the baseline sits, not just on a
## linear index. The variance is one instance. The baseline is another. There is no
## reason to expect the list to stop there, and section 9 says so.
##
## The three aggregate routes this design can exhibit, each isolated by holding the
## other two fixed:
##
##   MEAN     : studies differ in reported covariate mean. Works on ANY link; this
##              is the classical ecological route and is IDN-06's subject.
##   VARIANCE : studies differ in reported covariate SD. Nonlinear links only.
##   BASELINE : studies differ in baseline risk. Nonlinear links only.
##
## None of the three is randomized. Nobody assigns a study its case mix, its
## covariate spread, or its baseline risk, so all three carry whatever confounding
## distinguishes the populations. That is the finding the taxonomy supports, and it
## is stronger than the two-route version because it holds for more routes.
##
##   Rscript R/08-routes.R
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(MASS))
Sys.setenv(NL_NOMAIN = "1", E1_NOMAIN = "1", ANALYZE_NOMAIN = "1", E2_NOMAIN = "1")
source("R/07-run-e2.R")

## A two-aggregate-study target network in which each of the three between-study
## differences can be switched on independently. Everything not switched on is
## held exactly equal, which is what makes each row of the table an isolation
## rather than a mixture.
route_net <- function(mean_differs, sd_differs, total_n = 3000L) {
  net <- build_state_nl("curvature", spread = 0.6,
                        sd_ratio = if (sd_differs) 3.0 else 1.0, total_n)
  agd <- !as.logical(net$ipd)
  ## MEANS ARE ASSIGNED PER STUDY, NOT BY A HARDCODED ARM COUNT.
  ##
  ## This line read `rep(c(0.1, mu2), each = 2)`, which assumed the two aggregate
  ## studies had exactly two arms each. When the curvature state gained its third
  ## arm, four values were recycled into six slots: R warned, the assertions below
  ## still passed, and the two studies no longer had cleanly different means. A
  ## warning is not a failure and the guards would have kept certifying the route
  ## table against a network that was not the one described.
  mu2 <- if (mean_differs) 0.9 else 0.1
  studies <- unique(net$study[agd])
  stopifnot("the curvature state should have exactly two aggregate studies"
              = length(studies) == 2L)
  net$mu[agd] <- ifelse(net$study[agd] == studies[1], 0.1, mu2)
  net
}

route_theta <- function(b, baseline_differs) {
  th <- theta_true_nl(b)
  ## The second target study's intercept. Study order is base 1-3 then the two
  ## target studies, so the fifth intercept is the second target study's.
  if (baseline_differs) th[5] <- th[5] + 0.8
  th
}

estimable_at <- function(I, gi, tol = 1e-6) {
  u <- numeric(nrow(I)); u[gi] <- 1
  sum(abs(I %*% (MASS::ginv(I) %*% u) - u)) < tol
}

route_row <- function(label, mean_differs, sd_differs, baseline_differs) {
  net <- route_net(mean_differs, sd_differs)
  b <- build_design(net); gi <- gi_of(b)
  th <- route_theta(b, baseline_differs)
  I_logit <- logit_info(b, th)$total
  I_ident <- crossprod(b$X * sqrt(b$prec))
  data.frame(route = label, mean_differs = mean_differs,
             sd_differs = sd_differs, baseline_differs = baseline_differs,
             identity = estimable_at(I_ident, gi),
             logit = estimable_at(I_logit, gi),
             stringsAsFactors = FALSE)
}

main <- function() {
  tab <- rbind(
    route_row("none",     FALSE, FALSE, FALSE),
    route_row("mean",     TRUE,  FALSE, FALSE),
    route_row("variance", FALSE, TRUE,  FALSE),
    route_row("baseline", FALSE, FALSE, TRUE))
  cat("=== which between-study difference identifies the interaction? ===\n")
  print(tab, row.names = FALSE)

  ## THE REGISTERED PROPERTIES OF THE TABLE, asserted rather than read off it.
  ## Each is a claim the protocol makes and each stops the run if it fails.
  g <- function(r) tab[tab$route == r, ]
  stopifnot(
    ## With no between-study heterogeneity at all, nothing identifies the target,
    ## on either link. Without this the other rows measure nothing.
    "the null route identifies the target, so no row below isolates anything"
      = !g("none")$identity && !g("none")$logit,
    ## The mean route is link-agnostic: it is the classical ecological route.
    "the mean route does not work on a linear link"
      = g("mean")$identity && g("mean")$logit,
    ## The other two are nonlinear-only, which is what makes them invisible to a
    ## linear-link design such as CMU-02's.
    "the variance route is not nonlinear-only"
      = !g("variance")$identity && g("variance")$logit,
    "the baseline route is not nonlinear-only"
      = !g("baseline")$identity && g("baseline")$logit)

  n_nonlinear <- sum(!tab$identity & tab$logit)
  cat(sprintf("\nnonlinear-only routes found: %d\n", n_nonlinear))
  ## ROUND 10: THIS OUTPUT RESTORED A CLAIM THE PROTOCOL HAD REVOKED. Section 4
  ## says "any" is stronger than three fixed nonzero contrasts on one geometry
  ## can support, and this line went on printing it at every run. Same shape as
  ## the "source share" label and the "registered withdrawal rules" heading:
  ## the stored fields were repaired and the analyst-facing text was not.
  cat("The claim that VARIANCE is the unique nonlinear aggregate route is\n")
  cat(sprintf("withdrawn. Each of the %d nuisance quantities this design has identifies\n",
              nrow(tab) - 1L))
  cat("the interaction on its own on a curved link, checked at one nonzero\n")
  cat("contrast each with no general rank argument. None of these routes is\n")
  cat("randomized: nobody assigns a study its case mix, its covariate spread or\n")
  cat("its baseline risk.\n")
  saveRDS(list(table = tab, n_nonlinear_routes = n_nonlinear),
          "results/routes.rds")
  cat("\nwritten: results/routes.rds\n")
}

if (!interactive() && Sys.getenv("ROUTES_NOMAIN") == "") main()
