# DESIGN: what would the two summaries CMP-14 asks for actually tell an analyst?

**Target problem.** CMP-14 *Aggregate-data-only interactions may be prior-driven*.
Verdict in the catalog: partially addressed, very high priority.

**Status.** Design sketch. Nothing registered yet, no protocol, no critique round run.
Three groundwork probes are complete and are what this document rests on.

---

## 1. What the catalog asks for, and what is already answered

CMP-14 says: interaction parameters informed only by aggregate data can be regularized into
finite posterior intervals by the prior, so a proper credible interval is not evidence that
the likelihood contributed anything. It credits `cpaic` with three optional diagnostics and
names precisely what is missing:

> a default numerical summary: **prior-to-posterior contraction per interaction parameter**
> and an **effective likelihood rank**, reported without the analyst having to ask.

Two things are already settled and this study must not re-run them.

**CMU-02 answered the generic version.** It measured the operating characteristics of five
prior-sensitivity diagnostics, contraction among them, in a conjugate Gaussian
population-adjusted network. Contraction as a threshold rule had sensitivity 0.363; as a
continuous score the family reached AUC 0.51 to 0.78. Its headline was that these
diagnostics measure the prior's *influence* while the harm comes from the prior's
*location*. Its own statement of scope says CMP-14 "is touched only for the generic
aggregate-only interaction, not for component models".

**CMP-13 answered what the shared-interaction restriction costs.** Coverage of the causal
within-trial component interaction falls from 93.8% to 17.2% as the within-trial and
across-trial coefficients diverge. It did not examine any diagnostic.

So the open part is the join: in a **component** network, where a component's interaction can
be identified through routes that do not exist in a plain network, do the two summaries
CMP-14 names tell an analyst anything they need?

## 2. The five information states, and why the component structure adds one

With $K$ binary components, treatment $t$ is an indicator $c_t$, and additivity gives it
effect $c_t'\delta$ and modification $c_t'\Gamma$. For an individual in study $s$,

$$\eta = \alpha_s + c_t'\delta + x\,(\beta + c_t'\Gamma).$$

Each evidence source is a different linear functional of $\Gamma$:

| state | route | causal? |
|---|---|---|
| **A** | IPD within-study covariate variation, component has its own trial | yes, randomized |
| **B** | aggregate curvature: on a nonlinear link the arm mean depends on the covariate variance, so one aggregate study carries information with no between-study contrast | yes, but weak |
| **C** | between-study gradient in reported covariate means | **no**, ecological and confounded |
| **D** | nothing; the coordinate is rank-deficient | n/a |
| **E** | **additivity**: $\Gamma_k$ has no arm of its own but $c_{1,k} - c_1 = e_k$ | yes if additivity holds |

State **E** is the one component methods create and no other design has. State **B** exists
only on a nonlinear link, which is why CMU-02's identity-link design could not contain it.

## 3. What the groundwork already shows

Three probes, all closed form on an identity link, in `R/00-geometry.R` through
`R/03-probe-anticorrelation.R`.

**The summaries do separate "no information" cleanly.** A component appearing nowhere gives
contraction 1.000; two aggregate studies at the *same* covariate mean give 0.995, and the
effective rank drops by exactly one. So for state D the diagnostics work, and the structural
half of CMP-14's request is sound.

**They do not separate randomized information from confounded information.** In one
configuration:

| state | route | contraction | marginal likelihood precision |
|---|---|---:|---:|
| A | own IPD trial | 0.064 | 240.2 |
| E | additivity, randomized | 0.081 | 150.2 |
| C | between-study gradient, confounded | 0.082 | 147.3 |
| C0 | same but no gradient | 0.995 | 0.0 |
| D | absent | 1.000 | 0.0 |

**E and C are numerically indistinguishable** while their causal standing is opposite.

**The collision is generic, not a coincidence of the sizes chosen.** Sweeping the arm size
in state E and the between-study covariate spread in state C, the ranges overlap, and a
confounded interaction at spread 3.0 contracts to 0.0384 against the best randomized
configuration's 0.0408. No threshold orders them.

**Worse: the summary moves the wrong way.** With causal $\Gamma_W = 0.40$ and across-study
$\Gamma_B = 0.80$, increasing the between-study spread from 0.3 to 3.0 takes contraction
from 0.359 to 0.038 while coverage of the causal estimand goes from 0.890 to **0.000**. The
null control holds: with $\Gamma_B = \Gamma_W$ coverage stays 0.950 to 0.962 across the same
spreads, so the collapse is caused by the discordance and not by the geometry.

This is a stronger statement than CMU-02's. There the diagnostic was uninformative about the
harm; here it is **anti-correlated** with it over the knob an analyst would most naturally
read as reassuring.

## 4. The question, stated so it can fail

> Reported as default output, do prior-to-posterior contraction and effective likelihood
> rank distinguish the information states of a component interaction, and does either
> predict whether the reported interval covers the causal estimand?

Prespecified failure conditions, to be fixed before anything is run:

1. If contraction's AUC for predicting non-coverage exceeds some registered value across the
   scenario set, the summary is useful and the headline above is wrong.
2. If the E-versus-C collision disappears once the aggregate likelihood is nonlinear, the
   result is an artifact of the identity link and is withdrawn.
3. If the effective rank at any threshold separates C from E, the rank half of the request
   is sufficient on its own.

## 5. Shape of the study

**Two experiments, only one of which needs the machine.**

*E1, exact.* The geometry and coverage above, extended to a registered grid of component
networks crossing: which state each component is in, IPD fraction, between-study covariate
spread, discordance $\Gamma_B - \Gamma_W$, prior scale, and whether additivity holds. Closed
form, so no Monte Carlo error contaminates a diagnostic's verdict, which is the same
argument CMU-02 made and it applies verbatim. Cheap.

*E2, fitted.* State B exists only on a nonlinear link, and the whole "aggregate-data-only"
framing of CMP-14 is about aggregate arms carrying real information through curvature. This
needs actual ML-NMR fits with aggregate integration on a logit or log link. **Stan-bound, and
it cannot start until the OUT-11 benchmark releases the machine.**

**A third route worth registering as a candidate answer rather than only a critique.** The
diagnostics fail because they are functions of the information matrix alone, which knows
nothing about which rows are randomized. A summary that *does* separate the states is
available from the same object at no extra cost: decompose each interaction's marginal
likelihood precision into the share contributed by IPD within-study rows, by aggregate
curvature, and by the between-study gradient. `R/00-geometry.R` already computes exactly
this decomposition, and in the table above it separates E (150.2 from IPD, 0.0 from
aggregate) from C (0.0 from IPD, 147.1 from aggregate) perfectly where contraction cannot.
If that holds up across the grid, the study delivers a replacement rather than a complaint.

## 6. What this cannot settle

- Additivity is assumed to hold in states A, C, D and E; whether it *does* is CMP-13's and a
  separate question. State E's causal standing is conditional on it, and the design will
  include an additivity-violated arm to price that.
- One continuous covariate.
- Nothing here evaluates a plot read by an analyst, only automatic numerical summaries.
- Coverage is of the conditional interaction coefficient and of a target-population
  contrast; nothing is claimed about other estimands.
