# Protocol: a quantitative bias analysis verdict scored as a classifier

**Target problem.** DIA-14. ADEMP reporting. Committed before the registered run.
Design: [`DESIGN.md`](DESIGN.md). Probes: [`results/probes.md`](results/probes.md).

## 1. Claim

A QBA that declares a decision "robust" across an assumed bias region is judged in
practice by recovering the truth when the bias is known. That checks the
arithmetic, not whether the verdict is honest. **Refuting sentence:** a well-built
region is wide enough that excluding the truth is rare, so oracle recovery plus a
conventional width rule is an adequate evaluation.

## 2. Corrections to DESIGN.md before the run

1. **The verdict's truth.** DESIGN.md section 3 defines it as whether the decision at
   the true bias matches the unadjusted decision. With $b^*$ the true bias, that is
   "flip" $= \operatorname{sign}(\hat\theta - b^*) \ne \operatorname{sign}(\hat\theta)$, a
   property of the data, not of the true effect's sign. Under it, a grid verdict of
   ROBUST with $b^*$ inside the region implies no flip, so **false reassurance is
   exactly 0 whenever the region contains the truth**, and at most the exclusion
   probability $q$ overall. Section 8's first null control is this identity.
2. **Three methods are one.** With one scalar bias the deterministic grid, the bounds
   over the region and comparison of the tipping point ($b = \hat\theta$) with the
   region give the same verdict. The comparison that can differ is grid against
   probabilistic QBA.
3. **Second null control.** With no bias the grid declares FRAGILE whenever
   $\hat\theta$ lies inside the region, so false fragility is
   $P(\hat\theta \in \text{region})$, not a nominal rate. It is reported, not tested.

## 3. Design

Unanchored MAIC of A (individual data, 300) against B (aggregate, 300), binary
outcome, measured $x$ balanced (source $N(0,1)$, target $N(0.5,1)$), unmeasured binary
$U$ with outcome log OR $\gamma_U \in \{0.5, 1\}$, prevalence 0.3 in the source and
$p_T \in \{0.3, 0.5, 0.7\}$ in the target, conditional B effect
$\delta \in \{-0.3, -0.1, 0.1\}$: 18 cells, $b^*$ from 0 to 0.372 by quadrature.
Decision: B better if the bias-adjusted estimate is below 0.

Elicited region $[b^* + e - w, b^* + e + w]$, $w \in \{0.05, 0.15, 0.3\}$. Exclusion
probability set directly: $e \sim N(0, s^2)$, $s = w/\Phi^{-1}(1 - q/2)$,
$q \in \{0, 0.1, 0.3\}$; error direction symmetric or toward zero bias
("understated"); plus a region centered at zero bias, $[-w, w]$.

Methods: no QBA (always robust); grid (equal to bounds and tipping point);
probabilistic QBA, $b \sim U(\text{region})$ plus sampling error, ROBUST if the adjusted
estimate keeps its sign with probability at least 0.95, exact by 400-point quadrature
and, to measure the QBA's own Monte Carlo error, by 1000 draws.

**2000 replicates per cell.** MCSE of a rate near 0.1 is 0.007 per cell.

## 4. Measures and decision

False reassurance: P(ROBUST | flip). False fragility: P(FRAGILE | no flip). Pooled over
the 12 cells with nonzero bias. Oracle recovery: coverage of $\hat\theta - b^* \pm 1.96\,\text{SE}$.

- **Exact checks.** Zero grid false reassurance among replicates whose region contains
  $b^*$ and at $q = 0$. Any nonzero count means a coding error.
- **Primary.** Both rates for grid and probabilistic QBA at $q = 0.1$, $w = 0.15$ by
  direction; whether either method dominates on both rates anywhere.
- **Refuting sentence fails** if oracle coverage is 0.93 to 0.97 in every cell while
  grid false reassurance exceeds 0.2 under the zero-centered region at some width.
- **Positive control.** Zero-centered region, $w = 0.05$: grid false reassurance
  above 0.3.

## 5. Departures from DESIGN.md

One scalar bias parameter, so dependence among bias parameters is not studied;
effect modification and overlap not varied; 2000 rather than 4000 replicates;
expected regret not computed.
