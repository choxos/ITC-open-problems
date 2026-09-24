## RMSE of flexible against parametric surfaces, bias split at the support
## boundary, controls; decision.
source("R/00-model.R")
g <- build_grid()
d <- merge(do.call(rbind, lapply(list.files("results/run", full.names = TRUE), readRDS)), g, by = "cell")
tp <- do.call(rbind, lapply(seq_len(nrow(g)), function(i) { tw <- twt(g[i, ]); data.frame(cell = g$cell[i],
  truth_S = sum(tw$S * tau(TGT$S, g$shape[i])), truth_U = sum(tw$U * tau(TGT$U, g$shape[i]))) }))
d <- merge(d, tp, by = "cell"); d$est <- d$est_S + d$est_U; d$truth <- d$truth_S + d$truth_U; d$e <- d$est - d$truth
summ <- do.call(rbind, lapply(split(d, list(d$cell, d$method), drop = TRUE), function(z) { n <- nrow(z); cv <- mean(abs(z$e) <= 1.96 * z$se)
  data.frame(cell = z$cell[1], method = z$method[1], truth = z$truth[1], n = n, bias = mean(z$e), mcse = stats::sd(z$e) / sqrt(n),
             bias_S = mean(z$est_S - z$truth_S), bias_U = mean(z$est_U - z$truth_U), emp_sd = stats::sd(z$est), se_ratio = mean(z$se) / stats::sd(z$est),
             coverage = cv, cov_mcse = sqrt(cv * (1 - cv) / n), rmse = sqrt(mean(z$e^2)), cpu = mean(z$cpu)) }))
## RMSE ratio to the parametric surface with a paired bootstrap 95% interval over replicates.
set.seed(1)
rr <- do.call(rbind, lapply(split(d, d$cell), function(z) { w <- stats::reshape(z[, c("rep", "method", "e")], idvar = "rep", timevar = "method", direction = "wide")
  w <- w[stats::complete.cases(w), ]; rat <- function(i, m) sqrt(mean(w[i, paste0("e.", m)]^2) / mean(w[i, "e.par"]^2))
  do.call(rbind, lapply(setdiff(unique(z$method), "par"), function(m) { b <- replicate(500, rat(sample.int(nrow(w), replace = TRUE), m))
    data.frame(cell = z$cell[1], method = m, rmse_ratio = rat(seq_len(nrow(w)), m), lo = stats::quantile(b, 0.025), hi = stats::quantile(b, 0.975)) })) }))
summ <- merge(merge(g, summ, by = "cell"), rr, by = c("cell", "method"), all.x = TRUE)
summ <- summ[order(summ$shape, summ$pi, summ$method), ]; write.csv(summ, "results/summary.csv", row.names = FALSE)

at <- function(sh, p, m) summ[summ$shape == sh & summ$pi == p & summ$method == m, ]
cls <- function(z) if (z$hi < 1) "better" else if (z$lo > 1) "worse" else "tie"
rule <- function(m) { h0 <- cls(at("hinge", 0, m)); h2 <- cls(at("hinge", 0.2, m)); p2 <- cls(at("plateau", 0.2, m)); off <- "worse" %in% c(h2, p2)
  v <- if (off && h0 == "better") "CROSSOVER CONFIRMED: better on the support, worse with 20% of the target off it" else
    if (off) "PARAMETRIC ADEQUATE: no gain on the support, a loss off it" else
    if (h0 == "worse") "REVERSED: worse on the support, not worse off it" else "REFUTING SENTENCE HOLDS: no loss anywhere, including 20% off the support"
  sprintf("%s (against the parametric surface: hinge at 0 %s, hinge at 0.2 %s, plateau at 0.2 %s; RMSE ratios %s)", v, h0, h2, p2,
          paste(sprintf("%.2f [%.2f, %.2f]", c(at("hinge", 0, m)$rmse_ratio, at("hinge", 0.2, m)$rmse_ratio, at("plateau", 0.2, m)$rmse_ratio),
                        c(at("hinge", 0, m)$lo, at("hinge", 0.2, m)$lo, at("plateau", 0.2, m)$lo), c(at("hinge", 0, m)$hi, at("hinge", 0.2, m)$hi, at("plateau", 0.2, m)$hi)), collapse = ", ")) }
win <- function(sh) { z <- summ[summ$shape == sh & summ$pi == 0.2, ]; z$method[which.min(z$rmse)] }
nul <- summ[summ$shape == "linear" & summ$method %in% c("par", "spline", "gp"), ]
null_ok <- all(abs(nul$bias) <= 3 * nul$mcse & nul$coverage >= 0.93 & nul$coverage <= 0.97)
ps <- at("plateau", 0.2, "spline"); pp <- at("plateau", 0.2, "par"); pos_ok <- abs(ps$bias_U) > abs(pp$bias_S) - abs(ps$bias_S)
f3 <- function(x) sprintf("%.3f", x)
md <- c("# Decision", "", sprintf("**Registered primary, Gaussian-process surface: %s.**", rule("gp")), "",
  sprintf("Registered secondary, spline surface: %s.", rule("spline")), "",
  sprintf("Unidentifiable assumption (hinge and plateau coincide on the support): lowest RMSE at 20%% unsupported mass is %s under the hinge and %s under the plateau.", win("hinge"), win("plateau")), "",
  sprintf("Null control (linear surface: parametric, spline and Gaussian-process surfaces unbiased within 3 MCSE with coverage 0.93 to 0.97 at every unsupported mass): %s.", null_ok), "",
  sprintf("Positive control (plateau, 20%% unsupported: the spline's unsupported-region bias %s exceeds its supported-region gain over the parametric surface %s): %s.",
          f3(abs(ps$bias_U)), f3(abs(pp$bias_S) - abs(ps$bias_S)), pos_ok), "",
  sprintf("CPU seconds per fit: %s. Replicates dropped: %d.", paste(sprintf("%s %.3f", c("par", "spline", "gp"), vapply(c("par", "spline", "gp"), function(m) mean(summ$cpu[summ$method == m]), 0)), collapse = ", "),
          sum(N_SIM - summ$n[summ$method == "par"])), "",
  "| shape | unsupported mass | method | truth | bias | MCSE | bias on S | bias off S | empirical SD | SE ratio | coverage | RMSE | RMSE / parametric [95% interval] |",
  "|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|",
  sprintf("| %s | %.2f | %s | %.3f | %.3f | %.3f | %.3f | %.3f | %.3f | %.2f | %.3f | %.3f | %s |", summ$shape, summ$pi, summ$method, summ$truth, summ$bias, summ$mcse, summ$bias_S, summ$bias_U,
          summ$emp_sd, summ$se_ratio, summ$coverage, summ$rmse, ifelse(is.na(summ$rmse_ratio), "", sprintf("%.2f [%.2f, %.2f]", summ$rmse_ratio, summ$lo, summ$hi))), "")
writeLines(md, "results/decision.md"); cat(md[1:13], sep = "\n")
