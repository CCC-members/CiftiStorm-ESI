function protocol_headmodel_after_MaQC(ProtocolName,subID)

% Updaters:
% - Ariosky Areces Gonzalez
% - Deirel Paz Linares

%%
app_properties = jsondecode(fileread(strcat('app',filesep,'app_properties.json')));
app_protocols = jsondecode(fileread(strcat('app',filesep,'app_protocols.json')));
selected_data_set = app_protocols.(strcat('x',app_properties.selected_data_set.value));


%%
%% Checking the report output structure
%%
if(selected_data_set.report_output_path == "local")
    report_output_path = pwd;
else
    report_output_path = selected_data_set.report_output_path ;    
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
report_name = fullfile(report_output_path,'Reports',ProtocolName,['Report_',subID,'.html']);
iter = 2;
while(isfile(report_name))   
   report_name = fullfile(report_output_path,'Reports',ProtocolName,['Report_',subID,'_Iter_', num2str(iter),'.html']);
   iter = iter + 1;
end  

%%
%%
%%

% subjects_list = bst_get('ProtocolSubjects'); 

%%
%% Quality control
%%
% Get Protocol info
ProtocolInfo = bst_get('ProtocolInfo');
% Get subject definition
sSubject = bst_get('Subject', subID);
% Get MRI file and surface files
MriFile    = sSubject.Anatomy(sSubject.iAnatomy).FileName;
hFigMri1 = view_mri_slices(MriFile, 'x', 20);
bst_report('Snapshot',hFigMri1,MriFile,'MRI Axial view', [200,200,750,475]);

hFigMri2 = view_mri_slices(MriFile, 'y', 20);
bst_report('Snapshot',hFigMri2,MriFile,'MRI Coronal view', [200,200,750,475]);

hFigMri3 = view_mri_slices(MriFile, 'z', 20);
bst_report('Snapshot',hFigMri3,MriFile,'MRI Sagital view', [200,200,750,475]);

close([hFigMri1 hFigMri2 hFigMri3]);

%%
%% Quality control
%%
% Get subject definition and subject files
sSubject       = bst_get('Subject', subID);
MriFile        = sSubject.Anatomy(sSubject.iAnatomy).FileName;
CortexFile     = sSubject.Surface(sSubject.iCortex).FileName;
InnerSkullFile = sSubject.Surface(sSubject.iInnerSkull).FileName;
OuterSkullFile = sSubject.Surface(sSubject.iOuterSkull).FileName;
ScalpFile      = sSubject.Surface(sSubject.iScalp).FileName;

%
hFigMriSurf = view_mri(MriFile, CortexFile);

%
hFigMri4  = script_view_contactsheet( hFigMriSurf, 'volume', 'x','');
bst_report('Snapshot',hFigMri4,MriFile,'Cortex - MRI registration Axial view', [200,200,750,475]);

%
hFigMri5  = script_view_contactsheet( hFigMriSurf, 'volume', 'y','');
bst_report('Snapshot',hFigMri5,MriFile,'Cortex - MRI registration Coronal view', [200,200,750,475]);

%
hFigMri6  = script_view_contactsheet( hFigMriSurf, 'volume', 'z','');
bst_report('Snapshot',hFigMri6,MriFile,'Cortex - MRI registration Sagital view', [200,200,750,475]);

% Closing figures
close([hFigMriSurf hFigMri4 hFigMri5 hFigMri6]);

%
hFigMri7 = view_mri(MriFile, ScalpFile);
bst_report('Snapshot',hFigMri7,MriFile,'Scalp registration', [200,200,750,475]);

%
hFigMri8 = view_mri(MriFile, OuterSkullFile);
bst_report('Snapshot',hFigMri8,MriFile,'Outer Skull - MRI registration', [200,200,750,475]);

%
hFigMri9 = view_mri(MriFile, InnerSkullFile);
bst_report('Snapshot',hFigMri9,MriFile,'Inner Skull - MRI registration', [200,200,750,475]);

% Closing figures
close([hFigMri7 hFigMri8 hFigMri9]);

