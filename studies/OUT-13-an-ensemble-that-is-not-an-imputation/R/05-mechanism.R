## Post hoc, exploratory, after decision.md was read: which analyst variant carries
## the RMST offset, and how much of the draws' spread comes from pixel jitter
## against random censoring placement. First 10 replicates of cells 3 (fine) and 4
## (coarse), 6-month table, same seeds as the registered run; no elapsed limit.
## Writes results/mechanism.csv.
suppressWarnings(source("R/00-model.R"))
reconstruct <- function(pts, pub, events = pub$events, draw_cens = FALSE) {
  p <- IPDfromKM::preprocess(dat = pts, trisk = pub$trisk, nrisk = pub$nrisk, totalpts = N, maxy = 1)
  ipd <- if (draw_cens) getIPD_draw(prep = p, armID = 1, tot.events = events) else
    IPDfromKM::getIPD(prep = p, armID = 1, tot.events = events)
  data.frame(time = ipd$IPD$time, status = ipd$IPD$status)
}
g <- build_grid()
out <- do.call(rbind, lapply(c(3L, 4L), function(ci) { cc <- g[ci, ]
  do.call(rbind, lapply(1:10, function(k) {
    set.seed(MASTER_SEED %% 1e6 + 7919L * k + 104729L * cc$cell)
    d <- draw(cc); pub <- publish(d, cc); th <- functionals(d)[EST]
    sub <- function(n) { i <- unique(round(seq(1, nrow(pub$pts), length.out = min(n, nrow(pub$pts))))); pub$pts[i, ] }
    var_err <- vapply(seq_len(6), function(v) functionals(reconstruct(sub(c(30, 60, 120)[(v - 1) %% 3 + 1]), pub,
      events = if (v <= 3) pub$events else NULL))[["rmst24"]] - th[["rmst24"]], 0)
    ens <- function(jit, cens) vapply(seq_len(M_CAL), function(j) functionals(reconstruct(if (jit) jitter_pts(pub) else pub$pts, pub,
      draw_cens = cens))[EST], numeric(3))
    b <- cbind(both = apply(ens(TRUE, TRUE), 1, stats::var), jitter = apply(ens(TRUE, FALSE), 1, stats::var),
               censoring = apply(ens(FALSE, TRUE), 1, stats::var))
    rbind(data.frame(cell = ci, res = cc$res, rep = k, quantity = paste0("B_", rownames(b)), both = b[, "both"],
                     jitter = b[, "jitter"], censoring = b[, "censoring"], events_given = NA, events_not_given = NA, row.names = NULL),
          data.frame(cell = ci, res = cc$res, rep = k, quantity = paste0("rmst24_error_", c(30, 60, 120), "_points"),
                     both = NA, jitter = NA, censoring = NA, events_given = var_err[1:3], events_not_given = var_err[4:6]))[
      , c("cell", "res", "rep", "quantity", "both", "jitter", "censoring", "events_given", "events_not_given")]
  })) }))
write.csv(out, "results/mechanism.csv", row.names = FALSE)
s <- aggregate(cbind(both, jitter, censoring, events_given, events_not_given) ~ cell + res + quantity,
               data = out, FUN = mean, na.rm = TRUE, na.action = na.pass)
write.csv(s, "results/mechanism-summary.csv", row.names = FALSE); print(s, digits = 3)
