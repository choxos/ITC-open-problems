VERDICT: needs-revision

### P6's "does not shrink as the target grows" contradicts the 1/nT scaling it cites
SEVERITY: serious
QUOTE: "it does **not** shrink as the target grows, because both sides of the ratio scale with 1/nT."
PROBLEM: If numerator and denominator both scale as 1/nT, their ratio is constant in nT — that supports the claim that the *share* is flat. But the sentence is offered as a reason the term "is carried rather than argued away," i.e. that its magnitude is non-negligible. A constant share is a statement about variance composition, not about whether the term is large; the scaling argument proves the wrong thing. "Does not shrink" is also inconsistent with the table in P2, where the identity max share is 0.786 and the median 0.0928 — variability across cells is exactly what you would not see under a strict 1/nT = 1/nT cancellation.
WHY IT MATTERS: The justification for carrying the cross term rests on a scaling argument that demonstrates composition-invariance, not magnitude. A reader who accepts the stated logic is being told the term cannot be dropped when the argument only says its *fraction* is size-stable.
WOULD BE WRONG IF: the sentence is read strictly as "the share does not shrink," and the author intends magnitude to be inferred from the 0.0962 measurement in the preceding sentence rather than from the scaling clause.

---

### P2's floor is derived for a one-sided omission but applied to a two-component variance
SEVERITY: serious
QUOTE: "Omitting a fraction f of the variance reports a standard error of sqrt(1-f) times the truth, so coverage becomes 2*Phi(1.96*sqrt(1-f))-1. The smallest coverage shift worth claiming is 0.01, which needs f = 0.0791."
PROBLEM: The derivation models the *total* variance being under-reported by fraction f, i.e. the estimator's variance is (1−f)·V_total. The gate then screens on a cell's omitted-variance *share* of the total. That is consistent with the denominator sentence. But the criterion 2Φ(1.96√(1−f))−1 assumes the reported interval uses σ_reported = √(1−f)·σ_truth while the truth's interval uses σ_truth — which is only the right model if the *entire* variance, target-trial plus source plus cross, is what the published estimator reports. Published MAIC variances omit the target-trial and cross terms entirely (Section 6/Methods), so the published interval is not V_total scaled by (1−f); it is V_source alone. Measuring f as omitted/total against a coverage formula that assumes f is a fraction of the *reported* variance compares against the wrong reference quantity.
WHY IT MATTERS: The 0.0791 floor and the 340/792 cell count both depend on this derivation. If the correct reference is the published (source-only) variance, the same 0.01 coverage-shift criterion yields a different f and a different cell set, and the registered grid is either over- or under-powered.
WOULD BE WRONG IF: the design's estimand variance is in fact the thing being coverage-checked against V_total (e.g. the study scores every method, including the ones that carry all terms, against the full V_truth), in which case the formula's σ_truth = V_total is the right reference and only the prose identifying f with "omitted variance" is loose.

---

### P7 claims a control "cannot fail" on the identity link by quoting a gradient that is定义d to be zero there
SEVERITY: serious
QUOTE: "A nonzero identity gradient is an implementation defect; nonzero curved gradients are the subject of the study."
PROBLEM: This is a guard asserted rather than derived from a measured noise floor. The 5.55e-14 figure is presented as the empirically-measured residual that licenses the defect interpretation, but no tolerance is stated for what counts as "nonzero" on the identity link. 5.55e-14 is the floating-point noise floor of the integration machinery described in P1, and P1 spent a paragraph establishing that a tolerance must be calibrated against an independent reference rather than asserted. The same logic is not applied here: the threshold separating "defect" from "floating-point residual" on the identity link is taken as self-evident from a single number with no stated cutoff.
WHY IT MATTERS: If the registered control is "identity gradient = 0," a real implementation returning 1e-10 on a 4096-node product rule would trip the defect flag even though that is within the rule's own accuracy budget established in P1. Conversely if the cutoff is quietly the machine floor, the control is a tautology on the identity link and cannot fail — the defect class the sibling study flagged as "a guard cited for a check that cannot fail."
WOULD BE WRONG IF: the gradient machinery's tolerance has been independently bounded (as P1's integral was) and that bound is 5.55e-14 by construction, in which case the figure is a measured floor and the sentence is just missing the citation back to that bound.

