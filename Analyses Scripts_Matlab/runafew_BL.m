%%% runafew
clear all
close all
clc

% path ='C:\Users\Dan\Dropbox\Monash\PhD\Blue Light\Data\'; 
path='C:\Users\newmand\Dropbox\Monash\PhD\Blue Light\Data\';

subject_folder = {'BL1\BL1_1','BL2\BL2_L','BL3\BL3_L','BL4\BL4_L','BL5\BL5_L','BL6\BL6_L','BL7\BL7_L','BL8\BL8_L','BL9\BL9_L','BL10\BL10_L','BL11\BL11_L','BL12\BL12_L','BL13\BL13_L','BL14\BL14_L','BL15\BL15_L','BL16\BL16_L','BL17\BL17_L','BL18\BL18_L','BL19\BL19_L','BL20\BL20_L','BL21\BL21_L','BL22\BL22_L','BL23\BL23_L','BL24\BL24_L',...
                  'BL1\BL1_M','BL2\BL2_M','BL3\BL3_M','BL4\BL4_M','BL5\BL5_M','BL6\BL6_M','BL7\BL7_M','BL8\BL8_M','BL9\BL9_M','BL10\BL10_M','BL11\BL11_M','BL12\BL12_M','BL13\BL13_M','BL14\BL14_M','BL15\BL15_M','BL16\BL16_M','BL17\BL17_M','BL18\BL18_M','BL19\BL19_M','BL20\BL20_M','BL21\BL21_M','BL22\BL22_M','BL23\BL23_M','BL24\BL24_M',...
                  'BL1\BL1_H','BL2\BL2_H','BL3\BL3_H','BL4\BL4_H','BL5\BL5_H','BL6\BL6_H','BL7\BL7_H','BL8\BL8_H','BL9\BL9_H','BL10\BL10_H','BL11\BL11_H','BL12\BL12_H','BL13\BL13_H','BL14\BL14_H','BL15\BL15_H','BL16\BL16_H','BL17\BL17_H','BL18\BL18_H','BL19\BL19_H','BL20\BL20_H','BL21\BL21_H','BL22\BL22_H','BL23\BL23_H','BL24\BL24_H'};

allsubj = {'BL1_1','BL2_L','BL3_L','BL4_L','BL5_L','BL6_L','BL7_L','BL8_L','BL9_L','BL10_L','BL11_L','BL12_L','BL13_L','BL14_L','BL15_L','BL16_L','BL17_L','BL18_L','BL19_L','BL20_M','BL21_L','BL22_L','BL23_L','BL4_L',...
            'BL1_M','BL2_M','BL3_M','BL4_M','BL5_M','BL6_M','BL7_M','BL8_M','BL9_M','BL10_Meeg','BL11_M','BL13_M','BL13_M','BL14_M','BL15_M','BL16_M','BL17_M','BL18_M','BL19_M','BL20_Mm','BL21_M','BL22_M','BL23_M','BL24_M',...
            'BL1_H','BL2_H','BL3_H','BL4_H','BL5_H','BL6_H','BL7_H','BL8_H','BL9_H','BL10_H','BL11_H','BL12_H','BL13_H','BL14_H','BL15_H','BL16_H','BL17_H','BL18_H','BL19_H','BL20_H','BL21_H','BL22_H','BL23_H','BL24_H'}; 
        


duds = []; %BL16_H(64) has corrupted .edf file so can't extract pupil data %BL20_H has problem with EEG/Eyelink sync because Brain vision recorder had temporary "data buffer overflow" while recording and missed 2 trials in the EEG
                        %misnamed eeg/edf files: BL20_L(misnamed BL20_M),
                        %BL24_L(misnamed BL4_L),BL12_M (misnamed BL13_M)[these misnamings are delt with later in the script]
single_participants = [];
exp_conditions = {'C','D'}; c = 1; %DN
file_start = 1;

if c==1

