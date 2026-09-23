# Decision

**Refuting sentence (the interval-censored likelihood covers the practically important case): FAILS.** Interval-censored bias with missed detections (sensitivity 0.85 or 0.7): 0.25 to 0.94 months; with perfect detection: -0.05 to 0.01.

| detection sensitivity | visiting | true difference | method | bias | MCSE | RMSE |
|---:|---|---:|---|---:|---:|---:|
| 1.00 | regular | 0.00 | naive | 0.416 | 0.020 | 0.764 |
| 1.00 | regular | 0.00 | midpoint | 0.033 | 0.021 | 0.674 |
| 1.00 | regular | 0.00 | interval | 0.002 | 0.021 | 0.667 |
| 0.85 | regular | 0.00 | naive | 0.749 | 0.021 | 1.006 |
| 0.85 | regular | 0.00 | midpoint | 0.376 | 0.022 | 0.799 |
| 0.85 | regular | 0.00 | interval | 0.385 | 0.022 | 0.792 |
| 0.70 | regular | 0.00 | naive | 1.267 | 0.021 | 1.426 |
| 0.70 | regular | 0.00 | midpoint | 0.913 | 0.022 | 1.142 |
| 0.70 | regular | 0.00 | interval | 0.944 | 0.021 | 1.156 |
| 1.00 | informative | 0.00 | naive | 0.193 | 0.021 | 0.676 |
| 1.00 | informative | 0.00 | midpoint | 0.021 | 0.021 | 0.672 |
| 1.00 | informative | 0.00 | interval | -0.024 | 0.021 | 0.659 |
| 0.85 | informative | 0.00 | naive | 0.468 | 0.020 | 0.793 |
| 0.85 | informative | 0.00 | midpoint | 0.313 | 0.021 | 0.737 |
| 0.85 | informative | 0.00 | interval | 0.302 | 0.021 | 0.718 |
| 0.70 | informative | 0.00 | naive | 0.912 | 0.021 | 1.120 |
| 0.70 | informative | 0.00 | midpoint | 0.786 | 0.022 | 1.036 |
| 0.70 | informative | 0.00 | interval | 0.796 | 0.021 | 1.030 |
| 1.00 | regular | 1.59 | naive | 0.298 | 0.020 | 0.705 |
| 1.00 | regular | 1.59 | midpoint | 0.033 | 0.021 | 0.674 |
| 1.00 | regular | 1.59 | interval | 0.009 | 0.021 | 0.659 |
| 0.85 | regular | 1.59 | naive | 0.584 | 0.021 | 0.881 |
| 0.85 | regular | 1.59 | midpoint | 0.330 | 0.022 | 0.770 |
| 0.85 | regular | 1.59 | interval | 0.334 | 0.021 | 0.749 |
| 0.70 | regular | 1.59 | naive | 1.079 | 0.020 | 1.256 |
| 0.70 | regular | 1.59 | midpoint | 0.847 | 0.022 | 1.086 |
| 0.70 | regular | 1.59 | interval | 0.867 | 0.021 | 1.090 |
| 1.00 | informative | 1.59 | naive | 0.043 | 0.020 | 0.636 |
| 1.00 | informative | 1.59 | midpoint | -0.008 | 0.021 | 0.663 |
| 1.00 | informative | 1.59 | interval | -0.053 | 0.021 | 0.650 |
| 0.85 | informative | 1.59 | naive | 0.295 | 0.020 | 0.706 |
| 0.85 | informative | 1.59 | midpoint | 0.262 | 0.022 | 0.724 |
| 0.85 | informative | 1.59 | interval | 0.249 | 0.021 | 0.697 |
| 0.70 | informative | 1.59 | naive | 0.663 | 0.021 | 0.934 |
| 0.70 | informative | 1.59 | midpoint | 0.657 | 0.022 | 0.952 |
| 0.70 | informative | 1.59 | interval | 0.672 | 0.022 | 0.955 |

