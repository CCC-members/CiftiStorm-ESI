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
if(~isfolder(fullfile(output_path,'ciftistorm')))
    mkdir(fullfile(output_path,'ciftistorm'));
end
if(~isfolder(fullfile(output_path,'ciftistorm',subID)))
    mkdir(fullfile(output_path,'ciftistorm',subID));
end
if(~isfolder(fullfile(output_path,'brainstorm')))
    mkdir(fullfile(output_path,'brainstorm'));
end
if(~isfolder(fullfile(output_path,'brainstorm','Reports')))
    mkdir(fullfile(output_path,'brainstorm','Reports'));
end
end

