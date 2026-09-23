# Decision

**Registered primary.** Balanced selection accuracy (separate at variance ratio 5, shared at ratio 1) reaches 0.8 at 40 studies per class (AIC), NA (BIC), NA (likelihood-ratio test); NA means not within 40.

| studies per class | accuracy AIC | accuracy BIC | accuracy LRT | separate chosen at ratio 5 (AIC) | separate chosen at ratio 2 (AIC) | separate chosen when shared is true (AIC) |
|---:|---:|---:|---:|---:|---:|---:|
| 2 | 0.507 | 0.539 | 0.500 | 0.019 | 0.009 | 0.006 |
| 3 | 0.537 | 0.555 | 0.503 | 0.098 | 0.040 | 0.024 |
| 5 | 0.568 | 0.566 | 0.518 | 0.184 | 0.087 | 0.049 |
| 8 | 0.605 | 0.584 | 0.550 | 0.295 | 0.119 | 0.086 |
| 12 | 0.650 | 0.610 | 0.585 | 0.404 | 0.149 | 0.103 |
| 20 | 0.712 | 0.668 | 0.660 | 0.568 | 0.190 | 0.143 |
| 40 | 0.821 | 0.766 | 0.784 | 0.789 | 0.271 | 0.146 |

