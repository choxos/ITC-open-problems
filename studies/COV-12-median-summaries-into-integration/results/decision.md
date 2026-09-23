# Decision

**Refuting sentence (contrast error is a monotone function of mean-recovery error): holds under the identity link (slope 1.000, R^2 1.000); fails under the logit link (slope 0.246, R^2 0.597).**

Reconstruction error is measured net of the sample's own sampling error (error minus that of integrating over the actual target sample).

Largest normal-reconstruction biases:

| link | skew | summary | n | beta | bias | RMSE |
|---|---:|---|---:|---:|---:|---:|
| identity | 1.0 | range | 1000 | 0.8 | 2.150 | 2.639 |
| identity | 1.0 | range | 200 | 0.8 | 1.145 | 1.355 |
| identity | 0.5 | range | 1000 | 0.8 | 0.922 | 0.978 |
| identity | 1.0 | range | 1000 | 0.3 | 0.799 | 0.905 |
| identity | 0.5 | range | 200 | 0.8 | 0.582 | 0.652 |

Quantile-matched lognormal: max |bias| 0.092 over all cells; normal: 2.150.

