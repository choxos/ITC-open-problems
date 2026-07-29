# What the pre-run critique changed, and what the rebuilt mechanism already shows

Sol returned `unsound` with three fatal findings. Kimi returned `needs-revision` with five
serious ones. Each found something the other missed. Everything below was checked numerically
before it was accepted.

## The fatal finding, confirmed and fixed

**Sol.** The first design put the treatment on the Weibull shape and log-scale directly, so the
log hazard ratio contained the study baseline:

$$\log \mathrm{HR}_k(t,x) = \log(a_k/a_0) - a_k(d_k + \gamma_k x) - (a_k - a_0)\lambda_j + (a_k - a_0)\log t.$$

The treatment contrast would have varied across studies mechanically, manufacturing
treatment-by-study inconsistency that none of the fitted models allows.

Confirmed: the log hazard ratio moved from $-0.6955$ to $-0.9719$ across baselines of $\log 8$ to
$\log 18$, a spread of $-0.2764$, matching the predicted $(a_0-a_B)(\lambda_2-\lambda_1)$ to four
decimals. The first design's own calibration run never showed it, because that run held the
baseline fixed at $\log 12$.

Fixed by building the treatment arm as a **study-invariant multiplier** on the study's own
placebo hazard, $h_{jk}(t,x) = h_{j0}(t)\exp\{\beta_k + \kappa_k g(t) + \gamma_k x\}$. Verified
baseline-invariant to $4.4\times10^{-16}$, for both families.

The same change fixes a second finding of Sol's. In the old parameterization, changing the
non-proportionality also changed the effective size of the treatment effect and the
effect-modifier strength, because both were multiplied by the treatment-specific shape. In the
new one, $g(t_0)=0$, so the log hazard ratio at the reference time is $\beta_k + \gamma_k x$
whatever $\kappa_k$ is. Verified to $5.3\times10^{-16}$. **$\kappa$ now isolates
non-proportionality**, which is what the design claimed all along and did not deliver.

Gompertz is added, using $g(t)=(t-t_0)/t_0$ so the family is closed under the multiplier. The
quadrature truth agrees with 2,000,000 simulated draws for both families, to within the
simulation's own Monte Carlo error.

## The centrepiece was a theorem

**Kimi.** The first design's headline experiment was to hold the survival functions fixed, vary
only the censoring, and report that the transported hazard ratio moves. That is not an empirical
question. Struthers and Kalbfleisch (Biometrika 1986, doi:10.2307/2336212) and Xu and O'Quigley
(Biostatistics 2000, doi:10.1093/biostatistics/1.4.423) established that a misspecified
proportional-hazards fit converges to a least-false parameter that is a censoring- and
event-weighted average of the time-varying contrast. Both citations were checked against
CrossRef. The design's promise that "if it does not move, the entry's warning is weaker" was
false: non-movement is asymptotically impossible under non-proportional hazards.

Kimi's fix is adopted. The least-false parameter is now **computed**, by solving the limiting
score equation

$$\int f_1(t)\,dt = \int \frac{r_1(t)e^{\beta}}{r_0(t)+r_1(t)e^{\beta}}\,\bigl(f_0(t)+f_1(t)\bigr)\,dt,
\qquad r_k = \pi_k \bar S_k \bar G,\quad f_k = r_k \bar h_k,$$

with the marginal survival and hazard from the quadrature truth. Verified against a Cox fit on
400,000 per arm: worst disagreement 0.0031 on the log scale. Simulation is now reserved for
finite-sample behaviour around that limit, which is the part that is not already known.

## What the rebuilt mechanism shows, at zero compute cost

Sizing the effect exactly, rather than discovering its direction:

| $\kappa$ | true RMST diff at 18 | true marginal HR | reported HR across four censoring regimes | spread |
|---:|---:|---|---|---:|
| 0.00 | +1.155 | 0.73--0.82 | 0.769, 0.780, 0.792, 0.789 | 3.0% |
| 0.15 | +1.817 | 0.51--0.78 | 0.720, 0.703, 0.677, 0.694 | 6.4% |
| 0.30 | +2.359 | 0.32--0.84 | 0.687, 0.648, 0.593, 0.624 | 16.0% |

The $\kappa = 0$ row is the one worth having, and neither the first design nor either critique
anticipated it. That row is **exact conditional proportional hazards**, where Kimi predicted the
reported hazard ratio must not move. It moves by 3.0%. Decomposing why:

| $\gamma$ at $\kappa=0$ | marginal HR drift | reported HR spread |
|---:|---:|---:|
| 0.00 | 0.0% | **0.00%** |
| 0.15 | 2.7% | 0.76% |
| 0.30 | 11.6% | 3.01% |
| 0.50 | 35.8% | 7.93% |

and with $\gamma = 0.30$ but the covariate spread collapsed to zero, the movement is
**0.000%**.

So the censoring dependence of a transported hazard ratio has **two separate sources**, and they
are separable exactly:

1. **Non-proportional hazards**, the source the catalog entry names.
2. **Effect modification combined with covariate spread**, which moves the reported hazard ratio
   by up to 7.9% even when the conditional model is exactly proportional. Remove either
   ingredient and it is exactly zero.

The second is the mechanism the catalog entry's auditors described when they corrected the
source's framing, saying the instability "belongs to the marginal scale". Nobody appears to have
quantified it. It is now quantified, exactly, and it required no simulation at all.
