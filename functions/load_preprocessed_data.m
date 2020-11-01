function [subject_info,HeadModels,Cdata] = load_preprocessed_data(subject_info,selected_data_set,output_subject_dir,data_file,HeadModels,Cdata)
if(isequal(selected_data_set.modality,'EEG'))
    disp ("-->> Genering eeg file");
    if(selected_data_set.preprocessed_data.clean_data.run)
       if(isequal(lower(selected_data_set.preprocessed_data.clean_data.toolbox),'eeglab'))
           toolbox_path = selected_data_set.preprocessed_data.clean_data.toolbox_path;
           data_type    = selected_data_set.preprocessed_data.format;
           max_freq     = selected_data_set.preprocessed_data.clean_data.max_freq;
           EEG          = eeglab_preproc(subject_info.name, data_file, data_type, toolbox_path, 'verbosity', true, 'max_freq', max_freq);
           data         = EEG.data;
       end
    end    
    [hdr, data] = import_eeg_format(data_file,selected_data_set.preprocessed_data.format);
    if(~isequal(selected_data_set.process_import_channel.channel_label_file,"none"))
        user_labels = jsondecode(fileread(selected_data_set.process_import_channel.channel_label_file));
        disp ("-->> Cleanning EEG bad Channels by user labels");
        [data,hdr]  = remove_eeg_channels_by_labels(user_labels,data,hdr);
    end
    labels = hdr.label;
    for h=1:length(HeadModels)
        HeadModel = HeadModels(h);
        disp ("-->> Removing Channels  by preprocessed EEG");
        [Cdata_r,Ke] = remove_channels_and_leadfield_from_layout(labels,Cdata,HeadModel.Ke);
        disp ("-->> Sorting Channels and LeadField by preprocessed EEG");
        [Cdata_s,Ke] = sort_channels_and_leadfield_by_labels(labels,Cdata_r,Ke);
        HeadModels(h).Ke = Ke;
    end
    Cdata = Cdata_s;
    dirref = replace(fullfile('eeg','eeg.mat'),'\','/');
    subject_info.eeg_dir = dirref;
    dirref = replace(fullfile('eeg','eeg_info.mat'),'\','/');
    subject_info.eeg_info_dir = dirref;
    disp ("-->> Saving eeg_info file");
    save(fullfile(output_subject_dir,'eeg','eeg_info.mat'),'hdr');
    disp ("-->> Saving eeg file");
    save(fullfile(output_subject_dir,'eeg','eeg.mat'),'data');
else
    disp ("-->> Genering meg file");
    meg = load(data_file);
    hdr = meg.data.hdr;
    fsample = meg.data.fsample;
    trialinfo = meg.data.trialinfo;
    grad = meg.data.grad;
    time = meg.data.time;
    label = meg.data.label;
    cfg = meg.data.cfg;
    %                 labels = strrep(labels,'REF','');
    for h=1:length(HeadModels)
        HeadModel = HeadModels(h);
        disp ("-->> Removing Channels by preprocessed MEG");
        [Cdata_r,Ke] = remove_channels_and_leadfield_from_layout(label,Cdata,HeadModel.Ke);
        disp ("-->> Sorting Channels and LeadField by preprocessed MEG");
        [Cdata_s,Ke] = sort_channels_and_leadfield_by_labels(label,Cdata_r,Ke);
        HeadModels(h).Ke = Ke;
    end
    Cdata = Cdata_s;
    data = [meg.data.trial];
    trials = meg.data.trial;
    
    dirref = replace(fullfile('meg','meg.mat'),'\','/');
    subject_info.meg_dir = dirref;
    dirref = replace(fullfile('meg','meg_info.mat'),'\','/');
    subject_info.meg_info_dir = dirref;
    dirref = replace(fullfile('meg','trials.mat'),'\','/');
    subject_info.trials_dir = dirref;
    disp ("-->> Saving meg_info file");
    save(fullfile(output_subject_dir,'meg','meg_info.mat'),'hdr','fsample','trialinfo','grad','time','label','cfg');
    disp ("-->> Saving meg file");
    save(fullfile(output_subject_dir,'meg','meg.mat'),'data');
    disp ("-->> Saving meg trials file");
    save(fullfile(output_subject_dir,'meg','trials.mat'),'trials')
end
end

