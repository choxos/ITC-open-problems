## ---------------------------------------------------------------------------
## E1: the exact arm. No Monte Carlo anywhere.
##
## WHY EXACT RATHER THAN SIMULATED. The study evaluates summaries that are meant
## to tell an analyst whether a posterior is held up by its prior. If the
## posterior were itself a Monte Carlo approximation, every diagnostic would
## carry sampling noise of unknown size and a failure to flag could not be
## separated from a failure to converge. With a conjugate Gaussian model the
## posterior, the coverage and every diagnostic are closed form, so a failure
## belongs to the diagnostic. CMU-02 made the same argument and it applies here
## verbatim.
##
## A CONSEQUENCE WORTH STATING AS A RESULT RATHER THAN A CONVENIENCE. In this
## model the posterior covariance is (I + P0)^{-1}, which does not involve the
## data at all. Prior-to-posterior contraction and effective likelihood rank are
## therefore functions of the DESIGN, computable before a single patient is
## enrolled. Whatever they measure, it cannot be anything about what the data
## turned out to say. That is not an artifact of the exact arm; it is a property
## of the summaries CMP-14 asks for, and the exact arm is what makes it visible.
##
## There is consequently no replicate count in E1. Coverage is not a simulated
## frequency but a normal probability, computed from the exact sampling
## distribution of the posterior mean.
## ---------------------------------------------------------------------------

source("R/00-config.R")
source("R/00-geometry.R")

e_vec <- function(...) { v <- numeric(K_COMP); v[c(...)] <- 1; v }
PBO <- numeric(K_COMP)

## --- the four networks, one per information state ---------------------------
##
## Components 1, 2 and 4 are always in state A with their own individual-data
## trials, so the network is otherwise well identified. Only component 3 moves.
## Every state carries the SAME total number of patients, so a difference
## between states is a difference of evidence structure and not of sample size.
## The first version of this file did not equalize them and state E looked worse
## than state A partly because it had one study fewer.
build_state <- function(state, spread, n) {
  base <- list(
    list(ipd = TRUE, mu = 0.0, sd = 1, n = n, arms = list(PBO, e_vec(1))),
    list(ipd = TRUE, mu = 0.2, sd = 1, n = n, arms = list(PBO, e_vec(2))),
    list(ipd = TRUE, mu = 0.1, sd = 1, n = n, arms = list(PBO, e_vec(4))))
  target <- switch(state,
    own_ipd = list(
      list(ipd = TRUE, mu = 0.1 - spread / 2, sd = 1, n = n,
           arms = list(PBO, e_vec(3))),
      list(ipd = TRUE, mu = 0.1 + spread / 2, sd = 1, n = n,
           arms = list(PBO, e_vec(3)))),
    additivity = list(
      list(ipd = TRUE, mu = 0.1 - spread / 2, sd = 1, n = n,
           arms = list(PBO, e_vec(1), e_vec(1, 3))),
      list(ipd = TRUE, mu = 0.1 + spread / 2, sd = 1, n = n,
           arms = list(PBO, e_vec(1), e_vec(1, 3)))),
    ecological = list(
      list(ipd = FALSE, mu = 0.1 - spread / 2, sd = 1, n = n,
           arms = list(PBO, e_vec(3))),
      list(ipd = FALSE, mu = 0.1 + spread / 2, sd = 1, n = n,
           arms = list(PBO, e_vec(3)))),
    absent = list(
      ## Two studies of the same total size that do not touch component 3, so
      ## the absent state is not also a smaller study.
      list(ipd = TRUE, mu = 0.1 - spread / 2, sd = 1, n = n,
           arms = list(PBO, e_vec(1))),
      list(ipd = TRUE, mu = 0.1 + spread / 2, sd = 1, n = n,
           arms = list(PBO, e_vec(2)))),
    stop("unregistered information state: ", state))
  net <- make_network(c(base, target))
  ## `make_network` drops all-zero component columns when no arm uses them, which
  ## would silently change the parameter vector's length between states.
  for (k in seq_len(K_COMP)) {
    nm <- sprintf("c%d", k)
    if (is.null(net[[nm]])) net[[nm]] <- 0
  }
  net[, c("study", "ipd", "mu", "sd", "n", sprintf("c%d", seq_len(K_COMP)))]
}

