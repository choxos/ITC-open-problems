## ---------------------------------------------------------------------------
## IDN-08: is deletion recovery a property of the cut, and is it predicted by
## what can be measured across the gap before recovery?
##
## Networks (aggregate arm counts), with the study-level summaries that measure
## separation across a gap:
##   af    multinma atrial_fibrillation (GPL-3): population = prior stroke
##         proportion, design = publication year
##   dep   netmeta Linde2015 (GPL-2 or later): design = year
##   diab  multinma diabetes (GPL-3): design = follow-up years
##   copd  netmeta Baker2009 (GPL-2 or later): design = year
## A cut splits the treatments into two sets, each of at least two treatments.
## A study with arms on both sides keeps the side with more arms if that side
## has at least two, and otherwise is removed (ties removed). The cut is valid
## if every treatment keeps an arm and each side is connected. The link l is
## the cross-gap pair with the most patients in removed direct comparisons.
## Reference: the connected random-effects NMA estimate of the link (fixed study
## intercepts, arm random effects tau^2 / 2, REML), carrying its own variance.
## Bridge rb: arm-based model with exchangeable random study baselines
## (variance sigma^2) and the same arm random effects, fitted to the cut
## network by REML (the random-baseline bridge of Beliveau et al. 2017).
## Bridge rbx: rb with the baselines regressed on the separation covariates.
## z(l) = (bridge - reference) / sqrt(v_bridge + v_reference), conservative
## since both share the retained studies.
## Separations of a cut: |difference in mean study covariate between the two
## sides| / SD of that covariate across studies.
## Arm data enter as empirical logits with a 0.5 correction (normal approximation).
## ---------------------------------------------------------------------------

MASTER_SEED <- 20261219L; R_NULL <- 200L; R_POS <- 100L; GAMMA <- 0.5; MIN_CUTS <- 10L
NETS <- local({ e <- new.env()
  utils::data(list = c("atrial_fibrillation", "diabetes"), package = "multinma", envir = e)
  utils::data(list = c("Linde2015", "Baker2009"), package = "netmeta", envir = e)
  af <- e$atrial_fibrillation; L <- e$Linde2015; b <- e$Baker2009; db <- e$diabetes
  nets <- list(af = data.frame(study = as.character(af$studyc), trt = af$trtc, r = af$r, n = af$n, pop = af$stroke, des = af$year),
    dep = do.call(rbind, lapply(1:3, function(k) data.frame(study = as.character(L$id), trt = L[[paste0("treatment", k)]], r = L[[paste0("resp", k)]],
                                                            n = L[[paste0("n", k)]], pop = NA_real_, des = L$year))),
    diab = data.frame(study = db$studyc, trt = db$trtc, r = db$r, n = db$n, pop = NA_real_, des = db$time),
    copd = data.frame(study = b$study, trt = b$treatment, r = b$exac, n = b$total, pop = NA_real_, des = b$year))
  lapply(nets, function(d) { d <- d[!is.na(d$r) & !is.na(d$n) & !is.na(d$trt) & d$trt != "", ]; d$trt <- as.character(d$trt)
    d <- d[d$study %in% names(which(table(d$study) >= 2)), ]; d$yl <- log((d$r + 0.5) / (d$n - d$r + 0.5)); d$v <- 1 / (d$r + 0.5) + 1 / (d$n - d$r + 0.5); d })
})
SEPS <- lapply(NETS, function(d) c("pop", "des")[c(any(!is.na(d$pop)), TRUE)])

conn <- function(sub, M) { A <- crossprod(M[, sub, drop = FALSE]) > 0; seen <- 1
  repeat { nw <- which(colSums(A[seen, , drop = FALSE]) > 0); if (length(nw) == length(seen)) break; seen <- nw }; length(seen) == length(sub) }

