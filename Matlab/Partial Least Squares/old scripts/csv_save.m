function csv_save(header, file, data)
    n_model = (1:size(data, 1))';
    newdata = [n_model, data];
    fid = fopen(file, 'w'); % apre il file
    fprintf(fid, '%s\n', header); % scrive l'header
    fclose(fid); % chiude il file
    dlmwrite(file, newdata, '-append'); % aggiunge i dati numerici
end