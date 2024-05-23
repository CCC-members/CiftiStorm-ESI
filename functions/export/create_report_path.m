function create_report_path(CiftiStorm, subID)

%%
%% Checking the report output structure
%%
output_path         = CiftiStorm.Location;
if(output_path == "local")
    output_path     = pwd;
end
if(~isfolder(output_path))
    mkdir(output_path);
end
if(~isfolder(fullfile(output_path,'Reports')))
    mkdir(fullfile(output_path,'Reports'));
end
if(~isfolder(fullfile(output_path,'Reports',subID)))
    mkdir(fullfile(output_path,'Reports',subID));
end
end

