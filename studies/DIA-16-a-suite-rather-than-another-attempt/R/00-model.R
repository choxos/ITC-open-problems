## ---------------------------------------------------------------------------
## DIA-16: a bridge-deletion suite with individual data on both sides of the gap.
##
## Data: multinma 0.9.1 (GPL-3), both simulated individual data.
##   pso   plaque_psoriasis_ipd: UNCOVER-1, UNCOVER-2, UNCOVER-3 and IXORA-S; PASI 75; covariates
##         durnpso, prevsys, bsa, weight, psa.
##   ndmm  ndmm_ipd: Attal2012, McCarthy2012, Palumbo2014, lenalidomide versus
##         placebo; progression-free survival; covariates age, iss_stage3,
##         response_cr_vgpr, male.
## Unit (net, S, M, A, B): S != M; A an arm of both; B another arm of M. Every
## path between S and M is deleted: S keeps only its A arm; M keeps only B's
## outcomes, plus its covariate means over its arms other than A, as published.
## M's A arm is withheld. The bridge carries S's A arm into M's population.
## Reference: M's randomized A versus B (log OR for pso, Cox log HR for ndmm).
## Methods: naive (S's A arm as observed: absolute outcomes exchangeable across
## trials, the random-baseline assumption without a model) and maic (the
## matching bridge: S's A arm weighted to M's means by method of moments).
## For a binary outcome the discrepancy is exactly the arm-level transport error
## of A, logit p_A(S, weighted) - logit p_A(M), because M's B arm cancels.
## Stratifiers measured before recovery: separation (root mean square of the
## standardized differences between S's A arm means and M's published means)
## and overlap (MAIC effective sample share).
## Uncertainty: joint bootstrap of S's A arm and M's arms within arm; SE of a
## discrepancy is the interquartile range of its bootstrap distribution / 1.349.
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(survival))
MASTER_SEED <- 20261216L; N_BOOT <- 1000L; R_NULL <- 40L; B_NULL <- 200L; TOL <- log(1.5)
NET <- local({ e <- new.env(); utils::data(list = c("plaque_psoriasis_ipd", "ndmm_ipd"), package = "multinma", envir = e)
  xp <- c("durnpso", "prevsys", "bsa", "weight", "psa"); p <- e$plaque_psoriasis_ipd; p <- p[stats::complete.cases(p[, c(xp, "pasi75")]), ]
  xn <- c("age", "iss_stage3", "response_cr_vgpr", "male"); n <- e$ndmm_ipd
  num <- function(d, x) vapply(d[, x], as.numeric, numeric(nrow(d)))
  list(pso = list(x = xp, d = data.frame(study = p$studyc, trt = p$trtc, y = as.numeric(p$pasi75), time = NA_real_, num(p, xp))),
       ndmm = list(x = xn, d = data.frame(study = as.character(n$study), trt = as.character(n$trt), y = n$status, time = n$eventtime, num(n, xn)))) })
SHIFT <- list(pso = function(d) d$weight >= 100, ndmm = function(d) d$iss_stage3 == 1)

## Every ordered (S, M, A, B) in both networks, then 4 positive-control units
## with M restricted to a prognostic subgroup.
build_grid <- function() {
  g <- do.call(rbind, lapply(names(NET), function(nt) { arms <- lapply(split(NET[[nt]]$d$trt, NET[[nt]]$d$study), unique)
    do.call(rbind, lapply(names(arms), function(S) do.call(rbind, lapply(setdiff(names(arms), S), function(M)
      do.call(rbind, lapply(intersect(arms[[S]], arms[[M]]), function(a) data.frame(net = nt, S = S, M = M, A = a, B = setdiff(arms[[M]], a), kind = "main"))))))) }))
  g <- rbind(g, data.frame(net = c("pso", "pso", "ndmm", "ndmm"), S = c("UNCOVER-1", "UNCOVER-1", "Attal2012", "Attal2012"),
                           M = c("UNCOVER-2", "UNCOVER-3", "McCarthy2012", "Palumbo2014"), A = c("IXE_Q2W", "IXE_Q2W", "Len", "Len"),
                           B = c("PBO", "PBO", "Pbo", "Pbo"), kind = "shift"))
  g$unit <- seq_len(nrow(g)); rownames(g) <- NULL; g
}
## Null control: one trial split at random into halves within arm; half 1's A arm
## is bridged to half 2, whose own A versus B is the reference. Zero separation.
NULL_SET <- data.frame(net = c(rep("pso", 4), rep("ndmm", 3)),
  T = c("UNCOVER-1", "UNCOVER-2", "UNCOVER-3", "IXORA-S", "Attal2012", "McCarthy2012", "Palumbo2014"),
  A = c("IXE_Q2W", "IXE_Q2W", "IXE_Q2W", "IXE_Q2W", "Len", "Len", "Len"), B = c("PBO", "ETN", "ETN", "UST", "Pbo", "Pbo", "Pbo"))

