## Assemble the four estimators into one call per replicate.
##
## The primary target is the causal within-trial component interaction gammaW_c.
## Every method reports an estimate of it; they differ in what information is
## allowed to reach that estimate.
##
##   shared-info    one Gamma on the globally centered covariate, Wald interval
##                  from the observed information. Current practice.
##   shared-sandwich  the same point estimate with a study-cluster sandwich, so
##                  the comparison is not won merely by using a robust variance.
##   joint-split    separate gammaW and gammaB, both estimated jointly from all
##                  data. Aggregate arms can still inform gammaW through the
##                  curvature of the integrated likelihood.
##   ipd-anchored   gammaW estimated from individual data only, with a free
##                  intercept per study-arm so nothing but the randomized
##                  within-arm covariate contrast identifies it; then gammaB and
##                  the component main effects fitted to everything with gammaW
##                  held fixed, and the uncertainty stacked across the stages.

## Study-cluster sandwich for the shared model.
##
## The profiled score contributions are by study, so the twelve study scores are
## the natural clusters. The 12/11 factor is the usual small-cluster correction;
## with twelve studies it is not a rounding detail.
study_sandwich <- function(d, model, theta, H) {
  studies <- sort(unique(c(if (!is.null(d$ipd)) d$ipd$study, if (!is.null(d$agd)) d$agd$study)))
  U <- t(vapply(studies, function(s) {
    ds <- list(
      ipd = if (is.null(d$ipd)) NULL else {
        k <- d$ipd$study == s
        if (!any(k)) NULL else lapply(d$ipd, function(v) v[k])
      },
      agd = if (is.null(d$agd)) NULL else {
        k <- d$agd$study == s
        if (!any(k)) NULL else lapply(d$agd, function(v) v[k])
      })
    if (is.null(ds$ipd) && is.null(ds$agd)) return(rep(0, length(theta)))
    -make_nll(ds, model)(theta, TRUE)          # score = -gradient of nll
  }, numeric(length(theta))))
  m <- length(studies)
  B <- (m / (m - 1)) * crossprod(U)
  Hi <- tryCatch(solve(H), error = function(e) NULL)
  if (is.null(Hi)) return(NULL)
  Hi %*% B %*% t(Hi)
}

## Stage 1 of the IPD-anchored estimator: gammaW from individual data alone.
##
## A separate profiled intercept per study-ARM removes every between-arm and
## between-study contrast, so the only variation left identifying gammaW is the
## randomized comparison between covariate strata inside an arm. Aggregate data
## cannot reach this stage by construction, which is the point: it is what makes
## the estimate causal rather than partly ecological.
fit_stage1 <- function(d) {
  if (is.null(d$ipd)) return(NULL)
  ## A component that appears in no individual-data arm has no within-trial
  ## information about its interaction. Its column of the stage-1 design matrix
  ## is identically zero, and rather than let a rank-deficient fit produce a
  ## number, that component is declared not estimable. Declining to report is the
  ## behavior IDN-06 asks for: an aggregate-only interaction should be labelled,
  ## not quietly supplied from an ecological gradient.
  have <- c(A = any(d$ipd$aA == 1), B = any(d$ipd$aB == 1))
  if (!any(have)) return(NULL)
  nll <- make_nll(list(ipd = d$ipd, agd = NULL, n_study = d$n_study),
                  "stage1", group = "arm", keep = c(TRUE, have[["A"]], have[["B"]]))
  f <- fit_ml(nll, 1L + sum(have))
  if (is.null(f)) return(NULL)
  list(fit = f, nll = nll, H = obs_info(nll, f$par),
       names = c("beta", if (have[["A"]]) "gWA", if (have[["B"]]) "gWB"),
       estimable = have)
}

