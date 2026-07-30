## ---------------------------------------------------------------------------
## Run the whole pipeline and assert the SHAPE of what comes out.
##
## THIS FILE EXISTS BECAUSE ITS OWN ABSENCE WAS THE DEFECT. `R/00-config.R` has
## said since its first line that "R/09-smoke.R runs the whole pipeline before
## anything is reported" while no such file existed. That is precisely the
## registered-but-unimplemented pattern round 1 found in E2 and the previous
## study in this programme found five times, appearing this time in the header
## of the file that describes the discipline.
##
## What it checks is not that the code runs. Every script here already runs. It
## checks the claims the protocol makes ABOUT the output, because reading asks
## whether the code says the right thing and running asks whether it does it.
##
##   Rscript R/09-smoke.R
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(MASS))
Sys.setenv(E1_NOMAIN = "1", ANALYZE_NOMAIN = "1", E2_NOMAIN = "1",
           NL_NOMAIN = "1")
source("R/04-analyze.R")
source("R/03-run-e1.R")
source("R/07-run-e2.R")

fails <- character(); n <- 0L
ok <- function(label, cond, detail = "") {
  n <<- n + 1L
  if (isTRUE(cond)) cat(sprintf("  PASS  %s\n", label))
  else { cat(sprintf("  FAIL  %s%s\n", label,
                     if (nzchar(detail)) paste0(": ", detail) else ""))
         fails <<- c(fails, label) }
  flush.console()
}

## --- the artifacts the protocol quotes must exist ---------------------------
cat("=== artifacts ===\n")
for (f in c("results/e1.rds", "results/e2.rds", "results/e2-verdict.rds",
            "results/curvature-rank.rds", "results/registered-design.json"))
  ok(sprintf("%s exists", f), file.exists(f))

d <- readRDS("results/e1.rds")
e2 <- readRDS("results/e2.rds")

## --- E1: the structural claims ----------------------------------------------
cat("\n=== E1 structure ===\n")
ok("every registered state appears", setequal(unique(d$state), STATES),
   paste(setdiff(STATES, unique(d$state)), collapse = ", "))
ok("no column is entirely missing",
   !any(vapply(d, function(z) all(is.na(z)), logical(1))),
   paste(names(d)[vapply(d, function(z) all(is.na(z)), logical(1))],
         collapse = ", "))
ok("coverage is a probability",
   all(d$coverage >= 0 & d$coverage <= 1))
ok("contraction is a ratio in (0, 1]",
   all(d$contraction > 0 & d$contraction <= 1 + 1e-9))

## THE PATIENT BUDGET, which round 1 found unequal while two places asserted it
## was equal. Checked here rather than trusted, at every state and every budget.
cat("\n=== the equal-budget claim, checked at every level ===\n")
for (tn in TOTAL_N) {
  tot <- vapply(STATES, function(st) sum(build_state(st, 1.0, tn)$n), 0)
  ok(sprintf("every state enrolls %d patients", tn),
     all(abs(tot - tn) < 1e-6),
     paste(sprintf("%s=%g", names(tot), tot), collapse = " "))
}

## THE INTERACTION PRIOR REACHES ONLY THE INTERACTIONS, which round 1 found it
## did not.
##
## THE FIRST VERSION OF THIS CHECK ASSERTED THE WRONG THING and failed, and the
## code was right. It required that changing the interaction prior leave every
## nuisance POSTERIOR variance untouched. That cannot hold and should not: the
## posterior covariance is (I + P0)^{-1}, and I couples the interactions to the
## study intercepts and main effects, so constraining one coordinate necessarily
## moves the marginal variance of every coordinate correlated with it. That is a
## property of a non-orthogonal design, not of a misplaced prior.
##
## What the fix actually guarantees, and what is checked here, is that the
## PRIOR carries the interaction scale on the interaction coordinates alone.
## Everything downstream of the likelihood is allowed to move.
cat("\n=== the interaction prior reaches only the interactions ===\n")
b <- build_design(build_state("own_ipd", 1.0, 3000L))
gi_all <- b$S + b$K + 1 + seq_len(b$K)
nuis <- seq_len(b$S + b$K + 1)
P_a <- prior_precision(b, 0.1); P_b <- prior_precision(b, 2.5)
ok("the prior is diagonal, so no coordinate borrows another's scale",
   all(P_a[upper.tri(P_a)] == 0) && all(P_a[lower.tri(P_a)] == 0))
