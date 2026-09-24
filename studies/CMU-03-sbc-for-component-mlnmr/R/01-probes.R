## P1 simulator equals the fitted likelihood; smoke run of every cell type; null and
## positive controls on a few replicates; Pareto k; unit cost. Writes results/probes.md.
##   nice -n 19 Rscript R/01-probes.R
source("R/00-model.R"); g <- build_grid(); out <- c("# Probes", "")
cpu <- function(expr) { t0 <- proc.time()[["user.self"]]; v <- force(expr); list(v = v, s = proc.time()[["user.self"]] - t0) }

## P1: the coded log-likelihood computed here from multinma's stored integration
## points, minus (log_prob - log prior) from multinma's compiled model, must be
## constant in theta. This is the SBC prerequisite: the simulating likelihood is the
## conditioning likelihood.
set.seed(1); cc <- g[1, ]; sm <- simulate(cc); ipd <- sm$net$ipd; a <- sm$net$agd_arm
sf <- suppressWarnings(suppressMessages(stanfit_of(sm$net, chains = 2, iter = 1, warmup = 0, algorithm = "Fixed_param"))); ord <- upars_order(sf)
ll_r <- function(th) sum(vapply(split(seq_len(nrow(ipd)), paste(ipd$.study, ipd$.trt)), function(i)
    sum(stats::dbinom(ipd$.r[i], 1, stats::plogis(eta(th, cbind(ipd$x1[i], ipd$x2[i]), as.character(ipd$.study[i[1]]), as.character(ipd$.trt[i[1]]))), log = TRUE)), 0)) +
  sum(vapply(seq_len(nrow(a)), function(i) stats::dbinom(a$.r[i], a$.n[i],
    mean(stats::plogis(eta(th, cbind(a$.int_x1[[i]], a$.int_x2[[i]]), as.character(a$.study[i]), as.character(a$.trt[i])))), log = TRUE), 0))
dif <- replicate(20, { th <- draw_theta(); ll_r(th) - (rstan::log_prob(sf, th[ord], adjust_transform = FALSE) - logprior(t(th[ord]))) })
out <- c(out, "## P1 simulator against multinma's coded likelihood", "",
  sprintf("- R coded log-likelihood minus multinma's, over 20 prior draws: SD %.1e (a constant offset is the dropped normalizing terms)", stats::sd(dif)), "")
stopifnot(stats::sd(dif) < 1e-6)

## Smoke: one replicate per distinct cell type; every quantity must return a PIT in [0, 1].
set.seed(2); types <- c(1, 3, 7, 15, 16, 17, 5)
sm1 <- lapply(types, function(i) cpu(one_rep(g[i, ])))
for (z in sm1) stopifnot(all(z$v$u >= 0 & z$v$u <= 1))
out <- c(out, "## Smoke run", "", "| cell | construction | Q | margin | identification | implementation | sampler | CPU s | Pareto k | contrast PIT | log-lik PIT |",
  "|---:|---|---:|---|---|---|---|---:|---:|---:|---:|",
  vapply(seq_along(types), function(k) { cc <- g[types[k], ]; v <- sm1[[k]]$v
    sprintf("| %d | %s | %d | %s | %s | %s | %s | %.1f | %s | %.3f | %.3f |", cc$cell, cc$cons, cc$Q, cc$margin, cc$ident, cc$impl, cc$sampler, sm1[[k]]$s,
            if (is.na(v$k_hat[1])) "" else sprintf("%.2f", v$k_hat[1]), v$u[v$quantity == "contrast"], v$u[v$quantity == "loglik"]) }, ""), "")

## Controls: coded null (cell 1), 100 replicates; prior-as-posterior (15) and sign
## error (16), 20 each.
ctl <- function(i, n, seed) { set.seed(seed); do.call(rbind, lapply(seq_len(n), function(k) transform(one_rep(g[i, ]), rep = k))) }
ks <- function(u) stats::ks.test(u, "punif")$p.value
runs <- data.frame(cell = c(1, 15, 16), n = c(100, 20, 20), seed = c(101, 115, 116))
res <- lapply(seq_len(nrow(runs)), function(k) cpu(ctl(runs$cell[k], runs$n[k], runs$seed[k])))
out <- c(out, "## Controls (KS p-values; the registered run uses 1000 replicates per cell)", "",
  "| cell | implementation | replicates | seed | contrast | log-lik | smallest parameter p (which) | max Pareto k | CPU s |", "|---:|---|---:|---:|---:|---:|---|---:|---:|")
for (k in seq_along(res)) { r <- res[[k]]$v; i <- runs$cell[k]
  pp <- vapply(LAB, function(q) ks(r$u[r$quantity == q]), 0)
  out <- c(out, sprintf("| %d | %s | %d | %d | %.3f | %.2g | %.4f (%s) | %s | %.0f |", i, g$impl[i], runs$n[k], runs$seed[k], ks(r$u[r$quantity == "contrast"]),
                        ks(r$u[r$quantity == "loglik"]), min(pp), names(pp)[which.min(pp)], if (all(is.na(r$k_hat))) "" else sprintf("%.2f", max(r$k_hat, na.rm = TRUE)), res[[k]]$s)) }
out <- c(out, "", "With 15 quantities per cell, the chance that some quantity has p < 0.001 under a correct null is about 1.5%; the registered null threshold is p >= 0.001 per quantity at 1000 replicates.")

## Unit cost and total, from the smoke and control timings.
is_cpu <- res[[1]]$s / 100; nuts_cpu <- sm1[[which(types == 17)]]$s
ncell_is <- sum(g$sampler == "is")
tot <- (ncell_is * N_SIM * is_cpu + N_NUTS * nuts_cpu) / 3600
out <- c(out, "", "## Unit cost", "",
  sprintf("- CPU per importance-sampling replicate %.1f s (coded, Q 64); NUTS replicate %.1f s; Q 512 replicate %.1f s", is_cpu, nuts_cpu, sm1[[which(types == 7)]]$s),
  sprintf("- total CPU: %d IS cells x %d + %d NUTS replicates, about %.1f hours (user time under load average %s; an upper bound)",
          ncell_is, N_SIM, N_NUTS, tot, strsplit(system("sysctl -n vm.loadavg", intern = TRUE), " ")[[1]][2]), "")
writeLines(out, "results/probes.md"); cat(out, sep = "\n")
