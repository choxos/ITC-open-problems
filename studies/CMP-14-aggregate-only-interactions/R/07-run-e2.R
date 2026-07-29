## ---------------------------------------------------------------------------
## E2: does E1's conclusion survive a nonlinear link?
##
## Asymptotic, not fitted and not exact. A logistic likelihood is not conjugate,
## so the posterior has no closed form; what is closed form is the Fisher
## information, and from it the large-sample posterior covariance and a
## first-order expansion of the posterior mode's sampling distribution. Every
## coverage number below is a normal approximation and is labeled as one.
##
## WHAT E2 REPORTS, AND WHAT IT NO LONGER TRIES TO.
##
## Round 3 found the coverage calculation invalid wherever the model is
## misspecified, and it was right. Under discordance or synergy the true Bernoulli
## probability differs from the fitted one, so the score variance is no longer the
## model Fisher information, and for an aggregate arm mean the expected Hessian is
## not that information either: its second-derivative term vanishes only when the
## fitted mean equals the true one. The code nevertheless used
## (I + P0)^{-1} I (I + P0)^{-1}. Codex recomputed one registered curvature
## scenario under the correct Hessian and score variance and got 0.6898 against
## the 0.9400 reported, crossing both the nominal and the failure boundary.
##
## Two things could be done about that. A sandwich could be implemented, which for
## the aggregate rows needs the second derivative of a quadrature integral and is
## real work; or E2 could be scoped to the question it exists to answer. The
## second is chosen, because it is what the evidence supports rather than a
## partial sandwich presented as a whole one.
##
##   THE SEPARATION QUESTION NEEDS NO COVERAGE AT ALL. Whether contraction or
##   effective rank distinguishes the information states is a property of the
##   information matrix and the prior. It is computed exactly, on every scenario,
##   and E2's registered rules now operate on the full per-state distribution of
##   each diagnostic rather than on a coverage-filtered subset.
##
##   COVERAGE IS REPORTED ONLY WHERE THE MODEL IS CORRECT, that is at zero
##   discordance and zero synergy. There A equals B equals the Fisher information,
##   the expansion below is the ordinary one, and the number means what it says.
##   Those scenarios still contain failure, because a tight misplaced prior breaks
##   coverage without any misspecification at all.
##
##   MISSPECIFIED COVERAGE ON A NONLINEAR LINK IS OUT OF SCOPE and section 9 says
##   so. E1 answers the misspecified-coverage question exactly, on a linear link.
##
## The expansion used where it is valid: with p_i(theta) the model's mean for row
## i, the MAP solves score(theta) = -P0 theta, and about theta_true
##
##   theta_hat - theta_true  ~=  (I + P0)^{-1} [ U - P0 theta_true ],
##
## with U the score at theta_true. Var(theta_hat) = (I + P0)^{-1} I (I + P0)^{-1}
## holds when the model is correct, which is the only place it is now used.
##
##   Rscript R/07-run-e2.R
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(MASS))
source("R/06-nonlinear.R")

## The intercept that puts the placebo arm at the registered prevalence, so the
## curvature the link supplies is the same in every scenario rather than drifting
## with the parameter values.
base_alpha <- function() log(E2_BASE_P / (1 - E2_BASE_P))

theta_true_nl <- function(b) {
  th <- theta_true(b)
  th[seq_len(b$S)] <- base_alpha()
  th
}

## The TRUE arm means, which the additive logistic model cannot reproduce
## wherever discordance or synergy acts. Discordance replaces Gamma_W by
## Gamma_W + discord in the AGGREGATE rows carrying the target; synergy adds an
## unmodeled modification to arms holding components 1 and 3 together.
true_p <- function(b, theta, discord, synergy) {
  gh <- gh_rule(64)
  vapply(seq_len(nrow(b$net)), function(i) {
    th_i <- theta
    if (!as.logical(b$net$ipd[i]) && b$C[i, TARGET] == 1)
      th_i[gi_of(b)] <- th_i[gi_of(b)] + discord
    extra <- if (b$C[i, 1] == 1 && b$C[i, TARGET] == 1) synergy else 0
    xs <- b$net$mu[i] + sqrt(2) * b$net$sd[i] * gh$x
    w  <- gh$w / sqrt(pi)
    eta <- vapply(xs, function(x) {
      r <- design_row(b$net, i, x, b$S, b$K)
      sum(r * th_i) + extra * x
    }, 0)
    sum(w * expit(eta))
  }, 0)
}

