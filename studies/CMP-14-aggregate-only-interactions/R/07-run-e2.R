## ---------------------------------------------------------------------------
## E2: does E1's conclusion survive a nonlinear link?
##
## Asymptotic, not fitted and not exact. A logistic likelihood is not conjugate,
## so the posterior has no closed form; what is closed form is the Fisher
## information, and from it the large-sample posterior covariance and a
## first-order expansion of the posterior mode's sampling distribution. Every
## coverage number below is a normal approximation and is labeled as one.
##
## THE FIRST-ORDER EXPANSION, stated so a reader can see what it assumes. Write
## the model's mean for row i as p_i(theta) and the TRUE mean as q_i, which
## differs from p_i(theta_true) wherever discordance or synergy acts. The MAP
## solves score(theta) = P0 (theta - 0), and expanding about theta_true:
##
##   theta_hat - theta_true  ~=  (I + P0)^{-1} [ U - P0 theta_true ],
##   U = sum_i w_i g_i (q_i - p_i(theta_true)),
##
## with g_i the gradient of p_i and w_i the row weight. E[U] is the displacement
## caused by misspecification and Var(theta_hat) ~= (I + P0)^{-1} I (I + P0)^{-1}.
## Both terms are computed exactly; only the linearization is approximate, and it
## is the same approximation any asymptotic coverage statement makes.
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
  z <- stats::qnorm(1 - (1 - NOMINAL) / 2)
  lo <- (-bias - z * sd_post) / sqrt(v_samp)
  hi <- (-bias + z * sd_post) / sqrt(v_samp)

  ## The same four diagnostics, read off the logit information.
  contraction <- sd_post / row$prior_sd
  target_ratio <- (1 / A[gi, gi] - P0[gi, gi]) / P0[gi, gi]
  er <- eff_rank(I, P0, thresh = EFF_RATIO_OK)
  prec_from <- function(Is) {
    V <- solve(Is + P0)
    max(1 / V[gi, gi] - P0[gi, gi], 0)
  }
  w_in <- prec_from(inf$within); w_bt <- prec_from(inf$between)
  tot <- w_in + w_bt
  u <- numeric(b$p); u[gi] <- 1
  estimable <- sum(abs(I %*% (MASS::ginv(I) %*% u) - u)) < 1e-6

  cbind(row, data.frame(
    contraction = contraction, target_ratio = target_ratio,
    eff_rank = er$eff_rank, estimable = estimable,
    prec_within = w_in, prec_between = w_bt,
    share_within = if (tot > 0) w_in / tot else NA_real_,
    bias = bias, post_sd = sd_post, samp_sd = sqrt(v_samp),
    coverage = stats::pnorm(hi) - stats::pnorm(lo),
    stringsAsFactors = FALSE)) |>
    transform(failed = coverage < COVER_BAD)
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
  nominal <- res$coverage >= NOMINAL - 0.01
  keep <- res$failed | nominal
  r <- res[keep, ]
  sep <- function(stat, groups, safe_low) {
    a <- r[r$state %in% groups[1] & r$failed, stat]
    b <- r[r$state %in% groups[2] & !r$failed, stat]
    if (!length(a) || !length(b)) return(NA)
    ## Separable if every failing member of one group is less reassuring than
    ## every nominal member of the other.
    if (safe_low) min(a) > max(b) else max(a) < min(b)
  }
  rules <- rbind(
    data.frame(rule = "contraction separates additivity from ecological",
               separates = sep("contraction", c("ecological", "additivity"), TRUE)),
    data.frame(rule = "contraction separates additivity from curvature",
               separates = sep("contraction", c("curvature", "additivity"), TRUE)),
    data.frame(rule = "target ratio separates additivity from ecological",
               separates = sep("target_ratio", c("ecological", "additivity"), FALSE)),
    data.frame(rule = "target ratio separates additivity from curvature",
               separates = sep("target_ratio", c("curvature", "additivity"), FALSE)))
  ## The second registered condition: if source_share DOES separate curvature
  ## from ecological, the claim that they are the same kind of evidence is wrong.
  cs <- unique(res$share_within[res$state == "curvature" & !is.na(res$share_within)])
  es <- unique(res$share_within[res$state == "ecological" & !is.na(res$share_within)])
  list(rules = rules,
       withdraw_e1 = isTRUE(any(rules$separates)),
       curvature_share = cs, ecological_share = es,
       share_separates_curvature = !identical(sort(cs), sort(es)))
}

if (!interactive() && Sys.getenv("E2_NOMAIN") == "") {
  res <- readRDS("results/e2.rds")
  v <- e2_verdict(res)
  cat("\n=== the registered withdrawal rules ===\n")
  print(v$rules, row.names = FALSE)
  cat(sprintf("\nE1's conclusion is withdrawn: %s\n", v$withdraw_e1))
  cat(sprintf("source share, curvature: %s | ecological: %s | separates them: %s\n",
              paste(v$curvature_share, collapse = ", "),
              paste(v$ecological_share, collapse = ", "),
              v$share_separates_curvature))
  saveRDS(v, "results/e2-verdict.rds")
  cat("written: results/e2-verdict.rds\n")
}
