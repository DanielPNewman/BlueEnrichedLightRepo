%To test single participant on this script only:
% clear all
% close all
% clc
% path ='S:\R-MNHS-SPP\Bellgrove-data\4. Dan Newman\Blue Light Study\'; %DN
% s=1
% subject_folder = {'BL1\BL1_1'};
% allsubj = {'BL1_1'};
% blocks = {[1:1]};

targcodes = [101:124]; % Continuous Dots

old_fs = 500; % old sample rate
fs = 500; %new sample rate

% in sample points, the ERP epoch
ts = -0.7*fs:1.2*fs; % -500ms to 1000ms with 200ms either side to chop off later.
t = ts*1000/fs;
ts_crop = -0.5*fs:1*fs;
t_crop = ts_crop*1000/fs;
BLint = [-100 0];   % baseline interval in ms
default_response_time = 1.1-0.1;

Alpha_samps = ((abs(t_crop(1))+abs(t_crop(end)))/50)-1; %50ms alpha samples
ERP_samps = length(t_crop);

nchan = 65;

LPFcutoff=35;       % Low Pass Filter cutoff
HPFcutoff=0.0;       % High Pass Filter - either 0.01, 0.1, or 0.25 for cuttoff as I have filters .mats designed for these using "fdatool" tool in MATLAB
LPF = 1;    % 1 = low-pass filter the data, 0=don't.
HPF = 0; %0=don't use

if HPF==1
    if HPFcutoff==0.01;
        load('butter_HPF_0p01');
        HD_HPF = Hd;
    elseif  HPFcutoff==0.1;
        load('butter_HPF_0p1');
        HD_HPF = Hd;
    elseif  HPFcutoff==0.25;
        load('butter_HPF_0p25');
        HD_HPF = Hd;
    end
end

bandlimits(1,1) = 8; % defining the filter for alpha bandpass.
bandlimits(1,2) = 13;

[H1,G1]=butter(4,[2*(bandlimits(1,1)/old_fs) 2*(bandlimits(1,2)/old_fs)]); % alpha bandpass
[H2,G2]=butter(4,[2*(bandlimits(1,1)/fs) 2*(bandlimits(1,2)/fs)]); % alpha bandpass

PretargetARwindow=[-0.500,0];%time window (in seconds, must be factor of the 50ms alpha samples) to search for pre-target artifacts

% frontal channels, occipital channels, and POz and Pz, CPz, CP1, CP2, P1, P2

ARchans = [1:65];
ARchans_for_blinks = [1:65];
artifth = 100;
artifchans=[];  % keep track of channels on which the threshold is exceeded, causing trial rejection

% chanlocs = readlocs('cap128.loc');
chanlocs = readlocs ('actiCAP65_ThetaPhi.elp','filetype','besa'); %DN for actiCAP with reference channel 'FCz' included - hence 65 chans
chanlocs = chanlocs(1:nchan)';