## For an IPD arm the model's contribution is per-individual, so its "row" is the
## quadrature expansion; for an aggregate arm it is the single arm proportion.
## The displacement U is assembled over the same rows the information is.
displacement <- function(b, theta, discord, synergy) {
  U <- numeric(b$p)
  gh <- gh_rule(64)
  qt <- true_p(b, theta, discord, synergy)
  for (i in seq_len(nrow(b$net))) {
    if (as.logical(b$net$ipd[i])) {
      ## Individual data: the model is wrong only through synergy, which acts on
      ## the covariate, so the discrepancy varies with x and must be integrated.
      xs <- b$net$mu[i] + sqrt(2) * b$net$sd[i] * gh$x
      w  <- gh$w / sqrt(pi)
      extra <- if (b$C[i, 1] == 1 && b$C[i, TARGET] == 1) synergy else 0
      for (j in seq_along(xs)) {
        r <- design_row(b$net, i, xs[j], b$S, b$K)
        p_mod <- expit(sum(r * theta))
        p_tru <- expit(sum(r * theta) + extra * xs[j])
        U <- U + b$net$n[i] * w[j] * (p_tru - p_mod) * r
      }
    } else {
      pb <- agg_p(theta, b, i)
      g <- agg_grad(theta, b, i)
      U <- U + (b$net$n[i] / (pb * (1 - pb))) * g * (qt[i] - pb)
    }
  }
  U
}

evaluate_e2 <- function(row) {
  net <- build_state_nl(row$state, row$spread, row$sd_ratio, row$n)
  b <- build_design(net)
  th <- theta_true_nl(b)
  gi <- gi_of(b)
  P0 <- prior_precision(b, row$prior_sd)
  inf <- logit_info(b, th)
  I <- inf$total
  A <- solve(I + P0)
  U <- displacement(b, th, row$discord, row$synergy)
  bias <- as.vector(A %*% (U - P0 %*% th))[gi]
  v_samp <- (A %*% I %*% A)[gi, gi]
  sd_post <- sqrt(A[gi, gi])
  ## Correctly specified only; NA elsewhere, so a misspecified coverage figure
  ## cannot be read off this table by accident.
  well_specified <- row$discord == 0 && row$synergy == 0
  z <- stats::qnorm(1 - (1 - NOMINAL) / 2)
  cov <- if (!well_specified) NA_real_ else {
    lo <- (-bias - z * sd_post) / sqrt(v_samp)
    hi <- (-bias + z * sd_post) / sqrt(v_samp)
    stats::pnorm(hi) - stats::pnorm(lo)
  }

  ## The same four diagnostics, read off the logit information. Every precision
  ## here is PRIOR-FREE after round 3; see `lik_marginal_precision`.
  contraction <- sd_post / row$prior_sd
  target_ratio <- lik_marginal_precision(I, gi) / P0[gi, gi]
  er <- eff_rank(I, P0, thresh = EFF_RATIO_OK)
  u <- numeric(b$p); u[gi] <- 1
  estimable <- sum(abs(I %*% (MASS::ginv(I) %*% u) - u)) < 1e-6

  ## The flattened design, which removes the between-study contrast in covariate
  ## SDs while leaving the contrast in means. Round 3 showed the previous version
  ## subtracted two prior-regularized aggregate-only precisions, both of which are
  ## exactly zero prior-free, and reported their ratio as this study's headline.
  ## The well-posed question is leave-one-source-out on the FULL information,
  ## which does identify the target.
  net_flat <- net
  net_flat$sd[!as.logical(net_flat$ipd)] <-
    mean(net_flat$sd[!as.logical(net_flat$ipd)])
  b_flat <- build_design(net_flat)
  inf_flat <- logit_info(b_flat, theta_true_nl(b_flat))
  ss <- source_shares(I, inf$within, inf_flat$total, gi)
  w_in <- lik_marginal_precision(inf$within, gi)
  w_bt <- lik_marginal_precision(inf$between, gi)

  cbind(row, data.frame(
    contraction = contraction, target_ratio = target_ratio,
    eff_rank = er$eff_rank, estimable = estimable,
    prec_within = w_in, prec_between = w_bt, prec_full = ss$full,
    share_within = ss$share_within, share_curv = ss$share_curv,
    bias = bias, post_sd = sd_post, samp_sd = sqrt(v_samp),
    coverage = cov, well_specified = well_specified,
    stringsAsFactors = FALSE)) |>
    transform(failed = !is.na(coverage) & coverage < COVER_BAD)
}

