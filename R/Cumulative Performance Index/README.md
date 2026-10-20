# Cumulative Performance Index (CPI) in R

## Purpose

The Cumulative Performance Index (CPI) combines several model-performance indicators into one score, using principal component analysis (PCA) to derive data-driven weights. **Higher CPI values indicate better overall performance within the evaluated model pool.**

The mathematical definition is provided in [METHODS.md](METHODS.md).

## Inputs and derived indicators

Supply one aligned value per model for each available metric, calculated consistently for the same response variable:

| Metric | Calibration | Cross-validation | Prediction |
| --- | --- | --- | --- |
| Root mean squared error | `RMSEC` | `RMSECV` | `RMSEP` |
| Bias | `BIASC` | `BIASCV` | `BIASP` |
| Coefficient of determination | `R2C` | `R2CV` | `R2P` |

The script accepts these precomputed metrics and constructs six additional indicators:

- `abs(RMSECV / RMSEC - 1)`
- `abs(RMSEP / RMSEC - 1)`
- `abs(R2CV / R2C - 1)`
- `abs(R2P / R2C - 1)`
- `abs(BIASC - BIASCV)`
- `abs(BIASC - BIASP)`

**Both bias differences are calculated after taking absolute bias values and applying the supplied bias threshold to the biases involved.** The bias names in these two expressions refer to those processed values.

There are **up to 15 indicators with cross-validation metrics and up to 9 without them**. Columns containing missing values are excluded; unavailable metrics and bias-threshold exclusions can therefore reduce these counts.

## Procedure in brief

1. **Treat biases:** take absolute values and apply the user-supplied threshold. For complete data, a bias metric is excluded if all magnitudes are strictly below the threshold; otherwise values at or below it are replaced by the threshold.
2. **Construct indicators:** combine the original metrics, relative deviations, and differences between processed biases; exclude columns containing `NA` or `NaN`.
3. **Run PCA:** centre the retained indicators and, by default, scale them to unit variance. Retain the fewest PCs reaching the cumulative variance target `PCA_var` (default `0.95`).
4. **Derive weights:** combine absolute loadings weighted by each selected PC's explained-variance proportion, and normalize the metric weights to sum to one.
5. **Normalize and align direction:** divide absolute indicator values by their column maxima. Apply `1 - normalized value` to lower-is-better indicators, but not to the original R² metrics.
6. **Calculate CPI:** sum the weighted indicators for each model.

## Usage

R and its standard `stats` package are sufficient; no contributed packages are required. From the repository root:

```r
source("R/Cumulative Performance Index/CPI_functions.r")
```

The main function has the following arguments:

```r
CPI_dataframe(ID, RMSEC, RMSECV = NA, RMSEP = NA,
              BIASC, BIASCV = NA, BIASP = NA,
              R2C, R2CV = NA, R2P = NA,
              BIAS_thres = NA, PCA_var = 0.95, scale = TRUE)
```

`ID` identifies models. Calibration metrics are required; CV and prediction metrics default to `NA`. Supply and document `BIAS_thres` in the units of the bias inputs. `PCA_var` sets the cumulative variance target; `scale = FALSE` requests centring without variance scaling. See the brief [implementation notes](METHODS.md#7-implementation-notes) before running an analysis.

This schematic example assumes that `metrics` contains the input columns and that `bias_threshold` has been specified for the analysis; it supplies no scientific data or recommended threshold:

```r
result <- CPI_dataframe(
  ID = metrics$ID,
  RMSEC = metrics$RMSEC, RMSECV = metrics$RMSECV, RMSEP = metrics$RMSEP,
  BIASC = metrics$BIASC, BIASCV = metrics$BIASCV, BIASP = metrics$BIASP,
  R2C = metrics$R2C, R2CV = metrics$R2CV, R2P = metrics$R2P,
  BIAS_thres = bias_threshold
)
result$CPI
```

Omit `RMSECV`, `BIASCV`, and `R2CV` when CV metrics are unavailable. `CPI_dataframe` returns model identifiers, metric columns, and CPI values in input order. `CPI(...)` accepts the same arguments and returns only the CPI vector. The helpers `metric_ratio` and `metric_diff` calculate absolute relative deviations and absolute differences, respectively.

## Interpretation and limits

- The CPI is relative to the evaluated model pool. Including or removing models can change scores and rankings; **scores from different pools are not directly comparable**.
- The retained indicator set also affects the score. **Scores based on different indicator sets are not directly comparable**.
- PCA weights reflect the statistical structure of the supplied metrics, not their intrinsic scientific importance.
- If prediction-set metrics enter a CPI used for ranking or selection, that prediction set contributes to selection and is not a completely independent final validation set.
- Normalization uses absolute values, including for original R² metrics. Negative R² values lose their sign, which limits the usual higher-is-better interpretation.
- The CPI alone does not provide uncertainty, statistical significance, or independent predictive validation.

For reproducibility, retain the repository commit and algorithm version, R session information, model pool and order, metric definitions and values, data-partition procedures, retained indicator set, threshold and its rationale, and all function arguments. See [METHODS.md](METHODS.md) for the mathematical definition and operational requirements.

## Contact

Roberto Moscetti: rmoscetti@unitus.it
