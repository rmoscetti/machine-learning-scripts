function results2csv(mat_file)
load(mat_file);
name = split(mat_file,".");
name = char(name(1));
n_models = size(results.LVs, 1);
csv_data = zeros(n_models, 10);

%seq = [181:215, 227:248, 260:281, 293:325, 337:358, 360:394, 406:427, 439:460, 472:504, 516:537];

for i = results.pret_list
    % LVs
    LVs = results.LVs(i);
    csv_data(i, 1) = LVs;
    
    % RMSE
    csv_data(i, 2) = results.RMSE.CAL(i, LVs);
    csv_data(i, 3) = results.RMSE.CROSSV(i, LVs);
    csv_data(i, 4) = results.RMSE.PRED(i);
    
    % BIAS
    csv_data(i, 5) = results.BIAS.CAL(i, LVs);
    csv_data(i, 6) = results.BIAS.CROSSV(i, LVs);
    csv_data(i, 7) = results.BIAS.PRED(i);
    
    %R2
    csv_data(i, 8) = results.R2.CAL(i, LVs);
    csv_data(i, 9) = results.R2.CROSSV(i, LVs);
    csv_data(i, 10) = results.R2.PRED(i);
end

if ~exist(name, 'dir')  
    mkdir(name);  % Crea la cartella
    fprintf('Cartella "%s" creata con successo.\n', name);
else
    fprintf('ATTENZIONE - La cartella "%s" esiste già ed i file saranno sovrascritti.\nPremere un tasto per continuare o CTRL+C per interrompere.\n', name);
    pause;
end

%Tables
LVs = 1:20;
LVs_str = arrayfun(@num2str, LVs, 'UniformOutput', false); % Converte i numeri in stringhe
header = strjoin(LVs_str, ','); % Unisce le stringhe con una virgola come separatore
header = ['Model #,', header];

% Tab RMSEs
csv_RMSEC = fullfile(name, 'RMSEC.csv');
RMSEC = results.RMSE.CAL;
csv_save(header, csv_RMSEC, RMSEC);
csv_RMSECV = fullfile(name, 'RMSECV.csv');
RMSECV = results.RMSE.CROSSV;
csv_save(header, csv_RMSECV, RMSECV);

% Tab BIASs
csv_BIASC = fullfile(name, 'BIASC.csv');
BIASC = results.BIAS.CAL;
csv_save(header, csv_BIASC, BIASC);
csv_BIASCV = fullfile(name, 'BIASCV.csv');
BIASCV = results.BIAS.CROSSV;
csv_save(header, csv_BIASCV, BIASCV);

% Tab R2s
csv_R2C = fullfile(name, 'R2C.csv');
R2C = results.R2.CAL;
csv_save(header, csv_R2C, R2C);
csv_R2CV = fullfile(name, 'R2CV.csv');
R2CV = results.R2.CROSSV;
csv_save(header, csv_R2CV, R2CV);

% Risultati
header = 'Model #,LVs,RMSEC,RMSECV,RMSEP,BIASC,BIASP,BIASCV,R2C,R2CV,R2P';
csv_results = fullfile(name, 'results.csv');
csv_save(header, csv_results, csv_data);

end
