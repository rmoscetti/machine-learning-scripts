# =======================================================================
# Author: Roberto Moscetti
# Version: v1.1.0
# Date: 2026-10-21
# Description:
#   This script calculates the Cumulative Performance Index (CPI) using various
#   model performance metrics including calibration error, cross-validation error,
#   prediction error, bias metrics, and R² statistics. It employs Principal Component
#   Analysis (PCA) to assign data-dependent weights and combine the metrics into
#   a relative score for the pool of models supplied. See METHODS.md for details.
# =======================================================================

# metrics ratio
# This function compares a calibration value with a cross-validation or prediction value.
# It calculates the absolute value of (cv_pred/cal - 1).
metric_ratio <- function(cal, cv_pred){
  ratio <- abs(cv_pred/cal - 1)  # Compute relative difference ratio.
}

# metrics difference
# This function computes abs(cv_pred - cal) for the values supplied at the time of the call.
metric_diff <- function(cal, cv_pred){
  diff <- abs(cv_pred - cal)  # Compute absolute difference.
}

# CPI_dataframe
# This function calculates a Cumulative Performance Index (CPI) based on several input metrics.
# It processes error metrics (RMSEC, RMSECV, RMSEP), bias metrics (BIASC, BIASCV, BIASP), and R2 values,
# and then applies a principal component analysis (PCA) to weight the metrics before calculating the CPI.
CPI_dataframe <- function(ID, RMSEC, RMSECV = NA, RMSEP = NA, BIASC, BIASCV = NA, BIASP = NA, R2C, R2CV = NA, R2P = NA, BIAS_thres = NA, PCA_var = 0.95, scale = TRUE){
  
  # If length(RMSECV) != 1, compute abs(RMSECV / RMSEC - 1); this is a length check, not an NA check.
  if(!length(RMSECV) == 1){
    RMSEC_CV_ratio <- metric_ratio(RMSEC, RMSECV)
  } else {
    RMSEC_CV_ratio <- NA  # Otherwise, assign NA.
  }
  
  # If length(RMSEP) != 1, compute abs(RMSEP / RMSEC - 1).
  if(!length(RMSEP) == 1){
    RMSEC_P_ratio <- metric_ratio(RMSEC, RMSEP)
  } else {
    RMSEC_P_ratio <- NA  # Otherwise, assign NA.
  }
  
  # Process the BIASC metric if a bias threshold is provided and BIASC is not a single value.
  if (!is.na(BIAS_thres) & !length(BIASC) == 1){
    BIASC <- abs(BIASC)  # Use absolute values.
    # Set BIASC to NA if the strict '<' comparison contains no FALSE (including comparisons with NA).
    if (!(FALSE %in% (BIASC < BIAS_thres))) {
      BIASC <- NA
    } else {
      BIASC_raw <- BIASC  # Save absolute BIASC values before threshold replacement, not the signed input.
      BIASC[which(BIASC <= BIAS_thres)] <- BIAS_thres  # Replace values at or below the threshold.
      }
  }
  
  # Process the BIASCV metric similarly if a bias threshold is provided.
  if (!is.na(BIAS_thres) & !length(BIASCV) == 1){
    BIASCV <- abs(BIASCV)  # Use absolute values.
    # Set BIASCV to NA if the strict '<' comparison contains no FALSE (including comparisons with NA).
    if (!(FALSE %in% (BIASCV < BIAS_thres))) {
      BIASCV <- NA
    } else {
      BIASCV_raw <- BIASCV  # Save absolute BIASCV values before threshold replacement.
      BIASCV[which(BIASCV <= BIAS_thres)] <- BIAS_thres  # Replace values at or below the threshold.
    }
  }
  
  # Process the BIASP metric in the same manner if a bias threshold is provided.
  if (!is.na(BIAS_thres) & !length(BIASP) == 1){
    BIASP <- abs(BIASP)  # Use absolute values.
    # Set BIASP to NA if the strict '<' comparison contains no FALSE (including comparisons with NA).
    if (!(FALSE %in% (BIASP < BIAS_thres))) {
      BIASP <- NA
    } else {
      BIASP_raw <- BIASP  # Save absolute BIASP values before threshold replacement.
      BIASP[which(BIASP <= BIAS_thres)] <- BIAS_thres  # Replace values at or below the threshold.
      }
  }
  
  # Calculate both bias differences after all three bias-processing blocks.
  if(!length(BIASC) == 1){
    BIASC_CV_diff <- metric_diff(BIASC, BIASCV)
  } else {
    BIASC_CV_diff <- NA
  }

  # If length(BIASP) != 1, compare BIASC and BIASP after their bias-processing blocks.
  if(!length(BIASP) == 1){
    BIASC_P_diff <- metric_diff(BIASC, BIASP)
  } else {
    BIASC_P_diff <- NA
  }
  
  # If length(R2CV) != 1, compute abs(R2CV / R2C - 1).
  if(!length(R2CV) == 1){
    R2C_CV_ratio <- metric_ratio(R2C, R2CV)
  } else {
    R2C_CV_ratio <- NA
  }
  
  # If length(R2P) != 1, compute abs(R2P / R2C - 1).
  if(!length(R2P) == 1){
    R2C_P_ratio <- metric_ratio(R2C, R2P)
  } else {
    R2C_P_ratio <- NA
  }
  
  # Assemble 15 candidate indicators: nine original metrics and six derived indicators.
  newdata <- data.frame(RMSEC, RMSECV, RMSEC_CV_ratio, RMSEP, RMSEC_P_ratio,
                        BIASC, BIASCV, BIASC_CV_diff, BIASP, BIASC_P_diff, R2C_CV_ratio, R2C_P_ratio,
                        R2C, R2CV,  R2P)
   
  # Create a vector of ones (length 12) for later use in sign adjustments.
  ones <- rep(1,12)
  # Identify columns (from the first 15) that do not have any NA values.
  NA_check <- !apply(newdata[,1:15], 2, anyNA)
  # Keep only the columns without any NA values.
  newdata <- newdata[,NA_check]
  # Adjust the ones vector to match the columns kept (first 12 columns).
  ones <- ones[NA_check[1:12]]
  
  # Perform PCA on retained metrics before maximum normalization or direction inversion.
  if (scale == TRUE){
    pca <-prcomp(newdata, scale. = TRUE)  # Center (prcomp default) and scale to unit sample variance.
  } else {
    pca <-prcomp(newdata, center = TRUE)  # Otherwise, just center them.
  }
  pca.sum <- summary(pca)  # Summarize PCA results.
  
  # Extract explained proportions as reported by summary(pca), including its rounding.
  prop.var <- pca.sum$importance[2,]
  # Extract the cumulative variance explained.
  cum.var <- pca.sum$importance[3,]
  # Determine the minimum number of principal components needed to reach the desired cumulative variance (PCA_var).
  PCs <- min(which(cum.var >= PCA_var))
  # Restrict the explained variance proportions to the selected principal components.
  prop.var <- pca.sum$importance[2,1:PCs]
  
  # Calculate weights for the metrics based on the PCA loadings and explained variance.
  if (PCs != 1){
    # Multiply the absolute loadings by the proportion of variance for each component.
    wgs <- abs(sweep(pca$rotation[,1:PCs], 2, prop.var, '*'))
    # Normalize the weights so that the total sum equals one.
    wgs.norm <- wgs / sum(wgs)
    # Sum across components to obtain a single weight for each metric.
    wgs.norm <- apply(wgs.norm, 1, sum)
  } else {
    # If only one principal component, compute weights directly.
    wgs <- abs(pca$rotation[,1] * prop.var)
    wgs.norm <- wgs / sum(wgs)
  }
  
  # Normalize absolute metric values, including original R2 values, by each column's absolute maximum.
  metrics.max <- apply(abs(newdata), 2, max)  # Maximum absolute value for each retained metric.
  metrics.norm <- sweep(abs(newdata), 2, metrics.max, '/')  # In [0,1] only for finite, nonzero maxima.
  
  # Apply 1 - normalized value to retained indicators from the first 12 candidate columns.
  # Original R2C, R2CV and R2P columns are not inverted; their absolute values were normalized above.
  metrics.norm[,1:length(ones)] <- sweep(-1*metrics.norm[,1:length(ones)], 2, ones, '+')
  
  # Multiply each normalized metric by its corresponding weight.
  w.metrics <- sweep(metrics.norm, 2, wgs.norm, '*') 
  # Sum the weighted metrics row-wise to calculate the Cumulative Performance Index (CPI).
  newdata$CPI <- apply(w.metrics, 1, sum)
  
  # Add the ID column to the final data frame.
  newdata <- data.frame(ID, newdata)
  # Restore unthresholded absolute BIASC; BIASC_raw is undefined if its saving branch was skipped.
  newdata$BIASC <- BIASC_raw
  # Restore unthresholded absolute BIASCV when its current length is not 1; this requires BIASCV_raw.
  if (!length(BIASCV) == 1){ newdata$BIASCV <- BIASCV_raw }
  # Restore unthresholded absolute BIASP when its current length is not 1; this requires BIASP_raw.
  if (!length(BIASP) == 1){ newdata$BIASP <- BIASP_raw }
   
  # Return ID, retained metric columns, CPI and restored biases; PCA weights are not returned.
  return(newdata)
}

# CPI
# This is a wrapper function that calls CPI_dataframe and returns only the Cumulative Performance Index (CPI).
CPI <- function(ID, RMSEC, RMSECV = NA, RMSEP = NA, BIASC, BIASCV = NA, BIASP = NA, R2C, R2CV = NA, R2P = NA, BIAS_thres = NA, PCA_var = 0.95, scale = TRUE){
  # Compute the full data frame with CPI and other metrics.
  temp <- CPI_dataframe(ID, RMSEC, RMSECV, RMSEP, BIASC, BIASCV, BIASP, R2C, R2CV, R2P, BIAS_thres, PCA_var, scale)
  # Return only the CPI column.
  return(temp$CPI)
}
