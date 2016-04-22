% download data file
try
    fprintf('Receiving data file ''%s''\n', par.edfFile );
    status=Eyelink('ReceiveFile');
    if status > 0
        fprintf('ReceiveFile status %d\n', status);
    end
    if 2==exist(par.edfFile, 'file')
        fprintf('Data file ''%s'' can be found in ''%s''\n', par.edfFile, pwd );
    end
catch rdf
    fprintf('Problem receiving data file ''%s''\n', par.edfFile );
    rdf;
end