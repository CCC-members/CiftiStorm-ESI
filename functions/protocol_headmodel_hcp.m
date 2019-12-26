function protocol_headmodel_hcp(subID,ProtocolName)
% TUTORIAL_HCP: Script that reproduces the results of the online tutorial "Human Connectome Project: Resting-state MEG".
%
% CORRESPONDING ONLINE TUTORIALS:
%     https://neuroimage.usc.edu/brainstorm/Tutorials/HCP-MEG
%
% INPUTS: 
%     tutorial_dir: Directory where the HCP files have been unzipped

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
% Author: Francois Tadel, 2017
%
%
% Updaters:
% - Ariosky Areces Gonzalez
% - Deirel Paz Linares

%%
%% Preparing current subject
%%
app_properties = jsondecode(fileread(strcat('app',filesep,'app_properties.json')));
app_protocols = jsondecode(fileread(strcat('app',filesep,'app_protocols.json')));
selected_data_set = app_protocols.(strcat('x',app_properties.selected_data_set.value));


%%
%% Preparing Subject files
%%

% MRI File
[filepath,name,ext]= fileparts(selected_data_set.hcp_data_path.file_location);
filepath = strrep(filepath,'SubID',subID);
file_name = strrep(name,'SubID',subID);
T1w_file = fullfile(selected_data_set.hcp_data_path.base_path,subID,filepath,[file_name,ext]);

% Cortex Surfaces
[filepath,name,ext]= fileparts(selected_data_set.hcp_data_path.L_surface_location);
filepath = strrep(filepath,'SubID',subID);
file_name = strrep(name,'SubID',subID);
L_surface_file = fullfile(selected_data_set.hcp_data_path.base_path,subID,filepath,[file_name,ext]);

[filepath,name,ext]= fileparts(selected_data_set.hcp_data_path.R_surface_location);
filepath = strrep(filepath,'SubID',subID);
file_name = strrep(name,'SubID',subID);
R_surface_file = fullfile(selected_data_set.hcp_data_path.base_path,subID,filepath,[file_name,ext]);

[filepath,name,ext]= fileparts(selected_data_set.hcp_data_path.Atlas_seg_location);
filepath = strrep(filepath,'SubID',subID);
file_name = strrep(name,'SubID',subID);
Atlas_seg_location = fullfile(selected_data_set.hcp_data_path.base_path,subID,filepath,[file_name,ext]);

if(~isfile(T1w_file) || ~isfile(L_surface_file) || ~isfile(R_surface_file) || ~isfile(Atlas_seg_location))
    fprintf(2,strcat('\n -->> Error: The Tw1 or Cortex surfaces: \n'));
    disp(string(T1w_file));
    disp(string(L_surface_file));
    disp(string(R_surface_file));
    disp(string(Atlas_seg_location));
    fprintf(2,strcat('\n -->> Do not exist. \n'));
    fprintf(2,strcat('\n -->> Jumping to an other subject. \n'));
    return;
end

% Non-Brain surface files
[filepath,name,ext]= fileparts(selected_data_set.non_brain_data_path.head_file_location);
filepath = strrep(filepath,'SubID',subID);
file_name = strrep(name,'SubID',subID);
head_file = fullfile(selected_data_set.non_brain_data_path.base_path,subID,filepath,[file_name,ext]);

[filepath,name,ext]= fileparts(selected_data_set.non_brain_data_path.outerfile_file_location);
filepath = strrep(filepath,'SubID',subID);
file_name = strrep(name,'SubID',subID);
outerskull_file = fullfile(selected_data_set.non_brain_data_path.base_path,subID,filepath,[file_name,ext]);

[filepath,name,ext]= fileparts(selected_data_set.non_brain_data_path.innerfile_file_location);
filepath = strrep(filepath,'SubID',subID);
file_name = strrep(name,'SubID',subID);
innerskull_file = fullfile(selected_data_set.non_brain_data_path.base_path,subID,filepath,[file_name,ext]);

