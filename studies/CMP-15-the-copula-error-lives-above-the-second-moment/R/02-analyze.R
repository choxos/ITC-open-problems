## Errors by link and copula, the registered decision, controls, envelope, integration order.
## Writes results/summary.csv and results/decision.md.
source("R/00-model.R")
e <- read.csv("results/errors.csv"); cal <- read.csv("results/calibration.csv"); qm <- read.csv("results/qmc.csv"); con <- read.csv("results/contrasts.csv")
g <- e[e$recon == "gauss", ]; u <- e[e$recon == "gauss_uncal", ]
e0 <- e[e$truth_family != "gauss" | e$recon == "gauss_uncal", ]
summ <- do.call(rbind, lapply(split(e0, list(e0$link, e0$truth_family, e0$recon), drop = TRUE), function(z)
  data.frame(link = z$link[1], truth_family = z$truth_family[1], recon = z$recon[1], max_abs_error = max(abs(z$error)), max_mcse = max(z$mcse))))
write.csv(summ, "results/summary.csv", row.names = FALSE)
thr <- 0.02
pr <- g[g$link == "cloglog" & g$truth_family %in% c("clayton", "gumbel"), ]
matters <- any(abs(pr$error) > thr & abs(pr$error) > 3 * pr$mcse)
nl <- g[g$link != "identity" & g$truth_family != "gauss", ]
verdict <- if (matters) "FAMILY MATTERS" else if (all(abs(nl$error) < thr)) "REFUTED" else "MIXED"
cal_ok <- all(abs(cal$realized_r[cal$family != "gauss_uncal"] - cal$r[cal$family != "gauss_uncal"]) <= 0.005)
null_ok <- all(abs(e$error[e$link == "identity"]) < 1e-10)
pos <- g[g$link == "log" & g$truth_family == "gumbel" & g$margin == "beta" & g$r == 0.6 & g$gamma == 0.3, ]
## Falsifier: a wrong flexible family against the calibrated Gaussian, same truth and cell.
wf <- merge(e[!(e$recon %in% c("gauss", "gauss_uncal")) & e$truth_family != "gauss" & e$link != "identity", c("margin", "r", "link", "gamma", "truth_family", "recon", "error")],
            g[, c("margin", "r", "link", "gamma", "truth_family", "error")], by = c("margin", "r", "link", "gamma", "truth_family"), suffixes = c("_flex", "_gauss"))
worse <- mean(abs(wf$error_flex) > abs(wf$error_gauss))
t3 <- g[g$truth_family == "t3" & g$link != "identity", ]
## Integration order: RMSE of the calibrated Gaussian against the true value, primary cells.
tr <- e[e$recon == "gauss" & e$r == 0.6, c("margin", "link", "gamma", "truth_family", "truth", "error")]
qm$link <- sub(":.*", "", qm$label); qm$gamma <- as.numeric(sub(".*:", "", qm$label))
qo <- merge(qm, tr, by = c("margin", "link", "gamma"))
qo$rmse <- sqrt((qo$mean - qo$truth)^2 + qo$sd^2)
write.csv(qo, "results/qmc_rmse.csv", row.names = FALSE)
f3 <- function(x) sprintf("%.3f", x)
md <- c("# Decision", "", sprintf("**Registered primary: %s.** Calibrated Gaussian, complementary log-log, tail-dependent truth: largest absolute error %s (MCSE at most %s); %d of %d values above %.2f.",
          verdict, f3(max(abs(pr$error))), sprintf("%.4f", max(pr$mcse)), sum(abs(pr$error) > thr), nrow(pr), thr), "",
  sprintf("Largest absolute error of the calibrated Gaussian by link over non-Gaussian truths: logit %s, complementary log-log %s, log %s.",
          f3(max(abs(nl$error[nl$link == "logit"]))), f3(max(abs(nl$error[nl$link == "cloglog"]))), f3(max(abs(nl$error[nl$link == "log"])))), "",
  sprintf("Uncalibrated Gaussian against the Gaussian truth, largest absolute error (logit and complementary log-log): normal margins %s, Beta margins %s; log link %s and %s.",
          f3(max(abs(u$error[u$truth_family == "gauss" & u$margin == "normal" & u$link %in% c("logit", "cloglog")]))), f3(max(abs(u$error[u$truth_family == "gauss" & u$margin == "beta" & u$link %in% c("logit", "cloglog")]))),
          f3(max(abs(u$error[u$truth_family == "gauss" & u$margin == "normal" & u$link == "log"]))), f3(max(abs(u$error[u$truth_family == "gauss" & u$margin == "beta" & u$link == "log"])))), "",
  sprintf("Falsifier: a wrong flexible family was further from the truth than the calibrated Gaussian in %.0f%% of comparisons.", 100 * worse), "",
  sprintf("Envelope over five families, t-copula truth (outside the families): contained in %d of %d non-identity cells; median width %s.",
          sum(t3$contained), nrow(t3), f3(stats::median(t3$env_hi - t3$env_lo))), "",
  sprintf("Controls: matched correlation within 0.005 for every calibrated family: %s (largest deviation %s); identity link errors exactly zero: %s; positive (log link, Gumbel, Beta, r 0.6, gamma 0.3) beyond 3 MCSE: %s (error %s, MCSE %s).",
          cal_ok, sprintf("%.4f", max(abs(cal$realized_r - cal$r)[cal$family != "gauss_uncal"])), null_ok, abs(pos$error) > 3 * pos$mcse, f3(pos$error), f3(pos$mcse)), "")
writeLines(md, "results/decision.md"); cat(md, sep = "\n")
