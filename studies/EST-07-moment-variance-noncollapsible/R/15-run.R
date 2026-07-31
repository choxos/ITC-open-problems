## ---------------------------------------------------------------------------
## The registered study, run.
##
## Round 1 of critique, severity fatal: "software cannot run the registered
## study". It was right. Everything before this file measures the study's own
## constants; nothing produced a replicate. This file does.
##
##   Rscript R/15-run.R                # run everything not already done
##   CELLS=1,2,3 Rscript R/15-run.R    # a named subset, for a smoke run
##
## THREE THINGS THIS FILE HAS TO GET RIGHT.
##
## 1. COMMON RANDOM NUMBERS, per `CRN_BLOCKS`. Cells that differ only in a
##    blocked factor must see THE SAME DATA, so the contrast between them carries
##    no sampling noise of its own. `corr_assumed` is blocked, so it is excluded
##    from the seed key and the three correlation settings of a cell get
##    identical replicates. The variance methods are blocked by construction:
##    `estimate_all()` computes all of them from one fit on one replicate. This
##    is what makes the paired comparison in the analysis a paired comparison,
##    and it is why R/16 must cluster its Monte Carlo error by replicate.
##
## 2. RESUME, at chunk granularity. 116 cells at 2000 replicates is 232,000
##    replicate results, which is far too many files, so results are stored one
##    RDS per cell and written every `CHUNK` replicates. A killed run loses at
##    most one chunk. The store is keyed by cell_id and never appended blindly:
##    a partial cell is read back, extended, and rewritten.
##
## 3. NO FORKING. The sibling study OUT-11 lost four multi-hour runs to a
##    deadlock: `parallel::mclapply` forks, and a forked child of a process that
##    has loaded a threaded library can wedge with every worker at 0% CPU. This
##    file is serial. It is slower and it finishes, which the parallel version
##    did not.
## ---------------------------------------------------------------------------

source("R/05-estimators.R")

RUN_DIR <- "results/run"
CHUNK   <- 250L

## The registered grid, straight from the probe store. Never re-derived here: if
## P2's floor moves, the run follows it without an edit.
run_cells <- function() {
  p <- load_probes()
  if (is.null(p$P2_grid)) stop("P2 has not run; there is no registered grid")
  p$P2_grid[[1]]
}

## THE SEED KEY. Every grid factor EXCEPT the blocked ones, plus the replicate
## index. Two cells differing only in `corr_assumed` therefore produce the same
## `sample_replicate()` draw, which is the whole point of blocking it.
##
## The key is hashed to an integer rather than built by arithmetic on the factor
## levels, so adding a level later cannot silently re-map existing seeds.
crn_seed <- function(cell, r) {
  ## Built from the grid's OWN columns minus the blocked ones, not from a typed
  ## list. A typed list would have excluded `corr_assumed` by omission rather
  ## than by blocking, so un-blocking it later would have changed nothing and
  ## the run would have kept sharing data it was no longer supposed to share.
  keys <- setdiff(names(cell), c("cell_id", CRN_BLOCKS))
  s <- paste(c(vapply(keys, function(k) as.character(cell[[k]]), ""), r),
             collapse = "|")
  ## A stable 31-bit hash of the key string. `strtoi` on the first 7 hex digits
  ## of md5 is deterministic across sessions and platforms, which `sample.int`
  ## on a seeded stream would not be if the level set changed.
  as.integer(strtoi(substr(digest::digest(s, algo = "md5"), 1, 7), 16L))
}

cell_file <- function(cell_id) file.path(RUN_DIR, sprintf("cell-%03d.rds", cell_id))

