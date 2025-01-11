function pls_parallel(file_input, file_output)
% PLS_PARALLEL: A MATLAB function to perform parallel PLS calibration and prediction.
% Author: Roberto Moscetti
% Version: 0.2
% Date: 2025-01-11
%
% This script is designed for use with the PLS_Toolbox.
% It processes data from the provided input file, applies spectral pretreatments, and
% performs PLS calibration, cross-validation, and prediction using MATLAB's Parallel
% Computing Toolbox to speed up computations.
% INPUTS:
%   file_input  - MAT file containing calibration and prediction datasets.
%   file_output - MAT file where the computed results will be saved.

    clc; % Clear command window
    load pretreatment_list.mat % Load the pretreatment list file
    load(file_input) % Load the input data file

% Data preparation and conversion to dataset format
    % Uncomment if needed to split dataset
    % [X_cal, X_test, Y_cal, Y_test] = cal_test_split(X, Y, 0.25, 1);
    
    X_cal = dataset(X_cal); % Calibration data
    X_pred = dataset(X_pred); % Prediciton data
    
    % Additional test datasets (Commented out)
    % Xpred_2 = dataset(Xpred_2);
    % Xpred_3 = dataset(Xpred_3);

    Y_cal = dataset(Y_cal); % Calibration Y
    Y_pred = dataset(Y_pred); % Prediction Y
    
    % Additional test label datasets (Commented out)
    % Ypred_2 = dataset(Ypred_2);
    % Ypred_3 = dataset(Ypred_3);

    % Initialize parameters
    n = length(mynew_methods); % Number of pretreatments to test
    LVs = 20; % Maximum number of latent variables (LVs)
    k = 1; % Number of prediction sets

    % Initialize result storage variables
    results.RMSE.CAL = zeros(n, LVs); % Root Mean Square Error (Calibration)
    results.RMSE.CROSSV = zeros(n, LVs); % RMSE (Cross-validation)
    results.RMSE.PRED = zeros(n, k); % RMSE (Prediction)
    results.BIAS.CAL = zeros(n, LVs); % Bias (Calibration)
    results.BIAS.CROSSV = zeros(n, LVs); % Bias (Cross-validation)
    results.BIAS.PRED = zeros(n, k); % Bias (Prediction)
    results.R2.CAL = zeros(n, LVs); % R-squared (Calibration)
    results.R2.CROSSV = zeros(n, LVs); % R-squared (Cross-validation)
    results.R2.PRED = zeros(n, k); % R-squared (Prediction)

    % Mean results storage (if multiple prediction sets)
    if k > 1
        results.MEAN.RMSEP = zeros(n, 1); % Mean RMSE (Prediction)
        results.MEAN.BIASP = zeros(n, 1); % Mean Bias (Prediction)
        results.MEAN.R2P = zeros(n, 1); % Mean R-squared (Prediction)
    end

    % List of pretreatments to test
    results.pret_list = [181:215, 227:248, 260:281, 293:325, ...
                         337:358, 360:394, 406:427, 439:460, ...
                         472:504, 516:537];

    c = 0; % Counter for progress tracking
    for i = results.pret_list
        c = c + 1;

        % Spectral pretreatment settings (calibration)
        xprepro = mynew_methods{1, i}; % X pretreatment method
        yprepro = mynew_methods{2, i}; % Y pretreatment method
        options = pls('options'); % PLS options
        options.plots = 'none'; % Disable plots
        options.display = 'off'; % Disable display

        % Spectral pretreatment settings (cross-validation)
        optionscv = crossval('options'); % Cross-validation options
        optionscv.plots = 'none'; % Disable plots
        optionscv.lwr.waitbar = 'none'; % Disable waitbar
        optionscv.display = 'off'; % Disable display
        optionscv.preprocessing = {xprepro, yprepro}; % Apply pretreatments

        % Perform pretreatment preprocessing
        [Xcalp, spx] = preprocess('calibrate', xprepro, X_cal); % Preprocessing of X
        [Ycalp, spy] = preprocess('calibrate', yprepro, Y_cal); % Preprocessing of Y
        Xtestp_1 = preprocess('apply', spx, X_pred); % Apply X pretreatment to prediction data
        Ytestp_1 = preprocess('apply', spy, Y_pred); % Apply Y pretreatment to prediction data

        biasc = zeros(LVs, 1); % Initialize bias storage
        model = pls(Xcalp, Ycalp, LVs, options); % Train PLS model
        biasc(LVs) = model.bias(LVs); % Store bias for max LVs

        modelcv = crossval(X_cal, Y_cal, model, {'vet', 10}, LVs, optionscv); % Cross-validate model

        % Parallel loop to compute bias for intermediate LVs
        parfor lvs = 1:(LVs-1)
            model = pls(Xcalp, Ycalp, lvs, options); % Train model
            biasc(lvs) = model.bias(lvs); % Store bias
        end

        % Save calibration and cross-validation results
        results.RMSE.CAL(i, 1:LVs) = modelcv.rmsec; % Calibration RMSE
        results.RMSE.CROSSV(i, 1:LVs) = modelcv.rmsecv; % Cross-validation RMSE
        results.BIAS.CAL(i, 1:LVs) = biasc; % Calibration bias
        results.BIAS.CROSSV(i, 1:LVs) = modelcv.cvbias; % Cross-validation bias
        results.R2.CAL(i, 1:LVs) = modelcv.r2c; % Calibration R-squared
        results.R2.CROSSV(i, 1:LVs) = modelcv.r2cv; % Cross-validation R-squared

        % Determine optimal number of LVs
        suggested_LVs = choosecomp(modelcv); % Suggested LVs
        results.LVs(i, 1) = suggested_LVs; % Save suggested LVs

        % Final model calibration using suggested LVs
        final_model = pls(Xcalp, Ycalp, suggested_LVs, options);

        % Perform predictions and store results
        for j = 1:k
            eval(['pred = pls(Xtestp_' num2str(j) ', Ytestp_' num2str(j) ', final_model, options);']);
            results.RMSE.PRED(i, j) = pred.detail.rmsep(end); % RMSE (Prediction)
            results.BIAS.PRED(i, j) = pred.detail.predbias(end); % Bias (Prediction)
            results.R2.PRED(i, j) = pred.detail.r2p(end); % R-squared (Prediction)
        end
        
        clc; % Clear command window for progress updates
        disp(['Model ', num2str(c), ' of ', num2str(size(results.pret_list, 2))]); % Display progress
        disp(['Pretreatment: ', num2str(i)]); % Display current pretreatment
        for u = 1:size(xprepro, 2)
            disp(['- ', xprepro(1, u).description]); % Display pretreatment description
        end
        
    end

    % Compute average results (if multiple prediction sets)
    if k > 1
        results.MEAN.RMSEP = mean(results.RMSE.PRED, 2); % Mean RMSE
        results.MEAN.BIASP = mean(results.BIAS.PRED, 2); % Mean Bias
        results.MEAN.R2P = mean(results.R2.PRED, 2); % Mean R-squared
    end

    save(file_output, 'results'); % Save results to output file