% 
hFigSurf10 = view_surface(CortexFile);
bst_report('Snapshot',hFigSurf10,[],'Cortex mesh 3D top view', [200,200,750,475]);

%
figure_3d('SetStandardView', hFigSurf10, 'left');
bst_report('Snapshot',hFigSurf10,[],'Cortex mesh 3D left hemisphere view', [200,200,750,475]);

%
figure_3d('SetStandardView', hFigSurf10, 'bottom');
bst_report('Snapshot',hFigSurf10,[],'Cortex mesh 3D bottom view', [200,200,750,475]);

%
figure_3d('SetStandardView', hFigSurf10, 'right');
bst_report('Snapshot',hFigSurf10,[],'Cortex mesh 3D right hemisphere view', [200,200,750,475]);

% Closing figure
close(hFigSurf10);

%% 
%% Quality Control
%%
% Get subject definition and subject files
sSubject       = bst_get('Subject', subID);
MriFile        = sSubject.Anatomy(sSubject.iAnatomy).FileName;
CortexFile     = sSubject.Surface(sSubject.iCortex).FileName;
InnerSkullFile = sSubject.Surface(sSubject.iInnerSkull).FileName;
OuterSkullFile = sSubject.Surface(sSubject.iOuterSkull).FileName;
ScalpFile      = sSubject.Surface(sSubject.iScalp).FileName;

hFigSurf11 = script_view_surface(CortexFile, [], [], [],'top');
hFigSurf11 = script_view_surface(InnerSkullFile, [], [], hFigSurf11);
hFigSurf11 = script_view_surface(OuterSkullFile, [], [], hFigSurf11);
hFigSurf11 = script_view_surface(ScalpFile, [], [], hFigSurf11);
bst_report('Snapshot',hFigSurf11,[],'BEM surfaces registration top view', [200,200,750,475]);

close(hFigSurf11);

hFigSurf12 = script_view_surface(CortexFile, [], [], [],'left');
hFigSurf12 = script_view_surface(InnerSkullFile, [], [], hFigSurf12);
hFigSurf12 = script_view_surface(OuterSkullFile, [], [], hFigSurf12);
hFigSurf12 = script_view_surface(ScalpFile, [], [], hFigSurf12);
bst_report('Snapshot',hFigSurf12,[],'BEM surfaces registration left view', [200,200,750,475]);

close( hFigSurf12);

hFigSurf13 = script_view_surface(CortexFile, [], [], [],'right');
hFigSurf13 = script_view_surface(InnerSkullFile, [], [], hFigSurf13);
hFigSurf13 = script_view_surface(OuterSkullFile, [], [], hFigSurf13);
hFigSurf13 = script_view_surface(ScalpFile, [], [], hFigSurf13);
bst_report('Snapshot',hFigSurf13,[],'BEM surfaces registration right view', [200,200,750,475]);
close(hFigSurf13);

hFigSurf14 = script_view_surface(CortexFile, [], [], [],'back');
hFigSurf14 = script_view_surface(InnerSkullFile, [], [], hFigSurf14);
hFigSurf14 = script_view_surface(OuterSkullFile, [], [], hFigSurf14);
hFigSurf14 = script_view_surface(ScalpFile, [], [], hFigSurf14);
bst_report('Snapshot',hFigSurf14,[],'BEM surfaces registration back view', [200,200,750,475]);

close(hFigSurf14);

%%
%% Quality control
%%
% Get subject definition and subject files
ScalpFile      = sSubject.Surface(sSubject.iScalp).FileName;

%
hFigMri15 = view_mri(MriFile, ScalpFile);
bst_report('Snapshot',hFigMri15,[],'SPM Scalp Envelope - MRI registration', [200,200,750,475]);

% Close figures
close(hFigMri15);
%%
%% Quality control
%%
% View sources on MRI (3D orthogonal slices)
BSTChannelsFile = bst_fullfile(ProtocolInfo.STUDIES,subID, ['@raw' subID],'channel.mat');