## Every valid cut: side-1 treatments, the kept (study, treatment) incidence, the link.
enum_cuts <- function(d) {
  tr <- sort(unique(d$trt)); st <- unique(d$study); K <- length(tr)
  M <- unclass(table(factor(d$study, st), factor(d$trt, tr))) > 0
  out <- list()
  for (m in seq_len(2^(K - 1) - 1)) {
    s1 <- c(bitwAnd(m, 2^(0:(K - 2))) > 0, FALSE); if (sum(s1) < 2 || sum(!s1) < 2) next
    a1 <- drop(M %*% s1); a2 <- drop(M %*% !s1); cross <- a1 > 0 & a2 > 0
    Mk <- M; Mk[cross & !(a1 > a2 & a1 >= 2), s1] <- FALSE; Mk[cross & !(a2 > a1 & a2 >= 2), !s1] <- FALSE; Mk[rowSums(Mk) < 2, ] <- FALSE
    if (any(colSums(Mk) == 0) || !conn(which(s1), Mk) || !conn(which(!s1), Mk)) next
    pr <- expand.grid(t1 = tr[s1], t2 = tr[!s1], stringsAsFactors = FALSE)
    pr$n <- vapply(seq_len(nrow(pr)), function(i) { s <- st[cross & M[, pr$t1[i]] & M[, pr$t2[i]]]; sum(d$n[d$study %in% s & d$trt %in% c(pr$t1[i], pr$t2[i])]) }, 0)
    pr <- pr[order(-pr$n, pr$t1, pr$t2), ]
    out[[length(out) + 1]] <- list(side1 = tr[s1], keep = Mk, t1 = pr$t1[1], t2 = pr$t2[1], removed = sum(cross))
  }
  out
}
apply_cut <- function(d, cut) d[cut$keep[cbind(match(d$study, rownames(cut$keep)), match(d$trt, colnames(cut$keep)))], ]

## Arm-based REML fit. baseline "fixed": study intercepts (the connected NMA);
## "random": exchangeable study baselines with variance sigma^2, optionally
## regressed on study covariates zb. Returns treatment effects against ref.
fit_arm <- function(d, baseline = c("fixed", "random"), zb = character(0)) {
  baseline <- match.arg(baseline); tr <- sort(unique(d$trt)); ref <- tr[1]
  Xt <- outer(d$trt, tr[-1], "==") * 1; colnames(Xt) <- tr[-1]; st <- unique(d$study)
  X <- if (baseline == "fixed") { Xs <- outer(d$study, st, "==") * 1; colnames(Xs) <- paste0("s:", st); cbind(Xs, Xt) } else
    cbind(`(m)` = 1, as.matrix(d[, zb, drop = FALSE]), Xt)
  vinv <- function(A, s2, w, sw) { WA <- w * as.matrix(A); if (s2 == 0) return(WA); S <- rowsum(WA, d$study)[d$study, , drop = FALSE]; WA - s2 * w * S / (1 + s2 * sw) }
  core <- function(s2, t2) { w <- 1 / (d$v + t2 / 2); sw <- rowsum(w, d$study)[d$study, 1]; VX <- vinv(X, s2, w, sw); P <- crossprod(X, VX)
    b <- solve(P, crossprod(VX, d$yl)); r <- d$yl - drop(X %*% b)
    list(b = drop(b), P = P, ll = -0.5 * (sum(log(d$v + t2 / 2)) + sum(log(1 + s2 * rowsum(w, d$study)[, 1])) + as.numeric(determinant(P)$modulus) + sum(r * vinv(r, s2, w, sw)))) }
  par <- if (baseline == "fixed") c(0, if (nrow(d) > ncol(X)) stats::optimize(function(t) core(0, t^2)$ll, c(0, 2), maximum = TRUE)$maximum else 0) else
    stats::optim(c(0.5, 0.1), function(p) -core(p[1]^2, p[2]^2)$ll, method = "L-BFGS-B", lower = c(0, 0), upper = c(5, 2))$par
  f <- core(par[1]^2, par[2]^2); V <- solve(f$P); k <- colnames(X) %in% tr[-1]
  list(coef = c(stats::setNames(0, ref), f$b[k]), vcov = V, idx = which(k), ref = ref, sigma2 = par[1]^2, tau2 = par[2]^2, b = f$b)
}
contrast <- function(f, t1, t2) { l <- numeric(nrow(f$vcov)); names(l) <- rownames(f$vcov)
  if (t2 != f$ref) l[t2] <- 1; if (t1 != f$ref) l[t1] <- l[t1] - 1
  c(est = f$coef[[t2]] - f$coef[[t1]], var = drop(t(l) %*% f$vcov %*% l)) }

## Heterogeneity degrees of freedom of a side: study contrasts minus parameters.
side_df <- function(dc, trts) { s <- dc[dc$trt %in% trts, ]; sum(table(s$study) - 1) - (length(unique(s$trt)) - 1) }

