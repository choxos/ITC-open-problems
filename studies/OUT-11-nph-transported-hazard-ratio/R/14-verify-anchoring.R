## ---------------------------------------------------------------------------
## Does the FLEXIBLE ML-NMR arm anchor its target-standardized curves on the
## target study's baseline?
##
## Round 5 raised a concern that the level-shift result in R/13-verify-pooling.R
## does not by itself answer. That file shows the two studies' baselines differ
## by a pure level shift, so the pooled spline has no study-specific SHAPE to
## misrepresent. It does not show that `predict(baseline = "S2", aux = "S2")`
## anchors correctly when the auxiliary parameters carry NO study index at all.
##
## The specific worry is aliasing. Treatment A is observed only in study S1 and
## treatment B only in S2, so `beta_aux[.trtA, k]` is estimated entirely from S1
## and `beta_aux[.trtB, k]` entirely from S2: the treatment index and the study
## index are perfectly confounded for the two active arms. A treatment-specific
## spline could therefore absorb its own study's baseline, and the "target-
## standardized" curve would be standardized to the target covariate law while
## anchored on the wrong baseline. The reviewer noted the section 7.1 check
## numbers are consistent with that reading, and that a near-truth B minus A can
## arise from two offsetting errors as easily as from correct transport.
##
## The check is direct: predict every treatment's target RMST and compare against
## the KNOWN truth, one treatment at a time rather than only their difference,
## because it is exactly the difference that can hide offsetting errors. The
## IPD study's own placebo RMST is printed alongside as the value a wrongly
## anchored prediction would drift toward.
##
## CHECKPOINTS PER REPLICATE, because an earlier version of this check ran as a
## scratch script with an end-of-run summary and produced nothing usable when it
## stopped partway.
##
## THE CAUSE WAS MISDIAGNOSED FOR MOST OF THIS STUDY, so it is recorded here
## rather than in a commit message. Long runs were repeatedly declared "killed by
## this machine" on the evidence that `ps` showed no matching process. The filter
## was wrong twice over: it matched `Rscript`, but the running binary is
## `exec/R`, and when a launching shell exits the R process is reparented to
## launchd rather than terminated, so a live job looks like an absent one. On
## 2026-07-28 that mistake put THREE concurrent copies of the integration probe
## on one checkpoint file, each holding its own in-memory result list and each
## overwriting the file after every fit; nothing was lost only because they were
## found before any of them finished a fit. Check for a running job with
##   ps -Ao pid,ppid,etime,command -r | grep 'exec/R'
## and never conclude a job is dead from a name-based grep alone.
##
## Per-replicate checkpointing is still right, and is now also what makes a
## duplicate launch recoverable rather than destructive.
## ---------------------------------------------------------------------------

Sys.setenv(PROBE_NOMAIN = "1")
source("R/probe-integration.R")
source("R/04-calibrate.R")

ANCHOR_OUT <- Sys.getenv("ANCHOR_OUT", "results/anchoring-check.rds")
N_ANCHOR   <- as.integer(Sys.getenv("N_ANCHOR", "4"))

## SAMPLE-SIZE MULTIPLIER, so the same check separates a STRUCTURAL bias from a
## finite-sample one. This is the diagnostic that settled STC-PH: a bias that
## survives at four and sixteen times the arm sizes is a property of the
## estimator, and one that shrinks like 1/sqrt(n) is prior influence, spline
## shrinkage, or ordinary small-sample behavior. Asserting which without
## measuring it is what this study keeps having to retract.
## Integration order may be overridden for the LARGE-SAMPLE diagnostic only. The
## question there is whether a bias shrinks with n, not what the quadrature error
## is, and a 4x-sample fit at 256 points takes over 40 minutes on this machine
## while the same fit at 64 takes about a quarter of that. The integration error
## at 64 is 0.066 months, an order of magnitude below the 1.03-month bias under
## test. BOTH sample sizes must be run at the SAME order for the comparison to
## mean anything, which is why this is an explicit override and not a default.
N_INT_OVERRIDE <- Sys.getenv("N_INT_OVERRIDE", "")
if (nzchar(N_INT_OVERRIDE)) {
  N_INT <- as.integer(N_INT_OVERRIDE)
  cat(sprintf("integration order overridden to %d for this diagnostic\n", N_INT))
}

N_MULT <- as.numeric(Sys.getenv("N_MULT", "1"))
if (N_MULT != 1) {
  N_IPD_ARM <- round(N_IPD_ARM * N_MULT)
  N_AGD_ARM <- round(N_AGD_ARM * N_MULT)
  cat(sprintf("sample-size multiplier %g: IPD %d/arm, aggregate %d/arm\n",
              N_MULT, N_IPD_ARM, N_AGD_ARM))
}

## The hardest cell for this question: both arms strongly non-proportional, so
## each treatment-specific spline has the most to absorb.
FAM <- "weibull"; KA <- 0.30; KB <- 0.30
BB  <- solve_beta_b(FAM, KB, GAMMA, unname(MARGIN_LEVELS["recommend"]), KA)