hFigMri16      = script_view_mri_3d(MriFile, [], [], [], 'front');
hFigMri16      = view_channels(BSTChannelsFile, 'EEG', 1, 0, hFigMri16, 1);
bst_report('Snapshot',hFigMri16,[],'Sensor-MRI registration front view', [200,200,750,475]);

hFigMri17      = script_view_mri_3d(MriFile, [], [], [], 'left');
hFigMri17      = view_channels(BSTChannelsFile, 'EEG', 1, 0, hFigMri17, 1);
bst_report('Snapshot',hFigMri17,[],'Sensor-MRI registration left view', [200,200,750,475]);

hFigMri18      = script_view_mri_3d(MriFile, [], [], [], 'right');
hFigMri18      = view_channels(BSTChannelsFile, 'EEG', 1, 0, hFigMri18, 1);
bst_report('Snapshot',hFigMri18,[],'Sensor-MRI registration right view', [200,200,750,475]);

hFigMri19      = script_view_mri_3d(MriFile, [], [], [], 'back');
hFigMri19      = view_channels(BSTChannelsFile, 'EEG', 1, 0, hFigMri19, 1);
bst_report('Snapshot',hFigMri19,[],'Sensor-MRI registration back view', [200,200,750,475]);

% Close figures
close([hFigMri16 hFigMri17 hFigMri18 hFigMri19]);

% View sources on Scalp
ScalpFile      = sSubject.Surface(sSubject.iScalp).FileName;

hFigMri20      = script_view_surface(ScalpFile, [], [], [],'front');
hFigMri20      = view_channels(BSTChannelsFile, 'EEG', 1, 0, hFigMri20, 1);
bst_report('Snapshot',hFigMri20,[],'Sensor-Scalp registration front view', [200,200,750,475]);

hFigMri21      = script_view_surface(ScalpFile, [], [], [],'left');
hFigMri21      = view_channels(BSTChannelsFile, 'EEG', 1, 0, hFigMri21, 1);
bst_report('Snapshot',hFigMri21,[],'Sensor-Scalp registration left view', [200,200,750,475]);

hFigMri22      = script_view_surface(ScalpFile, [], [], [],'right');
hFigMri22      = view_channels(BSTChannelsFile, 'EEG', 1, 0, hFigMri22, 1);
bst_report('Snapshot',hFigMri22,[],'Sensor-Scalp registration right view', [200,200,750,475]);

hFigMri23      = script_view_surface(ScalpFile, [], [], [],'back');
hFigMri23      = view_channels(BSTChannelsFile, 'EEG', 1, 0, hFigMri23, 1);
bst_report('Snapshot',hFigMri23,[],'Sensor-Scalp registration back view', [200,200,750,475]);

% Close figures
close([hFigMri20 hFigMri21 hFigMri22 hFigMri23]);

%%
%% Quality control 
%%
%% 
hFigSurf24 = view_surface(CortexFile);
bst_report('Snapshot',hFigSurf24,[],'surface view', [200,200,750,475]);

%
figure_3d('SetStandardView', hFigSurf24, 'left');
bst_report('Snapshot',hFigSurf24,[],'Surface left view', [200,200,750,475]);

%
figure_3d('SetStandardView', hFigSurf24, 'bottom');
bst_report('Snapshot',hFigSurf24,[],'Surface bottom view', [200,200,750,475]);

%
figure_3d('SetStandardView', hFigSurf24, 'right');
bst_report('Snapshot',hFigSurf24,[],'Surface right view', [200,200,750,475]);

% Closing figure
close(hFigSurf24)
%%
%% Get Protocol information
%%

headmodel_options = struct();
headmodel_options.Comment = 'OpenMEEG BEM';
headmodel_options.HeadModelFile = bst_fullfile(ProtocolInfo.STUDIES,subID, ['@raw' subID]);
headmodel_options.HeadModelType = 'surface';

% Uploading Channels
BSTChannelsFile = bst_fullfile(ProtocolInfo.STUDIES,subID, ['@raw' subID],'channel.mat');
BSTChannels = load(BSTChannelsFile);
headmodel_options.Channel = BSTChannels.Channel;

