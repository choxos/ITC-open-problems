## P1 every method runs in every cell, P2 analytic gap, P3 null control, P4 ESS of
## all-candidate MAIC and unit cost. Writes results/probes.md.
source("R/00-model.R"); g <- build_grid(); out <- c("# Probes", "")
nas <- function(r) paste(sprintf("%s %d", names(tapply(is.na(r$est), r$method, sum)), tapply(is.na(r$est), r$method, sum)), collapse = ", ")

## P1: one replicate per cell; an NA estimate is a method failure.
set.seed(1); p1 <- do.call(rbind, lapply(seq_len(nrow(g)), function(i) one_rep(g[i, ])))
out <- c(out, "## P1 one replicate in each of the 20 cells", "",
  sprintf("- rows %d (expected %d); NA estimates by method: %s", nrow(p1), 5 * nrow(g), nas(p1)), "")

## P2: DESIGN.md section 2 before any simulation. Interaction SE with unit-variance
## covariates and residual SD 1 is sqrt(2 / N_ARM); omission bias is BETA DELTA.
se <- sqrt(2 / N_ARM); df <- 2 * N_ARM - 14; tc <- stats::qt(1 - ALPHA / 2, df)
pw <- function(b) stats::pt(tc, df, b / se, lower.tail = FALSE) + stats::pt(-tc, df, b / se)
b80 <- stats::uniroot(function(b) pw(b) - 0.8, c(0.01, 2))$root
out <- c(out, "## P2 analytic detection-materiality gap (6 candidates)", "",
  sprintf("- interaction SE %.3f; strength at 80%% detection %.3f", se, b80),
  sprintf("- strength at material omission (bias %.1f): %s", MATERIAL, paste(sprintf("shift %.1f: %.2f", c(0.2, 0.5), MATERIAL / c(0.2, 0.5)), collapse = "; ")),
  sprintf("- analytic power on the grid: %s", paste(sprintf("%.2f: %.3f", unique(g$beta), pw(unique(g$beta))), collapse = "; ")),
  sprintf("- predicted gap on the grid (material omission, detection below 0.8): %s", paste(vapply(c(0.2, 0.5), function(dl) { b <- unique(g$beta); b <- b[b * dl >= MATERIAL & pw(b) < 0.8]
    sprintf("shift %.1f: %s", dl, if (length(b)) paste(b, collapse = ", ") else "empty") }, ""), collapse = "; ")), "")

## P3: null control, strength 0, shift 0.5, 100 replicates per candidate count.
## P4: effective sample size of all-candidate MAIC and unit cost, same replicates.
out <- c(out, "## P3 null control and P4 ESS and cost (strength 0, shift 0.5, 100 replicates each)", "")
for (pp in c(6L, 13L)) { cc <- g[g$beta == 0 & g$delta == 0.5 & g$p == pp, ]; set.seed(3)
  tm <- system.time(r <- do.call(rbind, lapply(1:100, function(k) one_rep(cc))))[["user.self"]]; z <- r[r$method == "none", ]
  b <- tapply(r$est, r$method, mean, na.rm = TRUE) - truth(cc); ess <- tapply(r$ess, r$method, mean, na.rm = TRUE)
  out <- c(out, sprintf("- %d candidates: per-candidate false selection %.3f; bias %s; NA %s", pp, (sum(z$n_false) + sum(z$detect)) / (100 * pp),
                        paste(sprintf("%s %.3f", names(b), b), collapse = ", "), nas(r)),
    sprintf("- %d candidates: mean ESS of %d, oracle %.0f, screened %.0f, all %.0f; CPU %.3f s per replicate", pp, 2L * N_ARM,
            ess[["maic_oracle"]], ess[["maic_screen"]], ess[["maic_all"]], tm / 100)) }
out <- c(out, sprintf("- total for %d cells x %d replicates: about %.1f CPU-minutes at the 13-candidate unit cost", nrow(g), N_SIM, nrow(g) * N_SIM * tm / 100 / 60), "")
writeLines(out, "results/probes.md"); cat(out, sep = "\n")
