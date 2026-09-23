# Decision

**Failure one (overdispersion breaks the interval, not the estimate): NOT CONFIRMED.** Poisson rate-ratio bias within 3 MCSE and model-based coverage below 0.93 in overdispersed cells, sandwich coverage at least 0.93: Poisson coverage 0.846, 0.728, 0.808, 0.610; sandwich 0.926, 0.940, 0.944, 0.948.

**Failure two (a differing structural-zero fraction biases the transported absolute rate): CONFIRMED.** Absolute log-rate bias for Poisson, negative binomial and zero-inflated fits: -0.564 to 0.546.

Rate ratio without effect modification (b = 0) when the zero fraction differs: bias within 3 MCSE in all: TRUE (max |bias| 0.007). With b = 0.4: max |bias| 0.113.

Zero part recalibrated to the target's reported zero proportion: absolute-rate bias -0.041 to 0.254; rate-ratio bias -0.011 to 0.152.

