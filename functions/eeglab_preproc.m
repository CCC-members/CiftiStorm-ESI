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
%   save_path   - full path to save the cleanned EEG (key='save_path', value="fullpath")
%   freq_list   - vector of frequencies point to show in plots (key='freq_list', value=[1 6 10 18])
%   labels      - list of labels to select in the data (key='labels', value={'L1';'L2';'L3';.......;'Ln'})
%   read_marks  - true or false if you want to read the good time segments and reject the bad time segments
%   notime      - [min max] in seconds. Epoch latency or continuous dataset time range
%                 to exclude from the new dataset. For continuous data, may be
%                 [min1 max1; min2 max2; ...] to exclude several time ranges. For epoched
%                 data, the latency range must include an epoch boundary, as latency
%                 ranges in the middle of epochs cannot be removed from epoched data.
%
% Author: Eduardo Gonzalez-Moreira
% Date: Oct-2020
%
%
% Updates by:   Ariosky Areces Gonzalez
%               Deirel Paz Linares
%

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

if(~exist('freq_list','var'))
    freq_list = [1 6 10 18];
end

addpath(eeglab_path);
eeglab nogui;

%% Step2: Import data.
switch lower(data_type)
    case 'set'
        EEG         = pop_loadset(file_name);
    case 'mat'
        load(file_name);
        srate       = SAMPLING_FREQ;
        % For Pedrito's data selection
        load('templates/EEG_template.mat');
        EEG.srate   = srate;
        EEG.age     = age;
        EEG.data    = data;
        EEG.nbchan  = size(data,1);
        EEG.pnts    = size(data,2); 
        EEG.xmin    = 0;
        EEG.xmax    = EEG.xmin+(EEG.pnts-1)*(1/EEG.srate);       
        EEG.times   = (0:EEG.pnts-1)/EEG.srate.*1000;
        if(exist('labels','var'))
            EEG.chanlocs(length(labels)+1:end,:)    = [];
            new_labels                              = labels;
            [EEG.chanlocs.labels]                   = new_labels{:};
        end
    case 'dat'
        EEG         = pop_loadBCI2000(file_name);
    case 'plg'
        EEG         = readplot_plg(fullfile(file_name));
        template    = load('templates/EEG_template.mat');
        chanlocs    = template.EEG.chanlocs;        
        load('templates/labels_nomenclature.mat');
        orig_labels = labels_match(:,1);      
        for i=1:length(orig_labels)
            chanlocs(i).labels = labels_match{find(strcmp({EEG.chanlocs.labels},num2str(orig_labels{i})),1),2};
        end 
        EEG.chanlocs = chanlocs;
        EEG.chaninfo = template.EEG.chaninfo;
    case 'edf'
        EEG = pop_biosig(file_name);
        % For cuban dataset
        new_labels = replace({EEG.chanlocs.labels}','-REF','');
        [EEG.chanlocs.labels] = new_labels{:};
        new_labels = replace({EEG.chanlocs.labels}',' ','');
        [EEG.chanlocs.labels] = new_labels{:};
end
EEG.setname     = subID;
EEG.subID       = subID;

%% Filtering by user labels
if(exist('labels','var'))
    disp ("-->> Cleanning EEG bad Channels by user labels");
    EEG  = remove_eeg_channels_by_labels(labels,EEG);
end
%% Step 3: Visualization.
if verbosity
    eegplot(EEG.data);
end

%% Step 4: Downsample the data.
if EEG.srate > 300
    EEG = pop_resample(EEG, 200);
end

%% Step 5: Filtering the data at 0Hz and Max frequency Hz.
EEG = pop_eegfiltnew(EEG, 'locutoff', 0, 'hicutoff',max_freq, 'filtorder', 3300);

%% Step 6: Import channel info.
EEG = pop_chanedit(EEG, 'lookup',fullfile(eeglab_path,'plugins/dipfit3.4/standard_BEM/elec/standard_1005.elc'),'eval','chans = pop_chancenter( chans, [],[]);');
clear_ind = [];
for i=1:length(EEG.chanlocs)
    if(isempty(EEG.chanlocs(i).X))
        clear_ind = [clear_ind; i];
    end
end
EEG.chanlocs(clear_ind) = [];
EEG.data(clear_ind,:) = [];
EEG.nbchan = length(EEG.chanlocs);

if(exist('read_marks','var'))
    if(isfield(EEG,'TW') && ~isempty(EEG.TW))
        regions = [EEG.TW];
        rej_regions = [];
        for i=1:length(regions)
            if(isempty(rej_regions))
                time_end = regions(i).start - 1;
                rej_regions = [0 time_end];
            else
                time_start = regions(i-1).end + 1;
                time_end = regions(i).start - 1 ;
                rej_regions = [rej_regions; time_start time_end];
            end
        end
        time_start = regions(end).end + 1;
        time_end = EEG.times(end) ;
        rej_regions = [rej_regions; time_start time_end];
        
        EEG = eeg_eegrej(EEG, rej_regions);
        EEG.RejTime = rej_regions;
    end
    if(exist('notime','var'))
        EEG = eeg_eegrej( EEG, notime);
        EEG.RejTime = notime;
    end
end

if verbosity
    figure;
    [spectra,freqs] = spectopo(EEG.data,0,EEG.srate,'limits',[0 max_freq NaN NaN -10 10],'chanlocs',EEG.chanlocs,'chaninfo',EEG.chaninfo,'freq',freq_list);
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
    [spectra,freqs] = spectopo(EEG_interp.data,0,EEG_interp.srate,'limits',[0 max_freq NaN NaN -10 10],'chanlocs',EEG_interp.chanlocs,'chaninfo',EEG_interp.chaninfo,'freq',freq_list);
end
if(exist('save_path','var'))
    if(~isfolder(save_path))
        mkdir(save_path);
    end
    save(fullfile(save_path,strcat(subID, 'EEG_raw.mat')),'EEG','-v7.3');
    EEG = EEG_interp;
    save(fullfile(save_path,strcat(subID, 'EEG_interp.mat')),'EEG','-v7.3');
    
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    for iFig = 1:length(FigList)
        FigHandle = FigList(iFig);
        FigName   = get(FigHandle, 'Name');
        savefig(FigHandle, fullfile(save_path, strcat(subID, '_', num2str(iFig), '.fig')));
    end
else
    EEG = EEG_interp;
end
close all;
end