ok("nuisance PRIOR precision does not move with the interaction scale",
   max(abs(diag(P_a)[nuis] - diag(P_b)[nuis])) < 1e-12)
ok("nuisance prior precision is the registered weak value",
   all(abs(diag(P_a)[nuis] - 1 / PRIOR_SD_NUISANCE^2) < 1e-12))
ok("interaction prior precision IS the registered factor",
   all(abs(diag(P_a)[gi_all] - 1 / 0.1^2) < 1e-9) &&
   all(abs(diag(P_b)[gi_all] - 1 / 2.5^2) < 1e-9))
f1 <- exact_fit(b, 0.1, 0, 0); f2 <- exact_fit(b, 2.5, 0, 0)
ok("the target's posterior variance moves with the interaction prior",
   abs(f1$Vpost[f1$gi, f1$gi] - f2$Vpost[f2$gi, f2$gi]) > 1e-6)
## Recorded as a fact rather than asserted away: the coupling is real and an
## analyst tightening an interaction prior IS also moving their main effects.
cat(sprintf("    (nuisance posterior variances do move, by up to %.3g, through\n",
            max(abs(diag(f1$Vpost)[nuis] - diag(f2$Vpost)[nuis]))))
cat("     likelihood coupling rather than through the prior)\n")

## --- the four controls, re-run rather than read off a saved file ------------
cat("\n=== the four registered controls ===\n")
ok("absent is prior-only", all(d$contraction[d$state == "absent"] > 0.999))
nl <- d[d$discord == 0 & d$synergy == 0 & d$prior_sd >= 0.5 &
          d$state != "absent", ]
ok("the null control does not undercover",
   min(nl$coverage) >= NOMINAL - COVER_TOL, sprintf("min %.4f", min(nl$coverage)))
over <- nl[nl$coverage > NOMINAL + COVER_TOL, ]
ok("null overcoverage is confined to the stated shrinkage mechanism",
   !nrow(over) || all(over$state == "ecological" & over$spread <= 0.6 &
                        over$post_sd > over$samp_sd),
   sprintf("%d overcovering scenarios", nrow(over)))
tt <- d[d$prior_sd == min(PRIOR_SD) & d$n == min(TOTAL_N) & d$discord == 0 &
          d$synergy == 0 & d$state != "absent", ]
bs <- tapply(tt$bias, tt$state, mean)
ok("the tight prior pulls every state toward zero", all(bs < 0),
   paste(sprintf("%s=%+.3f", names(bs), bs), collapse = " "))
ok("and hurts the least-informed state most",
   names(bs)[which.min(bs)] == "ecological",
   paste(sprintf("%s=%+.3f", names(bs), bs), collapse = " "))
byp <- tapply(d$coverage[d$state == "absent"], d$prior_sd[d$state == "absent"], max)
ok("both kinds of prior-driven parameter are present",
   min(byp) < 0.01 && max(byp) > 0.99,
   paste(sprintf("sd=%s:%.2f", names(byp), byp), collapse = " "))

## --- the outcomes compute on the real object --------------------------------
cat("\n=== the registered outcomes ===\n")
for (nm in c("overlap_table", "state_pairs", "anticorrelation", "warning_table")) {
  z <- try(get(nm)(d), silent = TRUE)
  ok(sprintf("%s computes", nm), !inherits(z, "try-error"),
     if (inherits(z, "try-error")) conditionMessage(attr(z, "condition")) else "")
  if (!inherits(z, "try-error") && is.data.frame(z))
    ok(sprintf("%s is not empty", nm), nrow(z) > 0)
}
ov <- overlap_table(d)
ok("primary 1 covers both forms of effective rank",
   all(c("target_ratio", "eff_rank") %in% ov$statistic),
   paste(ov$statistic, collapse = ", "))
ok("primary 1 compares against NOMINAL scenarios",
   all(ov$n_nominal == sum(abs(d$coverage - NOMINAL) <= COVER_TOL)),
   sprintf("%s against %d", paste(unique(ov$n_nominal), collapse = ","),
           sum(abs(d$coverage - NOMINAL) <= COVER_TOL)))

