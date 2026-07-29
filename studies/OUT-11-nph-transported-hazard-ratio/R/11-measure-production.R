## ---------------------------------------------------------------------------
## Measure the EXACT production configuration, once, and write the numbers the
## budget is computed from.
##
## Round 4's finding was that the protocol claimed 227 s for a replicate's two
## ML-NMR arms while the same table measured 296.2 s for one flexible fit at the
## production integration order. That is not a discrepancy to be reconciled in
## prose: one of the numbers was never measured. The 227 s figure came from
## dividing a two-replicate wall clock by two under a concurrency assumption
## that was never checked.
##
## So this script runs what the run runs: both arms of a replicate, at N_INT and
## N_CHAINS as frozen, with WORKERS replicates actually in flight, and reports
## wall clock per replicate. It also measures the bootstrap speedup rather than
## assuming it equals the core count, because a fork that shares memory
## bandwidth rarely scales linearly.
##
##   Rscript R/11-measure-production.R
##   Rscript R/10-budget.R
## ---------------------------------------------------------------------------

suppressPackageStartupMessages(library(parallel))
Sys.setenv(PROBE_NOMAIN = "1", RUN_NOMAIN = "1")
source("R/07-run.R")

WORKERS <- as.integer(Sys.getenv("WORKERS", "2"))
cells <- build_cells(); cells$cell_id <- seq_len(nrow(cells))
cell <- cells[1, ]

secs <- function(expr) {
  t0 <- Sys.time(); force(expr)
  as.numeric(difftime(Sys.time(), t0, units = "secs"))
}

## MACHINE CONTENTION IS RECORDED, NOT ASSUMED AWAY.
##
## The first attempt at this measurement ran while an earlier probe was still
## alive, which was not noticed because the process is named `R`, not `Rscript`,
## and the check used to confirm the machine was quiet grepped for the latter.
## Separately, this machine runs a system indexing process that holds close to a
## full core for long stretches. Both inflate wall clock.
##
## Contention cannot be eliminated, and a budget measured on an artificially
## idle machine would understate a run that will not have one. So it is measured
## as it is, the load average is recorded alongside every figure, and the budget
## is reported as a RANGE rather than a point. What must not happen again is a
## number whose measurement conditions are unknown.
loadavg <- function() {
  z <- try(suppressWarnings(system("uptime", intern = TRUE)), silent = TRUE)
  if (inherits(z, "try-error")) return(NA_real_)
  m <- regmatches(z, regexec("averages?:? +([0-9.]+)", z))[[1]]
  if (length(m) < 2) NA_real_ else as.numeric(m[2])
}
own_R <- function() {
  z <- try(suppressWarnings(system("pgrep -f 'exec/R --no-echo' | wc -l",
                                   intern = TRUE)), silent = TRUE)
  if (inherits(z, "try-error")) NA_integer_ else as.integer(trimws(z))
}
cat(sprintf("machine at start: load %.2f, %d R processes alive\n",
            loadavg(), own_R()))

## RESUMABLE. Each measurement is saved the moment it is taken.
##
## The first attempt at this two-order measurement was killed partway and saved
## nothing, which is the same defect that cost three replicates of the
## integration probe. A measurement script that discards finished work on
## interruption is not usable on a machine that interrupts things.
TIMING_PATH <- "results/production-timing.rds"
timing <- if (file.exists(TIMING_PATH)) readRDS(TIMING_PATH) else list()
put <- function(...) {
  timing[names(list(...))] <<- list(...)
  saveRDS(timing, TIMING_PATH)
}
have <- function(k) !is.null(timing[[k]]) && !is.na(timing[[k]])

n_stan <- WORKERS * 2          # two full waves, so the number is not one draw

## One Stan pass at a given integration order, at the concurrency the run uses.
stan_pass <- function(n_int, seed_off) {
  cat(sprintf("Stan pass: %d replicates in flight, %d chains, N_INT = %d\n",
              WORKERS, N_CHAINS, n_int))
  l0 <- loadavg()
  N_INT <<- as.integer(n_int)
  el <- secs(mclapply(seq_len(n_stan), function(r) mlnmr_replicate(cell, seed_off + r),
                      mc.cores = WORKERS, mc.preschedule = FALSE))
  l1 <- loadavg()
  cat(sprintf("  %d replicates in %.1f s -> %.1f s per replicate (both arms)\n",
              n_stan, el, el / n_stan))
  cat(sprintf("  load average %.2f before, %.2f after\n", l0, l1))
  list(per_rep = el / n_stan, l0 = l0, l1 = l1)
}

## --- 1. the production order -------------------------------------------------
if (!have("stan_replicate_secs")) {
  z <- stan_pass(128L, 900)
  put(stan_replicate_secs = round(z$per_rep, 1),
      load_before = round(z$l0, 2), load_after = round(z$l1, 2),
      n_replicates_timed = n_stan, n_chains = N_CHAINS, workers = WORKERS,
      n_cores_boot = N_CORES_BOOT)
} else cat(sprintf("skip 128 pass, already measured at %.1f s\n",
                   timing$stan_replicate_secs))

## --- 2. THE SAME MEASUREMENT AT 256 POINTS, apples to apples ----------------
## Not a single fit extrapolated to a replicate. The protocol's claim that 256
## in production would cost "about 185 hours" rested on a single-fit timing of
## 597 s taken while other jobs were running, and choosing 128 over 256 rested
## on that claim. A registered parameter must not be decided by an extrapolation
## from a contended single fit, so the production configuration is measured at
## both orders the same way.
if (!have("stan_replicate_256_secs")) {
  z <- stan_pass(256L, 940)
  put(stan_replicate_256_secs = round(z$per_rep, 1),
      ratio_256_128 = round(z$per_rep / timing$stan_replicate_secs, 2),
      load_before_256 = round(z$l0, 2), load_after_256 = round(z$l1, 2))
  cat(sprintf("  ratio 256/128 = %.2f\n", timing$ratio_256_128))
} else cat(sprintf("skip 256 pass, already measured at %.1f s\n",
                   timing$stan_replicate_256_secs))

N_INT <<- 128L
d <- sim_for(cell, 950)

if (!have("flex_fit_256_secs")) {
  el <- secs(fit_flex(build_net(d, 256L)))
  put(flex_fit_256_secs = round(el, 1))
  cat(sprintf("  one flexible fit at 256 points, alone: %.1f s\n", el))
}

## --- 3. the bootstrap, one core and N_CORES_BOOT cores ----------------------
if (!have("boot_resample_secs")) {
  nb <- 40
  el_1 <- secs(freq_boot(d, n_boot = nb, tt = TT, cores = 1L))
  el_p <- secs(freq_boot(d, n_boot = nb, tt = TT, cores = N_CORES_BOOT))
  put(boot_resample_secs = round(el_1 / nb, 4), boot_speedup = round(el_1 / el_p, 2))
  cat(sprintf("  bootstrap %d resamples: %.1f s on 1 core, %.1f s on %d -> %.2fx\n",
              nb, el_1, el_p, N_CORES_BOOT, el_1 / el_p))
}

put(n_int = 128L)
cat("\nwritten: results/production-timing.rds\n")
str(timing)
