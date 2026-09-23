## ---------------------------------------------------------------------------
## DIA-18: repeated older-to-newer holdouts, and what their error against
## calendar gap measures.
##
## Networks (aggregate arm counts with publication year), all from installed
## packages:
##   af     multinma atrial_fibrillation (GPL-3): stroke, 26 trials 1989 to 2007;
##          study-level covariate: proportion with prior stroke
##   pso    multinma hta_psoriasis (GPL-3): PASI 75, 1988 to 2004
##   dep    netmeta Linde2015 (GPL-2 or later): response, depression, 1971 to 2012
##   copd   netmeta Baker2009 (GPL-2 or later): exacerbation, 1996 to 2008
##   smoke  metadat dat.hasselblad1998 (GPL-2 or later): cessation, 1974 to 1995
## Model: arm-level normal approximation to the empirical logit (0.5
## correction); fixed study intercepts; treatment effects against the network's
## control treatment REF; arm random effects with variance tau^2 / 2, so
## contrasts have heterogeneity tau^2 and within-study correlation 0.5 (the
## standard random-effects NMA); tau^2 by REML. In af the effect of every
## treatment against REF is modified by prior stroke (one shared interaction),
## so predictions are standardized to the held-out trial's population.
## Holdout unit (j, L): train on every trial published at least L years before
## trial j, L in LAGS, keep distinct training sets; gap = year_j minus the
## latest training year. Predict j's contrasts from the training component that
## contains j's treatments; otherwise the unit is non-estimable and counted.
## Error: e = observed minus predicted contrasts;
##   z2 = e' (V_pred + V_obs + tau2_hat H)^-1 e / df   (all four components but drift)
##   e2 = e'e / df                                     (raw)
## Statistic: OLS slope of z2 on gap (after subtraction) and of e2 on gap (raw).
## Null: the network's own design refitted to outcomes simulated from its
## full-data fit with no drift; positive control: the same with every effect
## against REF drifting DRIFT per year, sign random per treatment.
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261218L; LAGS <- c(0, 3, 6, 10, 15); R_NULL <- 400L; R_POS <- 200L; DRIFT <- 0.03
NETS <- local({ e <- new.env()
  utils::data(list = c("atrial_fibrillation", "hta_psoriasis"), package = "multinma", envir = e)
  utils::data(list = c("Linde2015", "Baker2009"), package = "netmeta", envir = e)
  utils::data(list = "dat.hasselblad1998", package = "metadat", envir = e)
  af <- e$atrial_fibrillation; L <- e$Linde2015; h <- e$hta_psoriasis; b <- e$Baker2009; s <- e$dat.hasselblad1998
  nets <- list(af = data.frame(study = as.character(af$studyc), year = af$year, trt = af$trtc, r = af$r, n = af$n, x = af$stroke),
    pso = data.frame(study = h$studyc, year = h$year, trt = h$trtc, r = h$PASI75, n = h$sample_size, x = NA_real_),
    dep = do.call(rbind, lapply(1:3, function(k) data.frame(study = as.character(L$id), year = L$year, trt = L[[paste0("treatment", k)]],
                                                            r = L[[paste0("resp", k)]], n = L[[paste0("n", k)]], x = NA_real_))),
    copd = data.frame(study = b$study, year = b$year, trt = b$treatment, r = b$exac, n = b$total, x = NA_real_),
    smoke = data.frame(study = as.character(s$study), year = s$year, trt = s$trt, r = s$xi, n = s$ni, x = NA_real_))
  lapply(nets, function(d) { d <- d[!is.na(d$r) & !is.na(d$n) & !is.na(d$trt) & d$trt != "", ]
    d <- d[d$study %in% names(which(table(d$study) >= 2)), ]; d$trt <- as.character(d$trt); d[order(d$year, d$study), ] })
})
REFS <- c(af = "Placebo/Standard care", pso = "Supportive care", dep = "Placebo", copd = "Placebo", smoke = "no_contact")
stopifnot(all(vapply(names(NETS), function(n) REFS[[n]] %in% NETS[[n]]$trt, TRUE)))
prep <- function(d) { d$yl <- log((d$r + 0.5) / (d$n - d$r + 0.5)); d$v <- 1 / (d$r + 0.5) + 1 / (d$n - d$r + 0.5); d }

