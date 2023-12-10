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
if(~isfolder(fullfile(output_path,'CiftiStorm',ProtocolName)))
    mkdir(fullfile(output_path,'CiftiStorm',ProtocolName));
end
if(~isfolder(fullfile(output_path,'CiftiStorm',ProtocolName,subID)))
    mkdir(fullfile(output_path,'CiftiStorm',ProtocolName,subID));
end
if(~isfolder(fullfile(output_path,'BST',ProtocolName,'Subjects')))
    mkdir(fullfile(output_path,'BST',ProtocolName,'Subjects'));
end
if(~isfolder(fullfile(output_path,'BST',ProtocolName,'Reports')))
    mkdir(fullfile(output_path,'BST',ProtocolName,'Reports'));
end
end

