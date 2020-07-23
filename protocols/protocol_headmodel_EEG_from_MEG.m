function [processed] = protocol_headmodel_EEG_from_MEG(ProtocolName,subID)
% @=============================================================================
% This function is part of the Brainstorm software:
% https://neuroimage.usc.edu/brainstorm
%
% Copyright (c)2000-2019 University of Southern California & McGill University
% This software is distributed under the terms of the GNU General Public License
% as published by the Free Software Foundation. Further details on the GPLv3
% license can be found at http://www.gnu.org/copyleft/gpl.html.
%
% FOR RESEARCH PURPOSES ONLY. THE SOFTWARE IS PROVIDED "AS IS," AND THE
% UNIVERSITY OF SOUTHERN CALIFORNIA AND ITS COLLABORATORS DO NOT MAKE ANY
% WARRANTY, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, NOR DO THEY ASSUME ANY
% LIABILITY OR RESPONSIBILITY FOR THE USE OF THIS SOFTWARE.
%
% For more information type "brainstorm license" at command prompt.
% =============================================================================@
%
% Author: Francois Tadel, 2014-2016
%
%
% Updaters:
% - Ariosky Areces Gonzalez
% - Deirel Paz Linares

%%
app_properties = jsondecode(fileread(strcat('app',filesep,'app_properties.json')));
selected_data_set = jsondecode(fileread(strcat('config_protocols',filesep,app_properties.selected_data_set.file_name)));


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
if(~isfolder(fullfile(report_output_path,'Reports',ProtocolName,subID)))
    mkdir(fullfile(report_output_path,'Reports',ProtocolName,subID));
end
subject_report_path = fullfile(report_output_path,'Reports',ProtocolName,subID);
report_name = fullfile(subject_report_path,[subID,'.html']);
iter = 2;
while(isfile(report_name))
    report_name = fullfile(subject_report_path,[subID,'_Iter_', num2str(iter),'.html']);
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
if(isempty(sSubject) || isempty(sSubject.iAnatomy) || isempty(sSubject.iCortex) || isempty(sSubject.iInnerSkull) || isempty(sSubject.iOuterSkull) || isempty(sSubject.iScalp))
    return;
end
try
    MriFile    = sSubject.Anatomy(sSubject.iAnatomy).FileName;
    hFigMri1 = view_mri_slices(MriFile, 'x', 20);
    bst_report('Snapshot',hFigMri1,MriFile,'MRI Axial view', [200,200,750,475]);
    saveas( hFigMri1,fullfile(subject_report_path,'MRI Axial view.fig'));
    
    hFigMri2 = view_mri_slices(MriFile, 'y', 20);
    bst_report('Snapshot',hFigMri2,MriFile,'MRI Coronal view', [200,200,750,475]);
    saveas( hFigMri2,fullfile(subject_report_path,'MRI Coronal view.fig'));
    
    hFigMri3 = view_mri_slices(MriFile, 'z', 20);
    bst_report('Snapshot',hFigMri3,MriFile,'MRI Sagital view', [200,200,750,475]);
    saveas( hFigMri3,fullfile(subject_report_path,'MRI Sagital view.fig'));
catch
end
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
try
    hFigMriSurf = view_mri(MriFile, CortexFile);
    
    %
    hFigMri4  = script_view_contactsheet( hFigMriSurf, 'volume', 'x','');
    bst_report('Snapshot',hFigMri4,MriFile,'Cortex - MRI registration Axial view', [200,200,750,475]);
    saveas( hFigMri4,fullfile(subject_report_path,'Cortex - MRI registration Axial view.fig'));
    %
    hFigMri5  = script_view_contactsheet( hFigMriSurf, 'volume', 'y','');
    bst_report('Snapshot',hFigMri5,MriFile,'Cortex - MRI registration Coronal view', [200,200,750,475]);
    saveas( hFigMri5,fullfile(subject_report_path,'Cortex - MRI registration Coronal view.fig'));
    %
    hFigMri6  = script_view_contactsheet( hFigMriSurf, 'volume', 'z','');
    bst_report('Snapshot',hFigMri6,MriFile,'Cortex - MRI registration Sagital view', [200,200,750,475]);
    saveas( hFigMri6,fullfile(subject_report_path,'Cortex - MRI registration Sagital view.fig'));
    % Closing figures
