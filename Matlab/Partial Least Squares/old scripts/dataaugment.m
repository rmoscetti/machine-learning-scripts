% Reference
% Deep Chemometrics with Data Augmentation
% https://github.com/EBjerrum/Deep-Chemometrics
% https://arxiv.org/pdf/1710.01927.pdf
% MATLAB help -> dataset class

function [x,y] = dataaugment(X, Y, betashift, slopeshift, multishift, rep, seed)
    col_names = X.axisscalename{2}; % 'Wavenumbers (cm^-1)'
    col_scale = X.axisscale{2}; % axis scale -> 1.0e+03 * 3.9996 ... 9.9991 
    classes = size(X.classid, 2); % why 'classid' and not only 'class'?
        % X.class -> {1×2 double}
        % X.classid -> {1×2 cell}
        % X.classname ->
        % 'CULTIVAR', 'SCANSIONE', 'PORZIONE', 'ORIGINE', 'Cal/Val'
        % X.classid{1} -> {'"FONTANE"'}    {'"CONSTANCE"'}
        % X.classid{1,1} -> {'"FONTANE"'}    {'"CONSTANCE"'}
        % X.classid{1,2} -> {'"TAGLIATO"'}    {'"TAGLIATO"'}
        % ...
        
    labels = size(X.label, 2); % labelname -> 'CODICE ALE', 'ID NUMBER'
        % MATLAB help -> size
        % X.label{1,1} -> labels of 'CODICE ALE'
        % X.label{1,2} -> labels of 'ID NUMBER'
    
    % Repetitions
    x = double(X);
        % double -> convert dataset variables to double array
        % an array of type double is storing 64-bit, double-precision
        % floating-point values
    x = repmat(x, rep, 1); % repmat -> repeat copies of array
        % repmat generates 'rep' copies of x rows,
        % y columns are untouched (multiplied by '1')
    y = [Y; repmat(Y, rep, 1)];
    
    % Shift of baseline - calculate arrays
    rng(seed);
    beta = (rand(size(x, 1), 1) * 2 * betashift) - betashift;
    % size(x,1) = 18. x is 18x3112 double (numeric matrix)
    % rand -> rand returns a random scalar drawn from the uniform
    %         distribution in the interval (0,1)
    % rand(size(x, 1), 1) -> gives a size(x,1) by 1 matrix of
    %     uniformly distributed random numbers -> 18x1 double matrix
    % histogram(rand(100000,1),20) -> to have a look at the uniform
    %                                 distribution of random numbers
    rng(seed + 1);
    slope = (rand(size(x, 1), 1) * 2 * slopeshift) - slopeshift + 1;
    % if betashift = slopeshift -> slope = beta +1

    % Calculate relative position
    axis = (0:(size(x, 2) - 1)) / (size(x, 2));
    % it generates a vector from 0 to around 1 of 1 by 3112 dimension;
    % size(x, 2) = 3112

    % Calculate offset to be added
    offset = slope .* axis + beta - axis - (slope / 2) + 0.5;

    % Multiplicative
    rng(seed + 2);
    multi = (rand(size(x, 1), 1) * 2 * multishift) - multishift + 1;
        % same formula as for slope

    x = multi .* x + offset;
    x = [double(X); x];
    x = dataset(x);
    x.axisscalename{2} = char(col_names);
    x.axisscale{2} = col_scale;
    
    aug_X = zeros(size(X, 1), 1);
    aug_n = aug_X;
    for j = 1:rep
        aug_X = aug_X + 1;
        aug_n = [aug_n; aug_X];
    end
    
    for k = 1:labels
        label_name = X.labelname{1,k};
        x.labelname{1,k} = char(label_name);
        row_labels = repmat(X.label{1,k}, rep+1, 1);
        x.label{1,k} = char(strcat(row_labels, "_", num2str(aug_n)));
    end
       
    for i = 1:classes
        class_data = repmat(X.classid{1,i}', rep+1, 1);
        class_name = X.classname{1,i};
        x.classid{1,i} = class_data';
        x.classname{1,i} = char(class_name);
    end
    
    x.classname{1,i+1} = char("Augmentation");
    x.classid{1,i+1} = char(num2str(aug_n));
end