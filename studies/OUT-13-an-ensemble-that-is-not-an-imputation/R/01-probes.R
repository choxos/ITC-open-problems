## P1 pipeline validation (null-control reporting), P3 ensemble size, P4 unit cost.
## Writes results/probes.md.
source("R/00-model.R"); g <- build_grid(); out <- c("# Probes", "")

## P1: fine figure, monthly risk table: the single reconstruction should match the
## true-data functionals to well within their sampling error.
set.seed(11); nc <- g[g$ctrl == "null", ]
p1 <- t(replicate(20, { d <- draw(nc); pub <- publish(d, nc)
  functionals(reconstruct(pub$pts, pub))[EST] - functionals(d)[EST] }))
sd_o <- apply(t(replicate(200, functionals(draw(nc))[EST])), 2, stats::sd)
out <- c(out, "## P1 null control (20 replicates)", "",
  sprintf("- %s: RMSE of single reconstruction %.2g; sampling SD %.3g; ratio %.3f", EST,
          sqrt(colMeans(p1^2)), sd_o, sqrt(colMeans(p1^2)) / sd_o), "")

## P3: ensemble size. Between variance from 20 draws against 60 draws, cell 4.
set.seed(13); cc <- g[4, ]
p3 <- t(replicate(10, { d <- draw(cc); pub <- publish(d, cc)
  v <- do.call(rbind, lapply(1:60, function(k) functionals(reconstruct(jitter_pts(pub), pub, draw_cens = TRUE))[EST]))
  c(apply(v[1:20, ], 2, stats::var) / apply(v, 2, stats::var)) }))
out <- c(out, "## P3 ensemble size (10 replicates, cell 4)", "",
  sprintf("- %s: B from 20 draws / B from 60 draws, median %.2f, range %.2f to %.2f", EST,
          apply(p3, 2, stats::median), apply(p3, 2, min), apply(p3, 2, max)), "")

## P4: unit cost per replicate, fine and coarse.
tm <- vapply(c(1, 2), function(i) system.time(one_rep(g[i, ]))[["elapsed"]], 0)
cpu <- vapply(c(1, 2), function(i) system.time(one_rep(g[i, ]))[["user.self"]], 0)
out <- c(out, "## P4 unit cost", "",
  sprintf("- elapsed per replicate: fine %.1f s, coarse %.1f s (CPU %.1f and %.1f s) on a shared machine", tm[1], tm[2], cpu[1], cpu[2]),
  sprintf("- total CPU for %d cells x %d replicates: about %.1f hours", nrow(g), N_SIM, nrow(g) * N_SIM * mean(cpu) / 3600), "")
writeLines(out, "results/probes.md"); cat(out, sep = "\n")
