function subj_error = headmodel_default_anat(properties)
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
modality = properties.general_params.modality;
subID                   = 'Template';
ProtocolName            = properties.general_params.protocol_name;
ProtocolName_R          = strcat(ProtocolName,'_Template');
subjects_process_error  = [];
subjects_processed      = [];
report_output_path      = properties.general_params.reports.output_path;
protocol_reset          = properties.general_params.protocol_reset; 

%%
%% Checking the report output structure
%%
if(report_output_path == "local")
    report_output_path = pwd;
end
if(~isfolder(report_output_path))
    mkdir(report_output_path);
end
if(~isfolder(fullfile(report_output_path,'Reports')))
    mkdir(fullfile(report_output_path,'Reports'));
end
if(~isfolder(fullfile(report_output_path,'Reports',ProtocolName)))
    mkdir(fullfile(report_output_path,'Reports',ProtocolName));
end
if(~isfolder(fullfile(report_output_path,'Reports',ProtocolName,subID)))
    mkdir(fullfile(report_output_path,'Reports',ProtocolName,subID));
end
subject_report_path = fullfile(report_output_path,'Reports',ProtocolName,subID);
report_name         = fullfile(subject_report_path,[subID,'.html']);
iter                = 2;
while(isfile(report_name))
    report_name     = fullfile(subject_report_path,[subID,'_Iter_', num2str(iter),'.html']);
    iter            = iter + 1;
end

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
%% Process import anatomy
%%
anat_error = process_import_anat(properties,'default',iSubject);

%%
%% Preparing eviroment
%%


%%
%% ===== IMPORT ANATOMY =====
%%
% Start a new report
bst_report('Start',['Protocol for subject:' , subID]);
bst_report('Info', '', [], ['Protocol for subject:' , subID]);

%%
%% Quality control
%%
% Get subject definition
sSubject    = bst_get('Subject', subID);

% Get MRI file and surface files
MriFile     = sSubject.Anatomy(sSubject.iAnatomy).FileName;
hFigMri1    = view_mri_slices(MriFile, 'x', 20);
bst_report('Snapshot',hFigMri1,MriFile,'MRI Axial view', [200,200,750,475]);
savefig( hFigMri1,fullfile(subject_report_path,'MRI Axial view.fig'));
close(hFigMri1);

hFigMri2    = view_mri_slices(MriFile, 'y', 20);
bst_report('Snapshot',hFigMri2,MriFile,'MRI Coronal view', [200,200,750,475]);
savefig( hFigMri2,fullfile(subject_report_path,'MRI Coronal view.fig'));
close(hFigMri2);

hFigMri3    = view_mri_slices(MriFile, 'z', 20);
bst_report('Snapshot',hFigMri3,MriFile,'MRI Sagital view', [200,200,750,475]);
savefig( hFigMri3,fullfile(subject_report_path,'MRI Sagital view.fig'));
close(hFigMri3);

%%
%% Process: Generate BEM surfaces
%%
if(properties.anatomy_params.surfaces_resolution.gener_BEM_surf)
    sFiles = bst_process('CallProcess', 'process_generate_bem', [], [], ...
        'subjectname', subID, ...
        'nscalp',      3242, ...
        'nouter',      3242, ...
        'ninner',      3242, ...
        'thickness',   4);
end
%%
%% Get subject definition and subject files
%%
sSubject       = bst_get('Subject', subID);
CortexFile     = sSubject.Surface(sSubject.iCortex).FileName;
InnerSkullFile = sSubject.Surface(sSubject.iInnerSkull).FileName;

%%
%% Forcing dipoles inside innerskull
%%
%             [iIS, BstTessISFile, nVertOrigR] = import_surfaces(iSubject, innerskull_file, 'MRI-MASK-MNI', 1);
%             BstTessISFile = BstTessISFile{1};
script_tess_force_envelope(CortexFile, InnerSkullFile);
% 
%%
%% Get subject definition and subject files
%%
sSubject        = bst_get('Subject', subID);
MriFile         = sSubject.Anatomy(sSubject.iAnatomy).FileName;
CortexFile      = sSubject.Surface(sSubject.iCortex).FileName;
InnerSkullFile  = sSubject.Surface(sSubject.iInnerSkull).FileName;
OuterSkullFile  = sSubject.Surface(sSubject.iOuterSkull).FileName;
ScalpFile       = sSubject.Surface(sSubject.iScalp).FileName;
iCortex         = sSubject.iCortex;
iAnatomy        = sSubject.iAnatomy;
iInnerSkull     = sSubject.iInnerSkull;
iOuterSkull     = sSubject.iOuterSkull;
iScalp          = sSubject.iScalp;

