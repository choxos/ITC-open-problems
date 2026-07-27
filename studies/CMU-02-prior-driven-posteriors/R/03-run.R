## Run the design.
##
##   Rscript R/03-run.R

.f <- grep("^--file=", commandArgs(FALSE), value = TRUE)
STUDY <- if (length(.f)) {
  dirname(dirname(normalizePath(sub("^--file=", "", .f[1]))))
} else {
  normalizePath(".")
}
here <- function(...) file.path(STUDY, ...)
stopifnot(file.exists(here("R", "00-config.R")))

suppressPackageStartupMessages(library(Matrix))
source(here("R", "01-model.R"))
source(here("R", "02-diagnostics.R"))
source(here("R", "00-config.R"))
source(here("..", "_shared", "R", "harness.R"))

OUTDIR <- here("results")
dir.create(OUTDIR, recursive = TRUE, showWarnings = FALSE)
scenarios <- build_scenarios()

## Evidence structure depends only on geometry and arm size, so build each once
## rather than per replicate.
EV <- new.env(parent = emptyenv())
ev_for <- function(geometry, n_arm) {
  k <- paste(geometry, n_arm)
  if (is.null(EV[[k]])) EV[[k]] <- build_evidence(geometry, n_arm)
  EV[[k]]
}

## Two contrasts are followed. gamma_C is the interaction CMP-14 is about; the
## target-population C versus B mean difference is the decision quantity CMU-02
## is about, and it is the one a committee would read.
contrasts_for <- function(mu_target) {
  cg <- numeric(NP); cg[match("gC", PARS)] <- 1
  list(gamma_C = cg, Delta_CB = contrast_CB(mu_target))
}

one_rep <- function(scen, rep_id) {
  ev <- ev_for(scen$geometry, scen$n_arm)
  S0 <- prior_cov(scen$prior)
  th <- true_theta(scen$gamma_C)
  z <- gen_z(ev$H, ev$V, th)

  truths <- c(gamma_C = scen$gamma_C,
              Delta_CB = true_delta_CB(scen$gamma_C, scen$mu_target))
  out <- list()
  for (nm in names(truths)) {
    cvec <- contrasts_for(scen$mu_target)[[nm]]
    r <- evaluate(z, ev$H, ev$V, S0, cvec)
    tv <- truths[[nm]]
    zq <- stats::qnorm(1 - (1 - HARM$level) / 2)
    lo <- r$est - zq * r$sd; hi <- r$est + zq * r$sd
    pgt <- stats::pnorm(r$est / r$sd)
    r$par <- nm
    r$truth <- tv
    r$lower <- lo; r$upper <- hi
    r$covered <- lo <= tv && tv <= hi
    ## Harm, defined by consequence. A confident claim on the wrong side of zero
    ## is the failure a committee would act on.
    r$confident <- pgt >= HARM$confident || pgt <= 1 - HARM$confident
    r$wrong_side <- (pgt >= HARM$confident && tv <= 0) ||
      (pgt <= 1 - HARM$confident && tv >= 0)
    ## Descriptive only. Never a gold standard; see the protocol.
    r$W <- weak_share(cvec, ev$H, ev$V, S0)
    out[[nm]] <- r
  }
  do.call(rbind, out)
}

res <- run_design(one_rep, scenarios, n_rep = N_REP, master_seed = MASTER_SEED,
                  outdir = OUTDIR)

write_provenance(
  OUTDIR, packages = c("stats", "Matrix", "future", "furrr"),
  extra = list(study = "CMU-02 prior-driven posteriors",
               scenarios = nrow(scenarios), replicates_per_scenario = N_REP,
               total = nrow(scenarios) * N_REP, master_seed = MASTER_SEED))

cat(sprintf("\n%d rows over %d scenarios x %d replicates x 2 contrasts\n",
            nrow(res), nrow(scenarios), N_REP))
