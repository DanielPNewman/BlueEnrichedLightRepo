% ELsetup
% SK 6-7-12

%%%%%%%% EYELINK SETUP AND CALIBRATION 
el=EyelinkInitDefaults(window);%,par);

if ~EyelinkInit(0, 1)
    fprintf('Eyelink Init aborted.\n');
    cleanup;  % cleanup function
    return;
end
% make sure that we get gaze data from the Eyelink
Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');

% open file to record data to
% Eyelink('Openfile', par.edfFile);
Eyelink('OpenFile',[answer{1},'.edf']);
% calibrate:
if par.calibrate
    EyelinkDoTrackerSetup(el); % Instructions come up on the screen. It seems Esc has to be pressed on the stim computer to exit at the end
end

disp('FINISHED CALIBRATING')

Eyelink('StartRecording');
WaitSecs(0.1);
% mark zero-plot time in data file
Eyelink('Message', 'SYNCTIME');
eye_used = -1;

% figure out which eye is being tracked:
eye_used = Eyelink('EyeAvailable');