%%
%% Quality control
%%

hFigSurf11      = script_view_surface(CortexFile, [], [], [],'top');
hFigSurf11      = script_view_surface(InnerSkullFile, [], [], hFigSurf11);
hFigSurf11      = script_view_surface(OuterSkullFile, [], [], hFigSurf11);
hFigSurf11      = script_view_surface(ScalpFile, [], [], hFigSurf11);
bst_report('Snapshot',hFigSurf11,[],'BEM surfaces registration top view', [200,200,750,475]);
savefig( hFigSurf11,fullfile(subject_report_path,'BEM surfaces registration view.fig'));
% Left
view(1,180)
bst_report('Snapshot',hFigSurf11,[],'BEM surfaces registration left view', [200,200,750,475]);
% Right
view(0,360)
bst_report('Snapshot',hFigSurf11,[],'BEM surfaces registration right view', [200,200,750,475]);
% Front
view(90,360)
bst_report('Snapshot',hFigSurf11,[],'BEM surfaces registration front view', [200,200,750,475]);
% Back
view(270,360)
bst_report('Snapshot',hFigSurf11,[],'BEM surfaces registration back view', [200,200,750,475]);
% Closing figure
close(hFigSurf11);

%%
%% Process: Generate SPM canonical surfaces
%%
bst_process('CallProcess', 'process_generate_canonical', sFiles, [], ...
    'subjectname', subID, ...
    'resolution',  2);  % 8196

%%
%% Quality control
%%
% Get subject definition and subject files
sSubject        = bst_get('Subject', subID);
ScalpFile       = sSubject.Surface(sSubject.iScalp).FileName;

%
hFigMri15       = view_mri(MriFile, ScalpFile);
bst_report('Snapshot',hFigMri15,[],'SPM Scalp Envelope - MRI registration', [200,200,750,475]);
savefig( hFigMri15,fullfile(subject_report_path,'SPM Scalp Envelope - MRI registration.fig'));
% Close figures
close(hFigMri15);

%%
%% Process: Set BEM Surfaces
%%
[sSubject, iSubject] = bst_get('Subject', subID);
db_surface_default(iSubject, 'Scalp', iScalp);
db_surface_default(iSubject, 'OuterSkull', iOuterSkull);
db_surface_default(iSubject, 'InnerSkull', iInnerSkull);
db_surface_default(iSubject, 'Cortex', iCortex);

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
%% Quality control
%%
% View sources on MRI (3D orthogonal slices)
[sSubject, iSubject]    = bst_get('Subject', subID);
MriFile                 = sSubject.Anatomy(sSubject.iAnatomy).FileName;
hFigMri16               = script_view_mri_3d(MriFile, [], [], [], 'front');
hFigMri16               = view_channels(ChannelFile, 'EEG', 1, 0, hFigMri16, 1);
bst_report('Snapshot',hFigMri16,[],'Sensor-MRI registration front view', [200,200,750,475]);
savefig( hFigMri16,fullfile(subject_report_path,'Sensor-MRI registration front view.fig'));
%Left
view(1,180)
bst_report('Snapshot',hFigMri16,[],'Sensor-MRI registration left view', [200,200,750,475]);
% Right
view(0,360)
bst_report('Snapshot',hFigMri16,[],'Sensor-MRI registration right view', [200,200,750,475]);
% back
view(270,360)
bst_report('Snapshot',hFigMri16,[],'Sensor-MRI registration back view', [200,200,750,475]);
% Close figures
close(hFigMri16);

