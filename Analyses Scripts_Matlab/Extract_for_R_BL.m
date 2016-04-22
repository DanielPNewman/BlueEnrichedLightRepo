clear all
close all
clc

% path ='C:\Users\Dan\Dropbox\Monash\PhD\Blue Light\Data\'; %DN
path='C:\Users\newmand\Dropbox\Monash\PhD\Blue Light\Data\';

subject_folder = {'BL1','BL2','BL3','BL4','BL5','BL6','BL7','BL8','BL9','BL10','BL11','BL12','BL13','BL14','BL15','BL16','BL17','BL18','BL19','BL20','BL21','BL22','BL23','BL24'};
allsubj=         {'BL1','BL2','BL3','BL4','BL5','BL6','BL7','BL8','BL9','BL10','BL11','BL12','BL13','BL14','BL15','BL16','BL17','BL18','BL19','BL20','BL21','BL22','BL23','BL4'};

%Low Light
subject_folder_L = {'BL1\BL1_1','BL2\BL2_L','BL3\BL3_L','BL4\BL4_L','BL5\BL5_L','BL6\BL6_L','BL7\BL7_L','BL8\BL8_L','BL9\BL9_L','BL10\BL10_L','BL11\BL11_L','BL12\BL12_L','BL13\BL13_L','BL14\BL14_L','BL15\BL15_L','BL16\BL16_L','BL17\BL17_L','BL18\BL18_L','BL19\BL19_L','BL20\BL20_L','BL21\BL21_L','BL22\BL22_L','BL23\BL23_L','BL24\BL24_L'};
allsubj_L = {'BL1_1','BL2_L','BL3_L','BL4_L','BL5_L','BL6_L','BL7_L','BL8_L','BL9_L','BL10_L','BL11_L','BL12_L','BL13_L','BL14_L','BL15_L','BL16_L','BL17_L','BL18_L','BL19_L','BL20_M','BL21_L','BL22_L','BL23_L','BL4_L'};
%Medium Light
subject_folder_M = {'BL1\BL1_M','BL2\BL2_M','BL3\BL3_M','BL4\BL4_M','BL5\BL5_M','BL6\BL6_M','BL7\BL7_M','BL8\BL8_M','BL9\BL9_M','BL10\BL10_M','BL11\BL11_M','BL12\BL12_M','BL13\BL13_M','BL14\BL14_M','BL15\BL15_M','BL16\BL16_M','BL17\BL17_M','BL18\BL18_M','BL19\BL19_M','BL20\BL20_M','BL21\BL21_M','BL22\BL22_M','BL23\BL23_M','BL24\BL24_M'};
allsubj_M = {'BL1_M','BL2_M','BL3_M','BL4_M','BL5_M','BL6_M','BL7_M','BL8_M','BL9_M','BL10_Meeg','BL11_M','BL13_M','BL13_M','BL14_M','BL15_M','BL16_M','BL17_M','BL18_M','BL19_M','BL20_Mm','BL21_M','BL22_M','BL23_M','BL24_M'};
%High Light
subject_folder_H = {'BL1\BL1_H','BL2\BL2_H','BL3\BL3_H','BL4\BL4_H','BL5\BL5_H','BL6\BL6_H','BL7\BL7_H','BL8\BL8_H','BL9\BL9_H','BL10\BL10_H','BL11\BL11_H','BL12\BL12_H','BL13\BL13_H','BL14\BL14_H','BL15\BL15_H','BL16\BL16_H','BL17\BL17_H','BL18\BL18_H','BL19\BL19_H','BL20\BL20_H','BL21\BL21_H','BL22\BL22_H','BL23\BL23_H','BL24\BL24_H'};
allsubj_H = { 'BL1_H','BL2_H','BL3_H','BL4_H','BL5_H','BL6_H','BL7_H','BL8_H','BL9_H','BL10_H','BL11_H','BL12_H','BL13_H','BL14_H','BL15_H','BL16_H','BL17_H','BL18_H','BL19_H','BL20_H','BL21_H','BL22_H','BL23_H','BL24_H'};

duds = []; %
single_participants = [];
file_start = 1;

HPF=1; %Use high-pass filtered erp? 1=yes, 0=no

