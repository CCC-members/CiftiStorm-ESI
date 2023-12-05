function CiftiStorm = process_export_subject(CiftiStorm, properties, subID, CSurfaces, sub_to_FSAve)

errMessage      = [];
ProtocolName    = general_params.bst_config.protocol_name;
output_path     = general_params.output_path;

%%
%% Export subject from protocol
%%
disp("--------------------------------------------------------------------------");
disp("-->> Export Subject from BST Protocol");
disp("--------------------------------------------------------------------------");
if(~isfolder(fullfile(output_path,'BST','Subjects',ProtocolName)))
    mkdir(fullfile(output_path,'BST','Subjects',ProtocolName));
end
iProtocol       = bst_get('iProtocol');
[~, iSubject]   = bst_get('Subject', subID);
subject_file    = fullfile(output_path,'BST','Subjects',ProtocolName,strcat(subID,'.zip'));
export_protocol(iProtocol, iSubject, subject_file);

%%
%% Save and display report
%%
disp("--------------------------------------------------------------------------");
disp("-->> Export BST Report");
disp("--------------------------------------------------------------------------");
report_path     = get_report_path(properties, subID);
ReportFile      = bst_report('Save', []);
bst_report('Export',  ReportFile, fullfile(report_path,[subID,'.html']));
disp(strcat("-->> Process finished for subject: ",subID));

%%
%% Export Subject
%%
disp("--------------------------------------------------------------------------");
disp("-->> Export to CiftiStorm");
disp("--------------------------------------------------------------------------");

disp(strcat('cfs -->> Export subject:' , subID));
errMessage = export_subject_structure(properties, subID, CSurfaces, sub_to_FSAve);

if(isempty(errMessage))
    CiftiStorm.Participants(end).Status             = "Completed";
    CiftiStorm.Participants(end).FileInfo           = "subject.mat";
    CiftiStorm.Participants(end).Process(9).Name    = "Export";
    CiftiStorm.Participants(end).Process(9).Status  = "Completed";
    CiftiStorm.Participants(end).Process(9).Error   = errMessage;
else
    CiftiStorm.Participants(end).Status             = "Rejected";
    CiftiStorm.Participants(end).FileInfo           = "";
    CiftiStorm.Participants(end).Process(9).Name    = "Export";
    CiftiStorm.Participants(end).Process(9).Status  = "Rejected";
    CiftiStorm.Participants(end).Process(9).Error   = errMessage;
end
end

