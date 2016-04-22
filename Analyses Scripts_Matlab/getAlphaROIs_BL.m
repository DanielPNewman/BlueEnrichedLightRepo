 %extracts and saves individualised ROI electrodes for each partivipant's pre-target 
 %alpha measurements by finding four electrodes per hemisphere with maximal difference 
 %in mean post-target (50-600ms) a-desynchronisation for contralateral versus ipsilateral 
 %targets (calculated from average post-target a waveforms for each session) selected from 
 %the 16 lateral parieto-occipital electrodes (left hemisphere P1, P3, P5, P7, PO3, PO7 PO9, O1; 
 %right-hemisphere P2, P4, P6, P8, PO4, PO8, PO10, O2).
%based on max post-target alpha desynchronisation to contralateral targets.

clear all
close all
clc
chanlocs = readlocs ('actiCAP65_ThetaPhi.elp','filetype','besa'); %DN for actiCAP

path='C:\Users\newmand\Dropbox\Monash\PhD\Blue Light\Data\';
% path='C:\Users\Dan\Dropbox\Monash\PhD\Blue Light\Data\';

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

allblocks = {[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],...
    [1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],...
    [1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1]...
    ,[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1]...
    ,[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1]...
    ,[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1]...
    ,[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1],[1]};

duds = [];
single_participants = [];
file_start = 1;

HPF=0; %Use high-pass filtered erp? 1=yes, 0=no

if ~isempty(duds) && isempty(single_participants)
    subject_folder([duds]) = [];
    allsubj([duds]) = [];
    allblocks([duds]) = [];
    subject_folder_L([duds]) = [];
    allsubj_L([duds]) = [];
    subject_folder_M([duds]) = [];
    allsubj_M([duds]) = [];
    subject_folder_H([duds]) = [];
    allsubj_H([duds]) = [];
    
end

if ~isempty(single_participants)
    subject_folder = subject_folder(single_participants);
    allsubj = allsubj(single_participants);
    allblocks = allblocks(single_participants);
    subject_folder_L = subject_folder_L(single_participants);
    allsubj_L = allsubj_L(single_participants);
    subject_folder_M = subject_folder_M(single_participants);
    allsubj_M = allsubj_M(single_participants);
    subject_folder_H = subject_folder_H(single_participants);
    allsubj_H = allsubj_H(single_participants);
end

% patch,motion,instance
targcodes = zeros(4,2,3);
targcodes(1,1,:) = [101 109 117]; % patch 1, up motion
targcodes(1,2,:) = [102 110 118]; % patch 1, down motion
targcodes(2,1,:) = [103 111 119]; % patch 2, up motion
targcodes(2,2,:) = [104 112 120]; % patch 2, down motion
targcodes(3,1,:) = [105 113 121]; % patch 3, up motion
targcodes(3,2,:) = [106 114 122]; % patch 3, down motion
targcodes(4,1,:) = [107 115 123]; % patch 4, up motion
targcodes(4,2,:) = [108 116 124]; % patch 4, down motion

fs=500;
numch=65;
rtlim=[0.05 1];
[B,A]=butter(4,8*2/fs);


left_hemi_chans = [1,3,4,8,9,12,13,17,18,19,23,24,28,29,33,34,37,38,41,42,43,47,48,51,52,56,57,60,61];
right_hemi_chans =[2,7,6,11,10,16,15,22,21,20,27,26,32,31,36,35,40,39,46,45,44,50,49,55,54,59,58,64,63];
centre_chans = [5,14,25,30,53,53,62];

BLint = [-100 0];   % baseline interval in ms

ts = -0.5*fs:1*fs;   % in sample points, the ERP epoch
t = ts*1000/fs;

trs = [-.500*fs:fs*.100];
tr = trs*1000/fs;

RH_ROI_allsubj=zeros(length(allsubj),4);
LH_ROI_allsubj=zeros(length(allsubj),4);