truth_rmst <- c(
  PBO = rmst_marg(TAU, MU_TGT, SD_X, placebo_arm(FAM, "tgt")),
  A   = rmst_marg(TAU, MU_TGT, SD_X, make_arm(FAM, "tgt", beta = BETA_A, kappa = KA, gamma = GAMMA)),
  B   = rmst_marg(TAU, MU_TGT, SD_X, make_arm(FAM, "tgt", beta = BB,     kappa = KB, gamma = GAMMA)))
## What a prediction anchored on the IPD study's baseline would drift toward.
wrong_anchor <- rmst_marg(TAU, MU_TGT, SD_X,
                          placebo_arm(FAM, "ipd"))

one_rep <- function(r) {
  ## sim_network reads N_IPD_ARM and N_AGD_ARM from the enclosing scope, which
  ## the multiplier above has already rescaled.
  d <- sim_network(SEED + 8100 + r, family = FAM, kappa_b = KB, gamma = GAMMA,
                   beta_b = BB, kappa_a = KA)
  f  <- fit_flex(build_net(d, N_INT))
  nd <- target_newdata(d, N_INT)
  p  <- predict(f, newdata = nd, baseline = "S2", aux = "S2", type = "rmst",
                times = TAU, level = "aggregate", summary = FALSE)
  s <- p$sims; nm <- dimnames(s)[[3]]
  get1 <- function(k) { j <- grep(sprintf(": %s]", k), nm, fixed = TRUE)
    if (length(j) != 1L) NA_real_ else mean(as.numeric(s[, , j])) }
  data.frame(rep = r, PBO = get1("PBO"), A = get1("A"), B = get1("B"))
}

## The truth this check measures against is a property of the DGM, not of any
## particular run, so it is written once to its own file. The exporter reads it
## from there. It used to be three literals typed into R/09-export-design.R,
## which is the exact shape of the defect this study keeps finding in itself.
save_truth <- function()
  saveRDS(list(truth = truth_rmst, wrong_anchor = wrong_anchor, family = FAM,
               kappa_a = KA, kappa_b = KB, beta_b = BB, tau = TAU),
          "results/anchoring-truth.rds")

## Run context travels WITH the checkpoint. Three anchoring datasets now exist at
## different arm sizes and integration orders, and a bare data frame of RMSTs
## carries nothing that says which is which.
stamp <- function(d) {
  attr(d, "n_int")  <- N_INT;     attr(d, "n_mult") <- N_MULT
  attr(d, "n_ipd")  <- N_IPD_ARM; attr(d, "n_agd")  <- N_AGD_ARM
  d
}

if (!interactive() && Sys.getenv("ANCHOR_NOMAIN") == "") {
  save_truth()
  done <- if (file.exists(ANCHOR_OUT)) readRDS(ANCHOR_OUT) else NULL
  for (r in seq_len(N_ANCHOR)) {
    if (!is.null(done) && r %in% done$rep) next
    z <- try(one_rep(r), silent = TRUE)
    if (inherits(z, "try-error")) { cat(sprintf("rep %d ERR\n", r)); next }
    done <- rbind(done, z)
    saveRDS(stamp(done), ANCHOR_OUT)                # checkpoint immediately
    cat(sprintf("rep %d  PBO %.3f  A %.3f  B %.3f\n", r, z$PBO, z$A, z$B))
    flush.console()
  }
  ## Re-stamp unconditionally, so a summary-only pass repairs a checkpoint
  ## written before the run context was recorded.
  if (!is.null(done)) saveRDS(stamp(done), ANCHOR_OUT)
  cat(sprintf("\ntruth in target : PBO %.3f  A %.3f  B %.3f   (B - A = %.3f)\n",
              truth_rmst[1], truth_rmst[2], truth_rmst[3],
              truth_rmst[3] - truth_rmst[2]))
  cat(sprintf("IPD study's own PBO RMST (a wrong anchor would drift here): %.3f\n",
              wrong_anchor))
  if (!is.null(done) && nrow(done) >= 2) {
    m  <- colMeans(done[, c("PBO", "A", "B")], na.rm = TRUE)
    se <- apply(done[, c("PBO", "A", "B")], 2, function(z)
      sd(z, na.rm = TRUE) / sqrt(sum(is.finite(z))))
    cat(sprintf("\nfitted mean     : PBO %.3f  A %.3f  B %.3f   (B - A = %.3f)\n",
                m[1], m[2], m[3], m[3] - m[2]))
    cat(sprintf("error vs truth  : PBO %+.3f  A %+.3f  B %+.3f  (B - A %+.3f)\n",
                m[1] - truth_rmst[1], m[2] - truth_rmst[2], m[3] - truth_rmst[3],
                (m[3] - m[2]) - (truth_rmst[3] - truth_rmst[2])))
    cat(sprintf("MCSE            : PBO %.3f  A %.3f  B %.3f   over %d replicates\n",
                se[1], se[2], se[3], nrow(done)))
    cat("\nRead: per-treatment errors much larger than the B - A error would mean\n")
    cat("the near-truth contrast comes from offsetting anchor errors, not transport.\n")
  }
}
