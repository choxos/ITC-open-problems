# Decision

**Conclusion: the panel does not classify realized error at the thresholds in use**

Prespecified in `protocol.md`. 128 cells, 4000 replicates each, 4 estimators. MAIC fitted on 0.993 of replicates (deployment-weighted non-fit 0.003). Material error, meaning |estimate - truth| > 0.20 in the transported effect, on 0.479 of fitted MAIC replicates under the deployment weights.

## Primary: operating points WITHIN each misspecification stratum

Cells are weighted equally inside a stratum, so no chosen mixture of misspecification frequencies enters the headline.

| stratum | rule | prevalence | sensitivity | specificity | fires on |
| --- | --- | ---: | ---: | ---: | ---: |
| well specified | ess | 0.493 | 0.326 (0.001) | 0.923 (0.001) | 0.200 |
| well specified | ess30 | 0.493 | 0.291 (0.001) | 0.934 (0.001) | 0.177 |
| well specified | ess_pct | 0.493 | 0.742 (0.001) | 0.623 (0.001) | 0.557 |
| well specified | cv_w | 0.493 | 0.742 (0.001) | 0.623 (0.001) | 0.557 |
| well specified | max_w | 0.493 | 0.350 (0.001) | 0.919 (0.001) | 0.214 |
| well specified | smd_matched | 0.493 | 0.000 (0.000) | 1.000 (0.000) | 0.000 |
| well specified | smd_pre | 0.493 | 0.822 (0.001) | 0.408 (0.001) | 0.706 |
| well specified | maha | 0.493 | 0.656 (0.001) | 0.692 (0.001) | 0.480 |
| well specified | smd_unmatched | 0.493 | 0.559 (0.002) | 0.610 (0.001) | 0.474 |
| well specified | bias_hat | 0.493 | 0.099 (0.001) | 0.962 (0.001) | 0.068 |
| omitted modifier | ess | 0.539 | 0.309 (0.001) | 0.926 (0.001) | 0.201 |
| omitted modifier | ess30 | 0.539 | 0.277 (0.001) | 0.937 (0.001) | 0.178 |
| omitted modifier | ess_pct | 0.539 | 0.735 (0.001) | 0.654 (0.002) | 0.556 |
| omitted modifier | cv_w | 0.539 | 0.735 (0.001) | 0.654 (0.002) | 0.556 |
| omitted modifier | max_w | 0.539 | 0.332 (0.001) | 0.920 (0.001) | 0.216 |
| omitted modifier | smd_matched | 0.539 | 0.000 (0.000) | 1.000 (0.000) | 0.000 |
| omitted modifier | smd_pre | 0.539 | 0.823 (0.001) | 0.431 (0.001) | 0.706 |
| omitted modifier | maha | 0.539 | 0.652 (0.001) | 0.721 (0.001) | 0.480 |
| omitted modifier | smd_unmatched | 0.539 | 0.571 (0.001) | 0.639 (0.001) | 0.474 |
| omitted modifier | bias_hat | 0.539 | 0.393 (0.001) | 0.807 (0.001) | 0.301 |
| cross-moment | ess | 0.640 | 0.265 (0.001) | 0.918 (0.001) | 0.199 |
| cross-moment | ess30 | 0.640 | 0.237 (0.001) | 0.929 (0.001) | 0.178 |
| cross-moment | ess_pct | 0.640 | 0.649 (0.001) | 0.607 (0.002) | 0.556 |
| cross-moment | cv_w | 0.640 | 0.649 (0.001) | 0.607 (0.002) | 0.556 |
| cross-moment | max_w | 0.640 | 0.285 (0.001) | 0.913 (0.001) | 0.214 |
| cross-moment | smd_matched | 0.640 | 0.000 (0.000) | 1.000 (0.000) | 0.000 |
| cross-moment | smd_pre | 0.640 | 0.767 (0.001) | 0.403 (0.002) | 0.706 |
| cross-moment | maha | 0.640 | 0.570 (0.001) | 0.683 (0.002) | 0.479 |
| cross-moment | smd_unmatched | 0.640 | 0.520 (0.001) | 0.608 (0.002) | 0.474 |
| cross-moment | bias_hat | 0.640 | 0.091 (0.001) | 0.957 (0.001) | 0.074 |
| both | ess | 0.688 | 0.251 (0.001) | 0.915 (0.001) | 0.199 |
| both | ess30 | 0.688 | 0.224 (0.001) | 0.927 (0.001) | 0.177 |
| both | ess_pct | 0.688 | 0.642 (0.001) | 0.633 (0.002) | 0.556 |
| both | cv_w | 0.688 | 0.642 (0.001) | 0.633 (0.002) | 0.556 |
| both | max_w | 0.688 | 0.269 (0.001) | 0.909 (0.001) | 0.214 |
| both | smd_matched | 0.688 | 0.000 (0.000) | 1.000 (0.000) | 0.000 |
| both | smd_pre | 0.688 | 0.771 (0.001) | 0.440 (0.002) | 0.705 |
| both | maha | 0.688 | 0.564 (0.001) | 0.707 (0.002) | 0.480 |
| both | smd_unmatched | 0.688 | 0.543 (0.001) | 0.681 (0.002) | 0.473 |
| both | bias_hat | 0.688 | 0.358 (0.001) | 0.827 (0.002) | 0.300 |