for s=file_start:length(allsubj)
    disp('-------#############################################-------');
    for LC=1:3 %LC= light condition (low medium high)
        disp('#################################################');
        erp=[];erp_HPF=[]; Alpha=[]; RT_bin_1 = []; RT_bin_2 = []; RT_bin_3 = [];

        matfile='_8_to_13Hz_neg500_to_1000_ARchans1to65_35HzLPF_point0HzHPF_ET';
        if LC==1
            load([path subject_folder_L{s} '\' allsubj_L{s} matfile]); %variables needed from these matfiles: 'Alpha','erp','erp_HPF','Pupil','Alpha_smooth_time','allRT','allrespLR','allTrig','t_crop','artifact_BLintTo100msPostResponse_n','artifact_PretargetToTarget_n','fixation_break_n','rejected_trial_n','artifact_neg500_to_0ms_n'
        elseif LC==2
            load([path subject_folder_M{s} '\' allsubj_M{s} matfile]);
        elseif LC==3
            load([path subject_folder_H{s} '\' allsubj_H{s} matfile]);
        end
        
        if HPF
            erp=erp_HPF;
        end
        
        %Kick out trials with fixation_breaks
        Alpha=Alpha(:,:,~fixation_break_n' & ~rejected_trial_n');
        allRT=allRT(~fixation_break_n' & ~rejected_trial_n');
        allrespLR=allrespLR(~fixation_break_n' & ~rejected_trial_n');
        allTrig=allTrig(~fixation_break_n' & ~rejected_trial_n');
        artifact_PretargetToTarget_n=artifact_PretargetToTarget_n(~fixation_break_n' & ~rejected_trial_n');
        artifact_BLintTo100msPostResponse_n=artifact_BLintTo100msPostResponse_n(~fixation_break_n' & ~rejected_trial_n');
        
        
        validrlock = zeros(1,length(allRT)); % length of RTs.
        for n=1:length(allRT);
            [blah,RTsamp] = min(abs(t*fs/1000-allRT(n))); % get the sample point of the RT.
            if RTsamp+trs(1) >0 & RTsamp+trs(end)<=length(t) & allRT(n)>0 % is the RT larger than 1st stim RT point, smaller than last RT point.
                erpr(:,:,n) = erp(:,RTsamp+trs,n);
                validrlock(n)=1;
            end
        end
        
        % patch,motion,ITI
        for patch = 1:4
            for motion = 1:2
                for i = 1:3
                    % calcs the indices of the triggers for each
                    % appropriate trial type.
                    conds1{s,patch,motion,i,LC} = find(allTrig==targcodes(patch,motion,i) & allrespLR==1 & ...
                        allRT>rtlim(1)*fs & allRT<rtlim(2)*fs & validrlock);
                end
            end
        end
        
        conds_all = [conds1{s,:,:,:,LC}];
        allRT_zscores = zeros(size(allRT));
        allRT_zscores(conds_all) = zscore(log10(allRT(conds_all)*1000/fs));
        
        for patch = 1:4
            for motion = 1:2
                for i = 1:3
                    conds_RT{s,patch,motion,i,LC} = find(allTrig==targcodes(patch,motion,i) & allrespLR==1 & allRT>rtlim(1)*fs & allRT<rtlim(2)*fs & ...
                        allRT_zscores>-3 & allRT_zscores<3);
                    avRT{s,patch,motion,i,LC} = allRT(conds_RT{s,patch,motion,i,LC})*1000/fs;
                    RT_Zs{s,patch,motion,i,LC} = allRT_zscores(conds_RT{s,patch,motion,i,LC});
                    
                    %Save alpha with Pre-target artifact trials kicked out (i.e. artifact_PretargetToTarget_n)
                    conds_PreAlpha{s,patch,motion,i,LC} = find(allTrig==targcodes(patch,motion,i) & allrespLR==1 & allRT>rtlim(1)*fs & allRT<rtlim(2)*fs & ... %make a different conds for Pupil kicking out pre-target pupil outliers
                        allRT_zscores>-3 & allRT_zscores<3 & ~artifact_PretargetToTarget_n');
                    Alpha_temp = squeeze(Alpha(1:numch,:,[conds_PreAlpha{s,patch,motion,i,LC}]));
                    PreAlpha_cond(s,:,:,patch,motion,i,LC) = squeeze(mean(Alpha_temp,3)); %Alpha_cond (Subject, channel, samples, patch, motion, i, LC)
                    
                    %Save alpha with Post-target artifact trials kicked out (i.e. artifact_BLintTo100msPostResponse_n
                    conds_PostAlpha{s,patch,motion,i,LC} = find(allTrig==targcodes(patch,motion,i) & allrespLR==1 & allRT>rtlim(1)*fs & allRT<rtlim(2)*fs & ... %make a different conds for Pupil kicking out pre-target pupil outliers
                        allRT_zscores>-3 & allRT_zscores<3 & ~artifact_BLintTo100msPostResponse_n');
                    Alpha_temp = squeeze(Alpha(1:numch,:,[conds_PostAlpha{s,patch,motion,i,LC}]));
                    PostAlpha_cond(s,:,:,patch,motion,i,LC) = squeeze(mean(Alpha_temp,3)); %Alpha_cond (Subject, channel, samples, patch, motion, i, LC)
                    
                end
            end
        end
        
        disp(['Subject ',allsubj{s},' Light_Cond_',num2str(LC),' Total Valid Trials: ',num2str(length([conds_PreAlpha{s,:,:,:,LC}])),' = ',num2str(round(100*length([conds_PreAlpha{s,:,:,:,LC}])/(336))),'%'])
        disp(['Subject ',allsubj{s},' Light_Cond_',num2str(LC),' Total Left Trials: ',num2str(length([conds_PreAlpha{s,[1,3],:,:,LC}])),' = ',num2str(round(100*length([conds_PreAlpha{s,[1,3],:,:,LC}])/((336)/2))),'%'])
        disp(['Subject ',allsubj{s},' Light_Cond_',num2str(LC),' Total Right Trials: ',num2str(length([conds_PreAlpha{s,[2,4],:,:,LC}])),' = ',num2str(round(100*length([conds_PreAlpha{s,[2,4],:,:,LC}])/((336)/2))),'%'])
        disp(['Subject ',allsubj{s},' Light_Cond_',num2str(LC),' Total Upper Left Trials: ',num2str(length([conds_PreAlpha{s,[3],:,:,LC}])),' = ',num2str(round(100*length([conds_PreAlpha{s,[3],:,:,LC}])/((336)/4))),'%'])
        disp(['Subject ',allsubj{s},' Light_Cond_',num2str(LC),' Total Upper Right Trials: ',num2str(length([conds_PreAlpha{s,[4],:,:,LC}])),' = ',num2str(round(100*length([conds_PreAlpha{s,[4],:,:,LC}])/((336)/4))),'%'])
        disp(['Subject ',allsubj{s},' Light_Cond_',num2str(LC),' Total Lower Left Trials: ',num2str(length([conds_PreAlpha{s,[1],:,:,LC}])),' = ',num2str(round(100*length([conds_PreAlpha{s,[1],:,:,LC}])/((336)/4))),'%'])
        disp(['Subject ',allsubj{s},' Light_Cond_',num2str(LC),' Total Lower Right Trials: ',num2str(length([conds_PreAlpha{s,[2],:,:,LC}])),' = ',num2str(round(100*length([conds_PreAlpha{s,[2],:,:,LC}])/((336)/4))),'%'])
    end
end


%% Topoplot of Grand Average Pre-target Alpha High Minus Low Light conditions
%Alpha_cond (Subject, channel, samples, patch, motion, i, LC)
PreAlphaHightMinusLow=squeeze(mean(mean(mean(mean(mean(PreAlpha_cond(:,:,find(Alpha_smooth_time==-450):find(Alpha_smooth_time==0),:,:,:,3),6),5),4),3),1))...
    -squeeze(mean(mean(mean(mean(mean(PreAlpha_cond(:,:,find(Alpha_smooth_time==-450):find(Alpha_smooth_time==0),:,:,:,1),6),5),4),3),1)); %PreAlphaHightMinusLow(channel)
figure
topoplot (PreAlphaHightMinusLow,chanlocs,'electrodes','off');
title('Effect of Light on pre-target Alpha power')
%% Topoplot of  Grand Average Post target Alpha, left minus right target
%Alpha_cond (Subject, channel, samples, patch, motion, i, LC)
PostAlpha_left_minus_rightTarget=squeeze(mean(mean(mean(mean(mean(mean(PostAlpha_cond(:,:,find(Alpha_smooth_time==50):find(Alpha_smooth_time==600),[1,3],:,:,:),7),6),5),4),3),1))...
    -squeeze(mean(mean(mean(mean(mean(mean(PostAlpha_cond(:,:,find(Alpha_smooth_time==50):find(Alpha_smooth_time==600),[2,4],:,:,:),7),6),5),4),3),1)); %PostAlpha_left_minus_rightTarget(channel)
figure
topoplot (PostAlpha_left_minus_rightTarget,chanlocs,'electrodes','off');


%%
% This section finds the best LH and RH ROI electrodes for each participant
% defined as the four occipito-parietal electrodes per hemisphere for each participant were those
% with maximal difference in post-target (50-600ms) alpha desynchronisation
% for contralateral verses ipsilateral targets (calculated from each
% participants’ average alpha waveforms from each session

PostAlpha_left_minus_rightTarget2=squeeze(mean(mean(mean(mean(PostAlpha_cond(:,:,find(Alpha_smooth_time==50):find(Alpha_smooth_time==600),[1,3],:,:,:),6),5),4),3))...
    -squeeze(mean(mean(mean(mean(PostAlpha_cond(:,:,find(Alpha_smooth_time==50):find(Alpha_smooth_time==600),[2,4],:,:,:),6),5),4),3)); %PostAlpha_left_minus_rightTarget2(subject,channel,LC)

LH_elec=[23,24,28,29,56,57,60,61];
RH_elec=[26,27,31,32,58,59,63,64];

for s=file_start:length(allsubj)  %DN: For each participant this specify the 4 occipito-pariatal electrodes for each hemisphere that show the greatest desyncronisation difference between cont/ipsilateral targets
    for LC=1:3
        LH_desync(s,:)= PostAlpha_left_minus_rightTarget2(s,LH_elec,LC);
        [temp1,temp2] = sort(LH_desync(s,:));
        LH_ROI(s,:,LC)= LH_elec(temp2(5:8)); %DN: pick the 4 parieto-occipito that show the highest left_minus_right values (8:11) i.e. maximal difference in post-target alpha desynchronisation for contralateral verses ipsilateral targets
        RH_desync(s,:)= PostAlpha_left_minus_rightTarget2(s,RH_elec,LC);
        [temp1,temp2] = sort(RH_desync(s,:));
        RH_ROI(s,:,LC)= RH_elec(temp2(1:4)); %DN: pick the 4 parieto-occipito that show the lowest left_minus_right values (1:4)i.e. maximal difference in post-target alpha desynchronisation for contralateral verses ipsilateral targets
        LH_ROI_s = LH_elec(temp2(5:8));
        RH_ROI_s = RH_elec(temp2(1:4));
        if LC==1
            save([path subject_folder_L{s} '\' allsubj_L{s} '_ROIs'],'LH_ROI_s','RH_ROI_s')
        elseif LC==2
            save([path subject_folder_M{s} '\' allsubj_M{s} '_ROIs'],'LH_ROI_s','RH_ROI_s')
        else
            save([path subject_folder_H{s} '\' allsubj_H{s} '_ROIs'],'LH_ROI_s','RH_ROI_s')
        end
    end
end

%Plot count of the electrodes chosen for spatial orienting sensitivity above:
LH_elec_RH_elec =[LH_elec RH_elec];
for LC=1:3
clear 'ROIs_elect_count'
for i=LH_elec_RH_elec
    ROIs_elect_count(i)=length(find(LH_ROI(:,:,LC)==i))+length(find(RH_ROI(:,:,LC)==i));
end
figure
% % topoplot (ROIs_elect_count,chanlocs,'electrodes','on','maplimits',[0 max(ROIs_elect_count)]);
topoplot (ROIs_elect_count,chanlocs,'electrodes','on','maplimits',[0 20]);
end



%% Topoplot of  Post target Alpha, left minus right target, for each light condition
%Alpha_cond (Subject, channel, samples, patch, motion, i, LC)
PostAlpha_left_minus_rightTarget_LC=squeeze(mean(mean(mean(mean(mean(PostAlpha_cond(:,:,find(Alpha_smooth_time==50):find(Alpha_smooth_time==600),[1,3],:,:,:),6),5),4),3),1))...
    -squeeze(mean(mean(mean(mean(mean(PostAlpha_cond(:,:,find(Alpha_smooth_time==50):find(Alpha_smooth_time==600),[2,4],:,:,:),6),5),4),3),1)); %PostAlpha_left_minus_rightTarget(channel, LC)
figure
counter=0;
for LC=1:3
    counter=counter+1;
    subplot(1,3,counter)
    topoplot (PostAlpha_left_minus_rightTarget_LC(:,LC),chanlocs,'maplimits',[min(PostAlpha_left_minus_rightTarget)...
        max(PostAlpha_left_minus_rightTarget)], 'electrodes','off');
    if LC==1
        title('Low Light')
    elseif LC==2
        title('Medium Light')
    else
        title('High Light')
    end
end



%% Topoplot of Pre-target Alpha
%Alpha_cond (Subject, channel, samples, patch, motion, i, LC)
PreAlpha_LC=squeeze(mean(mean(mean(mean(mean(PreAlpha_cond(:,:,find(Alpha_smooth_time==-450):find(Alpha_smooth_time==0),:,:,:,:),6),5),4),3),1));%PreAlphaHightMinusLow(channel, LC)
figure
counter=0;
for LC=1:3
    counter=counter+1;
    subplot(1,3,counter)
    topoplot (PreAlpha_LC(:,LC),chanlocs,'electrodes','off','maplimits',[-1*max(max(abs(PreAlpha_LC)))...
        max(max(abs(PreAlpha_LC)))]);
    if LC==1
        title('Pre-target Low') 
    elseif LC==2
        title('Pre-target Medium')
    else
        title('Pre-target High')
    end
end



%% 
figure
counter=0;
for LC=1:3
    counter=counter+1;
    
    subplot(3,3,counter)
     topoplot (PostAlpha_left_minus_rightTarget_LC(:,LC),chanlocs,'maplimits',[min(PostAlpha_left_minus_rightTarget)...
        max(PostAlpha_left_minus_rightTarget)], 'electrodes','off');
    if LC==1
        title(sprintf('Scalp regions most sensitive to\ncovert spatial attention orienting,\nLow Light.')) 
    elseif LC==2
        title(sprintf('Scalp regions most sensitive to\ncovert spatial attention orienting,\nMedium Light.'))
    else
        title(sprintf('Scalp regions most sensitive to\ncovert spatial attention orienting,\nHigh Light.'))
    end
    
    subplot(3,3,counter+3)
    topoplot (PreAlpha_LC(:,LC),chanlocs,'electrodes','off','maplimits',[-1*max(max(abs(PreAlpha_LC)))...
        max(max(abs(PreAlpha_LC)))]);
    if LC==1
        title(sprintf('Pre-target alpha power,\nLow Light.')) 
    elseif LC==2
        title(sprintf('Pre-target alpha power,\nMedium Light.'))
    else
        title(sprintf('Pre-target alpha power,\nHigh Light.'))
    end
    
    if LC==3
        subplot(3,3,counter+4.75)
        topoplot (PreAlphaHightMinusLow,chanlocs,'electrodes','off');
        
        subplot(3,3,counter+5.75)
%         topoplot (ROIs_elect_count,chanlocs,'electrodes','on','maplimits',[0 max(ROIs_elect_count)], 'plotchans', all_parietal_occipital);
        topoplot (ROIs_elect_count,chanlocs,'electrodes','off','maplimits',[0 max(ROIs_elect_count)]);
    end
   
end



%% 
figure
counter=0;
for plot=1:2
    counter=counter+1;
    
    subplot(2,1,counter)
    if plot==1
        topoplot (PostAlpha_left_minus_rightTarget,chanlocs,'electrodes','off');
        title(sprintf('Regions most sensitive\nto spatial attention orienting.')) 
    elseif plot==2
        topoplot (PreAlphaHightMinusLow,chanlocs,'electrodes','off');
        title(sprintf('Scalp regions most sensitive\nto prior light exposure.'))
    end
    
end




