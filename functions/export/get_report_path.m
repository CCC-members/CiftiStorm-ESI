function report_path = get_report_path(properties, subID)

%%
%% Checking the report output structure
%%
ProtocolName        = properties.general_params.bst_config.protocol_name;
output_path         = properties.general_params.bst_export.output_path;
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
if(~isfolder(fullfile(output_path,'Reports',ProtocolName,subID)))
    mkdir(fullfile(output_path,'Reports',ProtocolName,subID));
end
report_path = fullfile(output_path,'Reports',ProtocolName,subID);
end

