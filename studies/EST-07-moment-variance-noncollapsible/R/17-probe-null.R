## ---------------------------------------------------------------------------
## PROBE P7: the null control, measured rather than asserted.
##
## ROUND 2 OF CRITIQUE, severity fatal. The protocol registered a control that
## said: with no effect modification, beta_EM = 0, the omitted variance is exactly
## zero at every nT AND ON EVERY SCALE, because the estimand no longer depends on
## the target law. A run that violated it was to be treated as an implementation
## defect in the source variance.
##
## THAT IS FALSE ON BOTH CURVED LINKS, and it is false for the reason this study
## exists. With beta_EM = 0 the conditional contrast is constant in x, but the
## MARGINAL contrast is
##
##   Delta(F_T) = g( int mu_1 dF_T ) - g( int mu_0 dF_T ),
##
## and with nonzero prognostic coefficients the two integrals still depend on the
## target covariate law. That is non-collapsibility itself. Only the identity link
## is collapsible here, and only there does the gradient vanish.
##
## So the registered control would have been FAILED BY A CORRECT IMPLEMENTATION on
## logit and cloglog, and the failure would have been read as a bug in the source
## variance. This probe replaces the assertion with a measurement, and the
## protocol quotes the measurement.
##
## WHAT IT ALSO SHOWS, and this is a finding rather than a repair: target-moment
## uncertainty does not need effect modification to bite. The catalog entry frames
## the problem as one about effect modifiers. On a curved link it is not.
##
##   Rscript R/17-probe-null.R
## ---------------------------------------------------------------------------

source("R/05-estimators.R")

main <- function() {
  probes_done()
  pm <- population_means(shape = "mvnorm")
  ## beta_EM set to exactly zero: no effect modification anywhere, in either
  ## population, which is the condition the control names.
  pars <- make_pars(0)
  pars$beta_em <- rep(0, N_COVARIATE)

  res <- do.call(rbind, lapply(LINKS, function(lk) {
    g <- delta_gradient(pm$target, rep(1, N_COVARIATE), pars, lk, "mvnorm",
                        0.3, QUAD_ORDER)
    data.frame(link = lk, max_abs_gradient = max(abs(g)),
               vanishes = max(abs(g)) < NULL_TOL, stringsAsFactors = FALSE)
  }))

  cat("=== P7: does the estimand stop depending on the target law when",
      "beta_EM = 0? ===\n\n")
  print(res, row.names = FALSE, digits = 4)

  ## THE CONTROL, as it can honestly be stated: the gradient vanishes on the
  ## COLLAPSIBLE link and on no other. A run where the identity gradient is
  ## nonzero is an implementation defect; a run where the curved ones are nonzero
  ## is the subject of the study.
  ident_ok <- res$vanishes[res$link == "identity"]
  curved_nonzero <- all(!res$vanishes[res$link != "identity"])
  ok <- isTRUE(ident_ok) && isTRUE(curved_nonzero)
  cat(sprintf("\nidentity vanishes: %s;  both curved links do not: %s -> %s\n",
              ident_ok, curved_nonzero,
              if (ok) "control holds in the only form that is true"
              else "CONTROL FAILED"))

  p <- load_probes()
  p$P7_table <- list(res)
  p$P7_ok <- list(ok)
  saveRDS(p, PROBE_FILE)
  cat(sprintf("written: %s\n", PROBE_FILE))
}

if (!interactive() && Sys.getenv("P7_NOMAIN") == "") main()