catch
end
close([hFigMriSurf hFigMri4 hFigMri5 hFigMri6]);
try
    %
    hFigMri7 = view_mri(MriFile, ScalpFile);
    bst_report('Snapshot',hFigMri7,MriFile,'Scalp registration', [200,200,750,475]);
    saveas( hFigMri7,fullfile(subject_report_path,'Scalp registration.fig'));
    %
    hFigMri8 = view_mri(MriFile, OuterSkullFile);
    bst_report('Snapshot',hFigMri8,MriFile,'Outer Skull - MRI registration', [200,200,750,475]);
    saveas( hFigMri8,fullfile(subject_report_path,'Outer Skull - MRI registration.fig'));
    %
    hFigMri9 = view_mri(MriFile, InnerSkullFile);
    bst_report('Snapshot',hFigMri9,MriFile,'Inner Skull - MRI registration', [200,200,750,475]);
    saveas( hFigMri9,fullfile(subject_report_path,'Inner Skull - MRI registration.fig'));
catch
end
% Closing figures
close([hFigMri7 hFigMri8 hFigMri9]);

% 
try
    hFigSurf10 = view_surface(CortexFile);
    bst_report('Snapshot',hFigSurf10,[],'Cortex mesh 3D top view', [200,200,750,475]);
    saveas( hFigSurf10,fullfile(subject_report_path,'Cortex mesh 3D top view.fig'));
    %
    figure_3d('SetStandardView', hFigSurf10, 'left');
    bst_report('Snapshot',hFigSurf10,[],'Cortex mesh 3D left hemisphere view', [200,200,750,475]);
    
    %
    figure_3d('SetStandardView', hFigSurf10, 'bottom');
    bst_report('Snapshot',hFigSurf10,[],'Cortex mesh 3D bottom view', [200,200,750,475]);
    
    %
    figure_3d('SetStandardView', hFigSurf10, 'right');
    bst_report('Snapshot',hFigSurf10,[],'Cortex mesh 3D right hemisphere view', [200,200,750,475]);
catch
end
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

try
    hFigSurf11 = script_view_surface(CortexFile, [], [], [],'top');
    hFigSurf11 = script_view_surface(InnerSkullFile, [], [], hFigSurf11);
    hFigSurf11 = script_view_surface(OuterSkullFile, [], [], hFigSurf11);
    hFigSurf11 = script_view_surface(ScalpFile, [], [], hFigSurf11);
    bst_report('Snapshot',hFigSurf11,[],'BEM surfaces registration top view', [200,200,750,475]);
    saveas( hFigSurf11,fullfile(subject_report_path,'BEM surfaces registration top view.fig'));
catch
end
close(hFigSurf11);
try
    hFigSurf12 = script_view_surface(CortexFile, [], [], [],'left');
    hFigSurf12 = script_view_surface(InnerSkullFile, [], [], hFigSurf12);
    hFigSurf12 = script_view_surface(OuterSkullFile, [], [], hFigSurf12);
    hFigSurf12 = script_view_surface(ScalpFile, [], [], hFigSurf12);
    bst_report('Snapshot',hFigSurf12,[],'BEM surfaces registration left view', [200,200,750,475]);
catch
end
close( hFigSurf12);
try
    hFigSurf13 = script_view_surface(CortexFile, [], [], [],'right');
    hFigSurf13 = script_view_surface(InnerSkullFile, [], [], hFigSurf13);
    hFigSurf13 = script_view_surface(OuterSkullFile, [], [], hFigSurf13);
    hFigSurf13 = script_view_surface(ScalpFile, [], [], hFigSurf13);
    bst_report('Snapshot',hFigSurf13,[],'BEM surfaces registration right view', [200,200,750,475]);
catch
end
close(hFigSurf13);

try
    hFigSurf14 = script_view_surface(CortexFile, [], [], [],'back');
    hFigSurf14 = script_view_surface(InnerSkullFile, [], [], hFigSurf14);
    hFigSurf14 = script_view_surface(OuterSkullFile, [], [], hFigSurf14);
    hFigSurf14 = script_view_surface(ScalpFile, [], [], hFigSurf14);
    bst_report('Snapshot',hFigSurf14,[],'BEM surfaces registration back view', [200,200,750,475]);
catch
end
close(hFigSurf14);

%%
%% Quality control
%%
% Get subject definition and subject files
ScalpFile      = sSubject.Surface(sSubject.iScalp).FileName;

%
try
    hFigMri15 = view_mri(MriFile, ScalpFile);
    bst_report('Snapshot',hFigMri15,[],'SPM Scalp Envelope - MRI registration', [200,200,750,475]);
    saveas( hFigMri15,fullfile(subject_report_path,'SPM Scalp Envelope - MRI registration.fig'));
    % Close figures
catch
end
close(hFigMri15);


