# Decision

**Primary (weakest overlap, G-computation interval failure): alignment-aware score minus Kish ESS AUROC 0.090 (SE 0.013): NEITHER USABLE.**

| truncation | failure | diagnostic | AUROC | SE | failure rate |
|---|---|---|---:|---:|---:|
| all | fail_gc | kish_ess | 0.561 | 0.006 | 0.068 |
| all | fail_gc | unsupported_mass | 0.560 | 0.006 | 0.068 |
| all | fail_gc | max_weight_share | 0.544 | 0.005 | 0.068 |
| all | fail_gc | alignment_score | 0.590 | 0.007 | 0.068 |
| all | fail_maic | kish_ess | 0.590 | 0.006 | 0.083 |
| all | fail_maic | unsupported_mass | 0.592 | 0.005 | 0.083 |
| all | fail_maic | max_weight_share | 0.565 | 0.006 | 0.083 |
| all | fail_maic | alignment_score | 0.642 | 0.005 | 0.083 |
| all | fail_gc_mat | kish_ess | 0.754 | 0.003 | 0.190 |
| all | fail_gc_mat | unsupported_mass | 0.752 | 0.003 | 0.190 |
| all | fail_gc_mat | max_weight_share | 0.707 | 0.003 | 0.190 |
| all | fail_gc_mat | alignment_score | 0.722 | 0.003 | 0.190 |
| 1 | fail_gc | kish_ess | 0.501 | 0.010 | 0.087 |
| 1 | fail_gc | unsupported_mass | 0.507 | 0.009 | 0.087 |
| 1 | fail_gc | max_weight_share | 0.481 | 0.009 | 0.087 |
| 1 | fail_gc | alignment_score | 0.592 | 0.009 | 0.087 |
| 1 | fail_maic | kish_ess | 0.497 | 0.009 | 0.113 |
| 1 | fail_maic | unsupported_mass | 0.499 | 0.009 | 0.113 |
| 1 | fail_maic | max_weight_share | 0.497 | 0.008 | 0.113 |
| 1 | fail_maic | alignment_score | 0.657 | 0.008 | 0.113 |
| 1 | fail_gc_mat | kish_ess | 0.508 | 0.006 | 0.387 |
| 1 | fail_gc_mat | unsupported_mass | 0.501 | 0.005 | 0.387 |
| 1 | fail_gc_mat | max_weight_share | 0.498 | 0.005 | 0.387 |
| 1 | fail_gc_mat | alignment_score | 0.549 | 0.006 | 0.387 |
| 1.5 | fail_gc | kish_ess | 0.489 | 0.010 | 0.063 |
| 1.5 | fail_gc | unsupported_mass | 0.484 | 0.011 | 0.063 |
| 1.5 | fail_gc | max_weight_share | 0.497 | 0.011 | 0.063 |
| 1.5 | fail_gc | alignment_score | 0.579 | 0.010 | 0.063 |
| 1.5 | fail_maic | kish_ess | 0.491 | 0.009 | 0.086 |
| 1.5 | fail_maic | unsupported_mass | 0.501 | 0.009 | 0.086 |
| 1.5 | fail_maic | max_weight_share | 0.484 | 0.010 | 0.086 |
| 1.5 | fail_maic | alignment_score | 0.600 | 0.010 | 0.086 |
| 1.5 | fail_gc_mat | kish_ess | 0.520 | 0.007 | 0.143 |
| 1.5 | fail_gc_mat | unsupported_mass | 0.509 | 0.007 | 0.143 |
| 1.5 | fail_gc_mat | max_weight_share | 0.510 | 0.008 | 0.143 |
| 1.5 | fail_gc_mat | alignment_score | 0.551 | 0.008 | 0.143 |
| Inf | fail_gc | kish_ess | 0.498 | 0.012 | 0.052 |
| Inf | fail_gc | unsupported_mass | 0.490 | 0.011 | 0.052 |
| Inf | fail_gc | max_weight_share | 0.498 | 0.011 | 0.052 |
| Inf | fail_gc | alignment_score | 0.507 | 0.011 | 0.052 |
| Inf | fail_maic | kish_ess | 0.510 | 0.013 | 0.051 |
| Inf | fail_maic | unsupported_mass | 0.519 | 0.012 | 0.051 |
| Inf | fail_maic | max_weight_share | 0.487 | 0.013 | 0.051 |
| Inf | fail_maic | alignment_score | 0.503 | 0.011 | 0.051 |
| Inf | fail_gc_mat | kish_ess | 0.528 | 0.013 | 0.040 |
| Inf | fail_gc_mat | unsupported_mass | 0.505 | 0.013 | 0.040 |
| Inf | fail_gc_mat | max_weight_share | 0.504 | 0.013 | 0.040 |
| Inf | fail_gc_mat | alignment_score | 0.516 | 0.015 | 0.040 |

Second null control (orthogonal alignment, truncated support): G-computation |bias| at most 0.023, within 3 MCSE in 5 of 8 cells.

Positive control (full alignment, bent, truncation at 1): G-computation bias -0.141, -0.292; MAIC bias -0.151, -0.303.

Null control (full support): coverage 0.937 to 0.963, |bias| at most 0.013.

Extrapolation falsifier (linear modification, full alignment, truncation at 1): G-computation bias -0.003, 0.004.

Trimmed G-computation against the restricted estimand: |bias| at most 0.026, coverage 0.926 to 0.962.

