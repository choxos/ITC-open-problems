# A violation twice the size that would change a decision raises the
shared effect modifier check’s alarm rate from 1.3% to 4.5%
Ahmad Sofi-Mahmudi
2026-07-28

## What this measures

Population adjustment across a network of trials almost always assumes
**shared effect modification**: that a covariate modifies the effect of
every active treatment in a class in the same way. The assumption is
what lets an analysis borrow an interaction estimated where there are
individual data and apply it where there are only published summaries.

The check in general use for it is the following. Phillippo et al.
([1](#ref-phillippo2023)) fit a multilevel network meta-regression with
a single interaction shared across a treatment class, refit it with
treatment-specific interactions **one covariate at a time**, and compare
the posteriors and the model fit. `multinma` implements it
([2](#ref-multinma)). Their own assessment of its power is explicit: “it
is likely that this approach to assessing the shared effect modifier
assumption has low power, particularly when data are lacking.”

We are not aware of a study measuring what it can detect. That is a
statement about the ML-NMR population-adjustment literature, where the
check is a within-network comparison of shared against
treatment-specific interactions, and it is not a claim about
treatment-by-covariate interaction modeling in network meta-regression
at large, where common, independent and exchangeable interaction
structures have a longer history. It rests on a search of the
population-adjustment methods literature and the `multinma`
documentation rather than on a systematic review, and a reviewer was
right to ask that the scope be stated rather than implied. Within that
scope there is no threshold that separates a pass from a failure, no
statement of how much interaction stability is enough, and no statement
of what a pass licenses. This study measures all three, against a truth
it constructs, under a design registered before any replicate was run.

What it measures is not one procedure. “Compare the posteriors and the
model fit” is a description of an exploratory practice, not a decision
rule, so this study evaluates five explicit rules of our own
construction that the description admits. Those operating
characteristics are ours; the practice they formalize is the published
one, and the distinction matters for every number below.

The central measurement: when the two treatments’ effect modifiers
differ by 0.30, which leaves the transported estimate wrong by twice the
amount that would change a decision, the DIC rule fires in **0.045** of
analyses, 95% interval \[0.029, 0.070\]. When the assumption holds
**exactly** it fires in 0.013 \[0.005, 0.029\]. A violation that doubles
the error that matters moves the alarm rate by about three percentage
points.

The reason is precision, not thresholds: no network in this design came
within a factor of three of the precision needed to place a 95% interval
on the interaction contrast inside the region where the violation would
not matter. Consequently the one reading that could affirm the
assumption rather than merely fail to contradict it never fired, in
3,200 opportunities. That is a statement about what these networks can
resolve, and <a href="#sec-affirm" class="quarto-xref">Section 3.3</a>
shows it is also partly a statement about the prior.

Following the check is still better than not, though not uniformly.
Relaxing exactly what it fires on beat relaxing everything at every
target examined, and beat imposing the restriction at every target
except the one where nothing is transported. What the practice does not
support is being read as a test the assumption has survived.

## Design

### The data-generating mechanism

Individual $i$ in study $j$ on treatment $k$, binomial outcome, logit
link:

$$\mathrm{logit}\, p_{ijk} = \mu_j + \boldsymbol\beta' x_{ijk} + \mathbb{1}\{k \neq \text{PBO}\}\left(d_k + \delta_{jk} + \boldsymbol\gamma_k' x_{ijk}\right)$$

Two covariates, correlated 0.25, prognostic coefficients 0.40. Reference
PBO and two active treatments **A** and **C** in one class, which is
what makes the shared-interaction restriction bind, with equal main
effects 0.70. The drift is carried by $x_1$ and the parameter **is the
contrast**:

$$\gamma_A[x_1] = 0.30 + \tfrac{\text{drift}}{2}, \qquad \gamma_C[x_1] = 0.30 - \tfrac{\text{drift}}{2}, \qquad \gamma_A[x_1] - \gamma_C[x_1] = \text{drift}.$$

$x_2$ is shared exactly, so every replicate supplies one power
observation and one type I error observation from the same four fits.

**One** study contributes individual data and always compares PBO with
A. The rest contribute the arm-level summaries a publication reports. So
A is the treatment whose interaction is estimable within a study, and C
appears only in aggregate studies, where its interaction is identified
through between-study contrasts of covariate means and through the
curvature of the aggregate likelihood ([3](#ref-phillippo2020mlnmr)).
That asymmetry is the situation population adjustment exists for.

| Factor | Levels | What it varies |
|:---|:---|:---|
| drift, $\gamma_A[x_1] - \gamma_C[x_1]$ | 0, 0.30, 0.60, 1.20 | how far the assumption is violated |
| network size $J$ | 6, 12 | how much evidence the network holds |
| covariate spread $\tau_x$ | 0.25, 0.60 | the ecological information about interactions |
| treatment-effect heterogeneity $\tau_{re}$ | 0, 0.15 | a second specification error the check was not built to see |

The registered design: 32 cells, 50 replicates each, four fits per
replicate. Eight further cells at drift 0.15 were added by a dated
amendment during the run and are reported separately in section 3.8.

### The target, and why it is not a design factor

The check reads only the fitted network. Its output therefore **cannot**
depend on the population an analyst later transports to. One set of fits
is scored at every target displacement $s \in \{0, 0.5, 1.0, 1.5\}$
standard deviations along the drifting covariate, and that invariance is
the mechanism under test rather than an assumption of convenience.

Because $x_1$ is prognostic, displacing the target would also slide the
placebo risk along the logistic curve. The reference intercept is solved
separately for each displacement to hold the marginal placebo risk at
0.30 exactly, so displacement moves the treatment contrast and nothing
else.

| drift |   s = 0 | s = 0.5 |   s = 1 | s = 1.5 |
|------:|--------:|--------:|--------:|--------:|
|   0.0 |  0.0000 |  0.0000 |  0.0000 |  0.0000 |
|   0.3 | -0.0032 | -0.0310 | -0.0587 | -0.0858 |
|   0.6 | -0.0063 | -0.0617 | -0.1168 | -0.1704 |
|   1.2 | -0.0117 | -0.1210 | -0.2282 | -0.3302 |

True marginal risk difference for C versus A in the target, computed
exactly by Gauss-Hermite quadrature of the true model. Nine of sixteen
combinations exceed the 0.03 material threshold; displacement 0 never
does.

### The four fits

`class_interactions` in `multinma` 0.9.1.9002 ([4](#ref-multinma_dev))
is a single global switch, so on its own it cannot express a procedure
that relaxes one covariate at a time. The split is carried by the
regression formula, using the `.trt` and `.trtclass` specials.

| Fit         | Formula                                  |
|:------------|:-----------------------------------------|
| `common`    | `~ x1 + x2 + (x1 + x2):.trtclass`        |
| `split_x1`  | `~ x1 + x2 + (x1):.trt + (x2):.trtclass` |
| `split_x2`  | `~ x1 + x2 + (x2):.trt + (x1):.trtclass` |
| `split_all` | `~ x1 + x2 + (x1 + x2):.trt`             |

With two covariates these four fits are the complete model lattice, so a
strategy that relaxes exactly what the check flagged can be scored
rather than approximated.

This only works with `class_interactions = "independent"`. Under the
default `"common"`, an `x:.trt` term in the formula is silently demoted
to the class level: the split fit is the shared fit under another name,
with the same parameter names and a DIC that differs only by Monte Carlo
error. An analyst following the published recipe by editing the formula
alone would see no evidence against sharing in any dataset, because no
split model was ever fitted. Every split fit in this study asserts that
treatment-specific coefficients exist before any statistic is computed
from it.

### Readings of the check

There is no agreed threshold, so every reading in use is reported. With
two active treatments there is exactly one interaction contrast per
covariate, $\gamma_A[x] - \gamma_C[x]$, so no covariate is selected
before the interval is read. That removes one route to miscalibration;
it does not deliver nominal frequentist coverage, and it should not be
reported as if it did. An earlier draft claimed it did, and this study’s
own type I error contradicts the claim: under the global null the 95%
interval rule fires on 0.075 of replicates where there is no
treatment-effect heterogeneity and 0.110 where there is. Avoiding
selection is necessary for coverage, not sufficient.

The rules below are **thresholds we chose**. The DIC differences of 2, 5
and 10 are conventional reading guides for model comparison in general,
not validated cutoffs for detecting a violated shared effect modifier
assumption, and ([5](#ref-spiegelhalter2002)) is cited for the criterion
rather than for those cutoffs applied to this question.

- **DIC rule**: flag if
  $\mathrm{DIC}(\text{split}_x) < \mathrm{DIC}(\text{common}) - c$ for
  $c \in \{2, 5, 10\}$, the criterion of ([5](#ref-spiegelhalter2002))
  read at cutoffs of our choosing; $c = 5$ is the rule the verdict uses.
- **Posterior rule**: flag if the 95% credible interval for the contrast
  excludes zero.
- **Margin rule**: flag if
  $P(|\gamma_A[x] - \gamma_C[x]| > \varepsilon) > 0.95$ with
  $\varepsilon = 0.1531$, the contrast that makes the C-versus-A
  marginal risk difference exactly material at displacement 1. The
  margin is set by consequence, not taste.
- **Continuous scores**: $\Delta\mathrm{DIC}$ and the directional
  posterior probability, scored by AUROC ([6](#ref-hanley1982)).
- **Prior-posterior contraction**, so a fit that reported the prior can
  be told apart from one that reported the data.

## Results

6,400 ML-NMR fits over the registered design (1600 replicates over 32
cells, four models each), 1,600 more in the amendment arm, and 960 in
the prior-sensitivity arm. Every cell returned all 50 replicates: no
replicate was lost to a sampler that failed to start.

**The prior-sensitivity arm is a departure from registration and was not
previously disclosed.** The protocol registers 8 cells at 100 replicates
each, which is 3,200 fits. It ran at 30 replicates per cell, 960 fits. A
reviewer noticed that the published fit count could not be produced from
the registered design and asked where it came from; counting the stored
cells is how the shortfall was found. Nothing in the arm was re-selected
after results were seen, but at 30 replicates a cell-level rate carries
a Monte Carlo standard error near 0.09 rather than the 0.05 the
registered size implied, so this arm’s comparisons are read as
directional and not as measurements. The protocol now records the
departure.

### What the network resolves, and how firmly that can be stated

| studies | spread | heterogeneity | posterior SD, A | posterior SD, C | ratio | what the data alone resolve | multiples of $\varepsilon$ |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 6 | 0.25 | 0.00 | 0.238 | 1.633 | 6.87 | 1.82 | 11.9 |
| 6 | 0.25 | 0.15 | 0.235 | 1.534 | 6.52 | 1.69 | 11.0 |
| 6 | 0.60 | 0.00 | 0.215 | 0.801 | 3.73 | 0.59 | 3.8 |
| 6 | 0.60 | 0.15 | 0.214 | 0.670 | 3.14 | 0.48 | 3.2 |
| 12 | 0.25 | 0.00 | 0.225 | 0.885 | 3.93 | 0.80 | 5.2 |
| 12 | 0.25 | 0.15 | 0.225 | 0.837 | 3.72 | 0.78 | 5.1 |
| 12 | 0.60 | 0.00 | 0.184 | 0.329 | 1.78 | 0.32 | 2.1 |
| 12 | 0.60 | 0.15 | 0.181 | 0.299 | 1.65 | 0.30 | 2.0 |

The standard error the network itself puts on the difference between the
two treatments’ effect modifiers, with the prior removed, against the
difference that would make the target estimate materially wrong.

The difference between the two treatments’ interactions is the quantity
the whole check is about. A network of the kind population adjustment is
applied to resolves it to a standard error of **0.30 to 1.82** on the
log-odds scale. The difference that makes the transported estimate
materially wrong is $\varepsilon = 0.1531$. The evidence is therefore
between **2.0 and 11.9 times too coarse** to see what matters, before
any question of thresholds or rules arises.

**That last column is an approximation and its own sensitivity analysis
says so.** Subtracting prior precision from posterior precision recovers
the likelihood exactly only if both are Gaussian, which a weakly
identified interaction is not. Running the same networks under
`normal(0, 1)` instead of `normal(0, 2.5)` gives a data-only standard
error of about 0.99 where the wider prior gives about 1.73. Those should
agree and do not. The quantity is therefore reported as an
order-of-magnitude statement, not as a measurement, and **no headline
claim in this paper rests on it**; an earlier draft put it in the title
and a reviewer was right that it could not carry that weight.

What is measured rather than derived is the posterior standard deviation
itself, 0.30 to 1.64 across strata, which is what an analyst reads off
the output.

**A correction to how contraction was reported.** Contraction is
$1 - \mathrm{sd}(\text{posterior}) / \mathrm{sd}(\text{prior})$. Until
round-two review it was computed by dividing every arm by 2.5, the prior
of the main design, including the prior-sensitivity arm that was fitted
under `normal(0, 1)`. A reviewer showed from the published numbers alone
that the figures had to be measured against the wrong denominator, and
gave the argument that settles it: for a fixed likelihood, tightening a
prior **cannot raise**
$1 - \mathrm{sd}(\text{post})/\mathrm{sd}(\text{prior})$, yet the paper
reported it rising. The reviewer was right, the error is in
`R/02-fit.R`, and the direction of the reported effect was inverted.
Against the prior each arm was actually fitted under, contraction on the
drifting covariate **falls** from 0.33–0.42 under `normal(0, 2.5)` to
0.20–0.26 under `normal(0, 1)`, which is the expected direction.

What survives, and was the point of the arm, is that the check’s
behavior barely moves: the flag rate is 0.01–0.12 under the wider prior
against 0.00–0.15 under the tighter one. The prior changes how informed
the posterior looks relative to itself and leaves what the check does
almost untouched. At 30 replicates per cell this arm is directional
rather than precise.

The asymmetry the design was built around is large: the treatment with
only aggregate data carries **1.65 to 6.87 times** the posterior spread
of the treatment with individual data. A ratio of two posterior standard
deviations is not free of the prior, as an earlier draft called it; both
posteriors are shrunk toward the same prior. What can be said is
narrower and still worth saying: the ratio requires no subtraction of
prior from posterior precision, so it does not inherit the instability
that demoted the derived column above.

<div id="fig-contraction">

![](figures/contraction.png)

Figure 1: Prior-posterior contraction on the treatment-specific
interaction for the drifting covariate. Zero means the posterior is the
prior.

</div>

**Registered mechanism claim M2 is partly confirmed.** It asked for a
contraction gap of at least 0.20, widening as the network shrinks. The
gap runs from 0.047 to 0.558 and does widen monotonically as the network
shrinks, but it clears 0.20 in 5 of the 8 strata rather than all of
them, missing in the largest network at the widest covariate spread. The
claim is reported as partly met rather than met, and the prior-free
ratio is offered as the measure that should have been registered
instead.

### Power

| drift | studies | spread | heterogeneity | DIC \< -5 | 95% interval |
|------:|--------:|-------:|--------------:|----------:|-------------:|
|   0.3 |       6 |   0.25 |          0.00 |      0.02 |         0.08 |
|   0.3 |       6 |   0.25 |          0.15 |      0.06 |         0.10 |
|   0.3 |       6 |   0.60 |          0.00 |      0.04 |         0.12 |
|   0.3 |       6 |   0.60 |          0.15 |      0.06 |         0.12 |
|   0.3 |      12 |   0.25 |          0.00 |      0.00 |         0.02 |
|   0.3 |      12 |   0.25 |          0.15 |      0.04 |         0.12 |
|   0.3 |      12 |   0.60 |          0.00 |      0.06 |         0.16 |
|   0.3 |      12 |   0.60 |          0.15 |      0.08 |         0.18 |
|   0.6 |       6 |   0.25 |          0.00 |      0.00 |         0.04 |
|   0.6 |       6 |   0.25 |          0.15 |      0.08 |         0.10 |
|   0.6 |       6 |   0.60 |          0.00 |      0.12 |         0.24 |
|   0.6 |       6 |   0.60 |          0.15 |      0.16 |         0.32 |
|   0.6 |      12 |   0.25 |          0.00 |      0.06 |         0.12 |
|   0.6 |      12 |   0.25 |          0.15 |      0.18 |         0.28 |
|   0.6 |      12 |   0.60 |          0.00 |      0.28 |         0.40 |
|   0.6 |      12 |   0.60 |          0.15 |      0.30 |         0.38 |
|   1.2 |       6 |   0.25 |          0.00 |      0.06 |         0.12 |
|   1.2 |       6 |   0.25 |          0.15 |      0.18 |         0.22 |
|   1.2 |       6 |   0.60 |          0.00 |      0.46 |         0.62 |
|   1.2 |       6 |   0.60 |          0.15 |      0.44 |         0.58 |
|   1.2 |      12 |   0.25 |          0.00 |      0.38 |         0.52 |
|   1.2 |      12 |   0.25 |          0.15 |      0.42 |         0.46 |
|   1.2 |      12 |   0.60 |          0.00 |      0.82 |         0.88 |
|   1.2 |      12 |   0.60 |          0.15 |      0.86 |         0.92 |

Probability the check fires on the covariate that actually drifts.

Per cell these rates have a Monte Carlo standard error of about 0.065 at
50 replicates, so the largest of eight of them is not an upper bound on
anything. Pooled across strata, where the standard error is near 0.01,
the picture is this.

| rule         | true contrast | arm        |   n |  rate | 95% CI           |
|:-------------|--------------:|:-----------|----:|------:|:-----------------|
| 95% interval |          0.00 | registered | 400 | 0.092 | \[0.068, 0.125\] |
| 95% interval |          0.15 | amendment  | 400 | 0.082 | \[0.059, 0.114\] |
| 95% interval |          0.30 | registered | 400 | 0.112 | \[0.085, 0.147\] |
| 95% interval |          0.60 | registered | 400 | 0.235 | \[0.196, 0.279\] |
| 95% interval |          1.20 | registered | 400 | 0.540 | \[0.491, 0.588\] |
| DIC \< -5    |          0.00 | registered | 400 | 0.013 | \[0.005, 0.029\] |
| DIC \< -5    |          0.15 | amendment  | 400 | 0.020 | \[0.010, 0.039\] |
| DIC \< -5    |          0.30 | registered | 400 | 0.045 | \[0.029, 0.070\] |
| DIC \< -5    |          0.60 | registered | 400 | 0.148 | \[0.116, 0.186\] |
| DIC \< -5    |          1.20 | registered | 400 | 0.452 | \[0.404, 0.501\] |

Detection on the drifting covariate, pooled across all eight design
strata, 400 replicates per row. The contrast 0.15 is the amendment arm
and is excluded from every registered claim; 0 is the global null.

At a true contrast of 0.30 the transported estimate is wrong by 0.059
absolute risk at displacement 1, twice the material threshold. The DIC
rule fires in 0.045 \[0.029, 0.070\] of analyses, against 0.013 \[0.005,
0.029\] when the assumption holds exactly. At 0.60 it reaches 0.147 and
only at 1.20, eight times the contrast that would make the estimate
materially wrong and a stress test rather than a plausible violation,
does it reach 0.453.

At the amendment level of 0.15 the rate is 0.020 \[0.010, 0.039\], whose
interval overlaps the null’s: at a violation sitting just under the
threshold of mattering, the check does not reliably distinguish it from
no violation at all.

The 95% interval rule is uniformly more sensitive and correspondingly
less specific. Per-stratum rates are below, and are reported for
description rather than for comparison.

<div id="fig-power">

![](figures/power.png)

Figure 2: Probability the check fires on the covariate that actually
drifts, by rule. The dotted line is 0.80. Every panel is a design
stratum; the horizontal axis is the true difference between the two
treatments’ effect modifiers.

</div>

| rule         | type I error | 95% CI           |
|:-------------|-------------:|:-----------------|
| DIC \< -10   |       0.0000 | \[0.000, 0.010\] |
| DIC \< -2    |       0.0550 | \[0.037, 0.082\] |
| DIC \< -5    |       0.0125 | \[0.005, 0.029\] |
| margin       |       0.2350 | \[0.196, 0.279\] |
| 95% interval |       0.0925 | \[0.068, 0.125\] |

Type I error under the global null, where every interaction is shared
exactly. 400 replicates per rule.

The 95% interval rule runs at about twice its nominal rate. The margin
rule fires in nearly a quarter of replicates when the true difference is
exactly zero, for the reason given in
<a href="#sec-affirm" class="quarto-xref">Section 3.3</a>.

Every rate above depends on where the cut is put. The registered design
also scores the two continuous statistics threshold-free, as classifiers
by AUROC ([6](#ref-hanley1982)), which asks whether the check ranks
analyses correctly whatever cut an analyst chooses. **This analysis was
prespecified, computed from the first run onward, and then omitted from
the first two drafts. Three reviewers asked for it. Its absence was an
undisclosed departure and this is the correction.**

| true contrast | AUROC | 95% CI           |   n |
|--------------:|------:|:-----------------|----:|
|           0.3 | 0.557 | \[0.517, 0.596\] | 800 |
|           0.6 | 0.681 | \[0.644, 0.718\] | 800 |
|           1.2 | 0.843 | \[0.815, 0.870\] | 800 |

Ranking networks with a violation above networks without one, by
$-\Delta$DIC, each violation level against the global null. 0.5 is
chance.

Against the check’s own hypothesis, $-\Delta$DIC separates a violation
from none with an AUROC of 0.557 \[0.517, 0.596\] at twice the material
violation, rising to 0.843 only at the eightfold stress test. The
directional posterior probability is weaker throughout, reaching just
0.507 \[0.467, 0.547\] at the same violation, an interval that contains
chance.

| target displacement | AUROC | 95% CI           |
|--------------------:|------:|:-----------------|
|                 0.0 | 0.538 | \[0.509, 0.566\] |
|                 0.5 | 0.601 | \[0.572, 0.629\] |
|                 1.0 | 0.666 | \[0.636, 0.696\] |
|                 1.5 | 0.669 | \[0.637, 0.702\] |

Ranking analyses by whether the transported estimate is materially
wrong, by $-\Delta$DIC. Every replicate of the 32 registered cells
counts equally; this is not the deployment-weighted mixture the verdict
uses.

Against the outcome that actually matters, a materially wrong
transported estimate, the same statistic reaches 0.666 at
displacement 1. **No threshold recovers a ranking the statistic does not
contain**, so the weak detection rates above are a property of the
statistic and not an artifact of the cuts chosen for it. This is the
strongest form of the paper’s central claim, and it is the one that does
not depend on any rule of ours.

Intervals are Hanley and McNeil’s ([6](#ref-hanley1982)). Ties are
broken at run boundaries on the sorted score, which is the exact rather
than the approximate treatment; the implementation is checked against
the brute-force definition every time the analysis runs, and agrees to
2.6e-15.

### The check cannot give an all-clear

A committee reading a check wants to know whether the assumption is
safe, which is an equivalence statement: is the difference between the
two treatments’ modifiers small enough to ignore? Computed from the same
posteriors, $P(|\gamma_A[x_1] - \gamma_C[x_1]| \leq \varepsilon) > 0.95$
fired in **0 of 3,200** covariate-checks across the registered design.
Zero. Including every one of the 2,000 in which the two treatments’
modifiers were identical by construction.

**Neither of these rules is prior-free, and the direction of the bias
must be stated.** Under independent `normal(0, 2.5)` priors on the two
treatment-specific coefficients, their contrast has prior standard
deviation 3.536. The prior alone therefore places 0.965 of the contrast
beyond $\varepsilon$, which is **above the 0.95 threshold at which the
margin rule fires**, and leaves only 0.035 inside the equivalence
region. A reviewer identified this and it is correct: the margin rule
fires under the prior before any data are seen, and the equivalence rule
starts from almost nowhere.

So the right statement is not that the procedure cannot affirm the
assumption. It is a statement about precision, and it is sharper. For
the equivalence rule to fire, the posterior standard deviation of the
contrast must fall below roughly $\varepsilon / 1.96 = 0.0781$. The
tightest stratum in this design achieves 0.300, a factor of 3.8 short,
and the loosest 1.64. **No network in this design came within a factor
of three of the precision required to affirm the assumption at the
margin that matters.**

Three things about that calculation, since round-two review questioned
all three and the answers differ.

The $\varepsilon / 1.96$ condition **is** a normal approximation, and
this paper elsewhere says weakly identified posteriors are not Gaussian,
so it is offered as an interpretive gloss and not as a proof. It is not
what produces the count of zero. That count is measured directly:
$P(|\gamma_A[x_1] - \gamma_C[x_1]| \leq \varepsilon)$ is evaluated as
the proportion of posterior draws satisfying the inequality, so it
assumes no shape at all.

The contrast’s standard deviation likewise **does** account for the
covariance between the two treatment-specific coefficients, because it
is not assembled from two marginal standard deviations: the contrast is
formed draw by draw from the joint posterior,
$z^{(m)} = \gamma_A^{(m)}[x_1] - \gamma_C^{(m)}[x_1]$, and its standard
deviation is taken over those draws.

What cannot be defended is the claim an earlier draft made that the
count would remain zero “under any prior that does not itself supply the
answer”. A prior placed directly on the contrast, rather than
independently on each coefficient, would change the arithmetic above,
and this study did not run one. The count of zero is a result about
these networks under these priors.

The complementary reading runs backwards for the same reason:
$P(|\cdot| > \varepsilon) > 0.95$ fires in 0.48 of replicates at the
thinnest cell under the global null and 0.08 at the richest, firing
*more often where there is less information*. Both readings are governed
by the width of the posterior rather than its location, and in this
design that width is set as much by the prior as by the network.

### What a pass licenses, and why the registered gate was unreachable

| displacement | P(material error \| passed) | the same for an oracle model | excess attributable to the check |
|---:|---:|---:|---:|
| 0.0 | 0.427 | 0.446 | -0.019 |
| 0.5 | 0.559 | 0.573 | -0.014 |
| 1.0 | 0.675 | 0.639 | 0.036 |
| 1.5 | 0.723 | 0.662 | 0.061 |

The registered gate, and the same quantity for a model that knows which
specification is true, on the same replicates.

**The registered verdict fails.** The upper 95% bound on
$P(\text{material error} \mid \text{the
check did not fire})$ at displacement 1.0, deployment-weighted, is 0.697
against a threshold of 0.1, on a point estimate of 0.675 with a standard
error of 0.0134 over 1307 passing replicates from 32 cells. Scored
against systematic error alone rather than realized error the estimate
is 0.563. Both fail, by a factor of about seven.

Two notes on that bound, both from round-two review. First, an earlier
draft reported 0.777 here, which is the Wilson bound on the
**unweighted** risk of 0.758 printed beside the **weighted** point
estimate; a reviewer observed that the published bound could not be
reconstructed from the stated sample size and was right. The bound is
now computed for the quantity the registered rule names. The verdict is
unchanged, and would be unchanged under any interval this design could
produce. Second, the systematic-error indicator is a deterministic
function of a cell’s drift and the displacement, so it does not vary
within a cell and its sampling variance is exactly zero; its bound
equals its point estimate by construction rather than through unusual
precision, and all remaining uncertainty sits in deployment weights that
are declared rather than estimated.

It fails for a reason that is mostly not the check’s doing. An oracle
that knows which specification is correct, fitted to the same
replicates, is materially wrong 0.639 of the time. The check’s excess
over that oracle is **0.036**, and at displacements 0 and 0.5 the excess
is negative. A perfect check would have failed this gate. The threshold
was unreachable by any procedure, because at a material threshold of
0.03 absolute risk the estimation error of a six-study network alone
exceeds it in 0.46 to 0.58 of replicates when the assumption is exactly
true.

That is a finding about this program’s habit of writing verdict rules,
not only about the check: a threshold on total error charges a
diagnostic for noise it was never built to see. The oracle comparison is
the fix, and it was added after a pre-run critique predicted the failure
and computed the noise floor to within the interval the run later
measured.

### The mechanism: the check is blind to what determines the harm

| displacement | P(material error \| passed) | noise floor | excess over the floor | systematic only |
|---:|---:|---:|---:|---:|
| 0.0 | 0.427 | 0.427 | 0.000 | 0.000 |
| 0.5 | 0.559 | 0.427 | 0.132 | 0.563 |
| 1.0 | 0.675 | 0.427 | 0.248 | 0.563 |
| 1.5 | 0.723 | 0.427 | 0.296 | 0.563 |

The check’s output is identical at every displacement by construction;
the harm is not.

The check reads the fitted network and nothing else, so its output
cannot depend on the population an analyst transports to. The run
confirms this as a bookkeeping identity: the pass rate is 0.816875 at
every displacement, with a maximum absolute deviation of 0.

Over the same fits, the probability that a passed analysis is materially
wrong rises from 0.427 to 0.723, an excess over the noise floor of
0.296, against a registered threshold of 0.20. Against systematic error
the rise is from 0 to 0.563.

<div id="fig-decoupling">

![](figures/decoupling.png)

Figure 3: The check’s pass rate is flat by construction; what a pass is
worth is not.

</div>

**Registered mechanism claim M1 is confirmed**, with one qualification a
reviewer was right to press. The first half is an algebraic identity
rather than an empirical finding: the same fits are reused at every
displacement, so the pass rate *must* be identical, and the run verifies
the bookkeeping rather than discovering anything. The second half is
empirical. And the strong form of the conclusion is too strong: what a
pass is worth depends on the target displacement **and** on the drift,
and the check is blind to both. Displacement is the one this section
isolates, because it can be varied while holding the fitted network
exactly fixed.

### The three readings are not three procedures

The published recipe says to compare posteriors *and* model fit, which
reads as two independent opinions. They disagree in 0.107 of the 3200
covariate-checks, drawn from 1600 replicates. The registered threshold
was 0.10 and the point estimate exceeds it, but the 95% interval is
\[0.096, 0.118\], whose lower bound falls below 0.10, so **M4 is
reported as not clearly met**. A first draft called it confirmed; a
reviewer pointed out that a point estimate 0.007 above a threshold with
a standard error of 0.006 does not clear it. A second reviewer then
noted that the two checks inside a replicate share a fitted network, so
a binomial interval on 3200 independent observations is
anti-conservative; the interval above is clustered by replicate, which
widens the standard error from 0.0055 to 0.0057. The verdict is the same
either way.

The substantive point survives the arithmetic, and it is one-sided: the
DIC rule fires without the interval rule in 0.0006 of checks, and the
interval rule fires without DIC in 0.106. The DIC rule is very nearly a
strict subset of the interval rule, not a second opinion on the same
question.

Under the global null the two rules differ in type I error by 0.080 on
the drifting covariate, the pooling the table above displays, and by
0.087 pooling both covariates. Both exceed the registered 0.05, so **M3
is confirmed on either pooling.** Earlier drafts quoted the second
figure beside a table showing the first without saying which was which,
and two reviewers reported the apparent contradiction in successive
rounds.

When a violation is present the check also points at the wrong
covariate. At drift 1.20 the interval rule fires on the covariate that
is shared exactly in 0.388 of replicates. A fire is not a diagnosis.

### Following the check still beats the alternatives

| strategy | displacement | RMSE | P(material error) | decision reversal |
|:---|---:|---:|---:|---:|
| check, then relax what fired | 0 | 0.0426 | 0.433 | 0.450 |
| impose the restriction | 0 | 0.0422 | 0.438 | 0.453 |
| relax everything | 0 | 0.0514 | 0.497 | 0.465 |
| check, then relax what fired | 1 | 0.0928 | 0.687 | 0.385 |
| impose the restriction | 1 | 0.0995 | 0.700 | 0.452 |
| relax everything | 1 | 0.1218 | 0.801 | 0.357 |

Scoring the target estimand for all four fitted models, and defining
check-then-relax as relaxing exactly the covariates that fired, the
check earns its keep **on some losses and not uniformly**. It has the
lowest material-error rate at every displacement. On squared error it is
best at displacements 0.5, 1.0 and 1.5 but **not at 0**, where imposing
the restriction is marginally better (0.0422 against 0.0426). An earlier
draft claimed the lowest error “at every displacement”; a reviewer found
the exception in this paper’s own table. It is reported here as the
ordering it is: loss-dependent, and reversed at the one displacement
where there is nothing to transport.

| displacement | comparison | abs. error diff | 95% CI | sq. error diff | 95% CI |
|---:|:---|---:|:---|---:|:---|
| 0.0 | check_then_relax minus always_common | -0.00005 | \[-0.00069, 0.00059\] | 3.08e-05 | \[-0.000112, 0.000174\] |
| 0.0 | check_then_relax minus always_relaxed | -0.00517 | \[-0.00676, -0.00358\] | -8.26e-04 | \[-0.001200, -0.000452\] |
| 0.5 | check_then_relax minus always_common | -0.00187 | \[-0.00299, -0.00074\] | -2.96e-04 | \[-0.000522, -0.000071\] |
| 0.5 | check_then_relax minus always_relaxed | -0.01444 | \[-0.01694, -0.01194\] | -2.15e-03 | \[-0.002660, -0.001647\] |
| 1.0 | check_then_relax minus always_common | -0.00505 | \[-0.00686, -0.00323\] | -1.29e-03 | \[-0.001869, -0.000707\] |
| 1.0 | check_then_relax minus always_relaxed | -0.02882 | \[-0.03279, -0.02486\] | -6.21e-03 | \[-0.007221, -0.005206\] |
| 1.5 | check_then_relax minus always_common | -0.00877 | \[-0.01119, -0.00636\] | -3.18e-03 | \[-0.004194, -0.002168\] |
| 1.5 | check_then_relax minus always_relaxed | -0.04073 | \[-0.04597, -0.03548\] | -1.12e-02 | \[-0.012920, -0.009422\] |

Paired differences at every displacement, on both losses,
deployment-weighted to match the primary analysis. The three strategies
are scored on the same replicate, so the comparison is paired and its
interval is far tighter than a difference of two independent rates.
Negative favours check-then-relax.

The ordering is not uniform, and saying exactly where it holds is the
point.

**Against relaxing everything, check-then-relax wins at every
displacement**, by 0.0288 \[0.0249, 0.0328\] in weighted mean absolute
error at displacement 1.0, on both losses, with every interval excluding
zero.

**Against imposing the restriction it wins at displacements 0.5, 1.0 and
1.5 and is indistinguishable at 0.** At displacement 1.0 the advantage
is 0.0050 \[0.0032, 0.0069\]. At displacement 0 it is 0.00005
\[-0.00059, 0.00069\], an interval containing zero, and on squared error
the point estimate there favours the restricted model. That is the
expected result: at displacement 0 there is nothing to transport, so
relaxing can only add variance.

An earlier draft claimed the lowest error “at every displacement”. A
reviewer found the exception in this paper’s own RMSE column. Checking
it exposed a second problem the reviewers did not see: the paired
differences were computed **unweighted** while the RMSE table beside
them was deployment-weighted, and the two disagreed in sign at
displacement 0 for that reason alone. Both are now weighted, so the
table and the paired test answer the same question.

Restricting to the 1479 replicates in which **all four** fits met their
convergence criteria changes this hardly at all (0.0174 and 0.0116),
which answers the obvious objection that retaining badly-behaved relaxed
fits is what makes relaxation look poor. It is not.

Restricting instead to the sixteen cells with no treatment-effect
heterogeneity, where the estimand is unambiguous, gives 0.0178 and
0.0069 at displacement 1.0. The ordering does not depend on the cells
whose estimand a reviewer correctly questioned.

The margin is small, and the ranking of the alternatives is the
interesting part: **relaxing everything is worse than imposing the
restriction** on both RMSE and material error, because the relaxed model
spends precision it does not have. It is better only on decision
reversal (0.357 against 0.452), which is what one would expect of an
unbiased but noisy estimator against a biased but precise one.

<div id="fig-strategies">

![](figures/strategies.png)

Figure 4: RMSE of the transported C-versus-A risk difference under the
three strategies.

</div>

That the fully relaxed model is not simply available is visible in the
sampler: it fails its convergence criteria in 0.068 of replicates
overall and up to 0.24 in the worst cell, with $\hat R$ reaching 1.89
and effective sample size falling to 3.4.

Those two figures are the worst reached by the fully relaxed model, and
earlier drafts presented them as the worst in the study. They are not.
Across all four models the worst $\hat R$ is 5.13 and the worst
effective sample size is 1.03, both in the singly-relaxed split_x2 fit.
At least one fit misses its criteria in 0.076 of replicates. Quoting the
better of the two understated the problem, and this correction was found
while checking a reviewer’s arithmetic rather than reported by one. The
shared-interaction model never once failed. Those replicates are
retained and reported; excluding them would have removed exactly the
cases where relaxation is hardest.

### Nothing in the panel beats scrutinizing everything

The panel is compared on net benefit ([7](#ref-vickers2006)). The action
is to distrust the adjusted estimate and commission individual patient
data; the event the action is meant to catch is a **material error**,
defined throughout this paper as a realized C-versus-A marginal risk
difference wrong by more than 0.03 on the absolute scale. It is not a
decision reversal: no external decision threshold is imposed anywhere in
this study, so the event is defined by the size of the error and not by
which side of a boundary it lands on. For a rule that fires on a
fraction of analyses, net benefit at threshold $t$ is

$$\text{NB}(t) \;=\; \Pr(\text{fires},\ \text{material}) \;-\; \Pr(\text{fires},\ \text{not material}) \cdot \frac{t}{1 - t},$$

with both probabilities taken over the deployment mixture at
displacement 1.0, so $t$ is the probability of material error at which
commissioning the data is worth its cost. Distrusting every analysis is
$\pi - (1 - \pi)\,t / (1 - t)$ for prevalence $\pi$, and distrusting
none is zero by construction. Every rule in the panel is a strict
inequality on a continuous statistic ($\Delta\text{DIC} < -5$, and so
on), so the firing indicator is exact and no tie-breaking rule is
needed; the one place ties are handled explicitly is the weighted AUROC
of <a href="#sec-resolution" class="quarto-xref">Section 3.1</a>, where
they are broken at run boundaries on the sorted score.

The prevalence entering the curve is the same one the verdict reports:
material error is present in 0.675 of passing analyses at displacement
1.0. Sweeping $t$ from 0.05 to 0.60, distrusting every analysis has
higher net benefit than every rule in the panel at every threshold
examined. At a threshold of 0.20 the values are 0.625 for distrusting
everything against 0.098 for the DIC rule and 0.195 for the interval
rule.

<div id="fig-dca">

![](figures/decision-curve.png)

Figure 5: Decision curve. The action is to distrust the adjusted
estimate and commission individual data.

</div>

**This result and the previous one point in opposite directions, and the
reconciliation is the point.** Section
<a href="#sec-strategies" class="quarto-xref">Section 3.7</a> says
following the check beats the alternatives; this section says
distrusting everything beats following the check. Both are true because
they score different things. The strategy comparison scores **estimation
error**, where the check has something to contribute and contributes a
little. The decision curve scores **whether to trust an analysis at
all**, and the event it must predict is realized material error, most of
which is ordinary sampling noise: at zero drift, with the assumption
exactly true, the shared-interaction fit is already materially wrong in
about half of six-study replicates. No covariate check can predict that,
because it is not a covariate phenomenon. A reviewer put it exactly
right in round one: with a prevalence this high, treat-all dominates any
rule built on the check almost regardless of what the check does, so
this curve restates the noise-floor finding rather than measuring the
check.

Read together: on the error of the estimate the check earns a small
keep, and on the question of whether a committee should trust a
six-study population-adjusted analysis at all, the answer does not
depend on the check. That second statement is about network size, not
about this procedure.

The action’s consequences are not modeled. Commissioning individual
patient data is treated as an act with a cost expressible as a
probability threshold and a benefit of avoiding a material error; its
delay, its chance of being refused, and its chance of not resolving the
question are all set aside. So “nothing in the panel beats scrutinizing
everything” is a property of this coding of the action and this
deployment mixture, and is not a general recommendation to commission
data.

### The verdict does not transport across the one axis that matters

| held-out factor | level | observed | predicted | absolute error |
|:----------------|------:|---------:|----------:|---------------:|
| drift           |  0.00 |    0.422 |     0.891 |          0.469 |
| drift           |  0.30 |    0.767 |     0.749 |          0.018 |
| drift           |  0.60 |    0.983 |     0.737 |          0.246 |
| drift           |  1.20 |    1.000 |     0.828 |          0.172 |
| n_studies       |  6.00 |    0.812 |     0.755 |          0.058 |
| n_studies       | 12.00 |    0.774 |     0.827 |          0.053 |
| spread          |  0.25 |    0.784 |     0.760 |          0.024 |
| spread          |  0.60 |    0.802 |     0.828 |          0.025 |
| tau_re          |  0.00 |    0.794 |     0.780 |          0.014 |
| tau_re          |  0.15 |    0.792 |     0.806 |          0.013 |

A one-term mapping from the check statistic to the probability of
material error, fitted with one level of one factor held out and
evaluated on that level.

A mapping from $\Delta\mathrm{DIC}$ to the probability of material error
transports across network size, covariate spread and treatment-effect
heterogeneity, with absolute errors of 0.013 to 0.058. It does not
transport across drift, where the error reaches 0.469. The statistic’s
meaning depends on how badly the assumption is violated, which is the
one thing the analyst is using it to find out.

The protocol also prespecified a target-aware mapping, and its results
belong here. **Two earlier drafts drew the wrong conclusion from it, in
two different ways, and the third reading is the one the numbers
support.**

Adding the displacement as a second predictor changes the held-out
absolute error from 0.086 to 0.086 on average, which is no change at
all. The first draft explained this by saying displacement cannot help
because it does not enter the check statistic. That is a logical error:
a predictor can improve a prediction without changing another predictor.
The second draft said that all four displacements appear in training
within every fold, so displacement carries no information the mapping
did not have. A reviewer answered that correctly: being estimable is not
the same as being redundant, and since the check statistic is identical
across the four target rows while the risk of material error changes
strongly across them, displacement must carry information the statistic
does not.

The reviewer is right, and the explanation is a property of the
registered metric. Absolute error between *mean* predicted probability
and *mean* observed rate is calibration in the large, and a logistic
model fitted by maximum likelihood is calibrated in the large on its
training set by construction. A predictor whose distribution is
identical in training and test therefore cannot move it. The metric is
nearly blind to what was being asked.

Discrimination is not, and it answers the question:

| held-out factor | level | AUROC, statistic only | AUROC, plus displacement |
|:----------------|------:|----------------------:|-------------------------:|
| drift           |  0.00 |                 0.516 |                    0.502 |
| drift           |  0.30 |                 0.495 |                    0.753 |
| drift           |  0.60 |                 0.483 |                    0.825 |
| drift           |  1.20 |                 0.498 |                    0.801 |
| n_studies       |  6.00 |                 0.558 |                    0.686 |
| n_studies       | 12.00 |                 0.630 |                    0.747 |
| spread          |  0.25 |                 0.593 |                    0.719 |
| spread          |  0.60 |                 0.598 |                    0.710 |
| tau_re          |  0.00 |                 0.593 |                    0.716 |
| tau_re          |  0.15 |                 0.596 |                    0.715 |

Held-out discrimination for material error, from the check statistic
alone and from the check statistic plus the target displacement.

Across the ten folds the check statistic alone discriminates material
error at 0.48 to 0.63, which is close to chance. Adding the displacement
raises it to 0.50 to 0.83 over the same folds, and to 0.69 to 0.75 over
the six that hold out a design factor rather than a drift level. The
single fold where displacement does not help is the one holding out
drift 0, where the test set contains no violation at all and material
error is pure estimation noise that nothing can predict.

**Knowing the target is worth far more than knowing the check
statistic**, and the check cannot tell an analyst the target. That is a
sharper version of this section’s claim, not a weaker one, and the paper
reached it only because a reviewer refused two wrong explanations of a
null result.

What remains true, and is what the registered metric does measure, is
that the mapping transports across network size, spread and
heterogeneity and fails across drift.

### The decision boundary

| studies | spread | heterogeneity | DIC \< -5 | 95% interval | margin | affirms sharing |
|--------:|-------:|--------------:|----------:|-------------:|-------:|----------------:|
|       6 |   0.25 |          0.00 |      0.02 |         0.00 |   0.54 |               0 |
|       6 |   0.25 |          0.15 |      0.04 |         0.08 |   0.42 |               0 |
|       6 |   0.60 |          0.00 |      0.00 |         0.04 |   0.12 |               0 |
|       6 |   0.60 |          0.15 |      0.02 |         0.10 |   0.22 |               0 |
|      12 |   0.25 |          0.00 |      0.02 |         0.14 |   0.28 |               0 |
|      12 |   0.25 |          0.15 |      0.02 |         0.18 |   0.36 |               0 |
|      12 |   0.60 |          0.00 |      0.00 |         0.04 |   0.02 |               0 |
|      12 |   0.60 |          0.15 |      0.04 |         0.08 |   0.08 |               0 |

The amendment arm: drift 0.15, exactly one epsilon, the violation at
which the transported estimate becomes materially wrong at displacement
1.

The registered grid ran 0, 1.96, 3.92 and 7.84 multiples of
$\varepsilon$, so it measured the floor and the ceiling and nothing in
between. A second pre-run critique caught this while the run was in
progress, and eight cells at exactly one $\varepsilon$ were added by
dated amendment.

**Correction, made under review.** These cells sit just *below* the
boundary, not on it. At drift 0.15 the transported C-versus-A risk
difference is wrong by 0.0294 at displacement 1, against a material
threshold of 0.03, so by this study’s own definition the violation is
**not** material; the contrast that lands exactly on the threshold is
0.1531. A first draft of this section described drift 0.15 as the exact
boundary and as the violation that “precisely changes a decision”, and
that was false. What these cells show is the check’s behaviour at a
violation just short of mattering. The shared-interaction fit duly
delivers that error, with a bias of 0.0207 to 0.0311 and a
material-error rate of 0.48 to 0.64.

Pooled over the eight strata the DIC rule fires in **0.020** \[0.010,
0.039\] of those analyses and the interval rule in 0.083, against 0.013
and 0.092 under the global null. The intervals overlap. The registered
grid could not have produced this comparison, and it is the one a reader
needs: just below the size of violation that would change a decision,
the check does not distinguish the violation from its absence.

### Checks on the machinery

`multinma` reconstructs the joint covariate distribution of the
aggregate studies from a copula whose correlation matrix is estimated
from the one individual-level study. That estimate is off by a mean of
0.035 on a true correlation of 0.25, so it is not a material source of
error here.

Every DIC difference here is computed from a likelihood that is a
numerical integral over 64 points. Refitting the same simulated networks
at 256 points moved that difference by a median of 0.33 and at most
2.08, and **changed the DIC-5 verdict in 8.3% of replicates** and the
interval verdict in 4.2%. So a part of what the check reports is
quadrature, not evidence. This rate is of the same order as the signal
it sits beside: the DIC rule’s detection rate rises by about three
percentage points between no violation and one twice the size that
matters, and the numerical grid alone moves the verdict in 8.3% of
replicates. A first draft called this small; it is not. The check was
run on 24 simulated networks drawn from two cells, the largest network
at the widest covariate spread with and without drift, which is the
configuration where quadrature is most stressed; 256 points is not
demonstrated to be a converged reference, so this is a lower bound on
the instability rather than a measurement of it.

### An independent reviewer’s registered predictions

The second pre-run critique registered a table of predicted results so
they could be scored. Its prediction for the headline was 0.72 to 0.75
on the realized scale against a measured 0.758 unweighted, and 0.011 for
the DIC rule’s type I error against a measured 0.0125. Both hold. It
predicted M3 would be refuted, on the assumption that the 95% interval
rule sits at its nominal 0.05; the rule actually runs at 0.092, so M3 is
confirmed instead. Its per-cell power predictions are accurate at the
low end and optimistic at the high end.

## Discussion

The shared effect modifier assumption is what allows an interaction
estimated where there are individual data to be applied where there are
only summaries. On networks of this size and composition, the published
check on it does not have the resolution to test it. That is not a
defect of the procedure so much as a property of the evidence: the
posterior standard deviation of the difference between two treatments’
effect modifiers runs 0.30 to 1.64, which is **2.0 to 10.7 times** the
difference that would change a decision. That statement is drawn from
the measured posterior standard deviations, not from the derived
data-only quantity that an earlier draft used here and that
<a href="#sec-resolution" class="quarto-xref">Section 3.1</a> demotes to
an order of magnitude.

The threshold-free version is the one that depends on nothing we chose:
at a violation twice the size that matters, $-\Delta\mathrm{DIC}$ ranks
a violated network above an intact one with an AUROC of 0.557 \[0.517,
0.596\].

Three consequences follow, and none of them is a threshold problem.

**Silence is not reassurance.** The check never once affirmed that the
assumption holds, in 3,200 opportunities, including every replicate
where it held exactly. A procedure that can only fail to object should
not be reported in a way that reads as confirmation, and the sentence
“we assessed the shared effect modifier assumption and found no evidence
against it” carries almost no information about whether the assumption
holds.

**A pass is worth what the target makes it worth.** The check’s output
is invariant to the population being transported to, exactly and by
construction, while the damage from an undetected violation is
proportional to how far that population sits from the network. The same
pass licenses very different things in the two cases, and nothing in the
check distinguishes them.

**Use it anyway, but not as a gate.** Following the check and relaxing
exactly what it fires on beats relaxing everything at every displacement
on both losses, and beats imposing the restriction at every displacement
except zero, where the two are indistinguishable and there is nothing to
transport. It is worth running. What it is not worth is treating as a
test that the assumption has survived. This is a comparison of three
strategies, and the strategy an analyst would most want, partial pooling
of the interactions, is not among them.

The practical recommendation is to report the *width* alongside the
verdict. The posterior standard deviation of the interaction contrast,
compared against the contrast that would move the decision, says in one
number whether the check had any chance of firing. In the thinnest
networks here that ratio is about 11 to one, and a reader who saw it
would know to discount the pass entirely.

## What this does not settle

**What is being measured is our formalization, not a uniquely defined
published rule.** “Compare the posteriors and the model fit” describes
an exploratory practice. The DIC cuts at 2, 5 and 10, the interval rule,
the margin rule and the equivalence rule are five decision rules we
constructed that the description admits, and the equivalence rule in
particular was never part of the original proposal. Failure of a rule we
invented is not evidence that the authors of the practice claimed
something it does not deliver. What the study establishes is that no
rule in this family, on these networks, separates violations that matter
from their absence.

**A departure from the registered eligibility rule.** The protocol said
a replicate would be excluded if any of its four fits had $\hat R$ above
1.05, bulk ESS below 100, or divergences. The first cell of the run
showed that this rule excludes selectively: all six exclusions were
diagnostic failures and five involved a split model, while the shared
model never failed once, so the rule removes exactly the replicates
where relaxation is hardest. The rule was amended before the reported
run to record the diagnostics rather than exclude on them, which is a
departure from what was registered and is disclosed as one. The
consequences are reported: convergence failure rates by cell and model,
and every primary comparison repeated on the subset where all four fits
converged.

**The estimand under treatment-effect heterogeneity.** Where
$\tau_{re} = 0.15$ the truth is defined at $\delta_{jk} = 0$, which is a
superpopulation quantity, while the fixed-effect fits estimate a
precision-weighted function of the realized studies; and on the risk
scale, integrating the inverse link over the random-effect distribution
is not the same as setting the random effect to zero. Part of the error
attributed to the check in those cells is that mismatch. The oracle
comparison does not remove it, because the oracle is also a fixed-effect
model there, so it is an interaction-specification oracle and not a
fully correct one. Results restricted to the sixteen $\tau_{re} = 0$
cells are reported for the primary gate
(<a href="#sec-verdict" class="quarto-xref">Section 3.4</a>) and the
strategy comparison
(<a href="#sec-strategies" class="quarto-xref">Section 3.7</a>); an
earlier draft said they were separated “throughout” when they were
separated only in the per-cell tables, which a reviewer caught. Neither
conclusion changes. What is *not* repaired is the estimand itself: this
study does not define a single target under heterogeneity and estimate
that, and doing so would require refitting with a random-effects model.

The design is a best case in several specific ways that favour the
check, and the failures attributable to **those** idealizations are
conservative. The true marginal reference risk is supplied, covariate
moments in the target are known exactly, the ecological identification
route is unbiased, conditional constancy holds, and the violation is a
single linear drift in one covariate. No general lower-bound claim is
made, because three features of the design cut the other way and could
make the check look worse here than in practice: fitting fixed-effect
models to data generated with $\tau_{re} = 0.15$ is a second
specification error that inflates firing, 64-point quadrature adds
verdict noise that belongs to the implementation rather than to the
evidence, and a single individual-level study is an assumption about the
network, not necessarily a pessimistic one. An earlier draft asserted a
lower bound without these qualifications; a reviewer was right that the
general claim is not licensed.

The true marginal reference risk in the target is supplied to the
estimator, so no baseline-risk estimation error enters. Covariates are
normal with known target moments, and the ecological route by which the
aggregate-only treatment’s interaction is identified is unbiased by
construction: study covariate means are drawn independently of study
baselines and of the random treatment effects. Real networks will often
violate that, and the check’s failures there will arrive through a door
this study nailed shut. Conditional constancy holds. Only one covariate
drifts, and it drifts linearly.

There are two active treatments in one class and two covariates. A real
network has more of both, so multiplicity across covariates and the
selection involved in reading the widest of several pairwise differences
are not measured here; an earlier version of this design had three
treatments and was found, before running, to be reading a selected
contrast whose 95% interval is not a 95% interval.

The fits are fixed-effect while half the cells generate random treatment
effects of standard deviation 0.15. That is deliberate, and it is the
realistic case, but it means that in those cells the check is being read
under a second misspecification.

Only one individual-level study. What a second would buy is not
measured: that factor was dropped from the design to pay for
treatment-effect heterogeneity, which a pre-run critique identified as
the more consequential omission.

`class_interactions = "exchangeable"` is documented in `multinma`
0.9.1.9002 ([4](#ref-multinma_dev)) and raises “not yet supported”, so
the hierarchical middle ground between a shared interaction and fully
independent ones could not be fitted at all. That relaxation is the one
this catalog’s entry for IDN-05 proposed as the way forward, and the
entry’s claim that it ships in the package is wrong for this version and
is corrected alongside this study.

**This is the sharpest limit on the recommendation in
<a href="#sec-strategies" class="quarto-xref">Section 3.7</a>.** The
three strategies compared are impose, relax everything, and relax what
fired. A fourth, shrinking the treatment-specific interactions towards
each other rather than choosing between identical and independent, is
exactly what the problem entry proposes and is the one most likely to
beat all three, because the failure documented throughout this paper is
a precision failure and partial pooling is the standard answer to a
precision failure. **Package non-implementation is a reason for its
absence, not a justification**: we could have written the model. We did
not, and until someone does, “check, then relax what fired” is the best
of three options rather than a recommendation about what to do.

The material threshold of 0.03 absolute risk, the deployment weights,
and the choice of `normal(0, 2.5)` rather than the package default for
the regression prior are all declared judgments. The prior-sensitivity
arm shows the headline is insensitive to the last of them.

Fifty replicates per cell gives a per-cell standard error of about
0.065, which is why every result above is reported by stratum or pooled
and why no difference below about 0.13 within a single cell is claimed.

## References

<div id="refs" class="references csl-bib-body">

<div id="ref-phillippo2023" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">David M. Phillippo, Sofia Dias, A.
E. Ades, Mark Belger, Alan Brnabic, Daniel Saure, Alexander Schacht,
Yulan Yang, Nicky J. Welton. Validating the assumptions of population
adjustment: Application of multilevel network meta-regression to a
network of treatments for plaque psoriasis. Medical Decision Making.
2023;43(1):53–67.
doi:[10.1177/0272989X221117162](https://doi.org/10.1177/0272989X221117162)</span>

</div>

<div id="ref-multinma" class="csl-entry">

<span class="csl-left-margin">2.
</span><span class="csl-right-inline">David M. Phillippo. Multinma:
Bayesian network meta-analysis of individual and aggregate data. 2025.
doi:[10.5281/zenodo.3904454](https://doi.org/10.5281/zenodo.3904454)</span>

</div>

<div id="ref-phillippo2020mlnmr" class="csl-entry">

<span class="csl-left-margin">3.
</span><span class="csl-right-inline">David M. Phillippo, Sofia Dias, A.
E. Ades, Mark Belger, Alan Brnabic, Alexander Schacht, Daniel Saure,
Zbigniew Kadziola, Nicky J. Welton. Multilevel network meta-regression
for population-adjusted treatment comparisons. Journal of the Royal
Statistical Society Series A. 2020;183(3):1189–210.
doi:[10.1111/rssa.12579](https://doi.org/10.1111/rssa.12579)</span>

</div>

<div id="ref-multinma_dev" class="csl-entry">

<span class="csl-left-margin">4.
</span><span class="csl-right-inline">David M. Phillippo. Multinma:
Bayesian network meta-analysis of individual and aggregate data
\[Internet\]. 2026. Available from:
<https://github.com/dmphillippo/multinma/tree/8489bd83f388f3cb48062947cd9ab083218947dd></span>

</div>

<div id="ref-spiegelhalter2002" class="csl-entry">

<span class="csl-left-margin">5.
</span><span class="csl-right-inline">David J. Spiegelhalter, Nicola G.
Best, Bradley P. Carlin, Angelika van der Linde. Bayesian measures of
model complexity and fit. Journal of the Royal Statistical Society:
Series B. 2002;64(4):583–639.
doi:[10.1111/1467-9868.00353](https://doi.org/10.1111/1467-9868.00353)</span>

</div>

<div id="ref-hanley1982" class="csl-entry">

<span class="csl-left-margin">6.
</span><span class="csl-right-inline">James A. Hanley, Barbara J.
McNeil. The meaning and use of the area under a receiver operating
characteristic (ROC) curve. Radiology. 1982;143(1):29–36.
doi:[10.1148/radiology.143.1.7063747](https://doi.org/10.1148/radiology.143.1.7063747)</span>

</div>

<div id="ref-vickers2006" class="csl-entry">

<span class="csl-left-margin">7.
</span><span class="csl-right-inline">Andrew J. Vickers, Elena B. Elkin.
Decision curve analysis: A novel method for evaluating prediction
models. Medical Decision Making. 2006;26(6):565–74.
doi:[10.1177/0272989X06295361](https://doi.org/10.1177/0272989X06295361)</span>

</div>

</div>
