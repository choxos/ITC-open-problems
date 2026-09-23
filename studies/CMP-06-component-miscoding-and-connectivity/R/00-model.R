## ---------------------------------------------------------------------------
## CMP-06: component miscoding in a disconnected network bridged by a shared
## component.
##
## Subnetwork 1 (backbone X): X vs X+A (two trials), X vs X+C.
## Subnetwork 2 (backbone Y): Y+A vs Y+B+D (two trials), Y vs Y+D.
## The only link is component A. Target: the effect of B, X+B vs X, identified as
## (B + D - A from subnetwork 2) + (A from subnetwork 1) - (D from Y vs Y+D).
## Each contrast has variance V_EDGE. Effects: A -0.3, B -0.2, C -0.1, D -0.15.
## The analyst's coding of each subnetwork-2 arm is wrong independently:
##   connectivity-changing  the A in a Y+A arm is coded as a distinct agent A2;
##   connectivity-preserving the D in a Y+B+D arm is dropped (coded Y+B).
## Methods: deterministic fit of the coding used; coding sensitivity (every
## plausible coding of the two uncertain features, range of the estimates and
## union of their intervals); probabilistic coding (mixture over plausible codings
## with prior probability p per arm, 95% interval from the mixture); the
## estimability screen (rank check of the coding used).
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261201L; N_SIM <- 2000L; V_EDGE <- 0.01
EFF <- c(A = -0.3, B = -0.2, C = -0.1, D = -0.15)
TRIALS <- list(c("X", "X+A"), c("X", "X+A"), c("X", "X+C"), c("Y+A", "Y+B+D"), c("Y+A", "Y+B+D"), c("Y", "Y+D"))
COMPS <- c("A", "A2", "B", "C", "D", "X", "Y")
comp_vec <- function(r) as.numeric(COMPS %in% strsplit(r, "+", fixed = TRUE)[[1]])
G <- comp_vec("X+B") - comp_vec("X")
build_grid <- function() { g <- expand.grid(type = c("changing", "preserving"), p = c(0, 0.05, 0.15, 0.3), KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g <- g[!(g$type == "preserving" & g$p == 0), ]; g$cell <- seq_len(nrow(g)); g }
true_mean <- function(t) { f <- function(r) { k <- strsplit(r, "+", fixed = TRUE)[[1]]; sum(EFF[intersect(k, names(EFF))]) }; f(t[2]) - f(t[1]) }
MU <- vapply(TRIALS, true_mean, 0); TRUTH <- EFF[["B"]]

## Apply a coding: flags a (A coded as A2) and d (D dropped) per subnetwork-2 trial.
code_trials <- function(a_flag, d_flag) lapply(seq_along(TRIALS), function(j) { t <- TRIALS[[j]]
  if (j %in% 4:5) { k <- j - 3; if (a_flag[k]) t[1] <- "Y+A2"; if (d_flag[k]) t[2] <- "Y+B" }; t })
fit <- function(trials, y) {
  X <- t(vapply(trials, function(t) comp_vec(t[2]) - comp_vec(t[1]), numeric(length(COMPS))))
  P <- crossprod(X) / V_EDGE; Pi <- MASS::ginv(P)
  estimable <- max(abs(G %*% Pi %*% P - G)) < 1e-8
  if (!estimable) return(c(est = NA, se = NA, estimable = 0))
  c(est = drop(G %*% Pi %*% crossprod(X, y) / V_EDGE), se = sqrt(drop(G %*% Pi %*% G)), estimable = 1)
}
mix_ci <- function(m, s, w) { f <- function(q) sum(w * stats::pnorm(q, m, s))
  c(stats::uniroot(function(q) f(q) - 0.025, c(-10, 10))$root, stats::uniroot(function(q) f(q) - 0.975, c(-10, 10))$root) }

one_rep <- function(cell) {
  y <- MU + stats::rnorm(length(MU), 0, sqrt(V_EDGE))
  flag <- stats::runif(2) < cell$p
  used <- if (cell$type == "changing") code_trials(flag, c(FALSE, FALSE)) else code_trials(c(FALSE, FALSE), flag)
  det <- fit(used, y)
  ## Plausible codings: each uncertain feature of each subnetwork-2 trial either way.
  alts <- expand.grid(f1 = c(FALSE, TRUE), f2 = c(FALSE, TRUE))
  fits <- t(apply(alts, 1, function(a) fit(if (cell$type == "changing") code_trials(unlist(a), c(FALSE, FALSE)) else code_trials(c(FALSE, FALSE), unlist(a)), y)))
  prior <- apply(alts, 1, function(a) prod(ifelse(unlist(a), max(cell$p, 0.05), 1 - max(cell$p, 0.05))))
  ok <- fits[, "estimable"] == 1
  sens <- if (any(ok)) range(c(fits[ok, "est"] - 1.96 * fits[ok, "se"], fits[ok, "est"] + 1.96 * fits[ok, "se"])) else c(-Inf, Inf)
  if (any(!ok)) sens <- c(-Inf, Inf)                                 # some plausible coding leaves B unidentified
  pm <- if (sum(prior[!ok]) > 0.05) c(-Inf, Inf) else mix_ci(fits[ok, "est"], fits[ok, "se"], prior[ok] / sum(prior[ok]))
  cov <- function(ci) ci[1] <= TRUTH && TRUTH <= ci[2]
  data.frame(n_miscoded = sum(flag), det_estimable = det[["estimable"]],
             det_bias = det[["est"]] - TRUTH, det_cover = if (det[["estimable"]] == 1) cov(det[["est"]] + c(-1.96, 1.96) * det[["se"]]) else NA,
             sens_cover = cov(sens), sens_bounded = all(is.finite(sens)), sens_width = diff(sens),
             prob_cover = cov(pm), prob_bounded = all(is.finite(pm)), prob_width = diff(pm), det_width = 2 * 1.96 * det[["se"]])
}
