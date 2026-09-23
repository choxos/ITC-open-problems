## ---------------------------------------------------------------------------
## OUT-10: a proportional-odds violation reaches a decision in proportion to the
## utility increments at the violated cut-point.
##
## One trial of A versus C, 300 per arm, x ~ N(0, 1); ordinal outcome with four
## categories (1 worst, 4 best) from a cumulative logit
##   logit P(Y > k | x, a) = ALPHA_k + 0.8 x + a BETA_k,  k = 1, 2, 3,
## BETA constant (proportional odds), or larger at the bottom cut-point (A mainly
## moves patients out of the worst category), or larger at the top.
## Target: x ~ N(0.5, 1). Estimand: difference in expected utility, A minus C,
## sum_k u_k (p_k(A) - p_k(C)) under two utility vectors with the increments at the
## bottom (0, 0.6, 0.8, 1) or at the top (0, 0.2, 0.4, 1).
## Methods: proportional-odds regression (MASS::polr) and separate logistic
## regressions for each cut-point, both standardized over the target by
## G-computation; nonparametric bootstrap SE (60 resamples).
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(MASS))
MASTER_SEED <- 20261203L; N_ARM <- 300L; N_SIM <- 400L; N_BOOT <- 60L; M_T <- 0.5
ALPHA <- c(1.2, 0, -1.2)
BETAS <- list(po = c(0.5, 0.5, 0.5), bottom = c(1.2, 0.3, 0.2), top = c(0.2, 0.3, 1.2))
U <- list(bottom_heavy = c(0, 0.6, 0.8, 1), top_heavy = c(0, 0.2, 0.4, 1))
build_grid <- function() { g <- data.frame(violation = names(BETAS), stringsAsFactors = FALSE); g$cell <- seq_len(nrow(g)); g }
ZT <- stats::qnorm(stats::ppoints(400), M_T, 1)
cat_probs <- function(above) { above <- cbind(1, above, 0); above[, -ncol(above), drop = FALSE] - above[, -1, drop = FALSE] }   # rows: patients, cols: categories 1..4
truth <- function(cell) { b <- BETAS[[cell$violation]]
  pa <- function(a) colMeans(cat_probs(sapply(1:3, function(k) stats::plogis(ALPHA[k] + 0.8 * ZT + a * b[k]))))
  d <- pa(1) - pa(0); vapply(U, function(u) sum(u * d), 0) }
draw <- function(cell) { b <- BETAS[[cell$violation]]; x <- stats::rnorm(2 * N_ARM); A <- rep(0:1, each = N_ARM)
  P <- cat_probs(sapply(1:3, function(k) stats::plogis(ALPHA[k] + 0.8 * x + A * b[k])))
  y <- apply(P, 1, function(p) sample.int(4, 1, prob = p)); data.frame(x = x, A = A, y = y) }
du_po <- function(d) { f <- suppressWarnings(polr(factor(y, levels = 1:4) ~ x + A, data = d))
  pa <- function(a) colMeans(stats::predict(f, newdata = data.frame(x = ZT, A = a), type = "probs")); dd <- pa(1) - pa(0)
  vapply(U, function(u) sum(u * dd), 0) }
du_sep <- function(d) { ab <- function(a) sapply(1:3, function(k) { f <- suppressWarnings(stats::glm(I(y > k) ~ x + A, family = stats::binomial(), data = d))
    stats::predict(f, newdata = data.frame(x = ZT, A = a), type = "response") })
  dd <- colMeans(cat_probs(ab(1))) - colMeans(cat_probs(ab(0))); vapply(U, function(u) sum(u * dd), 0) }
one_rep <- function(cell) { d <- draw(cell); est <- rbind(po = du_po(d), separate = du_sep(d))
  bs <- replicate(N_BOOT, { i <- c(sample(which(d$A == 0), replace = TRUE), sample(which(d$A == 1), replace = TRUE)); db <- d[i, ]
    c(tryCatch(du_po(db), error = function(e) rep(NA, 2)), du_sep(db)) })
  se <- matrix(apply(bs, 1, stats::sd, na.rm = TRUE), 2, byrow = TRUE, dimnames = list(c("po", "separate"), names(U)))
  do.call(rbind, lapply(rownames(est), function(m) data.frame(method = m, utility = names(U), est = est[m, ], se = se[m, ]))) }