%%
%% Process: Generate SPM canonical surfaces
%%
% USAGE:     OutputFiles = process_generate_canonical('Run',     sProcess, sInputs)
%         [isOk, errMsg] = process_generate_canonical('Compute', iSubject, iAnatomy=[default], Resolution)
%                          process_generate_canonical('ComputeInteractive', iSubject, iAnatomy=[default], Resolution)
% process_generate_canonical('Compute', subID, 1, 2,0);

% sFiles = bst_process('CallProcess', 'process_generate_canonical',sFiles , [], ...
%     'subjectname', subID, ...
%     'resolution',  2);  % 8196

%%
%% Change de Channel file by EEG loyaut
%%
% Changing surfaces to SPM canonical surfaces
sSubject       = bst_get('Subject', subID);
ScalpFile      = sSubject.Surface(sSubject.iScalp).FileName;
[sSubject, iSubject] = bst_get('Subject', subID);
db_surface_default(iSubject, 'Scalp', 10);
db_surface_default(iSubject, 'OuterSkull', 11);
db_surface_default(iSubject, 'InnerSkull', 12);
db_surface_default(iSubject, 'Cortex', 13);

% note: find a better way to find the corrent Brainstorm sStudy
[sStudies, iStudies] = bst_get('StudyWithSubject', sSubject.FileName);
if(~isempty(iStudies))
else
    [sStudies, iStudies] = bst_get('StudyWithSubject', sSubject.FileName, 'intra_subject');
end
sStudy = bst_get('Study', iStudies);
if(isempty(sSubject) || isempty(sSubject.iAnatomy) || isempty(sSubject.iCortex) || isempty(sSubject.iInnerSkull) || isempty(sSubject.iOuterSkull) || isempty(sSubject.iScalp))
    return;
end

%   Process import chennel file
bstDefaults = bst_get('EegDefaults');
nameGroup = selected_data_set.process_import_channel.group_layout_name;
nameLayout = selected_data_set.process_import_channel.channel_layout_name;

iGroup = find(strcmpi(nameGroup, {bstDefaults.name}));
iLayout = strcmpi(nameLayout, {bstDefaults(iGroup).contents.name});
ChannelFile = bstDefaults(iGroup).contents(iLayout).fullpath;

[OutputFile, ChannelMat, ChannelReplace, ChannelAlign, Modality] = db_set_channel( iStudies, ChannelFile, 2,2);

% changing surfaces to BEM surfaces
[sSubject, iSubject] = bst_get('Subject', subID);
db_surface_default(iSubject, 'Scalp', 6);
db_surface_default(iSubject, 'OuterSkull', 7);
db_surface_default(iSubject, 'InnerSkull', 8);
db_surface_default(iSubject, 'Cortex', 9);

%%
%% projecting EEG electrodes on scalp surface
%%
process_channel_project('Compute',OutputFile,'EEG');

[sSubject, iSubject] = bst_get('Subject', subID);
[sStudies, iStudies] = bst_get('StudyWithSubject', sSubject.FileName);
if(~isempty(iStudies))
else
    [sStudies, iStudies] = bst_get('StudyWithSubject', sSubject.FileName, 'intra_subject');
end
sStudy = bst_get('Study', iStudies);
if(isempty(sSubject) || isempty(sSubject.iAnatomy) || isempty(sSubject.iCortex) || isempty(sSubject.iInnerSkull) || isempty(sSubject.iOuterSkull) || isempty(sSubject.iScalp))
    return;
end

%%
%% Quality control
%%
% View sources on MRI (3D orthogonal slices)
BSTChannelsFile = bst_fullfile(ProtocolInfo.STUDIES,sStudy.Channel(1).FileName);

try
    MriFile        = sSubject.Anatomy(sSubject.iAnatomy).FileName;
    
    hFigMri16      = script_view_mri_3d(MriFile, [], [], [], 'front');
    hFigMri16      = view_channels(BSTChannelsFile, 'EEG', 1, 0, hFigMri16, 1);
    bst_report('Snapshot',hFigMri16,[],'Sensor-MRI registration front view', [200,200,750,475]);
    saveas( hFigMri16,fullfile(subject_report_path,'Sensor-MRI registration front view.fig'));
    
    hFigMri17      = script_view_mri_3d(MriFile, [], [], [], 'left');
    hFigMri17      = view_channels(BSTChannelsFile, 'EEG', 1, 0, hFigMri17, 1);
    bst_report('Snapshot',hFigMri17,[],'Sensor-MRI registration left view', [200,200,750,475]);
    
    hFigMri18      = script_view_mri_3d(MriFile, [], [], [], 'right');
    hFigMri18      = view_channels(BSTChannelsFile, 'EEG', 1, 0, hFigMri18, 1);
    bst_report('Snapshot',hFigMri18,[],'Sensor-MRI registration right view', [200,200,750,475]);
    
    hFigMri19      = script_view_mri_3d(MriFile, [], [], [], 'back');
    hFigMri19      = view_channels(BSTChannelsFile, 'EEG', 1, 0, hFigMri19, 1);
    bst_report('Snapshot',hFigMri19,[],'Sensor-MRI registration back view', [200,200,750,475]);
