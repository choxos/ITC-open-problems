VERDICT: unsound

### Two estimands do not separate prediction 1's quantities
SEVERITY: fatal
QUOTE: That is what the two registered estimands separate and what the growth ladder measures.
PROBLEM: Prediction 1 is that reported-moment methods target the moment-matched contrast rather than Delta(F_T). The two registered estimands are both full-law contrasts (superpopulation Delta(F_T) and the same contrast in the drawn target sample). Neither is the moment-matched contrast. Coverage of both can fail together under a shared moment-matched point estimate; that pattern does not separate "interval too narrow" from "centered on a different quantity" the way the sentence claims. The ladder can test persistence; the estimand pair as defined cannot identify that the methods are right for a moment-matched target.
WHY IT MATTERS: The design's stated mechanism for making prediction 1 falsifiable does not measure the distinction the prediction is about. A registration that promises this separation will overclaim what the analysis can show.
WOULD BE WRONG IF: A third, moment-matched estimand is also computed every replicate and is what "the two" was meant to include, or "separate" only means superpopulation versus finite-sample and is not offered as evidence for the moment-matched claim.

### Anchored paragraph cites the wrong share range and contradicts itself
SEVERITY: fatal
QUOTE: In an anchored comparison the target trial's own effect carries about 83% of the interval's variance, and the moment term's median share ranges from 0.0224 to 0.0928 across links.
PROBLEM: The table immediately above gives anchored median moment shares of 0.0079 to 0.0395. The range 0.0224 to 0.0928 is the P2 overall median share by link (logit 0.0224, identity 0.0928), not the anchored column. The same paragraph says the effect is "immaterial with" an anchor (supported by anchored max 0.0777 and anchored medians below the floor), then quotes a range that includes 0.0928, which is above the 0.0791 floor and is therefore material by the study's own criterion.
WHY IT MATTERS: This is the study's declared "first result" and it mislabels probe numbers. Registration would freeze a headline claim the tables next to it refute.
WOULD BE WRONG IF: 0.0224 and 0.0928 are separately measured anchored medians under a different definition of share, and the P2 table match is coincidental.

### "About 83%" is not a measurement of anchored comparisons
SEVERITY: fatal
QUOTE: In an anchored comparison the target trial's own effect carries about 83% of the interval's variance
PROBLEM: The only components offered for that percentage are P2's componentwise medians "across the realized grid" (target-trial 0.02373 over a sum of medians of omitted, source, target-trial, and cross). That is not conditioned on anchored cells; it is not the median of within-cell shares; and it cannot hold in the same cells as the unanchored identity median moment share of 0.3612. Ratio of medians is not the median share.
WHY IT MATTERS: A core probe claim about where interval variance lives is arithmetically and population-mismatched to the evidence cited.
WOULD BE WRONG IF: 83% is the median across anchored cells of the within-cell target-trial share of total variance, and the component medians are only illustrative.

### Prediction 1 is stated as if moments never identify F_T
SEVERITY: serious
QUOTE: reported-moment methods target the moment-matched contrast, and their coverage of Delta(F_T) fails by an amount that persists as nT grows.
PROBLEM: Under `mvnorm`, means, variances, and correlation fix the law. With `corr_assumed = true` or `maic_oracle`, the Gaussian reconstruction matches the truth, so the moment-matched contrast and Delta(F_T) coincide and prediction 1's bias need not exist. The design includes those cells; section 7 notes reconstruction is always Gaussian but never restricts the prediction to non-Gaussian truth or wrong correlation.
WHY IT MATTERS: Nominal coverage on the Gaussian-correct cells would look like falsification of a global prediction that should only apply where moments do not determine F_T.
WOULD BE WRONG IF: Prediction 1 and its ladder falsification rule are pre-specified only for shapes or correlation assumptions where the completion is misspecified.

### Anchored is described as crossed in the study but gated out of the run set
SEVERITY: serious
QUOTE: `anchored` is crossed with the whole core rather than varied around a middle, because the two settings differ by an order of magnitude in what the moment term is a share of.
PROBLEM: No anchored cell clears the floor (max share 0.0777 < 0.0791); of cells clearing the floor, 340 are unanchored, i.e. all of them. The powered grid therefore does not cross anchoring. Anchored versus unanchored "results" are probe share decompositions only, while the factorial language presents anchoring as part of what the simulation study is.
WHY IT MATTERS: Readers and analysis code can treat anchoring as a design factor with coverage estimands it will never estimate.
WOULD BE WRONG IF: The growth ladder and analysis explicitly run both anchored levels, or the registration states that anchoring is probe-only and not a simulated factor.

### Cell gate uses a no-bias coverage formula to study a bias prediction
SEVERITY: serious
QUOTE: Omitting a fraction f of the variance reports a standard error of sqrt(1-f) times the truth, so coverage becomes 2*Phi(1.96*sqrt(1-f))-1.
PROBLEM: That mapping assumes correct centering. Prediction 1 asserts incorrect centering (moment-matched point estimate versus Delta(F_T)). Cells are admitted when omitted-variance share is large under a criterion that is not the operating characteristic under the predicted bias.
WHY IT MATTERS: The powered grid is selected for a variance-omission story; it is not shown to be the region where the identification/coverage claim is most testable, except for the ladder exemption.
WOULD BE WRONG IF: The gate is only intended to power variance-term comparisons, and prediction 1 is exclusively tested on the ladder with that limitation registered.

