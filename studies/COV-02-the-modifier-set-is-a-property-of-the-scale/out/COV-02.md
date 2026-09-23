# Which covariates a transported contrast depends on changes with the
scale, but not in a nested way
Ahmad Sofi-Mahmudi
2026-09-23

# Abstract

**Background.** Effect modification is scale-specific, and on
non-collapsible scales purely prognostic covariates change marginal
contrasts. Catalog problem COV-02 asks how the set of covariates a
transported contrast depends on differs between the scales a decision
might use.

**Methods.** Population-level calculation with a logistic outcome model:
zero, one or three conditional modifiers, two or six prognostic
non-modifiers, two prognostic strengths and two imbalances between
source and target (24 scenarios). For each covariate we computed how
much leaving it unbalanced changed the target contrast on the risk
difference, log risk ratio, marginal log odds ratio and conditional log
odds ratio scales, and counted it in the scale’s set if the change
exceeded 5% of the contrast.

**Results.** The conditional log odds ratio set never contained a
prognostic non-modifier; some marginal scale’s set did in 13 of 24
scenarios. The sets differed between the risk difference, marginal and
conditional odds ratio scales in 10 of 24, below the registered
threshold of half, so the refuting sentence holds as registered.
DESIGN.md’s prediction that the marginal odds ratio set contains the
risk-difference set failed in 5 scenarios, because with a logistic model
every prognostic variable modifies the risk difference. The median
relative change from leaving one prognostic variable unbalanced was
0.045 on the risk difference, 0.035 on the log risk ratio and 0.016 on
the marginal log odds ratio scale: the risk difference, not the odds
ratio, was the most sensitive.

**Conclusion.** The covariates a transport must balance depend on the
decision scale, and prognostic variables can matter on every marginal
scale, the risk difference included. The dependence is a matter of
degree around any threshold, not a nested rule; declare the scale and
balance prognostic variables that are imbalanced.

# The problem

With a logistic model the conditional risk difference is
$\operatorname{expit}(\alpha + \gamma^\top x + \delta + \beta^\top x) - \operatorname{expit}(\alpha + \gamma^\top x)$,
which depends on $\gamma^\top x$ even when $\beta = 0$. DESIGN.md said
that on the risk-difference scale only conditional modifiers matter;
that holds for a linear-risk model, not a logistic one. On the marginal
odds ratio scale prognostic variables enter through non-collapsibility
([1](#ref-daniel2021)). Only the conditional log odds ratio depends on
modifiers alone.

# Design

Registered protocol: `protocol.md`.
$\operatorname{logit}p = \operatorname{logit}(0.25) + g\sum_jx_j + A(-0.5 + 0.3\sum_{j\le m}x_j)$;
source $x \sim N(0, I)$, target $N(\mu\mathbf 1, I)$. Balancing a
covariate’s mean moves it to its target law (independent normals); an
unbalanced covariate stays at its source law. Contrasts from $10^6$
common random draws.

# Results

<div id="fig-change">

![](figures/fig1-change.png)

Figure 1: Largest relative change in the target contrast from leaving
one prognostic non-modifier unbalanced, by marginal scale (the
conditional log odds ratio is unaffected). Log scale; the dashed line is
the 5% threshold defining set membership.

</div>

The relative changes
(<a href="#fig-change" class="quarto-xref">Figure 1</a>) rose with
imbalance and prognostic strength on every marginal scale and were zero
on the conditional one. Which marginal scale was most sensitive depended
on the scenario: with many prognostic variables the log risk ratio
crossed the threshold where the risk difference and odds ratio did not,
and with few the risk difference crossed first. Because the changes sit
close to any fixed threshold, set membership flipped with small changes
in the scenario, which is why a nested rule does not describe it. Where
the target contrast itself was near zero (3 scenarios with three
modifiers and larger imbalance, contrast -0.001 or closer to zero on the
odds ratio scale) relative changes were very large and set membership
says little; absolute changes are the better guide there.

# What this does not answer

No time-to-event scale; no sampling, so how well the sets can be
estimated (COV-01) and the cost of balancing more covariates are not
studied; independent normal covariates. Peer review has not been done.

# References

<div id="refs" class="references csl-bib-body">

<div id="ref-daniel2021" class="csl-entry">

<span class="csl-left-margin">1.
</span><span class="csl-right-inline">Rhian Daniel, Jingjing Zhang,
Daniel Farewell. Making apples from oranges: Comparing noncollapsible
effect estimators and their standard errors after adjustment for
different covariate sets. Biometrical Journal. 2021;63(3):528–57.
doi:[10.1002/bimj.201900297](https://doi.org/10.1002/bimj.201900297)</span>

</div>

</div>
