% getChannelVars.m 
% Computes and saves the channel variances for each block, so these
% can be plotted to look for bad channels using check4badchans.m.
% Variance calc from FFT spectrum so can avoid certain frequencies.
% list ALL BDF files in a study in a cell array of cell arrays such that
% files{s}{n} is the name of the nth file of session (subject) s.
% also list session IDs (subject initials or whatever) in cell array sessionID.
clear all
close all
clc

% datafolder = 'S:\R-MNHS-SPP\Bellgrove-data\4. Dan Newman\Blue Light Study\';

datafolder= 'C:\Users\Dan\Dropbox\Monash\PhD\Blue Light\Data\';
matfolder = datafolder;


%Brain products files from Monash

subject_folder = {'BL1\BL1_1','BL2\BL2_L','BL3\BL3_L','BL4\BL4_L','BL5\BL5_L','BL6\BL6_L','BL7\BL7_L','BL8\BL8_L','BL9\BL9_L','BL10\BL10_L','BL11\BL11_L','BL12\BL12_L','BL13\BL13_L','BL14\BL14_L','BL15\BL15_L','BL16\BL16_L','BL17\BL17_L','BL18\BL18_L','BL19\BL19_L','BL20\BL20_L','BL21\BL21_L','BL22\BL22_L','BL23\BL23_L','BL24\BL24_L'...
                  'BL1\BL1_M','BL2\BL2_M','BL3\BL3_M','BL4\BL4_M','BL5\BL5_M','BL6\BL6_M','BL7\BL7_M','BL8\BL8_M','BL9\BL9_M','BL10\BL10_M','BL11\BL11_M','BL12\BL12_M','BL13\BL13_M','BL14\BL14_M','BL15\BL15_M','BL16\BL16_M','BL17\BL17_M','BL18\BL18_M','BL19\BL19_M','BL20\BL20_M','BL21\BL21_M','BL22\BL22_M','BL23\BL23_M','BL24\BL24_M'...
                  'BL1\BL1_H','BL2\BL2_H','BL3\BL3_H','BL4\BL4_H','BL5\BL5_H','BL6\BL6_H','BL7\BL7_H','BL8\BL8_H','BL9\BL9_H','BL10\BL10_H','BL11\BL11_H','BL12\BL12_H','BL13\BL13_H','BL14\BL14_H','BL15\BL15_H','BL16\BL16_H','BL17\BL17_H','BL18\BL18_H','BL19\BL19_H','BL20\BL20_H','BL21\BL21_H','BL22\BL22_H','BL23\BL23_H','BL24\BL24_H'};
              
sessionID = {'BL1_1','BL2_L','BL3_L','BL4_L','BL5_L','BL6_L','BL7_L','BL8_L','BL9_L','BL10_L','BL11_L','BL12_L','BL13_L','BL14_L','BL15_L','BL16_L','BL17_L','BL18_L','BL19_L','BL20_M','BL21_L','BL22_L','BL23_L','BL4_L'...
            'BL1_M','BL2_M','BL3_M','BL4_M','BL5_M','BL6_M','BL7_M','BL8_M','BL9_M','BL10_Meeg','BL11_M','BL13_M','BL13_M','BL14_M','BL15_M','BL16_M','BL17_M','BL18_M','BL19_M','BL20_Mm','BL21_M','BL22_M','BL23_M','BL24_M'...
            'BL1_H','BL2_H','BL3_H','BL4_H','BL5_H','BL6_H','BL7_H','BL8_H','BL9_H','BL10_H','BL11_H','BL12_H','BL13_H','BL14_H','BL15_H','BL16_H','BL17_H','BL18_H','BL19_H','BL20_H','BL21_H','BL22_H','BL23_H','BL24_H'};  

        
% subject_folder = {'BL19\BL19_L','BL19\BL19_M','BL19\BL19_H','BL20\BL20_L','BL20\BL20_M','BL20\BL20_H','BL21\BL21_L','BL21\BL21_M','BL21\BL21_H','BL22\BL22_L','BL22\BL22_M','BL22\BL22_H','BL23\BL23_L','BL23\BL23_M','BL23\BL23_H','BL24\BL24_L','BL24\BL24_M','BL24\BL24_H'};

