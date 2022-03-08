function [properties] = get_properties()
try
%     pred_options = jsondecode(fileread(strcat('bcv_predefinition/pred_properties.json')));
%     if(~isequal(pred_options.params.predefinition.option,'default'))
%         properties = jsondecode(fileread(strcat('bcv_predefinition/',pred_options.params.predefinition.option,'/properties.json')));
%     else
        properties = jsondecode(fileread(strcat('app/properties.json')));
%     end
catch ME
    fprintf(2,strcat('\nBC-V-->> Error: Loading the property files: \n'));
    fprintf(2,strcat(ME.message,'\n'));
    fprintf(2,strcat('Cause in file app\properties.json \n'));
    disp('Please verify the json format in the file.');
    properties = 'canceled';
    return;
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
anat_type = properties.anatomy_params.params.anatomy_type.type;
properties.anatomy_params.params.anat_config = properties.anatomy_params.params.anatomy_type.type_list{anat_type};

channel_type = properties.channel_params.params.channel_type.type;
properties.channel_params.params.chann_config = properties.channel_params.params.channel_type.type_list{channel_type};

prep_data_type = properties.prep_data_params.params.process_type.type;
properties.prep_data_params.params.prep_data_config = properties.prep_data_params.params.process_type.type_list{prep_data_type};
end

