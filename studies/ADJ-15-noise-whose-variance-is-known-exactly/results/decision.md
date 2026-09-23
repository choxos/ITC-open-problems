# Decision

**Refuting sentence (noise negligible at usable budgets, epsilon >= 1 and target n >= 150): FAILS.**

| target n | epsilon | released | modification | infeasible | coverage ignored | coverage propagated | coverage non-private |
|---:|---:|---|---|---:|---:|---:|---:|
| 40 | 0.5 | means | linear | 0.052 | 0.796 | 0.988 | 0.943 |
| 150 | 0.5 | means | linear | 0.000 | 0.918 | 0.959 | 0.952 |
| 500 | 0.5 | means | linear | 0.000 | 0.948 | 0.951 | 0.948 |
| 40 | 1 | means | linear | 0.003 | 0.879 | 0.967 | 0.947 |
| 150 | 1 | means | linear | 0.000 | 0.939 | 0.950 | 0.949 |
| 500 | 1 | means | linear | 0.000 | 0.947 | 0.948 | 0.944 |
| 40 | 4 | means | linear | 0.000 | 0.947 | 0.957 | 0.955 |
| 150 | 4 | means | linear | 0.000 | 0.952 | 0.953 | 0.953 |
| 500 | 4 | means | linear | 0.000 | 0.947 | 0.947 | 0.948 |
| 40 | 0.5 | means_sds | linear | 0.843 | 0.758 | 1.000 | 0.954 |
| 150 | 0.5 | means_sds | linear | 0.480 | 0.900 | 0.992 | 0.952 |
| 500 | 0.5 | means_sds | linear | 0.045 | 0.928 | 0.959 | 0.944 |
| 40 | 1 | means_sds | linear | 0.670 | 0.833 | 0.997 | 0.949 |
| 150 | 1 | means_sds | linear | 0.178 | 0.927 | 0.968 | 0.947 |
| 500 | 1 | means_sds | linear | 0.002 | 0.955 | 0.957 | 0.949 |
| 40 | 4 | means_sds | linear | 0.171 | 0.908 | 0.978 | 0.941 |
| 150 | 4 | means_sds | linear | 0.001 | 0.924 | 0.931 | 0.938 |
| 500 | 4 | means_sds | linear | 0.000 | 0.951 | 0.951 | 0.949 |
| 40 | 0.5 | means | quadratic | 0.032 | 0.730 | 0.982 | 0.921 |
| 150 | 0.5 | means | quadratic | 0.000 | 0.888 | 0.967 | 0.934 |
| 500 | 0.5 | means | quadratic | 0.000 | 0.931 | 0.941 | 0.934 |
| 40 | 1 | means | quadratic | 0.001 | 0.817 | 0.966 | 0.932 |
| 150 | 1 | means | quadratic | 0.000 | 0.920 | 0.943 | 0.933 |
| 500 | 1 | means | quadratic | 0.000 | 0.926 | 0.931 | 0.930 |
| 40 | 4 | means | quadratic | 0.000 | 0.902 | 0.926 | 0.925 |
| 150 | 4 | means | quadratic | 0.000 | 0.943 | 0.944 | 0.942 |
| 500 | 4 | means | quadratic | 0.000 | 0.935 | 0.935 | 0.935 |
| 40 | 0.5 | means_sds | quadratic | 0.872 | 0.734 | 1.000 | 0.934 |
| 150 | 0.5 | means_sds | quadratic | 0.446 | 0.856 | 0.989 | 0.957 |
| 500 | 0.5 | means_sds | quadratic | 0.057 | 0.929 | 0.959 | 0.945 |
| 40 | 1 | means_sds | quadratic | 0.697 | 0.749 | 1.000 | 0.950 |
| 150 | 1 | means_sds | quadratic | 0.187 | 0.883 | 0.977 | 0.962 |
| 500 | 1 | means_sds | quadratic | 0.000 | 0.943 | 0.952 | 0.951 |
| 40 | 4 | means_sds | quadratic | 0.185 | 0.917 | 0.982 | 0.969 |
| 150 | 4 | means_sds | quadratic | 0.000 | 0.952 | 0.958 | 0.950 |
| 500 | 4 | means_sds | quadratic | 0.000 | 0.951 | 0.951 | 0.951 |

RMSE, propagated, means only against means and second moments:

| target n | epsilon | modification | means | means and second moments |
|---:|---:|---|---:|---:|
| 150 | 0.5 | linear | 0.215 | 0.264 |
| 150 | 0.5 | quadratic | 0.300 | 0.357 |
| 150 | 1 | linear | 0.191 | 0.201 |
| 150 | 1 | quadratic | 0.250 | 0.240 |
| 150 | 4 | linear | 0.180 | 0.169 |
| 150 | 4 | quadratic | 0.229 | 0.171 |
| 150 | Inf | linear | 0.186 | 0.163 |
| 150 | Inf | quadratic | 0.224 | 0.169 |
| 40 | 0.5 | linear | 0.477 | 0.735 |
| 40 | 0.5 | quadratic | 0.735 | 0.973 |
| 40 | 1 | linear | 0.275 | 0.492 |
| 40 | 1 | quadratic | 0.467 | 0.534 |
| 40 | 4 | linear | 0.193 | 0.203 |
| 40 | 4 | quadratic | 0.262 | 0.229 |
| 40 | Inf | linear | 0.185 | 0.166 |
| 40 | Inf | quadratic | 0.242 | 0.172 |
| 500 | 0.5 | linear | 0.187 | 0.184 |
| 500 | 0.5 | quadratic | 0.236 | 0.199 |
| 500 | 1 | linear | 0.181 | 0.158 |
| 500 | 1 | quadratic | 0.230 | 0.176 |
| 500 | 4 | linear | 0.182 | 0.158 |
| 500 | 4 | quadratic | 0.233 | 0.163 |
| 500 | Inf | linear | 0.182 | 0.155 |
| 500 | Inf | quadratic | 0.236 | 0.169 |

