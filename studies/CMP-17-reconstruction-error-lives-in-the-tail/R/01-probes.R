## P1 every method runs in every cell, P2 materiality by route and estimand,
## P2c one arm's Kaplan-Meier error and number at risk, P3 unit cost.
## Writes results/probes.md.
source("R/00-model.R"); g <- build_grid(); out <- c("# Probes", "")

## P1: one replicate per cell with a 2-draw ensemble (the pooling path runs).
set.seed(1); p1 <- lapply(seq_len(nrow(g)), function(i) one_rep(g[i, ], m = 2))
out <- c(out, "## P1 one replicate per cell, 2-draw ensemble", "",
  sprintf("- cell %d (%s, table %g, %s, %d per arm, %s): methods %s; routes %s; estimates finite %s", g$cell, g$res, g$table, g$cens, g$n, g$effect,
          vapply(p1, function(r) paste(unique(r$method), collapse = ", "), ""), vapply(p1, function(r) paste(unique(r$route), collapse = ", "), ""),
          vapply(p1, function(r) all(is.finite(r$est) & r$w > 0), TRUE)), "")

## P2: replicates without ensemble: single-reconstruction error about the oracle
## over the oracle's spread across replicates (materiality), mean error, and the
## single's mean SE over the oracle's.
p2 <- function(cell, k) { set.seed(2); r <- do.call(rbind, lapply(seq_len(k), function(i) { z <- one_rep(cell, m = 0); o <- z[z$method == "oracle", ]; s <- z[z$method == "single", ]
  data.frame(route = o$route, estimand = o$estimand, oracle = o$est, err = s$est - o$est, se_o = sqrt(o$w), se_s = sqrt(s$w)) }))
  vapply(split(r, paste(r$route, r$estimand)), function(z) sprintf("%s %s %.3f (mean error %.4f, SE ratio %.3f)", z$route[1], z$estimand[1],
    sqrt(mean(z$err^2)) / stats::sd(z$oracle), mean(z$err), mean(z$se_s) / mean(z$se_o)), "") }
out <- c(out, "## P2 materiality, mean error and SE ratio by route and estimand (no ensemble)", "",
  paste("- null control (fine, monthly table, 250 per arm, 40 replicates):", paste(p2(g[g$ctrl == "null", ], 40), collapse = "; ")),
  paste("- coarse, no table, clustered, 250 per arm (40 replicates):", paste(p2(g[g$ctrl == "none" & g$table == 0 & g$cens == "clustered", ], 40), collapse = "; ")),
  paste("- large-trial cell, 1000 per arm (20 replicates):", paste(p2(g[g$ctrl == "large", ], 20), collapse = "; ")), "")

## P2c: one arm (study 2's control), 30 replicates: Kaplan-Meier error of the single
## reconstruction at 12, 29.5, 30 and 30.5 months, and the number at risk at 30
## months in the true data and in the reconstruction.
km_at <- function(d, t) summary(survival::survfit(survival::Surv(pmax(time, 1e-3), status) ~ 1, data = d), times = t, extend = TRUE)$surv
p2c <- function(cell) { set.seed(4); r <- t(replicate(30, { d <- draw(cell); pc <- publish(d$c2, cell); rc <- reconstruct(pc$pts, pc, cell$n)
  c(sapply(c(T_MS, 29.5, T_LATE, 30.5), function(t) km_at(rc, t) - km_at(d$c2, t)), sum(d$c2$time >= T_LATE), sum(rc$time >= T_LATE)) }))
  sprintf("KM error RMSE at 12, 29.5, 30, 30.5 months %s; at risk at 30 months true %.1f, reconstructed %.1f",
          paste(sprintf("%.4f", sqrt(colMeans(r[, 1:4]^2))), collapse = ", "), mean(r[, 5]), mean(r[, 6])) }
out <- c(out, "## P2c one arm: Kaplan-Meier error by time and number at risk (30 replicates each)", "",
  paste("- null control (fine, monthly table):", p2c(g[g$ctrl == "null", ])),
  paste("- coarse, no table, clustered:", p2c(g[g$ctrl == "none" & g$table == 0 & g$cens == "clustered", ])), "")

## P3: full replicate (M_DRAW draws per arm) at 250 and 1000 per arm.
tm <- sapply(c(g$cell[g$ctrl == "none" & g$table == 0 & g$cens == "clustered"], g$cell[g$ctrl == "large"]), function(k) { set.seed(3)
  system.time(z <- one_rep(g[k, ]))[c("elapsed", "user.self")] })
cpu <- ifelse(g$n == 1000L, tm[2, 2], tm[2, 1])
out <- c(out, "## P3 unit cost", "",
  sprintf("- full replicate (%d draws per arm): 250 per arm elapsed %.1f s, CPU %.1f s; 1000 per arm elapsed %.1f s, CPU %.1f s", M_DRAW, tm[1, 1], tm[2, 1], tm[1, 2], tm[2, 2]),
  sprintf("- total CPU for %d cells x %d replicates: about %.1f hours", nrow(g), N_SIM, N_SIM * sum(cpu) / 3600), "")
writeLines(out, "results/probes.md"); cat(out, sep = "\n")