## Stage 2: component main effects and the across-trial slopes, with gammaW held
## at its stage-1 value and entering as a fixed offset.
##
## Needed only for the secondary marginal contrast; the primary estimand gammaW
## is complete after stage 1.
fit_stage2 <- function(d, gW) {
  offs <- function(aA, aB, x, p) (aA * gW[["A"]] + aB * gW[["B"]]) * (x - p)
  off_i  <- if (is.null(d$ipd)) NULL else with(d$ipd, offs(aA, aB, x, p))
  off_a0 <- if (is.null(d$agd)) NULL else with(d$agd, offs(aA, aB, 0, p))
  off_a1 <- if (is.null(d$agd)) NULL else with(d$agd, offs(aA, aB, 1, p))
  nll <- make_nll(d, "stage2", offset_ipd = off_i,
                  offset_agd0 = off_a0, offset_agd1 = off_a1)
  f <- fit_ml(nll, 5)
  if (is.null(f)) return(NULL)
  list(fit = f, nll = nll, H = obs_info(nll, f$par))
}

## All four estimators for one replicate.
estimate_all <- function(dat) {
  d <- prep(dat)
  z <- stats::qnorm(0.975)
  out <- list()

  add_na <- function(method, par) {
    out[[length(out) + 1L]] <<- data.frame(
      method = method, par = par, est = NA_real_, se = NA_real_,
      lower = NA_real_, upper = NA_real_, not_estimable = TRUE,
      stringsAsFactors = FALSE)
  }

  add <- function(method, par, est, se) {
    if (!is.finite(se) || se <= 0) return(invisible(NULL))
    out[[length(out) + 1L]] <<- data.frame(
      method = method, par = par, est = est, se = se,
      lower = est - z * se, upper = est + z * se, not_estimable = FALSE,
      stringsAsFactors = FALSE)
  }

  ## --- shared
  nll_s <- make_nll(d, "shared")
  f_s <- fit_ml(nll_s, 5)
  ok_s <- !is.null(f_s) && f_s$max_score <= CONV$max_score &&
    max(abs(f_s$par)) <= CONV$max_abs_par
  if (ok_s) {
    H <- obs_info(nll_s, f_s$par)
    w <- wald(f_s, H, PARNAMES$shared)
    if (!is.null(w)) {
      for (cc in c("A", "B")) {
        i <- match(paste0("g", cc), PARNAMES$shared)
        add("shared-info", paste0("gW", cc), w$est[i], w$se[i])
      }
    }
    V <- study_sandwich(d, "shared", f_s$par, H)
    if (!is.null(V) && all(is.finite(diag(V))) && all(diag(V) > 0)) {
      for (cc in c("A", "B")) {
        i <- match(paste0("g", cc), PARNAMES$shared)
        add("shared-sandwich", paste0("gW", cc), f_s$par[i], sqrt(diag(V))[i])
      }
    }
  }

  ## --- joint split
  nll_j <- make_nll(d, "split")
  f_j <- fit_ml(nll_j, 7)
  if (!is.null(f_j)) {
    w <- wald(f_j, obs_info(nll_j, f_j$par), PARNAMES$split)
    if (!is.null(w)) {
      for (cc in c("A", "B")) {
        i <- match(paste0("gW", cc), PARNAMES$split)
        add("joint-split", paste0("gW", cc), w$est[i], w$se[i])
      }
    }
  }

  ## --- IPD-anchored
  s1 <- fit_stage1(d)
  if (!is.null(s1)) {
    w1 <- wald(s1$fit, s1$H, s1$names)
    if (!is.null(w1)) {
      for (cc in c("A", "B")) {
        i <- match(paste0("gW", cc), s1$names)
        ## NA rather than a number where the component is not estimable, so the
        ## analysis counts it as a declined estimate and not as a failure.
        if (is.na(i)) add_na("ipd-anchored", paste0("gW", cc))
        else add("ipd-anchored", paste0("gW", cc), w1$est[i], w1$se[i])
      }
    }
  }

  if (!length(out)) return(NULL)
  do.call(rbind, out)
}
