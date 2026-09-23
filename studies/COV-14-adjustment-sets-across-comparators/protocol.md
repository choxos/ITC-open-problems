# Protocol: covariate sets that differ across comparators, and the ranking read from them

**Target problem.** COV-14. ADEMP reporting. Committed before the registered run.
Design rationale: [`DESIGN.md`](DESIGN.md). Probe output, including the exact bias of
every cell: [`results/probes.md`](results/probes.md).

## 1. Claim and correction

One individual-data trial of A is compared, unanchored, with four aggregate
single-arm comparators that report different covariate subsets. Adjusting each
contrast for all it reports (maximal) minimizes each contrast's bias; adjusting all
contrasts for the covariates every comparator reports (intersection) makes the
omitted covariates common. DESIGN.md predicts an inversion: maximal wins on
per-contrast bias, intersection wins on ranking.

With independent normal covariates, MAIC on set $S_k$ has exact bias
$b_k = \sum_{m \notin S_k}(c_m + \beta_m)(\mu_{m,k} - \mu_{m,\text{IPD}})$, where $c_m$
is the prognostic coefficient and $\beta_m$ A's modification. **DESIGN.md wrote only
$\beta_m$.** In an unanchored comparison prognostic covariates bias the contrast too,
so its "zero modification" null control cannot hold and is replaced below. A ranking
depends on $b_k - b_j$; under the intersection this is
$\sum_{m \notin S}(c_m + \beta_m)(\mu_{m,k} - \mu_{m,j})$, small when comparator
populations are similar and not otherwise. The probe table confirms this without
sampling noise: with similar populations the intersection's bias spread across
contrasts is smaller in every cell; with dispersed populations it is larger in 8 of
18.

## 2. Design

Nine independent standard normal covariates, individual data on 300 patients of A,
four comparators of 200. Continuous outcome, residual SD 1,
$Y(t) = \sum_m c_m x_m + \tau_t\,(+\sum_m\beta_m x_m \text{ for A})$ with $c$ and
$\beta$ fixed shapes scaled by the strength factor. Comparator means
$0.4 + \text{spread}\cdot z_{mk}$, fixed per cell.

| factor | levels |
|---|---|
| reporting pattern | Fawsitt-like (covariate 1 missing from comparators 2 and 3, covariates 5 to 8 from 4); random (three missing per comparator, fixed per cell); adversarial (covariate 1, the strongest, missing from comparator 1, which has the largest effect; 5 to 8 missing from 4) |
| strength | 0.1, 0.25, 0.5 |
| comparator similarity (spread) | 0.05, 0.3 |
| true effects $\tau_{B_1..B_4}$ | separated (0.6, 0.4, 0.2, 0); tied (0.5, 0.45, 0.2, 0) |

36 cells plus 8 control cells, **1000 replicates** (about 2 core-hours).
**Estimand:** $\Delta_k$, B$_k$ versus A in comparator $k$'s population, and the true
ranking of the four $\Delta_k$.

**Methods.** Maximal MAIC; intersection MAIC; a bounded interval around the maximal
estimate that lets each unreported covariate's comparator mean range over the other
comparators' reported means, with the covariate's coefficient estimated in the
individual data.

## 3. Outcomes and decision

Per contrast: bias, coverage, with MCSE. Per analysis: probability the top-ranked
comparator is wrong, probability any rank is wrong; paired differences between
methods with MCSE.

**Primary.** Adversarial pattern, similar populations, tied effects, all three
strengths.

- **Inversion confirmed** if in at least two of the three primary cells the
  intersection has a lower probability of a wrong top rank (paired 95% MC interval
  excluding 0) while the maximal set has lower mean absolute per-contrast bias.
- **Maximal vindicated** if it is lower on both in at least two primary cells.
- **Intersection dominant** if lower on both in at least two, which section 1 says
  should not happen.

**Secondary.** The same comparison in dispersed cells, where section 1 predicts the
inversion can fail. The diagnostic
$\max_k\lvert\hat\Delta_k^{\max} - \hat\Delta_k^{\cap}\rvert$ scored by AUROC for a wrong
top rank under the maximal set, fit for purpose only if AUROC $\ge 0.75$. Coverage and
width of the bounded interval.

**Controls.** Complete reporting: the two methods coincide and are unbiased within 3
MCSE. Zero strength with gaps: every contrast unbiased within 3 MCSE. Positive: the
exact bias table must be reproduced by simulation within 3 MCSE in every cell.

## 4. Departures from DESIGN.md

Prognostic terms added to the bias (section 1); null control replaced; continuous
outcome only, so the non-collapsible arm is not run; the single-network ML-NMR arm is
not run; overlap is not a separate factor; independent covariates; $n_{sim} = 1000$.
