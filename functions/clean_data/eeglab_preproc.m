function EEGs  = eeglab_preproc(subID, file_name, data_type, eeglab_path, varargin)
%% Example of batch code to reject bad channels...
%
%
%  Usage:    >> EEGs = eeglab_preproc( subID, file_name, data_type, eeglab_path, 'key2', value1, 'key2', value2, ... );
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
%   verbosity       - Logical value for debbuging (key='debug',value=true OR false)
%   max_freq        - Integer maximun frequency to filtering the data (key='max_freq', value=from 1 to 92)
%   save_path       - full path to save the cleanned EEG (key='save_path', value="fullpath")
%   freq_list       - vector of frequencies point to show in plots (key='freq_list', value=[1 6 10 18])
%   labels          - list of labels to select in the data (key='labels', value={'L1';'L2';'L3';.......;'Ln'})
%   read_segments   - true or false if you want to read the good time segments and reject the bad time segments
%                   (key='read_segments',value=true OR false)
%   read_marks      - true or false if you want to read the marks on the data. (key='read_marks',value=true OR false)
%   events          - list of events to read from the data. you can match this events with the good segments and marks.
%                   (key='events', value=[] empty for all the events or list for selected)
%   notime          - [min max] in seconds. Epoch latency or continuous dataset time range
%                   to exclude from the new dataset. For continuous data, may be
%                   [min1 max1; min2 max2; ...] to exclude several time ranges. For epoched
%                   data, the latency range must include an epoch boundary, as latency
%                   ranges in the middle of epochs cannot be removed from epoched data.
%   use_raw_data    - Import data from raw data (key='use_raw_data',value=true OR false)
%
% Outputs:
%   EEGs            - Cleanned EEGs structure
%
%
% Author: Eduardo Gonzalez-Moreira
% Date: Oct-2020
%
%
% Updates by:   Ariosky Areces-Gonzalez
%               Deirel Paz-Linares
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

% Initializing empty params
if(~exist('verbosity','var'))
    verbosity           = true;
end
if(~exist('max_freq','var'))
    max_freq = 90;
end
if(~exist('freq_list','var'))
    freq_list = [1 6 10 18];
end

