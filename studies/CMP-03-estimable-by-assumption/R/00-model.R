## ---------------------------------------------------------------------------
## CMP-03: component network meta-analysis under an omitted interaction, for
## regimens that were administered and for regimens that never were.
##
## Components A, B, C, D against placebo. Eight two-arm trials (200 per arm,
## outcome SD 1, so each contrast has variance 0.01):
##   P-A, P-B, P-C, P-D, A vs A+B, B vs B+C, C vs A+C, P vs A+B.
## Pairs co-administered in some arm: A+B, B+C, A+C. Never: A+D, B+D, C+D.
## Truth: component effects BETA plus pairwise interactions (synergy is negative,
## the same sign as the effects). The additive fixed-effect model and a model with
## prespecified interactions for the three co-administered pairs are fitted by
## generalized least squares; bias, SD and 95% coverage of every regimen's effect
## are exact (normal linear model).
## rho(r): share of a regimen's component pairs never co-administered.
## ---------------------------------------------------------------------------

COMP <- c("A", "B", "C", "D"); BETA <- c(A = -0.3, B = -0.2, C = -0.25, D = -0.15); V_EDGE <- 0.01
TRIALS <- list(c("P", "A"), c("P", "B"), c("P", "C"), c("P", "D"), c("A", "A+B"), c("B", "B+C"), c("C", "A+C"), c("P", "A+B"))
PAIRS <- utils::combn(COMP, 2, paste, collapse = "+")
comps <- function(r) if (r == "P") character(0) else strsplit(r, "+", fixed = TRUE)[[1]]
pairs_of <- function(r) { k <- comps(r); if (length(k) < 2) character(0) else utils::combn(k, 2, paste, collapse = "+") }
ARMS <- unique(unlist(TRIALS)); OBS_PAIRS <- unique(unlist(lapply(ARMS, pairs_of)))
REGIMENS <- unlist(lapply(2:4, function(m) utils::combn(COMP, m, paste, collapse = "+")))

## Row of regimen r in the design: component indicators, then interaction indicators
## for the modeled pairs.
row_of <- function(r, ipairs) c(as.numeric(COMP %in% comps(r)), as.numeric(ipairs %in% pairs_of(r)))
true_effect <- function(r, iota) sum(BETA[comps(r)]) + sum(iota[intersect(names(iota), pairs_of(r))])

evaluate <- function(iota, ipairs = character(0)) {
  X <- t(vapply(TRIALS, function(t) row_of(t[2], ipairs) - row_of(t[1], ipairs), numeric(length(COMP) + length(ipairs))))
  mu <- vapply(TRIALS, function(t) true_effect(t[2], iota) - true_effect(t[1], iota), 0)
  M <- solve(crossprod(X) / V_EDGE) %*% t(X) / V_EDGE                       # coefficients = M y
  do.call(rbind, lapply(REGIMENS, function(r) { a <- row_of(r, ipairs); h <- drop(a %*% M)
    est <- sum(h * mu); tr <- true_effect(r, iota); sd <- sqrt(sum(h^2) * V_EDGE); b <- est - tr
    data.frame(regimen = r, administered = r %in% ARMS, rho = if (length(pairs_of(r))) mean(!(pairs_of(r) %in% OBS_PAIRS)) else 0,
               truth = tr, bias = b, sd = sd, coverage = stats::pnorm(1.96 - b / sd) - stats::pnorm(-1.96 - b / sd)) }))
}
