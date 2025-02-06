# Cumulative Performance Index (CPI) Calculation in R

This project provides a set of R functions designed to compute a **Cumulative Performance Index (CPI)** from multiple model performance metrics. The CPI is derived from error measurements (e.g., calibration error, cross-validation error, prediction error), bias values, and R² statistics. By leveraging **Principal Component Analysis (PCA)**, the code weights and combines these metrics into a single, informative index for model evaluation.

## Overview

The repository includes the following functions:

- **`metric_ratio`**  
  Computes the relative ratio difference between a calibration value and a prediction.  
  _Formula:_ `abs(cv_pred/cal - 1)`

- **`metric_diff`**  
  Computes the absolute difference between a calibration value and a prediction.  
  _Formula:_ `abs(cv_pred - cal)`

- **`CPI_dataframe`**  
  Combines multiple input metrics (errors, biases, and R² values) into a data frame and performs PCA on these metrics. The PCA-derived weights are then used to calculate the Cumulative Performance Index (CPI). This function also handles data quality by checking for `NA` values and applying bias thresholds.

- **`CPI`**  
  A wrapper function for `CPI_dataframe` that returns only the computed CPI values for each observation.

## Features

- **Metric Calculations:**  
  Calculates ratios and differences for error and bias metrics to standardize performance comparisons.

- **Bias Handling:**  
  Applies a user-defined threshold to bias metrics to ensure only meaningful differences contribute to the index.

- **Principal Component Analysis (PCA):**  
  Uses PCA to weight individual metrics based on their explained variance, thereby reducing dimensionality and emphasizing the most important performance aspects.

- **Customizable Parameters:**  
  Users can specify whether to scale data during PCA, set bias thresholds, and define the desired proportion of cumulative variance to be captured by the principal components.

## Requirements

- **R:**  
  The code is written in R. Ensure that you have R installed on your system.  
  [Download R](https://cran.r-project.org/)

- **Base R Packages:**  
  The implementation uses base R functions such as `prcomp` for PCA, so no additional packages are required.

## Installation

1. **Clone the repository:**
```bash
git clone https://github.com/rmoscetti/machine-learning-scripts/tree/main/R/Cumulative%20Performance%20Index
```

2. **Open the project in your preferred R environment (e.g., RStudio).**

3. **Source the script:**
In your R console or script, run:
```
source("path/to/CPI_functions.r")
```

4. **Usage**
After sourcing the script, you can compute the CPI for your data by calling the `CPI` function. Below is an example:
```
# Example data (replace with your own values)
ID <- 1:10
RMSEC <- runif(10, min = 1, max = 2)        # Example calibration errors
RMSECV <- runif(10, min = 1.5, max = 2.5)     # Example cross-validation errors
RMSEP <- runif(10, min = 1.8, max = 2.8)      # Example prediction errors
BIASC <- runif(10, min = 0.05, max = 0.15)    # Example calibration bias values
BIASCV <- runif(10, min = 0.06, max = 0.16)   # Example cross-validation bias values
BIASP <- runif(10, min = 0.07, max = 0.17)    # Example prediction bias values
R2C <- runif(10, min = 0.8, max = 0.95)       # Example calibration R² values
R2CV <- runif(10, min = 0.75, max = 0.93)     # Example cross-validation R² values
R2P <- runif(10, min = 0.7, max = 0.9)        # Example prediction R² values

# Set a bias threshold (if applicable) and PCA variance capture level
BIAS_thres <- 0.1
PCA_var <- 0.95
scale_data <- TRUE

# Compute the Composite Performance Index (CPI)
cpi_values <- CPI(ID, RMSEC, RMSECV, RMSEP, BIASC, BIASCV, BIASP, R2C, R2CV, R2P, BIAS_thres, PCA_var, scale_data)

# View the CPI values
print(cpi_values)
```

## Contributing
Contributions to enhance functionality, improve documentation, or optimize performance are welcome. Please fork the repository and submit a pull request with your proposed changes.

## License
This project is licensed under the MIT License. See the LICENSE file for details.

## Contact
For any questions or suggestions, please contact rmoscetti@unitus.it