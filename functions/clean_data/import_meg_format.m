function MEG = import_meg_format(subID, selected_data_set, base_path)
data_type    = selected_data_set.preprocessed_data.format;
MEG = struct;
MEG.subID = subID;
switch data_type
    case 'mat'
        MEG_file = load(base_path);
        MEG.hdr = MEG_file.data.hdr;
        MEG.srate = MEG_file.data.fsample;
        MEG.trialinfo = MEG_file.data.trialinfo;
        MEG.grad = MEG_file.data.grad;
        MEG.time = MEG_file.data.time;
        labels = MEG_file.data.label;
        MEG.cfg = MEG_file.data.cfg;
end
MEG.data = MEG_file.data.trial;
MEG.labels = strrep(labels,'REF','');
% MEG.srate = hdr.samples(1);
% if(~isequal(selected_data_set.process_import_channel.channel_label_file,"none"))
%     user_labels = jsondecode(fileread(selected_data_set.process_import_channel.channel_label_file));
%     disp ("-->> Cleanning EEG bad Channels by user labels");
%     MEG  = remove_eeg_channels_by_labels(user_labels,MEG);
% end
end
