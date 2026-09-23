## ---------------------------------------------------------------------------
## DIA-17: a masked-IPD benchmark of anchored population adjustment, scored
## against an estimand-matched reference and at the arm level.
##
## Data: multinma 0.9.1, plaque_psoriasis_ipd (GPL-3). Simulated individual data
## constructed to resemble UNCOVER-1, UNCOVER-2 and UNCOVER-3 (ixekizumab 80 mg every 2 or 4 weeks,
## placebo; UNCOVER-2 and -3 also etanercept). Outcome PASI 75 at week 12.
## Covariates: the five effect modifiers of Phillippo et al. 2020, durnpso,
## prevsys, bsa, weight, psa; rows missing any of them are dropped.
##
## Unit (S, M, A): source trial S supplies individual data on A versus PBO.
## Masked trial M (UNCOVER-2 or UNCOVER-3) is reduced to what a publication of ETN
## versus PBO reports: arm sizes, PASI 75 counts and covariate means over those
## two arms. M's A arm is withheld from every method. Target: M's population.
## Methods (see only S's individual data and M's aggregate):
##   bucher    unadjusted anchored comparison
##   maic      method-of-moments weights on the five covariates
##   stc_cond  main-effects logistic model in S, treatment coefficient
##             (a conditional log odds ratio) minus M's ETN versus PBO
##   stc_marg  the same model averaged over the MAIC-weighted S covariates
## References from M's full data, each method paired with its own estimand:
##   marg      marginal log OR of A versus ETN in M (bucher, maic, stc_marg)
##   cond      stc_cond's functional evaluated in M: conditional log OR of A
##             versus PBO from the same main-effects model fitted to M, minus
##             M's marginal ETN versus PBO log OR
## Collapsibility gap: cond minus marg. On the risk-difference scale the same
## gap (regression-adjusted minus unadjusted) is zero in expectation.
## Arm level: each marginal method's prediction of M's PBO and A response rates
## on the logit scale, against M's observed arms.
## Uncertainty: joint bootstrap, S and M resampled within arm and the whole
## pipeline rerun; the SE of every discrepancy is the bootstrap interquartile
## range of that discrepancy over 1.349 (robust to draws in which a sparse
## placebo arm separates a logistic fit), so arms shared between estimate and
## reference cancel correctly.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261217L; N_BOOT <- 1000L; DELTA <- 1
X <- c("durnpso", "prevsys", "bsa", "weight", "psa")
IPD <- local({ e <- new.env(); utils::data("plaque_psoriasis_ipd", package = "multinma", envir = e)
  d <- e$plaque_psoriasis_ipd; d <- d[stats::complete.cases(d[, c(X, "pasi75")]), ]
  data.frame(study = d$studyc, trt = d$trtc, y = as.numeric(d$pasi75), vapply(d[, X], as.numeric, numeric(nrow(d)))) })
lo <- stats::qlogis; elo <- function(r, n) log((r + 0.5) / (n - r + 0.5))

