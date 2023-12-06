function [status, reject_subjects] = check_properties(properties)
%CHECK_PROPERTIES Summary of this function goes here
%   Detailed explanation goes here
status = true;
reject_subjects = struct;
reject_anat = {};
reject_nonbrain = {};

disp('==========================================================================');
disp("-->> Checking properties");
disp('==========================================================================');
%%
%% Checking general params
%%
disp('-->> Checking general params');
general_params = properties.general_params;
if(isempty(general_params.modality) && ~isequal(general_params.modality,'EEG') && ~isequal(general_params.modality,'MEG'))
    status = false;
    fprintf(2,'\n-->> Error: The modality have to be EEG or MEG.\n');
    disp('-->> Process stopped!!!');
    return;
end
protocol_name = general_params.bst_config.protocol_name;
if(isempty(general_params.bst_config.protocol_name))
    status = false;
    fprintf(2,'\n-->> Error: The protocol name can not be empty.\n');
    disp('-->> Process stopped!!!');
    return;
end
if(~isfolder(general_params.bst_config.bst_path)...
        || ~isfile(fullfile(general_params.bst_config.bst_path,'brainstorm.m')))
    fprintf(2,"\n ->> Error: The selected Brainstorm path is wrong. \n");
    disp(general_params.bst_config.bst_path);
    disp('-->> Process stopped!!!');
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
%% Checking output param
if(isfolder(general_params.output_path))
    [~,values] = fileattrib(general_params.output_path);
    if(~values.UserWrite)
        fprintf(2,strcat("The current user do not have write permissions on the selected forder for Output path."));
        disp(general_params.output_path)
        disp(' Please check the folder permission or select another output folder.');
        status = false;
        return;
    end
    if(~isfolder(fullfile(general_params.output_path,'CiftiStorm',protocol_name)))
        mkdir(fullfile(general_params.output_path,'CiftiStorm',protocol_name));        
    end
    if(~isfolder(fullfile(general_params.output_path,'BST','Subjects',protocol_name)))
        mkdir(fullfile(general_params.output_path,'BST','Subjects',protocol_name));        
    end
    if(~isfolder(fullfile(general_params.output_path,'BST','Reports',protocol_name)))
        mkdir(fullfile(general_params.output_path,'BST','Reports',protocol_name));        
    end
