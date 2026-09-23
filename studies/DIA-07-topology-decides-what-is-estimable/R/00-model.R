## ---------------------------------------------------------------------------
## DIA-07: the same total sample size in different topologies, with the one
## individual-data trial placed on different edges.
##
## Treatments A, B, C, D; effect of k against A at covariate x: d_k + g_k x, with
## d = (0, -0.1, -0.2, -0.15) and g = (0, G, 3G, 2G) (so every edge is modified).
## Decision contrast: D versus A in a target with covariate mean M_T. Every trial's
## population has covariate mean 0 and SD 1; total 1200 patients split equally
## over the trials; outcome SD 1.
## An aggregate trial of k versus l estimates its own population's effect,
## (d_l - d_k) + (g_l - g_k) * 0, with variance 4 / n. The individual-data trial
## is standardized to the target by regression (STC): unbiased for
## (d_l - d_k) + (g_l - g_k) M_T, variance 4 (1 + M_T^2) / n.
## Fixed-effect network meta-analysis by generalized least squares; the
## estimate's bias and SD are exact; decision error is the probability that its
## sign differs from the truth's, and coverage that of its 95% interval.
## ---------------------------------------------------------------------------

N_TOT <- 1200; DK <- c(A = 0, B = -0.1, C = -0.2, D = -0.15)
TOPOLOGIES <- list(line = rbind(c("A", "B"), c("B", "C"), c("C", "D")),
                   star = rbind(c("A", "B"), c("A", "C"), c("A", "D")),
                   loop_tail = rbind(c("A", "B"), c("B", "C"), c("A", "C"), c("C", "D")),
                   two_path = rbind(c("A", "B"), c("B", "D"), c("A", "C"), c("C", "D")))
TRT <- c("B", "C", "D")                                            # basic parameters against A

evaluate <- function(topo, ipd, G, M_T) {
  E <- TOPOLOGIES[[topo]]; n <- N_TOT / nrow(E); gk <- c(A = 0, B = G, C = 3 * G, D = 2 * G)
  X <- t(apply(E, 1, function(e) (TRT == e[2]) - (TRT == e[1])))
  mean_e <- vapply(seq_len(nrow(E)), function(j) (DK[[E[j, 2]]] - DK[[E[j, 1]]]) + (gk[[E[j, 2]]] - gk[[E[j, 1]]]) * (if (j == ipd) M_T else 0), 0)
  v <- 4 / n * ifelse(seq_len(nrow(E)) == ipd, 1 + M_T^2, 1)
  h <- drop(c(0, 0, 1) %*% solve(crossprod(X, X / v)) %*% t(X / v))  # D versus A
  truth <- DK[["D"]] + gk[["D"]] * M_T; est <- sum(h * mean_e); sd <- sqrt(sum(h^2 * v))
  data.frame(topology = topo, ipd_edge = if (ipd == 0) "none" else paste(E[ipd, ], collapse = "-"), G = G, M_T = M_T,
             truth = truth, bias = est - truth, sd = sd, decision_error = if (truth < 0) stats::pnorm(0, est, sd, lower.tail = FALSE) else stats::pnorm(0, est, sd),
             coverage = stats::pnorm(1.96 - (est - truth) / sd) - stats::pnorm(-1.96 - (est - truth) / sd),
             ipd_weight = if (ipd == 0) 0 else abs(h[ipd]) / sum(abs(h)))
}