catch
end
% Close figures
close([hFigMri16 hFigMri17 hFigMri18 hFigMri19]);

% View sources on Scalp
try
    MriFile        = sSubject.Anatomy(sSubject.iAnatomy).FileName;
    ScalpFile      = sSubject.Surface(sSubject.iScalp).FileName;
    
    hFigMri20      = script_view_surface(ScalpFile, [], [], [],'front');
    hFigMri20      = view_channels(BSTChannelsFile, 'EEG', 1, 0, hFigMri20, 1);
    bst_report('Snapshot',hFigMri20,[],'Sensor-Scalp registration front view', [200,200,750,475]);
    saveas( hFigMri20,fullfile(subject_report_path,'Sensor-Scalp registration front view.fig'));
    
    hFigMri21      = script_view_surface(ScalpFile, [], [], [],'left');
    hFigMri21      = view_channels(BSTChannelsFile, 'EEG', 1, 0, hFigMri21, 1);
    bst_report('Snapshot',hFigMri21,[],'Sensor-Scalp registration left view', [200,200,750,475]);
    
    hFigMri22      = script_view_surface(ScalpFile, [], [], [],'right');
    hFigMri22      = view_channels(BSTChannelsFile, 'EEG', 1, 0, hFigMri22, 1);
    bst_report('Snapshot',hFigMri22,[],'Sensor-Scalp registration right view', [200,200,750,475]);
    
    hFigMri23      = script_view_surface(ScalpFile, [], [], [],'back');
    hFigMri23      = view_channels(BSTChannelsFile, 'EEG', 1, 0, hFigMri23, 1);
    bst_report('Snapshot',hFigMri23,[],'Sensor-Scalp registration back view', [200,200,750,475]);
catch
end
% Close figures
close([hFigMri20 hFigMri21 hFigMri22 hFigMri23]);

%%
%% Quality control 
%%
%% 
try
    hFigSurf24 = view_surface(CortexFile);
    bst_report('Snapshot',hFigSurf24,[],'surface view', [200,200,750,475]);
    saveas( hFigSurf24,fullfile(subject_report_path,'Surface view.fig'));
    %
    figure_3d('SetStandardView', hFigSurf24, 'left');
    bst_report('Snapshot',hFigSurf24,[],'Surface left view', [200,200,750,475]);
    
    %
    figure_3d('SetStandardView', hFigSurf24, 'bottom');
    bst_report('Snapshot',hFigSurf24,[],'Surface bottom view', [200,200,750,475]);
    
    %
    figure_3d('SetStandardView', hFigSurf24, 'right');
    bst_report('Snapshot',hFigSurf24,[],'Surface right view', [200,200,750,475]);
catch
end
% Closing figure
close(hFigSurf24)


%%
%% Forcing dipoles inside innerskull
%%
script_tess_force_envelope(CortexFile, InnerSkullFile);

% Get subject definition and subject files
sSubject       = bst_get('Subject', subID);

%%
%% Get Protocol information
%%
[sStudies, iStudies] = bst_get('StudyWithSubject', sSubject.FileName);
if(~isempty(iStudies))
else
    [sStudies, iStudies] = bst_get('StudyWithSubject', sSubject.FileName, 'intra_subject');
end
sStudy = bst_get('Study', iStudies);

headmodel_options = struct();
headmodel_options.Comment = 'OpenMEEG BEM';
headmodel_options.HeadModelFile = bst_fullfile(ProtocolInfo.STUDIES,sSubject.Name,sStudy.Name);
% if(selected_data_set.use_raw_data)
%     headmodel_options.HeadModelFile = bst_fullfile(ProtocolInfo.STUDIES,subID, ['@raw' subID]);
% else
%     headmodel_options.HeadModelFile = bst_fullfile(ProtocolInfo.STUDIES,subID,'@intra');
% end
headmodel_options.HeadModelType = 'surface';

