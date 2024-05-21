function [properties,status] = get_properties(varargin)

try
    app_properties = jsondecode(fileread(strcat('app/properties.json')));
catch ME
    fprintf(2,strcat('\nBC-V-->> Error: Loading the property files: \n'));
    fprintf(2,strcat(ME.message,'\n'));
    fprintf(2,strcat('Cause in file app\properties.json \n'));
    disp('Please verify the json format in the file.');
    properties = 'canceled';
    return;
end
defaults_param_files = app_properties.default_param_files;
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
process_files = app_properties.process_files;
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
if(~isempty(varargin))
    if(~isequal(lower(properties.anatomy_params.anatomy_type.type),'template') ...
            && ~isequal(lower(properties.anatomy_params.anatomy_type.type),'default') ...
            && ~isequal(lower(properties.anatomy_params.anatomy_type.type),'individual'))
        fprintf(2,"\n ->> Error: The anatomy type have to be <<template>>, or <<individual>>. \n");
        disp('template: For use default anatomy type.');
        disp('individual: For use HCP individual anatomy.');
        properties = 'canceled';
        disp('-->> Process stopped!!!');
        return;
    end
    if(isequal(lower(properties.anatomy_params.anatomy_type.type),'default'))
        properties.anatomy_params.anatomy_type = properties.anatomy_params.anatomy_type.type_list{1};
    elseif(isequal(lower(properties.anatomy_params.anatomy_type.type),'individual'))
        properties.anatomy_params.anatomy_type = properties.anatomy_params.anatomy_type.type_list{2};
    else
        properties.anatomy_params.anatomy_type = properties.anatomy_params.anatomy_type.type_list{3};
    end
    
    if(~isequal(lower(properties.channel_params.channel_type.type),'default') ...
            && ~isequal(lower(properties.channel_params.channel_type.type),'raw'))
        fprintf(2,"\n ->> Error: The channel type have to be <<raw>> or <<default>>. \n");
        disp('raw: Use raw data channel.');
        disp('default: Use BST default channel.');
        properties = 'canceled';
        disp('-->> Process stopped!!!');
        return;
    end
    if(isequal(lower(properties.channel_params.channel_type.type),'default'))
        properties.channel_params.channel_type = properties.channel_params.channel_type.type_list{2};
    else
        properties.channel_params.channel_type = properties.channel_params.channel_type.type_list{1};
    end

    if(~isequal(lower(properties.headmodel_params.Method.value),'meg_sphere') ...
            && ~isequal(lower(properties.headmodel_params.Method.value),'os_meg') ...
            && ~isequal(lower(properties.headmodel_params.Method.value),'eeg_3sphereberg') ...
            && ~isequal(lower(properties.headmodel_params.Method.value),'openmeeg') ...
            && ~isequal(lower(properties.headmodel_params.Method.value),'duneuro'))
        fprintf(2,"\n ->> Error: The channel type have to be <<meg_sphere>> or <<os_meg>>" + ...
            " or <<eeg_3sphereberg>> or <<openmeeg>> or <<duneuro>> . \n");
        disp('meg_sphere: Use MEG Spheres.');
        disp('os_meg: Use Overlapping spheres.');
        disp('eeg_3sphereberg: Use EEG three Spheres.');
        disp('openmeeg: Use OpenMEEG.');
        disp('duneuro: Use DUNeruro FEM.');
        properties = 'canceled';
        disp('-->> Process stopped!!!');
        return;
    end
    switch lower(properties.headmodel_params.Method.value)
        case 'meg_sphere'
            properties.headmodel_params.Method = properties.headmodel_params.Method.methods{1};
        case 'os_meg'
            properties.headmodel_params.Method = properties.headmodel_params.Method.methods{2};
        case 'eeg_3sphereberg'
            properties.headmodel_params.Method = properties.headmodel_params.Method.methods{3};
        case 'openmeeg'
            properties.headmodel_params.Method = properties.headmodel_params.Method.methods{4};
        case 'duneuro'
            properties.headmodel_params.Method = properties.headmodel_params.Method.methods{5};
    end
    properties = rmfield(properties,'defaults');
end

end

