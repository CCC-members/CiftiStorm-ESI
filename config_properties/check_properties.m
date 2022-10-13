function [status, reject_subjects] = check_properties(properties)
%CHECK_PROPERTIES Summary of this function goes here
%   Detailed explanation goes here
status = true;
reject_subjects = {};

disp('==========================================================================');
disp("-->> Checking properties");
disp('==========================================================================');
%%
%% Checking general params
%%
disp('-->> Checking general params');
general_params = properties.general_params.params;
if(isempty(general_params.modality) && ~isequal(general_params.modality,'EEG') && ~isequal(general_params.modality,'MEG'))
    status = false;
    fprintf(2,'\n-->> Error: The modality have to be EEG or MEG.\n');
    disp('-->> Process stoped!!!');
    return;
end
if(isempty(general_params.bst_config.protocol_name))
    status = false;
    fprintf(2,'\n-->> Error: The protocol name can not be empty.\n');
    disp('-->> Process stoped!!!');
    return;
end
if(~isempty(general_params.colormap) && ~isequal(general_params.colormap,'none') && ~isfile(general_params.colormap))
    status = false;
    fprintf(2,'\n-->> Error: Do not exist the colormap file defined in selected dataset configuration file.\n');
    disp(general_params.colormap);
    disp('-->> Process stoped!!!');
    return;
end
if(~isfolder(general_params.bst_config.bst_path)...
        || ~isfile(fullfile(general_params.bst_config.bst_path,'brainstorm.m')))
    fprintf(2,"\n ->> Error: The selected Brainstorm path is wrong. \n");
    disp(general_params.bst_config.bst_path);
    disp('-->> Process stoped!!!');
    status = false;
    return;
end
if(~isequal(general_params.bst_config.db_path,'local')...
        && ~isempty(general_params.bst_config.db_path)...
        && ~isfolder(general_params.db_path))
    fprintf(2,strcat("\n ->> Error: The Brainstorm database path is wrong. \n"));
    disp(general_params.bst_config.db_path);
    disp("______________________________________________________________________________________________");
    disp("Please configure app_properties.bst_db_path element in app/properties file. ")
    status = false;
    return;
end
if(isfolder(general_params.bst_config.db_path))
    [~,values] = fileattrib(general_params.bst_config.db_path);
    if(~values.UserWrite)
        fprintf(2,strcat("The current user do not have write permissions on the selected forder for Brainstorm database path."));
        disp(general_params.bst_config.db_path)
        disp(' Please check the folder permission or select another output folder.');
        status = false;
        return;
    end
end
if(~isfolder(general_params.spm_config.spm_path)...
        || ~isfile(fullfile(general_params.spm_config.spm_path,'spm.m')))
    fprintf(2,"\n ->> Error: The selected SPM path is wrong. \n");
    disp(general_params.spm_config.spm_path);
    disp('-->> Process stoped!!!');
    status = false;
    return;
end

