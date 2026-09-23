## ---------------------------------------------------------------------------
## CMP-26: an adversarial module for cpaic's two-stage component bridge.
##
## Package under test: cpaic at commit cf27b1a (not installed; the per-study STC
## and its validity gate are sourced from copies extracted with
##   git show cf27b1a:R/cstc.R > R/cpaic-cf27b1a/cstc.R
##   git show cf27b1a:R/fit_checks.R > R/cpaic-cf27b1a/fit_checks.R
## and the bridge is netmeta::discomb() called with the arguments cpaic's
## cnma_bridge() passes).
##
## Network: components A, B, C, D; inactive P; five two-arm trials, all with
## individual data (cSTC's default path; retaining aggregate-only edges is gated
## as experimental at this commit), 200 per arm, binary outcome.
##   subnetwork 1: T1 P vs A, T2 P vs B, T3 A vs A+B
##   subnetwork 2: T4 C vs C+D, T5 D vs A+D
## No regimen appears in both subnetworks; component A is in both.
## Component design rows: T1 A, T2 B, T3 B, T4 D, T5 A. C is not identified.
## Estimand: A+D versus P (A+D is observed only in subnetwork 2, P only in 1),
## the conditional log odds ratio at the true target covariate mean XT:
##   theta = b_A + b_D + G_A * XT.
## Outcome: logit p = MU + BX x + sum over the arm's components of b_c, plus
## g_A x when the arm contains A, plus SYN when it contains both C and D.
## x ~ N(M_TRIAL[t], 1). g_A = G_A in subnetwork 1 and G_A + DRIFT in 2; the
## target follows subnetwork 1's modification.
## Departures, one at a time, at matched severity (the shift each induces in the
## edge it corrupts, evaluated at the target: SYN; DRIFT * XT; G_A * (declared XT
## - XT)): synergy, drift of A's modification across subnetworks, a misdeclared
## target mean; and poor overlap (XT far from the trials).
## Methods: cstc: each trial's arm coefficient from cpaic's .cpaic_stc_one_study
## (glm y ~ arm + xc + arm:xc, xc = x - declared XT), bridged by discomb (common
## effect). unadjusted: each trial's own log odds ratio, bridged the same way.
## Prediction (known mechanisms, CMP-03 and CMP-11): each edge's probability
## limit minus its target value, passed through the fixed-effect GLS row of the
## estimand, h = m' (X'WX)^+ X'W, W = diag(1 / seTE^2) of the replicate.
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(netmeta))
MASTER_SEED <- 20261226L; N_SIM <- 1000L; N_ARM <- 200L
MU <- -0.5; BX <- 0.4; B <- c(A = -0.4, B = -0.3, C = -0.2, D = -0.5); G_A <- 0.4
TRIALS <- data.frame(study = paste0("T", 1:5), t2 = c("P", "P", "A", "C", "D"), t1 = c("A", "B", "A+B", "C+D", "A+D"),
                     sub = c(1, 1, 1, 2, 2), m = c(0, 0.3, -0.3, 0.6, 1.2), stringsAsFactors = FALSE)
COMP <- names(B); M_VEC <- c(A = 1, B = 0, C = 0, D = 1)
comps <- function(r) if (r == "P") character(0) else strsplit(r, "+", fixed = TRUE)[[1]]
xrow <- function(t1, t2) as.numeric(COMP %in% comps(t1)) - as.numeric(COMP %in% comps(t2))
X_NET <- t(mapply(xrow, TRIALS$t1, TRIALS$t2)); colnames(X_NET) <- COMP
## Rank map (CMP-24's projection test): the estimand is in the row space; C is not.
estimable <- function(m) max(abs(m %*% MASS::ginv(crossprod(X_NET)) %*% crossprod(X_NET) - m)) < 1e-8
stopifnot(estimable(M_VEC), !estimable(c(0, 0, 1, 0)))

build_grid <- function() {
  g <- data.frame(name = c("null", "synergy_mod", "synergy_strong", "drift_mod", "drift_strong", "target_mod", "target_strong",
                           "overlap_poor", "no_modification", "positive"),
                  syn = c(0, -0.15, -0.3, 0, 0, 0, 0, 0, 0, -0.3), drift = c(0, 0, 0, -0.15, -0.3, 0, 0, 0, 0, -0.3),
                  xt = c(1, 1, 1, 1, 1, 1, 1, 2.5, 1, 2.5), xt_decl_shift = c(0, 0, 0, 0, 0, -0.375, -0.75, 0, 0, 0),
                  ga = c(rep(G_A, 8), 0, G_A), stringsAsFactors = FALSE)
  g$cell <- seq_len(nrow(g)); g }