## --- the design, the truth, and the exact sampling distribution --------------
##
## Every arm reduces to weighted design rows: an individual-data arm to its
## Gauss-Hermite nodes with weight n*w, an aggregate arm to a single row at the
## study covariate mean with precision n. That is the whole distinction between
## within-study and between-study information and it is why an aggregate arm
## carries no covariate variation on an identity link.
build_design <- function(net) {
  S <- max(net$study); K <- K_COMP; p <- S + K + 1 + K
  gh <- gh_rule(32)
  rows <- list(); prec <- numeric(0); agd <- logical(0); arm <- integer(0)
  for (i in seq_len(nrow(net))) {
    if (as.logical(net$ipd[i])) {
      xs <- net$mu[i] + sqrt(2) * net$sd[i] * gh$x
      w  <- gh$w / sqrt(pi)
      for (j in seq_along(xs)) {
        rows[[length(rows) + 1L]] <- design_row(net, i, xs[j], S, K)
        prec <- c(prec, net$n[i] * w[j] / SIGMA^2)
        agd <- c(agd, FALSE); arm <- c(arm, i)
      }
    } else {
      rows[[length(rows) + 1L]] <- design_row(net, i, net$mu[i], S, K)
      prec <- c(prec, net$n[i] / SIGMA^2)
      agd <- c(agd, TRUE); arm <- c(arm, i)
    }
  }
  list(X = do.call(rbind, rows), prec = prec, agd = agd, arm = arm,
       S = S, K = K, p = p, C = C_of(net), net = net)
}

theta_true <- function(b) {
  th <- numeric(b$p)
  th[b$S + seq_len(b$K)] <- DELTA_MAIN
  th[b$S + b$K + 1] <- BETA_PROG
  th[b$S + b$K + 1 + seq_len(b$K)] <- GAMMA_W
  th
}

gi_of <- function(b, k = TARGET) b$S + b$K + 1 + k

## THE TRUTH THE DATA COME FROM, which is not the model's mean.
##
## Two departures, each attached to the state it prices.
##
##   discord: the ACROSS-STUDY association is Gamma_W + discord rather than
##            Gamma_W. It acts only where a covariate mean carries information
##            across studies, which is the aggregate rows. This is confounding by
##            case mix: studies with different populations differ in ways nobody
##            randomized, so the between-study gradient is not the causal one.
##
##   synergy: the combination 1+3 has an interaction the additive model has no
##            term for. It acts only on arms containing BOTH components, which
##            is what makes it invisible to a model that assumes additivity and
##            what makes state E's causal standing conditional.
mean_true <- function(b, discord, synergy) {
  th <- theta_true(b)
  m <- as.vector(b$X %*% th)
  gi <- gi_of(b)
  hit_eco <- b$agd & b$C[b$arm, TARGET] == 1
  m[hit_eco] <- m[hit_eco] + discord * b$X[hit_eco, gi]
  ## Arms carrying components 1 and 3 together. The extra term is a modification,
  ## so it multiplies the covariate exactly as an interaction does.
  both <- b$C[b$arm, 1] == 1 & b$C[b$arm, TARGET] == 1
  if (synergy != 0 && any(both)) {
    xcol <- b$X[, b$S + b$K + 1]        # the covariate column
    m[both] <- m[both] + synergy * xcol[both]
  }
  m
}

## --- the exact posterior and exact coverage ---------------------------------
exact_fit <- function(b, prior_sd, discord, synergy) {
  P0 <- diag(1 / prior_sd^2, b$p)
  W <- b$prec
  I <- crossprod(b$X * sqrt(W))
  Vpost <- solve(I + P0)
  A <- Vpost %*% t(b$X * W)
  mu_t <- mean_true(b, discord, synergy)
  gi <- gi_of(b)
  m_exp <- as.vector(A %*% mu_t)[gi]
  ## Var(posterior mean) = A W^{-1} A' = Vpost I Vpost. Forming W^{-1} would
  ## overflow: the outer Gauss-Hermite weights are of order 1e-20.
  v_samp <- (Vpost %*% I %*% Vpost)[gi, gi]
  sd_post <- sqrt(Vpost[gi, gi])
  truth <- theta_true(b)[gi]
  z <- stats::qnorm(1 - (1 - NOMINAL) / 2)
  lo <- (truth - m_exp - z * sd_post) / sqrt(v_samp)
  hi <- (truth - m_exp + z * sd_post) / sqrt(v_samp)
  list(I = I, P0 = P0, Vpost = Vpost, gi = gi,
       bias = m_exp - truth, post_sd = sd_post,
       samp_sd = sqrt(v_samp),
       coverage = stats::pnorm(hi) - stats::pnorm(lo))
}