else
    fprintf(2,strcat("The Output path do not exist."));
    disp(general_params.output_path)
    disp(' Please type a correct output folder.');
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
    anat_params = properties.anatomy_params;
    
    % Check default template configuration
    if(isequal(lower(anat_params.anatomy_type.id),'template'))
        disp("--------------------------------------------------------------------------");
        disp('-->> Checking template configuration');
        selected_anatomy = anat_params.anatomy_type;
        template_name = selected_anatomy.template_name;
        defaults = jsondecode(fileread(fullfile('bst_defaults','bst_default_anatomy.json')));
        if(~contains(template_name, {defaults.Name}))
            fprintf(2,strcat('\nBC-V-->> Error: The selected template name in process_import_anat.json is wrong \n'));
            disp(strcat("Name: ",template_name));
            disp(strcat("Please check the available anatomy templates in bst_template/bst_default_anatomy.json file"));
            status = false;
            disp('-->> Process stopped!!!');
            return;
        end
    end
   
    % Check HCP individual configuration
    if(isequal(lower(anat_params.anatomy_type.id),'individual'))
        disp("--------------------------------------------------------------------------");
        disp('-->> Checking HCP anatomy configuration');
        selected_anatomy = anat_params.anatomy_type;        
        SubID = 'SubID';
        base_path = strrep(selected_anatomy.base_path,SubID,'');
        if(~isfolder(fullfile(base_path)))
            fprinprep_paramstf(2,'The HCP individual base_path is not a folder.\n');
            disp('Please select a correct HCP Template folder in the process_import_anat.json configuration file.');
            status = false;
            disp('-->> Process stopped!!!');
            return;
        end
        structures = dir(base_path);
        structures(ismember( {structures.name}, {'.', '..'})) = [];  %remove . and ..
        count_HCP_structure = 0;
        for i=1:length(structures)
            structure = structures(i);            
            checked = check_HCP_anat_structure(structure, selected_anatomy);
            if(~checked)
                count_HCP_structure = count_HCP_structure + 1;
                reject_anat{end+1} = structure.name;
            end
        end
        if(~isequal(count_HCP_structure,0))
            if(isequal(count_HCP_structure,length(structures)))
                fprintf(2,'Any folder in the Anatomy base path have a HCP structure.\n');
                disp('Please check the HCP individual folder.');
                disp(base_path);
                status = false;
                disp('-->> Process stopped!!!');
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
        non_brain = anat_params.common_params.non_brain_surfaces;
        base_path = non_brain.base_path;
        if(~isfolder(fullfile(base_path)))
            fprintf(2,'The Non-brain surfaces base_path is not a folder.\n');
            disp('Please select a Non-brain surfaces folder in the process_import_anat.json configuration file.');
            status = false;
            disp('-->> Process stopped!!!');
            return;
        end
        structures = dir(base_path);
        structures(ismember( {structures.name}, {'.', '..'})) = [];  %remove . and ..
        count_non_brain = 0;
        for i=1:length(structures)
            structure = structures(i);
            checked = check_non_brain_surfaces(structure);
            if(~checked)
                count_non_brain = count_non_brain + 1;
                reject_nonbrain{end+1} = structure.name;
            end
        end
        if(~isequal(count_non_brain,0))
            if(isequal(count_non_brain,length(structures)))
                fprintf(2,'Any folder in the Non-brain surfaces path have a specific file location.\n');
                disp('Please check the non brain configuration.');
                status = false;
                disp('-->> Process stopped!!!');
                return;
            else
                warning('One or more of the Non-brain surfaces file is not correct.\n');
                warning('Please check the Non-brain surfaces configuration.');
            end
        end
    end
    % Check MRI transform configuration
    mri_transform = anat_params.common_params.mri_transformation;
    if(mri_transform.use_transformation)
        disp("--------------------------------------------------------------------------");
        disp('-->> Checking MRI transformation');
        base_path = mri_transform.base_path;
        if(~isfolder(fullfile(base_path)))
            fprintf(2,'The MRI transformation base_path is not a folder.\n');
            disp('Please select a correct MRI transformation folder in the process_import_anat.json configuration file.');
            status = false;
            disp('-->> Process stopped!!!');
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
                    disp('-->> Process stopped!!!');
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
    surf_resol = anat_params.common_params.surfaces_resolution;
    if(isempty(surf_resol.nvertices) || surf_resol.nvertices > 100000)
        fprintf(2,'The surfaces resolution have be between 2000 and 100000 vertices.\n');
        disp('Please check the nvertices configuration in the process_import_anat.json file.');
        status = false;
        disp('-->> Process stopped!!!');
        return;
    end   
    
    %%
    %% Checking import channel params
    %%
    disp("--------------------------------------------------------------------------");
    disp('-->> Checking channel params');
    channel_params = properties.channel_params;
   
    if(isequal(lower(channel_params.channel_type.id),'raw'))
        raw_data = channel_params.channel_type;
        base_path = strrep(raw_data.base_path,'SubID','');
        if(~isfolder(fullfile(base_path)))
            fprintf(2,'The raw_data base path is not a folder.\n');
            disp('Please type a correct raw_data folder in the process_raw_data.json configuration file.');
            status = false;
            disp('-->> Process stopped!!!');
            return;
        end
        if(isempty(raw_data.data_format))
            fprintf(2,'The raw_data format can not be empty.\n');
            disp('Please type a correct raw_data format in the process_raw_data.json configuration file.');
            status = false;
            disp('-->> Process stopped!!!');
            return;
        end
        structures = dir(base_path);
        structures(ismember( {structures.name}, {'.', '..'})) = [];  %remove . and ..
        count_raw = 0;
        for i=1:length(structures)
            structure = structures(i);
            raw_file = fullfile(base_path,structure.name,strrep(raw_data.file_location,'SubID',structure.name));
            if(~isfile(raw_file))
                count_raw = count_raw + 1;
                reject_chann{end+1} = structure.name;
            end            
        end
        if(~isequal(count_raw,0))
            if(isequal(count_raw,length(structures)))
                fprintf(2,'Any folder in the Raw_data path have a specific file location.\n');
                fprintf(2,'We can not find the raw_data file in this address:\n');
                fprintf(2,strcat(raw_data.file_location,'\n'));
                disp('Please check the raw_data configuration.');
                status = false;
                disp('-->> Process stopped!!!');
                return;
            else
                warning('One or more of the raw_data file are not correct.\n');
                warning('We can not find at least one of the raw_data file in this address:\n');
                warning(strcat(raw_data.file_location,'\n'));
                warning('Please check the raw_data configuration.');
            end
        end
    end
    if(isequal(lower(channel_params.channel_type.id),'default'))
        channel = channel_params.channel_type;
        group_name = channel.group_layout_name;
        layout_name = channel.channel_layout_name;
        defaults = jsondecode(fileread(fullfile('bst_defaults','bst_eeg_layouts.json')));
        if(~contains(group_name, {defaults.name}))
            fprintf(2,strcat('\nBC-V-->> Error: The selected template group in process_import_channel.json is wrong \n'));
            disp(strcat("Name: ",group_name));
            disp(strcat("Please check the available channel templates in bst_template/bst_eeg_layouts.json file"));
            status = false;
            disp('-->> Process stopped!!!');
            return;
        else
            index = find(strcmp({defaults.name},group_name),1);
            layout_names = defaults(1).contents;
            if(~contains(layout_name, {layout_names.name}))
                fprintf(2,strcat('\nBC-V-->> Error: The selected template name in process_import_channel.json is wrong \n'));
                disp(strcat("Name: ",layout_name));
                disp(strcat("Please check the available channel templates in bst_template/bst_eeg_layouts.json file"));
                status = false;
                disp('-->> Process stopped!!!');
                return;
            end
        end
    end    
    
    %% Joinning rejected subjects
    for i=1:length(reject_anat)
        reject_subjects(end+1).SubID                = reject_anat{i};
        reject_subjects(end).Status                 = "Rejected";
        reject_subjects(end).FileInfo               = "";
        reject_subjects(end).Process(1).Name        = "Check_anat";
        reject_subjects(end).Process(1).Status      = "Rejected";
        reject_subjects(end).Process(1).Error       = 'The subject do not contain a correct anatomy folder';
    end
    for i=1:length(reject_nonbrain)
        idx = find(ismember({reject_subjects.Name},reject_nonbrain{i}),1);
        if(isempty(idx))
            reject_subjects(end+1).SubID            = reject_nonbrain{i};
            reject_subjects(end).Status             = "Rejected";
            reject_subjects(end).FileInfo           = "";
            reject_subjects(end).Process(2).Name    = "Check_nonbrain";
            reject_subjects(end).Process(2).Status  = "Rejected";
            reject_subjects(end).Process(2).Error   = 'The subject do not contain a correct non-brain structure';
        else            
            reject_subjects(idx).Process(2).Name    = reject_nonbrain{i};
            reject_subjects(idx).Process(2).Status  = "Rejected";
            reject_subjects(idx).Process(2).Error   = 'The subject do not contain a correct non-brain structure';
        end
    end
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
end