% Uploading Channels
BSTChannelsFile = bst_fullfile(ProtocolInfo.STUDIES,sStudy.Channel.FileName);
BSTChannels = load(BSTChannelsFile);
headmodel_options.Channel = BSTChannels.Channel;
% if(selected_data_set.use_raw_data)
%     BSTChannelsFile = bst_fullfile(ProtocolInfo.STUDIES,subID, ['@raw' subID],'channel.mat');
% else    
%     BSTChannelsFile = bst_fullfile(ProtocolInfo.STUDIES,subID, '@intra','channel.mat');
% end
% BSTChannels = load(BSTChannelsFile);
% headmodel_options.Channel = BSTChannels.Channel;

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
headmodel_options.InnerSkullFile = OuterSkullFile;

OuterSkullFile = sSubject.Surface(sSubject.iOuterSkull).FileName;
headmodel_options.OuterSkullFile =  [];
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


%%
%% Recomputing Head Model
%%
[headmodel_options, errMessage] = bst_headmodeler(headmodel_options);

if(~isempty(headmodel_options))
    ProtocolInfo = bst_get('ProtocolInfo');
    
    [sStudies, iStudies] = bst_get('StudyWithSubject', sSubject.FileName);
    if(~isempty(iStudies))
    else
        [sStudies, iStudies] = bst_get('StudyWithSubject', sSubject.FileName, 'intra_subject');
    end
    sStudy = bst_get('Study', iStudies);
%     iStudy = ProtocolInfo.iStudy;
%     sStudy = bst_get('Study', iStudy);
    % If a new head model is available
    sHeadModel = db_template('headmodel');
    sHeadModel.FileName      = file_short(headmodel_options.HeadModelFile);
    sHeadModel.Comment       = headmodel_options.Comment;
    sHeadModel.HeadModelType = headmodel_options.HeadModelType;
    % Update Study structure
    iHeadModel = length(sStudy.HeadModel) + 1;
    sStudy.HeadModel(iHeadModel) = sHeadModel;
    sStudy.iHeadModel = iHeadModel;
    sStudy.iChannel = length(sStudy.Channel);
    % Update DataBase
    bst_set('Study', iStudies, sStudy);
    db_save();
    
    %%
    %% Quality control
    %%
    ProtocolInfo = bst_get('ProtocolInfo');
    
    BSTCortexFile = bst_fullfile(ProtocolInfo.SUBJECTS, headmodel_options.CortexFile);
    cortex = load(BSTCortexFile);
    
    BSTScalpFile = bst_fullfile(ProtocolInfo.SUBJECTS, ScalpFile);
    head = load(BSTScalpFile);
    
    %%
    %% Uploading Gain matrix
    %%
    BSTHeadModelFile = bst_fullfile(headmodel_options.HeadModelFile);
    BSTHeadModel = load(BSTHeadModelFile);
    Ke = BSTHeadModel.Gain;
    
    %%
    %% Uploading Channels Loc
    %%
    BSTChannelsFile = bst_fullfile(ProtocolInfo.STUDIES,sStudy.Channel.FileName);
    BSTChannels = load(BSTChannelsFile);
    
    [BSTChannels,Ke] = remove_channels_and_leadfield_from_layout([],BSTChannels,Ke,true);
    
    channels = [];
    for i = 1: length(BSTChannels.Channel)
        Loc = BSTChannels.Channel(i).Loc;
        center = mean(Loc,2);
        channels = [channels; center(1),center(2),center(3) ];
    end
    
    %%
    %% Ploting sensors and sources on the scalp and cortex
    %%
    [hFig25] = view3D_K(Ke,cortex,head,channels,1);
    bst_report('Snapshot',hFig25,[],'Field top view', [200,200,750,475]);
    view(0,360)
    saveas( hFig25,fullfile(subject_report_path,'Field view.fig'));
    
    bst_report('Snapshot',hFig25,[],'Field right view', [200,200,750,475]);
    view(1,180)
    bst_report('Snapshot',hFig25,[],'Field left view', [200,200,750,475]);
    view(90,360)
    bst_report('Snapshot',hFig25,[],'Field front view', [200,200,750,475]);
    view(270,360)
    bst_report('Snapshot',hFig25,[],'Field back view', [200,200,750,475]);
    
    % Closing figure
    close(hFig25)
    
    processed = true;
else
    processed = false;
end
%%
%% Save and display report
%%   
ReportFile = bst_report('Save');
bst_report('Export',  ReportFile,report_name);
bst_report('Open', ReportFile);
bst_report('Close');
disp([10 '-->> BrainStorm Protocol PhilipsMFF: Done.' 10]);

