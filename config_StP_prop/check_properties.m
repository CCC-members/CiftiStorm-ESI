function status = check_properties(properties)
%CHECK_PROPERTIES Summary of this function goes here
%   Detailed explanation goes here
status = true;
disp("-->> Checking properties");

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
if(isempty(general_params.protocol_name))
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
if(isempty(general_params.protocol_subjet_count) || general_params.protocol_subjet_count < 5)
    status = false;
    fprintf(2,'\n-->> Error: The protocol_subjet_count can not be empty or less than 5.\n');
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
if(~isequal(general_params.bst_database.db_path,'local')...
        && ~isempty(general_params.bst_database.db_path)...
        && ~isfolder(general_params.bst_database.db_path))
    fprintf(2,strcat("\n ->> Error: The Brainstorm database path is wrong. \n"));
    disp(general_params.bst_database.db_path);
    disp("______________________________________________________________________________________________");
    disp("Please configure app_properties.bst_db_path element in app/properties file. ")
    status = false;
    return;
end
if(isfolder(general_params.bst_database.db_path))
    [~,values] = fileattrib(general_params.bst_database.db_path);
    if(~values.UserWrite) 
        fprintf(2,strcat("The current user do not have write permissions on the selected forder for Brainstorm database path."));
        disp(general_params.bst_database.db_path)
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
% Anatomy type configuration
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
        disp('Please selcct a correct HCP Template folder or check the Template name filed.');
        status = false;
        disp('-->> Process stoped!!!');
        return;
    end
    T1w_file = fullfile(base_path,template_name,selected_anatomy.file_location);
    if(~isfile(T1w_file))
        fprintf(2,'The Template folder is not a HCP structure.\n');
        fprintf(2,'We can not find the T1w file in this address:\n');
        fprintf(2,strcat(T1w_file,'\n'));
        disp('Please check the HCP Template folder.');
        status = false;
        disp('-->> Process stoped!!!');
        return;
    end
    L_surf = fullfile(base_path,template_name,strrep(selected_anatomy.L_surface_location,'SubID',template_name));    
    if(~isfile(L_surf))
        fprintf(2,'The Template folder is not a HCP structure.\n');
        fprintf(2,'We can not find the Left surf file in this address:\n');
        fprintf(2,strcat(L_surf,'\n'));
        disp('Please check the HCP Template folder.');
        status = false;
        disp('-->> Process stoped!!!');
        return;
    end
    R_surf = fullfile(base_path,template_name,strrep(selected_anatomy.R_surface_location,'SubID',template_name)); 
    if(~isfile(R_surf))
        fprintf(2,'The Template folder is not a HCP structure.\n');
        fprintf(2,'We can not find the Rigth surf file in this address:\n');
        fprintf(2,strcat(R_surf,'\n'));
        disp('Please check the HCP Template folder.');
        status = false;
        disp('-->> Process stoped!!!');
        return;
    end
    atlas_file = fullfile(base_path,template_name,strrep(selected_anatomy.Atlas_seg_location,'SubID',template_name)); 
    if(~isfile(atlas_file))
        fprintf(2,'The Template folder is not a HCP structure.\n');
        fprintf(2,'We can not find the Atlas file in this address:\n');
        fprintf(2,strcat(atlas_file,'\n'));
        disp('Please check the HCP Template folder.');
        status = false;
        disp('-->> Process stoped!!!');
        return;
    end
    % Check non brain surfaces configuration
     non_brain = anat_params.non_brain_surfaces;
     base_path = strrep(non_brain.base_path,'SubID','');
     base_path = strrep(base_path,template_name,'');
     if(~isfolder(fullfile(base_path)))
         fprintf(2,'The Non-brain surfaces base_path is not a folder.\n');
         disp('Please select a Non-brain surfaces folder in the process_import_anat.json configuration file.');
         status = false;
         disp('-->> Process stoped!!!');
         return;
     end     
     skin_file = fullfile(base_path,template_name,strrep(non_brain.head_file_location,'SubID',template_name));
     if(~isfile(skin_file))
         fprintf(2,'We can not find the Head file in this address:\n');
         warning(skin_file);
         fprintf(2,'Please check the skin configuration.');
     end
     outer_file = fullfile(base_path,template_name,strrep(non_brain.outerfile_file_location,'SubID',template_name));
     if(~isfile(outer_file))
         fprintf(2,'We can not find the Head file in this address:\n');
         warning(outer_file);
         fprintf(2,'Please check the outerskull configuration.');
     end
     inner_file = fullfile(base_path,template_name,strrep(non_brain.innerfile_file_location,'SubID',template_name));
     if(~isfile(inner_file))
         fprintf(2,'We can not find the innerskull file in this address:\n');
         warning(inner_file);
         fprintf(2,'Please check the innerskull configuration.');
     end        
