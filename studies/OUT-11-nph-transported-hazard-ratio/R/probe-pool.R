## ---------------------------------------------------------------------------
## Pool every integration-order measurement this study has paid for, from
## whichever form it survived in, and report the paired contrasts.
##
## The early probe runs saved their results only at the end and this machine
## killed them partway, so three complete replicates exist ONLY as lines in a
## log file. They are real measurements and discarding them because the process
## that produced them died would be wasteful, so they are parsed back. Later
## runs checkpoint after every fit (see R/probe-integration.R) and are read from
## their rds directly.
##
## Replicates are keyed on (rep, n_int) and the first occurrence wins, because
## one replicate was accidentally run twice under different sampler seeds and
## counting it twice would understate the standard error.
## ---------------------------------------------------------------------------

parse_log <- function(path) {
  if (!file.exists(path)) return(NULL)
  ln <- grep("^rep +\\d+ int +\\d+", readLines(path, warn = FALSE), value = TRUE)
  if (!length(ln)) return(NULL)
  m <- regmatches(ln, regexec(
    "^rep +(\\d+) int +(\\d+) +([0-9.]+) s est ([-+][0-9.]+)", ln))
  m <- Filter(function(z) length(z) == 5L, m)
  if (!length(m)) return(NULL)
  data.frame(rep = as.integer(vapply(m, `[`, "", 2)),
             n_int = as.integer(vapply(m, `[`, "", 3)),
             secs = as.numeric(vapply(m, `[`, "", 4)),
             est = as.numeric(vapply(m, `[`, "", 5)),
             ## Every logged fit predates the two-arm probe, so all are flexible.
             arm = "flex",
             src = basename(path), stringsAsFactors = FALSE)
}

pool <- function() {
  logs <- Sys.glob("logs/probe-integration*.log")
  from_logs <- do.call(rbind, lapply(logs, parse_log))
  rds <- Sys.glob("results/integration-*.rds")
  from_rds <- do.call(rbind, lapply(rds, function(f) {
    z <- readRDS(f); z$src <- basename(f)
    if (is.null(z$arm)) z$arm <- "flex"
    z[, c("rep", "n_int", "secs", "est", "arm", "src")]
  }))
  all <- rbind(from_rds, from_logs)          # rds first: it wins ties
  all[!duplicated(all[, c("rep", "n_int", "arm")]), ]
}

paired <- function(d, lo, hi, which_arm = "flex") {
  d <- d[d$arm == which_arm, ]
  w <- reshape(d[d$n_int %in% c(lo, hi), c("rep", "n_int", "est")],
               idvar = "rep", timevar = "n_int", direction = "wide")
  w <- w[complete.cases(w), ]
  x <- w[[paste0("est.", hi)]] - w[[paste0("est.", lo)]]
  if (length(x) < 2) return(data.frame(contrast = sprintf("%d minus %d [%s]", hi, lo, which_arm),
                                       n = length(x), mean = NA, se = NA, t = NA,
                                       ci_lo = NA, ci_hi = NA))
  se <- sd(x) / sqrt(length(x))
  data.frame(contrast = sprintf("%d minus %d [%s]", hi, lo, which_arm), n = length(x),
             mean = mean(x), se = se, t = mean(x) / se,
             ci_lo = mean(x) - 1.96 * se, ci_hi = mean(x) + 1.96 * se)
}

if (!interactive()) {
  d <- pool()
  cat("=== every integration measurement, pooled and deduplicated ===\n")
  print(d[order(d$rep, d$n_int), ], row.names = FALSE, digits = 4)
  cat("\n=== mean seconds per fit, by order and arm ===\n")
  print(aggregate(secs ~ n_int + arm, d, function(z) c(mean = mean(z), n = length(z))),
        row.names = FALSE, digits = 4)
  cat("\n=== paired contrasts ===\n")
  rows <- list()
  for (aa in unique(d$arm))
    for (pr in list(c(64, 128), c(64, 256), c(128, 256), c(256, 512)))
      rows[[length(rows) + 1L]] <- paired(d, pr[1], pr[2], aa)
  res <- do.call(rbind, rows)
  print(res[!is.na(res$mean), ], row.names = FALSE, digits = 4)
  saveRDS(d, "results/integration-pooled.rds")
  cat("\nwritten: results/integration-pooled.rds\n")
}
