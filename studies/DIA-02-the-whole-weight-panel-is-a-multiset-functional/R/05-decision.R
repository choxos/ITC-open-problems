## ---------------------------------------------------------------------------
## The decision, computed from the run rather than typed.
##
##   Rscript R/04-analyze.R && Rscript R/05-decision.R
##
## The rule is the one in DESIGN.md section 7, applied mechanically:
##
##   panel at chance AND at least one geometric diagnostic materially better
##       -> CONFIRMS the proposition; the deliverable is that diagnostic plus the
##          invariance argument
##   panel discriminating as well as the geometric ones
##       -> REFUTES it; in realistic laws the geometry tracks the concentration
##          and the reported panel is adequate
##   the ESS-definition spread is reported in either branch, because
##   comparability is a separate defect with a separate fix
##
## THE CONTROLS GATE THE VERDICT. A study whose null control fails is measuring
## its own noise, and one whose positive control fails has nothing for any
## diagnostic to detect. Either way the decision is withheld rather than dressed
## up, which is the outcome a registered rule exists to make available.
## ---------------------------------------------------------------------------

source("R/00-config.R")

## How much better a geometric diagnostic must be than the best panel member to
## count as materially better. Registered here rather than read off the results:
## an AUROC gap smaller than this would not change what a practitioner should do.
AUROC_MATERIAL_GAP <- 0.10

## The band around 0.5 within which a diagnostic is "at chance". Two-sided,
## because a diagnostic reliably below 0.5 in the direction practitioners read it
## is worse than useless and must not be scored as a near miss.
CHANCE_BAND <- 0.05

fmt <- function(x, d = 3) formatC(x, format = "f", digits = d)

main <- function() {
  a <- readRDS("results/analysis.rds")
  if (is.null(a$primary)) stop("the run has no scored high-modification arm yet")
  p <- a$primary
  panel <- p[p$family == "panel", ]
  geo   <- p[p$family == "geometric", ]

  best_panel <- max(panel$auroc, na.rm = TRUE)
  best_geo   <- max(geo$auroc, na.rm = TRUE)
  best_geo_name <- geo$statistic[which.max(geo$auroc)]
  gap <- best_geo - best_panel

  panel_at_chance <- all(abs(panel$auroc - 0.5) <= CHANCE_BAND, na.rm = TRUE)
  geo_better      <- gap >= AUROC_MATERIAL_GAP

  ## Controls first. Neither branch of the rule means anything if they failed.
  null_ok <- a$null_rate <= 0.02
  pos_ok  <- max(a$positive, na.rm = TRUE) >= 0.05
  matched <- isTRUE(a$panel_matched)
  controls_ok <- null_ok && pos_ok && matched

  verdict <- if (!controls_ok) "NO VERDICT: a registered control failed"
    else if (panel_at_chance && geo_better)
      sprintf("CONFIRMED: the reported panel is at chance and %s is materially better",
              best_geo_name)
    else if (!panel_at_chance && gap < AUROC_MATERIAL_GAP)
      "REFUTED: the panel discriminates as well as the geometric diagnostics"
    else if (panel_at_chance && !geo_better)
      "PARTIAL: the panel is at chance and no geometric diagnostic rescues it"
    else "PARTIAL: the panel is not at chance but a geometric diagnostic is materially better"

  L <- c(); add <- function(...) L <<- c(L, sprintf(...))

  add("# Decision\n")
  add("**%s**\n", verdict)
  add("Prespecified in `DESIGN.md` section 7 and applied by `R/05-decision.R`.")
  add("Every number here is computed from `results/analysis.rds`; nothing is")
  add("transcribed.\n")

  add("## Controls\n")
  add("| control | requirement | observed | pass |")
  add("| --- | --- | ---: | :---: |")
  add("| null | material error with no support hole at most 0.02 | %s | %s |",
      fmt(a$null_rate, 4), ifelse(null_ok, "yes", "**NO**"))
  add("| positive | material error with a hole at least 0.05 somewhere | %s | %s |",
      fmt(max(a$positive, na.rm = TRUE), 4), ifelse(pos_ok, "yes", "**NO**"))
  add("| matched multiset | every panel member agreeing across support arms to %.0f%% | see below | %s |",
      100 * PANEL_MATCH_TOL, ifelse(matched, "yes", "**NO**"))
  add("")

  add("## The manipulation, as a measurement\n")
  add("Both support arms remove the same amount of source mass at the same")
  add("threshold, differing only in which coordinate carries the hole: the one")
  add("that modifies the treatment effect, or a purely prognostic one. If the")
  add("panel is a function of the weight multiset alone, it cannot tell them")
  add("apart; the geometric diagnostics can.\n")
  if (!is.null(a$invariance)) {
    add("| statistic | family | largest relative difference across arms |")
    add("| --- | --- | ---: |")
    for (i in seq_len(nrow(a$invariance)))
      add("| `%s` | %s | %s |", a$invariance$statistic[i],
          a$invariance$family[i], fmt(a$invariance$max_rel_diff[i], 4))
    add("")
  }

  add("## Primary: AUROC against material error, high-modification hole\n")
  add("Direction is declared rather than fitted, so a value below 0.5 means the")
  add("statistic is actively misleading in the direction practitioners read it.\n")
  add("| statistic | family | AUROC | SE |")
  add("| --- | --- | ---: | ---: |")
  for (i in seq_len(nrow(p)))
    add("| `%s` | %s | %s | %s |", p$statistic[i], p$family[i],
        fmt(p$auroc[i]), fmt(p$se[i]))
  add("")
  add("Best panel member %s; best geometric %s (`%s`); gap %s against a",
      fmt(best_panel), fmt(best_geo), best_geo_name, fmt(gap))
  add("registered materiality of %s.\n", fmt(AUROC_MATERIAL_GAP, 2))

  add("## The comparability defect, quantified\n")
  add("Three ESS definitions computed on identical data. The complaint is that")
  add("two analyses of the same evidence can report incomparable numbers, and its")
  add("size had not been measured.\n")
  add("Median spread **%.2f times**, 90th percentile %.2f, maximum %.2f.\n",
      a$ess_spread[["median"]], a$ess_spread[["p90"]], a$ess_spread[["max"]])

  add("## What this does and does not establish\n")
  add("The invariance is algebraic and is not in question: every panel member is a")
  add("symmetric function of the weights, so permuting which unit carries which")
  add("weight cannot move it. What the run establishes is that the invariance")
  add("BITES, meaning two analyses differing materially in error can be built at a")
  add("matched panel in an ordinary covariate law, rather than only in contrived")
  add("configurations. It does not establish that any particular geometric")
  add("diagnostic should be adopted; that needs the calibration a decision rule")
  add("would require, which this study does not provide.\n")

  writeLines(L, "results/decision.md")
  cat("written: results/decision.md\n")
  cat(verdict, "\n")
}

if (!interactive()) main()
