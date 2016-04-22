% calibrate dialog

par.edfFile=[par.runID '.edf'];
% calibrate?
calStr = questdlg('Calibrate this block?','No','No','Yes','Yes');
switch calStr
    case 'No'
        par.calibrate = 0;
    case 'Yes'
        par.calibrate = 1;
end