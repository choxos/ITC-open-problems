## ---------------------------------------------------------------------------
## The run: every diagnostic scored on every replicate, alongside the error it is
## supposed to predict.
##
##   Rscript R/03-run.R
##
## SERIAL AND CHECKPOINTED, deliberately. A sibling study in this repository was
## killed twice by machine contention while another registered run was the long
## pole, once by a fork deadlock and once by memory pressure, so this one takes a
## single core and writes a file per cell. Resume is by file existence.
##
## COMMON RANDOM NUMBERS ACROSS DIAGNOSTICS is automatic here: every diagnostic is
## computed from the same replicate, so a contrast between two diagnostics carries
## no sampling noise of its own and the Monte Carlo error of that contrast is a
## paired quantity. The analysis computes it that way.
## ---------------------------------------------------------------------------

source("R/02-panel.R")

RUN_DIR <- "results/run"
CHUNK   <- 250L

## The grid, fully crossed. `hole = none` is the null control and is run at the
## same replicate count as everything else, because a control evaluated on fewer
## replicates than the thing it controls is not a control.
build_grid <- function() {
  g <- expand.grid(dim = LEVELS$dim, hole = LEVELS$hole,
                   overlap = LEVELS$overlap,
                   omitted_moment = LEVELS$omitted_moment,
                   modification = LEVELS$modification,
                   KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$cell_id <- seq_len(nrow(g))
  g
}

cell_file <- function(id) file.path(RUN_DIR, sprintf("cell-%03d.rds", id))

## The seed is a deterministic function of the cell and the replicate, so results
## do not depend on scheduling and a resumed run reproduces a continuous one.
rep_seed <- function(cell, r)
  as.integer(1e6 + 9973L * r + 131L * cell$cell_id)

run_replicate <- function(cell, r) {
  set.seed(rep_seed(cell, r))
  d <- cell$dim
  xs <- try(draw_source(N_SOURCE, d, cell$overlap, cell$hole), silent = TRUE)
  if (inherits(xs, "try-error")) return(NULL)
  xt <- draw_target(N_TARGET, d)

  h  <- balancing(xs, cell$omitted_moment)
  mT <- colMeans(balancing(xt, cell$omitted_moment))
  fw <- try(fit_weights(h, mT), silent = TRUE)
  if (inherits(fw, "try-error") || fw$conv != 0L) return(NULL)
  w <- fw$w

  A <- stats::rbinom(N_SOURCE, 1, 0.5)
  Y <- draw_outcome(conditional_p(xs, A, cell$modification))
  num1 <- sum(w * A * Y); den1 <- sum(w * A)
  num0 <- sum(w * (1 - A) * Y); den0 <- sum(w * (1 - A))
  if (den1 <= 0 || den0 <= 0) return(NULL)
  est <- num1 / den1 - num0 / den0
  truth <- truth_superpopulation(d, cell$modification)

  p  <- panel_multiset(w)
  g  <- diagnostics_geometric(xs, w, xt, cell$omitted_moment)
  es <- ess_definitions(w)

  data.frame(cell_id = cell$cell_id, rep = r,
             dim = d, hole = cell$hole, overlap = cell$overlap,
             omitted_moment = cell$omitted_moment,
             modification = cell$modification,
             ## the reported panel, all functions of the multiset alone
             ess_kish = p$ess_kish, ess_pct = p$ess_pct,
             entropy_eff = p$entropy_eff, max_weight = p$max_weight,
             top_share = p$top_share,
             ## the candidates that read position
             balance_omitted = g$balance_omitted, ess_region = g$ess_region,
             hull_gap = g$hull_gap, ot_cost = g$ot_cost,
             ## the three competing ESS definitions, for their spread
             ess_def_kish = es[["kish"]], ess_def_cv = es[["cv"]],
             ess_def_entropy = es[["entropy"]],
             ## what every diagnostic is trying to predict
             est = est, truth = truth, abs_error = abs(est - truth),
             material = abs(est - truth) > MATERIAL_ERROR,
             ## the decision relevance of this cell's hole, measured not asserted
             mod_share = hole_modification_share(xt, cell$hole,
                                                 cell$modification),
             imbalance = fw$imbalance,
             stringsAsFactors = FALSE)
}

run_cell <- function(cell, n_rep = N_REP) {
  f <- cell_file(cell$cell_id)
  done <- if (file.exists(f)) readRDS(f) else NULL
  have <- if (is.null(done)) 0L else max(done$rep)
  if (have >= n_rep) return(invisible(NULL))
  todo <- seq.int(have + 1L, n_rep)
  for (s in seq(1L, length(todo), by = CHUNK)) {
    idx <- todo[s:min(s + CHUNK - 1L, length(todo))]
    t0 <- proc.time()
    rows <- do.call(rbind, lapply(idx, function(r) run_replicate(cell, r)))
    dt <- proc.time() - t0
    if (!is.null(rows)) done <- rbind(done, rows)
    saveRDS(done, f)
    cat(sprintf("  cell %2d: %d/%d (%.0f s for %d)\n", cell$cell_id,
                if (is.null(done)) 0L else max(done$rep), n_rep,
                unname(dt[["elapsed"]]), length(idx)))
    utils::flush.console()
  }
  invisible(NULL)
}

main <- function() {
  dir.create(RUN_DIR, recursive = TRUE, showWarnings = FALSE)
  g <- build_grid()
  only <- Sys.getenv("CELLS", "")
  if (nzchar(only)) g <- g[g$cell_id %in% as.integer(strsplit(only, ",")[[1]]), ]
  cat(sprintf("running %d cells x %d replicates\n", nrow(g), N_REP))
  for (i in seq_len(nrow(g))) {
    cell <- g[i, ]
    cat(sprintf("[%2d/%2d] dim=%d hole=%-18s overlap=%-8s omitted=%-26s mod=%s\n",
                i, nrow(g), cell$dim, cell$hole, cell$overlap,
                cell$omitted_moment, cell$modification))
    run_cell(cell)
  }
  cat("all cells complete\n")
}

if (!interactive() && Sys.getenv("RUN_NOMAIN") == "") main()
