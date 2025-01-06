function apply_pls_aug(file_input, file_vettore, file_output)
load pretreatment_list.mat
%eval(['load' file_input ';']);
load(file_input)
load(file_vettore)

%[X_cal, X_test, Y_cal, Y_test] = cal_test_split(X, Y, 0.25, 1);
X_cal = dataset(X_aug);
%Xtest = dataset(Xtest);
X_pred = dataset(X_pred);
%Xtest_2 = dataset(Xtest_2);
%Xtest_3 = dataset(Xtest_3);

Y_cal = dataset(Y_aug);
%Ytest = dataset(Ytest);
Y_pred = dataset(Y_pred);
%Ytest_2 = dataset(Ytest_2);
%Ytest_3 = dataset(Ytest_3);

n = length(mynew_methods); % number of pretreaments to be tested
%n = 1;
LVs = 20; % number of maximum latent variable to be computed
k = 1; % number of prediction sets

% preparing the new variables
results.RMSE.CAL = zeros(n, LVs);
results.RMSE.CROSSV = zeros(n, LVs);
results.RMSE.PRED = zeros(n, k);
results.BIAS.CAL = zeros(n, LVs);
results.BIAS.CROSSV = zeros(n, LVs);
results.BIAS.PRED = zeros(n, k);
results.R2.CAL = zeros(n, LVs);
results.R2.CROSSV = zeros(n, LVs);
results.R2.PRED = zeros(n, k);

if k > 1
    results.MEAN.RMSEP = zeros(n, 1);
    results.MEAN.BIASP = zeros(n, 1);
    results.MEAN.R2P = zeros(n, 1);
end

bar = waitbar(0, ""); % progress bar (open)

for i = 1:n
    waitbar(i/n, bar, ['Computations: ' sprintf('%d', i) ' / ' sprintf('%d', n)]); % progress bar update
    
    % settings for spectral pretreatments (cal)
    xprepro = mynew_methods{1,i};
    yprepro = mynew_methods{2,i};
    options = pls('options');
	options.plots = 'none';
    options.display = 'off';
	%options.preprocessing{1} = xprepro;
    %options.preprocessing{2} = yprepro;
    
    % settings for spectral pretreatments (cv)
    optionscv = crossval('options');
    optionscv.plots = 'none';
    optionscv.lwr.waitbar = 'none';
    optionscv.display = 'off';
    %optionscv.preprocessing = {xprepro, yprepro};
    
    % calibration and cross validation of model
    [Xcalp,spx] = preprocess('calibrate', xprepro, X_cal);
    [Ycalp,spy] = preprocess('calibrate', yprepro, Y_cal);
    Xtestp_1 = preprocess('apply',spx, X_pred); %apply to new data
    %Xtestp_2 = preprocess('apply',spx, Xtest_2); %apply to new data
    %Xtestp_3 = preprocess('apply',spx, Xtest_3); %apply to new data
    Ytestp_1 = preprocess('apply',spy, Y_pred); %apply to new data
    %Ytestp_2 = preprocess('apply',spy, Ytest_2); %apply to new data
    %Ytestp_3 = preprocess('apply',spy, Ytest_3); %apply to new data
    
    model = pls(Xcalp, Ycalp, LVs, options);
    %modelcv = crossval(Xcalp, Ycalp, model, {'vet', 10}, LVs, optionscv);
    modelcv = crossval(Xcalp, Ycalp, model, CV8_CV_aug, LVs, optionscv);
    
    % calibration and cross validation results
    results.RMSE.CAL(i, 1:LVs) = modelcv.rmsec;
    results.RMSE.CROSSV(i, 1:LVs) = modelcv.rmsecv;
    results.BIAS.CAL(i, 1:LVs) = modelcv.bias;
    results.BIAS.CROSSV(i, 1:LVs) = modelcv.cvbias;
    results.R2.CAL(i, 1:LVs) = modelcv.r2c;
    results.R2.CROSSV(i, 1:LVs) = modelcv.r2cv;
    
    % selection of the best number of LVs
    suggested_LVs = choosecomp(modelcv);
    results.LVs(i,1) = suggested_LVs; % suggested LVs are saved
    
    % calibration of model using the suggested LVs
    final_model = pls(Xcalp, Ycalp, suggested_LVs, options);
    
    % prediction tests
    for j = 1:k
        eval(['pred = pls(Xtestp_' num2str(j) ', Ytestp_' num2str(j) ', final_model, options);']);
        results.RMSE.PRED (i, j) = pred.detail.rmsep(end);
        results.BIAS.PRED (i, j) = pred.detail.predbias(end);
        results.R2.PRED (i, j) = pred.detail.r2p(end);
    end
end

% average of prediction results (only for a number of test sets > 1)
if k > 1
    results.MEAN.RMSEP = mean(results.RMSE.PRED, 2);
    results.MEAN.BIASP = mean(results.BIAS.PRED, 2);
    results.MEAN.R2P = mean(results.R2.PRED, 2);
end

close(bar); % progress bar (closed)

save (file_output, 'results'); % saving results