## ---------------------------------------------------------------------------
## OUT-13: is the spread of a reconstruction ensemble the reconstruction error?
##
## One arm, n = 250, Weibull event times (shape 1.2, median 18 months), follow-up
## to 36 months. The publication is the Kaplan-Meier figure, a risk table and the
## total number of events. The figure is digitized by reading the curve at each
## pixel column of a W x H plot and rounding to the pixel grid. Guyot's algorithm
## (IPDfromKM) reconstructs individual data, and three functionals are computed on
## the reconstruction: RMST to 24 months, KM survival at 12 months and Weibull
## survival extrapolated to 48 months.
##
## The reconstruction error of a functional is its value on the reconstruction
## minus its value on the true individual data. An ensemble is calibrated when its
## between-reconstruction variance B matches that error:
##   ratio = mean(B) (1 + 1/M) / var(ensemble mean - true-data value),
## which is 1 for draws from the posterior of the true data given the publication.
## Two ensembles: analyst variants (digitized point count and whether the event
## total is supplied), and observation-model draws (pixel positions redrawn from
## the digitization model, censorings placed at random within risk-table
## intervals). Guyot's rounding of event counts stays deterministic in both.
## ---------------------------------------------------------------------------

suppressPackageStartupMessages({ library(survival); library(IPDfromKM) })
MASTER_SEED <- 20261040L
N <- 250L; SHAPE <- 1.2; MED <- 18; SCALE <- MED / log(2)^(1 / SHAPE)
F_MAX <- 36; TAU <- 24; T_MS <- 12; T_EXT <- 48
M_CAL <- 20L; N_SIM <- 300L
RES <- list(fine = c(W = 1500, H = 1000), coarse = c(W = 300, H = 200))
EST <- c("rmst24", "s12", "s48")

