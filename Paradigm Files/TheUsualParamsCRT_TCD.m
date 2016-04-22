% The usual parameters - specifies monitor dimensions, viewing distance,
% etc - lots of things that will be the same for all experiments.

% Dell (Small Black Monitor): 
% Checked H=32.5cm, V=24.25cm

% scres = [1280 960];
% cm2px = 39.3846 ;
% cm2px = scres(1)/32;

% scres = [1280 1024]; %DN: Philips CRT Monitor at Monash
% cm2px = scres(1)/35.5;

scres = [1024 768];
cm2px = scres(1)/40;%DN: Sony (G520) CRT Monitor at Monash

dist = 57;  % viewing distance in cm is closer than using LCD (57)

whichScreen = 1;

[w, h]=Screen('WindowSize',whichScreen);
if any([w h]-scres), error(['resolution is wrong - should be ' num2str(scres)]); end

% midgray = 185;
midgray = 187;

scrsz_cm = scres/cm2px;

center = scres/2;

% use aproximation tanT ~= T.
deg2px = dist*cm2px*pi/180;

echo off            % won't print output to command window

% What's the monitor refresh rate? (for the CRT is 85 Hz)
hz=Screen('FrameRate', whichScreen,1);
framelen = 1000/hz;

% define a rect for the flash at upper left underneath photodiode, for Syncing:  
% syncRect = [14 20 20 26];    % note convention is [X-UprLeft Y-UprLeft X-LwrRight Y-LwrRight]
% syncRect = [5 5 35 35]; 
syncRect = [1 1 24 24]; 

% rect of fixation:
fixRect = [center-2 center+2];

% for sending codes down USB-serial (See SimpleGabors for example of use in task code):
setpulsedur = [109 112];
sendpulse = [109 104];
% For the trigger codes sent out the USB (posing as "serial" port), for some reason, the third binary bit seems to be
% broken, and the second is interpreted as the third! So only these 15 trigger codes will be distinguishable in the EEG:
% [1 4 5 8 9 12 13 16 17 20 21 24 25 28 29]
% So each experiment will have to choose from those. These will have to be transformed to account for the bit mix-up:
trigtransform = [1 nan nan 2 3 nan nan 8 9 nan nan 10 11 nan nan 16 17 nan nan 18 19 nan nan 24 25 nan nan 26 27];
% e.g. If you want a 29 sent, you send trigtransform(29), which is actually 27 but comes up in EEG as 29.

% Always use space as the stopkey
stopkey=KbName('space');
pausekey=KbName('p');
set(0,'defaultFigurePosition',[100 100 700 500])