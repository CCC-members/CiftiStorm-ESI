function subj_error = headmodel_default_anat(properties)
% Description here
%
%
% Author:
% - Ariosky Areces Gonzalez
% - Deirel Paz Linares
%%

%%
%% Preparing protocol specifications
%%
subj_error              = [];
general_params          = properties.general_params;
anatomy_type            = properties.anatomy_params.anatomy_type.type_list{1};
bst_output_path         = general_params.bst_export.output_path;
subID                   = anatomy_type.template_name;
ProtocolName            = general_params.bst_config.protocol_name;
protocol_reset          = general_params.bst_config.protocol_reset; 
subjects_process_error  = [];
subjects_processed      = [];
%%
%% Getting report path
%%
[subject_report_path] = get_report_path(properties, subID);

%%
%% Genering Subject Template
%%
disp('-->> Creating anatomy template.');
if(protocol_reset)
    gui_brainstorm('DeleteProtocol',ProtocolName);
    bst_db_path = bst_get('BrainstormDbDir');
    if(isfolder(fullfile(bst_db_path,ProtocolName)))
        protocol_folder = fullfile(bst_db_path,ProtocolName);
        rmdir(protocol_folder, 's');
    end
    gui_brainstorm('CreateProtocol',ProtocolName , 0, 0);
else
    gui_brainstorm('UpdateProtocolsList');
    iProtocol = bst_get('Protocol', ProtocolName);
    if(isempty(iProtocol))
        gui_brainstorm('CreateProtocol',ProtocolName , 0, 0);
    else
        gui_brainstorm('SetCurrentProtocol', iProtocol);
        sSubjects = bst_get('ProtocolSubjects');
        if(~isempty(find(ismember({sSubjects.Subject.Name},subID), 1)))
            db_delete_subjects( find(ismember({sSubjects.Subject.Name},subID)) );
        end
    end
end
    
db_add_subject(subID);
[sSubject, iSubject] = bst_get('Subject', subID);

%%
%% Start a New Report
%%
bst_report('Start',['Protocol for subject:' , subID]);
bst_report('Info',    '', [], ['Protocol for subject:' , subID]);
    
%%
%% Process import anatomy
%%
[anat_error, CSurfaces, sub_to_FSAve] = process_import_anat(properties,'default',iSubject,subID);


%%
%% Process: Import Atlas
%%
disp("--------------------------------------------------------------------------");
disp("-->> Process Import Atlas");
disp("--------------------------------------------------------------------------");
atlas_error = process_import_atlas(properties, 'default', subID, CSurfaces);

%%
%% Process: Generate BEM surfaces
%%
disp("--------------------------------------------------------------------------");
disp("-->> Process Generate BEM surfaces");
disp("--------------------------------------------------------------------------");
[errMessage, CSurfaces]     = process_gen_bem_surfaces(properties, subID, CSurfaces);
sSubject                    = bst_get('Subject', subID);
iScalp                      = sSubject.iScalp;
iOuterSkull                 = sSubject.iOuterSkull;
iInnerSkull                 = sSubject.iInnerSkull;
iCortex                     = sSubject.iCortex;

%%
%% Process: Generate SPM canonical surfaces
%%
disp("--------------------------------------------------------------------------");
disp("Process Generate SPM canonical surfaces");
disp("--------------------------------------------------------------------------");
%         [isOk, errMsg] = process_mni_normalize('Compute', MriFile, 'segment');
sFiles = bst_process('CallProcess', 'process_generate_canonical', [], [], ...
    'subjectname', subID, ...
    'resolution',  2);  % 8196
if(isempty(sFiles))
    subj_error.spm_canonical = "Updated SPM caninonical pluging";
    return;
end

%%
%% Quality control
%%
% Get subject definition and subject files
sSubject    = bst_get('Subject', subID);
MriFile     = sSubject.Anatomy(sSubject.iAnatomy).FileName;
ScalpFile   = sSubject.Surface(sSubject.iScalp).FileName;

%
hFigMri15 = view_mri(MriFile, ScalpFile);
bst_report('Snapshot',hFigMri15,[],'SPM Scalp Envelope - MRI registration', [200,200,900,700]);
savefig( hFigMri15,fullfile(subject_report_path,'SPM Scalp Envelope - MRI registration.fig'));
% Close figures
close(hFigMri15);

%%
%% Process Import Channel
%%
disp("--------------------------------------------------------------------------");
disp("-->> Process Import Channel");
disp("--------------------------------------------------------------------------");
iSurfaces = {iScalp, iOuterSkull, iInnerSkull, iCortex};
[ChannelFile, channel_error] = process_import_chann(properties, 'default', subID, iSurfaces);

%%
%% Process: Compute Headmodel
%%
disp("--------------------------------------------------------------------------");
disp("-->> Process Compute HeadModel");
disp("--------------------------------------------------------------------------");
errMessage = process_comp_headmodel(properties, subID, CSurfaces);

%%
%% Export subject from protocol
%%
disp("--------------------------------------------------------------------------");
disp("-->> Export Subject from BST Protocol");
disp("--------------------------------------------------------------------------");
if(~isfolder(fullfile(bst_output_path,'Subjects',ProtocolName)))
    mkdir(fullfile(bst_output_path,'Subjects',ProtocolName));
end
iProtocol       = bst_get('iProtocol');
[~, iSubject]   = bst_get('Subject', subID);
export_protocol(iProtocol, iSubject, fullfile(bst_output_path,'Subjects',ProtocolName,strcat(subID,'.zip')));
    
%%
%% Save and display report
%%
disp("--------------------------------------------------------------------------");
disp("-->> Export BST Report");
disp("--------------------------------------------------------------------------");
[~, report_name]    = get_report_path(properties, subID);
ReportFile          = bst_report('Save', []);
bst_report('Export',  ReportFile, report_name);
%     bst_report('Open', ReportFile);
%     bst_report('Close');
disp(strcat("-->> Process finished for subject: ",subID));

%%
%% Export Subject to BC-VARETA
%%
disp("--------------------------------------------------------------------------");
disp("-->> Export to BC-VARETA Structure");
disp("--------------------------------------------------------------------------");
if(isempty(errMessage))
    disp(strcat('BC-V -->> Export template:' , subID, ' to BC-VARETA structure'));
    if(general_params.bcv_config.export)
        export_error = export_subject_BCV_structure(properties, subID, CSurfaces, sub_to_FSAve);
    end
end

%%
%% Genering Manual QC file (need to check)
%%
%      generate_MaQC_file();

disp(strcat('-->> Subject:' , subID, '. Processing finished.'));
disp('==========================================================================');

disp(strcat('-->> Process finished....'));
disp('=================================================================');
disp('=================================================================');
save report.mat subjects_processed subjects_process_error;

end