### Baseline shift level 0 reintroduces the degeneracy that motivated the factor
SEVERITY: serious
QUOTE: the DGM previously gave source and target the same intercept, so their control arms were identical, the anchored contrast differenced away a quantity that was already equal, and the two estimands coincided exactly.
PROBLEM: The added factor still includes `target baseline shift` = 0 alongside 0.5. At 0 the design restores the same-intercept condition the paragraph says made estimands coincide and left the unanchored arm without its real baseline risk. That level is not labeled as a null control.
WHY IT MATTERS: A large slice of the grid may recreate the pathology the factor was added to remove, mixing degenerate and non-degenerate cells in pooled summaries.
WOULD BE WRONG IF: Shift 0 is an intentional control with separate pre-specified reporting, or "coincided" only under further conditions that shift 0 does not restore.

### Correction of "about 1%" points at the wrong identity number
SEVERITY: serious
QUOTE: An earlier draft rounded that to "about 1%", which understates the identity arm.
PROBLEM: The numbers used to "fix" the understatement are 0.0224 to 0.0928. In the anchored table printed above, identity is 0.0395, not 0.0928. The identity figure 0.0928 is the P2 overall median. The narrative of repairing an understatement still attaches identity to the wrong measurement.
WHY IT MATTERS: Same defect class as stale numbers, but here the generator is fine and the prose claims the wrong thing about a correct figure.
WOULD BE WRONG IF: The 1% draft claim was about overall (not anchored) shares and 0.0928 is the intended identity referent in that scope only, with grammar fixed.

### P6 claims the cross term is above the floor "including Monte Carlo error"
SEVERITY: serious
QUOTE: The worst cell reaches 0.0962 including Monte Carlo error against the 0.0791 threshold, so the cross term is above the threshold and cannot be ignored.
PROBLEM: "Including Monte Carlo error" usually means estimate plus error bar, i.e. a bound, not a point measurement of the share. The sentence treats that figure as establishing that the cross term is above 0.0791. If the point estimate is lower and only the upper bound clears 0.0791, the data do not establish that the share exceeds the floor.
WHY IT MATTERS: The entire rationale for the `maic_xcov` arm and for not dropping the cross term rests on clearing that threshold.
WOULD BE WRONG IF: 0.0962 is the point estimate of the worst-cell share (with MCE reported elsewhere as smaller), not an estimate-plus-MCE construction.

### Entropy success is described as showing the "moment term suffices" for prediction 1
SEVERITY: serious
QUOTE: If it reaches the registered coverage band across the grid, the moment term suffices *in these conditions* and the study reports that as a negative result about its own prediction.
PROBLEM: Prediction 1 is about identification bias and persistent coverage failure for Delta(F_T). The moment term is a variance correction; `maic_entropy` shares the point estimate with `maic_fixed`. Coverage success would falsify large bias relative to SE, not show that "the moment term suffices" as the mechanism. Coverage failure of `maic_fixed` that is closed by `maic_entropy` is a variance story, which is the withdrawn second prediction's territory, not prediction 1's.
WHY IT MATTERS: Pre-specified interpretation maps the same coverage outcome onto the wrong scientific claim.
WOULD BE WRONG IF: The registered prediction being tested by entropy is only whether the asymptotic moment variance restores coverage when identification bias is negligible, and that is stated as a separate hypothesis.

### P5 sufficiency rule cannot be checked from the evidence shown
SEVERITY: minor
QUOTE: A B is sufficient when two conditions hold together: the paired coverage difference from the reference, plus that difference's Monte Carlo error, is inside the 0.01 shift the study is willing to interpret; and the mean width is within 1% of the reference width.
PROBLEM: The table gives paired coverage differences and mean widths by B but not the reference width, not each difference's Monte Carlo error, and not a pass/fail against the two conditions. B = 400 has difference -0.005 and width 1.006; without those missing pieces, "800 is the smallest value in the grid meeting both" is asserted rather than shown.
WHY IT MATTERS: B is the study's main cost lever (99%–100% of runtime). The registered choice should be reconstructible from the probe report.
WOULD BE WRONG IF: The missing MCE and reference width are fixed in the export and the inequality uniquely selects 800.

### Falsification rule for prediction 1 does not name the method or estimand path
SEVERITY: minor
QUOTE: It is falsified if coverage of the superpopulation estimand approaches nominal along the ladder.
PROBLEM: "Approaches nominal" is not tied to the 0.935–0.965 band, a rate in nT, or a specific arm (`maic_fixed` versus entropy versus all reported-moment methods). Under a shared point estimate, several arms are equally relevant to the bias claim.
WHY IT MATTERS: After the run, both "prediction held" and "prediction falsified" remain arguable.
WOULD BE WRONG IF: Analysis code pre-commits a single arm, the band, and a numerical ladder criterion elsewhere in the registration package.