allblocks = {[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],...
            [1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],...
            [1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1]...
            ,[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1]...
            ,[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1]...
            ,[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1]}; 

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       allbadchans = {[5,59]%BL1\BL1_1
                      [59]%BL2\BL2_L
                      []%BL3\BL3_L
                      [41,46,22,16,28]%BL4\BL4_L
                      [56,19,33,62]%BL5\BL5_L
                      [41,17,46,22,37,58,19,34,29]%BL6\BL6_L 
                      [1,8,12]%BL7\BL7_L 
                      [37,41,45,50]%BL8\BL8_L 
                      [7,36,37,41,46,45]%BL9\BL9_L 
                      [17,22,28,37]%BL10\BL10_L 
                      [45,37,6]%BL11\BL11_L 
                      [32,37,45]%BL12\BL12_L
                      [7,40,11,16,45,37]%{'BL13\BL13_L'
                      [12,37,29]%{'BL14\BL14_L'
                      [48,53,17,22,28,41,60]%{'BL15\BL15_L'
                      [8,13,42]%'BL16\BL16_L'
                      [45,12,60,64]%'BL17\BL17_L'
                      [12,17,37,64,55,32,16]%%'BL18\BL18_L'
                      [37,45,7,12,46]%%'BL19\BL19_L'
                      [35,45,16]%%'BL20\BL20_L'
                      [37,45,64,42,41]%%'BL21\BL21_L'
                      [45,61,5]%%'BL22\BL22_L'
                      [45,34,13,15,58,16,56]%%'BL23\BL23_L'
                      [12,20,42,51,56,41,7,46,30,31]%%'BL24\BL24_L'
                      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                      [5,16,55]%BL1\BL1_M
                      [17,28,49,64]%BL2\BL2_M
                      [17,36]%BL3\BL3_M
                      [1,56,12,33]%BL4\BL4_M
                      [41,46,56]%BL5\BL5_M
                      [17,22,41,46,23,28,60,64,27]%BL6\BL6_M
                      [37,45]%,BL7\BL7_M
                      [37,45,50]%BL8\BL8_M
                      [41,46,27,59,45,8]%BL9\BL9_M
                      [37,17,12,60,33]%BL10\BL10_M
                      [28,17,41]%BL11\BL11_M 
                      [37,45,32,51,64,10,12]%BL12\BL12_M 
                      [45,34,35,39,11,38,46]%{'BL13\BL13_M'
                      [12,28,33]%{'BL14\BL14_M'
                      [43,28,32]%{'BL15\BL15_M'
                      [1,23,40]%BL16\BL16_M
                      [45,37,64,61,60]%'BL17\BL17_M'
                      [45,64,60,31,29]%'BL18\BL18_M'
                      [56,62,32,16,46]%%'BL19\BL19_M'
                      [17,22,37,49]%%'BL20\BL20_M'
                      [45,61]%%'BL21\BL21_M'
                      [37,45,16]%%'BL22\BL22_M'
                      [37,45,16,28]%%'BL23\BL23_M'
                      [11,12,17,23,60,46,36,51,41,28]%%'BL24\BL24_M'
                      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                      [55,12]%BL1\BL1_H 
                      [28,17,60,41]%BL2\BL2_H %AC
                      [1,3,22,55,31,32]%BL3\BL3_H %AC
                      [41,46,37,3,17,22]%BL4\BL4_H %AC
                      [46,41,22,60,43,37,3,17,16,64]%BL5\BL5_H %AC (4 SWITCHED OFF)
                      [17,22,41,46,23,28,60,64,27]%BL6\BL6_H %AC (4 SWITCHED OFF)
                      [45]%BL7\BL7_H %AC
                      [45,11,24,53,46,7]%BL8\BL8_H %AC_DEFINITELY_CHECK_THIS_ONE!!!
                      [2,41,46,45,37,59,3]%BL9\BL9_H %AC
                      [45,46,37,12,7,17,28]%BL10\BL10_H %AC
                      [45,44,22]%BL11\BL11_H
                      [37,32,28,41,42,8,3,12]%BL12\BL12_H
                      [10,40]%'BL13\BL13_H'
                      [1,7,47,36,37,45,12,48,24,29,43]%'BL14\BL14_H'
                      [33,37,40,42,28]%'BL15\BL15_H'
                      [45,22,50]%BL16\BL16_H
                      [1,37,45,32]%'BL17\BL17_H'
                      [45]%'BL18\BL18_H'
                      [37,8,61,16]%%'BL19\BL19_H'
                      [12,16,22,42,28]%%'BL20\BL20_H'
                      [37,45,64]%%'BL21\BL21_H'
                      [37,45,17,22,32]%%'BL22\BL22_H'
                      [45,20,16]%%'BL23\BL23_H'
                      [2,41,33,42,12,36,46]};%%'BL24\BL24_H'
                      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             

elseif c==2
  
    %%%
    
end

if ~isempty(duds) && isempty(single_participants)
    subject_folder([duds]) = [];
    allsubj([duds]) = [];
    allblocks([duds]) = [];
    allbadchans([duds]) = [];
end

if ~isempty(single_participants)
    subject_folder = subject_folder([single_participants]);
    allsubj = allsubj([single_participants]);
    allblocks = allblocks([single_participants]);
    allbadchans = allbadchans([single_participants]);
end

h = waitbar(0,'Please wait...');
steps = length(allsubj);
step = file_start-1;
for s=file_start:length(allsubj)
        
    disp(allsubj{s})
    tic
    if s==file_start
        waitbar(step/steps,h)
    else
        min_time = round((end_time*(steps-step))/60);
        sec_time = round(rem(end_time*(steps-step),60));
        % waitbar(step/steps,h,[num2str(min_time),' minutes, ',num2str(sec_time),' seconds remaining'])
        waitbar(step/steps,h,[num2str(min_time),' minutes remaining'])
    end
    step=step+1;
    subjID = [path subject_folder{s} '\' allsubj{s}];
    blocks = allblocks{s};
    badchans = allbadchans{s}; %for interpolating bad channels in Dots_Contin_resample.m
    if c==1
       Dots_Discrete_Upper_Lower_ET
%        FFT_BL
    elseif c==2
%         Dots_Discrete;
%         AlphaDots_Discrete;
    end
    end_time = toc;
end
close(h)