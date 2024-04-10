function CiftiStorm = process_export_subject(CiftiStorm, properties, subID)

errMessage      = [];
if(isequal(properties.anatomy_params.anatomy_type.id,'individual'))
    output_path     = fullfile(properties.general_params.output_path,'brainstorm');
else
    template_name = properties.anatomy_params.anatomy_type.template_name;
    output_path = fullfile(properties.general_params.output_path,strcat('brainstorm-',template_name));
end


%%
%% Export subject from protocol
%%
disp("-->> Export Subject from BST Protocol");
if(~isfolder(fullfile(output_path)))
    mkdir(fullfile(output_path));
end
iProtocol       = bst_get('iProtocol');
[~, iSubject]   = bst_get('Subject', subID);
subject_file    = fullfile(output_path,strcat(subID,'.zip'));
export_protocol(iProtocol, iSubject, subject_file);

%%
%% Save and display report
%%
if(getGlobalVerbose())
    disp("-->> Export BST Report");
    report_path     = get_report_path(properties, subID);
    ReportFile      = bst_report('Save', []);
    bst_report('Export',  ReportFile, fullfile(report_path,[subID,'.html'])); 
end

if(isempty(errMessage))
    CiftiStorm.Participants(end).Status                 = "Processing";
    CiftiStorm.Participants(end).FileInfo               = strcat(subID,".mat");
    CiftiStorm.Participants(end).Process(end+1).Name    = "Export";
    CiftiStorm.Participants(end).Process(end).Status    = "Completed";
    CiftiStorm.Participants(end).Process(end).Error     = errMessage;
else
    CiftiStorm.Participants(end).Status                 = "Rejected";
    CiftiStorm.Participants(end).FileInfo               = "";
    CiftiStorm.Participants(end).Process(end+1).Name    = "Export";
    CiftiStorm.Participants(end).Process(end).Status    = "Rejected";
    CiftiStorm.Participants(end).Process(end).Error     = errMessage;
end
end