%% Step2: Import data.
switch lower(data_type)
    case 'set'
        EEG         = pop_loadset(file_name);
    case 'mat'
        load(file_name);
        if(use_raw_data)
            EEG = F.header.EEG;
        else
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
        end
    case 'matrix'
        load(file_name);
        load('templates/EEG_template.mat');
        EEG.srate   = 128;
        EEG.data    = data;
        EEG.nbchan  = size(EEG.data,1);
        EEG.pnts    = size(EEG.data,2);
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
        try
            EEG         = readplot_plg(fullfile(file_name));
        catch
            EEGs = [];
            return;
        end
        template    = load('templates/EEG_template.mat');
        load('templates/labels_nomenclature.mat');
        orig_labels = labels_match(:,1);
        for i=1:length(orig_labels)
            label = orig_labels{i};
            pos = find(strcmp({EEG.chanlocs.labels},num2str(label)),1);
            if(~isempty(pos))
                EEG.chanlocs(pos).labels = labels_match{i,2};
            end
        end
        chan_row    = template.EEG.chanlocs(1);
        data_labels      = EEG.chanlocs;
        for i=1:length(data_labels)
            chan_row.labels = data_labels(i).labels;
            new_chanlocs(i) = chan_row;
        end
        EEG.chanlocs = new_chanlocs;
        EEG.chaninfo = template.EEG.chaninfo;
    case 'edf'
        EEG                     = pop_biosig(file_name);
        % For cuban dataset
        new_labels              = replace({EEG.chanlocs.labels}','-REF','');
        [EEG.chanlocs.labels]   = new_labels{:};
        new_labels              = replace({EEG.chanlocs.labels}',' ','');
        [EEG.chanlocs.labels]   = new_labels{:};
    case 'txt'
        load('templates/EEG_template.mat');
        [filepath,filename,~]   = fileparts(file_name);
        EEG.filename            = filename;
        EEG.filepath            = filepath;
        EEG.subject             = subID;
        data                    = readmatrix(file_name);
        data                    = data';
        EEG.data                = data;
        EEG.nbchan              = length(EEG.chanlocs);
        EEG.pnts                = size(data,2);
        EEG.srate               = 200;
        EEG.min                 = 0;
        EEG.max                 = EEG.xmin+(EEG.pnts-1)*(1/EEG.srate);
        EEG.times               = (0:EEG.pnts-1)/EEG.srate.*1000;
    case 'mff'
        [EEG, com] = pop_mffimport(file_name, 'code');
end
EEG.setname     = subID;
EEG.subID       = subID;

%% 3 Filtering by user labels
if(exist('labels','var'))
    disp ("-->> Cleanning EEG bad Channels by user labels");
    EEG  = remove_eeg_channels_by_labels(labels,EEG);
end

%% Step 4: Visualization.
if verbosity
    eegplot(EEG.data);
    FigList     = findobj(allchild(0), 'flat', 'Type', 'figure');
    FigHandle   = FigList(1);
    FigName     = 'EGG signal.fig';
    savefig(FigHandle, fullfile(save_path, FigName));
    close(FigHandle);
end

%% Step 5: Appling notch filter to 60Hz.
% EEG = pop_cleanline(EEG,'arg_direct',0,'linefreqs',60,'scanforlines',1,'p',0.01,...
%     'bandwidth',2,'sigtype','Channels','chanlist',1:EEG.nbchan,'taperbandwidth',2,...
%     'winsize',4,'winstep',1,'tau',100,'pad',2,'computepower',1,'normSpectrum',1,'verb',1,'plotfigures',0);

%% Step 6: Downsample the data.
if EEG.srate > 300
    EEG     = pop_resample(EEG, 200);
end

%% Step 7: Filtering the data at 0Hz and Max frequency Hz.
EEG         = pop_eegfiltnew(EEG, 'locutoff', 0, 'hicutoff',max_freq, 'filtorder', 3300);

%% Step 8: Import channel info.
EEG         = pop_chanedit(EEG, 'lookup',fullfile(eeglab_path,'plugins/dipfit/standard_BEM/elec/standard_1005.elc'),'eval','chans = pop_chancenter( chans, [],[]);');
clear_ind   = [];
for i=1:length(EEG.chanlocs)
    if(isempty(EEG.chanlocs(i).X))
        clear_ind = [clear_ind; i];
    end
end
EEG.chanlocs(clear_ind) = [];
EEG.data(clear_ind,:)   = [];
EEG.nbchan              = length(EEG.chanlocs);
if verbosity
    [spectra,freqs] = spectopo(EEG.data,0,EEG.srate,'limits',[0 max_freq NaN NaN -10 10],'chanlocs',EEG.chanlocs,'chaninfo',EEG.chaninfo,'freq',freq_list);
    FigList         = findobj(allchild(0), 'flat', 'Type', 'figure');
    FigHandle       = FigList(1);
    FigName         = 'Cross-spectrum.fig';
    savefig(FigHandle, fullfile(save_path, FigName));
    close(FigHandle);
end
if(exist('derivatives','var'))
    EEG.derivatives = derivatives;
else
    EEG.derivatives = [];
end
%%
%%  Step 9: Getting marks and segments
%%
EEGs = get_marks_and_segments(EEG, 'select_events', select_events);
try
    for i=1:length(EEGs)
        EEG = EEGs(i);
        events      = select_events.events;
        if(~isempty(events))
            save_forder = fullfile(save_path,EEG.subID_sufix);
            if(~isfolder(save_forder))
                mkdir(save_forder);
            end
        else
            save_forder = save_path;
        end
        if verbosity
            [spectra,freqs] = spectopo(EEG.data,0,EEG.srate,'limits',[0 max_freq NaN NaN -10 10],'chanlocs',EEG.chanlocs,'chaninfo',EEG.chaninfo,'freq',freq_list);
            FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
            FigHandle = FigList(1);
            FigName   = 'Cross-spectrum.fig';
            savefig(FigHandle, fullfile(save_forder, FigName));
            close(FigHandle);
            
            eegplot(EEG.data);
            FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
            FigHandle = FigList(1);
            FigName   = 'EGG signal.fig';
            savefig(FigHandle, fullfile(save_forder, FigName));
            close(FigHandle);
        end
        
        %% Step 10: Apply clean_rawdata() to reject bad channels and correct continuous data using Artifact Subspace Reconstruction (ASR).
        if(clean_art_params.default)
            EEG_cleaned     = clean_artifacts(EEG);
        else
            args            = clean_art_params.arguments;
            EEG_cleaned     = clean_artifacts(EEG,'FlatlineCriterion',args.FlatlineCriterion,...
                'ChannelCriterion',args.ChannelCriterion,...
                'LineNoiseCriterion',args.LineNoiseCriterion,...
                'Highpass',args.Highpass,...
                'BurstCriterion',args.BurstCriterion,...
                'WindowCriterion',args.WindowCriterion,...
                'BurstRejection',args.BurstRejection,...
                'Distance',args.Distance,...
                'WindowCriterionTolerances',args.WindowCriterionTolerances);
        end
        if verbosity
            vis_artifacts(EEG_cleaned,EEG);
            FigList     = findobj(allchild(0), 'flat', 'Type', 'figure');
            FigHandle   = FigList(1);
            FigName     = 'Checking artifacts.fig';
            savefig(FigHandle, fullfile(save_forder, FigName));
            close(FigHandle);
        end
        
        if(isequal(lower(chan_action),'interpolate'))
            %% Step 11: Interpolate all the removed channels.
            EEG_cleaned = pop_interp(EEG_cleaned, EEG.chanlocs, 'spherical');
        end
        
        %% Running ICA        
        if(decompose_ica.run)
            icatype = decompose_ica.icatype.value;
            extended = decompose_ica.extended;
            reorder = decompose_ica.reorder;
            concatenate = decompose_ica.concatenate;
            concatcond = decompose_ica.concatcond;
            EEG_cleaned = pop_runica( EEG_cleaned, 'icatype', icatype, 'options', {'extended', extended}, 'reorder', reorder, 'concatenate', concatenate, 'concatcond', concatcond, 'chanind', []);
            
            
            [EEG_cleaned, varargout] = pop_iclabel(EEG_cleaned, 'default');
            
            thresh                  = struct2array(decompose_ica.remove_comp.thresh)';
            [EEG_cleaned,com]       = pop_icflag(EEG_cleaned, thresh);
            components              = find(EEG_cleaned.reject.gcompreject == 1);
            plotag = 0;
            keepcomp = 0;
            [EEG_cleaned LASTCOM]   = pop_subcomp(EEG_cleaned,components, plotag, keepcomp);
            save(fullfile(save_forder,strcat(subID, '_EEG_ICA.mat')),'-struct','EEG_cleaned','-v7.3');
        end
        
        %% Saving EEG plots after cleaned
        if verbosity
            eegplot(EEG_cleaned.data);
            FigList     = findobj(allchild(0), 'flat', 'Type', 'figure');
            FigHandle   = FigList(1);
            FigName     = 'EGG signal_cleaned.fig';
            savefig(FigHandle, fullfile(save_forder, FigName));
            close(FigHandle);
            
            [spectra,freqs] = spectopo(EEG_cleaned.data,0,EEG_cleaned.srate,'limits',[0 max_freq NaN NaN -10 10],'chanlocs',EEG_cleaned.chanlocs,'chaninfo',EEG_cleaned.chaninfo,'freq',freq_list);
            FigList     = findobj(allchild(0), 'flat', 'Type', 'figure');
            FigHandle   = FigList(1);
            FigName     = 'Cross-spectrum_cleaned.fig';
            savefig(FigHandle, fullfile(save_forder, FigName));
            close(FigHandle);
            
            % Step 12: Saving EEGs before and after cleaned
            save(fullfile(save_forder,strcat(subID, '_EEG_raw.mat')),'-struct','EEG','-v7.3');
            EEG = EEG_cleaned;
            save(fullfile(save_forder,strcat(subID, '_EEG_cleaned.mat')),'-struct','EEG','-v7.3');            
        end       
        EEG = EEG_cleaned;
        EEGs(i) = EEG;
    end
catch
end

end
