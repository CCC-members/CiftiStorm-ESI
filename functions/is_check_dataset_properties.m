function valided = is_check_dataset_properties(selected_dataset)

valided = true;

if(isfield(selected_dataset, 'hcp_data_path'))
    if(~isfield(selected_dataset.hcp_data_path, 'base_path')...
            || ~isfield(selected_dataset.hcp_data_path, 'file_location')...
            || ~isfield(selected_dataset.hcp_data_path, 'L_surface_location')...
            || ~isfield(selected_dataset.hcp_data_path, 'R_surface_location')...
            || ~isfield(selected_dataset.hcp_data_path, 'Atlas_seg_location'))
        valided = false; 
        fprintf(2,'\n -->> Error: The hcp_data_path field is not correct \n');
        fprintf(2,'\n -->> Please, check the app_protocols.json file and fix the error \n');
        return;
    end  
end
if(isfield(selected_dataset, 'non_brain_data_path'))
    if(~isfield(selected_dataset.non_brain_data_path, 'base_path')...
            || ~isfield(selected_dataset.non_brain_data_path, 'head_file_location') ...
            || ~isfield(selected_dataset.non_brain_data_path, 'outerfile_file_location') ...
            || ~isfield(selected_dataset.non_brain_data_path, 'innerfile_file_location'))
        valided = false; 
        fprintf(2,'\n -->> Error: The non_brain_data_path field is not correct \n');
        return;
    end
end
if(isfield(selected_dataset, 'eeg_raw_data_path'))
    if(~isfield(selected_dataset.eeg_raw_data_path, 'base_path')...
            || ~isfield(selected_dataset.eeg_raw_data_path, 'file_location')...
            || ~isfield(selected_dataset.eeg_raw_data_path, 'data_format') ...
            || ~isfield(selected_dataset.eeg_raw_data_path, 'isfile'))
        valided = false;
        fprintf(2,'\n -->> Error: The EEG Raw folder don''t exist. \n');
        disp("OR");
        fprintf(2,'-->> Error: The eeg_raw_data_path field is not correct. \n');
        return;
    end 
end
if(isfield(selected_dataset, 'preprocessed_eeg'))
    if(~isfield(selected_dataset.preprocessed_eeg, 'base_path')...
            || ~isfield(selected_dataset.preprocessed_eeg, 'file_location')...
            || ~isfield(selected_dataset.preprocessed_eeg, 'format'))
        valided = false;
        fprintf(2,'\n -->> Error: The Preprocessed EEG folder don''t exist. \n');
        disp("OR");
        fprintf(2,'\n -->> Error: The preprocessed_eeg field is not correct. \n');
        return;
    end 
end
if(isfield(selected_dataset, 'anat_data_path'))
    if(~isfolder(selected_dataset.anat_data_path.base_path) && selected_dataset.anat_data_path.base_path ~= "none")
        valided = false;
        fprintf(2,'\n -->> Error: The Anat folder don''t exist. \n');
        return;
    end
end
if(isfield(selected_dataset, 'report_output_path'))
    if(~isfolder(selected_dataset.report_output_path) && selected_dataset.report_output_path ~= "local")
        valided = false;
        fprintf(2,'\n -->> Error: The report output folder don''t exist\n');
        return;
    end
end
if(isfield(selected_dataset, 'bcv_input_path'))
    if(~isfolder(selected_dataset.bcv_input_path) && selected_dataset.bcv_input_path ~= "local")
        valided = false;
        fprintf(2,'\n -->> Error: The input BC-Vareta folder don''t exist\n');
        return;
    end
end
if(isfield(selected_dataset, 'meg_data_path'))
    if(~isfield(selected_dataset.meg_data_path, 'base_path')...
            && (~isequal(selected_dataset.meg_data_path.base_path,"none") && ~isfolder(selected_dataset.meg_data_path.base_path)))
        valided = false;
        fprintf(2,'\n -->> Error: The meg_data_path field is not correct \n');
        return;
    end    
end
if(isfield(selected_dataset, 'meg_transformation_path'))
    if(~isfield(selected_dataset.meg_transformation_path, 'base_path')...
            && (~isequal(selected_dataset.meg_transformation_path.base_path,"none") && ~isfolder(selected_dataset.meg_transformation_path.base_path)))
        valided = false;
        fprintf(2,'\n -->> Error: The meg_transformation_path field is not correct \n');
        return;
    end    
end

end

