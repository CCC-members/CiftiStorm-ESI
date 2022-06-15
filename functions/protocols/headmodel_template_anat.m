function subj_error = headmodel_template_anat(properties)
% Description here
%
%
%
% Author:
% - Ariosky Areces Gonzalez
% - Deirel Paz Linares
%%

%%
%% Preparing protocol specifications
%%
subj_error = [];
modality                = properties.general_params.modality;
anatomy_type            = properties.anatomy_params.anatomy_type.type_list{2};
subID                   = anatomy_type.template_name;
ProtocolName            = properties.general_params.bst_config.protocol_name;
ProtocolName_R          = strcat(ProtocolName,'_Template');
subjects_process_error  = [];
subjects_processed      = [];
report_output_path      = properties.general_params.reports.output_path;
protocol_reset          = properties.general_params.bst_config.protocol_reset;

%%
%% Getting report path
%%
[subject_report_path] = get_report_path(properties, subID);

%%
%% Genering Subject Template
%%
disp('-->> Creating anatomy template.')
if(protocol_reset)
    gui_brainstorm('DeleteProtocol',ProtocolName_R);
    bst_db_path = bst_get('BrainstormDbDir');
    if(isfolder(fullfile(bst_db_path,ProtocolName_R)))
        protocol_folder = fullfile(bst_db_path,ProtocolName_R);
        rmdir(protocol_folder, 's');
    end
    gui_brainstorm('CreateProtocol',ProtocolName_R ,0, 0);
else
    %                 gui_brainstorm('UpdateProtocolsList');
    iProtocol = bst_get('Protocol', ProtocolName_R);
    gui_brainstorm('SetCurrentProtocol', iProtocol);
    subjects = bst_get('ProtocolSubjects');
end
db_add_subject(subID);
[sSubject, iSubject] = bst_get('Subject', subID);

%%
%% Start a New Report
%%
bst_report('Start',['Protocol for subject:' , subID]);
bst_report('Info',    '', [], ['Protocol for subject:' , subID]);

%%
%% Process Import Anatomy
%%
anat_error = process_import_anat(properties, 'template', iSubject, subID);

%%
%% Process: Generate BEM surfaces
%%
[errMessage]    = process_gen_bem_surfaces(properties, subID);
sSubject        = bst_get('Subject', subID);
iScalp          = sSubject.iScalp;
iOuterSkull     = sSubject.iOuterSkull;
iInnerSkull     = sSubject.iInnerSkull;
iCortex         = sSubject.iCortex;

%%
%% Process: Generate SPM canonical surfaces
%%
sFiles = bst_process('CallProcess', 'process_generate_canonical', sFiles, [], ...
    'subjectname', subID, ...
    'resolution',  2);  % 8196

%%
%% Quality control
%%
% Get subject definition and subject files
sSubject    = bst_get('Subject', subID);
MriFile     = sSubject.Anatomy(sSubject.iAnatomy).FileName;
ScalpFile   = sSubject.Surface(sSubject.iScalp).FileName;

%
hFigMri15 = view_mri(MriFile, ScalpFile);
bst_report('Snapshot',hFigMri15,[],'SPM Scalp Envelope - MRI registration', [200,200,750,475]);
savefig( hFigMri15,fullfile(subject_report_path,'SPM Scalp Envelope - MRI registration.fig'));
% Close figures
close(hFigMri15);

%%
%% ===== IMPORT CHANNEL =====
%%
iSurfaces = {iScalp, iOuterSkull, iInnerSkull, iCortex};
if(isequal(properties.channel_params.channel_type.type,3))
    channel_type = 'template';
elseif(isequal(properties.channel_params.channel_type.type,1))
    channel_type = 'individual';    
else
    channel_type = 'default';
end
[ChannelFile, channel_error] = process_import_chann(properties, channel_type, subID,iSurfaces);

%%
%% Process: Import Atlas
%%
if(isfield(properties.anatomy_params.anat_config,'default_atlas'))
    atlas_type = 'default';
else
    atlas_type = 'template';
end
atlas_error = process_import_atlas(properties, atlas_type, subID);

%%
%% Getting Headmodeler options
%%
[headmodel_options, errMessage] = process_comp_headmodel(properties, subID);

%%
%% Save and display report
%%
[subject_report_path, report_name] = get_report_path(properties, subID);
ReportFile = bst_report('Save', []);
bst_report('Export',  ReportFile, report_name);
%     bst_report('Open', ReportFile);
%     bst_report('Close');
disp(strcat("-->> Process finished for subject: ",subID));

%%
%% Geting subjects
%%
data_params = properties.prep_data_params.process_type.type_list{2};
if(contains(data_params.base_path,'SubID'))
    [base_path,~,~]    = fileparts(data_params.base_path);
    subjects           = dir(base_path);
else
    subjects           = dir(data_params.base_path);
end
subjects(ismember( {subjects.name}, {'.', '..'})) = [];  %remove . and ..
if(isempty(subjects))
    fprintf(2,strcat('-->> Error: We can not find any subject data: \n'));
    fprintf(2,strcat('-->> Do not exist the Raw data Or the Preprocessed data. \n'));
    fprintf(2,strcat('-->> Please configure the properties file correctly. \n'));
    return;
else
    for i=1:length(subjects)
        %%
        %% Export Subject to BC-VARETA
        %%
        subject = subjects(i);
        if(subject.isdir)
            subID = subject.name;
        else
            [~,subID,~] = fileparts(subject.name);
        end
        disp(strcat('BC-V -->> Export subject:' , subID, ' to BC-VARETA structure'));
        disp('=================================================================');
        if(properties.general_params.bcv_config.export)
            export_subject_BCV_structure(properties,subID,'iTemplate',iSubject,'FSAve_interp',true, 'iter', 2);
        end
        disp(strcat('-->> Subject:' , subID, '. Processing finished.'));
        disp('=================================================================');
    end
end
disp(strcat('-->> Process finished....'));
disp('=================================================================');
disp('=================================================================');
save report.mat subjects_processed subjects_process_error;
end

