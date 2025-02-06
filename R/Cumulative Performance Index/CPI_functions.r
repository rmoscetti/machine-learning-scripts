# =======================================================================
# Author: Roberto Moscetti
# Version: v1.0.0
# Date: 2025-02-06
# Description:
#   This script calculates the Composite Performance Index (CPI) using various
#   model performance metrics including calibration error, cross-validation error,
#   prediction error, bias metrics, and R² statistics. It employs Principal Component
#   Analysis (PCA) to assign weights to the metrics, thereby providing a single,
#   comprehensive index for model evaluation.
# =======================================================================

# metrics ratio
# This function computes the relative ratio difference between a calibration value and a prediction.
# It calculates the absolute value of (cv_pred/cal - 1).
metric_ratio <- function(cal, cv_pred){
  ratio <- abs(cv_pred/cal - 1)  # Compute relative difference ratio.
}

# metrics difference
# This function computes the absolute difference between a calibration value and a prediction.
metric_diff <- function(cal, cv_pred){
  diff <- abs(cv_pred - cal)  # Compute absolute difference.
}

# CPI_dataframe
# This function calculates a Composite Performance Index (CPI) based on several input metrics.
# It processes error metrics (RMSEC, RMSECV, RMSEP), bias metrics (BIASC, BIASCV, BIASP), and R2 values,
# and then applies a principal component analysis (PCA) to weight the metrics before calculating the CPI.
CPI_dataframe <- function(ID, RMSEC, RMSECV = NA, RMSEP = NA, BIASC, BIASCV = NA, BIASP = NA, R2C, R2CV = NA, R2P = NA, BIAS_thres = NA, PCA_var = 0.95, scale = TRUE){
  
  # If RMSECV is provided (i.e., not just a single NA), compute the ratio of RMSEC to RMSECV.
  if(!length(RMSECV) == 1){
    RMSEC_CV_ratio <- metric_ratio(RMSEC, RMSECV)
  } else {
    RMSEC_CV_ratio <- NA  # Otherwise, assign NA.
  }
  
  # If RMSEP is provided, compute the ratio of RMSEC to RMSEP.
  if(!length(RMSEP) == 1){
    RMSEC_P_ratio <- metric_ratio(RMSEC, RMSEP)
  } else {
    RMSEC_P_ratio <- NA  # Otherwise, assign NA.
  }
  
  # Process the BIASC metric if a bias threshold is provided and BIASC is not a single value.
  if (!is.na(BIAS_thres) & !length(BIASC) == 1){
    BIASC <- abs(BIASC)  # Use absolute values.
    # If all BIASC values are below the bias threshold, set BIASC to NA.
    if (!(FALSE %in% (BIASC < BIAS_thres))) {
      BIASC <- NA
    } else {
      BIASC_raw <- BIASC  # Save the original BIASC values.
      BIASC[which(BIASC <= BIAS_thres)] <- BIAS_thres  # Replace values below threshold with the threshold value.
      }
  }
  
  # Compute the difference between BIASC and BIASCV if BIASC is provided.
  if(!length(BIASC) == 1){
    BIASC_CV_diff <- metric_diff(BIASC, BIASCV)
  } else {
    BIASC_CV_diff <- NA
  }
  
  # Process the BIASCV metric similarly if a bias threshold is provided.
  if (!is.na(BIAS_thres) & !length(BIASCV) == 1){
    BIASCV <- abs(BIASCV)  # Use absolute values.
    # If all BIASCV values are below the bias threshold, set BIASCV to NA.
    if (!(FALSE %in% (BIASCV < BIAS_thres))) {
      BIASCV <- NA
    } else {
      BIASCV_raw <- BIASCV  # Save the original BIASCV values.
      BIASCV[which(BIASCV <= BIAS_thres)] <- BIAS_thres  # Replace values below threshold.
    }
  }
  
  # Process the BIASP metric in the same manner if a bias threshold is provided.
  if (!is.na(BIAS_thres) & !length(BIASP) == 1){
    BIASP <- abs(BIASP)  # Use absolute values.
    # If all BIASP values are below the bias threshold, set BIASP to NA.
    if (!(FALSE %in% (BIASP < BIAS_thres))) {
      BIASP <- NA
    } else {
      BIASP_raw <- BIASP  # Save the original BIASP values.
      BIASP[which(BIASP <= BIAS_thres)] <- BIAS_thres  # Replace values below threshold.
      }
  }
  
  # Compute the difference between BIASC and BIASP if BIASP is provided.
  if(!length(BIASP) == 1){
    BIASC_P_diff <- metric_diff(BIASC, BIASP)
  } else {
    BIASC_P_diff <- NA
  }
  
  # Compute the ratio of R2C to R2CV if R2CV is provided.
  if(!length(R2CV) == 1){
    R2C_CV_ratio <- metric_ratio(R2C, R2CV)
  } else {
    R2C_CV_ratio <- NA
  }
  
  # Compute the ratio of R2C to R2P if R2P is provided.
  if(!length(R2P) == 1){
    R2C_P_ratio <- metric_ratio(R2C, R2P)
  } else {
    R2C_P_ratio <- NA
  }
  
  # Combine all the input metrics and computed metrics into a data frame.
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
  
  # Perform Principal Component Analysis (PCA) on the cleaned metrics.
  if (scale == TRUE){
    pca <-prcomp(newdata, scale. = TRUE)  # Scale variables if 'scale' is TRUE.
  } else {
    pca <-prcomp(newdata, center = TRUE)  # Otherwise, just center them.
  }
  pca.sum <- summary(pca)  # Summarize PCA results.
  
  # Extract the proportion of variance explained by each principal component.
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
  
  # Normalize each metric by dividing by its maximum absolute value.
  metrics.max <- apply(abs(newdata), 2, max)  # Maximum value for each metric.
  metrics.norm <- sweep(abs(newdata), 2, metrics.max, '/')  # Scale metrics to [0,1].
  
  # Adjust the sign of the first set of metrics using the ones vector.
  # This flips the sign (multiplying by -1) and then adds 1, standardizing the direction.
  metrics.norm[,1:length(ones)] <- sweep(-1*metrics.norm[,1:length(ones)], 2, ones, '+')
  
  # Multiply each normalized metric by its corresponding weight.
  w.metrics <- sweep(metrics.norm, 2, wgs.norm, '*') 
  # Sum the weighted metrics row-wise to calculate the Composite Performance Index (CPI).
  newdata$CPI <- apply(w.metrics, 1, sum)
  
  # Add the ID column to the final data frame.
  newdata <- data.frame(ID, newdata)
  # Restore the original BIASC values to the data frame.
  newdata$BIASC <- BIASC_raw
  # Restore the original BIASCV values if available.
  if (!length(BIASCV) == 1){ newdata$BIASCV <- BIASCV_raw }
  # Restore the original BIASP values if available.
  if (!length(BIASP) == 1){ newdata$BIASP <- BIASP_raw }
   
  # Return the data frame containing all metrics and the computed CPI.
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