end
% Check HCP individual configuration
if(isequal(anat_params.anatomy_type.type,3))
    selected_anatomy = anat_params.anatomy_type.type_list{3};
    base_path = strrep(selected_anatomy.base_path,'SubID','');
    if(~isfolder(fullfile(base_path)))
        fprintf(2,'The HCP indivudial base_path is not a folder.\n');
        disp('Please select a correct HCP Template folder in the process_import_anat.json configuration file.');
        status = false;
        disp('-->> Process stoped!!!');
        return;
    end
    structures = dir(base_path);
    structures(ismember( {structures.name}, {'.', '..'})) = [];  %remove . and ..
    count_T1w = 0;
    count_L_surf = 0;
    count_R_surf = 0;
    count_Atlas = 0;
    for i=1:length(structures)
        structure = structures(i);          
        T1w_file = fullfile(base_path,structure.name,selected_anatomy.file_location);
        if(~isfile(T1w_file)); count_T1w = count_T1w + 1; end
        L_surf = fullfile(base_path,structure.name,strrep(selected_anatomy.L_surface_location,'SubID',structure.name));
        if(~isfile(L_surf)); count_L_surf = count_L_surf + 1; end
        R_surf = fullfile(base_path,structure.name,strrep(selected_anatomy.R_surface_location,'SubID',structure.name));
        if(~isfile(R_surf)); count_R_surf = count_R_surf + 1; end
        atlas_file = fullfile(base_path,structure.name,strrep(selected_anatomy.Atlas_seg_location,'SubID',structure.name));
        if(~isfile(atlas_file)); count_Atlas = count_Atlas + 1; end
    end
     if(~isequal(count_T1w,0))
         if(isequal(count_T1w,length(structures)))
             fprintf(2,'Any folder in the Anatomy base path have a HCP structure.\n');
             fprintf(2,'We can not find the T1w file in this address:\n');
             fprintf(2,strcat(T1w_file,'\n'));
             disp('Please check the HCP individual folder.');
             status = false;
             disp('-->> Process stoped!!!');
             return;
         else
             warning('The Template folder is not a HCP structure.\n');
             warning('We can not find the T1w file in this address:\n');
             warning(strcat(selected_anatomy.file_location,'\n'));
             warning('Please check the HCP individual folder.');
         end
     end
     if(~isequal(count_L_surf,0))
         if(isequal(count_L_surf,length(structures)))
             fprintf(2,'Any folder in the Anatomy base path have a HCP structure.\n');
             fprintf(2,'We can not find the Left surf file in this address:\n');
             fprintf(2,strcat(selected_anatomy.L_surface_location,'\n'));
             disp('Please check the Left surface config.');
             status = false;
             disp('-->> Process stoped!!!');
             return;
         else
             warning('The Template folder is not a HCP structure.\n');
             warning('We can not find the Left surf file in this address:\n');
             warning(strcat(selected_anatomy.L_surface_location,'\n'));
             warning('Please check the Left surface config.');
         end
     end
     if(~isequal(count_R_surf,0))
         if(isequal(count_R_surf,length(structures)))
             fprintf(2,'Any folder in the Anatomy base path have a HCP structure.\n');
             fprintf(2,'We can not find the Rigth surf file in this address:\n');
             fprintf(2,strcat(selected_anatomy.R_surface_location,'\n'));
             disp('Please check the R surface config.');
             status = false;
             disp('-->> Process stoped!!!');
             return;
         else
             warning('The Template folder is not a HCP structure.\n');
             warning('We can not find the Rigth surf file in this address:\n');
             warning(strcat(selected_anatomy.R_surface_location,'\n'));
             warning('Please check the R surface config.');
         end
     end
     if(~isequal(count_Atlas,0))
         if(isequal(count_Atlas,length(structures)))
             fprintf(2,'Any folder in the Anatomy base path have a HCP structure.\n');
             fprintf(2,'We can not find the Atlas file in this address:\n');
             fprintf(2,strcat(selected_anatomy.Atlas_seg_location,'\n'));
             disp('Please check the atlas file config.');
             status = false;
             disp('-->> Process stoped!!!');
             return;
         else
             warning('The Template folder is not a HCP structure.\n');
             warning('We can not find the Atlas file in this address:\n');
             warning(strcat(selected_anatomy.Atlas_seg_location,'\n'));
             warning('Please check the atlas file config.');
         end
     end
     % Check non brain surfaces configuration
     non_brain = anat_params.non_brain_surfaces;
     base_path = strrep(non_brain.base_path,'SubID','');
     if(~isfolder(fullfile(base_path)))
         fprintf(2,'The Non-brain surfaces base_path is not a folder.\n');
         disp('Please select a Non-brain surfaces folder in the process_import_anat.json configuration file.');
         status = false;
         disp('-->> Process stoped!!!');
         return;
     end
     structures = dir(base_path);
     structures(ismember( {structures.name}, {'.', '..'})) = [];  %remove . and ..
     count_skin = 0;
     count_outer = 0;
     count_inner = 0;
     for i=1:length(structures)
         structure = structures(i);
         skin_file = fullfile(base_path,structure.name,strrep(non_brain.head_file_location,'SubID',structure.name));
         if(~isfile(skin_file)); count_skin = count_skin + 1; end
         outer_file = fullfile(base_path,structure.name,strrep(non_brain.outerfile_file_location,'SubID',structure.name));
         if(~isfile(outer_file)); count_outer = count_outer + 1; end
         inner_file = fullfile(base_path,structure.name,strrep(non_brain.innerfile_file_location,'SubID',structure.name));
         if(~isfile(inner_file)); count_inner = count_inner + 1; end
     end
     % Check the skin surface configuration
     if(~isequal(count_skin,0))
         if(isequal(count_skin,length(structures)))
             fprintf(2,'Any folder in the Non-brain surfaces path have a specific file location.\n');
             fprintf(2,'We can not find the skin file in this address:\n');
             fprintf(2,strcat(non_brain.head_file_location,'\n'));
             disp('Please check the skin configuration.');
             status = false;
             disp('-->> Process stoped!!!');
             return;
         else
             warning('One or more of the Non-brain surfaces file is not correct.\n');
             warning('We can not find at least one of the Head file in this address:\n');
             warning(strcat(non_brain.head_file_location,'\n'));
             warning('Please check the skin configuration.');
         end
     end
     % Check the outerskull surface configuration
     if(~isequal(count_outer,0))
         if(isequal(count_outer,length(structures)))
             fprintf(2,'Any folder in the Non-brain surfaces path have a specific file location.\n');
             fprintf(2,'We can not find the outerskull file in this address:\n');
             fprintf(2,strcat(non_brain.outerfile_file_location,'\n'));
             disp('Please check the outerskull configuration.');
             status = false;
             disp('-->> Process stoped!!!');
             return;
         else
             warning('One or more of the Non-brain surfaces file is not correct.\n');
             warning('We can not find at least one of the Head file in this address:\n');
             warning(strcat(non_brain.outerfile_file_location,'\n'));
             warning('Please check the outerskull configuration.');
         end
     end
     % Check the outerskull surface configuration
     if(~isequal(count_inner,0))
         if(isequal(count_inner,length(structures)))
             fprintf(2,'Any folder in the Non-brain surfaces path have a specific file location.\n');
             fprintf(2,'We can not find the innerskull file in this address:\n');
             fprintf(2,strcat(non_brain.innerfile_file_location,'\n'));
             disp('Please check the innerskull configuration.');
             status = false;
             disp('-->> Process stoped!!!');
             return;
         else
             warning('One or more of the Non-brain surfaces file is not correct.\n');
             warning('We can not find at least one of the innerskull file in this address:\n');
             warning(strcat(non_brain.innerfile_file_location,'\n'));
             warning('Please check the innerskull configuration.');
         end
     end
