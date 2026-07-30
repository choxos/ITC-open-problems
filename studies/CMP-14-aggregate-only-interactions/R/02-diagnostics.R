## ---------------------------------------------------------------------------
## The four diagnostics, computed the same way for every scenario.
##
## Two are what CMP-14 asks to be made default output. One is the estimability
## screen `cpaic` already ships, included because a proposed summary has to beat
## what exists rather than beat nothing. The fourth is this study's candidate
## replacement, which is free: it reads the same information matrix the other
## three read and simply refuses to add up rows that mean different things.
## ---------------------------------------------------------------------------

source("R/01-exact.R")

## --- 1. prior-to-posterior contraction, per interaction parameter -----------
## The marginal posterior SD over the marginal prior SD for the target's own
## coordinate. Marginal, not conditional: an analyst reads a marginal interval,
## so that is what a summary describing it has to be built from.
diag_contraction <- function(fit, prior_sd)
  sqrt(fit$Vpost[fit$gi, fit$gi]) / prior_sd

## --- 2. effective likelihood rank -------------------------------------------
## Ordinary rank is binary and the failure CMP-14 describes is continuous, so
## the effective version counts directions in which the likelihood is worth more
## than the prior. Two forms are reported because they answer different
## questions and conflating them would be its own defect:
##
##   whole-model : how many directions of the full parameter vector the data
##                 dominate. This is the model-level number CMP-14 asks for.
##   target-own  : the likelihood-to-prior information ratio along the TARGET's
##                 own coordinate. A model-level count can be high while the one
##                 parameter an analyst cares about is prior-driven, so a
##                 per-parameter version is what a reader of one interaction
##                 needs.
diag_eff_rank <- function(fit) {
  er <- eff_rank(fit$I, fit$P0, thresh = EFF_RATIO_OK)
  ## Round 3: this was the posterior marginal precision minus the prior's
  ## diagonal, which credits the likelihood with identification the prior
  ## supplied. It is now the likelihood's own marginal precision, prior-free,
  ## over the prior's, which is what "the data are worth more than the prior
  ## along this coordinate" has to mean.
  ratio <- lik_marginal_precision(fit$I, fit$gi) / fit$P0[fit$gi, fit$gi]
  list(eff_rank = er$eff_rank, rank = er$rank, n_par = er$n_par,
       target_ratio = ratio)
}

## --- 3. the estimability screen already implemented --------------------------
## Whether the target coordinate is identified by the likelihood at all, which
## is what a structural rank check answers. Computed on the likelihood
## information alone, with no prior, because a prior makes everything estimable
## and that is precisely the confusion the screen exists to avoid.
diag_rank_screen <- function(fit, tol = 1e-8) {
  ev <- eigen((fit$I + t(fit$I)) / 2, symmetric = TRUE, only.values = TRUE)$values
  keep <- ev > tol * max(ev)
  ## The target is estimable if its coordinate is not in the null space: check
  ## by asking whether the generalized inverse reproduces the unit vector.
  Ip <- MASS::ginv(fit$I)
  u <- numeric(nrow(fit$I)); u[fit$gi] <- 1
  estimable <- sum(abs(fit$I %*% (Ip %*% u) - u)) < 1e-6
  list(estimable = estimable, rank = sum(keep))
}

