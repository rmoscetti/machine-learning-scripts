function pls_parallel(file_input, file_output)
% PLS_PARALLEL: A MATLAB function to perform parallel PLS calibration and prediction.
% Author: Roberto Moscetti
% Version: 0.1
% Date: 2025-01-06
%
% This script is designed for use with the PLS_Toolbox.
% It processes data from the provided input file, applies spectral pretreatments, and
% performs PLS calibration, cross-validation, and prediction using MATLAB's Parallel
% Computing Toolbox to speed up computations.
% INPUTS:
%   file_input  - MAT file containing calibration and prediction datasets.
%   file_output - MAT file where the computed results will be saved.

    load pretreatment_list.mat % Load the list of pretreatment methods.
    load(file_input) % Load calibration and prediction datasets.

    % Convert calibration and prediction data into compatible dataset format.
    X_cal = dataset(X_cal);
    X_pred = dataset(X_pred);
    % Uncomment the following lines if additional prediction datasets are used (at the moment is not working).
    % Xtest_2 = dataset(Xtest_2);
    % Xtest_3 = dataset(Xtest_3);
    Y_cal = dataset(Y_cal);
    Y_pred = dataset(Y_pred);
    % Uncomment the following lines if additional prediction datasets are used (at the moment is not working).
    % Ytest_2 = dataset(Ytest_2);
    % Ytest_3 = dataset(Ytest_3);

    n = length(mynew_methods); % Number of pretreatment methods to be tested.
    LVs = 20; % Maximum number of latent variables to be computed.
    k = 1; % Number of prediction datasets.

    % Initialize the results structure to store RMSE, BIAS, and R^2 values.
    results.RMSE.CAL = zeros(n, LVs);
    results.RMSE.CROSSV = zeros(n, LVs);
    results.RMSE.PRED = zeros(n, k);
    results.BIAS.CAL = zeros(n, LVs);
    results.BIAS.CROSSV = zeros(n, LVs);
    results.BIAS.PRED = zeros(n, k);
    results.R2.CAL = zeros(n, LVs);
    results.R2.CROSSV = zeros(n, LVs);
    results.R2.PRED = zeros(n, k);

    % If multiple prediction sets are used, prepare for average computations.
    if k > 1
        results.MEAN.RMSEP = zeros(n, 1);
        results.MEAN.BIASP = zeros(n, 1);
        results.MEAN.R2P = zeros(n, 1);
    end

    % List of pretreatment indices to process.
    results.pret_list = [181:215, 227:248, 260:281, 293:325, 337:358, 360:394, ...
                         406:427, 439:460, 472:504, 516:537];

    % Creazione della DataQueue per il counter
    dq = parallel.pool.DataQueue;
    afterEach(dq, @(count) fprintf('Avanzamento: %d/%d\n', count, length(results.pret_list)));

    % Variabile condivisa per tracciare l'avanzamento
    progress = 0;
	
	% Use a parallel pool for computations.
    parfor i_idx = 1:length(results.pret_list)
        i = results.pret_list(i_idx); % Current pretreatment index.
		
		% Incremento del counter
        send(dq, i_idx); % Notifica il progresso tramite DataQueue

        % Retrieve spectral pretreatment methods for X and Y data.
        xprepro = mynew_methods{1, i};
        yprepro = mynew_methods{2, i};

        % Configure PLS options.
        options = pls('options');
        options.plots = 'none';
        options.display = 'off';

        % Configure cross-validation options.
        optionscv = crossval('options');
        optionscv.plots = 'none';
        optionscv.lwr.waitbar = 'none';
        optionscv.display = 'off';

        % Apply calibration pretreatments to X and Y datasets.
        [Xcalp, spx] = preprocess('calibrate', xprepro, X_cal);
        [Ycalp, spy] = preprocess('calibrate', yprepro, Y_cal);

        % Apply pretreatments to prediction datasets.
        Xtestp_1 = preprocess('apply', spx, X_pred);
        Ytestp_1 = preprocess('apply', spy, Y_pred);
        % Uncomment the following lines if additional prediction datasets are used (at the moment is not working)
        % Xtestp_2 = preprocess('apply', spx, Xtest_2);
        % Ytestp_2 = preprocess('apply', spy, Ytest_2);

        % Compute bias for each latent variable.
        biasc = zeros(LVs, 1);
        for lvs = 1:LVs
            model = pls(Xcalp, Ycalp, lvs, options);
            biasc(lvs) = model.bias(lvs);
        end

        % Perform cross-validation using the current model.
        modelcv = crossval(X_cal, Y_cal, model, {'vet', 10}, LVs, optionscv);

        % Store calibration and cross-validation results.
        results.RMSE.CAL(i, 1:LVs) = modelcv.rmsec;
        results.RMSE.CROSSV(i, 1:LVs) = modelcv.rmsecv;
        results.BIAS.CAL(i, 1:LVs) = biasc;
        results.BIAS.CROSSV(i, 1:LVs) = modelcv.cvbias;
        results.R2.CAL(i, 1:LVs) = modelcv.r2c;
        results.R2.CROSSV(i, 1:LVs) = modelcv.r2cv;

        % Determine the optimal number of latent variables.
        suggested_LVs = choosecomp(modelcv);
        results.LVs(i, 1) = suggested_LVs;

        % Calibrate the final model using the optimal number of latent variables.
        final_model = pls(Xcalp, Ycalp, suggested_LVs, options);

        % Perform predictions on the test datasets.
        for j = 1:k
            eval(['pred = pls(Xtestp_' num2str(j) ', Ytestp_' num2str(j) ', final_model, options);']);
            results.RMSE.PRED(i, j) = pred.detail.rmsep(end);
            results.BIAS.PRED(i, j) = pred.detail.predbias(end);
            results.R2.PRED(i, j) = pred.detail.r2p(end);
        end
    end

    % Compute mean prediction results if multiple test sets are used.
    if k > 1
        results.MEAN.RMSEP = mean(results.RMSE.PRED, 2);
        results.MEAN.BIASP = mean(results.BIAS.PRED, 2);
        results.MEAN.R2P = mean(results.R2.PRED, 2);
    end

    % Save the results to the specified output file.
    save(file_output, 'results');
end