end
% Chacek MRI transform configuration
mri_transform = anat_params.mri_transformation;
if(mri_transform.use_transformation)
    base_path = strrep(mri_transform.base_path,'SubID','');
    if(~isfolder(fullfile(base_path)))
        fprintf(2,'The MRI transformation base_path is not a folder.\n');
        disp('Please select a correct MRI transformation folder in the process_import_anat.json configuration file.');
        status = false;
        disp('-->> Process stoped!!!');
        return;
    end
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

% Check surface resolution
surf_resol = anat_params.surfaces_resolution;
if(isempty(surf_resol.nverthead) || surf_resol.nverthead < 5000 || surf_resol.nverthead > 15000)
    fprintf(2,'The Head resolution have be between 5000 and 15000 vertices.\n');
    disp('Please check the nverthead configuration in the process_import_anat.json file.');
    status = false;
    disp('-->> Process stoped!!!');
    return;
end
if(isempty(surf_resol.nvertskull) || surf_resol.nvertskull < 5000 || surf_resol.nvertskull > 15000)
    fprintf(2,'The Skull resolution have be between 5000 and 15000 vertices.\n');
    disp('Please check the nvertskull configuration in the process_import_anat.json file.');
    status = false;
    disp('-->> Process stoped!!!');
    return;
end
if(isempty(surf_resol.nvertcortex) || surf_resol.nvertcortex < 5000 || surf_resol.nvertcortex > 15000)
    fprintf(2,'The Cortex resolution have be between 5000 and 15000 vertices.\n');
    disp('Please check the nvertcortex configuration in the process_import_anat.json file.');
    status = false;
    disp('-->> Process stoped!!!');
    return;
