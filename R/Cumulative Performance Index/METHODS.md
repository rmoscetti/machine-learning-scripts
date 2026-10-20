# Cumulative Performance Index: method

## 1. Purpose

The Cumulative Performance Index (CPI) combines model-performance indicators into one score. Principal component analysis (PCA) provides data-driven weights, and a weighted sum combines indicators with a common performance direction. The score is relative to the evaluated model pool.

This document describes algorithm version **v1.1.0** in [`CPI_functions.r`](CPI_functions.r). It is repository documentation, not manuscript supplementary material. See [README.md](README.md) for usage.

## 2. Performance indicators

Metrics are supplied for the same response variable, using consistent definitions and data-partition procedures across models. The script does not estimate them from response data. Calibration, cross-validation, and prediction are denoted by C, CV, and P, respectively.

| Indicator | Definition or meaning |
| --- | --- |
| `RMSEC` | Calibration root mean squared error |
| `RMSECV` | Cross-validation root mean squared error |
| `RMSEP` | Prediction root mean squared error |
| `BIASC` | Calibration bias |
| `BIASCV` | Cross-validation bias |
| `BIASP` | Prediction bias |
| `R2C` | Calibration coefficient of determination |
| `R2CV` | Cross-validation coefficient of determination |
| `R2P` | Prediction coefficient of determination |
| Calibration–CV RMSE deviation | `abs(RMSECV / RMSEC - 1)` |
| Calibration–prediction RMSE deviation | `abs(RMSEP / RMSEC - 1)` |
| Calibration–CV R² deviation | `abs(R2CV / R2C - 1)` |
| Calibration–prediction R² deviation | `abs(R2P / R2C - 1)` |
| Calibration–CV bias difference | `abs(BIASC - BIASCV)`, after bias treatment |
| Calibration–prediction bias difference | `abs(BIASC - BIASP)`, after bias treatment |

There are **up to 15 indicators with CV metrics and up to 9 without CV metrics**. Without CV, the three original CV metrics and their three derived indicators are absent. Columns containing any `NA` or `NaN` are excluded before PCA and scoring; bias treatment can also reduce the retained set. No missing values are imputed.

## 3. Bias threshold

With a supplied threshold `BIAS_thres`, each available bias vector (`BIASC`, `BIASCV`, and `BIASP`) is first converted to absolute values. For complete data, if all values are **strictly below** the threshold, that bias metric is excluded. Otherwise, values **less than or equal to** the threshold are replaced by the threshold, and larger values are retained. The threshold must be chosen and justified for the analysis; no value is prescribed here.

After all three bias vectors have been treated, the differences are calculated as:

```text
BIASC_CV_diff = abs(BIASC - BIASCV)
BIASC_P_diff  = abs(BIASC - BIASP)
```

In these expressions, the bias names refer to their absolute, threshold-treated values. Thus both differences compare biases processed in the same way. If an involved bias is excluded, its difference is unavailable and is removed through the missing-value filter.

## 4. PCA-derived weights

Let $X=(x_{ij})$ contain the retained indicators, with one row per model and one column per indicator. PCA is applied to this matrix **before** maximum normalization or direction adjustment. The columns are centred and, with the default `scale = TRUE`, scaled to unit sample variance. With `scale = FALSE`, they are only centred. PCA is calculated using `prcomp`.

The minimum number $K$ of principal components reaching the cumulative explained-variance target `PCA_var` is retained; the default target is **0.95**. Let $l_{jk}$ be the loading of indicator $j$ on PC $k$, and let $q_k$ be that PC's explained-variance proportion as reported by the PCA summary. Indicator weights are obtained from absolute loadings weighted by these proportions:

$$
w_j = \frac{\sum_{k=1}^{K}|l_{jk}|q_k}
{\sum_{h=1}^{p}\sum_{k=1}^{K}|l_{hk}|q_k},
\qquad \sum_{j=1}^{p}w_j=1,
$$

where $p$ is the number of retained indicators. These weights describe the statistical structure of the indicators in the evaluated pool.

## 5. Normalization and CPI

Each retained indicator is normalized by its maximum absolute value across the evaluated models:

$$
u_{ij}=\frac{|x_{ij}|}{\max_r|x_{rj}|}.
$$

For RMSEs, biases, relative deviations, and bias differences, lower values are preferred, so the directional indicator is $v_{ij}=1-u_{ij}$. For the original `R2C`, `R2CV`, and `R2P`, no inversion is applied: $v_{ij}=u_{ij}$. Absolute values are nevertheless used for these R² metrics too; negative R² values therefore lose their sign.

The CPI for model $i$ is

$$
\mathrm{CPI}_i=\sum_{j=1}^{p}w_jv_{ij}.
$$

**Higher CPI values indicate better overall performance within the evaluated model pool**, subject to the sign convention above. When calculations are finite, maxima are nonzero, and weights are valid, the score lies between 0 and 1; these endpoints are not universal performance standards.

## 6. Interpretation and limitations

- Scores depend on the model pool, which determines PCA weights and normalization maxima. CPI values from different pools are not directly comparable.
- Scores also depend on the retained indicator set. CPI values based on different indicator sets are not directly comparable.
- PCA-derived weights reflect statistical structure, not the intrinsic scientific importance of each metric.
- When prediction-set metrics contribute to a CPI used to rank or select models, that set contributes to selection and is not a completely independent final validation set.
- The CPI alone does not quantify uncertainty, establish statistical significance, or provide independent predictive validation.

For reproducibility, record the algorithm version and repository commit, R session information, model pool and order, metric definitions and values, data-partition procedures, retained indicators, threshold and rationale, and all function arguments.

## 7. Implementation notes

Use aligned numeric vectors with sufficient variation for PCA. Constant columns can prevent scaled PCA, and zero denominators, zero normalization maxima, or non-finite values are not automatically resolved. Supply and document a bias threshold: the current implementation can fail with the default `BIAS_thres = NA` or when all calibration biases are excluded. Returned bias columns contain absolute values before threshold replacement, so they need not match the values used in scoring. PCA weights and intermediate calculations are not returned by the functions.