build_grid_e2 <- function() {
  g <- expand.grid(state = E2_STATES, spread = E2_SPREADS,
                   sd_ratio = E2_SD_RATIO, discord = E2_DISCORD,
                   n = E2_TOTAL_N, prior_sd = E2_PRIOR_SD,
                   synergy = E2_SYNERGY,
                   KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  ## Same structural restrictions as E1, plus one for the new factor: the SD
  ## ratio acts only on `curvature`, and the between-study mean spread does not
  ## act on it at all, since that state holds the means equal by construction.
  g <- g[!(g$synergy != 0 & g$state != "additivity"), ]
  g <- g[!(g$discord != 0 & !g$state %in% c("ecological", "curvature")), ]
  g <- g[!(g$sd_ratio != 1 & g$state != "curvature"), ]
  g <- g[!(g$state == "curvature" & g$spread != E2_SPREADS[1]), ]
  rownames(g) <- NULL
  g$scenario <- seq_len(nrow(g))
  g
}

main <- function() {
  g <- build_grid_e2()
  cat(sprintf("E2: %d registered scenarios on a %s link\n", nrow(g), E2_LINK))
  res <- do.call(rbind, lapply(seq_len(nrow(g)), function(i) evaluate_e2(g[i, ])))
  rownames(res) <- NULL

  ## THE NEGATIVE CONTROL FOR THE NEW STATE. Equal aggregate SDs must identify
  ## nothing, or `curvature` is not a curvature route at all and the state is
  ## withdrawn. This is the control round 1's finding made necessary.
  eq <- res[res$state == "curvature" & res$sd_ratio == 1, ]
  if (nrow(eq) && any(eq$estimable))
    stop("the curvature state is estimable with EQUAL aggregate SDs in ",
         sum(eq$estimable), " scenarios; the registered mechanism is wrong and ",
         "the state must be withdrawn")
  ne <- res[res$state == "curvature" & res$sd_ratio > 1, ]
  if (nrow(ne) && !all(ne$estimable))
    stop("the curvature state is NOT estimable with unequal aggregate SDs; the ",
         "registered mechanism is wrong")

  saveRDS(res, "results/e2.rds")
  cat(sprintf("written: results/e2.rds  (%d rows)\n\n", nrow(res)))
  cat("coverage and contraction by state, logit link:\n")
  print(do.call(rbind, lapply(split(res, res$state), function(z) data.frame(
    state = z$state[1], n = nrow(z),
    cover_min = round(min(z$coverage), 3),
    cover_max = round(max(z$coverage), 3),
    contract_min = round(min(z$contraction), 4),
    contract_max = round(max(z$contraction), 4),
    share_within_min = round(min(z$share_within, na.rm = TRUE), 3),
    share_within_max = round(max(z$share_within, na.rm = TRUE), 3)))),
    row.names = FALSE)
}

if (!interactive() && Sys.getenv("E2_NOMAIN") == "") main()

## --- the three registered rules, evaluated rather than eyeballed -------------
## Section 7 of the protocol registers exactly what E2 must show for E1's
## conclusion to be withdrawn. Those conditions are checked here so the verdict
## is arithmetic, and so a reader can see it was not reached by looking at a
## table of ranges and forming an impression.
e2_verdict <- function(res) {
  ## ROUND 3 REBUILT THIS. The first version checked contraction and the
  ## per-parameter ratio only, never the whole-model effective-rank count, so one
  ## of the two summaries CMP-14 actually asks for controlled no decision. It also
  ## compared a coverage-filtered subset, keeping failing aggregate rows and
  ## nominal additivity rows and discarding the rest, so a registered separation
  ## could occur among the discarded rows without triggering withdrawal. And it
  ## let equal-SD curvature rows into the curvature comparisons although the
  ## protocol says those contain no curvature identification at all.
  ##
  ## Separation is a property of the diagnostics and the design, not of coverage,
  ## so the rule now compares the COMPLETE per-state distribution of each
  ## diagnostic over every registered row of that state, with the equal-SD
  ## curvature rows excluded from the curvature side because the protocol
  ## registers them as identifying nothing.
  rows_for <- function(st) {
    z <- res[res$state == st, ]
    if (st == "curvature") z <- z[z$sd_ratio > 1, ]
    z
  }
  ## Separable if the two states' value ranges do not overlap at all: some
  ## threshold puts every member of one on one side and every member of the other
  ## on the other. Direction-free, because a summary that inverted would still be
  ## a summary that separates.
  separates <- function(stat, s1, s2) {
    a <- rows_for(s1)[[stat]]; b <- rows_for(s2)[[stat]]
    a <- a[is.finite(a)]; b <- b[is.finite(b)]
    if (!length(a) || !length(b)) return(NA)
    min(a) > max(b) || min(b) > max(a)
  }
  grid <- expand.grid(
    stat = c("contraction", "target_ratio", "eff_rank"),
    against = c("ecological", "curvature"),
    stringsAsFactors = FALSE)
  rules <- do.call(rbind, lapply(seq_len(nrow(grid)), function(i) data.frame(
    rule = sprintf("%s separates additivity from %s", grid$stat[i],
                   grid$against[i]),
    separates = separates(grid$stat[i], "additivity", grid$against[i]),
    stringsAsFactors = FALSE)))

  ## The source-share condition, on the prior-free leave-one-source-out statistic.
  cs <- unique(rows_for("curvature")$share_curv)
  es <- unique(rows_for("ecological")$share_curv)
  cs <- cs[!is.na(cs)]; es <- es[!is.na(es)]
  list(rules = rules,
       withdraw_e1 = isTRUE(any(rules$separates)),
       curvature_share = unique(rows_for("curvature")$share_within[
         !is.na(rows_for("curvature")$share_within)]),
       ecological_share = unique(rows_for("ecological")$share_within[
         !is.na(rows_for("ecological")$share_within)]),
       share_within_is_constructional = FALSE,
       share_curv_curvature = if (length(cs)) range(cs) else NA,
       share_curv_ecological = if (length(es)) range(es) else NA,
       share_curv_separates = length(cs) > 0 && length(es) > 0 &&
         (min(cs) > max(es) || min(es) > max(cs)))
}

if (!interactive() && Sys.getenv("E2_NOMAIN") == "") {
  res <- readRDS("results/e2.rds")
  v <- e2_verdict(res)
  cat("\n=== the registered withdrawal rules ===\n")
  print(v$rules, row.names = FALSE)
  cat(sprintf("\nE1's conclusion is withdrawn: %s\n", v$withdraw_e1))
  cat(sprintf("coverage reported for %d of %d scenarios (correctly specified only)\n",
              sum(res$well_specified), nrow(res)))
  cat(sprintf("source share, curvature: %s | ecological: %s | separates them: %s\n",
              paste(v$curvature_share, collapse = ", "),
              paste(v$ecological_share, collapse = ", "),
              v$share_separates_curvature))
  saveRDS(v, "results/e2-verdict.rds")
  cat("written: results/e2-verdict.rds\n")
}