## The training component that contains treatments tt.
component <- function(d, tt) { seen <- tt; repeat { nw <- unique(d$trt[d$study %in% d$study[d$trt %in% seen]]); if (all(nw %in% seen)) break; seen <- union(seen, nw) }
  d[d$trt %in% seen, ] }

## Random-effects NMA with fixed study intercepts; zc: study-level covariates
## (columns of d) that modify every treatment's effect against ref.
fit_nma <- function(d, ref, zc = character(0)) {
  tr <- setdiff(sort(unique(d$trt)), ref); act <- as.numeric(d$trt != ref)
  zc <- zc[vapply(zc, function(z) ref %in% d$trt && stats::var(tapply(d[[z]], d$study, `[`, 1)) > 0, TRUE)]
  Xt <- outer(d$trt, tr, "==") * 1; colnames(Xt) <- tr
  st <- unique(d$study); Xs <- outer(d$study, st, "==") * 1; colnames(Xs) <- paste0("s:", st)
  X <- cbind(Xs, Xt, matrix(vapply(zc, function(z) act * d[[z]], numeric(nrow(d))), nrow(d), dimnames = list(NULL, zc)))
  if (qr(X)$rank < ncol(X)) { if (!length(zc)) stop("rank-deficient design"); return(fit_nma(d, ref)) }
  ns <- length(st)
  gls <- function(t2) { w <- 1 / (d$v + t2 / 2); P <- crossprod(X * w, X); b <- solve(P, crossprod(X * w, d$yl)); list(P = P, b = b, w = w) }
  reml <- function(t2) { f <- gls(t2); -0.5 * (sum(log(d$v + t2 / 2)) + as.numeric(determinant(f$P)$modulus) + sum(f$w * (d$yl - X %*% f$b)^2)) }
  t2 <- if (nrow(d) > ncol(X)) stats::optimize(reml, c(0, 4), maximum = TRUE)$maximum else 0
  f <- gls(t2); k <- -(seq_len(ns)); V <- solve(f$P)
  list(coef = drop(f$b)[k], vcov = V[k, k, drop = FALSE], alpha = drop(f$b)[seq_len(ns)], tau2 = t2, trt = tr, zc = zc, ref = ref)
}

## Predict held-out trial dj's contrasts (against its first arm) from fit f.
predict_err <- function(f, dj) {
  dj <- dj[order(dj$trt != f$ref), ]; k <- nrow(dj); nm <- c(f$trt, f$zc)
  row <- function(i) { l <- stats::setNames(numeric(length(nm)), nm); if (dj$trt[i] != f$ref) l[dj$trt[i]] <- 1
    for (z in f$zc) l[z] <- (dj$trt[i] != f$ref) * dj[[z]][i]; l }
  L <- matrix(vapply(2:k, function(i) row(i) - row(1), numeric(length(nm))), k - 1, length(nm), byrow = TRUE)
  e <- (dj$yl[-1] - dj$yl[1]) - drop(L %*% f$coef[nm])
  S <- L %*% f$vcov[nm, nm] %*% t(L) + diag(dj$v[-1], k - 1) + dj$v[1] + f$tau2 * (diag(0.5, k - 1) + 0.5)
  c(z2 = drop(t(e) %*% solve(S, e)) / (k - 1), e2 = sum(e^2) / (k - 1), df = k - 1)
}

## Holdout units of a network design: (j, lag) with distinct training sets.
units_for <- function(d) { st <- unique(d[, c("study", "year")])
  do.call(rbind, lapply(st$study, function(j) { yj <- st$year[st$study == j]
    u <- do.call(rbind, lapply(LAGS, function(L) { tr <- st$study[st$study != j & st$year <= yj - L]
      if (length(tr) < 1) NULL else data.frame(j = j, lag = L, gap = yj - max(st$year[st$study %in% tr]), key = paste(sort(tr), collapse = "|")) }))
    if (is.null(u)) NULL else u[!duplicated(u$key), ] })) }