truth <- function(cell) unname(B["A"] + B["D"] + cell$ga * cell$xt)

lp <- function(r, x, sub, cell) { k <- comps(r); ga <- cell$ga + if (sub == 2) cell$drift else 0
  MU + BX * x + sum(B[k]) + ("A" %in% k) * ga * x + (all(c("C", "D") %in% k)) * cell$syn }
draw <- function(cell) lapply(seq_len(nrow(TRIALS)), function(t) { tr <- TRIALS[t, ]
  x <- stats::rnorm(2 * N_ARM, tr$m); arm <- rep(c(tr$t2, tr$t1), each = N_ARM)
  eta <- ifelse(arm == tr$t1, lp(tr$t1, x, tr$sub, cell), lp(tr$t2, x, tr$sub, cell))
  data.frame(arm = arm, x = x, y = stats::rbinom(2 * N_ARM, 1, stats::plogis(eta)), stringsAsFactors = FALSE) })

CPAIC <- new.env()
for (f in c("cstc.R", "fit_checks.R")) sys.source(file.path("R", "cpaic-cf27b1a", f), envir = CPAIC)
cstc_edge <- function(d, t, xt_decl) {
  s <- CPAIC$.cpaic_stc_one_study(d, info = list(trt = "arm", outcome = "y"), family = "binomial", ref_arm = TRIALS$t2[t],
         target_mean = list(x = xt_decl), effect_modifiers = "x", prognostics = "x", sm = "OR", outcome_args = list(), study_id = TRIALS$study[t])
  c(TE = s$contrasts$TE, seTE = s$contrasts$seTE) }
raw_edge <- function(d, t) { r1 <- sum(d$y[d$arm == TRIALS$t1[t]]); r0 <- sum(d$y[d$arm == TRIALS$t2[t]]); n <- N_ARM
  c(TE = log(r1 / (n - r1)) - log(r0 / (n - r0)), seTE = sqrt(1 / r1 + 1 / (n - r1) + 1 / r0 + 1 / (n - r0))) }
bridge <- function(E) { f <- withCallingHandlers(discomb(E[, "TE"], E[, "seTE"], TRIALS$t1, TRIALS$t2, TRIALS$study, sm = "OR", inactive = "P",
    sep.comps = "+", reference.group = "P", common = TRUE, random = FALSE),
    warning = function(w) if (grepl("not uniquely identifiable: 'C'", conditionMessage(w), fixed = TRUE)) invokeRestart("muffleWarning"))
  c(est = f$TE.common["A+D", "P"], se = f$seTE.common["A+D", "P"]) }
h_row <- function(se) { W <- diag(1 / se^2); drop(M_VEC %*% MASS::ginv(t(X_NET) %*% W %*% X_NET) %*% t(X_NET) %*% W) }

## Probability limit of each edge minus its target value (quadrature over x).
Z <- stats::qnorm(stats::ppoints(4000))
marg_lor <- function(t, cell) { tr <- TRIALS[t, ]; x <- tr$m + Z
  stats::qlogis(mean(stats::plogis(lp(tr$t1, x, tr$sub, cell)))) - stats::qlogis(mean(stats::plogis(lp(tr$t2, x, tr$sub, cell)))) }
edge_bias <- function(cell) {
  tgt <- drop(X_NET %*% c(B["A"] + cell$ga * cell$xt, B["B"], B["C"], B["D"]))
  xd <- cell$xt + cell$xt_decl_shift
  cond <- vapply(seq_len(nrow(TRIALS)), function(t) { tr <- TRIALS[t, ]; lp(tr$t1, xd, tr$sub, cell) - lp(tr$t2, xd, tr$sub, cell) }, 0)
  list(cstc = cond - tgt, unadjusted = vapply(seq_len(nrow(TRIALS)), marg_lor, 0, cell = cell) - tgt) }

one_rep <- function(cell, eb = edge_bias(cell)) {
  d <- draw(cell); xd <- cell$xt + cell$xt_decl_shift
  do.call(rbind, lapply(c("cstc", "unadjusted"), function(m) tryCatch({
    E <- t(vapply(seq_along(d), function(t) if (m == "cstc") cstc_edge(d[[t]], t, xd) else raw_edge(d[[t]], t), numeric(2)))
    b <- bridge(E); data.frame(method = m, est = b[["est"]], se = b[["se"]], pred = sum(h_row(E[, "seTE"]) * eb[[m]]), error = NA_character_)
  }, error = function(e) data.frame(method = m, est = NA_real_, se = NA_real_, pred = NA_real_, error = conditionMessage(e)))))
}
