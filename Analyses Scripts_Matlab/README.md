#In Matlab:

NOTE: these scripts require the EEGLAB plugin/toolbox for Matlab here http://sccn.ucsd.edu/eeglab/  (Delorme & Makeig, 2004). 
Also required is the EYE-EEG plug in for EEGLAB from here http://www2.hu-berlin.de/eyetracking-eeg/ to import and process the Eyelink data files, and also the BDFimport plugin (which can be downloaded using the EEGLAB GUI) for importing the raw BrainVision eeg files

###After installing EEGLAB and the required EEGLAB plugins, we ran the scripts in the following order.
(note: can skip steps 1 and 2 because they are just for finding noisy eeg channeles, which have already been found listed in 'runafew_BL.m' for step 3)

1. 'getChannelVars_BL.m' - to extract a measure of electrode noise
2. 'Check4badchans_BL.m' - checks for noisy channeles, you manually list any noisy channeles in 'runafew_BL.m'
3. 'runafew_BL.m' - calls 'Dots_Discrete_Upper_Lower_ET.m' to extract ERP, Alpha, and Pupil Diameter epochs 
4. 'getAlphaROIs_BL.m' - extracts and saves individualised ROI electrodes for each partivipant's pre-target alpha 
5. 'Extract_for_R_BL.m' - extracts trial-by-trial data (behavioural, EEG/ERP, pupil) and saves to .csv for import into R for inferential analysis


## License

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/">Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License</a>.