holdouts <- function(d, net) { d <- prep(d); u <- units_for(d); zc <- if (net == "af") "x" else character(0); cache <- new.env()
  out <- t(vapply(seq_len(nrow(u)), function(i) { dj <- d[d$study == u$j[i], ]; tr <- d[d$study %in% strsplit(u$key[i], "|", fixed = TRUE)[[1]], ]
    cm <- component(tr, dj$trt[1]); if (!all(dj$trt %in% cm$trt)) return(c(z2 = NA_real_, e2 = NA_real_, df = NA_real_))
    ck <- paste(u$key[i], paste(sort(unique(cm$trt)), collapse = "|"))
    f <- if (!is.null(cache[[ck]])) cache[[ck]] else (cache[[ck]] <- tryCatch(fit_nma(cm, if (REFS[[net]] %in% cm$trt) REFS[[net]] else sort(unique(cm$trt))[1], zc), error = function(e) NULL))
    if (is.null(f)) c(z2 = NA_real_, e2 = NA_real_, df = -1) else predict_err(f, dj) }, numeric(3)))
  cbind(u[, c("j", "lag", "gap")], out) }

slope <- function(y, x) { ok <- is.finite(y); if (sum(ok) < 3 || stats::var(x[ok]) == 0) NA_real_ else unname(stats::coef(stats::lm(y[ok] ~ x[ok]))[2]) }
naive_p <- function(y, x) { ok <- is.finite(y); s <- summary(stats::lm(y[ok] ~ x[ok]))$coefficients; if (nrow(s) < 2) NA_real_ else stats::pt(s[2, 3], sum(ok) - 2, lower.tail = FALSE) }
summarize_h <- function(h) c(S = slope(h$z2, h$gap), S_raw = slope(h$e2, h$gap), p_raw = naive_p(h$e2, h$gap),
                             same_era = mean(h$z2[h$gap <= 2], na.rm = TRUE), n_same = sum(is.finite(h$z2) & h$gap <= 2),
                             n_est = sum(is.finite(h$z2)), n_nonest = sum(is.na(h$df)), n_fitfail = sum(h$df %in% -1))

## Outcomes simulated on the network's own design from its full-data fit, with
## drift `rate` per year (sign random per treatment) in every effect against REF.
simulate_net <- function(d, net, rate = 0) {
  d <- prep(d); f <- fit_nma(d, REFS[[net]], if (net == "af") "x" else character(0)); act <- d$trt != f$ref
  s <- stats::setNames(sample(c(-1, 1), length(f$trt), replace = TRUE), f$trt)
  mu <- f$alpha[paste0("s:", d$study)] + ifelse(act, f$coef[d$trt], 0) + if (length(f$zc)) act * f$coef[["x"]] * d$x else 0
  mu <- mu + ifelse(act, rate * s[d$trt] * (d$year - stats::median(d$year)), 0) + stats::rnorm(nrow(d), 0, sqrt(f$tau2 / 2))
  d$r <- stats::rbinom(nrow(d), d$n, stats::plogis(mu)); d[, c("study", "year", "trt", "r", "n", "x")]
}

## Secondary: the full-data model with a common drift per decade in every effect
## against REF (a hierarchical temporal model in its simplest form).
drift_fit <- function(d, net) { d <- prep(d); d$dec <- (d$year - stats::median(d$year)) / 10
  f <- fit_nma(d, REFS[[net]], c(if (net == "af") "x", "dec")); c(drift = f$coef[["dec"]], se = sqrt(f$vcov["dec", "dec"])) }

## Cells: per network the real holdouts, then null and drift replicates in chunks.
CHUNK <- 50L
build_grid <- function() {
  g <- do.call(rbind, lapply(names(NETS), function(n) rbind(data.frame(net = n, type = "real", chunk = 0L),
    data.frame(net = n, type = "null", chunk = seq_len(R_NULL %/% CHUNK)), data.frame(net = n, type = "pos", chunk = seq_len(R_POS %/% CHUNK)))))
  g$cell <- seq_len(nrow(g)); g
}
run_cell <- function(cc, n = CHUNK) { d <- NETS[[cc$net]]
  if (cc$type == "real") { h <- holdouts(d, cc$net); return(list(h = h, s = summarize_h(h), drift = drift_fit(d, cc$net))) }
  rate <- if (cc$type == "pos") DRIFT else 0
  list(s = t(vapply(seq_len(n), function(k) tryCatch(summarize_h(holdouts(simulate_net(d, cc$net, rate), cc$net)), error = function(e) rep(NA_real_, 8)), numeric(8))))
}