---

### Prediction 1 ("deficit does not close as the target grows") is not measurable by any registered probe
SEVERITY: serious
QUOTE: "no variance indexed by the reported moments can be correct for it, and the deficit does not close as the target grows."
PROBLEM: This is the study's primary registered prediction, asserted in §1. The design varies nT across {100, 300, 1000} and Section 4 reports per-cell shares. But the probes (§2) establish the cross-term share is constant in nT (P6), the identification gradient shrinks with *source* size not target size (P3, 0.02872→0.004265 — note that is nS, the source), and P7's curved-link gradients are about effect modification presence, not target-size scaling. No probe or registered analysis separates a "deficit that does not close in nT" from "a deficit whose composition is stable in nT." P6's flat-share finding is being asked to carry Prediction 1's "does not close" claim, but a flat share is consistent with both a constant *absolute* deficit and a shrinking one — it does not distinguish them.
WHY IT MATTERS: The headline prediction is the thing the study is registered to falsify. If the registered grid measures share-stability rather than deficit-stability, the prediction as written is not testable by what is registered, and a null result would not be evidence against it.
WOULD BE WRONG IF: the coverage analysis on the registered replicates is specified to compare the *absolute* coverage gap across nT levels within a cell, in which case the grid does measure deficit-closure directly and Prediction 1 is testable — but that contrast is not described in §6 or §2.

---

### P3's "gap shrinks with source size" is offered as a correctness check but the reference quantity is the wrong one
SEVERITY: serious
QUOTE: "The gap shrinks monotonically with source size, from 0.02872 to 0.004265, which is what a correct implementation does and a wrong one does not."
PROBLEM: The sentence uses the gradient-gap-as-function-of-source-size trajectory as evidence of a correct implementation. But the gradient gap P3 measures is a statement about *identification* (as the section itself now says two sentences earlier: "retained only for what it does measure: whether the two gradients agree"). A shrinking identification gap with nS is a property of the estimator's convergence to the estimand, not a calibration of the implementation's correctness. A wrong implementation can also have an identification gap that shrinks with nS (e.g. one with a constant multiplicative bias), and a correct implementation under a misspecified link would not. The trajectory is being used to license the implementation while the measurement is of a different thing — identification, not implementation fidelity.
WHY IT MATTERS: This is the self-consistency check the rest of the probe results lean on. If "shrinks with nS" does not actually certify correctness, then the identity-link baseline used to anchor the curved-link claims in P7 ("the identity link is the case where the answer is known") is certified by a criterion that cannot certify it.
WOULD BE WRONG IF: the gap is derived analytically as O(1/nS) and the measured 0.02872→0.004265 trajectory is being compared against that analytic rate as a reference, in which case it is a rate check, not a generic "shrinks" heuristic — but the sentence cites only the shrinkage, not the rate.

---

### The 0.005 / 0.004873 Monte Carlo error pair is a threshold asserted rather than derived
SEVERITY: serious
QUOTE: "The coverage Monte Carlo error the design **targets** is 0.005; the error 2000 replicates actually **deliver** is 0.004873, and that is the figure any claim about resolving a coverage difference is judged against."
PROBLEM: 0.005 is stated as the target with no derivation: it is not tied to the 0.01 smallest-claimable-coverage-shift from P2 (which would imply 0.005 is half the shift, a defensible rule, but that rule is not stated), nor to a paired-contrast standard deviation measured anywhere. P2 establishes that a threshold must be *solved from the criterion, not asserted to follow from it*; the same standard is not applied to the Monte Carlo error target. 0.004873 is then presented as "what 2000 replicates deliver," but with no formula or measurement shown for whether that is the binomial σ = √(0.95·0.05/2000) ≈ 0.00487 or the paired-contrast error that §6 elsewhere says is the relevant quantity. The two give different numbers, and the prose does not say which one 0.004873 is.
WHY IT MATTERS: Every coverage-resolving claim in the study is judged against this figure. If it is the unpaired binomial error, it overstates the precision available for the paired contrasts that are the actual analyses (§6: contrasts are paired), and claims of "resolving a 0.01 shift" are being judged against the wrong error.
WOULD BE WRONG IF: 0.004873 is explicitly the paired-contrast Monte Carlo error measured from a probe, and "0.005 target" is that measurement rounded with the derivation omitted — a prose omission rather than a substantive one.

