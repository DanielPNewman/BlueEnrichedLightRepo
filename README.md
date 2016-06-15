# BlueLightRepo
Code for my short wavelength (blue) light /attention experiment, conducted at Monash University. 
Includes paradigm files (matlab/psychtoolbox), data processing/analysis files (matlab/eeglab) and Inferential Statistics/data analysis files (R)

**Newman**, D.P., Lockley, S.W., Loughnane, G.M., Martins, A.C.P., Abe, R., Zoratti, M.T.R., Kelly, S.P., O’Neill, M.H., Rajaratnam, S.M.W., O’Connell, R.G., & Bellgrove, M.A. (2016). [Ocular exposure to blue-enriched light has an asymmetric influence on neural activity and spatial attention.][7] *Scientific Reports*. 6, 27754. doi:10.1038/srep27754. 

##Paradigm Files:
The paradigm was run on a 32-bit windows XP machine using MATLAB (MathWorks) and the Psychophysics Toolbox extensions (Brainard, 1997; Cornelissen, Peters, & Palmer, 2002; Pelli, 1997).

The paradigm script is "DiscreteDots4Patch4_22_05_2014.m" The other scripts/functions in the "Paradigm Files" folder are called by  "DiscreteDots4Patch4_22_05_2014.m" 


##To reproduce inferential statistics and plots:
Run Blue_Enriched_light_Markdown.Rmd using R with Rstudio

##Full Analysis Pipeline:

###Raw Data
The raw data are available [here on FigShare][1] and are open access and available under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 International License.

###In Matlab, run scripts to process raw eeg files:
(note: can skip steps 1 and 2 because they are just for finding noisy eeg channeles, which have already been found listed in 'runafew_BL.m' for step 3)

1. 'getChannelVars_BL.m' - to extract a measure of electrode noise
2. 'Check4badchans_BL.m' - checks for noisy channeles, you manually list any noisy channeles in 'runafew_BL.m'
3. 'runafew_BL.m' - calls 'Dots_Discrete_Upper_Lower_ET.m' to extract ERP, Alpha, and Pupil Diameter epochs 
4. 'getAlphaROIs_BL.m' - extracts and saves individualised ROI electrodes for each partivipant's pre-target alpha measurements 
5. 'Extract_for_R_BL.m' - extracts trial-by-trial data (behavioural, EEG/ERP, pupil) and saves to .csv for import into R for inferential analysis

### Run the Inferential Statistics/ analysis in R (with Rstudio):
1. Blue_Enriched_light_Markdown.Rmd


## License

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/">Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License</a>.


[1]: https://dx.doi.org/10.4225/03/574CEA1FAFB69
[7]: http://www.nature.com/articles/srep27754 