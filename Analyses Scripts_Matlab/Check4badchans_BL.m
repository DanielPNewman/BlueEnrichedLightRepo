clear all
close all


datafolder = 'S:\R-MNHS-SPP\Bellgrove-data\4. Dan Newman\Blue Light Study\'; 
datafolder='C:\Users\Dan\Dropbox\Monash\PhD\Blue Light\Data\';

subject_folder = {'BL1\BL1_1','BL2\BL2_L','BL3\BL3_L','BL4\BL4_L','BL5\BL5_L','BL6\BL6_L','BL7\BL7_L','BL8\BL8_L','BL9\BL9_L','BL10\BL10_L','BL11\BL11_L','BL12\BL12_L','BL13\BL13_L','BL14\BL14_L','BL15\BL15_L','BL16\BL16_L','BL17\BL17_L','BL18\BL18_L','BL19\BL19_L','BL20\BL20_L','BL21\BL21_L','BL22\BL22_L','BL23\BL23_L','BL24\BL24_L'...
                  'BL1\BL1_M','BL2\BL2_M','BL3\BL3_M','BL4\BL4_M','BL5\BL5_M','BL6\BL6_M','BL7\BL7_M','BL8\BL8_M','BL9\BL9_M','BL10\BL10_M','BL11\BL11_M','BL12\BL12_M','BL13\BL13_M','BL14\BL14_M','BL15\BL15_M','BL16\BL16_M','BL17\BL17_M','BL18\BL18_M','BL19\BL19_M','BL20\BL20_M','BL21\BL21_M','BL22\BL22_M','BL23\BL23_M','BL24\BL24_M'...
                  'BL1\BL1_H','BL2\BL2_H','BL3\BL3_H','BL4\BL4_H','BL5\BL5_H','BL6\BL6_H','BL7\BL7_H','BL8\BL8_H','BL9\BL9_H','BL10\BL10_H','BL11\BL11_H','BL12\BL12_H','BL13\BL13_H','BL14\BL14_H','BL15\BL15_H','BL16\BL16_H','BL17\BL17_H','BL18\BL18_H','BL19\BL19_H','BL20\BL20_H','BL21\BL21_H','BL22\BL22_H','BL23\BL23_H','BL24\BL24_H'};
              
sessionID = {'BL1_1','BL2_L','BL3_L','BL4_L','BL5_L','BL6_L','BL7_L','BL8_L','BL9_L','BL10_L','BL11_L','BL12_L','BL13_L','BL14_L','BL15_L','BL16_L','BL17_L','BL18_L','BL19_L','BL20_M','BL21_L','BL22_L','BL23_L','BL4_L'...
            'BL1_M','BL2_M','BL3_M','BL4_M','BL5_M','BL6_M','BL7_M','BL8_M','BL9_M','BL10_Meeg','BL11_M','BL13_M','BL13_M','BL14_M','BL15_M','BL16_M','BL17_M','BL18_M','BL19_M','BL20_Mm','BL21_M','BL22_M','BL23_M','BL24_M'...
            'BL1_H','BL2_H','BL3_H','BL4_H','BL5_H','BL6_H','BL7_H','BL8_H','BL9_H','BL10_H','BL11_H','BL12_H','BL13_H','BL14_H','BL15_H','BL16_H','BL17_H','BL18_H','BL19_H','BL20_H','BL21_H','BL22_H','BL23_H','BL24_H'}; 

       

file_start = 1;
blocks = {[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],...
            [1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],...
            [1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1]...
            [1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],...
            [1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],...
            [1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],...
            [1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1],[1:1]}; %DN


for s=file_start:length(sessionID)
% for s=1:length(sessionID)
    matfile{s} = [datafolder subject_folder{s} '\' sessionID{s} '_chanvars.mat'];
end
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for s=file_start:file_start %length(sessionID)
% for s=1:length(sessionID)   
    disp(sessionID{s})
    load(matfile{s})
    chanVar = double(chanVar);
  
    badchans =    []; %DN: these two lines will swap and bad channels you identify with the 'changechans' in the next line
    changechans = [];
    chanVar(badchans(1:end),:) = chanVar(changechans(1:end),:);
    
    avVar = mean(chanVar,2); 
    
    figure;
    topoplot(avVar,chanlocs,'plotchans',[1:64],'electrodes','numbers');
    title(subject_folder{s})
    
    figure; hold on
    plot(chanVar(1:64))
    title(subject_folder{s})
end