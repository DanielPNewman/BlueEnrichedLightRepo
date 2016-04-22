
% Cleanup routine:
function cleanup

IOPort('CloseAll')
Screen('CloseAll');
% Close window:
sca;

% Restore keyboard output to Matlab:
ListenChar(0);

% Shutdown Eyelink:
Eyelink('Shutdown'); %DN: commented out for now. Uncomment later

