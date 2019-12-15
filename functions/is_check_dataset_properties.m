function valided = is_check_dataset_properties(selected_dataset)

valided = true;

if(isfield(selected_dataset, 'eeg_data_path'))
    if(~isfolder(selected_dataset.eeg_data_path) && selected_dataset.eeg_data_path ~= "none")
        valided = false;
        fprintf(2,'\n ->> Error: The EEG folder don''t exist\n');
        return;
    end 
end
if(isfield(selected_dataset, 'anat_data_path'))
    if(~isfolder(selected_dataset.anat_data_path) && selected_dataset.anat_data_path ~= "all")
        valided = false;
        fprintf(2,'\n ->> Error: The Anat folder don''t exist\n');
        return;
    end
end
if(isfield(selected_dataset, 'hcp_data_path'))
    if(~isfolder(selected_dataset.hcp_data_path) && selected_dataset.hcp_data_path ~= "all")
        valided = false;
        fprintf(2,'\n ->> Error: The ciftify folder don''t exist\n');
        return;
    end
end
if(isfield(selected_dataset, 'non_brain_data_path'))
    if(~isfolder(selected_dataset.non_brain_data_path) && selected_dataset.non_brain_data_path ~= "all")
        valided = false;
        fprintf(2,'\n ->> Error: The non_brain folder don''t exist\n');
        return;
    end
end
if(isfield(selected_dataset, 'report_output_path'))
    if(~isfolder(selected_dataset.report_output_path) && selected_dataset.report_output_path ~= "local")
        valided = false;
        fprintf(2,'\n ->> Error: The report output folder don''t exist\n');
        return;
    end
end
if(isfield(selected_dataset, 'bcv_input_path'))
    if(~isfolder(selected_dataset.bcv_input_path) && selected_dataset.bcv_input_path ~= "local")
        valided = false;
        fprintf(2,'\n ->> Error: The input BC-Vareta folder don''t exist\n');
        return;
    end
end

end

