function valided = check_app_properties(app_properties)

valided = true;

if(~isfolder(app_properties.bst_path) || ~isfile(fullfile(app_properties.bst_path,'brainstorm.m')))
    fprintf(2,"\n ->> Error: The selected Brainstorm path is wrong. \n");
    disp(app_properties.bst_path);
    disp('-->> Process stoped!!!');
    valided = false;
    return;
end
if(~isfolder(app_properties.spm_path) || ~isfile(fullfile(app_properties.spm_path,'spm.m')))
    fprintf(2,"\n ->> Error: The selected SPM path is wrong. \n");
    disp(app_properties.bst_path);
    disp('-->> Process stoped!!!');
    valided = false;
    return;
end
if(~isfile(fullfile("config_protocols",app_properties.selected_data_set.file_name)))
    fprintf(2,strcat("\n ->> Error: The file ",app_properties.selected_data_set.file_name," do not exit \n"));
    disp(app_properties.selected_data_set.file_name);
    disp("______________________________________________________________________________________________");
    disp("Please configure app_properties.selected_data_set.file_name element in app/properties file. ")
    valided = false;
    return;
end

if(~isequal( app_properties.bst_db_path,'local') && ~isempty(app_properties.bst_db_path,'local') && ~isfolder(app_properties.bst_db_path))
    fprintf(2,strcat("\n ->> Error: The Brainstorm database path is wrong. \n"));
    disp(app_properties.bst_db_path);
    disp("______________________________________________________________________________________________");
    disp("Please configure app_properties.bst_db_path element in app/properties file. ")
    valided = false;
    return;
end
if(isfolder(app_properties.bst_db_path))
    [~,values] = fileattrib(app_properties.bst_db_path);
    if(~values.UserWrite) 
        fprintf(2,strcat("The current user do not have write permissions on the selected forder for Brainstorm database path."));
        disp(app_properties.bst_db_path)
       disp(' Please check the folder permission or select another output folder.');
       valided = false;
       return;
    end
end
end

