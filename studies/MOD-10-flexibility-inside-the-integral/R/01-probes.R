## P1 every method runs in every cell and the one-column prediction equals the
## summation-convention form; P2 least-false parametric bias from one large
## replicate; P3 null control; P4 unit cost and the integration burden.
## Writes results/probes.md.
source("R/00-model.R"); g <- build_grid(); out <- c("# Probes", "")

## P1: one replicate per cell; prediction check on one gp fit.
set.seed(1); p1 <- lapply(seq_len(nrow(g)), function(i) one_rep(g[i, ]))
d <- draw(g[4, ]); f <- mgcv::gam(y ~ s + xbar + s(X, by = LA, k = K, bs = "gp"), data = d, weights = w, method = "REML", knots = list(X = KNOTS))
x <- c(0.5, 1, 1.25, 1.5); cols <- f$smooth[[1]]$first.para:f$smooth[[1]]$last.para
nd1 <- list(s = factor(rep(1, 4), levels = levels(d$s)), xbar = rep(0, 4), X = matrix(x, ncol = 1), LA = matrix(1, 4, 1))
ndQ <- list(s = nd1$s, xbar = nd1$xbar, X = matrix(x, 4, Q), LA = cbind(1, matrix(0, 4, Q - 1)))
dp <- max(abs(stats::predict(f, nd1, type = "lpmatrix")[, cols] - stats::predict(f, ndQ, type = "lpmatrix")[, cols]))
out <- c(out, "## P1 one replicate per cell", "",
  sprintf("- cell %d (%s, unsupported %.2f): methods %s; finite %s", g$cell, g$shape, g$pi, vapply(p1, function(r) paste(r$method, collapse = ", "), ""),
          vapply(p1, function(r) all(is.finite(r$est_S + r$est_U) & r$se > 0), TRUE)),
  sprintf("- one-column against %d-column prediction of the surface basis: largest difference %.1e; gp rank %d of %d", Q, dp, f$rank, length(stats::coef(f))), "")

## P2: parametric surface's least-false bias, supported and unsupported parts, from
## one replicate with 100 times the arm size.
big <- function(cell) { n0 <- N_ARM; N_ARM <<- 100L * n0; on.exit(N_ARM <<- n0); set.seed(2); d <- draw(cell)
  b <- stats::coef(stats::lm(y ~ s + xbar + A + A:xbar, data = d, weights = w))[c("A", "xbar:A")]; tw <- twt(cell)
  c(S = sum(tw$S * (b[1] + b[2] * TGT$S - tau(TGT$S, cell$shape))), U = sum(tw$U * (b[1] + b[2] * TGT$U - tau(TGT$U, cell$shape)))) }
p2 <- t(sapply(seq_len(nrow(g)), function(i) big(g[i, ])))
out <- c(out, "## P2 parametric least-false bias (arm size 15000)", "",
  sprintf("- %s, unsupported %.2f: truth %.3f; bias on S %.3f, off S %.3f", g$shape, g$pi, vapply(seq_len(nrow(g)), function(i) truth(g[i, ]), 0), p2[, "S"], p2[, "U"]), "")
## P2b: the same for the flexible surfaces at 20% unsupported mass (arm size 3000),
## which says whether the positive control can fire.
bigf <- function(cell) { n0 <- N_ARM; N_ARM <<- 20L * n0; on.exit(N_ARM <<- n0); set.seed(2); r <- one_rep(cell); tw <- twt(cell)
  r$bias_S <- r$est_S - sum(tw$S * tau(TGT$S, cell$shape)); r$bias_U <- r$est_U - sum(tw$U * tau(TGT$U, cell$shape)); r }
out <- c(out, "## P2b flexible surfaces at 20% unsupported mass (arm size 3000, one replicate)", "",
  unlist(lapply(c("hinge", "plateau"), function(sh) { r <- bigf(g[g$shape == sh & g$pi == 0.2, ])
    sprintf("- %s: %s", sh, paste(sprintf("%s on S %.3f, off S %.3f", r$method, r$bias_S, r$bias_U), collapse = "; ")) })), "")

## P2c: the plateau at 20% unsupported mass at the registered arm size, 50 replicates:
## bias on and off S by method, with MCSE, which says whether the positive control can fire.
cc <- g[g$shape == "plateau" & g$pi == 0.2, ]; tw <- twt(cc); set.seed(5)
r <- do.call(rbind, lapply(1:50, function(k) one_rep(cc)))
r$bS <- r$est_S - sum(tw$S * tau(TGT$S, cc$shape)); r$bU <- r$est_U - sum(tw$U * tau(TGT$U, cc$shape))
out <- c(out, "## P2c plateau, 20% unsupported, arm size 150 (50 replicates)", "",
  sprintf("- %s: bias on S %.3f (MCSE %.3f), off S %.3f (MCSE %.3f)", names(tapply(r$bS, r$method, mean)), tapply(r$bS, r$method, mean),
          tapply(r$bS, r$method, stats::sd) / sqrt(50), tapply(r$bU, r$method, mean), tapply(r$bU, r$method, stats::sd) / sqrt(50)), "")

## P3: null control, linear surface, no unsupported mass, 20 replicates.
## P4: CPU per replicate from P3, and one gp fit at Q and 4Q quadrature points.
cc <- g[g$shape == "linear" & g$pi == 0, ]; set.seed(3)
tm <- system.time(r <- do.call(rbind, lapply(1:20, function(k) one_rep(cc))))[["user.self"]]
b <- tapply(r$est_S + r$est_U, r$method, mean) - truth(cc); s <- tapply(r$est_S + r$est_U, r$method, stats::sd)
q4 <- function(q) { Q <<- q; on.exit(Q <<- 64L); set.seed(4); d <- draw(g[4, ])
  system.time(mgcv::gam(y ~ s + xbar + s(X, by = LA, k = K, bs = "gp"), data = d, weights = w, method = "REML", knots = list(X = KNOTS)))[["user.self"]] }
out <- c(out, "## P3 null control (linear, no unsupported mass, 20 replicates) and P4 cost", "",
  sprintf("- bias (empirical SD): %s", paste(sprintf("%s %.3f (%.3f)", names(b), b, s), collapse = ", ")),
  sprintf("- CPU per replicate %.2f s; total for %d cells x %d replicates about %.1f CPU-hours", tm / 20, nrow(g), N_SIM, nrow(g) * N_SIM * tm / 20 / 3600),
  sprintf("- one gp fit: %.2f s CPU at %d quadrature points, %.2f s at %d", q4(64L), 64L, q4(256L), 256L), "")
writeLines(out, "results/probes.md"); cat(out, sep = "\n")
