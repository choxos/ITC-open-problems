## ---------------------------------------------------------------------------
## Integration sensitivity, promised by the protocol.
##
## Every DIC difference in this study is computed from a model whose aggregate
## likelihood is a numerical integral over 64 points. If the check's verdict moves
## when that number changes, the verdict is partly an artefact of quadrature. This
## refits a prespecified subset at 64 and at 256 points on the SAME simulated
## data and compares the quantity the check actually reads.
##
##   Rscript R/07-integration-check.R [n_replicates]
## ---------------------------------------------------------------------------

do.call(Sys.setenv, as.list(setNames(rep("1", 6),
  c("OMP_NUM_THREADS", "VECLIB_MAXIMUM_THREADS", "OPENBLAS_NUM_THREADS",
    "MKL_NUM_THREADS", "RCPP_PARALLEL_NUM_THREADS", "STAN_NUM_THREADS"))))

setwd(normalizePath(file.path(dirname(sub("^--file=", "",
  grep("^--file=", commandArgs(FALSE), value = TRUE)[1])), "..")))
source("R/00-config.R"); source("R/01-dgm.R")
source("R/02-fit.R"); source("R/03-replicate.R")
suppressPackageStartupMessages(library(parallel))

args <- commandArgs(TRUE)
NREP <- if (length(args)) as.integer(args[1]) else 12L

## The worst case for quadrature is the largest network at the widest covariate
## spread, where the aggregate studies sit furthest apart, crossed with the
## presence and absence of drift.
CELLS <- DESIGN$cell[DESIGN$n_studies == 12L & DESIGN$spread == 0.60 &
                     DESIGN$tau_re == 0 & DESIGN$drift %in% c(0, 0.60)]

RNGkind("L'Ecuyer-CMRG")
one <- function(ci, j) {
  set.seed(SEED_BASE + 1000L * ci + j, kind = "L'Ecuyer-CMRG")
  scen <- as.list(DESIGN[ci, ])
  dat  <- make_network_data(scen)
  out <- lapply(c(64L, 256L), function(ni) {
    N_INT <<- ni
    net <- build_network(dat)          # same data, different quadrature
    fc <- fit_one(net, character(0)); f1 <- fit_one(net, "x1")
    if (is.null(fc) || is.null(f1)) return(NULL)
    cs <- check_stats(f1, fc, "x1")
    data.frame(cell = ci, rep = j, n_int = ni, ddic = cs$ddic,
               diff_mean = cs$diff_mean, diff_sd = cs$diff_sd,
               post_flag = cs$post_flag)
  })
  if (any(vapply(out, is.null, TRUE))) return(NULL)
  do.call(rbind, out)
}

res <- do.call(rbind, mclapply(
  as.list(as.data.frame(t(expand.grid(ci = CELLS, j = seq_len(NREP))))),
  function(v) tryCatch(one(v[1], v[2]), error = function(e) NULL),
  mc.cores = 3L, mc.preschedule = TRUE))

w <- reshape(res, idvar = c("cell", "rep"), timevar = "n_int", direction = "wide")
w$ddic_shift <- w$ddic.256 - w$ddic.64
w$flag_changed <- w$post_flag.256 != w$post_flag.64
w$dic5_changed <- (w$ddic.256 < -5) != (w$ddic.64 < -5)

dir.create("results", showWarnings = FALSE)
write.csv(w, "results/integration-check.csv", row.names = FALSE)
cat(sprintf(paste("integration check on %d fits per arm:",
                  "median |shift in DIC difference| %.2f, max %.2f;",
                  "the DIC-5 verdict changed in %.1f%% and the posterior verdict",
                  "in %.1f%% of replicates\n"),
            nrow(w), median(abs(w$ddic_shift)), max(abs(w$ddic_shift)),
            100 * mean(w$dic5_changed), 100 * mean(w$flag_changed)))
