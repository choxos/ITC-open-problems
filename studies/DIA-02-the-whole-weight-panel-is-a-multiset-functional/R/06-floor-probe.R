## ---------------------------------------------------------------------------
## Can the strata the null control killed be rescued by more source records?
##
##   Rscript R/06-floor-probe.R
##
## WHY. `N_SOURCE` was registered from an estimator-noise floor measured at the
## middle of the grid, and the middle is not the worst corner. At `dim8/moderate`
## MAIC's own sampling error exceeds the 0.03 material threshold on 0.288 of
## replicates with no support hole at all, so the label there is mostly noise and
## `R/04-analyze.R` drops the stratum. Three quarters of the grid went with it.
##
## The principled repair is to raise the source size until the estimator can
## resolve the threshold, not to lower the threshold until the estimator looks
## adequate: the threshold is a decision quantity and must not move to suit the
## data. This probe measures what source size that takes, or establishes that no
## affordable one does, which is itself the answer.
##
## It measures the floor only, with NO hole, which is the null control's own
## condition, so it is cheap relative to a full rescue run.
## ---------------------------------------------------------------------------

source("R/02-panel.R")

N_PROBE   <- 300L
SIZES     <- c(16000L, 48000L, 96000L, 192000L)
STRATA    <- list(list(dim = 3L, overlap = "moderate"),
                  list(dim = 8L, overlap = "moderate"))

floor_one <- function(n_src, d, overlap, r) {
  set.seed(50000L + 977L * r + 13L * n_src %/% 1000L + d)
  xs <- draw_source(n_src, d, overlap, "none")
  xt <- draw_target(N_TARGET, d)
  h  <- balancing(xs, "none")
  fw <- try(fit_weights(h, colMeans(balancing(xt, "none"))), silent = TRUE)
  if (inherits(fw, "try-error") || fw$conv != 0L) return(NA_real_)
  w <- fw$w
  A <- stats::rbinom(n_src, 1, 0.5)
  Y <- draw_outcome(conditional_p(xs, A, "moderate"))
  den1 <- sum(w * A); den0 <- sum(w * (1 - A))
  if (den1 <= 0 || den0 <= 0) return(NA_real_)
  est <- sum(w * A * Y) / den1 - sum(w * (1 - A) * Y) / den0
  abs(est - truth_superpopulation(d, "moderate"))
}

main <- function() {
  out <- list()
  for (s in STRATA) for (n in SIZES) {
    t0 <- proc.time()
    e <- vapply(seq_len(N_PROBE), function(r) floor_one(n, s$dim, s$overlap, r), 0)
    dt <- unname((proc.time() - t0)[["elapsed"]])
    e <- e[is.finite(e)]
    row <- data.frame(dim = s$dim, overlap = s$overlap, n_source = n,
                      n_ok = length(e), median = stats::median(e),
                      p95 = unname(stats::quantile(e, 0.95)),
                      p_material = mean(e > MATERIAL_ERROR),
                      sec_per_rep = dt / N_PROBE, stringsAsFactors = FALSE)
    out[[length(out) + 1L]] <- row
    cat(sprintf("dim%d/%s n=%7d: median %.4f p95 %.4f P(>%.2f)=%.4f  %.2f s/rep\n",
                s$dim, s$overlap, n, row$median, row$p95, MATERIAL_ERROR,
                row$p_material, row$sec_per_rep))
    utils::flush.console()
  }
  res <- do.call(rbind, out)
  dir.create("results", showWarnings = FALSE)
  saveRDS(res, "results/floor-probe.rds")

  ## THE VERDICT USES THE UPPER CONFIDENCE BOUND, NOT THE POINT ESTIMATE. At 300
  ## replicates a rate near the 0.02 threshold carries a Monte Carlo standard
  ## error around 0.008, so declaring a size adequate because its point estimate
  ## landed below the threshold would be making a decision inside its own noise:
  ## exactly the defect this probe exists to repair, one level up. A size is
  ## adequate only when the Clopper-Pearson upper bound is below the threshold,
  ## which at zero events out of 300 is the rule of three, 0.010.
  cat(sprintf("\n=== smallest size passing the null control ===\n"))
  cat(sprintf("Criterion: upper 95%% bound on P(material) below %.2f, not the point\n", 0.02))
  cat(sprintf("estimate, because at %d replicates the point estimate's own error near\n", N_PROBE))
  cat(sprintf("that threshold is about %.3f.\n\n",
              sqrt(0.02 * 0.98 / N_PROBE)))
  res$upper <- vapply(seq_len(nrow(res)), function(i) {
    k <- round(res$p_material[i] * res$n_ok[i])
    stats::binom.test(k, res$n_ok[i])$conf.int[2]
  }, 0)
  print(res[, c("dim", "overlap", "n_source", "p_material", "upper", "sec_per_rep")],
        row.names = FALSE, digits = 3)
  cat("\n")
  for (s in STRATA) {
    z <- res[res$dim == s$dim & res$overlap == s$overlap & res$upper <= 0.02, ]
    if (nrow(z)) {
      k <- z[which.min(z$n_source), ]
      cat(sprintf("dim%d/%s: n = %d (upper bound %.4f), at %.2f s/rep -> %.1f h for 12000 replicates\n",
                  s$dim, s$overlap, k$n_source, k$upper, k$sec_per_rep,
                  k$sec_per_rep * 12000 / 3600))
    } else {
      cat(sprintf("dim%d/%s: NONE of %s passes; not rescuable at these sizes\n",
                  s$dim, s$overlap, paste(SIZES, collapse = ", ")))
    }
  }
  cat("\nThe per-replicate cost above omits the geometric diagnostics, which the\n")
  cat("production runner also computes and which dominate at large n through the\n")
  cat("sliced transport cost, so treat these times as a lower bound.\n")
  saveRDS(res, "results/floor-probe.rds")
  cat("\nwritten: results/floor-probe.rds\n")
}

if (!interactive()) main()