% sessionID = {'BL19_L','BL19_M','BL19_H','BL20_M','BL20_Mm','BL20_H','BL21_L','BL21_M','BL21_H','BL22_L','BL22_M','BL22_H','BL23_L','BL23_M','BL23_H','BL4_L','BL24_M','BL24_H'}; 

        

file_start = 1;
blocks = {[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],...
            [1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],...
            [1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1]...
            ,[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1]...
            ,[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1]}; %DN


clear files matfile
for s=file_start:length(sessionID)
        f=0;
        for b=blocks{s}
            f=f+1;
     files{s}{f} = [datafolder subject_folder{s} '\' sessionID{s},'.vhdr']; %DN
        end
     matfile{s} = [matfolder subject_folder{s} '\' sessionID{s} '_chanvars.mat']; %DN
end

% how much of the spectrum to use?
speclims = [4 48];  % Limits in Hz

minBreakDur_s = 25;  % number of seconds defining a "break" between blocks within a data file. Was using 2 for CTET
minBlockDur_s = 60; % a block must be at least 30s, otherwise the pause btw triggers is something else.

%chanlocs = readlocs('cap64.loc');
%chanlocs = readlocs('cap128.loc');
chanlocs = readlocs ('actiCAP64_ThetaPhi.elp','filetype','besa'); %DN for actiCAP


%%%%%%%%%%%%%%%%%%%%% From here it's all standard

h = waitbar(0,'Please wait...');
steps = length(sessionID);
step = file_start-1;                
for s=file_start:length(sessionID)
    disp(s)
    tic
    % First go through the blocks and see if there are breaks (defined by time btw triggers of minBreakDur_s seconds)
    % if there are, then find the block breaks and read files in block by block:
    if s==file_start
        waitbar(step/steps,h)
    else
        min_time = round((end_time*(steps-step))/60);
        sec_time = round(rem(end_time*(steps-step),60));
%         waitbar(step/steps,h,[num2str(min_time),' minutes, ',num2str(sec_time),' seconds remaining'])
        waitbar(step/steps,h,[num2str(min_time), ' minutes remaining'])
    end        
    step=step+1;
    numb=0; clear files1 blockrange;
        
    clear chanVar
    for b=1:length(files{s}) %DN
        % For the purposes of looking for bad channels, it seems most sensible to leave the BDF referenced as it was recorded.
        % If we average-reference, a bad channel's badness is diluted and may spread to other channels.
        % With a single reference channel, it would be ok, as long as that channel is clean.
  
        folder = subject_folder{s};
        EEG = pop_loadbv ([datafolder folder],['' sessionID{s} '.vhdr']); %DN: still need to add the equivelent to 'blockrange' (see above) in here 
        EEG = pop_rmdat( EEG, {'boundary'},[0 1] ,1); %DN: this deletes the data from 0 to 1 sec around the DC Correction triggers that BrainVision puts in
        for i=1:length([EEG.event.latency]) %DN: round the event latencies back to whole numbers (intergers), because the pop_rmdat line (above) makes non-interger latencies at the points where you kicked out the bad DC Correction data  
            EEG.event(i).latency = round([EEG.event(i).latency]);
        end
        EEG = letterkilla_old(EEG); %DN: this gets rid of the 'S' that BrainVision appends to the triggers and changes all the 'boundary' triggers to '-88' 
        if EEG.srate>500,
            EEG = pop_resample(EEG, 500);
        end
        % Fish out the event triggers and times
        clear trigs stimes
        for i=1:length(EEG.event)
            trigs(i)=EEG.event(i).type;
            stimes(i)=EEG.event(i).latency;
        end
        temp = abs(fft(EEG.data(:,stimes(1):stimes(end))'))'; % FFT amplitude spectrum
        tempF = [0:size(temp,2)-1]*EEG.srate/size(temp,2); % Frequency scale
        chanVar(:,b) = mean(temp(:,find(tempF>speclims(1) & tempF<speclims(2))),2);       % ROW of variances
        
    end

    save(matfile{s},'chanlocs','chanVar')
    end_time = toc;
end
close(h)

