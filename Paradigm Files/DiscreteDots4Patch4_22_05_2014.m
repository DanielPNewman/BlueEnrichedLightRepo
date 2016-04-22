reset(RandStream.getDefaultStream,sum(100*clock)); % to avoid randomisation problem
% reset(RandStream.getGlobalStream,sum(100*clock)); % to avoid randomisation problem

% ***************************************************** BASIC SET - UP 
clear all;
SITE = 'T';
commandwindow;
load parDD4

if SITE=='C'|SITE=='E'
    TheUsualParamsCRT_Dell_lores      % this script defines some useful parameters of the monitor, trigger port, etc common to all experiments
elseif SITE == 'T'
%     TheUsualParamsASUS
    TheUsualParamsCRT_TCD
end

%%%%%%%%%% IMPORTANT SETTINGS (note many of the time values in ms won't work out exactly - depends on refresh rate & flicker - it'll be the closest it can be, should be checked in EEG)
par.videoFrate = 85;   % Monitor refresh rate
% if length(par.FlickFdots)==2
%     par.FlickFdots = fliplr(par.FlickFdots)      % Flicker frequency in Hz for the dots - one for every patch
% else
    par.FlickFdots = [21.25 21.25 21.25 21.25];    % [patch-on-left patch-on-right]
%     par.FlickFdots = [21.25 21.25];
% end

par.numPatches = 4;

par.useEL=1;    % 1 to use EyeLink and track the eyes. 0 otherwise
par.FixWinSize = 4;    % RADIUS of fixation (circular) window in degrees

 %par.numtrials = 18;
par.numtrials = 48*7; %was 48*7 (i.e. 336 trials) should take about 35-40mins
par.cohLevels = [60]; % coherence levels - these will be randomly interleaved - separate by spaces or commas
par.BGcolor=0;      % BACKGROUND COLOR
par.dotspeed = 6;       % in degrees per second
par.dotsize = 6;   % in pixels
par.numdots = 150;  % this will be the number in a square; the ones outside the circle will be taken away
par.dotpatchsize = 8;   % degrees of visual angle - diameter of dot patch
% par.patchloc = [0 0];
% par.patchloc = [-10 -6; 10 -6;];% patch location coordinates [x y] in degrees relative to center of screen
par.patchloc = [-10 -6; 10 -6; -10 6; 10 6;];% patch location coordinates [x y] in degrees relative to center of screen
% bottom left, bottom right, top left, top right
par.motionDir = [90 270];    % in degrees relative to positive x-axis (0=rightward)

% TIMING, all in ms - converted later
% NOTE totalDotDur, cohMotionOnset, cohMotionOffset sho0uld all have the same number of elements:
% par.totalDotDur = [3300 4300 5300]; % in ms - how long are the dots up in total, between the incoherent prelude, cues, delay, etc
par.totalDotDur = [2800 3800 4800]; % in ms - how long are the dots up in total, between the incoherent prelude, cues, delay, etc
par.cohMotionOnset = [1800 2800 3800];  % in ms - when does the motion become coherent? Can be more than 1 and will be randomized. If using a cue, setting it to double the cue onset time will promote a rhythm
par.cohMotionOffset = [par.totalDotDur];  % in ms - when does the motion become incoherent - set to totalDotDur if it will stay coherent til the end
par.deadline = 1000; % 1600;     % in ms, from start of coherent motion. Will be incorrect trial if subject doesn't respond by deadline. If responseCue is on, deadline doesn't apply
par.fixperiod = 400;
par.FBdur = 200;  % feedback duration (sounds)
par.ITI = 400;  % Inter-trial interval ; then self paced start
par.responseAcceptTime = 200;   % in ms, only log button clicks after this time

par.pointsPerCorrectTrial = 40;

% Major task options:
par.patchCue = 0;       % 1 to use arrow cue to indicate which of two patches will have motion
par.directionCue = 0;   % 1 to use directional cues (color change, parameters below), 0 to not.   % not implemented yet! (nearly)
par.responseCue = 0;    % 1 if response has to be withheld til the end of motion
par.randomizeResponseMapping = 0;
par.switchDir = 0;      % 1 if half the trials will switch direction during coherent motion. GL: Patch is missing from conditiondescrip.
par.UDTR = 0;   % 1 if you want to do an up-down transform rule (staircase) procedure
% UDTR options, parameters:
par.UDTRstepsize = 1;
par.UDTRnumCorr2goDown = 3;
par.UDTRnumErr2goUp = 1;
currentCoh = par.cohLevels(1);

% Direction cue stuff:
par.cueValidity = [25 50 75];   % = percentage of trials to the RIGHT (or more generally, the SECOND motion direction above)
% [25 50 75] or for just practicing, set to [50 50 50].

par.rgbG = [0 255 0];      % Green
par.rgbY = [233 233 0];    % Yellow
par.rgbC = [0 239 239];    % Cyan       % these have to be readjusted for the new black DELL in CCNY
par.rgbGRAY = [221 221 221];
par.rgbDARKERGRAY = [181 181 181]; %DN
par.cueOnsetTime = 600;     % in ms from dot onset

% Response cue stuff
par.responseCueTime = par.totalDotDur;  % in ms from dot onset  % DOESN'T DO ANYTHING YET - at the moment, resp cue comes up at end of dots always
par.button2modir_fixed = [1 2];  % the motion direction that corresponds to each button
par.responseCueXPos = 0.46; % x-coordinate of the left-side of the response cue - adjust to get it centered by trial and error!!

% switch direction stuff
par.switchDirTime = [1300];     % in ms from dot onset
par.switchDuration = 200;           % in ms, how long to take to go from one motion direction to the opposite