% View sources on Scalp
[sSubject, iSubject]    = bst_get('Subject', subID);
MriFile                 = sSubject.Anatomy(sSubject.iAnatomy).FileName;
ScalpFile               = sSubject.Surface(sSubject.iScalp).FileName;
hFigMri20               = script_view_surface(ScalpFile, [], [], [],'front');
hFigMri20               = view_channels(ChannelFile, 'EEG', 1, 0, hFigMri20, 1);
bst_report('Snapshot',hFigMri20,[],'Sensor-Scalp registration front view', [200,200,750,475]);
savefig( hFigMri20,fullfile(subject_report_path,'Sensor-Scalp registration front view.fig'));
%Left
view(1,180)
bst_report('Snapshot',hFigMri20,[],'Sensor-Scalp registration left view', [200,200,750,475]);
% Right
view(0,360)
bst_report('Snapshot',hFigMri20,[],'Sensor-Scalp registration right view', [200,200,750,475]);
% Back
view(270,360)
bst_report('Snapshot',hFigMri20,[],'Sensor-Scalp registration back view', [200,200,750,475]);
% Close figures
close(hFigMri20);

%%
%% Process: Import Atlas
%%
atlas_error = process_import_atlas(properties, 'default', subID);

%%
%% Quality control
%%
%
hFigSurf24 = view_surface(CortexFile);
% Deleting the Atlas Labels and Countour from Cortex
delete(findobj(hFigSurf24, 'Tag', 'ScoutLabel'));
delete(findobj(hFigSurf24, 'Tag', 'ScoutMarker'));
delete(findobj(hFigSurf24, 'Tag', 'ScoutContour'));

bst_report('Snapshot',hFigSurf24,[],'surface view', [200,200,750,475]);
savefig( hFigSurf24,fullfile(subject_report_path,'Surface view.fig'));
%Left
view(1,180)
bst_report('Snapshot',hFigSurf24,[],'Surface left view', [200,200,750,475]);
% Bottom
view(90,270)
bst_report('Snapshot',hFigSurf24,[],'Surface bottom view', [200,200,750,475]);
% Rigth
view(0,360)
bst_report('Snapshot',hFigSurf24,[],'Surface right view', [200,200,750,475]);
% Closing figure
close(hFigSurf24)

%%
%% Getting Headmodeler options
%%
sSubject            = bst_get('Subject', subID);
[sStudies, iStudy]  = bst_get('StudyWithSubject', sSubject.FileName, 'intra_subject');
headmodel_options = get_headmodeler_options(modality, subID, iStudy);

%%
%% Process Head Model
%%
[headmodel_options, errMessage] = bst_headmodeler(headmodel_options);

if(~isempty(headmodel_options))
    sStudy = bst_get('Study', iStudy);
    % If a new head model is available
    sHeadModel                      = db_template('headmodel');
    sHeadModel.FileName             = file_short(headmodel_options.HeadModelFile);
    sHeadModel.Comment              = headmodel_options.Comment;
    sHeadModel.HeadModelType        = headmodel_options.HeadModelType;
    % Update Study structure
    iHeadModel                      = length(sStudy.HeadModel) + 1;
    sStudy.HeadModel(iHeadModel)    = sHeadModel;
    sStudy.iHeadModel               = iHeadModel;
    sStudy.iChannel                 = length(sStudy.Channel);
    % Update DataBase
    bst_set('Study', iStudy, sStudy);
    db_save();
    
    %%
    %% Quality control of Head model
    %%
    qc_headmodel(headmodel_options,modality,subject_report_path);
    
    %%
    %% Save and display report
    %%
    ReportFile = bst_report('Save', []);
    bst_report('Export',  ReportFile,report_name);
    bst_report('Open', ReportFile);
    bst_report('Close');
    processed = true;
    disp(strcat("-->> Process finished for subject: Template"));

else
    subjects_process_error = [subjects_process_error; subID];    
end

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
    fprintf(2,strcat('\n -->> Error: We can not find any subject data: \n'));
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
        if(properties.general_params.bcv_config.export)
            export_subject_BCV_structure(properties,subID,'iTemplate',iSubject,'FSAve_interp',false);
        end
        disp(strcat('-->> Subject:' , subID, '. Processing finished.'));
    end
end
disp(strcat('-->> Process finished....'));
disp('=================================================================');
disp('=================================================================');
save report.mat subjects_processed subjects_process_error;

end