%%
%% Checking anatomy params
%%
if(~general_params.bst_config.after_MaQC.run)
    % Anatomy type configuration
    disp("--------------------------------------------------------------------------");
    disp('-->> Checking anatomy params');
    anat_params = properties.anatomy_params.params;
    if(isempty(anat_params.anatomy_type.type)...
            && ~isequal(anat_params.anatomy_type.type,1)...
            && ~isequal(anat_params.anatomy_type.type,2)...
            && ~isequal(anat_params.anatomy_type.type,3))
        fprintf(2,"\n ->> Error: The anatomy type have to be <<1>>, <<2>>, or <<3>>. \n");
        disp('1: For use default anatomy type.');
        disp('2: For use HCP anatomy as template.');
        disp('3: For use HCP individual anatomy.');
        status = false;
        disp('-->> Process stoped!!!');
        return;
    end
    % Check default template configuration
    if(isequal(anat_params.anatomy_type.type,1))
        disp("--------------------------------------------------------------------------");
        disp('-->> Checking template configuration');
        selected_anatomy = anat_params.anatomy_type.type_list{1};
        template_name = selected_anatomy.template_name;
        defaults = jsondecode(fileread(fullfile('bst_templates','bst_default_anatomy.json')));
        if(~contains(template_name, {defaults.name}))
            fprintf(2,strcat('\nBC-V-->> Error: The selected template name in process_import_anat.json is wrong \n'));
            disp(strcat("Name: ",template_name));
            disp(strcat("Please check the aviable anatomy templates in bst_template/bst_default_anatomy.json file"));
            status = false;
            disp('-->> Process stoped!!!');
            return;
        end
    end
    % Check HCP template configuration
    if(isequal(anat_params.anatomy_type.type,2))
        disp("--------------------------------------------------------------------------");
        disp('-->> Checking template configuration');
        selected_anatomy = anat_params.anatomy_type.type_list{2};
        template_name = selected_anatomy.template_name;
        if(isempty(template_name))
            fprintf(2,'The HCP template name can not be empty.\n');
            disp('Please type a HCP Template name.');
            status = false;
            disp('-->> Process stoped!!!');
            return;
        end
        base_path = selected_anatomy.base_path;
        if(~isfolder(fullfile(base_path)))
            fprintf(2,'The HCP template base_path is not a folder.\n');
            disp('Please select a correct HCP Template folder in the process_import_anat.json configuration file.');
            status = false;
            disp('-->> Process stoped!!!');
            return;
        end
        if(~isfolder(fullfile(base_path,template_name)))
            fprintf(2,strcat("There is no folder with <<",template_name,">> in the selected HCP Template folder.\n"));
            disp('Please select a correct HCP Template folder or check the Template name filed.');
            status = false;
            disp('-->> Process stoped!!!');
            return;
        end
        anat_path = fullfile(base_path,template_name,strrep(selected_anatomy.HCP_anat_path,'SubID',template_name), 'T1w');
        checked = check_HCP_anat_structure(anat_path, template_name, selected_anatomy);
        if(~checked)
            fprintf(2,strcat("The folder <<",template_name,">> is not an HCP Template folder.\n"));
            disp('Please select a correct HCP Template folder or check the Template name filed.');
            status = false;
            disp('-->> Process stoped!!!');
            return;
        end
        % Check non brain surfaces configuration
        disp("--------------------------------------------------------------------------");
        disp('-->> Checking non brain surfaces configuration');
        non_brain = anat_params.non_brain_surfaces;
        base_path = non_brain.base_path;
        if(~isfolder(fullfile(base_path)))
            fprintf(2,'The Non-brain surfaces base_path is not a folder.\n');
            disp('Please select a Non-brain surfaces folder in the process_import_anat.json configuration file.');
            status = false;
            disp('-->> Process stoped!!!');
            return;
        end
        checked = check_non_brain_surfaces(base_path,template_name);
        if(~checked)
            fprintf(2,'The Non-brain selected folder is not a FSL Bet command output.\n');
            disp('Please correct the Non-brain surfaces folder in the process_import_anat.json configuration file.');
            status = false;
            disp('-->> Process stoped!!!');
            return;
        end
    end
    % Check HCP individual configuration
    if(isequal(anat_params.anatomy_type.type,3))
        disp("--------------------------------------------------------------------------");
        disp('-->> Checking HCP anatomy configuration');
        selected_anatomy = anat_params.anatomy_type.type_list{3};
        if(isequal(selected_anatomy.subID_prefix,'none') || isempty(selected_anatomy.subID_prefix))
            SubID = 'SubID';
        else
            subID_prefix = selected_anatomy.subID_prefix;
            SubID = strcat(subID_prefix,'SubID');
        end
        base_path = strrep(selected_anatomy.base_path,SubID,'');
        if(~isfolder(fullfile(base_path)))
            fprinprep_paramstf(2,'The HCP individual base_path is not a folder.\n');
            disp('Please select a correct HCP Template folder in the process_import_anat.json configuration file.');
            status = false;
            disp('-->> Process stoped!!!');
            return;
        end
        structures = dir(base_path);
        structures(ismember( {structures.name}, {'.', '..'})) = [];  %remove . and ..
        count_HCP_structure = 0;
        for i=1:length(structures)
            structure = structures(i);
            anat_path = fullfile(base_path,structure.name,strrep(selected_anatomy.HCP_anat_path,SubID,structure.name), 'T1w');
            checked = check_HCP_anat_structure(anat_path, structure.name, selected_anatomy);
            if(~checked)
                count_HCP_structure = count_HCP_structure + 1;
                reject_subjects{length(reject_subjects)} = structure.name;
            end
        end
        if(~isequal(count_HCP_structure,0))
            if(isequal(count_HCP_structure,length(structures)))
                fprintf(2,'Any folder in the Anatomy base path have a HCP structure.\n');
                disp('Please check the HCP individual folder.');
                status = false;
                disp('-->> Process stoped!!!');
                return;
            else
                warning('Some of the subjects do not have a HCP structure.');
                warning('Those anatomies will reject from the analysis.');
                warning('Please check the HCP individual folder.');
            end
        end
        
        % Check non brain surfaces configuration
        disp("--------------------------------------------------------------------------");
        disp('-->> Checking non brain surfaces configuration');
        if(isequal(selected_anatomy.subID_prefix,'none') || isempty(selected_anatomy.subID_prefix))
            SubID = 'SubID';
        else
            subID_prefix = selected_anatomy.subID_prefix;
            SubID = strcat(subID_prefix,'SubID');
        end
        non_brain = anat_params.non_brain_surfaces;
        base_path = non_brain.base_path;
        if(~isfolder(fullfile(base_path)))
            fprintf(2,'The Non-brain surfaces base_path is not a folder.\n');
            disp('Please select a Non-brain surfaces folder in the process_import_anat.json configuration file.');
            status = false;
            disp('-->> Process stoped!!!');
            return;
        end
        structures = dir(base_path);
        structures(ismember( {structures.name}, {'.', '..'})) = [];  %remove . and ..
        count_non_brain = 0;
        for i=1:length(structures)
            structure = structures(i);
            checked = check_non_brain_surfaces(base_path,structure.name);
            if(~checked)
                count_non_brain = count_non_brain + 1;
                reject_subjects{length(reject_subjects)+1} = structure.name;
            end
        end
        if(~isequal(count_non_brain,0))
            if(isequal(count_non_brain,length(structures)))
                fprintf(2,'Any folder in the Non-brain surfaces path have a specific file location.\n');
                disp('Please check the non brain configuration.');
                status = false;
                disp('-->> Process stoped!!!');
                return;
            else
                warning('One or more of the Non-brain surfaces file is not correct.\n');
                warning('Please check the Non-brain surfaces configuration.');
            end
        end
    end
    % Check MRI transform configuration
    mri_transform = anat_params.mri_transformation;
    if(mri_transform.use_transformation)
        disp("--------------------------------------------------------------------------");
        disp('-->> Checking MRI transformation');
        base_path = mri_transform.base_path;
        if(~isfolder(fullfile(base_path)))
            fprintf(2,'The MRI transformation base_path is not a folder.\n');
            disp('Please select a correct MRI transformation folder in the process_import_anat.json configuration file.');
            status = false;
            disp('-->> Process stoped!!!');
            return;
        end
        if(isequal(anat_params.anatomy_type.type,2))
            transf_file = fullfile(base_path,template_name,strrep(mri_transform.file_location,'SubID',template_name));
            if(~isfile(transf_file))
                fprintf(2,'We can not find the MRI file transformation for the HCP anat template:\n');
                fprintf(2,strcat(strrep(mri_transform.file_location,'SubID',template_name),'\n'));
                disp('Please check the transformation config.');
            end
        end
        if(isequal(anat_params.anatomy_type.type,3))
            structures = dir(base_path);
            structures(ismember( {structures.name}, {'.', '..'})) = [];  %remove . and ..
            count_transf = 0;
            for i=1:length(structures)
                structure = structures(i);
                transf_file = fullfile(base_path,structure.name,strrep(mri_transform.file_location,'SubID',structure.name));
                if(~isfile(transf_file)); count_transf = count_transf + 1; end
            end
            if(~isequal(count_transf,0))
                if(isequal(count_transf,length(structures)))
                    fprintf(2,'Any folder in the MRI Transformation base path have a specific file location.\n');
                    fprintf(2,'We can not find the MRI file transformation in this address:\n');
                    fprintf(2,strcat(mri_transform.file_location,'\n'));
                    disp('Please check the transformation config.');
                    status = false;
                    disp('-->> Process stoped!!!');
                    return;
                else
                    warning('One or more of the MRI transformation file is not correct.\n');
                    warning('We can not find at least one of the MRI transformation file in this address:\n');
                    warning(strcat(mri_transform.file_location,'\n'));
                    warning('Please check the transformation config.');
                end
            end
        end
    end
    
    % Check surface resolution
    disp("--------------------------------------------------------------------------");
    disp('-->> Checking surface resolution');
    surf_resol = anat_params.surfaces_resolution;
    if(isempty(surf_resol.nverthead) || surf_resol.nverthead < 2000 || surf_resol.nverthead > 15000)
        fprintf(2,'The Head resolution have be between 2000 and 15000 vertices.\n');
        disp('Please check the nverthead configuration in the process_import_anat.json file.');
        status = false;
        disp('-->> Process stoped!!!');
        return;
    end
    if(isempty(surf_resol.nvertskull) || surf_resol.nvertskull < 2000 || surf_resol.nvertskull > 15000)
        fprintf(2,'The Skull resolution have be between 2000 and 15000 vertices.\n');
        disp('Please check the nvertskull configuration in the process_import_anat.json file.');
        status = false;
        disp('-->> Process stoped!!!');
        return;
    end
    if(isempty(surf_resol.nvertcortex) || surf_resol.nvertcortex < 2000 || surf_resol.nvertcortex > 15000)
        fprintf(2,'The Cortex resolution have be between 2000 and 15000 vertices.\n');
        disp('Please check the nvertcortex configuration in the process_import_anat.json file.');
        status = false;
        disp('-->> Process stoped!!!');
        return;
    end
    
    %%
    %% Checking import channel params
    %%
    disp("--------------------------------------------------------------------------");
    disp('-->> Checking channel params');
    channel_params = properties.channel_params.params;
    if(isempty(channel_params.channel_type.type)...
            && ~isequal(channel_params.channel_type.type,1)...
            && ~isequal(channel_params.channel_type.type,2))
        fprintf(2,"\n ->> Error: The anatomy type have to be <<1>> or <<2>>. \n");
        disp('1: Use raw data channel.');
        disp('2: Use BST default channel.');
        status = false;
        disp('-->> Process stoped!!!');
        return;
    end
    if(isequal(channel_params.channel_type.type,1))
        raw_data = channel_params.channel_type.type_list{1};
        base_path = strrep(raw_data.base_path,'SubID','');
        if(~isfolder(fullfile(base_path)))
            fprintf(2,'The raw_data base path is not a folder.\n');
            disp('Please type a correct raw_data folder in the process_raw_data.json configuration file.');
            status = false;
            disp('-->> Process stoped!!!');
            return;
        end
        if(isempty(raw_data.data_format))
            fprintf(2,'The raw_data format can not be empty.\n');
            disp('Please type a correct raw_data format in the process_raw_data.json configuration file.');
            status = false;
            disp('-->> Process stoped!!!');
            return;
        end
        structures = dir(base_path);
        structures(ismember( {structures.name}, {'.', '..'})) = [];  %remove . and ..
        count_raw = 0;
        for i=1:length(structures)
            structure = structures(i);
            raw_file = fullfile(base_path,structure.name,strrep(raw_data.file_location,'SubID',structure.name));
            if(raw_data.isfile);if(~isfile(raw_file)); count_raw = count_raw + 1; end
            else; if(~isfolder(raw_file)); count_raw = count_raw + 1; end; end
        end
        if(~isequal(count_raw,0))
            if(isequal(count_raw,length(structures)))
                fprintf(2,'Any folder in the Raw_data path have a specific file location.\n');
                fprintf(2,'We can not find the raw_data file in this address:\n');
                fprintf(2,strcat(raw_data.file_location,'\n'));
                disp('Please check the raw_data configuration.');
                status = false;
                disp('-->> Process stoped!!!');
                return;
            else
                warning('One or more of the raw_data file are not correct.\n');
                warning('We can not find at least one of the raw_data file in this address:\n');
                warning(strcat(raw_data.file_location,'\n'));
                warning('Please check the raw_data configuration.');
            end
        end
    end
    if(isequal(channel_params.channel_type.type,2))
        channel = channel_params.channel_type.type_list{2};
        group_name = channel.group_layout_name;
        layout_name = channel.channel_layout_name;
        defaults = jsondecode(fileread(fullfile('bst_templates','bst_layout_default.json')));
        if(~contains(group_name, {defaults.name}))
            fprintf(2,strcat('\nBC-V-->> Error: The selected template group in process_import_channel.json is wrong \n'));
            disp(strcat("Name: ",group_name));
            disp(strcat("Please check the aviable channel templates in bst_template/bst_layout_default.json file"));
            status = false;
            disp('-->> Process stoped!!!');
            return;
        else
            index = find(strcmp({defaults.name},group_name),1);
            layout_names = defaults(1).contents;
            if(~contains(layout_name, {layout_names.name}))
                fprintf(2,strcat('\nBC-V-->> Error: The selected template name in process_import_channel.json is wrong \n'));
                disp(strcat("Name: ",layout_name));
                disp(strcat("Please check the aviable channel templates in bst_template/bst_layout_default.json file"));
                status = false;
                disp('-->> Process stoped!!!');
                return;
            end
        end
    end
    %%
    %% Checking subject number in each folder
    %%
    anat_params = properties.anatomy_params.params;
    if(isequal(anat_params.anatomy_type.type,3))
        hcp_base_path = selected_anatomy.base_path;
        hcp_subjects = dir(hcp_base_path);
        hcp_subjects(ismember( {hcp_subjects.name}, {'.', '..'})) = [];  %remove . and ..
        hcp_names = {hcp_subjects.name};
        
        non_brain_path = non_brain.base_path;
        nb_subjects = dir(non_brain_path);
        nb_subjects(ismember( {nb_subjects.name}, {'.', '..'})) = [];  %remove . and ..
        nb_names = {nb_subjects.name};
        
        index1 = ismember(hcp_names,nb_names);
        index2 = ismember(nb_names,hcp_names);
        hcp_names(index1) = [];
        nb_names(index2) = [];
        reject_subjects = [reject_subjects , hcp_names, nb_names];
    end
    reject_subjects = unique(reject_subjects);
    if(~isempty(reject_subjects))
        disp("-->> Subjects to reject");
        disp("--------------------------------------------------------------------------");
        warning('-->> Some subject do not have the correct structure');
        warning('-->> The following subjects will be rejected for analysis');
        disp(reject_subjects);
        warning('Please check the folder structure.');
    end
else
    
end
disp("--------------------------------------------------------------------------");
disp('-->> All preoperties checked.');
disp('==========================================================================');
end                                                                                                                                                            