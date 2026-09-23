## Calibrations, contrasts under every family, errors, envelope, integration order.
## Writes results/calibration.csv, results/contrasts.csv, results/errors.csv, results/qmc.csv.
source("R/00-model.R")
grid <- expand.grid(margin = c("normal", "beta"), r = c(0.3, 0.6), KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
cal <- do.call(rbind, lapply(seq_len(nrow(grid)), function(i) { m <- grid$margin[i]; r <- grid$r[i]
  p <- vapply(FAMILIES, function(f) calibrate(f, r, m), 0)
  data.frame(margin = m, r = r, family = c(FAMILIES, "gauss_uncal"), param = c(p, r)) }))
## Realized correlation on independent draws (the matched-margin check).
cal$realized_r <- vapply(seq_len(nrow(cal)), function(i) { f <- sub("_uncal", "", cal$family[i])
  mean_pearson(draw_x(f, cal$param[i], cal$margin[i], N_CAL, 99)) }, 0)
write.csv(cal, "results/calibration.csv", row.names = FALSE)

## Contrasts per family in N_BATCH independent batches.
con <- do.call(rbind, lapply(seq_len(nrow(cal)), function(i) { f <- sub("_uncal", "", cal$family[i])
  b <- vapply(seq_len(N_BATCH), function(k) all_contrasts(draw_x(f, cal$param[i], cal$margin[i], N_DRAW / N_BATCH, 1000 * i + k)), numeric(length(LABELS)))
  data.frame(cal[i, c("margin", "r", "family")], label = LABELS, value = rowMeans(b), batch_sd = apply(b, 1, stats::sd)) }))
con$link <- sub(":.*", "", con$label); con$gamma <- as.numeric(sub(".*:", "", con$label))
write.csv(con, "results/contrasts.csv", row.names = FALSE)

## Errors against each true family; MCSE from the batch SDs.
key <- function(z) paste(z$margin, z$r, z$label)
envf <- c("gauss", "clayton", "gumbel", "sclayton", "sgumbel")
err <- do.call(rbind, lapply(TRUE_FAM, function(tf) {
  tr <- con[con$family == tf, ]
  do.call(rbind, lapply(unique(c("gauss", "gauss_uncal", setdiff(envf, tf))), function(rf) { rc <- con[con$family == rf, ]; rc <- rc[match(key(tr), key(rc)), ]
    data.frame(tr[, c("margin", "r", "link", "gamma")], truth_family = tf, recon = rf, truth = tr$value, error = rc$value - tr$value,
               mcse = sqrt(tr$batch_sd^2 + rc$batch_sd^2) / sqrt(N_BATCH)) })) }))
env <- do.call(rbind, lapply(split(con[con$family %in% envf, ], list(con$margin[con$family %in% envf], con$r[con$family %in% envf], con$label[con$family %in% envf]), drop = TRUE),
  function(z) data.frame(z[1, c("margin", "r", "link", "gamma")], env_lo = min(z$value), env_hi = max(z$value))))
err <- merge(err, env, by = c("margin", "r", "link", "gamma"))
err$contained <- err$truth >= err$env_lo & err$truth <= err$env_hi
write.csv(err, "results/errors.csv", row.names = FALSE)

## Integration order: calibrated Gaussian at n randomized-QMC points, primary cells.
qm <- do.call(rbind, lapply(c("normal", "beta"), function(m) { rho <- cal$param[cal$family == "gauss" & cal$margin == m & cal$r == 0.6]
  do.call(rbind, lapply(c(64, 256, 1024, 4096), function(n) {
    v <- vapply(1:200, function(k) all_contrasts(qmc_gauss(rho, m, n, k)), numeric(length(LABELS)))
    data.frame(margin = m, r = 0.6, n = n, label = LABELS, mean = rowMeans(v), sd = apply(v, 1, stats::sd)) })) }))
write.csv(qm, "results/qmc.csv", row.names = FALSE)
cat("done\n")
