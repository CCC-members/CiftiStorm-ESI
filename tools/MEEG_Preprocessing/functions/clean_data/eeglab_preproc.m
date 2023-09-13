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
if(~exist('min_freq','var') || isempty(min_freq))
    min_freq = 0;
end
if(~exist('max_freq','var') || isempty(max_freq))
    max_freq = 90;
end
if(~exist('freq_list','var') || isempty(freq_list))
    freq_list = [3 6 10 22];
end

%% Step2: Import data.
 f_report('Index',strcat("Importing raw data - ",subID));
switch lower(data_type)
    case 'set'
        EEG                     = pop_loadset(file_name);
    case 'mat'
        EEG                     = eeg_emptyset;
        load(file_name);
        EEG.data                = data;
        
        % For Pedrito's data selection
        %         srate                   = SAMPLING_FREQ;
        %         EEG.srate               = srate;
        %         EEG.age                 = age;
        %         if(exist('labels','var'))
        %             EEG.chanlocs(length(labels)+1:end,:)    = [];
        %             new_labels                              = labels;
        %             [EEG.chanlocs.labels]                   = new_labels{:};
        %         end

        % For DEAP dataset 
        EEG.srate               = 256;  
        EEG.trials              = 1;
        EEG.nbchan              = size(data,1);
        EEG.pnts                = size(data,2);
        EEG.xmin                = 0;
        EEG.xmax                = EEG.xmin+(EEG.pnts-1)*(1/EEG.srate);
        EEG.times               = (0:EEG.pnts-1)/EEG.srate.*1000;           
        EEG.chanlocs                   = cell2struct(labels, 'labels',2);       
    case 'matrix'
        load(file_name);
        EEG                     = eeg_emptyset;
        EEG.srate               = 128;
        EEG.data                = data;
        EEG.nbchan              = size(EEG.data,1);
        EEG.pnts                = size(EEG.data,2);
        EEG.xmin                = 0;
        EEG.xmax                = EEG.xmin+(EEG.pnts-1)*(1/EEG.srate);
        EEG.times               = (0:EEG.pnts-1)/EEG.srate.*1000;
        if(exist('labels','var'))
            EEG.chanlocs(length(labels)+1:end,:)    = [];
            new_labels                              = labels;
            [EEG.chanlocs.labels]                   = new_labels{:};
        end
    case 'dat'
        EEG                     = pop_loadBCI2000(file_name);
    case 'plg'
        try
            EEG                 = readplot_plg(fullfile(file_name));
        catch
            EEGs                = [];
            return;
        end
        template                = eeg_emptyset;
        load('templates/labels_nomenclature.mat');
        orig_labels             = labels_match(:,1);
        for i=1:length(orig_labels)
            label               = orig_labels{i};
            pos                 = find(strcmp({EEG.chanlocs.labels},num2str(label)),1);
            if(~isempty(pos))
                EEG.chanlocs(pos).labels = labels_match{i,2};
            end
        end