clear files matfiles; k=0;
for n=1:length(blocks)
    k=k+1;
    paths{k} = [path subject_folder{s} '\'];
    files{k} = [allsubj{s} '.vhdr'];
    matfiles{k} = [path subject_folder{s} '\' allsubj{s} '.mat'];
    ET_files{k} = [path 'SamplesAndEvents_combined\' allsubj{s} '.asc'];
    ET_matfiles{k} = [path subject_folder{s} '\' allsubj{s} '_ET.mat'];
end

erp = [];erp_HPF = []; Alpha = []; Pupil=[]; n=0; artifacts_anywhereInEpoch = 0;
allRT=[]; allrespLR=[]; allTrig=[];     % note allRT will be in sample points
for f=1:length(files)
    disp(f)
    path_temp=[paths{f}];
    file_temp=[files{f}];
    EEG = pop_loadbv(path_temp,file_temp);
    %% From loadbvSK that simon wrote
    loadbvSK_DN
    %%
    EEG = letterkilla_old(EEG); %DN: removes the letters that Brain Products appends to the triggers
    % First LP Filter
    if LPF, EEG.data = eegfilt(EEG.data,old_fs,0,LPFcutoff); end
    
    % interpolate bad channels %Interpolation already done in loadbsSK_DN above?
    if ~isempty(badchans)
        EEG.chanlocs = chanlocs;
        EEG=eeg_interp(EEG,[badchans],'spherical');
    end
    
    EEG_HPF = EEG;
    
    EEG.data = double(EEG.data);

    %% Ger's method to filter alpha:
    EEG_alpha.data = filtfilt(H1,G1,EEG.data')';

    %% Dan's method to filter alpha
    %%%%%%%%%%% band-pass filter, isolating the alpha band at 8-14 Hz. ftrans,
    %%%%%%%%%%% ftype etc are specialised filter settings for alpha
%     EEG_alpha = pop_firpm(EEG, 'fcutoff', [bandlimits(1,1) bandlimits(1,2)], 'ftrans', 1, 'ftype', ...
%         'bandpass', 'wtpass', 1, 'wtstop', 28.7822, 'forder', 1822); % Parks-McClellan filter
    %%
    if HPF
        EEG_HPF.data = double(EEG_HPF.data(1:nchan,:));
        % [H_HP1,G_HP1]=butter(4,2*HPFcutoff/old_fs,'high');   %Ger's old HPF method
        % EEG_HPF.data = filtfilt(H_HP1,G_HP1,EEG_HPF.data')'; %Ger's old HPF method
        EEG_HPF.data = filtfilthd(HD_HPF,EEG_HPF.data')'; %New HPF method using filters designed with "fdatool" tool in MATLAB
        disp('HPF finished')
    else
        EEG_HPF.data=double(EEG.data);
    end

    
    % average-reference the whole continuous data (safe to do this now after interpolation):
    EEG.data = EEG.data - repmat(mean(EEG.data([1:nchan],:),1),[nchan,1]);
    EEG_HPF.data = EEG_HPF.data - repmat(mean(EEG_HPF.data([1:nchan],:),1),[nchan,1]);
    EEG_alpha.data = EEG_alpha.data - repmat(mean(EEG_alpha.data([1:nchan],:),1),[nchan,1]);
    
    %% Fix file names:
    if strcmp(subject_folder(s),'BL10\BL10_M')%eeg files were named differently to .edf files for this session
        ET_matfiles{f}=[path, 'BL10\BL10_M\BL10_M_ET.mat'];
        ET_files{f}=[path, 'SamplesAndEvents_combined\BL10_M.asc'];
    end
    if strcmp(subject_folder(s),'BL20\BL20_L')%eeg files were named differently to .edf files for this session
        ET_matfiles{f}=[path, 'BL20\BL20_L\BL20_L_ET.mat'];
        ET_files{f}=[path, 'SamplesAndEvents_combined\BL20_L.asc'];
    end
    if strcmp(subject_folder(s),'BL24\BL24_L')%eeg files were named differently to .edf files for this session
        ET_matfiles{f}=[path, 'BL24\BL24_L\BL24_L_ET.mat'];
        ET_files{f}=[path, 'SamplesAndEvents_combined\BL24_L.asc'];
    end
    if strcmp(subject_folder(s),'BL12\BL12_M')%eeg files were named differently to .edf files for this session
        ET_matfiles{f}=[path, 'BL12\BL12_M\BL12_M_ET.mat'];
        ET_files{f}=[path, 'SamplesAndEvents_combined\BL12_M.asc'];
    end
    
    %% Sync up the Eyelink data:
    if ~strcmp(subject_folder(s),'BL16\BL16_H')%%BL16_H(64) has corrupted .edf file so skip this for BL16_H
        
        if ~exist(ET_matfiles{f}, 'file') %DN: if ET matfile has NOT has been saved previouslty,
            FixEyelinkMessages %then calculate and save it now
        end
        load(ET_matfiles{f}) %DN: load the ET mat file
        %Add an extra 4 rows into the EEG struct - 'TIME'
        %'GAZE_X' 'GAZE_Y' 'AREA'. This will add these as extra channels onto EEG.data
        %So the final channel is the pupil area (i.e. diameter):
        
        EEG = pop_importeyetracker(EEG,ET_matfiles{f},[first_event last_event]...
            ,[1:4] ,{'TIME' 'GAZE_X' 'GAZE_Y' 'AREA'},0,1,0,1);
    end
    
    if strcmp(subject_folder(s),'BL16\BL16_H')%BL16_H(64) has corrupted .edf file so just fill the eyetracker channels with zeros
        EEG.data(end+1:end+4,:) = 0;
        EEG.nbchan = size(EEG.data,1);
        if ~isempty(EEG.chanlocs)
            EEG.chanlocs(end+1).label = '';
        end;
    end
    
    Pupil_ch=length(EEG.data(:,1)); %Now that the eyelink data is added to the EEG struct Find the channel number for pupil area/diameter
    %%
    numev = length(EEG.event);
    
    % Fish out the event triggers and times
    clear trigs stimes RT motion_on
    for i=1:numev
        trigs(i)=EEG.event(i).type;
        stimes(i)=round(EEG.event(i).latency);
    end
    
    targtrigs = [];
    for i=1:length(trigs)
        if any(targcodes(:)==trigs(i))
            targtrigs = [targtrigs i];
        end
    end
    
    %         if trigs(targtrigs(end))==trialCond(1)
    %             motion_on = targtrigs(1:end-1); % GL: indices of trigs when motion on. get rid of last trig, it was a repeat
    %         else
    motion_on = targtrigs;
    %         end
    
    rejected_trial_n=zeros(length(motion_on),1);
    fixation_break_n=zeros(length(motion_on),1);
    artifact_PretargetToTarget_n=zeros(length(motion_on),1);
    artifact_BLintTo100msPostResponse_n=zeros(length(motion_on),1);
    artifact_BLintTo900ms_n=zeros(length(motion_on),1);
    artifact_neg500_to_0ms_n=zeros(length(motion_on),1);
        
    for n=1:length(motion_on)
        clear ep ep_HPF ep_alpha ep_art_reject ep_test ep_filt_Alpha_Hz ep_filt_abs_cut
        if ~isnan(motion_on(n))
            locktime = stimes(motion_on(n));
            try
                if motion_on(n)~=motion_on(end)%as long as it is not the final trial
                    A=find((trigs(motion_on(n)+1:motion_on(n+1)))==4);%find the relative position of all 4 (trials started) between current motion_on and next motion_on
                    TrialEndTrig=A(1); %mark the first of these, which marks the end of the current trial
                    clear A
                else %if it is the final trial
                    TrialEndTrig=length(trigs)-motion_on(end); %then just say trial end is the last recorded trigger
                end
                if any(ismember(trigs(motion_on(n):motion_on(n)+TrialEndTrig), 28))                                                  %If any trigger between the current motion_on and the end of that trial is...
                    fixation_break_n(n)=1;                                                                                             % a "28", then its a Fixation Break
                    rejected_trial_n(n)=1;
                    response_time = default_response_time*fs;
                elseif any(trigs(motion_on(n):motion_on(n)+TrialEndTrig)==12) % If there was a response before the start of the next trial
                    ResponseClicks=find(trigs(motion_on(n)+1:motion_on(n)+TrialEndTrig)==12);%position of any clicks relative to motion_on
                    response_time = stimes(motion_on(n)+ResponseClicks(1))-locktime; % time in samples from beginning of motion to the first response.
                    response_time = floor(response_time);
                    if response_time>default_response_time*fs
                        response_time = default_response_time*fs;
                    end
                    clear ResponseClicks
                else
                    response_time = default_response_time*fs;
                end
            catch
                response_time = default_response_time*fs;
            end
            try
                ep = EEG.data(1:nchan,locktime+ts);   % chop out an epoch
                ep_HPF = EEG_HPF.data(1:nchan,locktime+ts);
                ep_alpha = EEG_alpha.data(1:nchan,locktime+ts);
            catch
                disp('EEG ended too soon')
                allTrig(n) = 0;
                allrespLR(n) = 0;
                allRT(n) = 0;
                erp(:,:,n) = zeros(nchan,ERP_samps);
                erp_HPF(:,:,n) = zeros(nchan,ERP_samps);
                Alpha(:,:,n) = zeros(nchan,Alpha_samps);
                rejected_trial_n(n)=1;
                if ~strcmp(subject_folder(s),'TTN49')%for TTN49 we started EEG recording slightly too late so missed the first couple of EEG samples
                    if n ~= length(motion_on) %ignore it if this happens on final motion trigger, it was an extra/repeat and cut off
                        keyboard
                    end
                end
                continue;
            end
            
            try
                ep_pupil = EEG.data(Pupil_ch,locktime+ts);   % chop out an epoch of pupil diameter
            catch
                disp('Pupil Diameter data ended too soon')
                allTrig(n) = 0;
                allrespLR(n) = 0;
                allRT(n) = 0;
                Pupil(:,n) = zeros(Pupil_samps);
                rejected_trial_n(n)=1;
                keyboard
                continue;
            end
            
            BLamp =mean(ep(:,find(t>BLint(1) & t<BLint(2))),2); % record baseline amplitude (t<0) for each channel, 
            ep = ep - repmat(BLamp,[1,length(t)]); % baseline correction
            
            BLamp = mean(ep_HPF(:,find(t>BLint(1) & t<BLint(2))),2);
            ep_HPF = ep_HPF - repmat(BLamp,[1,length(t)]); % baseline correction
            
            BLamp = mean(ep_alpha(:,find(t>BLint(1) & t<BLint(2))),2);
            ep_alpha = ep_alpha - repmat(BLamp,[1,length(t)]); % baseline correction
            
            ep_test = [find(ts==-0.5*fs):find(ts==(0*fs))];
            if isempty(ep_test)
                disp('Empty epoch for art rejection')
                keyboard
            end
            ep_test = [find(t>BLint(1) & t<floor(((response_time*1000/fs)+100)))];
            if isempty(ep_test)
                disp('Empty epoch for art rejection2')
                keyboard
            end
            
            artifchans_thistrial = ARchans(find(max(abs(ep_HPF(ARchans,find(t<0))),[],2)>artifth | max(abs(ep_HPF(ARchans,find(t>BLint(1) & t<floor(((response_time*1000/fs)+100))))),[],2)>artifth));
            
            artifchans_blinks_thistrial = ARchans(find(max(abs(ep_HPF(ARchans_for_blinks,find(t<0))),[],2)>artifth));
            
            artifchans_blinks_thistrial(find(ismember(artifchans_blinks_thistrial,artifchans_thistrial))) = [];
            artifchans_thistrial = [artifchans_thistrial,artifchans_blinks_thistrial(find(~ismember(artifchans_blinks_thistrial,artifchans_thistrial)))];
            artifchans = [artifchans artifchans_thistrial];
            
            artifchans_PretargetToTarget_thistrial = ARchans(find(max(abs(ep_HPF(ARchans,find(ts==PretargetARwindow(1)*fs):find(ts==0))),[],2)>artifth));  % pre-target artifact rejection from -500-0ms only [find(ts==-.500*fs) gives you the point in samples -500ms before the target]
            artifchans_BLintTo100msPostResponse_thistrial = ARchans(find(max(abs(ep_HPF(ARchans,find(t>BLint(1) & t<floor(((response_time*1000/fs)+100))))),[],2)>artifth)); %Baseling until 100ms after response.
            
            artifchans_BLintTo900ms_thistrial = ARchans(find(max(abs(ep_HPF(ARchans,find(ts==-0.1*fs):find(ts==0.9*fs))),[],2)>artifth));  % artifact rejection from -100 to 900ms only
            
            artifchans_neg500_to_0ms_thistrial= ARchans(find(max(abs(ep_HPF(ARchans,find(ts==-0.5*fs):find(ts==0))),[],2)>artifth));  % artifact rejection from -700 to 0ms only
            
            if ~isempty(artifchans_thistrial)
                artifacts_anywhereInEpoch = artifacts_anywhereInEpoch+1;
            end   % artifact rejection (threshold test)
            
            if artifchans_PretargetToTarget_thistrial
                artifact_PretargetToTarget_n(n)=1;
            end
            
            if artifchans_BLintTo100msPostResponse_thistrial
                artifact_BLintTo100msPostResponse_n(n)=1;
            end
            
            if artifchans_BLintTo900ms_thistrial
                artifact_BLintTo900ms_n(n)=1;
            end
            
            if artifchans_neg500_to_0ms_thistrial
                artifact_neg500_to_0ms_n(n)=1;
            end
            
            ep = double(ep); % filtfilt needs doubles
            ep_HPF = double(ep_HPF);
            ep_pupil = double(ep_pupil);
            
            %%  Ger's method for alpha::
            ep_filt_Alpha_Hz = filtfilt(H1,G1,ep')'; % alpha filter again.
            
            %%%%%%%% rectifying the data and chopping off ends %%%%%%%%
            ep_filt_abs_cut = abs(ep_filt_Alpha_Hz(:,find(ts==ts_crop(1)):find(ts==ts_crop(end)))); % 64x701
            % Smoothing. This goes from 1:700, leaving out the final
            % sample, 0ms.
            alpha_temp = []; Alpha_smooth_time = []; Alpha_smooth_sample = [];
            for q = 1:size(ep_filt_abs_cut,1)
                counter = 1;
                for windowlock = 26:25:size(ep_filt_abs_cut,2)-25 % 1,26,51,etc. 26 boundaries = 1:50, 51 boundaries = 26:75, 676 boundaries = 651:
                    alpha_temp(q,counter) = mean(ep_filt_abs_cut(q,windowlock-25:windowlock+24));
                    Alpha_smooth_time(counter) = t_crop(windowlock);
                    Alpha_smooth_sample(counter) = ts_crop(windowlock);
                    counter = counter+1;
                end
            end
            
            %             figure
            %             plot(ep_filt_abs_cut(54,:))
            %             figure
            %             plot(Alpha_smooth_time,alpha_temp(54,:))
            %             keyboard
            
            %             figure, hold on, for i = 1:64, plot(ep(i,find(ts==ts_crop(1)):find(ts==ts_crop(end))),'b'), end; keyboard
            erp(:,:,n) = ep(:,find(ts==ts_crop(1)):find(ts==ts_crop(end)));
            
            erp_HPF(:,:,n) = ep_HPF(:,find(ts==ts_crop(1)):find(ts==ts_crop(end)));
            
            Pupil(:,n)= ep_pupil(find(ts==ts_crop(1)):find(ts==ts_crop(end)));
            
            Alpha(:,:,n) = alpha_temp;
            allTrig(n) = trigs(motion_on(n));
            try
                if motion_on(n)~=motion_on(end)%as long as it is not the final trial
                    A=find((trigs(motion_on(n)+1:motion_on(n+1)))==4);%find the relative position of all 4 (trials started) between current motion_on and next motion_on
                    TrialEndTrig=A(1); %mark the first of these, which marks the end of the current trial
                    clear A
                else %if it is the final trial
                    TrialEndTrig=length(trigs)-motion_on(end); %then just say trial end is the last recorded trigger
                end
                if ~any(ismember(trigs(motion_on(n):motion_on(n)+TrialEndTrig), 28))  %If no fixation break
                    if any(trigs(motion_on(n):motion_on(n)+TrialEndTrig)==12) % and if there was any response/s before the start of the next trial
                        ResponseClicks=find(trigs(motion_on(n)+1:motion_on(n)+TrialEndTrig)==12);%get position of any response clicks relative to motion_on
                        allrespLR(n) = 1;
                        allRT(n) = stimes(motion_on(n)+ResponseClicks(1))-stimes(motion_on(n)); % time in samples from beginning of motion to the first response.
                        clear ResponseClicks
                    else %else there was no response:
                        allrespLR(n) = 0;
                        allRT(n) = 0;
                    end
                else
                    allrespLR(n) = 0;
                    allRT(n) = 0;
                    fixation_break_n(n)=1;
                    rejected_trial_n(n)=1;
                end
            catch
                allrespLR(n) = 0;
                allRT(n) = 0;
                rejected_trial_n(n)=1; %DN
            end
        else
            rejected_trial_n(n)=1; %if isnan(motion_on(n)) - this should never happen since motion_on will always be a number
            allTrig(n) = 0;
            allrespLR(n) = 0;
            allRT(n) = 0;
            erp(:,:,n) = zeros(nchan,ERP_samps);
            erp_HPF(:,:,n) = zeros(nchan,ERP_samps);
            Alpha(:,:,n) = zeros(nchan,Alpha_samps);
            Pupil(:,n) = zeros(1,Pupil_samps);
        end
    end
end
Alpha = Alpha(1:nchan,:,:);
erp = erp(1:nchan,:,:);
erp_HPF = erp_HPF(1:nchan,:,:);
Pupil=Pupil(:,:);
figure;
hist(artifchans,[1:nchan]); title([allsubj{s} ': ' num2str(artifacts_anywhereInEpoch) ' artifacts = ',num2str(round(100*(artifacts_anywhereInEpoch/length(allRT)))),'%']) % s from runafew
disp([allsubj{s},' number of trials: ',num2str(length(allRT))])
if length(allRT)~=size(Alpha,3)
    disp(['WTF ',allsubj{s},' number of trials: ',num2str(length(allRT)),' not same as Alpha'])
end
save([path subject_folder{s} '\' allsubj{s} '_',num2str(bandlimits(1,1)),'_to_',num2str(bandlimits(1,2)), ...
    'Hz_neg',num2str(abs(t_crop(1))),'_to_',num2str(t_crop(end)),'_ARchans',num2str(ARchans(1)),'to',num2str(ARchans(end)),...
    '_',num2str(LPFcutoff),'HzLPF_point',strrep(num2str(HPFcutoff),'0.',''),'HzHPF_ET'],...
    'Alpha','erp','erp_HPF','Pupil','allRT','allrespLR','allTrig', ...
    'artifchans','t_crop','Alpha_smooth_time','Alpha_smooth_sample',...
    'artifact_PretargetToTarget_n','artifact_BLintTo100msPostResponse_n',...
    'fixation_break_n','rejected_trial_n','artifact_BLintTo900ms_n','artifact_neg500_to_0ms_n')
close all
return;


% %% STFT:
% nchan=65;
% fs=500;
% clear stftC
% TC = [-1500:100:700];%100ms sliding window
% fftlen = 300;
% F = [0:20]*fs/fftlen; %Frequencies
% for tt=1:length(TC)
%     temp = abs(fft(erp(:,find(t_crop>=TC(tt),1)-fftlen/2+[1:fftlen],:),[],2))./(fftlen/2);
%     stftC(:,:,tt,:) = reshape(temp(:,1:length(F),:),[nchan length(F) 1 size(erp,3)]);
% end %stftC(Electrode,Frequency,Time,Trial)
% 
% %Isolate time-range and collapse accross it
% Trange = find(TC>0 & TC<800);
% spec =squeeze(mean(stftC(:,:,Trange,:),3)); %spec(Electrode,Frequency,Trial)
% %Isolate frequency band within that time range and collapse accross it:
% band = find(F>8 & F<14);
% 
% PreAlpha=squeeze(mean(spec(:,band,:),2)); %PreAlpha(electrode trial)
% 
% 
% Alpha_simon=squeeze(mean(stftC(:,band,:,:),2)); %Alpha_simon(Electrode,Time,Trial)
% % 