---

### The B=800 sizing compares coverage to nominal 0.95 while the method interval is biased inward — the ceiling is not the right reference
SEVERITY: serious
QUOTE: "800 comes from measuring the corrected interval against an independent B = 3200 reference ... paired coverage difference ... 800 ... -0.00125"
PROBLEM: The table shows coverage rising past 0.95 (0.9538 at B=800) while the paired difference to B=3200 shrinks toward zero. The prose declares B=800 sufficient because the paired difference is −0.00125, "within" the error budget. But the comparison is to a *B=3200 reference interval, not to the truth*: if the resampling method itself is biased — and the very next sentence says empirical quantiles from finite B are biased inward — then convergence to the B=3200 interval only certifies that B=800 reproduces a biased reference. The sizing test answers "does B=800 match B=3200," not "does B=800 give correct coverage." The 0.9538 figure at B=800 already exceeding 0.95 is not interrogated against the true coverage at B=∞; it is reported as if pairing-stability is the criterion.
WHY IT MATTERS: §5 says maic_perturb's interval "is not centered on the shared estimate," so its coverage is not a paired contrast against the other methods in the sense §6 uses. The B sizing is the linchpin of the perturbation arm's credibility (it is 99–100% of cost). If the sizing criterion matches the arm to a finite-B reference rather than to the true interval it is meant to estimate, the 800-figure could be calibrated against a reference that carries the same bias.
WOULD BE WRONG IF: an analytic or nested-bootstrap bias correction is applied so that B=3200 is plausibly close to B=∞, or if the B=3200 reference is itself validated against a known-coverage construction — neither is stated but either would make the reference adequate.

---

### §5's "ported asymptotic variance" is registered as an analysis the software performs, but the design fixes only what it carries — not the porting
SEVERITY: serious
QUOTE: "`maic_entropy` | adds the moment term, the ported asymptotic variance"
PROBLEM: The methods table registers maic_entropy as carrying "the ported asymptotic variance." Porting an asymptotic variance from one link/scale to another (the whole premise is a non-collapsible link where the published variance is for an identity link, per the MIS-03 lineage) requires a derivation: the sandwich, the influence function, the moment-estimation term. Nothing in the protocol states which source the variance is ported from, what the porting assumes, or whether the software implements the ported form or re-derives it. If the "ported" variance is simply the identity-link sandwich applied on the logit/cloglog scale, it is not the asymptotic variance of the non-collapsible estimand and the entropy arm reports the wrong quantity as if it were the ported one. The catalog's "porting claim," which §5 explicitly says the study "will not report as if it did" settle, is left unspecified in the one place (the method definition) where it must be.
WHY IT MATTERS: maic_entropy reaching the registered coverage band is the study's negative-result branch ("If it reaches the registered coverage band ... the study reports that as a negative result about its own prediction"). If the variance it carries is not actually the ported asymptotic variance for the non-collapsible scale, the negative result is about the wrong estimator and the study's own prediction is neither confirmed nor refuted by its own arm.
WOULD BE WRONG IF: the ported variance is fully specified in DESIGN.md and implemented in code, and the protocol's one-line table cell merely abbreviates a derivation documented elsewhere — then the defect is a documentation gap in the protocol, not a registered-analysis-cannot-be-performed defect.

---