## --- 4. the candidate replacement: where the information came from -----------
##
## THE ARGUMENT. Contraction and effective rank are functions of the information
## matrix, and an information matrix is a sum over rows. Summing is exactly what
## destroys the distinction the analyst needs, because a row from an individual-
## data arm and a row from a between-study covariate contrast contribute the
## same kind of number while carrying completely different causal warrant. The
## fix is not a better threshold on the sum; it is to not take the sum.
##
## The target's marginal likelihood precision is decomposed by refitting the
## information from each source separately and reading the same coordinate. The
## shares do not add to one in general, because sources are not orthogonal, so
## what is reported is each source's precision and the share of their total.
##
##   within  : rows from individual-data arms, where the covariate varies inside
##             a randomized comparison. Causal.
##   between : rows from aggregate arms, where the only covariate contrast is
##             across studies. Not randomized, and confounded by whatever else
##             differs between the populations.
## Round 3: the first two versions of this were both wrong, in the same way and
## for the same reason. Both computed each source's "precision" from a
## prior-regularized inverse, so a source that identifies nothing still scored
## positive, and both then took a ratio of such numbers. See
## `lik_marginal_precision` and `source_shares` in R/00-geometry.R for the
## prior-free, well-posed replacement.
diag_source_survival <- function(b, prior_sd, fit) {
  gi <- fit$gi
  info_of <- function(keep) {
    if (!any(keep)) return(matrix(0, b$p, b$p))
    crossprod(b$X[keep, , drop = FALSE] * sqrt(b$prec[keep]))
  }
  ## On an identity link the aggregate arm mean does not depend on the covariate
  ## SD at all, so flattening the SDs changes nothing and `surv_sd` is
  ## identically ONE: everything survives, because the SD contrast was carrying
  ## nothing. That is not a limitation to work around, it is the fact that makes
  ## `curvature` a nonlinear-only state, and E1 reports it as such. Under the
  ## pre-round-6 loss orientation the same fact read as zero.
  ss <- source_shares(info_of(rep(TRUE, nrow(b$X))), info_of(!b$agd),
                      info_of(rep(TRUE, nrow(b$X))), gi)
  list(within = lik_marginal_precision(info_of(!b$agd), gi),
       between = lik_marginal_precision(info_of(b$agd), gi),
       surv_between = ss$surv_between, surv_sd = ss$surv_sd,
       full = ss$full)
}

## --- every diagnostic for one scenario, in one place -------------------------
## Returned as a flat row so the analysis never has to know which diagnostic
## came from where, and so a diagnostic that silently fails to compute shows up
## as NA in a column rather than as a missing column.
all_diagnostics <- function(b, prior_sd, fit) {
  er <- diag_eff_rank(fit)
  rs <- diag_rank_screen(fit)
  ss <- diag_source_survival(b, prior_sd, fit)
  data.frame(
    contraction = diag_contraction(fit, prior_sd),
    eff_rank = er$eff_rank, eff_rank_of = er$n_par,
    target_ratio = er$target_ratio,
    estimable = rs$estimable, lik_rank = rs$rank,
    prec_within = ss$within, prec_between = ss$between, prec_full = ss$full,
    surv_between = ss$surv_between, surv_sd = ss$surv_sd,
    stringsAsFactors = FALSE)
}

## --- turning each diagnostic into a warning ---------------------------------
## The registered rules, so "the diagnostic fires" is arithmetic rather than
## interpretation. Each returns TRUE when the analyst is being warned.
## ROUND 6: THE ROW LABELED `eff_rank` WAS BUILT FROM `target_ratio`, and
## `d$eff_rank` appeared in no warning at all. So the exported table carried
## target-ratio performance under the effective-rank name and the whole-model
## count, which is the model-level summary CMP-14 asks for, controlled no
## decision. Both now exist under their own names.
warnings_from <- function(d) data.frame(
  ## The summary CMP-14 asks for, read the way such a summary is read: a
  ## parameter whose posterior is barely narrower than its prior is prior-driven.
  contraction  = d$contraction >= CONTRACT_OK,
  ## Per-parameter: the likelihood is worth less than the prior along the
  ## target's own coordinate. Named for what it is computed from.
  target_ratio = d$target_ratio < EFF_RATIO_OK,
  ## Whole-model: the data dominate the prior in fewer than every direction, so
  ## the fit is carrying at least one prior-driven coordinate somewhere. The
  ## threshold is the parameter count itself and is therefore not a tuning
  ## choice; `eff_rank_of` is that count as computed by `eff_rank()`.
  eff_rank     = d$eff_rank < d$eff_rank_of,
  ## The structural screen: the coordinate is not identified by the likelihood.
  rank_screen  = !d$estimable,
  ## The candidate: less than half the target's likelihood precision survives
  ## deleting the between-study source, so most of it is non-randomized.
  source_survival = is.na(d$surv_between) | d$surv_between < SOURCE_OK,
  stringsAsFactors = FALSE)