if(~isfile(head_file) || ~isfile(outerskull_file) || ~isfile(innerskull_file))
    fprintf(2,strcat('\n -->> Error: The Tw1 or Cortex surfaces: \n'));
    disp(string(T1w_file));
    disp(string(L_surface_file));
    disp(string(R_surface_file));
    fprintf(2,strcat('\n -->> Do not exist. \n'));
    fprintf(2,strcat('\n -->> Jumping to an other subject. \n'));
    return;
end


% MEG file
[filepath,name,ext]= fileparts(selected_data_set.meg_data_path.file_location);
filepath = strrep(filepath,'SubID',subID);
file_name = strrep(name,'SubID',subID);
MEG_file = fullfile(selected_data_set.hcp_data_path.base_path,subID,filepath,[file_name,ext]);
if(~isfile(MEG_file))
    fprintf(2,strcat('\n -->> Error: The MEG: \n'));
    disp(string(MEG_file));
    fprintf(2,strcat('\n -->> Do not exist. \n'));
    fprintf(2,strcat('\n -->> Jumping to an other subject. \n'));
    return;
end

% Transformation file
[filepath,name,ext]= fileparts(selected_data_set.meg_transformation_path.file_location);
filepath = strrep(filepath,'SubID',subID);
file_name = strrep(name,'SubID',subID);
MEG_transformation_file = fullfile(selected_data_set.meg_transformation_path.base_path,subID,filepath,[file_name,ext]);
if(~isfile(MEG_transformation_file))
    fprintf(2,strcat('\n -->> Error: The MEG tranformation file: \n'));
    disp(string(MEG_transformation_file));
    fprintf(2,strcat('\n -->> Do not exist. \n'));
    fprintf(2,strcat('\n -->> Jumping to an other subject. \n'));
    return;
end


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
report_name = fullfile(report_output_path,'Reports',ProtocolName,[subID,'.html']);
iter = 2;
while(isfile(report_name))   
   report_name = fullfile(report_output_path,'Reports',ProtocolName,[subID,'_Iter_', num2str(iter),'.html']);
   iter = iter + 1;
end

%%
%% Start a new report
%%
bst_report('Start',['Protocol for subject:' , subID]);
bst_report('Info',    '', [], ['Protocol for subject:' , subID])

%%
%% Import Anatomy
%%
% Build the path of the files to import
[sSubject, iSubject] = bst_get('Subject', subID);
% Process: Import MRI
[BstMriFile, sMri] = import_mri(iSubject, T1w_file, 'ALL-MNI', 0);

%%
%% Read Transformation
%%
bst_progress('start', 'Import HCP MEG/anatomy folder', 'Reading transformations...');
% Read file
fid = fopen(MEG_transformation_file, 'rt');
strFid = fread(fid, [1 Inf], '*char');
fclose(fid);
% Evaluate the file (.m file syntax)
eval(strFid);

%%
%% MRI=>MNI Tranformation
%%
% Convert transformations from "Brainstorm MRI" to "FieldTrip voxel"
Tbst2ft = [diag([-1, 1, 1] ./ sMri.Voxsize), [size(sMri.Cube,1); 0; 0]; 0 0 0 1];
% Set the MNI=>SCS transformation in the MRI
Tmni = transform.vox07mm2spm * Tbst2ft;
sMri.NCS.R = Tmni(1:3,1:3);
sMri.NCS.T = Tmni(1:3,4);
% Compute default fiducials positions based on MNI coordinates
sMri = mri_set_default_fid(sMri);

