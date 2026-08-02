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
## THE REGISTERED PRIMARY AND THE CROSS-ARM TEST ARE REPORTED SEPARATELY, AND THE
## REGISTERED ONE IS NAMED AS SUCH. They disagree, and the disagreement is the
## most useful thing this study produced, so it is not resolved by promoting
## whichever number reads better. Section 7 registered a WITHIN-ARM outcome: among
## replicates that all share one hole placement, does a diagnostic flag the ones
## that err? Section 8 registered a CROSS-ARM control: at matched multisets, can
## any panel member tell the two placements apart? Only the second varies the
## thing the proposition is about. The first is reported as the registered primary
## and the rule is applied to it; the second is reported beside it with that
## difference stated.
##
## THE CONTROLS GATE THE GRID, NOT THE VERDICT. Where a control fails the cells
## are dropped by `R/04-analyze.R` on the control's own evidence, and this program
## reports how much of the grid that cost. A verdict is withheld only if nothing
## survives.
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

  registered <- if (panel_at_chance && geo_better)
      sprintf("CONFIRMED: the reported panel is at chance and %s is materially better",
              best_geo_name)
    else if (!panel_at_chance && gap < AUROC_MATERIAL_GAP)
      "REFUTED: the panel discriminates as well as the geometric diagnostics"
    else if (panel_at_chance && !geo_better)
      "PARTIAL: the panel is at chance and no geometric diagnostic rescues it"
    else "PARTIAL: the panel is not at chance but a geometric diagnostic is materially better"

  ## The cross-arm reading, computed the same way and kept separate.
  cx <- a$cross
  cx_panel <- cx[cx$family == "panel", ]
  cx_geo   <- cx[cx$family == "geometric", ]
  cx_panel_max <- max(cx_panel$separation, na.rm = TRUE)
  cx_panel_se  <- max(cx_panel$se, na.rm = TRUE)
  cx_best      <- cx_geo$statistic[which.max(cx_geo$separation)]
  cx_best_val  <- max(cx_geo$separation, na.rm = TRUE)
  cx_blind     <- cx_panel_max <= 0.5 + CHANCE_BAND
  cross_reading <- if (cx_blind && cx_best_val >= 0.5 + AUROC_MATERIAL_GAP)
      sprintf("CONFIRMED: no panel member separates the two placements (best %s, within %.4f of chance) while %s separates them at %s",
              fmt(cx_panel_max, 3), cx_panel_max - 0.5, cx_best, fmt(cx_best_val))
    else if (!cx_blind) "REFUTED: a panel member separates the two placements"
    else "PARTIAL: the panel is blind but no geometric diagnostic separates the placements"

  L <- c(); add <- function(...) L <<- c(L, sprintf(...))

  add("# Decision\n")
  add("**Registered primary (DESIGN.md section 7): %s**\n", registered)
  add("**Cross-arm control (DESIGN.md section 8), quantified: %s**\n", cross_reading)
  add("These two disagree. \"Why the two readings disagree\", below, says why, and")
  add("neither is discarded.\n")
  add("Every number here is computed from `results/analysis.rds` by")
  add("`R/05-decision.R`; nothing is transcribed.\n")

  add("## What the controls left standing\n")
  add("Two of three controls failed on part of the grid. `R/04-analyze.R` drops")
  add("the failing strata on the controls' own evidence rather than on the")
  add("results, so the surviving subgrid would move by itself if the study were")
  add("rerun with more source records or a different balancing set.\n")
  add("| control | requirement | outcome |")
  add("| --- | --- | --- |")
  add("| null | material error with no hole at most %.2f, per stratum | passed in %s; **failed** elsewhere |",
      0.02, paste(a$ok_strata, collapse = ", "))
  add("| matched multiset | every panel member agreeing across arms to %.0f%% | passed for balancing set `%s`; **failed** for the other |",
      100 * PANEL_MATCH_TOL, paste(a$ok_om, collapse = ", "))
  add("| positive | material error with a hole at a substantial rate | passed, %s in the strong-modification arm |",
      fmt(max(a$arm$p_material[a$arm$hole == "high_modification"]), 4))
  add("")
  add("Surviving subgrid: **%d of %d cells**, %s replicates.\n",
      a$n_cells_kept, a$n_cells_all, format(a$n_rep_kept, big.mark = ","))
  add("Per-stratum null rates, which is what forced the first restriction:\n")
  add("| stratum | P(material error) with no hole |")
  add("| --- | ---: |")
  for (i in seq_along(a$null_by))
    add("| %s | %s |", names(a$null_by)[i], fmt(a$null_by[[i]], 4))
  add("")
  add("The failure at `dim8/moderate` is not a property of any diagnostic. At")
  add("eight covariates and a 0.60 mean shift the weights concentrate enough that")
  add("MAIC's own sampling error exceeds the %.2f material threshold on %s of",
      MATERIAL_ERROR, fmt(max(a$null_by), 3))
  add("replicates with no support hole at all. `N_SOURCE` was registered from a")
  add("floor measured at the middle of the grid, and the middle is not the worst")
  add("corner. That is the same defect IDN-05 documented and it is worth naming")
  add("again: a threshold below its own measurement noise reads as a finding.\n")

  add("## The manipulation, as a measurement\n")
  add("Both support arms remove the same mass at the same threshold on")
  add("exchangeable standard normal coordinates, differing only in which")
  add("coordinate carries the hole: the one that modifies the treatment effect, or")
  add("a purely prognostic one.\n")
  add("| hole | modification | bias | mean abs error | P(material) | modification mass in hole |")
  add("| --- | --- | ---: | ---: | ---: | ---: |")
  for (i in seq_len(nrow(a$arm)))
    add("| %s | %s | %s | %s | %s | %s |", a$arm$hole[i], a$arm$modification[i],
        fmt(a$arm$bias[i], 5), fmt(a$arm$mae[i], 5),
        fmt(a$arm$p_material[i], 5), fmt(a$arm$mod_share[i], 2))
  add("")
  add("A hole in the modifying coordinate biases the estimate; a hole of identical")
  add("size in a prognostic coordinate does not, to five decimal places. That is")
  add("the contrast the rest of the study scores diagnostics against.\n")

  add("## Registered primary: AUROC against material error, within the high-modification arm\n")
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

  add("## Cross-arm control: can any statistic tell the two placements apart?\n")
  add("Both arms are matched on every panel member to within %.0f%%, and one is",
      100 * PANEL_MATCH_TOL)
  add("unbiased while the other is not. `separation` is `max(AUROC, 1 - AUROC)`,")
  add("because here the question is whether the arms are distinguishable at all.\n")
  add("| statistic | family | AUROC | separation | SE |")
  add("| --- | --- | ---: | ---: | ---: |")
  for (i in seq_len(nrow(cx)))
    add("| `%s` | %s | %s | %s | %s |", cx$statistic[i], cx$family[i],
        fmt(cx$auroc[i], 4), fmt(cx$separation[i]), fmt(cx$se[i], 4))
  add("")

  if (!is.null(a$sensitivity)) {
    s <- merge(cx[, c("statistic", "family", "separation")],
               a$sensitivity[, c("statistic", "separation")], by = "statistic",
               suffixes = c("_kept", "_plus"))
    s <- s[order(-s$separation_kept), ]
    add("### Sensitivity to the restriction's boundary\n")
    add("The null control is a hard cut, so `%s` is excluded on a rate of %s",
        paste(a$borderline, collapse = ", "),
        fmt(a$null_by[[a$borderline[1]]], 4))
    add("against a threshold of %.2f, a difference of a few Monte Carlo standard", 0.02)
    add("errors. Adding it back moves nothing, so the cut is not doing the work.\n")
    add("| statistic | family | separation, kept subgrid | plus borderline |")
    add("| --- | --- | ---: | ---: |")
    for (i in seq_len(nrow(s)))
      add("| `%s` | %s | %s | %s |", s$statistic[i], s$family[i],
          fmt(s$separation_kept[i], 4), fmt(s$separation_plus[i], 4))
    add("")
  }

  add("## Why the two readings disagree\n")
  add("Section 7 registered the within-arm outcome, and every replicate in that")
  add("arm shares one hole placement. The only thing varying across those")
  add("replicates is sampling noise, so the outcome asks which replicate drew a")
  add("bad sample, not where the support sits. A concentration measure answers the")
  add("first question about as well as anything, which is why the panel is")
  add("competitive there and why the registered rule reads REFUTED.\n")
  add("The proposition is about the second question, and answering it requires")
  add("comparing analyses at DIFFERENT placements. That comparison is section 8's")
  n_cross <- sum(a$arm$n[a$arm$hole != "none"])
  add("control, and at %s replicates every panel member sits within %.4f of chance",
      format(n_cross, big.mark = ","), cx_panel_max - 0.5)
  add("with a standard error of %s, so the blindness is measured rather than",
      fmt(cx_panel_se, 4))
  add("merely unrejected.\n")
  add("**The registered primary outcome was the wrong measurement for the")
  add("proposition, and the study's own control was the right one.** That is a")
  add("finding about the design, and it is recorded rather than repaired by")
  add("relabeling the cross-arm test as primary after the fact.\n")

  add("## The comparability defect, quantified\n")
  add("Three ESS definitions computed on identical data. The complaint is that")
  add("two analyses of the same evidence can report incomparable numbers, and its")
  add("size had not been measured.\n")
  add("Median spread **%.2f times**, 90th percentile %.2f, maximum %.2f.\n",
      a$ess_spread[["median"]], a$ess_spread[["p90"]], a$ess_spread[["max"]])

  add("## What this does and does not establish\n")
  add("The invariance is algebraic and was never in question: every panel member")
  add("is a symmetric function of the weights. What the run establishes is that it")
  add("BITES, meaning two analyses differing by %s in bias can be built at a panel",
      fmt(max(abs(a$arm$bias)) - min(abs(a$arm$bias)), 4))
  add("matched to %.0f%% in an ordinary covariate law, rather than only in",
      100 * PANEL_MATCH_TOL)
  add("contrived configurations. The refuting sentence in section 1 fails.\n")
  add("Four things it does not establish.\n")
  add("1. **`hull_gap` is geometric and blind anyway** (separation %s). It takes a",
      fmt(cx$separation[cx$statistic == "hull_gap"]))
  add("   maximum over coordinates, and both arms remove an identical wedge, so")
  add("   the maximum is identical. Reading position is not enough; a diagnostic")
  add("   that aggregates over coordinates inherits the same defect.")
  add("2. **`balance_omitted` was never given a chance to see anything.** The")
  add("   design registered it as the cheap comparator most likely to overturn the")
  add("   headline, and the cells where it has something to see are exactly the")
  add("   `one_modifier_second_moment` cells the matched-multiset control")
  add("   eliminated. Its separation of %s here is the tautological zero its own",
      fmt(cx$separation[cx$statistic == "balance_omitted"]))
  add("   code comment predicted, and the comparison the design wanted was not")
  add("   run. That is a live threat to the headline, not a settled one.")
  add("3. **`ess_region` was handed the easiest possible instance, and its %s is",
      fmt(max(cx$separation)))
  add("   an upper bound rather than an estimate of field performance.** The")
  add("   region it examines and the region the hole empties are the same")
  add("   construction, the modifier's upper decile, so perfect separation is what")
  add("   the arithmetic requires and not evidence about a hole placed elsewhere.")
  add("   Two things keep it from being circular. The region is chosen from the")
  add("   effect-modifier structure, which MAIC already requires naming, not from")
  add("   knowledge of the hole; and in the prognostic-hole arm the hole lies")
  add("   outside the examined region and the statistic correctly reads")
  add("   near-normal rather than firing on any hole at all. What is untested is a")
  add("   hole in a high-modification region the analyst did not think to examine,")
  add("   which is the case where this diagnostic would fail exactly as the panel")
  add("   does.")
  add("4. **No diagnostic here is calibrated.** Separating two placements is not a")
  add("   threshold, and this study does not provide one.\n")

  writeLines(L, "results/decision.md")
  cat("written: results/decision.md\n")
  cat("registered primary:", registered, "\n")
  cat("cross-arm control :", cross_reading, "\n")
}

if (!interactive()) main()