### The 484% cost-increase framing revokes an earlier claim and reinstates the smaller cost nowhere else
SEVERITY: minor
QUOTE: "**The cost rose by 484%** against the 102.6 core-hours measured when B was typed at 200 and the grid was smaller. ... An earlier draft reported this as a saving."
PROBLEM: The 102.6 core-hours figure (B=200, smaller grid) is retained as the reference for the 484% increase, but no registered quantity any longer corresponds to it — the registered B is 800 and the registered grid is the larger one. The 598.8 figure is what the verifier will regenerate; the 102.6 figure is cited purely to express a delta. If the protocol is regenerated from registered-design.json after the grid was enlarged, the 102.6 baseline is not a number the generator would know about unless it is also stored. Either it is hard-coded prose (violating "no number is typed") or it is emitted from a field whose continued presence in the registered design contradicts the claim that B was corrected.
WHY IT MATTERS: This is exactly the "number generated correctly while the sentence around it claims something the number does not support" failure class the prompt flags. 598.8 is legitimately emitted; 102.6 has to be emitted too or it is typed, and if emitted it implies the registered design still stores a B=200 grid, which §6 says it does not.
WOULD BE WRONG IF: the registered design explicitly archives a prior-grid cost figure for the express purpose of this delta, in which case 102.6 is emitted and consistent — but then §6 should say so.

---

### "One overlap level and one true correlation" omits the mixed-binary realization as a third fixed overlap
SEVERITY: minor
QUOTE: "One overlap level and one true correlation. Both are fixed at 0.4 and 0.3."
PROBLEM: §7 lists two scope limits. But §4 narrates that the mixed arm's binary covariate initially ran at a realized standardized difference of 0.001, then was repaired to 0.4. The repair means the *realized* overlap is now 0.4 on all covariates including the binary one, but that realization depends on a latent-shift solve that is itself a design choice — there is a continuum of laws giving the same 0.4 marginal difference, and the study registers one. §7 does not list "one overlap realization" among its scope limits even though §4 made the choice explicit. A reader infers the only overlap degrees of freedom are the level and the correlation; the reparameterization choice is a third.
WHY IT MATTERS: The mixed-arm findings will be conditional on which 0.4-realization was solved to. Scope-limit omissions are the cheapest fix at this stage and the most expensive to correct after the run.
WOULD BE WRONG IF: the latent-shift solution is unique given the registered mixed law and overlap, making the realization determined rather than a choice — then there is no third degree of freedom to list.

---

### STC is registered as a method but its variance handling is unspecified relative to the comparison set
SEVERITY: minor
QUOTE: "`stc` | conditional outcome model, marginalized over the reported law"
PROBLEM: The methods table gives STC one line. §5 then specifies precisely how the four maic_* arms and maic_perturb share (or do not share) a fit, what their intervals are centered on, and whether they enter the paired test. STC gets none of this: is its variance the model-based sandwich, a sandwich with the moment term added, or the resampling-style? Does it enter the paired contrast against the maic arms or only against the truth? Without this, "STC marginalizes over the reported law" can be run in several ways that yield different variances, and the registered analysis cannot be performed "as specified" because the specification is incomplete for this one method.
WHY IT MATTERS: STC is one of six methods and its result contributes to the coverage table. An underspecified method is the registered-analysis-cannot-be-performed defect in its mild form.
WOULD BE WRONG IF: STC's variance construction is specified in DESIGN.md and the protocol's one-line cell is a deliberate abbreviation; then this is a documentation issue, not a specification defect.

---

Total: 11 findings — 4 serious, 6 serious-tier (those needing derivation or cross-section consistency), 2 minor. The dominant defect class is claims whose quoted evidence measures a different quantity than the sentence claims (P3 shrinkage licenses correctness; P6 flat-share licenses magnitude; P2 floor against wrong variance of reference; B=800 against a biased reference; P7 zero-guard with no stated tolerance), which matches the prompt's prediction that this is the failure surface the generator leaves open. The numbers are internally consistent with what emit-protocol would produce; the sentences around several of them overclaim what the number proves.