% Two-dot-patch options:
par.patchCueValidity = 100;  % percentage of trials in which the cue correectly indicates the patch that will have motion
par.cueDur = 200;           % duration of cue in ms
par.OneOrBoth = 'O';    % 'O' or 'B' - will there be motion in just one patch or both? ** Only O implemented 8/3/12
par.IndependentOrYoked = 'I'; % 'I' or 'Y' - will they always say the same thing, or be independent? ** Not implemented 8/3/12

par.leadintime = 1000; % how long to pause before experiment starts

par.MinTimeBtwClicks = 0.3; % 300 ms?

dlg_title = 'Dot Motion Task';
while 1
    prompt = {'Enter SUBJECT/RUN/TASK IDENTIFIER:','EEG? (1=yes, 0=no)','Direction Cue Colors listed in the order Left, Neutral, Right - e.g. YGC'};
    def = {par.runID,num2str(par.recordEEG),par.ColorOrderStr};
    answer = inputdlg(prompt,dlg_title,1,def);
    par.runID = answer{1};
    par.recordEEG = str2num(answer{2});
    par.ColorOrderStr = answer{3};
    if exist([par.runID '.mat'],'file'), 
        dlg_title = [par.runID '.mat EXISTS ALREADY - CHOOSE ANOTHER, OR DELETE THAT ONE IF IT IS RUBBISH']
    else
        break;
    end
end

for c=1:3
    eval(['par.cuecolors{c} = par.rgb' par.ColorOrderStr(c) ';'])
end
colorstrings = {'Green' 'Cyan' 'Yellow'};

% Set up for triggers
if par.recordEEG
    if SITE=='C'
        % USB port (posing as Serial Port) for triggers
        [port, errmsg] = IOPort('OpenSerialPort', 'COM4','BaudRate=115200');
        IOPort('Write', port, uint8([setpulsedur 2 0 0 0]))   % pulse width given by last 4 numbers (each a byte, little-endian)
    elseif SITE=='E'
        port = hex2dec('1130');
        lptwrite(port,0);
    elseif SITE=='T'
        % Parallel Port for triggers - set to zero to start
%         port = hex2dec('2010');
        port = hex2dec('2568'); %DN Change this port address for the Monash computer
        lptwrite(port,0);
    end
end

tic   % see how long it takes to get through block

% SOUND STUFF
Fs = 22050; % Hz
Good = 0.3*sin(2*pi*500*[0:1/Fs:0.1]);
si = hanning(Fs/100)';
env = [si(1:round(length(si)/2)) ones(1,length(Good)-2*round(length(si)/2)) fliplr(si(1:round(length(si)/2)))];
hGood = audioplayer(Good.*env, Fs);

Bad = 0.4*sin(2*pi*200*[0:1/Fs:0.3]);
si = hanning(Fs/100)';
env = [si(1:round(length(si)/2)) ones(1,length(Bad)-2*round(length(si)/2)) fliplr(si(1:round(length(si)/2)))];
hBad = audioplayer(Bad.*env, Fs);
play(hGood)

if par.useEL, ELCalibrateDialog, end

% Opens a graphics window on the main monitor
window = Screen('OpenWindow', whichScreen, par.BGcolor);

if abs(hz-par.videoFrate)>1
    cleanup; error(['The monitor is NOT SET to the desired frame rate of ' num2str(par.videoFrate) ' Hz. Change it.'])
end

if par.useEL
    %%%%%%%%% EYETRACKING PARAMETERS    
    par.TgWinSize = 3;    % RADIUS of fixation (circular) window in degrees
    ELsetupCalib
    Eyelink('Command', 'clear_screen 0')
    Eyelink('command', 'draw_box %d %d %d %d 15', center(1)-round(deg2px*par.FixWinSize), center(2)-round(deg2px*par.FixWinSize), center(1)+round(deg2px*par.FixWinSize), center(2)+round(deg2px*par.FixWinSize));
%     Eyelink('command', 'draw_box %d %d %d %d 15', center(1)-deg2px*par.FixWinSize, center(2)-deg2px*par.FixWinSize, center(1)+deg2px*par.FixWinSize, center(2)+deg2px*par.FixWinSize);
end
Screen('FillRect',window, par.BGcolor); % GL: recolour the screen to black after calibration.

