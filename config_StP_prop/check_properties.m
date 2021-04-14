function status = check_properties(properties)
%CHECK_PROPERTIES Summary of this function goes here
%   Detailed explanation goes here
status = true;
disp("-->> Checking properties");

%%
%% Checking general params
%%
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
             disp('Please check the HCP Template folder.');
             status = false;
             disp('-->> Process stoped!!!');
             return;
         else
             warning('The Template folder is not a HCP structure.\n');
             warning('We can not find the T1w file in this address:\n');
             warning(strcat(selected_anatomy.file_location,'\n'));
             warning('Please check the HCP Template folder.');
         end
     end
     if(~isequal(count_L_surf,0))
         if(isequal(count_L_surf,length(structures)))
             fprintf(2,'Any folder in the Anatomy base path have a HCP structure.\n');
             fprintf(2,'We can not find the Left surf file in this address:\n');
             fprintf(2,strcat(selected_anatomy.L_surface_location,'\n'));
             disp('Please check the HCP Template folder.');
             status = false;
             disp('-->> Process stoped!!!');
             return;
         else
             warning('The Template folder is not a HCP structure.\n');
             warning('We can not find the Left surf file in this address:\n');
             warning(strcat(selected_anatomy.L_surface_location,'\n'));
             warning('Please check the HCP Template folder.');
         end
     end
     if(~isequal(count_R_surf,0))
         if(isequal(count_R_surf,length(structures)))
             fprintf(2,'Any folder in the Anatomy base path have a HCP structure.\n');
             fprintf(2,'We can not find the Rigth surf file in this address:\n');
             fprintf(2,strcat(selected_anatomy.R_surface_location,'\n'));
             disp('Please check the HCP Template folder.');
             status = false;
             disp('-->> Process stoped!!!');
             return;
         else
             warning('The Template folder is not a HCP structure.\n');
             warning('We can not find the Rigth surf file in this address:\n');
             warning(strcat(selected_anatomy.R_surface_location,'\n'));
             warning('Please check the HCP Template folder.');
         end
     end
     if(~isequal(count_Atlas,0))
         if(isequal(count_Atlas,length(structures)))
             fprintf(2,'Any folder in the Anatomy base path have a HCP structure.\n');
             fprintf(2,'We can not find the Atlas file in this address:\n');
             fprintf(2,strcat(selected_anatomy.Atlas_seg_location,'\n'));
             disp('Please check the HCP Template folder.');
             status = false;
             disp('-->> Process stoped!!!');
             return;
         else
             warning('The Template folder is not a HCP structure.\n');
             warning('We can not find the Atlas file in this address:\n');
             warning(strcat(selected_anatomy.Atlas_seg_location,'\n'));
             warning('Please check the HCP Template folder.');
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
        if(~isfile(transf_file))
            count_transf = count_transf + 1;
        end
    end
    if(~isequal(count_transf,0))
        if(isequal(count_transf,length(structures)))
            fprintf(2,'Any folder in the MRI Transformation base path have a specific file location.\n');
            fprintf(2,'We can not find the MRI file transformation in this address:\n');
            fprintf(2,strcat(mri_transform.file_location,'\n'));
            disp('Please check the HCP Template folder.');
            status = false;
            disp('-->> Process stoped!!!');
            return;
        else
            warning('One or more of the MRI transformation folder is not correct.\n');
            warning('We can not find at least one of the MRI transformation file in this address:\n');
            warning(strcat(mri_transform.file_location,'\n'));
            warning('Please check the HCP Template folder.');
        end
    end    
end
% Check non brain surfaces configuration
non_brain = anat_params.non_brain_surfaces;

%%
%% Checking channel params
%%



end

                                                                                                                                                            