## 8 main units, 4 self units (S = M, null control), 2 positive-control units:
## M's outcomes in every arm regenerated from a main-effects logistic model
## fitted to M plus DELTA logits, a baseline shift that leaves the relative
## effect nearly intact and moves every arm, so MAIC should be discordant.
build_grid <- function() {
  g <- expand.grid(S = c("UNCOVER-1", "UNCOVER-2", "UNCOVER-3"), M = c("UNCOVER-2", "UNCOVER-3"), A = c("IXE_Q2W", "IXE_Q4W"),
                   KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$kind <- ifelse(g$S == g$M, "self", "main")
  g <- rbind(g, data.frame(S = "UNCOVER-1", M = c("UNCOVER-2", "UNCOVER-3"), A = "IXE_Q2W", kind = "pos"))
  g <- g[order(g$kind != "main", g$kind), ]; g$unit <- seq_len(nrow(g)); rownames(g) <- NULL; g
}
unit_data <- function(u) {
  dm <- IPD[IPD$study == u$M & IPD$trt %in% c(u$A, "ETN", "PBO"), ]
  if (u$kind == "pos") { D <- cbind(stats::model.matrix(~ trt - 1, dm), as.matrix(dm[, X]))
    dm$y <- stats::rbinom(nrow(dm), 1, stats::plogis(drop(D %*% lfit(dm$y, D)) + DELTA)) }
  list(ds = IPD[IPD$study == u$S & IPD$trt %in% c(u$A, "PBO"), ], dm = dm)
}

## What a publication of M's ETN versus PBO comparison reports.
mask <- function(dm) { z <- dm[dm$trt %in% c("ETN", "PBO"), ]
  list(n = c(ETN = sum(z$trt == "ETN"), PBO = sum(z$trt == "PBO")),
       r = c(ETN = sum(z$y[z$trt == "ETN"]), PBO = sum(z$y[z$trt == "PBO"])), xbar = colMeans(z[, X])) }

maic_w <- function(x, target) {
  s <- apply(x, 2, stats::sd); z <- sweep(sweep(x, 2, target), 2, s, "/")
  o <- stats::optim(numeric(ncol(z)), function(a) sum(exp(z %*% a)), function(a) colSums(z * drop(exp(z %*% a))),
                    method = "BFGS", control = list(maxit = 1000, reltol = 1e-14))
  w <- drop(exp(z %*% o$par)); w / mean(w)
}
rse <- function(v) stats::IQR(v, na.rm = TRUE) / 1.349     # robust bootstrap SE
lfit <- function(y, D) suppressWarnings(stats::glm.fit(D, y, family = stats::binomial())$coefficients)

## The methods: S's individual data and M's aggregate only. Arm-level logits
## from counts carry a 0.5 correction, since UNCOVER-2's placebo arm has 4
## responders and a bootstrap draw can have none.
methods_fit <- function(ds, agd, A) {
  x <- as.matrix(ds[, X]); a <- ds$trt == A; w <- maic_w(x, agd$xbar)
  bc <- elo(agd$r[["ETN"]], agd$n[["ETN"]]) - elo(agd$r[["PBO"]], agd$n[["PBO"]])
  b <- lfit(ds$y, cbind(1, as.numeric(a), x))
  g <- function(t) lo(sum(w * stats::plogis(cbind(1, t, x) %*% b)) / sum(w))
  la <- c(bucher = elo(sum(ds$y[a]), sum(a)), maic = elo(sum(w[a] * ds$y[a]), sum(w[a])), stc_marg = g(1))
  lc <- c(bucher = elo(sum(ds$y[!a]), sum(!a)), maic = elo(sum(w[!a] * ds$y[!a]), sum(w[!a])), stc_marg = g(0))
  list(rel = c(la - lc - bc, stc_cond = b[[2]] - bc), la = la, lc = lc,
       ess = sum(w)^2 / sum(w^2) / length(w), bal = max(abs(colSums(w * x) / sum(w) - agd$xbar) / apply(x, 2, stats::sd)))
}

## The references: M's full data.
references <- function(dm, A) {
  l <- function(t) elo(sum(dm$y[dm$trt == t]), sum(dm$trt == t)); p <- function(t) mean(dm$y[dm$trt == t])
  k <- dm$trt %in% c(A, "PBO"); ab <- dm$trt %in% c(A, "ETN")
  b <- lfit(dm$y[k], cbind(1, as.numeric(dm$trt[k] == A), as.matrix(dm[k, X])))
  rd <- stats::lm.fit(cbind(1, as.numeric(dm$trt[ab] == A), as.matrix(dm[ab, X])), dm$y[ab])$coefficients[[2]]
  c(marg = l(A) - l("ETN"), cond = b[[2]] - (l("ETN") - l("PBO")), lA = l(A), lC = l("PBO"), rd_marg = p(A) - p("ETN"), rd_cond = rd)
}

## Every discrepancy for one (resampled) data set. Relative: each method against
## its own reference; stc_cond also against the marginal one (the mismatch).
stats_one <- function(ds, dm, A) {
  f <- methods_fit(ds, mask(dm), A); r <- references(dm, A); m <- c("bucher", "maic", "stc_marg")
  c(stats::setNames(f$rel[m] - r[["marg"]], paste0("rel_", m)), rel_stc_cond = f$rel[["stc_cond"]] - r[["cond"]],
    rel_stc_cond_vs_marg = f$rel[["stc_cond"]] - r[["marg"]],
    stats::setNames(f$la - r[["lA"]], paste0("armA_", m)), stats::setNames(f$lc - r[["lC"]], paste0("armC_", m)),
    gap_logor = r[["cond"]] - r[["marg"]], gap_rd = r[["rd_cond"]] - r[["rd_marg"]],
    est_maic = f$rel[["maic"]], ref_marg = r[["marg"]], ess = f$ess, bal = f$bal)
}

rs <- function(d) d[unlist(lapply(split(seq_len(nrow(d)), d$trt), function(i) i[sample.int(length(i), length(i), replace = TRUE)]), use.names = FALSE), ]

## One unit: point values and N_BOOT joint bootstrap draws (failed draws kept as NA).
one_unit <- function(u, n_boot = N_BOOT) {
  dd <- unit_data(u); self <- u$kind == "self"
  pt <- stats_one(dd$ds, dd$dm, u$A)
  bt <- t(vapply(seq_len(n_boot), function(b) tryCatch({ dm <- rs(dd$dm)
    ds <- if (self) dm[dm$trt %in% c(u$A, "PBO"), ] else rs(dd$ds); stats_one(ds, dm, u$A) },
    error = function(e) rep(NA_real_, length(pt))), numeric(length(pt))))
  colnames(bt) <- names(pt)
  list(unit = u, point = pt, boot = bt, n = c(S = nrow(dd$ds), M = nrow(dd$dm)))
}