%  ************************************************* CODES AND TRIAL SEQUENCE
% trigger codes - can only use these 15 for brain products: [1 4 5 8 9 12 13 16 17 20 21 24 25 28 29]  (don't ask!)
par.CD_RESP  = 1;
par.CD_FIX_ON = 4;
par.CD_DOTS_ON = 5;
par.CD_CUE_ON = 8;
par.CD_COHMOTION_ON = 9;
par.CD_COHMOTION_OFF = 29;
par.CD_BUTTONS = [12 13];   % left and right mouse
par.FIXBREAKtrig = 28;

% performance codes
par.PC_CORRECT = 1;
par.PC_INCORRECT = 2;
par.PC_FIXBREAK = 3;
par.PC_TOOLATE = 4;
par.PC_TOOEARLY = 5;    % For response cue

%%%%%  coherence, motion direction and color waveforms
nMD = length(par.motionDir);
nDP = size(par.patchloc,1);     
par.FlickTdots = round(par.videoFrate./par.FlickFdots);      % In number of video frames
nrefON = floor(par.FlickTdots/2);                       % number of refreshes where the dots are ON
nrefOFF = par.FlickTdots-nrefON;                      % number of refreshes where the dots are OFF

par.switchDirFr = round(par.switchDirTime*par.FlickFdots/1000)+1;
par.numswitchFr = round(par.switchDuration*par.FlickFdots/1000);
par.responseAcceptFr = round(par.responseAcceptTime*par.FlickFdots/1000);
par.cueOnsetFr = round(par.cueOnsetTime*par.FlickFdots/1000);
% stimulus conditions - number of directions x number of coherence levels x coherent motion
% durations x coherence-waveform shapes (switch direction?)
% We'll construct a cell array called "coh" which has a cell for each condition, with each row of each cell having a timecourse of coherence
% levels for a given motion direction

numcond = 0;
clear conditiondescrip coh trigger triggerFr correctDir patchWithMo
for c=1:length(par.cohLevels)
    for o=1:length(par.cohMotionOnset)
        for p=1:par.numPatches
            numFr1 = round((par.totalDotDur(o)./1000).*par.FlickFdots(p));
            cohMotionOnFr1 = round(par.cohMotionOnset(o)*par.FlickFdots(p)/1000)+1;
            cohMotionOffFr1 = round(par.cohMotionOffset(o)*par.FlickFdots(p)/1000)+1;
            for m=1:nMD
                numcond = numcond+1;
                coh{numcond}(1:nMD,1:numFr1) = 0;
                coh{numcond}(m,cohMotionOnFr1:cohMotionOffFr1-1) = par.cohLevels(c);
                if par.directionCue
                    if SITE=='T'|SITE=='E'
                        trigger{numcond} = [par.CD_DOTS_ON par.CD_CUE_ON 100+numcond];
                    elseif SITE=='C'
                        trigger{numcond} = [par.CD_DOTS_ON par.CD_CUE_ON par.CD_COHMOTION_ON];
                    end
                    triggerFr{numcond} = [1 par.cueOnsetFr(p) cohMotionOnFr1];
                elseif par.patchCue
                    if SITE=='T'|SITE=='E'
                        trigger{numcond} = [par.CD_DOTS_ON par.CD_CUE_ON 100+numcond];
                    elseif SITE=='C'
                        trigger{numcond} = [par.CD_DOTS_ON par.CD_CUE_ON par.CD_COHMOTION_ON];
                    end
                    triggerFr{numcond} = [1 par.cueOnsetFr(p) cohMotionOnFr1];
                else
                    if SITE=='T'|SITE=='E'
                        trigger{numcond} = [par.CD_DOTS_ON 100+numcond];
                    elseif SITE=='C'
                        trigger{numcond} = [par.CD_DOTS_ON par.CD_COHMOTION_ON];
                    end
                    triggerFr{numcond} = [1 cohMotionOnFr1];
                end
                correctDir(numcond) = m;
                patchWithMo(numcond) = p;
                conditiondescrip{numcond} = ['Trigger ' num2str(numcond) ': coherence ' num2str(par.cohLevels(c)) ', patch ' num2str(p) ', motion dir ' num2str(par.motionDir(m)) ', coh motion onset ' num2str(par.cohMotionOnset(o))];
                if par.switchDir
                    numcond = numcond+1;
                    coh{numcond}(1:nMD,1:numFr1) = 0;
                    coh{numcond}(3-m,cohMotionOnFr1:par.switchDirFr(o)-1) = par.cohLevels(c);
                    % transition period
                    si = linspace(0,par.cohLevels(c),par.numswitchFr+2);
                    % ramp down the wrong direction:
                    coh{numcond}(3-m,par.switchDirFr(o)+[0:par.numswitchFr]) = fliplr(si(1:end-1));
                    % 5 ramp up the right direction:
                    coh{numcond}(m,par.switchDirFr(o)+[0:par.numswitchFr]) = si(2:end);
                    coh{numcond}(m,par.switchDirFr(o)+par.numswitchFr+1:end) = par.cohLevels(c);
                    %                 modir{numcond}(1:par.numFr(o)) = par.motionDir(3-m)*pi/180;
                    %                 modir{numcond}(par.switchDirFr(o)+length(find(si(2:end-1)<0,1))-1:end) = par.motionDir(m)*pi/180;
                    trigger{numcond} = trigger{numcond-1};  % triggers are the same as for non switch.
                    triggerFr{numcond} = triggerFr{numcond-1};
                    correctDir(numcond) = m;
                    patchWithMo(numcond) = p;
                    conditiondescrip{numcond} = ['Trigger ' num2str(numcond) ': coherence ' num2str(par.cohLevels(c)) ', patch ' num2str(p) ', motion dir ' num2str(par.motionDir(m)) ', coh motion onset ' num2str(par.cohMotionOnset(o)) ' SWITCH']
                end
            end
        end
    end
end

% probabilistic cues?
if par.directionCue
    % Now we have to tripple the number of conditions because there are three cue colors for left cue neutral cue and
    % right cue...
    k=0; integerproportions=[];
    while 1
        k=k+1;
        integerproportions = k*par.cueValidity/100; % e.g. for cueValidity [25 50 75] this would be 1 2 3, for [20 50 80] it would be 2 5 8
        if all(abs(round(integerproportions)-integerproportions)<0.1), break; end
    end
    % first duplicate all the other stuff:
    for c=1:length(par.cueValidity)-1
        for n=1:numcond
            coh{n+c*numcond}=coh{n};
            trigger{n+c*numcond}=trigger{n};
            triggerFr{n+c*numcond}=triggerFr{n};
            correctDir(n+c*numcond)=correctDir(n);
            patchWithMo(n+c*numcond)=patchWithMo(n);
            conditiondescrip{n+c*numcond}=[conditiondescrip{n} ' Direction cue ' num2str(c+1)];
        end
    end
    % Now do the colors and repetitions:
    for c=1:length(par.cueValidity)
        for n=1:numcond
            dotcolor{n+(c-1)*numcond} = par.cuecolors{c}'*ones(1,size(coh{n},2));
            dotcolor{n+(c-1)*numcond}(:,1:par.cueOnsetFr-1) = par.rgbGRAY'*ones(1,par.cueOnsetFr-1);
            if correctDir(n)==1
                numperminblock(n+(c-1)*numcond) = integerproportions(length(par.cueValidity)+1-c);
            elseif correctDir(n)==2
                numperminblock(n+(c-1)*numcond) = integerproportions(c);
            end
        end
    end
    numcond = numcond*length(par.cueValidity);
elseif par.patchCue
    
    k=0; integerproportions=[];   % should be a number in integerproportions for every dot patch
    while 1
        k=k+1;
        integerproportions = k*[par.patchCueValidity 100-par.patchCueValidity]/100; % e.g. for cueValidity [25 50 75] this would be 1 2 3, for [20 50 80] it would be 2 5 8
        if all(abs(round(integerproportions)-integerproportions)<0.1), break; end
    end
    % first duplicate all the other stuff:  
    for n=1:numcond
        coh{n+numcond}=coh{n};
        trigger{n+numcond}=trigger{n};
        triggerFr{n+numcond}=triggerFr{n};
        correctDir(n+numcond)=correctDir(n);
        patchWithMo(n+numcond)=patchWithMo(n);
        conditiondescrip{n+numcond}=conditiondescrip{n};
        dotcolor{n} = par.rgbGRAY'*ones(1,size(coh{n},2));
        dotcolor{n+numcond} = par.rgbGRAY'*ones(1,size(coh{n+numcond},2));
    end
    % Now do the repetitions:
    extra_descr_str = {'valid' 'invalid'};
    for c=1:2
        for n=1:numcond
            conditiondescrip{n+(c-1)*numcond} = [conditiondescrip{n} ' ' extra_descr_str{c}];
            numperminblock(n+(c-1)*numcond) = integerproportions(c);
        end
    end
    numcond = numcond*2;
else
    for n=1:numcond
        dotcolor{n} = par.rgbGRAY'*ones(1,size(coh{n},2));
        numperminblock(n) = 1; % number of cond instances per minblock. 24 conds in this case.
    end
end
par.conditiondescrip = conditiondescrip;

disp(['Number of conditions: ' num2str(numcond)])
% Trial condition randomization, new GL:
minblock = [];
for n=1:numcond
    % minblock = 1:24, if numperminblock == 2, minblock =
    % 1,1,2,2,3,3,...24,24
    minblock = [minblock ones(1,numperminblock(n))*n];
end

% % bottom left, bottom right, top left, top right
% LeftLowerTarget_logical = (trialCond == 1|trialCond ==2|trialCond ==9|trialCond ==10|trialCond ==17|trialCond ==18);
% RightLowerTarget_logical = (trialCond == 3|trialCond ==4|trialCond ==11|trialCond ==12|trialCond ==19|trialCond ==20);
% LeftUpperTarget_logical = (trialCond == 5|trialCond ==6|trialCond ==13|trialCond ==14|trialCond ==21|trialCond ==22);
% RightUpperTarget_logical = (trialCond == 7|trialCond ==8|trialCond ==15|trialCond ==16|trialCond ==23|trialCond ==24);
left_target_logical = [1,2,5,6,9,10,13,14,17,18,21,22];
right_target_logical = [3,4,7,8,11,12,15,16,19,20,23,24];
upper_target_logical = [5:8,13:16,21:24];
lower_target_logical = [1:4,9:12,17:20];
temp = [];
number_of_minblocks = ceil(par.numtrials/size(minblock,2));
for blocker = 1:number_of_minblocks
    minblock_rand = minblock(randperm(size(minblock,2)));
    this_is_crap = 1;
    while this_is_crap
        minblock_rand = minblock(randperm(size(minblock,2)));
        this_is_crap = 0;
        for i = 1:length(minblock_rand)-4
            if all(ismember(minblock_rand(i:i+4),left_target_logical)) | all(ismember(minblock_rand(i:i+4),right_target_logical)) | ...
                    all(ismember(minblock_rand(i:i+4),upper_target_logical)) | all(ismember(minblock_rand(i:i+4),lower_target_logical))
                this_is_crap = 1;
            end
        end
    end            
    temp = [temp,minblock_rand];
end

% % % repmat is repeat minblock to fit into the amount of total trials
% % temp = repmat(minblock,[1,ceil(par.numtrials/size(minblock,2))]); 
% % % Now RANDOMIZE the sequence of trials, across the whole block.
% % temp = temp(:,randperm(size(temp,2)));      % jumble the columns in temp
% if numtrials is not evenly divisible by the minimum block length, shave off some trials from the end
temp(:,par.numtrials+1:end)=[];
trialCond = temp;
save(['Quicksave_',par.runID],'trialCond')
% *********************************************************************************** START TASK
% Instructions:
% leftmargin = 0.1;
% if par.responseCue
%     Screen('DrawText', window, ['Watch the dot motion until it is finished.'], leftmargin*scres(1), 0.2*scres(2), 255);
%     Screen('DrawText', window, ['Then indicate the direction of motion using the mouse button assignments shown.'], leftmargin*scres(1), 0.3*scres(2), 255);
%     Screen('DrawText', window, ['Do not respond until the screen says you can.'], leftmargin*scres(1), 0.4*scres(2), 255);
% else
%     Screen('DrawText', window, 'Click left button with left hand for UPWARD motion.', leftmargin*scres(1), 0.2*scres(2), 255);
%     Screen('DrawText', window, 'Click right button with right hand for DOWNWARD motion.', leftmargin*scres(1), 0.3*scres(2), 255);
% end
% 
% if par.directionCue
%     Screen('DrawText', window, [colorstrings{strmatch(par.ColorOrderStr(1),colorstrings)} ' Dots means ' num2str(100-par.cueValidity(1)) '% likely to the LEFT'], leftmargin*scres(1), 0.5*scres(2), 255);
%     Screen('DrawText', window, [colorstrings{strmatch(par.ColorOrderStr(2),colorstrings)} ' Dots means 50/50 to the left or Right'], leftmargin*scres(1), 0.6*scres(2), 255);
%     Screen('DrawText', window, [colorstrings{strmatch(par.ColorOrderStr(3),colorstrings)} ' Dots means ' num2str(par.cueValidity(3)) '% likely to the RIGHT'], leftmargin*scres(1), 0.7*scres(2), 255);
% end

% Screen('DrawText', window, 'Press both buttons to begin each trial.', leftmargin*scres(1), 0.8*scres(2), 255);
% Screen('DrawText', window, 'Press any button to begin task.', leftmargin*scres(1), 0.9*scres(2), 255);

leftmargin = 0.1;
Screen('DrawText', window, 'Click left mouse button with right hand as', leftmargin*scres(1), 0.2*scres(2), 255);
Screen('DrawText', window, 'FAST as you can for upward OR downward motion.', leftmargin*scres(1), 0.3*scres(2), 255);
Screen('DrawText', window, 'The motion could be in ANY patch.', leftmargin*scres(1), 0.5*scres(2), 255);
% Screen('DrawText', window, 'Press any button to begin each trial.', leftmargin*scres(1), 0.7*scres(2), 255);
Screen('DrawText', window, 'Press any button to begin task.', leftmargin*scres(1), 0.8*scres(2), 255);

Screen('Flip', window); 
HideCursor;

% Things that we'll save on a trial by trial basis
clear PTBtrigT PTBtrig ClickT Click RespLR perf button2modir
RespT=[];
nPTBtrig=0;
numResp=1;

% Waits for the user to press a button.
[clicks,x,y,whichButton] = GetClicks(whichScreen,0);
% if par.recordEEG, sendtrigger(par.CD_RESP,port,SITE,0),end
% if par.useEL, Eyelink('Message', ['TASK_START']); end
ClickT(1) = GetSecs;
Click(1)=whichButton(1);    % The first response will be the one that sets the task going, after subject reads instructions
% Click(1)=whichButton;

%%%%%%%%%%%%%%%%%%%% START TRIALS

% initial lead-in:
% Screen('FillRect',window, par.BGcolor); % screen blank
% Screen('Flip', window);
% WaitSecs(par.leadintime/1000);

Screen('DrawText', window, 'Loading...', 0.35*scres(1), 0.5*scres(2), 255);
Screen('Flip', window);
WaitSecs(par.leadintime/1000);

if par.UDTR
    currentnumCorr = 0;
    currentnumErr = 0;
    UDTRfig = figure;
    trialcoh = [];
end

portUP=0; lastTTL=0; ButtonDown=0;

clear PT
% First make ALL dot stimuli and store:
dots = cell(4,par.numtrials);   % This will contain dot locations relative to center of screen, in DEGREES
   
for n=1:par.numtrials   
    % MAKE THE DOTS FOR THIS TRIAL
        % First make incoherent motion for all patches:
    pwm = patchWithMo(trialCond(n));
    for p=1:par.numPatches
        dots{p,n}=[];
        numFr = round(size(coh{trialCond(n)},2)*par.FlickTdots(pwm)/par.FlickTdots(p));
        % First generate dots at random locations on each frame
        for i=1:numFr
            for d=1:par.numdots
                dots{p,n}(d,:,i) = [(rand-0.5)*par.dotpatchsize (rand-0.5)*par.dotpatchsize];
            end
        end
        % if this is the patch with dots, make coherent motion:
        if p==pwm
            % then add the coherence by selecting dots to move in certain direction relative to
            % previous frame. A different random set is selected each frame.
            for i=2:numFr
                r = randperm(par.numdots);
                for m=1:nMD
                    ncd = round(par.numdots*coh{trialCond(n)}(m,i)/100);
                    randsel = r(1:ncd);
                    % for the selected dots, move them in a particular direction
                    dots{pwm,n}(randsel,1,i) = dots{pwm,n}(randsel,1,i-1)+cos(par.motionDir(m)*pi/180)*par.dotspeed/par.FlickFdots(pwm);         % x-coordinate
                    dots{pwm,n}(randsel,2,i) = dots{pwm,n}(randsel,2,i-1)-sin(par.motionDir(m)*pi/180)*par.dotspeed/par.FlickFdots(pwm);         % y-coordinate
                    r(1:ncd)=[];
                end
                % if it's gone off to the left, wrap it around to the far right
                dots{pwm,n}(find(dots{pwm,n}(:,1,i)<par.dotpatchsize/2),1,i) = dots{pwm,n}(find(dots{pwm,n}(:,1,i)<par.dotpatchsize/2),1,i)+par.dotpatchsize;
                % if it's gone off to the right, wrap it around to the far left
                dots{pwm,n}(find(dots{pwm,n}(:,1,i)>par.dotpatchsize/2),1,i) = dots{pwm,n}(find(dots{pwm,n}(:,1,i)>par.dotpatchsize/2),1,i)-par.dotpatchsize;
                % if it's gone off to the left, wrap it around to the far right
                dots{pwm,n}(find(dots{pwm,n}(:,2,i)<par.dotpatchsize/2),2,i) = dots{pwm,n}(find(dots{pwm,n}(:,2,i)<par.dotpatchsize/2),2,i)+par.dotpatchsize;
                % if it's gone off to the right, wrap it around to the far left
                dots{pwm,n}(find(dots{pwm,n}(:,2,i)>par.dotpatchsize/2),2,i) = dots{pwm,n}(find(dots{pwm,n}(:,2,i)>par.dotpatchsize/2),2,i)-par.dotpatchsize;
            end
        end
        % Finally, go through the dots and get rid of the dots falling outside the
        % circle - put them off the screen.
        for i=1:numFr
            for d=1:par.numdots
                if sqrt(sum(dots{p,n}(d,:,i).^2)) > par.dotpatchsize/2
                    dots{p,n}(d,:,i) = 2*center/deg2px + 0.01;
                end
            end
        end
        PT1 = [];
        for i=1:numFr
            PT1 = [PT1 ; i*ones(nrefON(p),1);zeros(nrefOFF(p),1)];
        end
        PT{n}(:,p) = PT1;
    end   
end

% for p=1:par.numPatches
%     Screen('DrawDots', window, dots{p,1}(:,:,PT{1}(1,p))'*deg2px, par.dotsize, dotcolor{trialCond(1)}(:,min([PT{1}(1,p) size(dotcolor{trialCond(1)},2)])), round(center+par.patchloc(p,:).*[1 -1]*deg2px));
% end
% Screen('Flip', window);
    
% if par.useEL
%     %%%%%%%%% EYETRACKING PARAMETERS    
%     par.TgWinSize = 3;    % RADIUS of fixation (circular) window in degrees
%     ELsetupCalib
%     Eyelink('Command', 'clear_screen 0')
%     Eyelink('command', 'draw_box %d %d %d %d 15', center(1)-round(deg2px*par.FixWinSize), center(2)-round(deg2px*par.FixWinSize), center(1)+round(deg2px*par.FixWinSize), center(2)+round(deg2px*par.FixWinSize));
% %     Eyelink('command', 'draw_box %d %d %d %d 15', center(1)-deg2px*par.FixWinSize, center(2)-deg2px*par.FixWinSize, center(1)+deg2px*par.FixWinSize, center(2)+deg2px*par.FixWinSize);
% end
% Screen('FillRect',window, par.BGcolor); % GL: recolour the screen to black after calibration.

n=0; %DN
while n<par.numtrials 
    n=n+1;
% for n=1:par.numtrials
        
    ITIstart = GetSecs;
    trialcoh(n) = currentCoh;
%         
%     % SET UP TRIAL
    perf(n) = 0;    % initialize performance code to nothing
%     
    disp(['TRIAL ' num2str(n)])
    quit=0;
    while GetSecs<ITIstart+par.ITI/1000; end
    
    % START TRIAL
    % Fixation interval:
    if par.useEL, Eyelink('Message', ['TRIAL' num2str(n) 'FIX_ON' num2str(par.CD_FIX_ON)]); end
    if par.recordEEG, sendtrigger(par.CD_FIX_ON,port,SITE,0); end  
    Screen('FillRect',window, 90, fixRect);
    if n>1
        for p=1:par.numPatches
%             Screen('DrawDots', window, dots{p,n-1}(:,:,PT{n-1}(1,p))'*deg2px, par.dotsize, dotcolor{trialCond(n)}(:,min([PT{n-1}(1,p) size(dotcolor{trialCond(n-1)},2)])), round(center+par.patchloc(p,:).*[1 -1]*deg2px));
            Screen('DrawDots', window, dots{p,n-1}(:,:,PT{n-1}(1,p))'*deg2px, par.dotsize, par.rgbDARKERGRAY', round(center+par.patchloc(p,:).*[1 -1]*deg2px)); %DN
        end
    end    
%     Screen('Flip', window);
    Screen('Flip', window, [], 1);  % "Dont clear" = 1 means it won't clear the framebuffer after flip (will  keep fixation point)
    
%     WaitSecs(0.5); % wait a half second so they're ready, before checking
%     eye. maybe already like this.
    
    % Wait til subject is ready...
    if par.useEL
        % Wait until Gaze enters fixation window to start trial... 
        while 1
           checkeyeSK
           if isnan(x) & isnan(y) % blink
           elseif sqrt(x^2+y^2)<deg2px*par.FixWinSize  % eye in fixation window?
               break; 
           end
           % check for keyboard press
           [keyIsDown, secs, keyCode] = KbCheck;
           % if spacebar was pressed stop display
           if keyCode(stopkey), quit=1; break; end
        end
        if quit, break; end
    end
% % %     GetClicks(whichScreen,0); %DN: got rid of this section so that
% instead of participant clicking both mouse buttons to start each trial, the trial starts automatically if participant is fixating  
% % %     while 1
% % %         [xblah,yblah,buttons] = GetMouse(whichScreen);
% % %         if length(find(buttons))>=1, break; end % Setting this to 1 makes it just a left or right click to begin.
% % %     end
    WaitSecs((par.fixperiod-framelen*2)/1000);
    
    portUP=0; lastTTL=0; ButtonDown=0;
    
    % DOT MOTION
    trigs_sent = 0;
    for i=1:size(PT{n},1)
        if par.recordEEG, if SITE=='T'|SITE=='E', if portUP & GetSecs-lastTTL>0.01, lptwrite(port,0); portUP=0; end, end, end
        for p=1:par.numPatches
            if PT{n}(i,p)
                Screen('DrawDots', window, dots{p,n}(:,:,PT{n}(i,p))'*deg2px, par.dotsize, dotcolor{trialCond(n)}(:,min([PT{n}(i,p) size(dotcolor{trialCond(n)},2)])), round(center+par.patchloc(p,:).*[1 -1]*deg2px));
            end
        end
        Screen('FillRect',window, 255, fixRect);
            
        trg = find(triggerFr{trialCond(n)}==PT{n}(i,pwm));
        if ~isempty(trg)
            if trg>trigs_sent
                if par.recordEEG, sendtrigger(trigger{trialCond(n)}(trg),port,SITE,1); portUP=1; lastTTL=GetSecs; end
                if par.useEL, Eyelink('Message', ['TRIAL' num2str(n) '_' num2str(trigger{trialCond(n)}(trg))]); end
                nPTBtrig = nPTBtrig+1;
                [VBLTimestamp PTBtrigT(nPTBtrig)] = Screen('Flip', window);
                PTBtrig(nPTBtrig) = trigger{trialCond(n)}(trg);
                trigs_sent = trigs_sent+1;
            else
                Screen('Flip', window);
            end
            checkButton
        else
            Screen('Flip', window);
            checkButton
        end
        if par.useEL
            checkeyeSK
            if isnan(x) & isnan(y) % blink
            elseif sqrt(x^2+y^2)>deg2px*par.FixWinSize  % eye in fixation window?
                if par.recordEEG, sendtrigger(par.FIXBREAKtrig,port,SITE,0); portUP=0; lastTTL=GetSecs; end
                Eyelink('Message', ['TRIAL' num2str(n) '_fixation_break']);
                perf(n) = par.PC_FIXBREAK;
                break;
            end
        end
    end
    
    respClockStart = PTBtrigT(end);     % from when should the response deadline count?
    
    if ~perf(n)  % trial still to be resolved
        if par.responseCue
            if par.randomizeResponseMapping
                button2modir(n,:) = randperm(2);  
            else
                button2modir(n,:) = par.button2modir_fixed; 
            end
            if button2modir(n,1)==1
                Screen('DrawText',window,'< | >', par.responseCueXPos*scres(1), 0.45*scres(2), 255);
            elseif button2modir(n,1)==2
                Screen('DrawText',window,'> | <', par.responseCueXPos*scres(1), 0.45*scres(2), 255);
            end
            Screen('FillRect',window, 255, fixRect);
            Screen('Flip', window);

            respClockStart = GetSecs;
            % is there already a response?
            first_resp = find(RespT>PTBtrigT(end),1);
            if ~isempty(first_resp)
                perf(n) = par.PC_TOOEARLY;
            end
        else
            button2modir(n,:) = par.button2modir_fixed; 
        end
    end
    
    while ~perf(n)  % trial still to be resolved
        first_resp = find(RespT>respClockStart,1);
        if ~isempty(first_resp)
            if (RespT(first_resp)-respClockStart)*1000 > par.deadline
                perf(n) = par.PC_TOOLATE;
                break;
            end
            buttonpressed = RespLR(first_resp);
            if button2modir(n,buttonpressed)==1
%             if button2modir(n,buttonpressed)==correctDir(trialCond(n))
                perf(n) = par.PC_CORRECT;
            else
                perf(n) = par.PC_INCORRECT;
            end
            break;
        else
            checkButton
        end
        t_now = GetSecs;
        if t_now-respClockStart>par.deadline/1000
            % This could be because they clicked before there was even any motion information, so check for that:
            early_resp = find(RespT>PTBtrigT(end-1),1);
            if ~isempty(early_resp)
                perf(n) = par.PC_TOOEARLY;
            else
                perf(n) = par.PC_TOOLATE;
            end
            break;
        end
    end
    
    perf
    
    % FEEDBACK!
    switch perf(n)
        case par.PC_CORRECT
            % play nice beep
%             play(hGood)
%             Screen('DrawText', window, ['Correct'], 0.45*scres(1), 0.45*scres(2), 255); % GL: Change this to put in centre...
%             Screen('DrawText', window, [num2str(par.pointsPerCorrectTrial) ' points!'], 0.45*scres(1), 0.55*scres(2), 255);
%             Screen('Flip', window);
            if par.UDTR
                currentnumCorr = currentnumCorr+1;  
                currentnumErr = 0;
            end
%             Screen('FillRect',window, 255, fixRect);
            Screen('FillRect',window, 90, fixRect);
            for p=1:par.numPatches
%                 Screen('DrawDots', window, dots{p,n}(:,:,PT{n}(1,p))'*deg2px, par.dotsize, dotcolor{trialCond(n)}(:,min([PT{n}(1,p) size(dotcolor{trialCond(n)},2)])), round(center+par.patchloc(p,:).*[1 -1]*deg2px));
                Screen('DrawDots', window, dots{p,n}(:,:,PT{n}(1,p))'*deg2px, par.dotsize, par.rgbDARKERGRAY', round(center+par.patchloc(p,:).*[1 -1]*deg2px)); %DN
%                 WaitSecs(0.1); %DN so they don't blink as soon as they click
                Screen('DrawText', window, ['Blink Now'], 0.425*scres(1), 0.475*scres(2), 109);
            end
            Screen('Flip', window);
            WaitSecs(par.FBdur/1000);
        case par.PC_INCORRECT
            % play horrid beep
            play(hBad)
            Screen('DrawText', window, ['Wrong Button!'], 0.45*scres(1), 0.45*scres(2), 109);
            for p=1:par.numPatches
                Screen('DrawDots', window, dots{p,n}(:,:,PT{n}(1,p))'*deg2px, par.dotsize, par.rgbDARKERGRAY', round(center+par.patchloc(p,:).*[1 -1]*deg2px)); %DN
            end
            Screen('Flip', window);
            if par.UDTR
                currentnumCorr = 0;  
                currentnumErr = currentnumErr+1;
            end
            WaitSecs(par.FBdur/1000);
        case par.PC_TOOLATE
            play(hBad)
            Screen('DrawText', window, ['TOO SLOW'], 0.45*scres(1), 0.45*scres(2), 109);
            for p=1:par.numPatches
                Screen('DrawDots', window, dots{p,n}(:,:,PT{n}(1,p))'*deg2px, par.dotsize, par.rgbDARKERGRAY', round(center+par.patchloc(p,:).*[1 -1]*deg2px)); %DN
            end
            Screen('Flip', window);
            if par.UDTR
                currentnumCorr = 0;  
                currentnumErr = currentnumErr+1;
            end
            WaitSecs(par.FBdur/1000);
        case par.PC_TOOEARLY
            play(hBad)
            if par.responseCue
                Screen('DrawText', window, ['TOO FAST! Wait for the response cue.'], 0.2*scres(1), 0.45*scres(2), 109);
            else
%                 Screen('DrawText', window, ['TOO FAST! Wait for motion information!'], 0.2*scres(1), 0.45*scres(2), 109);
                Screen('DrawText', window, ['TOO FAST! Only click if you see motion!'], 0.25*scres(1), 0.475*scres(2), 109); %DN: Changed this
            end
            for p=1:par.numPatches
                Screen('DrawDots', window, dots{p,n}(:,:,PT{n}(1,p))'*deg2px, par.dotsize, par.rgbDARKERGRAY', round(center+par.patchloc(p,:).*[1 -1]*deg2px)); %DN
            end
            Screen('Flip', window);
            if par.UDTR
                currentnumCorr = 0;  
                currentnumErr = currentnumErr+1;
            end
            WaitSecs(par.FBdur/1000);
        case par.PC_FIXBREAK
%             if par.recordEEG, sendtrigger(par.FIXBREAKtrig,port,SITE,1); portUP=1; lastTTL=GetSecs; end
%             Eyelink('Message', ['TRIAL' num2str(n) '_fixation_break']);
            
            play(hBad)
            
            Screen('DrawText', window, ['KEEP YOUR EYE ON THE SPOT!'], 0.3*scres(1), 0.45*scres(2), 109);
            for p=1:par.numPatches
                Screen('DrawDots', window, dots{p,n}(:,:,PT{n}(1,p))'*deg2px, par.dotsize, par.rgbDARKERGRAY', round(center+par.patchloc(p,:).*[1 -1]*deg2px)); %DN
            end
            
            Screen('Flip', window);

            WaitSecs(par.FBdur/1000);

            n = n-1;
    end
           
    if par.UDTR
        if currentnumCorr==par.UDTRnumCorr2goDown
            currentCoh = currentCoh - par.UDTRstepsize;
            currentnumCorr = 0;
        elseif currentnumErr==par.UDTRnumErr2goUp
            currentCoh = currentCoh + par.UDTRstepsize;
            currentnumErr = 0;
        end
        % now update the coherence waveforms
        for c=1:numcond
            coh{c}(find(coh{c}~=0)) = currentCoh;
        end
        disp(['UDTR ** :: trial coherence is now ' num2str(currentCoh)])
        figure(UDTRfig)
        plot(trialcoh,'ko-','LineWidth',3)
    end
    % Inter-trial interval... 
end

Percent_correct = ((length(find(perf==1))/par.numtrials)*100) %DN: just added this here so the experimenter can see participants performance in the command prompt 

% Feedback for the whole block
txtstart = 0.1*scres(1);
Screen('DrawText', window, ['On this block you got ' num2str(length(find(perf==par.PC_CORRECT))) ' correct out of ' num2str(length(perf)) '.'], txtstart, 0.25*scres(2), 255);
Screen('DrawText', window, [num2str(length(find(perf==par.PC_TOOLATE))) ' trials were TOO SLOW.'], txtstart, 0.35*scres(2), 255);
Screen('DrawText', window, ['So you earned a total of ' num2str(length(find(perf==par.PC_CORRECT))*par.pointsPerCorrectTrial) ' points.'], txtstart, 0.45*scres(2), 255);
Screen('DrawText', window, ['Click to Exit'], txtstart, 0.55*scres(2), 255);
Screen('Flip', window); 
GetClicks(whichScreen,0);

if par.useEL, 
    Eyelink('StopRecording');
    Eyelink('CloseFile');
    ELdownloadDataFile
end

cleanup

disp(['number correct = ' num2str(length(find(perf==1)))])

%DN: 
if SITE=='T'
    cohmo_trigs = find(PTBtrig>100 & PTBtrig<=100+numcond); %DN: Changed this line to suit triggers for Trinity and Monash
elseif SITE=='C'
    cohmo_trigs = find(PTBtrig==par.CD_COHMOTION_ON);
end
% if length(cohmo_trigs)~=length(trialCond), error('trigger number mismatch!!'); end %DN: just commented this out for now till we fix this problem 
clear RTs 
for n=1:length(cohmo_trigs); 
    RTs(n) = nan;
    stimtime = PTBtrigT(cohmo_trigs(n));
%   nextresp = find(RespT>stimtime,1);
    nextresp = find(RespT>stimtime & RespT<stimtime+2.5,1); %DN: just put a limit (2500ms) on  response times to be included so any response time over 2500ms is kicked out for this analysis
    if ~isempty(nextresp)
        RTs(n) = RespT(nextresp) - stimtime;
    end
end
figure; hist(RTs*1000,[0:100:1800])
title(['MEDIAN RT: ' num2str(median(RTs)*1000)]) 

%DN: just added this in to calculate mean left and right RT
% bottom left, bottom right, top left, top right
LeftLowerTarget_logical = (trialCond == 1|trialCond ==2|trialCond ==9|trialCond ==10|trialCond ==17|trialCond ==18);
RightLowerTarget_logical = (trialCond == 3|trialCond ==4|trialCond ==11|trialCond ==12|trialCond ==19|trialCond ==20);
LeftUpperTarget_logical = (trialCond == 5|trialCond ==6|trialCond ==13|trialCond ==14|trialCond ==21|trialCond ==22);
RightUpperTarget_logical = (trialCond == 7|trialCond ==8|trialCond ==15|trialCond ==16|trialCond ==23|trialCond ==24);
LeftLowerTargetRTs = RTs(LeftLowerTarget_logical);
RightLowerTargetRTs = RTs(RightLowerTarget_logical);
LeftUpperTargetRTs = RTs(LeftUpperTarget_logical);
RightUpperTargetRTs = RTs(RightUpperTarget_logical);
MeanLowerLeftTargetRT=nanmean(LeftLowerTargetRTs);
MeanLowerRightTargetRT=nanmean(RightLowerTargetRTs);
MeanUpperLeftTargetRT=nanmean(LeftUpperTargetRTs);
MeanUpperRightTargetRT=nanmean(RightUpperTargetRTs);
toc
%DN moved the saving down to here and now saves mean left and right RT
% mkdir([par.runID,'_data'])
save([par.runID],'ClickT','Click','nPTBtrig','PTBtrigT','PTBtrig','RespT','RespLR','perf','trialCond','coh','dotcolor','trigger','triggerFr','button2modir','correctDir','par', 'conditiondescrip','RTs','MeanLowerLeftTargetRT','MeanLowerRightTargetRT','MeanUpperLeftTargetRT','MeanUpperRightTargetRT')
save parDD4 par