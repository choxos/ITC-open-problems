## The design.
##
## Revised after an adversarial review of the proposed design and a timed pilot.
## Four changes, each recorded in protocol.md with its reason.

MASTER_SEED <- 20260728L

## 2000 replicates. For coverage near 0.95 the Monte Carlo SE is
## sqrt(0.95*0.05/2000) = 0.00487, so a 2-point coverage error is four Monte
## Carlo SEs from nominal. Methods share the replicate, so paired coverage
## contrasts are considerably more precise than that.
N_REP <- 2000L

LEVELS <- list(
  ## How the treatment network relates contrasts to components. THE change the
  ## review forced. In the originally proposed network every contrast added
  ## exactly one component, so each interaction was recoverable from a directly
  ## component-isolating comparison and the study would have tested ordinary
  ## network meta-regression while claiming to test component models. The
  ## `bundled` network contains contrasts that move two components at once, so
  ## the component decomposition has to do real work.
  network = c("isolating", "bundled"),

  ## Discordance between the within-trial causal interaction and the across-trial
  ## association, as gamma_B = rho * gamma_W. Swept rather than set to two
  ## extremes: the review's point was that naming only rho = 0 and rho = 1 fixes
  ## the sign of the answer, and that a reader needs to see where the damage
  ## becomes material rather than that it exists at the extremes.
  ##
  ## `null` and `between-only` are separate because they set gamma_W = 0 and so
  ## are not on the rho scale. `nonlinear` is a misspecification stress case in
  ## which no linear model is correct.
  pattern = c("rho1", "rho0.5", "rho0", "rho-0.5", "rho-1", "null",
              "between-only", "nonlinear"),

  ## Which trials contribute individual data. `no-B-ipd` gives individual data
  ## only to trials whose contrasts add component A, so gamma_W,B has no
  ## within-trial contrast anywhere and rests entirely on aggregate variation.
  ## That is the case IDN-06 is actually about, and the proposed design never
  ## produced it.
  ipd = c("all", "six", "four", "four-low", "no-B-ipd"),

  n_arm = c(100L, 400L),

  ## Between-study spread in modifier prevalence.
  spread = c("narrow", "wide")
)

build_scenarios <- function() {
  g <- expand.grid(network = LEVELS$network, pattern = LEVELS$pattern,
                   ipd = LEVELS$ipd, n_arm = LEVELS$n_arm, spread = LEVELS$spread,
                   KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  g <- g[order(g$network, g$pattern, g$ipd, g$n_arm, g$spread), ]
  g$scenario <- seq_len(nrow(g))
  rownames(g) <- NULL
  g
}

## What counts as a usable fit. Declared here so a failure is a recorded outcome.
## The protocol also fixes how failures enter the summaries: every performance
## measure is reported twice, once over converged replicates and once counting a
## failed replicate as non-coverage, and any scenario where the two differ by
## more than one percentage point is flagged. Silently dropping failures would
## favor whichever method fails on its hardest replicates.
CONVERGENCE <- list(max_score = 1e-6, max_abs_par = 5,
                    min_eig = 1e-8, max_cond = 1e10)

## The prespecified conclusions.
##
## The proposed rule was a five-clause count over 72 cells with thresholds that
## had never been checked against what the design can resolve. A timed pilot
## made the shape of the answer clear enough to state a rule that can actually
## be evaluated, so the rule is about where the boundary lies rather than
## whether an effect exists, as in study 1.
DECISION <- list(
  material_at_mild_discordance =
    "At rho = 0.5, meaning the across-trial association is half the within-trial
     interaction, shared-Gamma coverage for at least one component is below 0.90
     with its Monte Carlo 95% interval excluding 0.95, in at least one network
     structure at n = 400.",

  material_only_at_strong_discordance =
    "Shared-Gamma coverage stays within 0.93 to 0.97 at rho = 0.5 but falls
     below 0.90 at rho = 0 or rho = -1.",

  not_material =
    "Shared-Gamma coverage stays within 0.93 to 0.97 at every rho, and the
     median absolute standardized bias across the discordant patterns is below
     0.10.",

  uninformative_if =
    "Any method converges on fewer than 95% of replicates in more than 10% of
     scenarios; or conditional and unconditional coverage differ by more than
     0.01 anywhere; or the shared model fails its own negative controls, meaning
     coverage outside 0.93 to 0.97 at rho = 1 or under `null`, since the shared
     model is correctly specified there; or the split model fails those same
     controls."
)

## Separately prespecified, because it is the claim the catalog entry actually
## makes and it is not about coverage.
##
## CMP-13 says aggregate studies pull a shared Gamma toward the across-trial
## association. If that is the mechanism, bias should vanish when every trial
## supplies individual data. The pilot suggests it does not, because the shared
## parameterization imposes the equality whatever the data type. This is stated
## in advance so the finding is a test rather than an observation.
MECHANISM_CLAIM <- list(
  catalog_claim = "Shared-Gamma bias is caused by aggregate studies.",
  supported_if = "Under `all` IPD, absolute standardized bias for shared Gamma
     is below 0.10 in every discordant pattern.",
  refuted_if = "Under `all` IPD, absolute standardized bias for shared Gamma
     exceeds 0.20 in at least half the discordant patterns, which would show the
     conflation is a property of the parameterization and not of the data type."
)