## Secondary: the same rules over the declared mixture

| rule | cut | sensitivity | specificity | fires on | sens (equal wts) | spec (equal wts) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| ess | 35 | 0.183 (0.000) | 0.963 (0.000) | 0.107 | 0.284 | 0.921 |
| ess30 | 30 | 0.161 (0.000) | 0.969 (0.000) | 0.093 | 0.254 | 0.932 |
| ess_pct | 0.5 | 0.623 (0.001) | 0.701 (0.001) | 0.454 | 0.686 | 0.630 |
| cv_w | 1 | 0.623 (0.001) | 0.701 (0.001) | 0.454 | 0.686 | 0.630 |
| max_w | 0.1 | 0.204 (0.001) | 0.959 (0.000) | 0.119 | 0.305 | 0.916 |
| smd_matched | 0.1 | 0.000 (0.000) | 1.000 (0.000) | 0.000 | 0.000 | 1.000 |
| smd_pre | 0.25 | 0.784 (0.001) | 0.401 (0.001) | 0.688 | 0.793 | 0.419 |
| maha | 1 | 0.534 (0.001) | 0.760 (0.001) | 0.381 | 0.605 | 0.701 |
| smd_unmatched | 0.1 | 0.450 (0.001) | 0.690 (0.001) | 0.377 | 0.547 | 0.631 |
| bias_hat | 0.1 | 0.144 (0.000) | 0.942 (0.000) | 0.099 | 0.240 | 0.892 |

Replicates on which MAIC had no solution: 3,747. Bracketing the primary rule's sensitivity by counting every one of them as a caught failure, then as a missed one, gives 0.285 and 0.273.

## Discrimination, which separates a bad threshold from a useless statistic

| diagnostic | AUROC | AUPRC | vs transport | vs noise | vs non-coverage |
| --- | ---: | ---: | ---: | ---: | ---: |
| ess | 0.731 (0.001) | 0.707 | 0.653 | 0.847 | 0.630 |
| ess_pct | 0.723 (0.001) | 0.698 | 0.667 | 0.813 | 0.644 |
| cv_w | 0.723 (0.001) | 0.698 | 0.667 | 0.813 | 0.644 |
| max_w | 0.741 (0.001) | 0.716 | 0.660 | 0.833 | 0.645 |
| smd_matched | 0.550 (0.001) | 0.509 | 0.538 | 0.571 | 0.544 |
| smd_pre | 0.683 (0.001) | 0.671 | 0.655 | 0.799 | 0.630 |
| maha | 0.682 (0.001) | 0.669 | 0.656 | 0.796 | 0.631 |
| smd_unmatched | 0.606 (0.001) | 0.592 | 0.665 | 0.663 | 0.592 |
| bias_hat | 0.604 (0.001) | 0.591 | 0.684 | 0.643 | 0.587 |
| orc_cross | 0.581 (0.001) | 0.551 | 0.809 | 0.505 | 0.590 |
| lambda_norm | 0.698 (0.001) | 0.664 | 0.660 | 0.796 | 0.622 |

### All three error components, equal cell weights, and the other thresholds

