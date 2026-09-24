## Post hoc, after decision.md was read. The registered censoring model is fitted to
## the whole follow-up, so the administrative end at 36 months enters as a
## covariate-free mass of censoring events and pulls the x1 coefficient toward
## zero (0.88 against a true 1.2 in a 20000-per-arm check). Here the censoring
## process is observed on [0, TAU) only, which is all the weights use. Same seeds.
##   Rscript R/05-corrected.R point   every cell, no bootstrap (bias, SD, sandwich SE)
##   Rscript R/05-corrected.R boot    primary cell 4 with the registered bootstrap
source("R/00-model.R")
ipcw_registered <- ipcw
ipcw <- function(d, form) { adm <- d$time >= TAU; d$status[adm] <- 1L; d$time[adm] <- TAU; ipcw_registered(d, form) }
g <- build_grid(); mode <- commandArgs(TRUE)[1]
seed <- function(k, cell) set.seed(MASTER_SEED %% 1e6 + 7919L * k + 104729L * cell)
if (mode == "point") {
  r <- do.call(rbind, parallel::mclapply(seq_len(nrow(g)), function(i) { cc <- g[i, ]
    do.call(rbind, lapply(seq_len(N_SIM), function(k) { seed(k, cc$cell); d <- draw(cc); e <- estimates(d, cc)
      data.frame(cell = cc$cell, rep = k, truth = truth(cc), part_km = e$est[["part_km"]], tada = e$est[["tada"]],
                 tada_miss = e$est[["tada_miss"]], se_fixed = e$se_fixed, ess_part = ess(e$wp), ess_prod = ess(e$wp * e$wc)) })) },
    mc.cores = as.integer(Sys.getenv("WORKERS", "2"))))
  saveRDS(r, "results/corrected-point.rds")
  s <- do.call(rbind, lapply(split(r, r$cell), function(z) { n <- nrow(z); f <- function(m) mean(z[[m]] - z$truth)
    data.frame(cell = z$cell[1], n = n, bias_part_km = f("part_km"), bias_tada = f("tada"), mcse_tada = stats::sd(z$tada) / sqrt(n),
               bias_tada_miss = f("tada_miss"), sd_tada = stats::sd(z$tada), rmse_tada = sqrt(mean((z$tada - z$truth)^2)),
               rmse_part_km = sqrt(mean((z$part_km - z$truth)^2)), se_ratio_fixed = mean(z$se_fixed) / stats::sd(z$tada),
               cov_fixed = mean(abs(z$tada - z$truth) <= 1.96 * z$se_fixed), ess_part = mean(z$ess_part), ess_prod = mean(z$ess_prod)) }))
  write.csv(merge(g, s, by = "cell"), "results/corrected-point.csv", row.names = FALSE); print(s, digits = 3)
} else {
  cc <- g[g$cell == 4, ]
  r <- do.call(rbind, parallel::mclapply(seq_len(N_SIM), function(k) { seed(k, cc$cell)
    z <- tryCatch(one_rep(cc), error = function(e) NULL); if (is.null(z)) NULL else transform(z, rep = k) },
    mc.cores = as.integer(Sys.getenv("WORKERS", "2")), mc.preschedule = FALSE))
  r$truth <- truth(cc); saveRDS(r, "results/corrected-cell4-boot.rds")
  s <- do.call(rbind, lapply(split(r, r$method), function(z) { e <- z$est - z$truth; n <- nrow(z)
    data.frame(method = z$method[1], n = n, bias = mean(e), mcse = stats::sd(e) / sqrt(n), se_ratio = mean(z$se) / stats::sd(z$est),
               coverage = mean(abs(e) <= 1.96 * z$se), ess_prod = mean(z$ess_prod)) }))
  write.csv(s, "results/corrected-cell4-boot.csv", row.names = FALSE); print(s, digits = 3)
}
