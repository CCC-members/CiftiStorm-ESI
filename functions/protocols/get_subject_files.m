function [subject_environment, files_checked] = get_subject_files(selected_data_set,subID,dataset_name)
%GET_SUBJECT_FILES Summary of this function goes here
%   Detailed explanation goes here

subject_environment = struct;
files_checked = true;
% MRI File
base_path =  strrep(selected_data_set.hcp_data_path.base_path,'SubID',subID);
filepath = strrep(selected_data_set.hcp_data_path.file_location,'SubID',subID);
T1w_file = fullfile(base_path,filepath);
subject_environment.T1w_file = T1w_file;

% Cortex Surfaces
filepath = strrep(selected_data_set.hcp_data_path.L_surface_location,'SubID',subID);
L_surface_file = fullfile(base_path,filepath);
subject_environment.L_surface_file = L_surface_file;

filepath = strrep(selected_data_set.hcp_data_path.R_surface_location,'SubID',subID);
R_surface_file = fullfile(base_path,filepath);
subject_environment.R_surface_file = R_surface_file;

filepath = strrep(selected_data_set.hcp_data_path.Atlas_seg_location,'SubID',subID);
Atlas_seg_location = fullfile(base_path,filepath);
subject_environment.Atlas_seg_location = Atlas_seg_location;

if(~isfile(T1w_file) || ~isfile(L_surface_file) || ~isfile(R_surface_file) || ~isfile(Atlas_seg_location))
    fprintf(2,strcat('\n -->> Error: The Tw1 or Cortex surfaces: \n'));
    disp(string(T1w_file));
    disp(string(L_surface_file));
    disp(string(R_surface_file));
    disp(string(Atlas_seg_location));
    fprintf(2,strcat('\n -->> Do not exist. \n'));
    fprintf(2,strcat('\n -->> Jumping to an other subject. \n'));
    files_checked = false;
end

% Non-Brain surface files
base_path =  strrep(selected_data_set.non_brain_data_path.base_path,'SubID',subID);
filepath = strrep(selected_data_set.non_brain_data_path.head_file_location,'SubID',subID);
head_file = fullfile(base_path,filepath);
subject_environment.head_file = head_file;

filepath =  strrep(selected_data_set.non_brain_data_path.outerfile_file_location,'SubID',subID);
outerskull_file = fullfile(base_path,filepath);
subject_environment.outerskull_file = outerskull_file;

filepath = strrep(selected_data_set.non_brain_data_path.innerfile_file_location,'SubID',subID);
innerskull_file = fullfile(base_path,filepath);
subject_environment.innerskull_file = innerskull_file;

if(~isfile(head_file) || ~isfile(outerskull_file) || ~isfile(innerskull_file))
% if(~isfile(head_file))
    fprintf(2,strcat('\n -->> Error: The Non-brain surfaces: \n'));
    disp(string(head_file));
    %             disp(string(L_surface_file));
    %             disp(string(R_surface_file));
    fprintf(2,strcat('\n -->> Do not exist. \n'));
    fprintf(2,strcat('\n -->> Jumping to an other subject. \n'));
    files_checked = false;
    return;
end

if(isequal(dataset_name,'hbn'))
    % eeg raw data files
    base_path =  strrep(selected_data_set.eeg_raw_data_path.base_path,'SubID',subID);
    filepath = strrep(selected_data_set.eeg_raw_data_path.file_location,'SubID',subID);
    raw_eeg = fullfile(base_path,filepath);
    subject_environment.raw_eeg = raw_eeg;
    
    if(selected_data_set.eeg_raw_data_path.isfile)
        if(~isfile(raw_eeg))
            fprintf(2,strcat('\n -->> Error: The EEG Raw data: \n'));
            disp(string(raw_eeg));
            fprintf(2,strcat('-->> Do not exist or is not a file. \n'));
            fprintf(2,strcat('-->> Jumping to an other subject. \n'));
            files_checked = false;
            return;
        end
    else
        if(~isfolder(raw_eeg))
            %         if(~isequal(selected_data_set.eeg_raw_data_path.))
            fprintf(2,strcat('\n -->> Error: The EEG Raw data: \n'));
            disp(string(raw_eeg));
            fprintf(2,strcat('-->> Do not exist or is not a folder. \n'));
            fprintf(2,strcat('-->> Jumping to an other subject. \n'));
            files_checked = false;
            return;
        end
        if(isequal(selected_data_set.eeg_raw_data_path.data_format,'mff'))
            
        end
    end
end

%%
%% Checking the report output structure
%%
if(selected_data_set.report_output_path == "local")
    report_output_path = pwd;
else
    report_output_path = selected_data_set.report_output_path ;
end
if(~isfolder(report_output_path))
    mkdir(report_output_path);
end
if(~isfolder(fullfile(report_output_path,'Reports')))
    mkdir(fullfile(report_output_path,'Reports'));
end
if(~isfolder(fullfile(report_output_path,'Reports',ProtocolName)))
    mkdir(fullfile(report_output_path,'Reports',ProtocolName));
end
if(~isfolder(fullfile(report_output_path,'Reports',ProtocolName,subID)))
    mkdir(fullfile(report_output_path,'Reports',ProtocolName,subID));
end
subject_report_path = fullfile(report_output_path,'Reports',ProtocolName,subID);
report_name = fullfile(subject_report_path,[subID,'.html']);
iter = 2;
while(isfile(report_name))
    report_name = fullfile(subject_report_path,[subID,'_Iter_', num2str(iter),'.html']);
    iter = iter + 1;
end
subject_environment.subject_report_path = subject_report_path;
subject_environment.report_name = report_name;

end