build_grid <- function() {
  g <- expand.grid(res = names(RES), table = c(3, 6, 0), cens = c("spread", "clustered"),
                   KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$ctrl <- "none"
  g <- rbind(g, data.frame(res = "fine", table = 1, cens = "spread", ctrl = "null"))
  g$cell <- seq_len(nrow(g)); g
}

S_pop <- function(t) exp(-(t / SCALE)^SHAPE)
truth <- function() c(rmst24 = stats::integrate(S_pop, 0, TAU)$value, s12 = S_pop(T_MS), s48 = S_pop(T_EXT))

## Administrative censoring from uniform accrual over 24 months. Clustered: 30% of
## patients also drop out just before a 6-monthly visit, so censoring within a
## risk-table interval is far from uniform.
draw <- function(cell) {
  t <- stats::rweibull(N, SHAPE, SCALE); cz <- stats::runif(N, F_MAX - 24, F_MAX)
  if (cell$cens == "clustered") {
    drop <- stats::runif(N) < 0.3
    cz[drop] <- pmin(cz[drop], 6 * sample.int(5, sum(drop), replace = TRUE) - stats::runif(sum(drop)))
  }
  data.frame(time = pmin(t, cz), status = as.integer(t <= cz))
}

## The publication: the curve read at pixel-column centers with ordinates rounded to
## the pixel grid; the risk table; the event total. The digitized curve is kept as
## the full column trace and as its step corners (first and last column of each
## level), which carry the same information.
publish <- function(d, cell) {
  r <- RES[[cell$res]]; f <- survfit(Surv(time, status) ~ 1, data = d)
  tc <- (seq_len(r[["W"]]) - 0.5) * F_MAX / r[["W"]]; tc <- tc[tc <= max(d$time)]
  sc <- summary(f, times = tc, extend = TRUE)$surv
  trace <- data.frame(time = c(0, tc), surv = c(1, round(sc * r[["H"]]) / r[["H"]]))
  lev <- cumsum(c(TRUE, diff(trace$surv) != 0))
  keep <- !duplicated(lev) | !duplicated(lev, fromLast = TRUE)
  tr <- if (cell$table > 0) seq(0, max(d$time), by = cell$table) else NULL
  nr <- if (length(tr)) vapply(tr, function(u) sum(d$time >= u), 0) else NULL
  list(trace = trace, pts = trace[keep, ], trisk = tr, nrisk = nr, events = sum(d$status),
       dx = F_MAX / r[["W"]], dy = 1 / r[["H"]])
}

## Guyot's algorithm as IPDfromKM implements it spaces the censorings evenly in each
## risk-table interval. The draw version places each one uniformly at random.
getIPD_draw <- IPDfromKM::getIPD
body(getIPD_draw) <- parse(text = sub("j * (TT[upp[(i)]] - TT[low[i]])/(ncen + 1)",
  "stats::runif(1) * (TT[upp[(i)]] - TT[low[i]])",
  paste(deparse(body(IPDfromKM::getIPD), width.cutoff = 500), collapse = "\n"), fixed = TRUE))[[1]]
stopifnot(!identical(body(getIPD_draw), body(IPDfromKM::getIPD)))

reconstruct <- function(pts, pub, events = pub$events, draw_cens = FALSE) {
  setTimeLimit(elapsed = 20, transient = TRUE); on.exit(setTimeLimit(elapsed = Inf))
  p <- IPDfromKM::preprocess(dat = pts, trisk = pub$trisk, nrisk = pub$nrisk, totalpts = N, maxy = 1)
  ipd <- if (draw_cens) getIPD_draw(prep = p, armID = 1, tot.events = events) else
    IPDfromKM::getIPD(prep = p, armID = 1, tot.events = events)
  data.frame(time = ipd$IPD$time, status = ipd$IPD$status)
}

## The three functionals with their sampling standard errors.
functionals <- function(d) {
  f <- survfit(Surv(time, status) ~ 1, data = d)
  rm <- summary(f, rmean = TAU)$table; s <- summary(f, times = T_MS, extend = TRUE)
  w <- survreg(Surv(pmax(time, 1e-3), status) ~ 1, data = d, dist = "weibull")
  mu <- stats::coef(w)[[1]]; sg <- w$scale; g <- (log(T_EXT) - mu) / sg; S48 <- exp(-exp(g))
  grad <- c(-1 / sg, -g) * (-exp(g) * S48)     # dS/d(mu), dS/d(log sigma)
  c(rmst24 = rm[["rmean"]], s12 = s$surv, s48 = S48,
    se_rmst24 = rm[["se(rmean)"]], se_s12 = s$std.err, se_s48 = sqrt(drop(t(grad) %*% w$var %*% grad)))
}

## Posterior draw of the true curve given the digitized corners, under the known
## observation model: a level first seen at column center t started in
## (t - dx, t], and its ordinate is uniform within its pixel row.
jitter_pts <- function(pub) {
  p <- pub$pts; lev <- cumsum(c(TRUE, diff(p$surv) != 0)); nl <- max(lev)
  dy <- stats::runif(nl, -0.5, 0.5) * pub$dy; dx <- c(0, stats::runif(nl - 1)) * pub$dx
  first <- !duplicated(lev)
  out <- data.frame(time = p$time - ifelse(first, dx[lev], 0), surv = pmin(1, p$surv + dy[lev]))
  out$surv[1] <- 1; out$time[1] <- 0
  out <- out[order(out$time), ]; out$surv <- cummin(pmax(out$surv, 0)); out
}

ens_summary <- function(v) {
  v <- do.call(rbind, v)
  data.frame(estimand = EST, est = colMeans(v[, EST, drop = FALSE]),
             w = colMeans(v[, paste0("se_", EST), drop = FALSE]^2),
             b = apply(v[, EST, drop = FALSE], 2, stats::var), m = nrow(v))
}

one_rep <- function(cell) {
  d <- draw(cell); pub <- publish(d, cell)
  fo <- functionals(d); fs <- functionals(reconstruct(pub$pts, pub))
  row <- function(method, f) data.frame(method = method, estimand = EST, est = f[EST],
                                        w = f[paste0("se_", EST)]^2, b = NA, m = 1)
  ## Analyst variants: 30, 60 or 120 digitized points (evenly spaced along the
  ## corners), with the event total supplied or not.
  sub <- function(k) { i <- unique(round(seq(1, nrow(pub$pts), length.out = min(k, nrow(pub$pts))))); pub$pts[i, ] }
  tv <- lapply(seq_len(6), function(k) tryCatch(functionals(reconstruct(sub(c(30, 60, 120)[(k - 1) %% 3 + 1]), pub,
    events = if (k <= 3) pub$events else NULL)), error = function(e) NULL))
  cv <- lapply(seq_len(M_CAL), function(k) tryCatch(functionals(reconstruct(jitter_pts(pub), pub, draw_cens = TRUE)),
    error = function(e) NULL))
  rbind(row("oracle", fo), row("single", fs),
        data.frame(method = "variants", ens_summary(Filter(Negate(is.null), tv))),
        data.frame(method = "draws", ens_summary(Filter(Negate(is.null), cv))))
}
