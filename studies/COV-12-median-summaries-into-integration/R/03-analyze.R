## Contrast error by reconstruction; is it a function of mean error alone?
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
summ <- do.call(rbind, lapply(split(d, d$cell), function(z) do.call(rbind, lapply(c("normal", "lognormal", "sample_exact"), function(m)
  data.frame(cell = z$cell[1], method = m, bias = mean(z[[m]]), mcse = stats::sd(z[[m]]) / sqrt(nrow(z)), rmse = sqrt(mean(z[[m]]^2)))))))
summ <- merge(g, summ, by = "cell")
write.csv(summ, "results/summary.csv", row.names = FALSE)
## Per replicate, regress contrast error on beta x mean error, by link, pooling
## both reconstructions. Identity: slope 1 and R^2 near 1 predicted.
fitlink <- function(lk) {
  z <- d[d$link == lk, ]
  e <- c(z$normal - z$sample_exact, z$lognormal - z$sample_exact)
  m <- c(z$beta * z$mean_err_normal, z$beta * z$mean_err_lognormal)
  f <- stats::lm(e ~ m); c(slope = coef(f)[["m"]], r2 = summary(f)$r.squared)
}
fi <- fitlink("identity"); fl <- fitlink("logit")
worst <- summ[summ$method == "normal", ]; worst <- worst[order(-abs(worst$bias)), ][1:5, ]
md <- c("# Decision", "",
  sprintf("**Refuting sentence (contrast error is a monotone function of mean-recovery error): holds under the identity link (slope %.3f, R^2 %.3f); %s under the logit link (slope %.3f, R^2 %.3f).**",
          fi[["slope"]], fi[["r2"]], if (fl[["r2"]] < 0.9) "fails" else "holds", fl[["slope"]], fl[["r2"]]), "",
  "Reconstruction error is measured net of the sample's own sampling error (error minus that of integrating over the actual target sample).", "",
  "Largest normal-reconstruction biases:", "", "| link | skew | summary | n | beta | bias | RMSE |", "|---|---:|---|---:|---:|---:|---:|",
  sprintf("| %s | %.1f | %s | %d | %.1f | %.3f | %.3f |", worst$link, worst$skew, worst$summary, worst$n_t, worst$beta, worst$bias, worst$rmse), "",
  sprintf("Quantile-matched lognormal: max |bias| %.3f over all cells; normal: %.3f.",
          max(abs(summ$bias[summ$method == "lognormal"])), max(abs(summ$bias[summ$method == "normal"]))), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
