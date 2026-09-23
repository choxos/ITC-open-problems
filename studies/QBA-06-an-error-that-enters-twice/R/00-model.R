## ---------------------------------------------------------------------------
## QBA-06: a misclassified binary covariate that is both a balancing variable and
## a modifier.
##
## Source trial A versus C, 400 per arm; true binary X with prevalence 0.3 in the
## source and 0.5 in the target. logit P(Y = 1) = -1 + 0.5 X + A (-0.5 + B X).
## Recorded X* has sensitivity and specificity (SE_S, SP_S) in the source and
## (SE_T, SP_T) in the target, which reports the prevalence of X* only.
## Estimand: marginal log odds ratio, A versus C, in the target (true X law).
## Methods:
##   maic_naive        weights balance X* to the target's reported X* prevalence
##   maic_prev_only    target's true prevalence recovered with (SE_T, SP_T), then
##                     mapped to the X* prevalence the source's assay would show
##   maic_corrected    category weights chosen so that the weighted source's implied
##                     true prevalence, sum over X* of weight x P(X = 1 | X*), equals
##                     the target's corrected prevalence. Reweighting the X* categories
##                     cannot change the true mix within each category, so balancing
##                     X* alone does not balance X even with identical assays.
##   stc_naive         logistic model on X*, averaged over the target's X* prevalence
##   stc_outcome_only  latent-class likelihood with known (SE_S, SP_S) for the outcome
##                     model, averaged over the target's reported X* prevalence
##   stc_corrected     the same, averaged over the target's corrected true prevalence
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261026L
N_ARM <- 400L; P_S <- 0.3; P_T <- 0.5; N_SIM <- 1000L
LEVELS <- list(assay = c("same_good", "same_poor", "source_worse", "target_worse"), b = c(0.5, 1))
ASSAY <- list(same_good = c(0.9, 0.95, 0.9, 0.95), same_poor = c(0.75, 0.85, 0.75, 0.85),
              source_worse = c(0.75, 0.85, 0.95, 0.98), target_worse = c(0.95, 0.98, 0.75, 0.85))
build_grid <- function() { g <- expand.grid(assay = LEVELS$assay, b = LEVELS$b, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE); g$cell <- seq_len(nrow(g)); g }
lor <- function(p, b) { r <- function(a) p * stats::plogis(-1 + 0.5 + a * (-0.5 + b)) + (1 - p) * stats::plogis(-1 + a * (-0.5)); stats::qlogis(r(1)) - stats::qlogis(r(0)) }
truth <- function(cell) lor(P_T, cell$b)
obs_prev <- function(p, se, sp) se * p + (1 - sp) * (1 - p)
true_prev <- function(q, se, sp) min(max((q - (1 - sp)) / (se + sp - 1), 0), 1)

draw <- function(cell) { a <- ASSAY[[cell$assay]]; n <- 2 * N_ARM; A <- rep(0:1, each = N_ARM); x <- stats::rbinom(n, 1, P_S)
  xs <- ifelse(x == 1, stats::rbinom(n, 1, a[1]), stats::rbinom(n, 1, 1 - a[2]))
  y <- stats::rbinom(n, 1, stats::plogis(-1 + 0.5 * x + A * (-0.5 + cell$b * x)))
  structure(data.frame(A = A, xs = xs, y = y), q_target = mean(stats::rbinom(800, 1, obs_prev(P_T, a[3], a[4])))) }

maic_bin <- function(d, q) { q <- min(max(q, 1e-6), 1 - 1e-6); w <- ifelse(d$xs == 1, q / mean(d$xs), (1 - q) / (1 - mean(d$xs)))
  p1 <- sum(w * d$y * d$A) / sum(w * d$A); p0 <- sum(w * d$y * (1 - d$A)) / sum(w * (1 - d$A)); stats::qlogis(p1) - stats::qlogis(p0) }

## Latent-class likelihood: X ~ Bern(pi), X* | X by the known source assay,
## Y | X, A logistic with an A-by-X interaction.
latent_fit <- function(d, se, sp) {
  nll <- function(th) { pi <- stats::plogis(th[5]); lin <- function(x) th[1] + th[2] * x + d$A * (th[3] + th[4] * x)
    l1 <- pi * ifelse(d$xs == 1, se, 1 - se) * stats::dbinom(d$y, 1, stats::plogis(lin(1)))
    l0 <- (1 - pi) * ifelse(d$xs == 1, 1 - sp, sp) * stats::dbinom(d$y, 1, stats::plogis(lin(0)))
    -sum(log(l1 + l0)) }
  stats::optim(c(-1, 0, -0.5, 0, 0), nll, method = "BFGS", control = list(maxit = 300))$par
}
g_lor <- function(th, p) { r <- function(a) p * stats::plogis(th[1] + th[2] + a * (th[3] + th[4])) + (1 - p) * stats::plogis(th[1] + a * th[3]); stats::qlogis(r(1)) - stats::qlogis(r(0)) }

fit_all <- function(cell, d) { a <- ASSAY[[cell$assay]]; q <- attr(d, "q_target")
  pT <- true_prev(q, a[3], a[4]); q_src <- obs_prev(pT, a[1], a[2])
  f <- stats::glm(y ~ A * xs, family = stats::binomial(), data = d); b <- stats::coef(f)
  stc_naive <- g_lor(c(b[1], b[3], b[2], b[4]), q)
  th <- latent_fit(d, a[1], a[2])
  pS <- true_prev(mean(d$xs), a[1], a[2]); qS <- obs_prev(pS, a[1], a[2])
  pi1 <- a[1] * pS / qS; pi0 <- (1 - a[1]) * pS / (1 - qS)
  s1 <- (pT - pi0) / (pi1 - pi0)
  c(maic_naive = maic_bin(d, q), maic_prev_only = maic_bin(d, q_src), maic_corrected = maic_bin(d, s1), stc_naive = unname(stc_naive),
    stc_outcome_only = g_lor(th, q), stc_corrected = g_lor(th, pT))
}
