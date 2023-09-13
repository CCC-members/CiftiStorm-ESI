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

end

