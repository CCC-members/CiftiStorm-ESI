function report_path = get_report_path(CiftiStorm, subID)

%%
%% Checking the report output structure
%%
output_path         = CiftiStorm.Location;
if(output_path == "local")
    output_path     = pwd;
end
report_path = fullfile(output_path,'Reports',subID);
if(~isfolder(report_path))
    mkdir(report_path);
end
end