%%
%% MRI=>SCS TRANSFORMATION =====
%%
% Set the MRI=>SCS transformation in the MRI
Tscs = transform.vox07mm2bti * Tbst2ft;
sMri.SCS.R = Tscs(1:3,1:3);
sMri.SCS.T = Tscs(1:3,4);
% Standard positions for the SCS fiducials
NAS = [90,   0, 0] ./ 1000;
LPA = [ 0,  75, 0] ./ 1000;
RPA = [ 0, -75, 0] ./ 1000;
Origin = [0, 0, 0];
% Convert: SCS (meters) => MRI (millimeters)
sMri.SCS.NAS    = cs_convert(sMri, 'scs', 'mri', NAS) .* 1000;
sMri.SCS.LPA    = cs_convert(sMri, 'scs', 'mri', LPA) .* 1000;
sMri.SCS.RPA    = cs_convert(sMri, 'scs', 'mri', RPA) .* 1000;
sMri.SCS.Origin = cs_convert(sMri, 'scs', 'mri', Origin) .* 1000;
% Save MRI structure (with fiducials)
bst_save(BstMriFile, sMri, 'v7'); 
%%

%%
%% Quality control
%%
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
%%
%% Process: Import surfaces 
%%

nverthead = selected_data_set.process_import_surfaces.nverthead;
nvertcortex = selected_data_set.process_import_surfaces.nvertcortex;
nvertskull = selected_data_set.process_import_surfaces.nvertskull;

bst_process('CallProcess', 'script_process_import_surfaces', [], [], ...
    'subjectname', subID, ...
    'headfile',    {head_file, 'MRI-MASK-MNI'}, ...
    'cortexfile1', {L_surface_file, 'GII-MNI'}, ...
    'cortexfile2', {R_surface_file, 'GII-MNI'}, ...
    'innerfile',   {innerskull_file, 'MRI-MASK-MNI'}, ...
    'outerfile',   {outerskull_file, 'MRI-MASK-MNI'}, ...
    'nverthead',   nverthead, ...
    'nvertcortex', nvertcortex, ...
    'nvertskull',  nvertskull);

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
%% Process: Generate BEM surfaces
%%
bst_process('CallProcess', 'process_generate_bem', [], [], ...
    'subjectname', subID, ...
    'nscalp',      1922, ...
    'nouter',      1922, ...
    'ninner',      1922, ...
    'thickness',   4);

%%
%% Get subject definition and subject files
%%
sSubject       = bst_get('Subject', subID);
CortexFile     = sSubject.Surface(sSubject.iCortex).FileName;
InnerSkullFile = sSubject.Surface(sSubject.iInnerSkull).FileName;

%%
%% Forcing dipoles inside innerskull
%%
script_tess_force_envelope(CortexFile, InnerSkullFile);


%%
%% Get subject definition and subject files
%%
sSubject       = bst_get('Subject', subID);
MriFile        = sSubject.Anatomy(sSubject.iAnatomy).FileName;
CortexFile     = sSubject.Surface(sSubject.iCortex).FileName;
InnerSkullFile = sSubject.Surface(sSubject.iInnerSkull).FileName;
OuterSkullFile = sSubject.Surface(sSubject.iOuterSkull).FileName;
ScalpFile      = sSubject.Surface(sSubject.iScalp).FileName;
iCortex        = sSubject.iCortex;
iAnatomy       = sSubject.iAnatomy;
iInnerSkull    = sSubject.iInnerSkull;
iOuterSkull    = sSubject.iOuterSkull;
iScalp         = sSubject.iScalp;
%%
%% Quality Control
%%
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
%% Process: Generate SPM canonical surfaces
%%
sFiles = bst_process('CallProcess', 'process_generate_canonical', [], [], ...
    'subjectname', subID, ...
    'resolution',  2);  % 8196

%%
%% Quality control
%%
% Get subject definition and subject files
sSubject       = bst_get('Subject', subID);
ScalpFile      = sSubject.Surface(sSubject.iScalp).FileName;

%
hFigMri15 = view_mri(MriFile, ScalpFile);
bst_report('Snapshot',hFigMri15,[],'SPM Scalp Envelope - MRI registration', [200,200,750,475]);

% Close figures
close(hFigMri15);

%%
%% ===== ACCESS RECORDINGS =====
%%
% Process: Create link to raw file
sFiles = bst_process('CallProcess', 'process_import_data_raw', sFiles, [], ...
    'subjectname',    subID, ...
    'datafile',       {MEG_file, '4D'}, ...
    'channelreplace', 0, ...
    'channelalign',   1);