## --- one replicate ------------------------------------------------------------
##
## Returns one row per method. The cell's factors travel with the row so the
## analysis never has to join back to the grid and cannot join it wrongly.
run_replicate <- function(cell, r) {
  set.seed(crn_seed(cell, r))
  d <- try(sample_replicate(cell$nS, cell$nT, cell$k, cell$link, cell$shape,
                            rho_true = 0.3,
                            modifier_span = cell$modifier_span), silent = TRUE)
  if (inherits(d, "try-error")) return(NULL)

  ## THE TRUTH THIS REPLICATE IS SCORED AGAINST is the anchored superpopulation
  ## estimand of the cell. It does not depend on the replicate, but it is
  ## computed per replicate rather than cached because caching it per cell was
  ## how a sibling study came to score replicates against a stale truth.
  pm <- population_means(shape = cell$shape)
  pars <- d$hidden$pars; pars_T <- d$hidden$pars_T
  truth <- truth_anchored_superpop(pars, pars_T, cell$link, cell$shape,
                                   mu = pm$target,
                                   sigma = rep(1, N_COVARIATE), rho = 0.3,
                                   order = QUAD_ORDER)

  z <- try(estimate_all(d, cell$link, cell$corr_assumed), silent = TRUE)
  if (inherits(z, "try-error") || !nrow(z)) return(NULL)

  z$rep <- r
  ## The cell's factors travel with every row, so the analysis reads one flat
  ## table and never joins back to the grid. A join is where a mislabeled cell
  ## would enter, and there is no join here to get wrong.
  for (nm in names(cell)) z[[nm]] <- cell[[nm]]
  z$truth <- truth
  z$covered <- z$lower <= truth & truth <= z$upper
  z$width <- z$upper - z$lower
  z$error <- z$est - truth
  z
}

## --- one cell -----------------------------------------------------------------
run_one_cell <- function(cell, n_rep = N_REP) {
  f <- cell_file(cell$cell_id)
  done <- if (file.exists(f)) readRDS(f) else NULL
  have <- if (is.null(done)) 0L else max(done$rep)
  if (have >= n_rep) return(invisible(NULL))

  todo <- seq.int(have + 1L, n_rep)
  for (start in seq(1L, length(todo), by = CHUNK)) {
    idx <- todo[start:min(start + CHUNK - 1L, length(todo))]
    t0 <- proc.time()
    rows <- do.call(rbind, lapply(idx, function(r) run_replicate(cell, r)))
    dt <- proc.time() - t0
    if (!is.null(rows)) {
      rows$cpu_per_rep <- unname(dt[["user.self"]] + dt[["sys.self"]]) /
                          length(idx)
      done <- rbind(done, rows)
    }
    saveRDS(done, f)
    cat(sprintf("  cell %3d: %d/%d replicates (%.1f s for %d)\n",
                cell$cell_id, max(done$rep), n_rep,
                unname(dt[["elapsed"]]), length(idx)))
    flush.console()
  }
  invisible(NULL)
}

main <- function() {
  if (!requireNamespace("digest", quietly = TRUE))
    stop("package 'digest' is required for the CRN seed key")
  ## The probe constants become globals here. Without this `QUAD_ORDER` is still
  ## the placeholder and the truth computation stops, which is the guard doing
  ## its job: a run must not score replicates against a guessed integration
  ## order.
  probes_done()
  dir.create(RUN_DIR, recursive = TRUE, showWarnings = FALSE)
  cells <- run_cells()

  only <- Sys.getenv("CELLS", "")
  if (nzchar(only)) {
    want <- as.integer(strsplit(only, ",")[[1]])
    cells <- cells[cells$cell_id %in% want, ]
    cat(sprintf("restricted to %d cell(s) by CELLS=%s\n", nrow(cells), only))
  }

  ## `xcov.rds` is needed by `maic_xcov` on the first replicate. Failing here is
  ## far better than failing 200 cells in.
  invisible(xcov_store())

  cat(sprintf("running %d cells x %d replicates\n", nrow(cells), N_REP))
  for (i in seq_len(nrow(cells))) {
    cell <- cells[i, ]
    cat(sprintf("[%3d/%3d] cell %3d: %s nT=%d nS=%d k=%.2f %s %s %s\n",
                i, nrow(cells), cell$cell_id, cell$link, cell$nT, cell$nS,
                cell$k, cell$shape, cell$corr_assumed, cell$modifier_span))
    run_one_cell(cell)
  }
  cat("all cells complete\n")
}

if (!interactive() && Sys.getenv("RUN_NOMAIN") == "") main()
