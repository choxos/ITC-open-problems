## Exploratory (not registered): is the disagreement larger than Monte Carlo noise?
## Split each cell's replicates into odd and even halves; correlate each measure's
## method ranking between halves (reliability) and RMSE in one half with expected
## loss in the other (cross-measure agreement free of shared noise).
SRC <- "../COV-03-prognostic-index-variance"
cfg <- unique(read.csv(file.path(SRC, "results/summary.csv"))[, c("cell", "shift", "ratio")])
files <- list.files(file.path(SRC, "results/run"), full.names = TRUE)
sp <- function(a, b) suppressWarnings(stats::cor(a, b, method = "spearman"))
out <- do.call(rbind, lapply(files, function(f) { z <- readRDS(f); z <- z[is.finite(z$est) & is.finite(z$se), ]
  do.call(rbind, lapply(c(-0.1, 0.1), function(d) {
    h <- lapply(0:1, function(k) { w <- z[z$rep %% 2 == k, ]
      t(sapply(split(w, w$method), function(m) { tau <- m$truth + d
        c(rmse = sqrt(mean((m$est - m$truth)^2)), loss = mean((m$est < tau) != (m$truth < tau))) })) })
    data.frame(cell = z$cell[1], d = d, rel_rmse = sp(h[[1]][, "rmse"], h[[2]][, "rmse"]), rel_loss = sp(h[[1]][, "loss"], h[[2]][, "loss"]),
               cross = mean(c(sp(h[[1]][, "rmse"], h[[2]][, "loss"]), sp(h[[2]][, "rmse"], h[[1]][, "loss"])))) })) }))
out <- merge(cfg, out, by = "cell"); out$poor <- out$shift == 0.6 & out$ratio == 0.5
write.csv(out, "results/reliability.csv", row.names = FALSE)
a <- aggregate(cbind(rel_rmse, rel_loss, cross) ~ poor, data = out, FUN = function(x) mean(x, na.rm = TRUE))
print(a)

## Averaged over both sides of the threshold (the analyst does not know which side the
## truth is on): does the loss ranking agree with RMSE?
s <- read.csv("results/scored.csv"); s <- s[s$c == 1, ]
both <- do.call(rbind, lapply(c(0.1, 0.3), function(a) {
  w <- s[abs(s$d) == a, ]; l <- aggregate(cbind(wrong, rmse) ~ cell + method + shift + ratio, data = w, FUN = mean)
  do.call(rbind, lapply(split(l, l$cell), function(z) data.frame(cell = z$cell[1], dist = a, poor = z$shift[1] == 0.6 & z$ratio[1] == 0.5,
    rho = sp(z$rmse, z$wrong), same_best = z$method[which.min(z$rmse)] == z$method[which.min(z$wrong)]))) }))
write.csv(both, "results/two-sided.csv", row.names = FALSE)
print(aggregate(cbind(rho, same_best) ~ dist + poor, data = both, FUN = function(x) mean(x, na.rm = TRUE)))