elo <- function(r, n) log((r + 0.5) / (n - r + 0.5))
rse <- function(v) stats::IQR(v, na.rm = TRUE) / 1.349
maic_w <- function(x, target) {
  s <- apply(x, 2, stats::sd); z <- sweep(sweep(x, 2, target), 2, s, "/")
  o <- stats::optim(numeric(ncol(z)), function(a) sum(exp(z %*% a)), function(a) colSums(z * drop(exp(z %*% a))),
                    method = "BFGS", control = list(maxit = 1000, reltol = 1e-14))
  w <- drop(exp(z %*% o$par)); w / mean(w)
}
rs <- function(d) d[unlist(lapply(split(seq_len(nrow(d)), d$trt), function(i) i[sample.int(length(i), length(i), replace = TRUE)]), use.names = FALSE), ]

unit_data <- function(u) { d <- NET[[u$net]]$d; dm <- d[d$study == u$M, ]
  if (u$kind == "shift") dm <- dm[SHIFT[[u$net]](dm), ]
  list(sa = d[d$study == u$S & d$trt == u$A, ], dm = dm) }
## What survives the deletion of every S to M path.
mask <- function(dm, u) list(b = dm[dm$trt == u$B, c("y", "time")], xbar = colMeans(dm[dm$trt != u$A, NET[[u$net]]$x, drop = FALSE]))
## A versus B: arm a (weights wa) against arm b.
eff <- function(a, wa, b, net) if (net == "pso") elo(sum(wa * a$y), sum(wa)) - elo(sum(b$y), nrow(b)) else
  unname(stats::coef(coxph(Surv(c(a$time, b$time), c(a$y, b$y)) ~ rep(1:0, c(nrow(a), nrow(b))), weights = c(wa, rep(1, nrow(b))))))

## In the myeloma shift units M is all ISS stage III, a published mean of 1 that
## method of moments cannot reach, so ISS stage leaves MAIC's matching set there.
xset <- function(u) if (identical(u$kind, "shift") && u$net == "ndmm") setdiff(NET$ndmm$x, "iss_stage3") else NET[[u$net]]$x
stats_one <- function(sa, dm, u) {
  x <- xset(u); ms <- mask(dm, u); ms$xbar <- ms$xbar[x]; xa <- as.matrix(sa[, x]); w <- maic_w(xa, ms$xbar)
  ref <- eff(dm[dm$trt == u$A, ], rep(1, sum(dm$trt == u$A)), ms$b, u$net)
  en <- eff(sa, rep(1, nrow(sa)), ms$b, u$net); em <- eff(sa, w, ms$b, u$net)
  c(ref = ref, est_naive = en, est_maic = em, d_naive = en - ref, d_maic = em - ref, ess = sum(w)^2 / sum(w^2) / length(w),
    bal = max(abs(colSums(w * xa) / sum(w) - ms$xbar) / apply(xa, 2, stats::sd)), sep = sqrt(mean(((colMeans(xa) - ms$xbar) / apply(xa, 2, stats::sd))^2)))
}

## One unit: point values, N_BOOT joint bootstrap draws (failed draws kept as NA),
## and the published ground truth (what M reports, the reference).
one_unit <- function(u, n_boot = N_BOOT) {
  dd <- unit_data(u); pt <- stats_one(dd$sa, dd$dm, u)
  bt <- t(vapply(seq_len(n_boot), function(b) tryCatch(stats_one(rs(dd$sa), rs(dd$dm), u), error = function(e) rep(NA_real_, length(pt))), numeric(length(pt))))
  colnames(bt) <- names(pt); ms <- mask(dd$dm, u)
  list(unit = u, point = pt, boot = bt, published = c(nB = nrow(ms$b), eventsB = sum(ms$b$y), ms$xbar), nS = nrow(dd$sa), nM = nrow(dd$dm))
}

## One half split: z of each discrepancy with B_NULL bootstrap draws.
null_split <- function(k, n_boot = B_NULL) {
  v <- NULL_SET[k, ]; d <- NET[[v$net]]$d; d <- d[d$study == v$T, ]
  h <- unlist(lapply(split(seq_len(nrow(d)), d$trt), function(i) i[sample.int(length(i), length(i) %/% 2)]), use.names = FALSE)
  sa <- d[h, ][d$trt[h] == v$A, ]; dm <- d[-h, ]; u <- list(net = v$net, A = v$A, B = v$B)
  pt <- stats_one(sa, dm, u)[c("d_naive", "d_maic")]
  bt <- vapply(seq_len(n_boot), function(b) tryCatch(stats_one(rs(sa), rs(dm), u)[c("d_naive", "d_maic")], error = function(e) c(d_naive = NA_real_, d_maic = NA_real_)), numeric(2))
  pt / apply(bt, 1, rse)
}