%         chan_row                = template.EEG.chanlocs(1);
%         data_labels             = EEG.chanlocs;
%         for i=1:length(data_labels)
%             chan_row.labels     = data_labels(i).labels;
%             new_chanlocs(i)     = chan_row;
%         end
%         EEG.chanlocs            = new_chanlocs;
%         EEG.chaninfo            = template.EEG.chaninfo;
        
    case 'edf'
        EEG                     = pop_biosig(file_name);
        % For cuban dataset
        new_labels              = replace({EEG.chanlocs.labels}','-REF','');
        [EEG.chanlocs.labels]   = new_labels{:};
        new_labels              = replace({EEG.chanlocs.labels}',' ','');
        [EEG.chanlocs.labels]   = new_labels{:};
    case 'txt'
        EEG                     = eeg_emptyset;
        [~,filename,~]          = fileparts(file_name);
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
        EEG                     = pop_readegimff( file_name );
end
EEG.setname                     = subID;

if(exist('derivatives','var') && ~isempty(derivatives))
    EEG.derivatives             = derivatives;
end

%% 3 Filtering by user labels
if(exist('labels','var') && ~isempty(labels))
    disp ("-->> Cleanning EEG bad Channels by user labels.");
    f_report('Info','Cleanning EEG bad Channels by user labels.');
    EEG                         = remove_eeg_channels_by_labels(labels,EEG);
end

%% Step 4: Visualization.
if verbosity
    eegplot(EEG.data);
    FigList                     = findobj(allchild(0), 'flat', 'Type', 'figure');
    FigHandle                   = FigList(1);
    FigName                     = 'EEG signal';
    savefig(FigHandle, fullfile(save_path, strcat(FigName,".fig")));
    close(FigHandle);
    close all;    
end

%% Step 5: Appling notch filter to 60Hz.
% EEG = pop_cleanline(EEG,'arg_direct',0,'linefreqs',60,'scanforlines',1,'p',0.01,...
%     'bandwidth',2,'sigtype','Channels','chanlist',1:EEG.nbchan,'taperbandwidth',2,...
%     'winsize',4,'winstep',1,'tau',100,'pad',2,'computepower',1,'normSpectrum',1,'verb',1,'plotfigures',0);

%% Step 6: Downsample the data.
if(EEG.srate > 300 && clean)
    f_report('Info','pop_resample() - Resample dataset (pop up window).');
    EEG                         = pop_resample(EEG, 200);
end

%% Step 7: Filtering the data at Min frequency Hz and Max frequency Hz.
f_report('Info',strcat('pop_eegfiltnew() - Filter data using Hamming windowed sinc FIR filter. (',num2str(max_freq),'Hz)'));
EEG                             = pop_eegfiltnew(EEG, 'locutoff', min_freq, 'hicutoff',max_freq, 'filtorder', 3300);

%% Step 8: Import channel info.
f_report('Info',strcat('Edit the channel locations structure by EEGLAB template.'));
chan_template = dir(fullfile(eeglab_path,'**',electrode_file));
chan_template_file = fullfile(chan_template.folder,chan_template.name);
EEG                             = pop_chanedit(EEG, 'lookup',chan_template_file,'eval','chans = pop_chancenter( chans, [],[]);');
clear_ind                       = [];
for i=1:length(EEG.chanlocs)
    if(isempty(EEG.chanlocs(i).X))
        clear_ind               = [clear_ind; i];
    end
end
EEG.chanlocs(clear_ind)         = [];
EEG.data(clear_ind,:)           = [];
EEG.nbchan                      = length(EEG.chanlocs);
if verbosity    
    spectopo(EEG.data,0,EEG.srate,'limits',[min_freq max_freq NaN NaN -10 10],'chanlocs',EEG.chanlocs,'chaninfo',EEG.chaninfo,'freq',freq_list);
    FigList                     = findobj(allchild(0), 'flat', 'Type', 'figure');
    FigHandle                   = FigList(1);
    FigName                     = 'Cross-spectrum Raw data';
    % Add a Snapshot to the report
    f_report('Snapshot', FigHandle, FigName, [] , [200,200,875,450]);
    savefig(FigHandle, fullfile(save_path, strcat(FigName,".fig")));
    close(FigHandle);
    close all;   
    
    pop_topoplot( EEG, 1, [0 100 200 300 400 500], 'Continuous EEG data epoch', [2 3]);
    FigList                     = findobj(allchild(0), 'flat', 'Type', 'figure');
    FigHandle                   = FigList(1);
    FigName                     = 'Continuous EEG data epoch';
    % Add a Snapshot to the report
    f_report('Snapshot', FigHandle, FigName, [] , [200,200,875,450]);
    savefig(FigHandle, fullfile(save_path, strcat(FigName,".fig")));
    close(FigHandle);
    close all;   
end

%%
%%  Step 9: Getting marks and segments
%%
if(clean)
    f_report('Info','Getting marks and segments');
    [EEGs, select_events]           = get_marks_and_segments(EEG, select_events);
    for i=1:length(EEGs)
        EEG                         = EEGs(i);
        events                      = select_events.events;
        if(~isempty(events))
            save_forder = fullfile(save_path,EEG.event_name);
            if(~isfolder(save_forder))
                mkdir(save_forder);
            end
        else
            save_forder             = save_path;
        end
        if verbosity
            f_report('Sub-Index',strcat("Processing - ",EEG.event_name));
            spectopo(EEG.data,0,EEG.srate,'limits',[min_freq max_freq NaN NaN -10 10],'chanlocs',EEG.chanlocs,'chaninfo',EEG.chaninfo,'freq',freq_list);
            FigList                 = findobj(allchild(0), 'flat', 'Type', 'figure');
            FigHandle               = FigList(1);
            FigName                 = strcat("Cross-spectrum - ",EEG.event_name);
            % Add a Snapshot to the report
            f_report('Snapshot', FigHandle, FigName, [] , [200,200,875,450]);
            savefig(FigHandle, fullfile(save_forder, strcat(FigName,".fig")));
            close(FigHandle);
            
            eegplot(EEG.data);
            FigList                 = findobj(allchild(0), 'flat', 'Type', 'figure');
            FigHandle               = FigList(1);
            FigName                 = strcat("EEG signal - ",EEG.event_name);
            savefig(FigHandle, fullfile(save_forder, strcat(FigName,".fig")));
            close(FigHandle);
            close all;
            
            pop_topoplot( EEG, 1, [0 100 200 300 400 500], 'Continuous EEG data epoch', [2 3]);
            FigList                 = findobj(allchild(0), 'flat', 'Type', 'figure');
            FigHandle               = FigList(1);
            FigName                 = strcat("Continuous EEG data epoch - ",EEG.event_name);
            % Add a Snapshot to the report
            f_report('Snapshot', FigHandle, FigName, [] , [200,200,875,450]);
            savefig(FigHandle, fullfile(save_path, strcat(FigName,".fig")));
            close(FigHandle);
            close all;
        end
        
        %% Step 10: Apply clean_rawdata() to reject bad channels and correct continuous data using Artifact Subspace Reconstruction (ASR).
        %   Add sub-topics to the report
        f_report('Sub-Index','Correct continuous data using Artifact Subspace Reconstruction (ASR).');
        if(clean_art_params.default)
            f_report('Info','Clean data with dafault params.');
            EEG_cleaned             = clean_artifacts(EEG);
        else
            f_report('Info','Clean data with predefinition params.');
            args                    = clean_art_params.arguments;
            EEG_cleaned             = clean_artifacts(EEG,'FlatlineCriterion',args.FlatlineCriterion,...
                'ChannelCriterion',args.ChannelCriterion,...
                'LineNoiseCriterion',args.LineNoiseCriterion,...
                'Highpass',args.Highpass,...
                'BurstCriterion',args.BurstCriterion,...
                'WindowCriterion',args.WindowCriterion,...
                'BurstRejection',args.BurstRejection,...
                'Distance',args.Distance,...
                'WindowCriterionTolerances',args.WindowCriterionTolerances);
        end
        
        %% Step 11: Interpolate all the removed channels.
        if(isequal(lower(chan_action),'interpolate'))
            f_report('Info',"pop_interp() - Interpolate data channels.");
            EEG_cleaned             = pop_interp(EEG_cleaned, EEG_cleaned.chanlocs, 'spherical');
        end
        
        %% Running ICA
        if(decompose_ica.run)
            %   Run an ICA decomposition of an EEG dataset
            %   Add sub-topics to the report
            f_report('Sub-Index','Run an ICA decomposition.');
            icatype                 = decompose_ica.icatype.value;
            extended                = decompose_ica.extended;
            reorder                 = decompose_ica.reorder;
            concatenate             = decompose_ica.concatenate;
            concatcond              = decompose_ica.concatcond;
            EEG_cleaned             = pop_runica( EEG_cleaned, 'icatype', icatype, 'options', {'extended', extended}, 'reorder', reorder, 'concatenate', concatenate, 'concatcond', concatcond, 'chanind', []);
            %   Label independent components using ICLabel.
            f_report('Info',"Label independent components using ICLabel.");
            [EEG_cleaned]           = pop_iclabel(EEG_cleaned, 'default');
            thresh                  = struct2array(decompose_ica.remove_comp.thresh)';
            %   pop_icflag - Flag components as atifacts
            f_report('Info',"pop_icflag - Flag components as atifacts.");
            [EEG_cleaned]           = pop_icflag(EEG_cleaned, thresh);
            components              = find(EEG_cleaned.reject.gcompreject == 1);
            plotag                  = 0;
            keepcomp                = 0;
            %   pop_subcomp() - remove specified components from an EEG dataset.
            f_report('Info',"pop_subcomp() - Remove specified components.");
            [EEG_cleaned]           = pop_subcomp(EEG_cleaned,components, plotag, keepcomp);
            save(fullfile(save_forder,strcat(subID, '_EEG_ICA.mat')),'-struct','EEG_cleaned','-v7.3');
            %   pop_spectopo() - Plot spectra of specified data channels or components.
            pop_spectopo( EEG_cleaned,1,[EEG_cleaned.xmin*1000 EEG_cleaned.xmax*1000],'EEG','freq',freq_list,'freqrange',[0 max_freq],'electrodes','on');
            FigList                 = findobj(allchild(0), 'flat', 'Type', 'figure');
            FigHandle               = FigList(1);
            FigName                 = strcat('Cross-spectrum_ICA - ',EEG_cleaned.event_name);
            % Add a Snapshot to the report
            f_report('Snapshot', FigHandle, FigName, [] , [200,200,875,450]);
            savefig(FigHandle, fullfile(save_forder, strcat(FigName,".fig")));
            close(FigHandle);
            close all;
        end
        
        %% Saving EEG plots after cleaned
        if verbosity
            eegplot(EEG_cleaned.data);
            FigList                 = findobj(allchild(0), 'flat', 'Type', 'figure');
            FigHandle               = FigList(1);
            FigName                 = strcat('EGG signal_cleaned - ',EEG_cleaned.event_name);
            savefig(FigHandle, fullfile(save_forder, strcat(FigName,".fig")));
            close(FigHandle);
            
            spectopo(EEG_cleaned.data,0,EEG_cleaned.srate,'limits',[min_freq max_freq NaN NaN -10 10],'chanlocs',EEG_cleaned.chanlocs,'chaninfo',EEG_cleaned.chaninfo,'freq',freq_list);
            FigList                 = findobj(allchild(0), 'flat', 'Type', 'figure');
            FigHandle               = FigList(1);
            FigName                 = strcat("Cross-spectrum_cleaned - ",EEG_cleaned.event_name);
            % Add a Snapshot to the report
            f_report('Snapshot', FigHandle, FigName, [] , [200,200,875,450]);
            savefig(FigHandle, fullfile(save_forder, strcat(FigName,".fig")));
            close(FigHandle);
            
            pop_topoplot( EEG_cleaned, 1, [0 100 200 300 400 500], 'Continuous EEG data epoch', [2 3]);
            FigList                 = findobj(allchild(0), 'flat', 'Type', 'figure');
            FigHandle               = FigList(1);
            FigName                 = strcat("Continuous EEG data epoch_cleaned - ",EEG_cleaned.event_name);
            % Add a Snapshot to the report
            f_report('Snapshot', FigHandle, FigName, [] , [200,200,875,450]);
            savefig(FigHandle, fullfile(save_path, strcat(FigName,".fig")));
            close(FigHandle);
            
            % Step 12: Saving EEGs before and after cleaned
            save(fullfile(save_forder,strcat(subID, '_EEG_raw.mat')),'-struct','EEG','-v7.3');
            EEG                     = EEG_cleaned;
            save(fullfile(save_forder,strcat(subID, '_EEG_cleaned.mat')),'-struct','EEG','-v7.3');
            close all;
        end
        EEG                         = EEG_cleaned;
        EEGs(i)                     = EEG;
        
    end
else
    EEGs = EEG;
end
end