%%
%% Process: Set BEM Surfaces
%%
[sSubject, iSubject] = bst_get('Subject', subID);
db_surface_default(iSubject, 'Scalp', iScalp);
db_surface_default(iSubject, 'OuterSkull', iOuterSkull);
db_surface_default(iSubject, 'InnerSkull', iInnerSkull);
db_surface_default(iSubject, 'Cortex', iCortex);
%%
%% Quality control
%%
    % View sources on MRI (3D orthogonal slices)
[sSubject, iSubject] = bst_get('Subject', subID);
ScalpFile      = sSubject.Surface(sSubject.iScalp).FileName;

hFigScalp16      = script_view_surface(ScalpFile, [], [], [], 'front');
[hFigScalp16, iDS, iFig] = view_helmet(sFiles.ChannelFile, hFigScalp16);
bst_report('Snapshot',hFigScalp16,[],'Sensor-Helmet registration front view', [200,200,750,475]);

hFigScalp17      = script_view_surface(ScalpFile, [], [], [], 'left');
[hFigScalp17, iDS, iFig] = view_helmet(sFiles.ChannelFile, hFigScalp17);
bst_report('Snapshot',hFigScalp17,[],'Sensor-Helmet registration left view', [200,200,750,475]);

hFigScalp18      = script_view_surface(ScalpFile, [], [], [], 'right');
[hFigScalp18, iDS, iFig] = view_helmet(sFiles.ChannelFile, hFigScalp18);
bst_report('Snapshot',hFigScalp18,[],'Sensor-Helmet registration right view', [200,200,750,475]);

hFigScalp19      = script_view_surface(ScalpFile, [], [], [], 'back');
[hFigScalp19, iDS, iFig] = view_helmet(sFiles.ChannelFile, hFigScalp19);
bst_report('Snapshot',hFigScalp19,[],'Sensor-Helmet registration back view', [200,200,750,475]);
% Close figures
close([hFigScalp16 hFigScalp17 hFigScalp18 hFigScalp19]);

% View 4D coils on Scalp
[hFigMri20, iDS, iFig] = view_channels_3d(sFiles.ChannelFile,'4D', 'scalp', 0, 0);
view(90,360)
bst_report('Snapshot',hFigMri20,[],'4D coils-Scalp registration front view', [200,200,750,475]);

view(180,360)
bst_report('Snapshot',hFigMri20,[],'4D coils-Scalp registration left view', [200,200,750,475]);

view(0,360)
bst_report('Snapshot',hFigMri20,[],'4D coils-Scalp registration right view', [200,200,750,475]);

view(270,360)
bst_report('Snapshot',hFigMri20,[],'4D coils-Scalp registration back view', [200,200,750,475]);

% Close figures
close(hFigMri20);


% View 4D coils on Scalp
[hFigMri21, iDS, iFig] = view_channels_3d(sFiles.ChannelFile,'MEG', 'scalp');
view(90,360)
bst_report('Snapshot',hFigMri21,[],'4D coils-Scalp registration front view', [200,200,750,475]);

view(180,360)
bst_report('Snapshot',hFigMri21,[],'4D coils-Scalp registration left view', [200,200,750,475]);

view(0,360)
bst_report('Snapshot',hFigMri21,[],'4D coils-Scalp registration right view', [200,200,750,475]);

view(270,360)
bst_report('Snapshot',hFigMri21,[],'4D coils-Scalp registration back view', [200,200,750,475]);

% Close figures
close(hFigMri21);

%%
%% Process: Import Atlas
%%

[sSubject, iSubject] = bst_get('Subject', subID);

LabelFile = {Atlas_seg_location,'MRI-MASK-MNI'};
script_import_label(sSubject.Surface(sSubject.iCortex).FileName,LabelFile,0);

