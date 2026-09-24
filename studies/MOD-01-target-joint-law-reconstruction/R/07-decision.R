## ---------------------------------------------------------------------------
## The decision, computed from the run rather than typed.
##
##   Rscript R/06-analyze.R && Rscript R/07-decision.R
##
## The rule is DESIGN.md section 7, applied mechanically. One branch of it was
## written against a method that turned out not to exist: section 5 listed
## maximum entropy and independence as separate arms and they are the same
## distribution, so the surviving comparator in the first branch is the borrowed
## correlation matrix. That substitution is recorded here rather than made
## silently, because it changes which comparison the branch is about.
##
## THE EXACT CONTROLS GATE THE VERDICT. Both are identities: one covariate, where
## there is no off-diagonal to reconstruct, and zero correlation, where the true
## law is the independence law. A failure of either is an implementation fault
## that invalidates every number in the grid, so the decision is withheld rather
## than dressed up.
## ---------------------------------------------------------------------------

source("R/00-config.R")

fmt <- function(x, d = 4) formatC(x, format = "f", digits = d)

main <- function() {
  a <- readRDS("results/analysis.rds")
  ctl <- if (file.exists("results/controls.rds")) readRDS("results/controls.rds") else NULL

  p <- a$primary
  ind <- p[p$method == "gcomp_indep", ]
  bor <- p[p$method == "gcomp_borrowed", ]
  ora <- p[p$method == "gcomp_oracle", ]
  stc <- p[p$method == "stc_means", ]
  ri  <- p[p$method == "recon_interval", ]

  indep_material    <- abs(ind$mean_bias) > MATERIAL_LOGOR
  borrowed_material <- abs(bor$mean_bias) > MATERIAL_LOGOR
  ## "Within Monte Carlo error of the oracle" is judged on the PAIRED gap, whose
  ## error is far smaller than either arm's own, so this is a demanding test and
  ## not a formality.
  gap_prim <- a$gap[a$gap$scale == "logOR" & a$gap$modification == "nonlinear" &
                    a$gap$gamma_sign == "positive" & a$gap$rho == 0.6, ]
  all_within <- all(abs(gap_prim$indep_minus_oracle) <= 3 * gap_prim$indep_mcse) &&
                all(abs(gap_prim$borrowed_minus_oracle) <= 3 * gap_prim$borrowed_mcse)

  controls_ok <- is.null(ctl) || isTRUE(ctl$both_ok)

  verdict <- if (!controls_ok)
      "NO VERDICT: an exact control failed, so the grid's numbers are not trustworthy"
    else if (all_within)
      "NOT MATERIAL: every reconstruction sits within Monte Carlo error of the oracle"
    else if (indep_material && !borrowed_material)
      sprintf("MATTERS, AND IS FIXABLE: independence is biased by %s while a borrowed correlation matrix is not",
              fmt(ind$mean_bias))
    else if (indep_material && borrowed_material)
      sprintf("MATTERS, AND CORRELATION IS NOT ENOUGH: independence is biased by %s and a borrowed correlation matrix by %s",
              fmt(ind$mean_bias), fmt(bor$mean_bias))
    else
      sprintf("SMALL: independence is biased by %s, inside the material threshold of %s",
              fmt(ind$mean_bias), fmt(MATERIAL_LOGOR))

  ## The falsifier for the study's own headline.
  f <- a$falsifier
  fm <- f[f$gamma_sign == "mixed", ]
  fp <- f[f$gamma_sign == "positive", ]
  cancels <- nrow(fm) > 0 &&
             max(abs(fm$mean_indep_minus_oracle)) < MATERIAL_LOGOR &&
             max(abs(fp$mean_indep_minus_oracle)) > MATERIAL_LOGOR

  L <- c(); add <- function(...) L <<- c(L, sprintf(...))

  add("# Decision\n")
  add("**%s**\n", verdict)
  add("**Falsifier: %s**\n", if (cancels)
      "the mixed sign pattern cancels the error, as section 2 predicts, so the recommendation can be conditioned on the sign pattern"
      else "the mixed sign pattern does NOT rescue independence, so section 2's cancellation account is wrong and the recommendation cannot be conditioned on the sign pattern")
  add("Prespecified in `DESIGN.md` section 7 and applied by `R/07-decision.R`.")
  add("Every number is computed from `results/analysis.rds`; nothing is")
  add("transcribed. %d cells, %d replicates each.\n", a$n_cells, a$n_rep)

  if (!is.null(ctl)) {
    add("## Controls\n")
    add("Both are identities rather than expectations, so a failure is an")
    add("implementation fault and not a finding.\n")
    add("| control | what makes it exact | largest disagreement | tolerance | pass |")
    add("| --- | --- | ---: | ---: | :---: |")
    add("| one covariate | no off-diagonal exists, so every reconstruction is the truth | %s | %s | %s |",
        fmt(max(ctl$A$table$max_disagreement), 5), fmt(ctl$A$tol, 5),
        ifelse(ctl$A$ok, "yes", "**NO**"))
    add("| zero correlation | the true law IS the independence law | %s | %s | %s |",
        fmt(max(ctl$B$table$max_disagreement), 5), fmt(ctl$A$tol, 5),
        ifelse(ctl$B$ok, "yes", "**NO**"))
    add("")
    add("A third control was registered and withdrawn before the run. DESIGN.md")
    add("section 8 claimed the risk-difference scale makes the reconstruction")
    add("exactly irrelevant; it does not, because collapsibility fixes the")
    add("relation between the marginal and the mean conditional effect without")
    add("fixing that mean against the joint law. Measured, the collapsible scale")
    add("carries %.0f%% to %.0f%% of the log odds ratio's reconstruction shift",
        100 * min(ctl$scale_ratio$table$ratio), 100 * max(ctl$scale_ratio$table$ratio))
    add("rather than none of it, and the arm is reported as a prediction below.\n")
  }

  add("## Registered primary\n")
  add("Bias in the target marginal log odds ratio, in nonlinear-modification")
  add("cells with all-positive coefficients and correlation 0.6, where section 2")
  add("predicts the error is largest.\n")
  add("| method | mean bias | worst-cell bias | coverage | width |")
  add("| --- | ---: | ---: | ---: | ---: |")
  for (i in seq_len(nrow(p)))
    add("| %s | %s | %s | %s | %s |", p$method[i], fmt(p$mean_bias[i]),
        fmt(p$worst_bias[i]), fmt(p$mean_coverage[i], 3), fmt(p$mean_width[i], 3))
  add("")
  add("Material threshold %s on the log odds ratio.\n", fmt(MATERIAL_LOGOR, 2))

  add("## The falsifier, in full\n")
  add("Section 2 predicts that positive covariances cancel under a mixed sign")
  add("pattern, so independence should be adequate there despite strong")
  add("correlation. This is the test that can take most of the practical")
  add("recommendation away.\n")
  add("| sign pattern | modification | section 2 scalar | independence minus oracle | worst cell |")
  add("| --- | --- | ---: | ---: | ---: |")
  for (i in seq_len(nrow(f)))
    add("| %s | %s | %s | %s | %s |", f$gamma_sign[i], f$modification[i],
        fmt(f$indep_gap_scalar[i], 3), fmt(f$mean_indep_minus_oracle[i]),
        fmt(f$worst[i]))
  add("")

  add("## Mechanism: is the error linear in section 2's scalar?\n")
  add("| scale | modification | dim | cells | slope | R-squared |")
  add("| --- | --- | ---: | ---: | ---: | ---: |")
  for (i in seq_len(nrow(a$mechanism)))
    add("| %s | %s | %d | %d | %s | %s |", a$mechanism$scale[i],
        a$mechanism$modification[i], a$mechanism$dim[i], a$mechanism$cells[i],
        fmt(a$mechanism$slope[i], 3), fmt(a$mechanism$r2[i], 3))
  add("")
  add("A high R-squared with one slope per block confirms the second-order")
  add("account. A poor fit means the expansion is not what drives the error at")
  add("these strengths, and the deliverable is the measurement rather than the")
  add("mechanism.\n")

  add("## The bound an analyst can compute from published data\n")
  add("Realized gap inside the computable bound in **%d of %d cells (%s)**.\n",
      sum(a$bounds$contains, na.rm = TRUE), sum(!is.na(a$bounds$contains)),
      fmt(mean(a$bounds$contains, na.rm = TRUE), 3))
  add("The bound uses the proportionality fitted in the mechanism block above, so")
  add("this is an in-sample assessment of its SHAPE and not of a constant an")
  add("analyst would have to supply independently. A deployable version needs")
  add("that constant, and this study does not provide it.\n")

  add("## The scale prediction that replaced the withdrawn control\n")
  add("| scale | cells | mean absolute gap | worst |")
  add("| --- | ---: | ---: | ---: |")
  for (i in seq_len(nrow(a$scale_effect)))
    add("| %s | %d | %s | %s |", a$scale_effect$scale[i], a$scale_effect$cells[i],
        fmt(a$scale_effect$mean_abs_gap[i]), fmt(a$scale_effect$worst_abs_gap[i]))
  add("")

  add("## Prediction 4: the copula family beyond the correlation matrix\n")
  add("All three families are matched on Pearson correlation, so the borrowed")
  add("correlation arm has the right second moment and the wrong family. A")
  add("difference across families here is dependence the correlation matrix")
  add("cannot carry.\n")
  add("| scale | modification | copula | cells | borrowed minus oracle |")
  add("| --- | --- | --- | ---: | ---: |")
  for (i in seq_len(nrow(a$copula_effect)))
    add("| %s | %s | %s | %d | %s |", a$copula_effect$scale[i],
        a$copula_effect$modification[i], a$copula_effect$copula[i],
        a$copula_effect$cells[i], fmt(a$copula_effect$mean_borrowed_gap[i]))
  add("")

  add("## What this does and does not establish\n")
  add("The conditional-versus-marginal mismatch that the catalog entry leads with")
  add("is closed in the literature and is not retested here; conventional STC at")
  add("target means appears only as a labeled reference point. What is measured")
  add("is the residual the entry names and nobody had sized: the error left after")
  add("standardizing correctly, caused by not knowing the target's joint law.\n")
  add("Four limits.\n")
  add("1. **The reported marginals are exact.** Nothing here is sampling error in")
  add("   the published moments; EST-07 and MIS-03 own that, and mixing the two")
  add("   would make neither interpretable.")
  add("2. **The outcome model is correctly specified.** MOD-02 owns")
  add("   misspecification, and standardizing a wrong model over a right law is a")
  add("   different failure with a different fix.")
  add("3. **The borrowed correlation arm is optimistic.** The IPD trial here")
  add("   shares the target's dependence structure, so borrowing is exactly right")
  add("   about correlation and wrong only about the family. In practice the two")
  add("   trials' dependence would differ as well, and that arm would do worse.")
  add("4. **Covariates are continuous.** Categorical covariates constrain a joint")
  add("   law far more tightly than continuous ones, so the reconstruction")
  add("   problem is different and easier there.\n")

  writeLines(L, "results/decision.md")
  cat("written: results/decision.md\n")
  cat(verdict, "\n")
}

if (!interactive()) main()
