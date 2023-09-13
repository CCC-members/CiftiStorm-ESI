function [ChannelFile] = reduce_channel_BY_prep_eeg_OR_user_labels(selected_data_set,channel_layout,ChannelFile,subID)

if(isfield(selected_data_set, 'process_import_channel') ...
        && isfield(selected_data_set.process_import_channel, 'channel_label_file') ...
        && ~isequal(selected_data_set.process_import_channel.channel_label_file,'none'))
    % Checking if label file match with selected channel layout
    user_labels = jsondecode(fileread(selected_data_set.process_import_channel.channel_label_file));
    if(is_match_labels_vs_channel_layout(user_labels,channel_layout.Channel))
        disp("-->> Labels file is matching whit the selected Channel Layout.");
        disp("-->> Removing channels from Labels file.");       
        [channel_layout] = remove_channels_from_layout(user_labels,channel_layout);
    else
        msg = '-->> Some labels don''t match whit the selected Channel Layout.';
        fprintf(2,msg);
        disp('');
        brainstorm stop;
        return;
    end
elseif(isfield(selected_data_set, 'preprocessed_eeg') )
    if(~isequal(selected_data_set.preprocessed_eeg.base_path,'none'))
        filepath = strrep(selected_data_set.preprocessed_eeg.file_location,'SubID',subID);
        base_path =  strrep(selected_data_set.preprocessed_eeg.base_path,'SubID',subID);
        eeg_file = fullfile(base_path,filepath);
        if(isfile(eeg_file))
            disp ("-->> Genering eeg file");
            [hdr, data] = import_eeg_format(eeg_file,selected_data_set.preprocessed_eeg.format);
            labels = hdr.label;
            labels = strrep(labels,'REF','');
            disp ("-->> Removing channels");
            [channel_layout] = remove_channels_from_layout(labels,channel_layout);
            disp ("-->> Sorting channels");
            [channel_layout] = sort_channels_by_labels(labels,channel_layout);
        else
            
        end
    end
else
    return;    
end

tmp_path = selected_data_set.tmp_path;
if(isequal(tmp_path,'local'))
    tmp_path = pwd;
end
tmp_path = fullfile(tmp_path,'tmp');
if(~isfolder(tmp_path))
    mkdir(tmp_path);
end
[~,name,ext] = fileparts(ChannelFile);
ChannelFile = fullfile(tmp_path,[name,ext]);
disp('-->> Saving new channel file in tmp folder.')
save(ChannelFile,'-struct','channel_layout');

end