%%
%% Quality control 
%%
% 
CortexFile = sSubject.Surface(sSubject.iCortex).FileName;
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
ProtocolInfo = bst_get('ProtocolInfo');
% Get subject directory
[sSubject] = bst_get('Subject', subID);
subjectSubDir = bst_fileparts(sSubject.FileName);
iStudy = ProtocolInfo.iStudy;
 sStudy = bst_get('Study', iStudy);
headmodel_options = struct();
headmodel_options.Comment = 'Overlapping spheres'; %OpenMEEG BEM
headmodel_options.HeadModelFile = bst_fullfile(ProtocolInfo.STUDIES,subjectSubDir, sStudy.Name);
headmodel_options.HeadModelType = 'surface';

% Uploading Channels
BSTChannelsFile = bst_fullfile(ProtocolInfo.STUDIES,sStudy.Channel.FileName);
BSTChannels = load(BSTChannelsFile);
headmodel_options.Channel = BSTChannels.Channel;

headmodel_options.MegRefCoef = BSTChannels.MegRefCoef;
headmodel_options.MEGMethod = 'os_meg'; %openmeg
headmodel_options.EEGMethod = '';
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
headmodel_options.OuterSkullFile =  [];
headmodel_options.GridOptions = [];
headmodel_options.GridLoc  = [];
headmodel_options.GridOrient  = [];
headmodel_options.GridAtlas  = [];
headmodel_options.Interactive  = true;
headmodel_options.SaveFile  = true;

% BSTScalpFile = bst_fullfile(ProtocolInfo.SUBJECTS, ScalpFile);
% BSTOuterSkullFile = bst_fullfile(ProtocolInfo.SUBJECTS, OuterSkullFile);
% BSTInnerSkullFile = bst_fullfile(ProtocolInfo.SUBJECTS, InnerSkullFile);
% headmodel_options.BemFiles = {BSTInnerSkullFile};
% headmodel_options.BemNames = {'Brain'};
% headmodel_options.BemCond = 1;
% 
% iMeg = [];
% for i = 1: length(headmodel_options.Channel)
%     chan = headmodel_options.Channel(i);
%     if(isequal(chan.Type,'MEG'))
%      iMeg = [iMeg, i];   
%     end  
% end
% for i = 1: length(headmodel_options.Channel)
%     chan = headmodel_options.Channel(i);
%     if(isequal(chan.Type,'MEG REF'))
%      iMeg = [iMeg, i];   
%     end  
% end
% headmodel_options.iMeg = iMeg;
% headmodel_options.iEeg = [];
% headmodel_options.iEcog = [];
% headmodel_options.iSeeg = [];
% headmodel_options.BemSelect = [false,false,true];
% headmodel_options.isAdjoint = false;
% headmodel_options.isAdaptative = true;
% headmodel_options.isSplit = false;
% headmodel_options.SplitLength = 4000;


%%
%% Process Head Model
%%
[headmodel_options, errMessage] = bst_headmodeler(headmodel_options);

%%
%% Quality control 
%%

ProtocolInfo = bst_get('ProtocolInfo');
% Get subject directory
[sSubject] = bst_get('Subject', subID);
subjectSubDir = bst_fileparts(sSubject.FileName);
iStudy = ProtocolInfo.iStudy;
sStudy = bst_get('Study', iStudy);
BSTCortexFile = bst_fullfile(ProtocolInfo.SUBJECTS, CortexFile);
cortex = load(BSTCortexFile);

BSTScalpFile = bst_fullfile(ProtocolInfo.SUBJECTS, ScalpFile);
head = load(BSTScalpFile);

%%
%% Uploading Gain matrix
%%
BSTHeadModelFile = bst_fullfile(ProtocolInfo.STUDIES,subjectSubDir, sStudy.Name,'headmodel_surf_os_meg.mat');
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
[hFig25] = view3D_K(Ke,cortex,head,channels,200);
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
ReportFile = bst_report('Save', sFiles);
bst_report('Export',  ReportFile,report_name);
bst_report('Open', ReportFile);
bst_report('Close');
disp([10 '-->> BrainStorm Protocol PhilipsMFF: Done.' 10]);

