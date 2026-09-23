## ---------------------------------------------------------------------------
## COV-03: registered constants.
##
## A variable that is purely prognostic on the logit scale changes the marginal
## log odds ratio, because the marginal effect depends on the distribution of the
## prognostic index u = gamma'x. To second order in Var(u),
##
##   Delta(F) ~= delta - Var_F(u) * {expit(alpha + E_F u + delta) - expit(alpha + E_F u)},
##
## so Delta depends on BOTH the variance of u and, through the risk difference at
## the mean index, on its mean. DESIGN.md section 2 claimed dependence on the
## variance alone; that is wrong whenever Var(u) > 0, and the grid below crosses
## the two so the correction is measured rather than asserted.
##
##   source("R/00-config.R")
## ---------------------------------------------------------------------------

MASTER_SEED <- 20260923L

P       <- 3L            # prognostic covariates, independent normal
ALPHA   <- stats::qlogis(0.3)
DELTA_A <- -0.8          # conditional log OR, A versus C
DELTA_B <- -0.5          # conditional log OR, B versus C
EM_BETA <- 0.4           # A x x1 interaction when effect modification is present
N_ARM   <- 500L          # per arm, both trials

LEVELS <- list(
  design   = c("anchored", "unanchored"),
  var_T    = c(0.25, 1, 4),      # Var_T(u): prognostic strength in the target
  ratio    = c(0.5, 1, 2),       # Var_S(u) / Var_T(u)
  shift    = c(0, 0.3, 0.6),     # target covariate mean minus source, in target SDs
  em       = c("none", "present")
)

## Material bias on the log odds ratio (DESIGN.md section 7).
BIAS_MATERIAL <- 0.05
NOMINAL <- 0.95
N_SIM <- 1000L
G_POINTS <- 4000L        # target draws for G-computation, fixed per replicate

build_grid <- function() {
  g <- expand.grid(design = LEVELS$design, var_T = LEVELS$var_T,
                   ratio = LEVELS$ratio, shift = LEVELS$shift, em = LEVELS$em,
                   KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g$cell <- seq_len(nrow(g))
  g
}

## Prognostic coefficient per covariate, set so Var_T(u) takes its level with
## target covariate SD 1: Var_T(u) = P g^2.
gcoef <- function(var_T) sqrt(var_T / P)
sd_S <- function(ratio) sqrt(ratio)