| diagnostic | vs arm imbalance | vs transport | vs noise | AUROC (equal wts) | material 0.10 | material 0.30 | anchored contrast |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| ess | 0.813 | 0.653 | 0.847 | 0.721 | 0.683 | 0.779 | 0.699 |
| ess_pct | 0.807 | 0.667 | 0.813 | 0.717 | 0.675 | 0.770 | 0.692 |
| cv_w | 0.807 | 0.667 | 0.813 | 0.717 | 0.675 | 0.770 | 0.692 |
| max_w | 0.837 | 0.660 | 0.833 | 0.729 | 0.690 | 0.791 | 0.708 |
| smd_matched | 0.583 | 0.538 | 0.571 | 0.557 | 0.537 | 0.564 | 0.544 |
| smd_pre | 0.739 | 0.655 | 0.799 | 0.690 | 0.641 | 0.728 | 0.658 |
| maha | 0.737 | 0.656 | 0.796 | 0.690 | 0.640 | 0.726 | 0.657 |
| smd_unmatched | 0.615 | 0.665 | 0.663 | 0.623 | 0.583 | 0.629 | 0.590 |
| bias_hat | 0.603 | 0.684 | 0.643 | 0.619 | 0.582 | 0.625 | 0.588 |
| orc_cross | 0.502 | 0.809 | 0.505 | 0.586 | 0.577 | 0.576 | 0.566 |
| lambda_norm | 0.758 | 0.660 | 0.796 | 0.695 | 0.657 | 0.739 | 0.671 |

### Discrimination against the transport component, by stratum

| diagnostic | well specified | omitted modifier | cross-moment | both |
| --- | ---: | ---: | ---: | ---: |
| ess | 0.946 | 0.837 | 0.637 | 0.658 |
| ess_pct | 0.925 | 0.862 | 0.642 | 0.679 |
| cv_w | 0.925 | 0.862 | 0.642 | 0.679 |
| max_w | 0.940 | 0.841 | 0.643 | 0.664 |
| smd_matched | 0.587 | 0.600 | 0.529 | 0.541 |
| smd_pre | 0.897 | 0.859 | 0.617 | 0.681 |
| maha | 0.894 | 0.859 | 0.618 | 0.683 |
| smd_unmatched | 0.737 | 0.946 | 0.573 | 0.755 |
| bias_hat | 0.725 | 0.938 | 0.566 | 0.746 |
| orc_cross | 0.500 | 0.500 | 0.648 | 0.626 |
| lambda_norm | 0.869 | 0.850 | 0.630 | 0.681 |

### The anchored contrast, which is what a submission reports

| rule | sensitivity | specificity | prevalence |
| --- | ---: | ---: | ---: |
| ess | 0.171 | 0.961 | 0.515 |
| ess30 | 0.150 | 0.967 | 0.515 |
| ess_pct | 0.589 | 0.689 | 0.515 |
| cv_w | 0.589 | 0.689 | 0.515 |
| max_w | 0.190 | 0.957 | 0.515 |
| smd_matched | 0.000 | 1.000 | 0.515 |
| smd_pre | 0.764 | 0.393 | 0.515 |
| maha | 0.504 | 0.750 | 0.515 |
| smd_unmatched | 0.435 | 0.685 | 0.515 |
| bias_hat | 0.136 | 0.940 | 0.515 |

## Calibration of a locked mapping

Leave-one-factor-level-out: fourteen folds, each holding out every cell at one level of one factor. Median over folds, with the worst fold, and the within-cell replicate split as the optimistic bound. A logistic model on one transformed diagnostic; no splines.

| diagnostic | intercept | slope | calibration error (median) | worst fold | same-cell |
| --- | ---: | ---: | ---: | ---: | ---: |
| ess | -0.257 | 1.179 | 0.076 | 0.197 | 0.066 |
| ess_pct | -0.269 | 1.195 | 0.095 | 0.200 | 0.069 |
| cv_w | -0.326 | 1.256 | 0.108 | 0.202 | 0.078 |
| max_w | -0.350 | 1.381 | 0.117 | 0.201 | 0.091 |
| smd_matched | -0.434 | 0.540 | 0.129 | 0.319 | 0.105 |
| smd_pre | -0.317 | 1.227 | 0.098 | 0.235 | 0.075 |
| maha | -0.315 | 1.192 | 0.096 | 0.235 | 0.075 |
| smd_unmatched | -0.331 | 0.877 | 0.163 | 0.362 | 0.101 |
| bias_hat | -0.430 | 1.151 | 0.165 | 0.280 | 0.086 |
| orc_cross | -0.353 | 1.265 | 0.132 | 0.299 | 0.080 |
| lambda_norm | -0.356 | 1.146 | 0.133 | 0.234 | 0.099 |

## Decision curve: is acting on the rule better than not?

