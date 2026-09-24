## ---------------------------------------------------------------------------
## CMP-17: does the tail's reconstruction error reach a downstream comparison?
##
## Network A, B, C with a common comparator. Study 1: individual data, A versus
## C. Study 2: B versus C, published as a Kaplan-Meier figure of both arms with a
## risk table and event totals, and reconstructed arm by arm with Guyot's
## algorithm. The publication model is OUT-13's (R/00-model.R there, sourced
## read-only): Weibull events (shape 1.2, control median 18 months), OUT-13's
## censoring mechanisms, pixel-rounded figure. N_ARM patients per arm in both
## studies (250, or 1000 in the large-trial cell). Hazard ratios versus C: A 0.7,
## B 0.8 (the second null: both 1).
## Estimands, A versus B in study 2's population (C's law is common, so anchored
## differences of arm functionals estimate them): log hazard ratio; RMST
## difference to 24 months; survival differences at 12 (early), 30 (late, few
## at risk) and 48 months (extrapolated). Truth from the generating Weibulls.
## Three downstream routes on the same data:
##   joint_study   Weibull likelihood over both studies with study-specific
##                 shapes, so study 2's extrapolation rests on its reconstructed
##                 rows alone; all five estimands
##   joint_common  the same with a common shape, pinned mostly by study 1
##   km            anchored (Bucher) differences of arm Kaplan-Meier functionals
##                 with Greenwood variances, and a study-stratified Cox log
##                 hazard ratio; RMST, 12 and 30 months
##   arm           upstream reference: study 2's control arm alone, Weibull
##                 survival at 48 months by OUT-13's functionals(), the quantity
##                 OUT-13 found most exposed; truth S_pop(48)
## Methods: oracle (study 2's true data), single (one reconstruction of each arm
## from all digitized corners), draws (M_DRAW reconstructions of each arm from
## OUT-13's observation model, each refitted and pooled by Rubin's rules; OUT-13
## found them to understate the extrapolated tail's error).
## ---------------------------------------------------------------------------

source("../OUT-13-an-ensemble-that-is-not-an-imputation/R/00-model.R")
draw_out13 <- draw
MASTER_SEED <- 20261317L; N_SIM <- 500L; M_DRAW <- 10L; T_LATE <- 30
T_NR <- c(15, 33)   # number-at-risk check times, midway between 6-monthly table times so no table pins them
EST_C <- c("loghr", "rmst24", "s12", "s30", "s48")
HR <- list(effect = c(A = 0.7, B = 0.8), null = c(A = 1, B = 1))

