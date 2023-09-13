# EEG Preprocessing based on EEGLAB

% Authors
 - Ariosky Areces Gonzalez
 - Deirel Paz Linares
 - Usama Riaz

% March 08, 2022


Removing artifacts from EEG data is the reason why EEGLAB has become so popular. EEGLAB pioneered the use of independent component analysis to reject artifacts and is implementing new measures such as artifact subspace reconstructions. This series of tutorials guides you through removing artifacts from EEG data, both manually and automatically.


a. Remove bad channels
b. Remove bad data
c. Automated rejection

    There are several sections to this menu indicating different sequential processes: 

    The top section is about high-pass filtering your data. By default, this option is not selected since EEGLAB assumes that you might have already filtered your data. However, if this is not the case, you may select that option. The frequency limits indicate the transition bandwidth for the high pass filter (so 0.25 to 0.75 Hz indicate a high-pass filter at 0.5 Hz). 

    The second option deals with removing bad channels. There are three methods to remove bad channels. Flat channels may be removed. Channels with a large amount of noise may be removed based on their standard deviation, and channels, which are poorly correlated with other channels, may be removed. The rejection threshold for channel correlation is set to 0.8. Note that channel rejection based on their correlation is performed differently if you have imported channel locations (a different heuristic that takes into account channel location is used in case you have them - and we strongly advise importing channel locations before automated artifact rejection). 

    The third section deals with rejecting bad portions of data using the Artifact Subspace Reconstruction (ASR) algorithm. The full description of this algorithm is outside the scope of this tutorial. For more information, we refer to this Appendix. ASR may be used to correct bad portions of data or to remove them. For offline EEG processing, we advise to remove them, which corresponds to the default options. First, ASR finds clean portions of data (calibration data) and calculates PCA-extracted components’ standard deviation (ignoring physiological EEG alpha and theta waves by filtering them out). It rejects data regions if they exceed 20 times (by default) the standard deviation of the calibration data. The lower this threshold, the more aggressive the rejection is. The Riemannian distance is an experimental metric published in this article that claims superior performance – ASR’s author C. Kothe disputes its claims. 

    The fourth option deals with the additional rejection of bad portions of data based on a set number of channels passing a standard deviation threshold in a given time window. The time window size can be fine-tuned when running the function from the command line. This allows rejecting bad portions of data that ASR might have missed. 

    The last option allows plotting results of the rejection with rejected data highlighted. 

d. Indep. Comp. Analysis

    The ICLabel plugin of Luca Pion-Tonachini is an EEGLAB plugin installed by default with EEGLAB, which provides an estimation of the type of each of the independent components (brain, eye, muscle, line noise, etc.). The ICLabel project’s goal was to develop an EEG IC classifier that is reliable and accurate enough to use in large-scale studies. The current classifier implementation is trained on thousands of manually labeled ICs and hundreds of thousands of unlabeled ICs. More information may be found in the ICLabel reference article. The ICLabel website also allows you to train to recognize components and compare your performance with experts. Note that ICLabel is one of many such EEGLAB plugins that can automatically find artifactual ICA components. Other plugins or toolboxes worth checking for automatically labeling ICA components are MARA, FASTER, SASICA, ADUST, and IC_MARK. 


- References 

EEGLAB (https://eeglab.org/) 

https://eeglab.org/tutorials/05_Preprocess/Filtering.html 

Artifact Subspace Reconstruction (https://eeglab.org/tutorials/06_RejectArtifacts/cleanrawdata.html#automated-artifact-rejection-with-clean-rawdata-plugin) 

https://eeglab.org/tutorials/10_Group_analysis/study_data_visualization_tools.html#precomputing-and-visualizing-channel-data 

