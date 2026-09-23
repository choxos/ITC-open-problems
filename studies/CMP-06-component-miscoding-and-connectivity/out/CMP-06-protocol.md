# Protocol: component miscoding in a network bridged by one shared component

**Target problem.** CMP-06 (component miscoding only; covariate measurement error excluded). ADEMP
reporting. Committed before the registered run. Design: [`DESIGN.md`](DESIGN.md).

## 1. Claim

A component matrix parsed deterministically from labels can be wrong, and because a bridge exists exactly
when subnetworks share a component, a miscoding can change what is estimable rather than perturb a
coefficient. **Refuting sentence:** plausible miscodings leave the row space intact, so their effect is a
small perturbation of an estimate that standard sensitivity analysis covers.

## 2. Design

Subnetwork 1: X vs X+A (two trials), X vs X+C. Subnetwork 2: Y+A vs Y+B+D (two trials), Y vs Y+D. Only
component A links them. Component effects A $-0.3$, B $-0.2$, C $-0.1$, D $-0.15$; each trial contrast has
variance 0.01. Target: the effect of B (X+B vs X), identified under the true coding through A. Each
subnetwork-2 trial's coding is wrong independently with probability $p \in \{0, 0.05, 0.15, 0.3\}$:
**connectivity-changing** (its A coded as a distinct agent, A2) or **connectivity-preserving** (the D in its
Y+B+D arm dropped). 7 cells, **2000 replicates**.

Methods: deterministic fit of the coding used, with the estimability screen (rank check); coding
sensitivity (fit every plausible coding of the two uncertain features; union of the 95% intervals, or the
whole line if some plausible coding leaves B unidentified); probabilistic coding (mixture over plausible
codings weighted by the prior miscoding probability, at least 0.05; the whole line if the non-identifying
codings carry more than 5% prior mass).

## 3. Decision

**Primary:** coverage in the connectivity-changing cells ($p > 0$), deterministic given estimability and
probabilistic. **Confirmed** if deterministic coverage is below 0.90 in some cell while probabilistic coverage
is at least 0.93; **refuted for inference** if both are at least 0.93 in every such cell; otherwise mixed.
Reported: non-estimability frequency (the screen's firing rate, exact by construction), bias and coverage
given a miscoding, and how often sensitivity and probabilistic intervals are bounded.

Controls. **Null:** $p = 0$: deterministic coverage 0.93 to 0.97. **Second null:** connectivity-preserving
miscoding keeps deterministic coverage at least 0.93. **Positive:** connectivity-changing at $p = 0.3$ makes
the target non-estimable in at least 5% of replicates.

## 4. Departures from DESIGN.md

Frequentist fixed-effect component model on contrast-level data; one hand-built network; no covariate
adjustment layer, overlap or effect-modification factors, no synergy; the plausible coding set is the two
uncertain features of the two subnetwork-2 trials; no Bayesian arm, so no prior-free precision. A false
bridge (a distinct agent coded as the shared component) is outside the design, because the target is then
not identified under the true coding; it is discussed, not simulated.