Net benefit relative to flagging nothing. A rule earns its place only above both alternatives.

| threshold prob | flag none | flag all | ess | ess30 | ess_pct | cv_w | max_w | smd_matched | smd_pre | maha | smd_unmatched | bias_hat |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 0.100 | 0.000 | 0.421 | 0.086 | 0.075 | 0.281 | 0.281 | 0.095 | 0.000 | 0.341 | 0.242 | 0.197 | 0.066 |
| 0.200 | 0.000 | 0.348 | 0.083 | 0.073 | 0.259 | 0.259 | 0.092 | 0.000 | 0.297 | 0.224 | 0.175 | 0.061 |
| 0.300 | 0.000 | 0.255 | 0.080 | 0.070 | 0.231 | 0.231 | 0.089 | 0.000 | 0.241 | 0.202 | 0.146 | 0.056 |
| 0.400 | 0.000 | 0.131 | 0.075 | 0.066 | 0.194 | 0.194 | 0.083 | 0.000 | 0.167 | 0.172 | 0.108 | 0.049 |
| 0.500 | 0.000 | -0.043 | 0.069 | 0.061 | 0.142 | 0.142 | 0.076 | 0.000 | 0.063 | 0.130 | 0.054 | 0.039 |

## Systematic transport bias, with the cell as the unit

42 of 128 cells have a systematic transport bias above 0.20.

| diagnostic | AUROC vs systematic bias | Spearman with |bias| |
| --- | ---: | ---: |
| ess | 0.808 | 0.469 |
| ess_pct | 0.818 | 0.495 |
| cv_w | 0.818 | 0.495 |
| max_w | 0.813 | 0.479 |
| smd_matched | 0.708 | 0.337 |
| smd_pre | 0.813 | 0.492 |
| maha | 0.808 | 0.476 |
| smd_unmatched | 0.821 | 0.508 |
| bias_hat | 0.829 | 0.545 |
| orc_cross | 0.845 | 0.764 |
| lambda_norm | 0.783 | 0.451 |

## The four prespecified mechanism claims

| claim | holds | evidence |
| --- | :---: | --- |
| variance_not_bias | yes | Effective sample size discriminates outcome noise at AUROC 0.847 and transport error at 0.653, a gap of 0.194 against a prespecified 0.10. |
| threshold_not_transportable | no | Across the 24 cells the rule flags on most replicates, the material-error rate runs from 0.751 to 0.902, a span of 0.150 against a prespecified 0.30. Across the 88 cells it is silent on, the rate runs from 0.045 to 0.835. |
| panel_is_one_statistic | yes | Within a fixed source size the three agree to 0.0e+00 in AUROC, and the matched-moment balance statistic never exceeds 1.4e-14. |
| bias_hat_helps | no | In the diagnosable stratum, against the transport component, the proposal reaches 0.937 and the best routinely reported diagnostic 0.851, a gain of 0.086 against a prespecified 0.10. |

## The same statistics for the other estimators

| method | diagnostic | AUROC | vs transport | material error rate | median ESS | coverage |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| maic_mean | ess | 0.704 | 0.599 | 0.433 | 261.783 | 0.730 |
| maic_mean | smd_pre | 0.685 | 0.607 | 0.433 | 261.783 | 0.730 |
| maic_mean | maha | 0.683 | 0.608 | 0.433 | 261.783 | 0.730 |
| maic_mean | smd_unmatched | 0.602 | 0.624 | 0.433 | 261.783 | 0.730 |
| maic_mean | bias_hat | 0.602 | 0.641 | 0.433 | 261.783 | 0.730 |
| stc | smd_pre | 0.656 | 0.635 | 0.340 | 550.000 | 0.533 |
| stc | maha | 0.655 | 0.636 | 0.340 | 550.000 | 0.533 |
| stc | smd_unmatched | 0.606 | 0.619 | 0.340 | 550.000 | 0.533 |
| stc | bias_hat | 0.611 | 0.628 | 0.340 | 550.000 | 0.533 |
| unadj | smd_pre | 0.804 | 0.891 | 0.596 | 550.000 | 0.357 |
| unadj | maha | 0.804 | 0.891 | 0.596 | 550.000 | 0.357 |
| unadj | smd_unmatched | 0.802 | 0.892 | 0.596 | 550.000 | 0.357 |
| unadj | bias_hat | 0.798 | 0.873 | 0.596 | 550.000 | 0.357 |