ch_LR = [23,56;27,59];
ch_CPP = [25]; %Pz

load('SessionOrder_Participant_by_Light')%load the order (1st, 2nd, 3rd) each participant completed the 3 light contitions - participant x light(low,Med,High)
load('KSS_BeforeMinusAfterLight_Participant_by_Light')%Difference in KSS sleepiness scale before vs after light, participant x light(low,Med,High)
load('Sex')%participant Gender 1=Male/2=Female:
load('Age')%Age on day of testing
load('LightConds_Order')%1=HML, 2=HLM, 3=MHL, 4=MLH, 5=LHM,6=LMH
load('LightCondsGuessedCorrectly')%1=guessed correctly, 0=incorrectly
load('LightCondsGuess_Confidence')%How confident they were about their guess on scale of 1-10

if ~isempty(duds) && isempty(single_participants)
    subject_folder([duds]) = [];
    allsubj([duds]) = [];
end

if ~isempty(single_participants)
    subject_folder = subject_folder(single_participants);
    allsubj = allsubj(single_participants);
end

% patch,motion,ITI
targcodes = zeros(4,2,3);
targcodes(1,1,:) = [101 109 117]; % patch 1, up motion
targcodes(1,2,:) = [102 110 118]; % patch 1, down motion
targcodes(2,1,:) = [103 111 119]; % patch 2, up motion
targcodes(2,2,:) = [104 112 120]; % patch 2, down motion
targcodes(3,1,:) = [105 113 121]; % patch 3, up motion
targcodes(3,2,:) = [106 114 122]; % patch 3, down motion
targcodes(4,1,:) = [107 115 123]; % patch 4, up motion
targcodes(4,2,:) = [108 116 124]; % patch 4, down motion

rtlim=[0.2 2]; %RT must be between 200ms and 2000ms
fs=500; % sample rate %500Hz

%response locked erp epoch
trs = [-.500*fs:fs*.100]; %in samples
tr = trs*1000/fs; %in ms

master_matrix_R = []; % This saves the matrix for SPSS/R analysis.
total_numtr = 0;
ID_vector=cell(30000,1); %this will save the subjects ID for each single trial can be pasted into SPSS for ID column. Code at the end of the script clear the emplt cells