end

%%
%% Checking import channel params
%%
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
%% Checking preprocessed data params
%%
disp('-->> Checking preprocessed data params');
prep_params = properties.prep_data_params.params;
if(isequal(prep_params.process_type.type,1))
    
elseif(isequal(prep_params.process_type.type,2))
    prep_config = prep_params.process_type.type_list{2};
    base_path = strrep(prep_config.base_path,'SubID','');
    if(~isfolder(fullfile(base_path)))
        fprintf(2,'The prerpocessed_data base path is not a folder.\n');
        disp('Please type a correct prerpocessed_data folder in the process_prep_data.json configuration file.');
        status = false;
        disp('-->> Process stoped!!!');
        return;
    end
    if(isempty(prep_config.format))
        fprintf(2,'The preprocessed data format can not be empty.\n');
        disp('Please type a correct preprocessed data format in the process_prep_data.json configuration file.');
        status = false;
        disp('-->> Process stoped!!!');
        return;
    end
    [path,name,ext] = fileparts(prep_config.file_location);
    if(~isequal(strcat('.',prep_config.format),ext))
         fprintf(2,'The preprocessed data format and the file location extension do not match.\n');
        disp('Please check the process_prep_data.json configuration file.');
        status = false;
        disp('-->> Process stoped!!!');
        return;
    end
    structures = dir(base_path);
    structures(ismember( {structures.name}, {'.', '..'})) = [];  %remove . and ..
    count_data = 0;
    for i=1:length(structures)
        structure = structures(i);
        data_file = fullfile(base_path,structure.name,strrep(prep_config.file_location,'SubID',structure.name));
        if(~isfile(data_file)); count_data = count_data + 1; end        
    end
    if(~isequal(count_data,0))
        if(isequal(count_data,length(structures)))
            fprintf(2,'Any folder in the Prep_data path have a specific file location.\n');
            fprintf(2,'We can not find the Prep_data file in this address:\n');
            fprintf(2,strcat(prep_config.file_location,'\n'));
            disp('Please check the Prep_data configuration.');
            status = false;
            disp('-->> Process stoped!!!');
            return;
        else
            warning('One or more of the Prep_data file are not correct.');
            warning('We can not find at least one of the Prep_data file in this address:');
            warning(strcat(prep_config.file_location));
            warning('Please check the Prep_data configuration.');
        end
    end      
end
if(isequal(prep_params.process_type.type,1) || isequal(prep_params.process_type.type,2))
   % Checking clean data params
    clean_data = prep_params.clean_data;   
    if(clean_data.run)
        if(isempty(clean_data.toolbox))
            fprintf(2,'The clean data toolbox can not be empty.\n');
            disp('Please type a correct clean data toolbox in the process_prep_data.json configuration file.');
            status = false;
            disp('-->> Process stoped!!!');
            return;
        end
        if(isequal(clean_data.toolbox,'eeglab'))
            if(isempty(clean_data.toolbox_path) || ~isfile(fullfile(clean_data.toolbox_path,'eeglab.m')))
                fprintf(2,'The clean data toolbox path is wrong.\n');
                disp('Please type a correct clean data toolbox path in the process_prep_data.json configuration file.');
                status = false;
                disp('-->> Process stoped!!!');
                return;
            end
        end
        if(isempty(clean_data.max_freq) || clean_data.max_freq < 20 || clean_data.max_freq > 90)
            fprintf(2,'The Clean_data max_frequency have be between 20 and 90 vertices.\n');
            disp('Please check the Clean_data max_frequency configuration in the process_prep_data.json file.');
            status = false;
            disp('-->> Process stoped!!!');
            return;
        end
        select_events = clean_data.select_events;
        if(~isempty(select_events.by) && ~isequal(select_events.by,'segments') && ~isequal(select_events.by,'marks'))
            fprintf(2,"\n ->> Error: The select_events type have to be <<empty>>, <<segments>>, or <<marks>>. \n");
            disp('empty: For use all data and do not extract events.');
            disp('segments: Get the data events from the good segments.');
            disp('marks: Get the data events from all segments.');
            status = false;
            disp('-->> Process stoped!!!');
            return;
        end
    end 
end
disp('-->> All preoperties checked.');


end

                                                                                                                                                            