## --- THE TWO ARMS MUST AGREE ON THE ALIASING FORMULA -------------------------
## Round 6 established that both departures are exactly a shift of the target
## coefficient, and E2 was rewritten to use bias = shift - [(I+P0)^{-1} P0 th*].
## E1 reaches the same quantity by a completely different route: an exact
## Gaussian posterior mean, A %*% mean_true, with no aliasing algebra in it at
## all. If the result is right the two must coincide, and if a future repair
## reaches one arm and not the other this is what notices. That failure mode has
## occurred three times in this study.
cat("\n=== the aliasing formula, checked across both arms ===\n")
local({
  set.seed(11)
  g <- build_grid()
  g <- g[sample(nrow(g), 40), ]
  gaps <- vapply(seq_len(nrow(g)), function(i) {
    r <- g[i, ]
    b <- build_design(build_state(r$state, r$spread, r$n))
    gi <- gi_of(b)
    fit <- exact_fit(b, r$prior_sd, r$discord, r$synergy)
    shift <- r$discord + r$synergy
    th_star <- theta_true(b); th_star[gi] <- th_star[gi] + shift
    A <- solve(fit$I + prior_precision(b, r$prior_sd))
    abs(fit$bias -
        (shift - as.vector(A %*% (prior_precision(b, r$prior_sd) %*% th_star))[gi]))
  }, 0)
  ok("E1's exact bias equals E2's aliasing formula on E1's design",
     max(gaps) < 1e-10,
     sprintf("worst gap %.3e over %d scenarios, %d of them aliased",
             max(gaps), nrow(g), sum(g$discord != 0 | g$synergy != 0)))
})

## --- E2: the negative control and the registered verdict --------------------
cat("\n=== E2 ===\n")
ok("every E2 state appears", setequal(unique(e2$state), E2_STATES),
   paste(setdiff(E2_STATES, unique(e2$state)), collapse = ", "))
eq <- e2[e2$state == "curvature" & e2$sd_ratio == 1, ]
ne <- e2[e2$state == "curvature" & e2$sd_ratio > 1, ]
ok("curvature identifies nothing with equal aggregate SDs",
   nrow(eq) > 0 && !any(eq$estimable))
ok("curvature is identified with unequal aggregate SDs",
   nrow(ne) > 0 && all(ne$estimable))
v <- e2_verdict(e2)
ok("no registered separation rule fires", !isTRUE(v$withdraw_e1),
   paste(v$rules$rule[isTRUE(v$rules$separates)], collapse = "; "))
## Round 2 found the two-way share unable to separate these states by
## construction, so it is checked as a CONSTRUCTIONAL fact rather than as
## evidence, and the statistic that can actually fire is checked separately.
ok("surv_between is zero in both aggregate-only states, by construction",
   identical(v$curvature_share, 0) && identical(v$ecological_share, 0),
   sprintf("curvature %s, ecological %s",
           paste(v$curvature_share, collapse = ","),
           paste(v$ecological_share, collapse = ",")))
ok("the three-way split separates the two aggregate routes",
   isTRUE(v$surv_sd_separates),
   sprintf("curvature %s, ecological %s",
           paste(v$surv_sd_curvature, collapse = "-"),
           paste(v$surv_sd_ecological, collapse = "-")))
## ROUND 6 FLIPPED THIS. `surv_sd` was the fraction LOST when the SD contrast
## is flattened; it is now the fraction SURVIVING, so "the curvature route
## carries nothing here" reads as 1 rather than 0.
ok("the curvature route is absent from the mean-gradient state",
   all(v$surv_sd_ecological == 1))

cat(sprintf("\n%s\n", strrep("-", 70)))
if (length(fails)) {
  cat(sprintf("SMOKE TEST FAILED: %d of %d checks\n", length(fails), n))
  for (f in fails) cat("  ", f, "\n")
  quit(status = 1)
}
cat(sprintf("SMOKE TEST PASSED: %d checks. Every stage runs and every claim the\n", n))
cat("protocol makes about the shape of the output holds.\n")