for s=1:length(allsubj)
    disp(['Subject: ',num2str(s)])
    disp(['Subject: ',allsubj{s}])
    matfile='_8_to_13Hz_neg500_to_1000_ARchans1to65_35HzLPF_point0HzHPF_ET';
    
    load([path subject_folder{s} '\' allsubj{s} '_ROIs.mat']); %load the participant's individualised Alpha ROI electrodes sensitive to Light
    
    for LC=1:3 %LC= light condition (low medium high)
        if LC==1
            load([path subject_folder_L{s} '\' allsubj_L{s} matfile]);  %variables needed from these matfiles: 'Alpha','erp','erp_HPF','Pupil','Alpha_smooth_time','allRT','allrespLR','allTrig','t_crop','artifact_BLintTo100msPostResponse_n','artifact_PretargetToTarget_n','fixation_break_n','rejected_trial_n','artifact_neg500_to_0ms_n'
            load([path subject_folder_L{s} '\' allsubj_L{s} '_ROIs.mat']);
        elseif LC==2
            load([path subject_folder_M{s} '\' allsubj_M{s} matfile]);
            load([path subject_folder_M{s} '\' allsubj_M{s}  '_ROIs.mat']);%Loads individualised Alpha ROI electrodes sensitive to spatial attention orienting
        elseif LC==3
            load([path subject_folder_H{s} '\' allsubj_H{s} matfile]);
            load([path subject_folder_H{s} '\' allsubj_H{s} '_ROIs.mat']);
        end
        
        if HPF %Use high-pass filtered erp?
            erp=erp_HPF;
        end
        
        allTrials=allTrig; % just renamed this because it makes more sense to me to call it trials
        
        %% calculate the response locked ERPs
        erpr = zeros(size(erp,1),length(tr),size(erp,3));
        validrlock = zeros(1,length(allRT)); % length of RTs.
        for n=1:length(allRT);
            [blah,RTsamp] = min(abs(t_crop*fs/1000-allRT(n))); % get the sample point of the RT.
            if RTsamp+trs(1) >0 & RTsamp+trs(end)<=length(t_crop) & allRT(n)>0 % is the RT larger than 1st stim RT point, smaller than last RT point.
                erpr(:,:,n) = erp(:,RTsamp+trs,n);
                validrlock(n)=1;
            end
        end
        %%
        
        %DN: master_matrix_R columns:
        %1.Subject number 2.Light Condition 3.total trial number 4.inter-subject trial number
        %5.ITI 6.Target Side 7.Target upper/Lower visual field  8.Motion Directio
        %9.Accuracy 10.Fixation Break or Blink 11.Artefact during pre-target window
        %12.Artefact during post-target window 13.Artefact anwhere in pre-target window
        %14.Rejected trial 15.Reaction time (RT) 16.Pre-target Alpha Power overall
        %17.Pre-target Alpha Power Left Hemi 18.Pre-target Alpha Power Right Hemi
        %19.Pre-target AlphaAsym 20.Pre-target Pupil Diameter  21.Sex 22.Age
        %23.Number of repeated trials due to fixation breaks 24.Light Condition Order
        %25.KSS_BeforeMinusAfter 26.Light Conditions Guessed Correctly
        %27.Cond_Guessed_Confidence 28.Session (1st, 2nd or 3rd) %29. Target Patch quadrant
        %30. Alpha Power from all parietal and occipital electrodes 
        
        
        for trial=1:length(allTrials) % 
            total_numtr = total_numtr+1;
            ID_vector(total_numtr) = subject_folder(s);
            %% 1. Subject number:
            master_matrix_R(total_numtr,1) = s;
            %% 2. Light Condition:
            master_matrix_R(total_numtr,2) = LC; % (1=Low 2=Medium 3=High)
            %% 3. total trial number:
            master_matrix_R(total_numtr,3) = total_numtr;
            %% 4. inter-subject trial number
            master_matrix_R(total_numtr,4) = trial;
            %% 5. ITI:
            if ismember (allTrials(trial), targcodes(:,:,1)) % any ITI1 targcode.
                master_matrix_R(total_numtr,5) = 1;
            elseif ismember (allTrials(trial), targcodes(:,:,2))% any ITI2 targcode.
                master_matrix_R(total_numtr,5) = 2;
            else
                master_matrix_R(total_numtr,5) = 3; % any ITI3 targcode.
            end
            %% 6. Target Side:
            if ismember(allTrials(trial),targcodes(1,:,:))||ismember(allTrials(trial),targcodes(3,:,:)) % any left patch targcode. i.e. left target
                master_matrix_R(total_numtr,6) = 1;
            else
                master_matrix_R(total_numtr,6) = 2; %right target
            end
            %% 7. Target upper/Lower visual field:
            if ismember(allTrials(trial),targcodes(1,:,:))||ismember(allTrials(trial),targcodes(2,:,:)) % any upper visual visual field patch targcode.
                master_matrix_R(total_numtr,7) = 1;
            else
                master_matrix_R(total_numtr,7) = 2; %Lower visual field (2)
            end
            %% 8. Motion Direction:
            if ismember(allTrials(trial),targcodes(:,1,:)) % any up motion targcode.
                master_matrix_R(total_numtr,8) = 1; % Uppward motion
            else
                master_matrix_R(total_numtr,8) = 2; %Downward motion
            end
            %% 9. Accuracy:
            master_matrix_R(total_numtr,9) = allrespLR(trial); %1=correct 0=wrong
            %% 10. Fixation Break or Blink:
            master_matrix_R(total_numtr,10) = fixation_break_n(trial); %0=no fixation or blink; 1=there was a fixation break or blink
            %% 11. Artefact during pre-target window (-500 - 0ms):
            master_matrix_R(total_numtr,11)= artifact_PretargetToTarget_n(trial);
            %% 12. Artefact during post-target window (-100ms to 100ms after response):
            master_matrix_R(total_numtr,12)= artifact_BLintTo100msPostResponse_n(trial);
            %% 13. Artefact anwhere in pre-target window (-500 to 0ms)
            master_matrix_R(total_numtr,13)=artifact_neg500_to_0ms_n(trial);
            %% 14. Rejected trial
            master_matrix_R(total_numtr,14)=rejected_trial_n(trial);
            %% 15. Reaction time (RT):
            master_matrix_R(total_numtr,15)=allRT(trial)*1000/fs;
            %% 16. Pre-target Alpha Power overall (combining the two individualized ROIs):
            master_matrix_R(total_numtr,16)=squeeze(mean(mean(Alpha([LH_ROI_s RH_ROI_s],find(Alpha_smooth_time==-450):find(Alpha_smooth_time==0),trial),1),2));
            %% 17. Pre-target Alpha Power Left Hemi _Control:
            master_matrix_R(total_numtr,17)=squeeze(mean(mean(Alpha([LH_ROI_s],find(Alpha_smooth_time==-450):find(Alpha_smooth_time==0),trial),1),2));
            %% 18. Pre-target Alpha Power Right Hemi (individualized ROI):
            master_matrix_R(total_numtr,18)=squeeze(mean(mean(Alpha([RH_ROI_s],find(Alpha_smooth_time==-450):find(Alpha_smooth_time==0),trial),1),2));
            %% 19.  Pre-target AlphaAsym:
            if master_matrix_R(total_numtr,17) && master_matrix_R(total_numtr,18)
                master_matrix_R(total_numtr,19)=(master_matrix_R(total_numtr,18)-master_matrix_R(total_numtr,17))/(master_matrix_R(total_numtr,18)+master_matrix_R(total_numtr,17)); %(RightHemiROI - LeftHemiROI)/(RightHemiROI + LeftHemiROI)
            else
                master_matrix_R(total_numtr,19)=0;
            end
            %% 20. Pre-target Pupil Diameter:
            master_matrix_R(total_numtr,20)=mean(Pupil(find(t_crop==-500):find(t_crop==0),trial));
            %% 21. Sex
            master_matrix_R(total_numtr,21)=Sex(s);
            %% 22. Age
            master_matrix_R(total_numtr,22)=Age(s);
            %% 23. Number of repeated trials due to fixation breaks:
            master_matrix_R(total_numtr,23)=length(allRT(~(~fixation_break_n) & ~(~rejected_trial_n)));
            %% 24. Light Condition Order:
            master_matrix_R(total_numtr,24)=LightConds_Order(s);
            %% 25. KSS_BeforeMinusAfter:
            master_matrix_R(total_numtr,25)=KSS_BeforeMinusAfterLight(s,LC);
            %% 26. Light Conditions Guessed Correctly:
            master_matrix_R(total_numtr,26)=LightCondsGuessedCorrectly(s);
            %% 27. Cond_Guessed_Confidence:
            master_matrix_R(total_numtr,27)=LightCondsGuess_Confidence(s);
            %% 28. Session (1st, 2nd or 3rd):
            master_matrix_R(total_numtr,28)=SessionOrder_Participant_by_Light(s,LC);
            %% 29. Target Patch quadrant
            if ismember(allTrials(trial),targcodes(1,:,:)) % Left Upper quadrant (i.e. target appeared in the patch in the Left Upper quadrant)
                master_matrix_R(total_numtr,29) = 1;
            elseif ismember(allTrials(trial),targcodes(2,:,:)) %Right Upper quadrant
                master_matrix_R(total_numtr,29) = 2;
            elseif ismember(allTrials(trial),targcodes(3,:,:)) %Left Lower quadrant
                master_matrix_R(total_numtr,29) = 3;
            else
                master_matrix_R(total_numtr,29) = 4; %Right Lower quadrant
            end
            %% 30. Alpha Power from all parietal and occipital electrodes ("P" and "O" electrodes, not "TP" or "CP" electrodes):
            all_parietal_occipital=[23:32, 56:64];
            master_matrix_R(total_numtr,30)=squeeze(mean(mean(Alpha(all_parietal_occipital,find(Alpha_smooth_time==-450):find(Alpha_smooth_time==0),trial),1),2));
        end
    end
end
% find empty cells in ID_vector
emptyCells = cellfun(@isempty,ID_vector);
% remove empty cells
ID_vector(emptyCells) = [];

%Save the data in .csv format to be read into R for inferential stats analysis
csvwrite ('master_matrix_R.csv',master_matrix_R)

cell2csv ('ID_vector.csv',ID_vector)

