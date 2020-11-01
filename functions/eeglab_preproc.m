function EEG  = eeglab_preproc(subID, file_name, data_type, eeglab_path, varargin)
%% Example of batch code to reject bad channels...
% 
%
%  Usage:    >> EEG = eeglab_preproc( subID, file_name, data_type, eeglab_path, 'key2', value1, 'key2', value2, ... ); 
%
%
% Inputs:
%   subID       - Subject ID
%   file_name   - Full EEG file name to import
%   data_type   - EEG file tipy ('set', 'mat', 'PLG', 'edf')
%   eeglab_path - root path of EEGLAB toolbox
%
% Optional inputs:
%
%   verbosity   - Logical value for debbuging (key='debug',value=true OR false) 
%   max_freq    - Integer maximun frequency to filtering the data (key='max_freq', value=from 1 to 92)
%   save_path   - full path to save the cleanned EEG (key='save_path', value="fullpath/file_name")
%   
%
% Author: Eduardo Gonzalez-Moreira
% Date: Oct-2020

%%
%% Step 1: Preparing workspace.
if(nargin<4 || ~isequal(rem(length(varargin),2),0))
    error('Not enough input arguments.');
    fprintf(2,"\n ->> Please check the Usage description \n");
    return;
end

for i=1:2:length(varargin)
   eval([varargin{i} '=  varargin{(i+1)};']) 
end

if(~exist('verbosity','var'))
    verbosity = true;
end

if(~exist('max_freq','var'))
    max_freq = 92;
end

addpath(eeglab_path);
eeglab nogui;


%% Step2: Import data.
switch data_type
    case 'set'
        EEG = pop_loadset(loadName);
    case 'mat'
        load(loadName);
    case 'dat'
        EEG = pop_loadBCI2000(loadName);
    case 'PLG'
        EEG = pop_load_plg([rawDataFiles.folder,'\',loadName]);
    case 'edf'
        EEG = pop_biosig(file_name);
end
EEG.setname = subID;

%% Step 3: Visualization.
if verbosity
  eegplot(EEG.data);
end

%% Step 4: Downsample the data.
if EEG.srate > 300
    EEG = pop_resample(EEG, 200);
end

%% Step 5: Filtering the data at 0Hz and 45 Hz.
EEG = pop_eegfiltnew(EEG, 'locutoff', 0, 'hicutoff',max_freq, 'filtorder', 3300);

% %% Step 6: Import channel info.
new_labels = replace({EEG.chanlocs.labels}','-REF','');
[EEG.chanlocs.labels] = new_labels{:};
new_labels = replace({EEG.chanlocs.labels}',' ','');
[EEG.chanlocs.labels] = new_labels{:};

EEG = pop_chanedit(EEG, 'lookup',fullfile(eeglab_path,'plugins/dipfit3.4/standard_BEM/elec/standard_1005.elc'),'eval','chans = pop_chancenter( chans, [],[]);');
clear_ind = [];
for i=1:length(new_labels)
   if(isempty(EEG.chanlocs(i).X)) 
       clear_ind = [clear_ind; i];
   end
end
EEG.chanlocs(clear_ind) = [];
EEG.data(clear_ind,:) = [];
EEG.nbchan = length(EEG.chanlocs);
if verbosity
    figure;
    [spectra,freqs] = spectopo(EEG.data,0,EEG.srate,'limits',[0 30 NaN NaN -10 10],'chanlocs',EEG.chanlocs,'chaninfo',EEG.chaninfo,'freq',[1 6 10 18]);
end

%% Step 7: Apply clean_rawdata() to reject bad channels and correct continuous data using Artifact Subspace Reconstruction (ASR).
EEG_cleaned = clean_artifacts(EEG);
if verbosity
    vis_artifacts(EEG_cleaned,EEG);
end

%% Step 8: Interpolate all the removed channels.
EEG_interp = pop_interp(EEG_cleaned, EEG.chanlocs, 'spherical');
if verbosity
    eegplot(EEG_interp.data)
    figure;
    [spectra,freqs] = spectopo(EEG_interp.data,0,EEG_interp.srate,'limits',[0 30 NaN NaN -10 10],'chanlocs',EEG_interp.chanlocs,'chaninfo',EEG_interp.chaninfo,'freq',[1 6 10 18]);
end
EEG = EEG_interp;

if(exist('save_path','var'))
    save(save_path,'EEG','-v7.3');
end
end
