## ---------------------------------------------------------------------------
## Measure the runtime of the ACTUAL production configuration.
##
## Both round-two reviewers found the runtime estimate unauditable, and one was
## right that it omitted the bootstrap, which turned out to dominate. A second
## way to get this wrong is to extrapolate: the integration probe timed 2-chain
## fits run one at a time, while the run uses 4 chains with several fits in
## flight, so per-fit wall clock and throughput are both different. Contention
## on 4 performance cores is not something to predict from a single-fit timing.
##
## This measures THROUGHPUT, fits per second, at the concurrency the run will
## use, which is the only number the schedule actually depends on.
## ---------------------------------------------------------------------------

suppressPackageStartupMessages({library(parallel); library(multinma); library(dplyr)})
source("R/00-config.R")
source("R/01-dgm.R")
Sys.setenv(PROBE_NOMAIN = "1")
source("R/probe-integration.R")
source("R/03-estimators.R")

N_INT_TEST <- as.integer(Sys.getenv("N_INT_TEST", "64"))
CONC       <- as.integer(strsplit(Sys.getenv("CONC", "2,3"), ",")[[1]])

## The sampler policy binds on the DERIVED estimand, not on every internal
## spline coefficient, so the ESS that matters is the ESS of B minus A. The
## integration probe only ever reported the global minimum across all monitored
## parameters, which is a different and much more pessimistic number. Measuring
## the right one decides whether four chains are needed at all, and that
## decision is worth roughly five hours of run time.
est_ess <- function(fit, nd) {
  p <- predict(fit, newdata = nd, baseline = "S2", aux = "S2",
               type = "rmst", times = TAU, level = "aggregate", summary = FALSE)
  s  <- p$sims
  nm <- dimnames(s)[[3]]
  j  <- function(k) grep(sprintf(": %s]", k), nm, fixed = TRUE)[1]
  dr <- s[, , j("B"), drop = FALSE] - s[, , j("A"), drop = FALSE]
  dr <- array(dr, dim = dim(s)[1:2])          # iterations x chains
  c(ess_bulk = posterior::ess_bulk(dr), ess_tail = posterior::ess_tail(dr),
    rhat = posterior::rhat(dr))
}

one_replicate <- function(seed, n_int, report = FALSE) {
  d   <- sim_network(seed)
  net <- build_net(d, n_int)
  nd  <- target_newdata(d, n_int)
  ## Both ML-NMR arms, which is what a production replicate costs.
  out <- lapply(list(ph = fit_ph(net), flex = fit_flex(net)), est_ess, nd = nd)
  if (report) return(out)
  TRUE
}

if (Sys.getenv("ESS_ONLY") != "") {
  for (nc in c(2L, 4L)) {
    N_CHAINS <<- nc
    r <- one_replicate(SEED + 7001, N_INT_TEST, report = TRUE)
    for (a in names(r))
      cat(sprintf("chains %d  %-4s  derived-estimand ESS bulk %5.0f  tail %5.0f  Rhat %.4f\n",
                  nc, a, r[[a]]["ess_bulk"], r[[a]]["ess_tail"], r[[a]]["rhat"]))
    flush.console()
  }
  quit(save = "no")
}

cat(sprintf("integration points: %d, chains: %d, iter: %d\n\n",
            N_INT_TEST, N_CHAINS, N_ITER))

for (k in CONC) {
  n <- k * 2                    # two batches per level, so the number is not one draw
  t0 <- Sys.time()
  invisible(mclapply(seq_len(n), function(i) one_replicate(SEED + 5000 + i, N_INT_TEST),
                     mc.cores = k))
  el <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
  cat(sprintf("concurrency %d: %d replicates in %6.1f s -> %6.1f s per replicate, "
              , k, n, el, el / n))
  cat(sprintf("480 replicates = %5.1f h\n", 480 * (el / n) / 3600)); flush.console()
}

## The bootstrap is pure single-threaded R, so it parallelizes to all logical
## cores rather than to the 2 or 3 the Stan fits allow.
cat("\n--- bootstrap throughput ---\n")
d <- sim_network(SEED + 1)
for (k in c(4L, 8L)) {
  n <- k * 4
  t0 <- Sys.time()
  invisible(mclapply(seq_len(n), function(i) freq_all(boot_once(d)), mc.cores = k))
  el <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
  cat(sprintf("workers %d: %6.3f s per resample -> 500 x 480 = %5.1f h\n",
              k, el / n, 500 * 480 * (el / n) / 3600)); flush.console()
}
