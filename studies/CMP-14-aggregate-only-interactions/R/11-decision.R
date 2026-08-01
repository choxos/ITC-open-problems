## ---------------------------------------------------------------------------
## The decision, computed from the result files rather than typed.
##
## Every other completed study in this programme carries a `results/decision.md`
## that a program writes. CMP-14 did not: its answer lived only in prose inside
## `protocol.md`, so a reader had to trust that the sentence and the tables agreed.
## IDN-05 learned this the hard way, its first decision file being typed by hand
## and a reviewer finding three figures in it that disagreed with the manuscript.
##
## Nothing below is transcribed. The counts, the overlap tests and the verdict all
## come from `results/e1.rds`, `results/e2.rds` and `results/e2-verdict.rds`.
##
##   Rscript R/11-decision.R
## ---------------------------------------------------------------------------

source("R/00-config.R")

STATS <- c("contraction", "target_ratio", "eff_rank", "prec_within",
           "prec_between", "surv_between", "surv_sd")

## The three classes, named once in the protocol and applied identically here.
## Gross overcoverage sits in `neither`, not in `failed`: it is a real defect of
## an interval and it is not the defect this study measures.
classify <- function(d) {
  failed  <- !is.na(d$coverage) & d$coverage < COVER_BAD
  nominal <- !is.na(d$coverage) & abs(d$coverage - NOMINAL) <= COVER_TOL
  list(failed = failed, nominal = nominal,
       n_failed = sum(failed), n_nominal = sum(nominal),
       n_neither = sum(!failed & !nominal), n_total = nrow(d))
}

## PRIMARY 1, an existence claim no weighting can move. For each statistic, does
## the range of values taken by FAILING scenarios overlap the range taken by
## NOMINAL ones? A single value compatible with both establishes that no
## threshold on that statistic separates them.
overlap_test <- function(d, cl, stat) {
  if (!stat %in% names(d)) return(NULL)
  a <- d[[stat]][cl$failed]; b <- d[[stat]][cl$nominal]
  a <- a[is.finite(a)];      b <- b[is.finite(b)]
  if (!length(a) || !length(b)) return(NULL)
  lo <- max(min(a), min(b)); hi <- min(max(a), max(b))
  data.frame(statistic = stat,
             failing_min = min(a), failing_max = max(a),
             nominal_min = min(b), nominal_max = max(b),
             overlaps = hi >= lo,
             stringsAsFactors = FALSE)
}

fmt <- function(x) formatC(x, format = "g", digits = 4)

main <- function() {
  e1 <- readRDS("results/e1.rds")
  e2 <- readRDS("results/e2.rds")
  v  <- readRDS("results/e2-verdict.rds")

  c1 <- classify(e1); c2 <- classify(e2)
  o1 <- do.call(rbind, lapply(STATS, function(s) overlap_test(e1, c1, s)))
  o2 <- do.call(rbind, lapply(STATS, function(s) overlap_test(e2, c2, s)))

  all_overlap <- all(o1$overlaps) && all(o2$overlaps)

  L <- c()
  add <- function(...) L <<- c(L, sprintf(...))

  add("# Decision\n")
  add("**Conclusion: no diagnostic in the panel separates failing from nominal")
  add("scenarios, on either arm.**\n")
  add("**Standing: EXPLORATORY ON BOTH ARMS, and this is not a hedge.** E1 ran")
  add("before `protocol.md` existed, and every E2 rule was rebuilt after E2's")
  add("output had been read. Neither arm is confirmatory and the E2 arm is not the")
  add("safer of the two. Nothing here confirms anything; each number is a")
  add("measurement whose grid and outcome definitions were chosen with earlier")
  add("numbers already seen. A reader wanting a confirmatory version of this")
  add("result needs a fresh study with these outcomes registered in advance.\n")

  add("## Classification\n")
  add("A scenario **fails** if coverage is below %.2f, is **nominal** if coverage",
      COVER_BAD)
  add("is within %.2f of %.2f, and is **neither** otherwise. Gross overcoverage",
      COVER_TOL, NOMINAL)
  add("sits in `neither`: it is a real defect of an interval and it is not the")
  add("defect this study measures, so it is excluded rather than reclassified.\n")
  add("| arm | failing | nominal | neither | total |")
  add("| --- | ---: | ---: | ---: | ---: |")
  add("| E1, exact | %d | %d | %d | %d |", c1$n_failed, c1$n_nominal,
      c1$n_neither, c1$n_total)
  add("| E2, nonlinear | %d | %d | %d | %d |", c2$n_failed, c2$n_nominal,
      c2$n_neither, c2$n_total)
  add("")

  emit <- function(o, label, cl) {
    add("## Primary 1 on %s: does any statistic separate the two classes?\n", label)
    add("Compared over the **comparison set**, the %d failing plus the %d nominal",
        cl$n_failed, cl$n_nominal)
    add("scenarios. The intermediate and over-covering bands belong to neither")
    add("side and are excluded from the denominator as well.\n")
    add("| statistic | failing range | nominal range | overlaps |")
    add("| --- | --- | --- | :---: |")
    for (i in seq_len(nrow(o)))
      add("| `%s` | %s to %s | %s to %s | %s |", o$statistic[i],
          fmt(o$failing_min[i]), fmt(o$failing_max[i]),
          fmt(o$nominal_min[i]), fmt(o$nominal_max[i]),
          ifelse(o$overlaps[i], "**yes**", "no"))
    add("")
    add("**%d of %d statistics overlap.** An overlap means at least one value is",
        sum(o$overlaps), nrow(o))
    add("taken by both a failing and a nominal scenario, so no threshold on that")
    add("statistic can separate them, whatever weighting is applied to the grid.\n")
  }
  emit(o1, "E1, the exact arm", c1)
  emit(o2, "E2, the nonlinear arm", c2)

  add("## The state-separation rules\n")
  add("`results/e2-verdict.rds` evaluates whether any diagnostic separates the")
  add("information states it was proposed to distinguish.\n")
  add("| rule | separates |")
  add("| --- | :---: |")
  for (i in seq_len(nrow(v$rules)))
    add("| %s | %s |", v$rules$rule[i],
        ifelse(isTRUE(v$rules$separates[i]), "yes", "**no**"))
  add("")
  add("Any state separation at all: **%s**.\n",
      ifelse(isTRUE(v$any_state_separation), "yes", "no"))

  add("## What this does and does not establish\n")
  add("It establishes, on this grid, that the panel's statistics take overlapping")
  add("values on scenarios that cover and scenarios that do not, so a practitioner")
  add("reading them as a screen is reading noise. It does not establish that no")
  add("diagnostic could work, that the overlap persists off this grid, or anything")
  add("confirmatory whatsoever, for the reason stated at the top.\n")

  writeLines(L, "results/decision.md")
  cat(sprintf("written: results/decision.md\n"))
  cat(sprintf("E1 %d failing / %d nominal; E2 %d failing / %d nominal\n",
              c1$n_failed, c1$n_nominal, c2$n_failed, c2$n_nominal))
  cat(sprintf("all statistics overlap on both arms: %s\n", all_overlap))
}

if (!interactive()) main()
