**Study `studies/DIA-02-the-whole-weight-panel-is-a-multiset-functional`.** Its primary
outcome and controls were fixed before the run; the rule restricting the analysis to the
cells the controls leave standing was written after it, as its protocol records. 48 cells, 2000 replicates each, 96,000
replicates. Nine diagnostics: the five reported panel members, all symmetric functions of
the weight multiset, against four candidates that read position as well as weight.

**The manipulation.** Two source populations remove the same mass at the same threshold on
exchangeable standard normal coordinates and differ only in which coordinate carries the
hole: the one that modifies the treatment effect, or a purely prognostic one. The first is
biased by **+0.01639** on the target marginal risk difference; the second by **-0.00009**,
which is zero to five decimal places. Material error, meaning the transported effect wrong
by more than 0.03 absolute risk, occurs on **0.106** of replicates in the first and **0.005**
in the second, against **0.003** with no hole at all.

**Result on the registered primary: refuted.** Section 7 registered the AUROC of each
diagnostic against material error *within* the modifying-hole arm. There the best panel
member reaches 0.574 (`max_weight`) and the best geometric candidate 0.592 (`ess_region`), a
gap of 0.018 against a registered materiality of 0.10. By the registered rule the panel
discriminates as well as the geometric diagnostics, and the proposition is refuted.

**Result on the study's own control: confirmed, emphatically.** Section 8 registered a
separate check, that at matched multisets every panel member must be numerically identical
across the two support arms. Read as a discrimination task over 16,000 replicates, **every
panel member sits within 0.005 of chance** (`max_weight` 0.505, `ess_kish` 0.502,
`entropy_eff` 0.501, `top_share` 0.500) with a standard error of 0.005, while `ess_region`
separates the two arms at **1.000** and optimal-transport cost at 0.726. The blindness is
measured, not merely unrejected.

**The disagreement is the finding.** Within one arm every replicate shares one hole
placement, so the only thing varying is sampling noise and the outcome asks which replicate
drew a bad sample. A concentration measure answers that about as well as anything. The
proposition is about comparing analyses at *different* placements, and only the cross-arm
comparison varies it. The registered primary outcome was the wrong measurement for the
question the study was built to ask, and the study's own control was the right one. That is
recorded rather than repaired by relabeling the control as primary after the fact.

**The refuting sentence in the design fails.** Two analyses differing by 0.016 in bias were
built at a panel matched to 2% in an ordinary covariate law, not a contrived one, so the
invariance bites in practice and not only in principle.

**Two of three controls failed, and the failures cost three quarters of the grid.** The
matched-multiset control failed wherever a modifier's second moment was left unmatched, by up
to a 0.908 relative difference, because dropping that moment breaks the coordinate symmetry
the manipulation rests on. The null control failed at `dim8/moderate`, where MAIC's own
sampling error exceeds the 0.03 threshold on **0.288** of replicates with no support hole at
all, and at `dim3/moderate` at 0.021. The source size had been registered from a noise floor
measured at the middle of the grid, and the middle is not the worst corner. This is the same
defect IDN-05 documented, of a threshold set below its own measurement noise, and it is worth
naming twice because such a floor reads as a finding. The analysis drops failing strata on
the controls' own evidence rather than on the results, leaving 12 of 48 cells and 24,000
replicates.

**The comparability half, quantified for the first time.** Three published ESS definitions
computed on identical data disagree by a median factor of **1.55**, a 90th percentile of
**3.50**, and a maximum of **15.48**. The complaint that two analyses of the same evidence
can report incomparable numbers had never been given a size.

**The exclusion is not a boundary artifact.** `dim3/moderate` is dropped on a null rate of
0.0213 against a 0.02 cut, a few Monte Carlo standard errors above it. Adding it back moves
the panel from 0.5046 to 0.5024 and `ess_region` from 0.9999 to 0.9997, so the cut is not
doing the work.

**What this does not answer.** Four limits, three of them live. `hull_gap` is a geometric
diagnostic and is blind anyway, at 0.503, because it maximizes over coordinates and both arms
remove an identical wedge; reading position is not sufficient if the reading is then
aggregated away. `balance_omitted`, registered as the cheap comparator most likely to
overturn the headline, was never given anything to see: the cells where it has content are
exactly the ones the matched-multiset control eliminated, so the comparison the design wanted
did not run. **`ess_region`'s 1.000 is an upper bound, not an estimate of field
performance**: the region it examines and the region the hole empties are the same
construction, so perfect separation is what the arithmetic requires. Two things keep that
from being circular, namely that the region comes from the effect-modifier structure MAIC
already requires naming rather than from knowledge of the hole, and that in the
prognostic-hole arm the hole lies outside the examined region and the statistic correctly
reads near-normal instead of firing on any hole at all. What is untested is a hole in a
high-modification region the analyst did not think to examine, which is where this diagnostic
would fail exactly as the panel does. And no diagnostic here is calibrated: separating two
placements is not a threshold.