headmodel_options.MegRefCoef = [];
headmodel_options.MEGMethod = '';
headmodel_options.EEGMethod = 'openmeeg';
headmodel_options.ECOGMethod = '';
headmodel_options.SEEGMethod = '';
headmodel_options.HeadCenter = [];
headmodel_options.Radii = [0.88,0.93,1];
headmodel_options.Conductivity = [0.33,0.0042,0.33];
headmodel_options.SourceSpaceOptions = [];

% Uploading cortex
CortexFile     = sSubject.Surface(sSubject.iCortex).FileName;
headmodel_options.CortexFile = CortexFile;

% Uploading head
ScalpFile      = sSubject.Surface(sSubject.iScalp).FileName;
headmodel_options.HeadFile = ScalpFile;

InnerSkullFile = sSubject.Surface(sSubject.iInnerSkull).FileName;
headmodel_options.InnerSkullFile = InnerSkullFile;

OuterSkullFile = sSubject.Surface(sSubject.iOuterSkull).FileName;
headmodel_options.OuterSkullFile =  OuterSkullFile;
headmodel_options.GridOptions = [];
headmodel_options.GridLoc  = [];
headmodel_options.GridOrient  = [];
headmodel_options.GridAtlas  = [];
headmodel_options.Interactive  = true;
headmodel_options.SaveFile  = true;

BSTScalpFile = bst_fullfile(ProtocolInfo.SUBJECTS, ScalpFile);
BSTOuterSkullFile = bst_fullfile(ProtocolInfo.SUBJECTS, OuterSkullFile);
BSTInnerSkullFile = bst_fullfile(ProtocolInfo.SUBJECTS, InnerSkullFile);
headmodel_options.BemFiles = {BSTScalpFile, BSTOuterSkullFile,BSTInnerSkullFile};
headmodel_options.BemNames = {'Scalp','Skull','Brain'};
headmodel_options.BemCond = [1,0.0125,1];
headmodel_options.iMeg = [];
headmodel_options.iEeg = 1:length(BSTChannels.Channel);
headmodel_options.iEcog = [];
headmodel_options.iSeeg = [];
headmodel_options.BemSelect = [true,true,true];
headmodel_options.isAdjoint = false;
headmodel_options.isAdaptative = true;
headmodel_options.isSplit = false;
headmodel_options.SplitLength = 4000;


 [headmodel_options, errMessage] = bst_headmodeler(headmodel_options);

%%
%% Quality control 
%%

BSTCortexFile = bst_fullfile(ProtocolInfo.SUBJECTS, CortexFile);
cortex = load(BSTCortexFile);
head = load(BSTScalpFile);
% Uploading Gain matrix
BSTHeadModelFile = bst_fullfile(ProtocolInfo.STUDIES,subID, ['@raw' subID],'headmodel_surf_openmeeg.mat');
BSTHeadModel = load(BSTHeadModelFile);
Ke = BSTHeadModel.Gain;

channels = [BSTChannels.Channel.Loc];
channels = channels';

%%
[hFig25] = view3D_K(Ke,cortex,head,channels,17);
bst_report('Snapshot',hFig25,[],'Field top view', [200,200,750,475]);
view(0,360)
bst_report('Snapshot',hFig25,[],'Field right view', [200,200,750,475]);
view(1,180)
bst_report('Snapshot',hFig25,[],'Field left view', [200,200,750,475]);
view(90,360)
bst_report('Snapshot',hFig25,[],'Field front view', [200,200,750,475]);
view(270,360)
bst_report('Snapshot',hFig25,[],'Field back view', [200,200,750,475]);

% Closing figure
close(hFig25)
%%
%% Export Subject to BC-VARETA
%%
% export_subject_BCV(sSubject);

%%
%% Save and display report
%%   
ReportFile = bst_report('Save');
bst_report('Export',  ReportFile,report_name);
bst_report('Open', ReportFile);
bst_report('Close');
disp([10 '-->> BrainStorm Protocol PhilipsMFF: Done.' 10]);

