## ---------------------------------------------------------------------------
## The run: every method on every replicate, against the same truth.
##
##   Rscript R/04-run.R              all cells
##   CELLS=3,7 Rscript R/04-run.R    named cells
##
## SERIAL AND CHECKPOINTED. A sibling study in this repository was killed
## repeatedly by machine contention, so this one takes a single core, writes a
## file per cell, and resumes by file existence. Repeated invocation is
## idempotent, which is what lets a supervisor be a loop rather than a scheduler.
##
## COMMON RANDOM NUMBERS ARE STRUCTURAL HERE, NOT AN OPTION. Every method
## standardizes the SAME fitted model over a different law, and every Gaussian law
## is a linear map of one shared base sample. So a contrast between two methods
## carries neither IPD sampling noise nor integration noise of its own, and the
## Monte Carlo error of that contrast is a paired quantity that `R/05-analyze.R`
## computes as one.
##
## rho = 0 IS THE INDEPENDENCE COPULA FOR ALL THREE FAMILIES, so those cells are
## run once rather than three times. That is not a saving of convenience: running
## them three times would put three copies of the same numbers into every pooled
## average and silently weight the no-dependence case triple.
## ---------------------------------------------------------------------------

source("R/02-methods.R")

RUN_DIR <- "results/run"
CHUNK   <- 250L

build_grid <- function() {
  g <- expand.grid(rho = LEVELS$rho, copula = LEVELS$copula,
                   gamma_sign = LEVELS$gamma_sign,
                   modification = LEVELS$modification,
                   scale = LEVELS$scale, overlap = LEVELS$overlap,
                   dim = LEVELS$dim,
                   KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g <- g[!(g$rho == 0 & g$copula != "gaussian"), ]
  g <- g[order(g$dim, g$scale, g$modification, g$gamma_sign, g$rho, g$copula), ]
  g$cell_id <- seq_len(nrow(g))
  rownames(g) <- NULL
  g
}

cell_file <- function(id) file.path(RUN_DIR, sprintf("cell-%03d.rds", id))

## Deterministic in the cell and the replicate, so results do not depend on
## scheduling and a resumed run reproduces a continuous one.
rep_seed <- function(cell, r) as.integer(2e6 + 7919L * r + 137L * cell$cell_id)

ci <- function(est, se) {
  z <- stats::qnorm(1 - (1 - NOMINAL) / 2)
  c(lo = est - z * se, hi = est + z * se)
}

run_replicate <- function(cell, r, truth, gamma) {
  set.seed(rep_seed(cell, r))
  d <- cell$dim
  x <- draw_ipd(N_IPD, d, cell$rho, cell$copula, cell$overlap)
  A <- stats::rbinom(N_IPD, 1, 0.5)
  y <- draw_outcome(prob_of(x, A, gamma, cell$modification))
  ## A degenerate arm carries no information about the contrast and is dropped
  ## rather than fitted, so a convergence failure means a real one.
  if (length(unique(A)) < 2L || length(unique(y)) < 2L) return(NULL)
  fit <- fit_ipd(x, A, y, cell$modification)
  if (is.null(fit)) return(NULL)

  ## The correlation the analyst can borrow: estimated in the IPD trial, which is
  ## the only patient-level data anyone has.
  R_ipd <- stats::cor(x)

  m <- list(
    stc_means      = stc_at_means(fit, d, cell$scale),
    gcomp_oracle   = standardize(fit, law_oracle(d, cell$rho, cell$copula, N_INT),
                                 cell$scale),
    gcomp_indep    = standardize(fit, law_independence(d, N_INT), cell$scale),
    gcomp_borrowed = standardize(fit, law_gaussian(R_ipd, N_INT), cell$scale))
  if (any(vapply(m, is.null, TRUE))) return(NULL)
  ri <- reconstruction_interval(fit, d, cell$scale, N_INT)
  if (is.null(ri)) return(NULL)

  row <- data.frame(cell_id = cell$cell_id, rep = r,
                    rho = cell$rho, copula = cell$copula,
                    gamma_sign = cell$gamma_sign, modification = cell$modification,
                    scale = cell$scale, overlap = cell$overlap, dim = d,
                    truth = truth, stringsAsFactors = FALSE)
  for (nm in names(m)) {
    b <- ci(m[[nm]]$est, m[[nm]]$se)
    row[[paste0(nm, "_est")]]   <- m[[nm]]$est
    row[[paste0(nm, "_se")]]    <- m[[nm]]$se
    row[[paste0(nm, "_cover")]] <- truth >= b[["lo"]] && truth <= b[["hi"]]
    row[[paste0(nm, "_width")]] <- b[["hi"]] - b[["lo"]]
  }
  row$recon_est   <- ri$est
  row$recon_cover <- truth >= ri$lo && truth <= ri$hi
  row$recon_width <- ri$hi - ri$lo

  ## Section 2's scalar, recorded per replicate so the registered mechanism check
  ## regresses observed bias on a computed quantity rather than on a story.
  R_true <- matrix(cell$rho, d, d); diag(R_true) <- 1
  row$prog_var_true  <- prognostic_var(gamma, R_true)
  row$prog_var_indep <- prognostic_var(gamma, diag(d))
  row$indep_gap      <- independence_gap(gamma, R_true)
  row
}

run_cell <- function(cell, n_rep = N_REP) {
  f <- cell_file(cell$cell_id)
  done <- if (file.exists(f)) readRDS(f) else NULL
  have <- if (is.null(done)) 0L else max(done$rep)
  if (have >= n_rep) return(invisible(NULL))
  gamma <- gamma_vec(cell$dim, cell$gamma_sign)
  truth <- truth_target(cell$dim, cell$rho, cell$copula, gamma,
                        cell$modification, cell$scale)
  todo <- seq.int(have + 1L, n_rep)
  for (s in seq(1L, length(todo), by = CHUNK)) {
    idx <- todo[s:min(s + CHUNK - 1L, length(todo))]
    t0 <- proc.time()
    rows <- do.call(rbind, lapply(idx, function(r)
      run_replicate(cell, r, truth, gamma)))
    dt <- unname((proc.time() - t0)[["elapsed"]])
    if (!is.null(rows)) done <- rbind(done, rows)
    saveRDS(done, f)
    cat(sprintf("  cell %3d: %d/%d (%.0f s for %d)\n", cell$cell_id,
                if (is.null(done)) 0L else max(done$rep), n_rep, dt, length(idx)))
    utils::flush.console()
  }
  invisible(NULL)
}

main <- function() {
  probes_done(c("TRUTH_N", "N_INT"))
  dir.create(RUN_DIR, recursive = TRUE, showWarnings = FALSE)
  g <- build_grid()
  only <- Sys.getenv("CELLS", "")
  if (nzchar(only)) g <- g[g$cell_id %in% as.integer(strsplit(only, ",")[[1]]), ]
  cat(sprintf("running %d cells x %d replicates at N_INT = %d, TRUTH_N = %d\n",
              nrow(g), N_REP, N_INT, TRUTH_N))
  for (i in seq_len(nrow(g))) {
    cell <- g[i, ]
    cat(sprintf("[%3d/%3d] d=%d %-8s %-9s %-6s %-9s rho=%.1f %s\n",
                i, nrow(g), cell$dim, cell$scale, cell$modification,
                cell$overlap, cell$gamma_sign, cell$rho, cell$copula))
    run_cell(cell)
  }
  cat("all cells complete\n")
}

if (!interactive() && Sys.getenv("RUN_NOMAIN") == "") main()
