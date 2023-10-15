function [properties] = get_properties()
try
    properties = jsondecode(fileread(strcat('app/properties.json')));
catch ME
    fprintf(2,strcat('\nBC-V-->> Error: Loading the property files: \n'));
    fprintf(2,strcat(ME.message,'\n'));
    fprintf(2,strcat('Cause in file app\properties.json \n'));
    disp('Please verify the json format in the file.');
    properties = 'canceled';
    return;
end
defaults_param_files = properties.default_param_files;
for i=1:length(defaults_param_files)
    try        
        module_params                                               = jsondecode(fileread(defaults_param_files(i).file_path));
        properties.defaults.(defaults_param_files(i).module_id)     = module_params;        
    catch ME
        fprintf(2,strcat('\nBC-V-->> Error: Loading the property files: \n'));
        fprintf(2,strcat(ME.message,'\n'));
        fprintf(2,strcat('Cause in file', defaults_param_files(i).file_path , '\n'));
        disp('Please verify the json format in the file.');
        properties = 'canceled';
        return;
    end
end
process_files = properties.process_files;
for i=1:length(process_files)
    try        
        module_params                            = jsondecode(fileread(process_files(i).file_path));
        properties.(process_files(i).module_id)  = module_params;        
    catch ME
        fprintf(2,strcat('\nBC-V-->> Error: Loading the property files: \n'));
        fprintf(2,strcat(ME.message,'\n'));
        fprintf(2,strcat('Cause in file', process_files(i).file_path , '\n'));
        disp('Please verify the json format in the file.');
        properties = 'canceled';
        return;
    end
end
anat_type = properties.anatomy_params.anatomy_type.type;
properties.anatomy_params.anat_config = properties.anatomy_params.anatomy_type.type_list{anat_type};
channel_type = properties.channel_params.channel_type.type;
properties.channel_params.chann_config = properties.channel_params.channel_type.type_list{channel_type};

end