## Score every cut of network d (arm data) against its connected reference.
score_cuts <- function(d, net, cuts, adjusted = TRUE) {
  full <- fit_arm(d, "fixed"); zs <- SEPS[[net]]
  st <- unique(d[, c("study", "pop", "des")]); sds <- vapply(zs, function(v) stats::sd(st[[v]]), 0)
  do.call(rbind, lapply(seq_along(cuts), function(i) { cut <- cuts[[i]]; dc <- apply_cut(d, cut); ref <- contrast(full, cut$t1, cut$t2)
    sc <- unique(dc[, c("study", "pop", "des")]); side <- tapply(dc$trt %in% cut$side1, dc$study, any)[sc$study]
    s <- vapply(zs, function(v) abs(mean(sc[[v]][side]) - mean(sc[[v]][!side])) / sds[[v]], 0)
    rb <- tryCatch(contrast(fit_arm(dc, "random"), cut$t1, cut$t2), error = function(e) c(est = NA, var = NA))
    rbx <- if (adjusted) tryCatch({ dz <- dc; for (v in zs) dz[[v]] <- (dz[[v]] - mean(st[[v]])) / sds[[v]]; contrast(fit_arm(dz, "random", zs), cut$t1, cut$t2) },
                                  error = function(e) c(est = NA, var = NA)) else c(est = NA, var = NA)
    data.frame(cut = i, t1 = cut$t1, t2 = cut$t2, removed = cut$removed, pop_sep = if ("pop" %in% zs) s[["pop"]] else NA, des_sep = s[["des"]],
               ref = ref[["est"]], e_rb = rb[["est"]] - ref[["est"]], z_rb = (rb[["est"]] - ref[["est"]]) / sqrt(rb[["var"]] + ref[["var"]]),
               e_rbx = rbx[["est"]] - ref[["est"]], z_rbx = (rbx[["est"]] - ref[["est"]]) / sqrt(rbx[["var"]] + ref[["var"]]),
               df1 = side_df(dc, cut$side1), df2 = side_df(dc, setdiff(unique(dc$trt), cut$side1))) }))
}

## Statistics over cuts (rb bridge): variance of z, and slopes of the absolute
## error |e| on the separations entered together. |z| is not used for the slopes:
## the bridge SE varies across cuts and would turn bias into precision; the null
## calibrates the |e| slopes for that variation.
cut_stats <- function(sc, net) { ok <- is.finite(sc$z_rb); zs <- SEPS[[net]]
  Xs <- as.matrix(sc[ok, paste0(zs, "_sep"), drop = FALSE]); b <- stats::coef(stats::lm(abs(sc$e_rb[ok]) ~ Xs))
  c(T_var = stats::var(sc$z_rb[ok]), T_pop = if ("pop" %in% zs) unname(b[2]) else NA_real_, T_des = unname(b[length(b)]), rej = mean(abs(sc$z_rb[ok]) > 1.96), n_ok = sum(ok)) }

## Outcomes simulated on network d's design. Baselines exchangeable (null), or
## shifted by GAMMA logits per SD of the first separation covariate, population
## in af and design elsewhere (positive control); shifting on both would let the
## two signed differences cancel within a cut.
simulate_net <- function(d, net, gamma = 0) {
  fx <- fit_arm(d, "fixed"); rb <- fit_arm(d, "random"); st <- unique(d[, c("study", "pop", "des")])
  mu <- rb$b[["(m)"]] + stats::rnorm(nrow(st), 0, sqrt(rb$sigma2))
  v <- SEPS[[net]][1]; mu <- mu + gamma * (st[[v]] - mean(st[[v]])) / stats::sd(st[[v]])
  eta <- mu[match(d$study, st$study)] + fx$coef[d$trt] + stats::rnorm(nrow(d), 0, sqrt(fx$tau2 / 2))
  d$r <- stats::rbinom(nrow(d), d$n, stats::plogis(eta)); d$yl <- log((d$r + 0.5) / (d$n - d$r + 0.5)); d$v <- 1 / (d$r + 0.5) + 1 / (d$n - d$r + 0.5); d
}

## Cells: per network the real cuts, then null and positive-control replicates in chunks.
CHUNK <- 50L
build_grid <- function() {
  g <- do.call(rbind, lapply(names(NETS), function(n) rbind(data.frame(net = n, type = "real", chunk = 0L),
    data.frame(net = n, type = "null", chunk = seq_len(R_NULL %/% CHUNK)), data.frame(net = n, type = "pos", chunk = seq_len(R_POS %/% CHUNK)))))
  g$cell <- seq_len(nrow(g)); g
}
run_cell <- function(cc, cuts, n = CHUNK) { d <- NETS[[cc$net]]
  if (cc$type == "real") { sc <- score_cuts(d, cc$net, cuts); return(list(sc = sc, s = cut_stats(sc, cc$net))) }
  gam <- if (cc$type == "pos") GAMMA else 0
  list(s = t(vapply(seq_len(n), function(k) tryCatch(cut_stats(score_cuts(simulate_net(d, cc$net, gam), cc$net, cuts, adjusted = FALSE), cc$net),
                                                    error = function(e) rep(NA_real_, 5)), numeric(5))))
}
