function MEG = import_meg_format(subID, properties, base_path)
data_type    = properties.data_config.format;
MEG = struct;
MEG.subID = subID;
switch data_type
    case 'mat'
        try
            MEG_file        = load(base_path);
            MEG.hdr         = MEG_file.data.hdr;
            MEG.srate       = MEG_file.data.fsample;
            MEG.trialinfo   = MEG_file.data.trialinfo;
            MEG.grad        = MEG_file.data.grad;
            MEG.time        = MEG_file.data.time;
            MEG.labels      = MEG_file.data.label;
            MEG.cfg         = MEG_file.data.cfg;
        catch
            lab         = load('/home/Ian/Documents/meg-tool/BC-V_data_converter-master/app/meg_label.mat');
            channel     = lab.Channel1;
            lim         = length(channel);
            for i=1:lim
                ni = string(channel(i).Name);
                name(i) = ni ;
            end
            name        = name';
            MEG.labels  = name;
        end
end
try
    MEG.data = MEG_file.data.trial;
catch
    MEG.data = MEG_file.meg;
end
%MEG.labels = strrep(labels,'REF','');
% MEG.srate = hdr.samples(1);
% if(~isequal(selected_data_set.process_import_channel.channel_label_file,"none"))
%     user_labels = jsondecode(fileread(selected_data_set.process_import_channel.channel_label_file));
%     disp ("-->> Cleanning EEG bad Channels by user labels");
%     MEG  = remove_eeg_channels_by_labels(user_labels,MEG);
% end
end

