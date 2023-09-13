function create_report_path(properties, subID)

%%
%% Checking the report output structure
%%
ProtocolName        = properties.general_params.bst_config.protocol_name;
output_path         = properties.general_params.output_path;
if(output_path == "local")
    output_path     = pwd;
end
if(~isfolder(output_path))
    mkdir(output_path);
end
if(~isfolder(fullfile(output_path,'Reports')))
    mkdir(fullfile(output_path,'Reports'));
end
if(~isfolder(fullfile(output_path,'Reports',ProtocolName)))
    mkdir(fullfile(output_path,'Reports',ProtocolName));
end
if(isfolder(fullfile(output_path,'Reports',ProtocolName,subID)))
    rmdir(fullfile(output_path,'Reports',ProtocolName,subID),'s');
end
mkdir(fullfile(output_path,'Reports',ProtocolName,subID));
end