build_grid <- function() {
  g <- expand.grid(res = "coarse", table = c(6, 0), cens = c("spread", "clustered"), KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$n <- 250L; g$effect <- "effect"; g$ctrl <- "none"
  g <- rbind(g, data.frame(res = "fine", table = 1, cens = "spread", n = 250L, effect = "effect", ctrl = "null"),
                data.frame(res = "coarse", table = 0, cens = "clustered", n = 250L, effect = "null", ctrl = "null_effect"),
                data.frame(res = "coarse", table = 0, cens = "clustered", n = 1000L, effect = "effect", ctrl = "large"))
  g$cell <- seq_len(nrow(g)); g
}

## Weibull survival and RMST to TAU in closed form, scale lam and shape k.
S_wb <- function(t, lam, k) exp(-(t / lam)^k)
rmst_wb <- function(lam, k) lam * gamma(1 + 1 / k) * stats::pgamma((TAU / lam)^k, 1 / k)
contrast <- function(lamA, lamB, k) c(loghr = -k * (log(lamA) - log(lamB)), rmst24 = rmst_wb(lamA, k) - rmst_wb(lamB, k),
  s12 = S_wb(T_MS, lamA, k) - S_wb(T_MS, lamB, k), s30 = S_wb(T_LATE, lamA, k) - S_wb(T_LATE, lamB, k), s48 = S_wb(T_EXT, lamA, k) - S_wb(T_EXT, lamB, k))
truth <- function(cell) { h <- HR[[cell$effect]]; contrast(SCALE * h[["A"]]^(-1 / SHAPE), SCALE * h[["B"]]^(-1 / SHAPE), SHAPE) }

## One arm: OUT-13's draw() with the arm's Weibull scale and size bound as
## arguments, so the censoring mechanism is OUT-13's own.
draw_arm <- function(cell, hr) { f <- draw_out13; formals(f) <- c(formals(f), list(SCALE = SCALE * hr^(-1 / SHAPE), N = cell$n)); f(cell) }
draw <- function(cell) { h <- HR[[cell$effect]]
  list(s1 = rbind(data.frame(draw_arm(cell, 1), trt = "C", study = 1), data.frame(draw_arm(cell, h[["A"]]), trt = "A", study = 1)),
       c2 = draw_arm(cell, 1), b2 = draw_arm(cell, h[["B"]])) }

## OUT-13's reconstruct() with the arm size passed in and a CPU-time guard in place
## of its 20-second wall-clock guard, which fired under machine load.
reconstruct <- function(pts, pub, n, events = pub$events, draw_cens = FALSE) {
  setTimeLimit(cpu = 60, transient = TRUE); on.exit(setTimeLimit(cpu = Inf))
  p <- IPDfromKM::preprocess(dat = pts, trisk = pub$trisk, nrisk = pub$nrisk, totalpts = n, maxy = 1)
  ipd <- if (draw_cens) getIPD_draw(prep = p, armID = 1, tot.events = events) else IPDfromKM::getIPD(prep = p, armID = 1, tot.events = events)
  data.frame(time = ipd$IPD$time, status = ipd$IPD$status)
}

## All three routes; estimands and variances (delta method on the joint routes);
## study 2's number at risk early and late, the n_j of DESIGN.md section 2.
fit_all <- function(s1, c2, b2) {
  d <- rbind(s1, data.frame(c2, trt = "C", study = 2), data.frame(b2, trt = "B", study = 2))
  d$trt <- factor(d$trt, levels = c("C", "A", "B")); d$study <- factor(d$study); d$time <- pmax(d$time, 1e-3)
  joint <- function(route, fml) { f <- survival::survreg(fml, data = d, dist = "weibull")
    th <- c(stats::coef(f), log(f$scale)); V <- stats::vcov(f); ks <- length(th)   # the last log scale is study 2's
    gf <- function(p) { lp <- p[1] + p[2]; contrast(exp(lp + p[3]), exp(lp + p[4]), exp(-p[ks])) }
    J <- vapply(seq_along(th), function(j) { h <- 1e-6 * max(1, abs(th[j])); e <- replace(numeric(ks), j, h); (gf(th + e) - gf(th - e)) / (2 * h) }, numeric(length(EST_C)))
    data.frame(route = route, estimand = EST_C, est = gf(th), w = rowSums((J %*% V) * J)) }
  arm <- function(k, s) { z <- d[d$trt == k & d$study == s, ]; sf <- survival::survfit(survival::Surv(time, status) ~ 1, data = z)
    sm <- summary(sf, times = c(T_MS, T_LATE), extend = TRUE); rm <- summary(sf, rmean = TAU)$table
    rbind(est = c(rm[["rmean"]], sm$surv), v = c(rm[["se(rmean)"]], sm$std.err)^2) }
  fa <- arm("A", 1); fc1 <- arm("C", 1); fb <- arm("B", 2); fc2 <- arm("C", 2); bu <- fa[1, ] - fc1[1, ] - fb[1, ] + fc2[1, ]; vb <- fa[2, ] + fc1[2, ] + fb[2, ] + fc2[2, ]
  cx <- survival::coxph(survival::Surv(time, status) ~ trt + strata(study), data = d); cv <- stats::vcov(cx); cc <- c(1, -1)
  out <- rbind(joint("joint_study", survival::Surv(time, status) ~ study + trt + strata(study)),
               joint("joint_common", survival::Surv(time, status) ~ study + trt),
               data.frame(route = "km", estimand = c("loghr", "rmst24", "s12", "s30"), est = c(sum(cc * stats::coef(cx)), bu), w = c(drop(t(cc) %*% cv %*% cc), vb)),
               { fc <- functionals(c2); data.frame(route = "arm", estimand = "s48", est = fc[["s48"]], w = fc[["se_s48"]]^2) })
  transform(out, nr_early = sum(c2$time >= T_NR[1]) + sum(b2$time >= T_NR[1]), nr_late = sum(c2$time >= T_NR[2]) + sum(b2$time >= T_NR[2]))
}

one_rep <- function(cell, m = M_DRAW) {
  d <- draw(cell); pc <- publish(d$c2, cell); pb <- publish(d$b2, cell); n <- cell$n
  fo <- fit_all(d$s1, d$c2, d$b2); fs <- fit_all(d$s1, reconstruct(pc$pts, pc, n), reconstruct(pb$pts, pb, n))
  dr <- Filter(Negate(is.null), lapply(seq_len(m), function(k) tryCatch(fit_all(d$s1, reconstruct(jitter_pts(pc), pc, n, draw_cens = TRUE),
    reconstruct(jitter_pts(pb), pb, n, draw_cens = TRUE)), error = function(e) NULL)))
  out <- rbind(data.frame(method = "oracle", fo, b = NA, m = 1), data.frame(method = "single", fs, b = NA, m = 1))
  if (length(dr) >= 2) { E <- sapply(dr, `[[`, "est"); W <- sapply(dr, `[[`, "w")
    out <- rbind(out, data.frame(method = "draws", fo[, c("route", "estimand")], est = rowMeans(E), w = rowMeans(W),
      nr_early = mean(sapply(dr, function(z) z$nr_early[1])), nr_late = mean(sapply(dr, function(z) z$nr_late[1])), b = apply(E, 1, stats::var), m = length(dr))) }
  out
}
