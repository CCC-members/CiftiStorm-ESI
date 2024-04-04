function report_path = get_report_path(properties, subID)

%%
%% Checking the report output structure
%%
ProtocolName        = properties.general_params.bst_config.protocol_name;
output_path         = properties.general_params.output_path;
if(output_path == "local")
    output_path     = pwd;
end
report_path = fullfile(output_path,'brainstorm','Reports',subID);
if(~isfolder(report_path))
    mkdir(report_path);
end
end

