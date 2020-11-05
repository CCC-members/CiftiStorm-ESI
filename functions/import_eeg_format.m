function EEG = import_eeg_format(subject_info, selected_data_set, base_path)
data_type    = selected_data_set.preprocessed_data.format;
if(selected_data_set.preprocessed_data.clean_data.run)
    if(isequal(lower(selected_data_set.preprocessed_data.clean_data.toolbox),'eeglab'))
        toolbox_path = selected_data_set.preprocessed_data.clean_data.toolbox_path;        
        max_freq     = selected_data_set.preprocessed_data.clean_data.max_freq;        
        save_path    = fullfile(properties.report_output_path,'Reports',properties.protocol_name,subject_info.name,'EEGLab_preproc');
        EEG          = eeglab_preproc(subject_info.name, base_path, data_type, toolbox_path, 'verbosity', true, 'max_freq', max_freq, 'save_path', save_path);        
        EEG.labels   = {EEG.chanlocs(:).labels};
    end
else
    EEG = struct;
    EEG.subID = subject_info.name;
    switch data_type
        case 'edf'
            [hdr, data]= edfread(base_path);
        case 'plg'
            [pat_info, inf_info, plg_info, mrk_info, win_info, cdc_info, states_name] = plg2matlab(base_path);
            % creating output structure
            data = plg_info.data;            
            hdr.pat_info = pat_info;
            hdr.inf_info = inf_info;
            hdr.mrk_info = mrk_info;
            hdr.win_info = win_info;
            hdr.cdc_info = cdc_info;
            hdr.states_name = states_name;
            hdr.label = inf_info.PLGMontage;
    end
    EEG.data = data;
    EEG.labels = strrep(hdr.label,'REF','');
    EEG.srate = hdr.samples(1);    
end
if(~isequal(selected_data_set.process_import_channel.channel_label_file,"none"))
    user_labels = jsondecode(fileread(selected_data_set.process_import_channel.channel_label_file));
    disp ("-->> Cleanning EEG bad Channels by user labels");
    EEG  = remove_eeg_channels_by_labels(user_labels,EEG);
end
end
