function EEGs = import_eeg_format(subID, properties, base_path)

data_type    = properties.format;
if(~isequal(properties.channel_label_file,"none") && ~isempty(properties.channel_label_file))
    user_labels = jsondecode(fileread(properties.channel_label_file));    
end
if(properties.clean_data.run)    
    if(isequal(lower(properties.clean_data.toolbox),'eeglab'))
        toolbox_path    = properties.clean_data.toolbox_path;
        max_freq        = properties.clean_data.max_freq;            
        select_events   = properties.clean_data.select_events;
        if(isequal(properties.name,'raw_data'))
           use_raw_data = true; 
        else
            use_raw_data = false;
        end
        %         save_path    = fullfile(selected_data_set.report_output_path,'Reports',selected_data_set.protocol_name,subject_info.name,'EEGLab_preproc');
        if(exist('user_labels','var'))
            EEGs      = eeglab_preproc(subID, base_path, data_type, toolbox_path, 'verbosity', true, 'max_freq', max_freq,...
                'labels', user_labels, 'select_events', select_events, 'use_raw_data', use_raw_data);
        else
            EEGs      = eeglab_preproc(subID, base_path, data_type, toolbox_path, 'verbosity', true, 'max_freq', max_freq,...
                 'select_events', select_events, 'use_raw_data', use_raw_data);
        end
        for i=1:length(EEGs)
            EEGs(i).labels   = {EEGs(i).chanlocs(:).labels};
        end
    end
else    
    switch data_type
        case 'edf'
            [hdr, data]     = edfread(base_path);
             EEG.data    = data;
             EEG.labels  = strrep(hdr.label,'REF','');
             EEG.srate   = hdr.samples(1);
        case 'plg'
            try
                EEG         = readplot_plg(fullfile(base_path));
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
            labels = EEG.chanlocs;
            for i=1:length(labels)
               chan_row.labels = labels(i).labels;
               new_chanlocs(i) = chan_row;
            end
            EEG.chanlocs = new_chanlocs;
            EEG.chaninfo = template.EEG.chaninfo;
        case 'txt'
            load('templates/EEG_template_58Ch.mat');
            [filepath,filename,~]   = fileparts(base_path);
            EEG.filename            = filename;
            EEG.filepath            = filepath;
            EEG.subject             = subID;
            data                    = readmatrix(base_path);
            data                    = data';
            EEG.data                = data;
            EEG.nbchan              = length(EEG.chanlocs);
            EEG.pnts                = size(data,2);
            EEG.srate               = 200;
            EEG.min                 = 0;
            EEG.max                 = EEG.xmin+(EEG.pnts-1)*(1/EEG.srate);
            EEG.times               = (0:EEG.pnts-1)/EEG.srate.*1000;
            EEG.subID               = subID;
            EEG.setname             = subID;
    end   
    if(exist('user_labels','var'))
        disp ("-->> Cleanning EEG bad Channels by user labels");
        EEG         = remove_eeg_channels_by_labels(user_labels,EEG);
        EEG.labels  = {EEG.chanlocs(:).labels};
    end
    EEG.subID   = subID;
    EEG.setname = subID;
    EEGs        = EEG;
end
end