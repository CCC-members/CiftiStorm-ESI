function protocol_headmodel_hbn(hcp_data_path,eeg_data_path,non_brain_data_path,subID,ProtocolName)
% TUTORIAL_PHILIPS_MFF: Script that reproduces the results of the online tutorials "Yokogawa recordings".
%
%
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



eeg_data_path = char(eeg_data_path);
hcp_data_path = char(hcp_data_path);
non_brain_path = char(non_brain_data_path);
subID = char(subID);
ProtocolName = char(ProtocolName);



ID = strsplit(subID,'-');
ID = ID(2);




% ===== IMPORT ANATOMY =====
% Subject name
SubjectName = char(ID);

% Start a new report
bst_report('Start',['Protocol for subject:' , SubjectName]);
bst_report('Info',    '', [], ['Protocol for subject:' , SubjectName])

% Build the path of the files to import
SubjectDir = char(fullfile(hcp_data_path,subID));
AnatDir    = char(fullfile(hcp_data_path, subID, 'T1w'));
RawFile    = char(fullfile(eeg_data_path, subID, 'EEG', 'raw', 'mff_format', SubjectName));



% Process: Import MRI
sFiles = bst_process('CallProcess', 'process_import_mri', [], [], ...
    'subjectname', SubjectName, ...
    'mrifile',     {fullfile(AnatDir,'T1w.nii.gz'), 'ALL-MNI'});

%% Quality control
%%
% Get subject definition
sSubject = bst_get('Subject', SubjectName);
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
% Process: Import surfaces
sFiles = bst_process('CallProcess', 'script_process_import_surfaces', sFiles, [], ...
    'subjectname', SubjectName, ...
    'headfile',    {fullfile(SubjectDir,'Non_Brain',['P-',SubjectName,'_outskin_mesh.nii.gz']), 'MRI-MASK-MNI'}, ...
    'cortexfile1', {fullfile(AnatDir,'fsaverage_LR32k',['P-',SubjectName,'.L.midthickness.32k_fs_LR.surf.gii']), 'GII-MNI'}, ...
    'cortexfile2', {fullfile(AnatDir,'fsaverage_LR32k',['P-',SubjectName,'.R.midthickness.32k_fs_LR.surf.gii']), 'GII-MNI'}, ...
    'innerfile',   {fullfile(SubjectDir,'Non_Brain',['P-',SubjectName,'_inskull_mesh.nii.gz']), 'MRI-MASK-MNI'}, ...
    'outerfile',   {fullfile(SubjectDir,'Non_Brain',['P-',SubjectName,'_outskull_mesh.nii.gz']), 'MRI-MASK-MNI'}, ...
    'nverthead',   7000, ...
    'nvertcortex', 8000, ...
    'nvertskull',  7000);

%% Quality control
%%
% Get subject definition and subject files
sSubject       = bst_get('Subject', SubjectName);
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
%%
% Process: Generate BEM surfaces
bst_process('CallProcess', 'process_generate_bem', [], [], ...
    'subjectname', SubjectName, ...
    'nscalp',      1922, ...
    'nouter',      1922, ...
    'ninner',      1922, ...
    'thickness',   4);

%% Quality Control
%%
% Get subject definition and subject files
sSubject       = bst_get('Subject', SubjectName);
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
%%
% Process: Generate SPM canonical surfaces
sFiles = bst_process('CallProcess', 'process_generate_canonical', sFiles, [], ...
    'subjectname', SubjectName, ...
    'resolution',  2);  % 8196

%% Quality control
%%
% Get subject definition and subject files
sSubject       = bst_get('Subject', SubjectName);
ScalpFile      = sSubject.Surface(sSubject.iScalp).FileName;

%
hFigMri15 = view_mri(MriFile, ScalpFile);
bst_report('Snapshot',hFigMri15,[],'SPM Scalp Envelope - MRI registration', [200,200,750,475]);

% Close figures
close(hFigMri15);
%%
%%
% ===== ACCESS RECORDINGS =====
% Process: Create link to raw file
sFiles = bst_process('CallProcess', 'process_import_data_raw', sFiles, [], ...
    'subjectname',    SubjectName, ...
    'datafile',       {RawFile, 'EEG-EGI-MFF'}, ...
    'channelreplace', 0, ...
    'channelalign',   0);

% Process: Set channel file%
sFiles = bst_process('CallProcess', 'process_import_channel', sFiles, [], ...
    'usedefault',   32, ...  % NotAligned: GSN HydroCel 129 E001 (32) / GSN 129 (26)
    'channelalign', 1, ...
    'fixunits',     1, ...
    'vox2ras',      1);

% Process: Set BEM Surfaces
[sSubject, iSubject] = bst_get('Subject', SubjectName);
db_surface_default(iSubject, 'Scalp', 5);
db_surface_default(iSubject, 'OuterSkull', 6);
db_surface_default(iSubject, 'InnerSkull', 7);
db_surface_default(iSubject, 'Cortex', 1);

% Process: Project electrodes on scalp
sFiles = bst_process('CallProcess', 'process_channel_project', sFiles, []);

%% Quality control
%%
% View sources on MRI (3D orthogonal slices)
[sSubject, iSubject] = bst_get('Subject', SubjectName);
MriFile        = sSubject.Anatomy(sSubject.iAnatomy).FileName;

hFigMri16      = script_view_mri_3d(MriFile, [], [], [], 'front');
hFigMri16      = view_channels(sFiles.ChannelFile, 'EEG', 1, 0, hFigMri16, 1);
bst_report('Snapshot',hFigMri16,[],'Sensor-MRI registration front view', [200,200,750,475]);

hFigMri17      = script_view_mri_3d(MriFile, [], [], [], 'left');
hFigMri17      = view_channels(sFiles.ChannelFile, 'EEG', 1, 0, hFigMri17, 1);
bst_report('Snapshot',hFigMri17,[],'Sensor-MRI registration left view', [200,200,750,475]);

hFigMri18      = script_view_mri_3d(MriFile, [], [], [], 'right');
hFigMri18      = view_channels(sFiles.ChannelFile, 'EEG', 1, 0, hFigMri18, 1);
bst_report('Snapshot',hFigMri18,[],'Sensor-MRI registration right view', [200,200,750,475]);

hFigMri19      = script_view_mri_3d(MriFile, [], [], [], 'back');
hFigMri19      = view_channels(sFiles.ChannelFile, 'EEG', 1, 0, hFigMri19, 1);
bst_report('Snapshot',hFigMri19,[],'Sensor-MRI registration back view', [200,200,750,475]);

% View sources on Scalp
[sSubject, iSubject] = bst_get('Subject', SubjectName);
MriFile        = sSubject.Anatomy(sSubject.iAnatomy).FileName;
ScalpFile      = sSubject.Surface(sSubject.iScalp).FileName;

hFigMri20      = script_view_surface(ScalpFile, [], [], [],'front');
hFigMri20      = view_channels(sFiles.ChannelFile, 'EEG', 1, 0, hFigMri20, 1);
bst_report('Snapshot',hFigMri20,[],'Sensor-Scalp registration front view', [200,200,750,475]);

hFigMri21      = script_view_surface(ScalpFile, [], [], [],'left');
hFigMri21      = view_channels(sFiles.ChannelFile, 'EEG', 1, 0, hFigMri21, 1);
bst_report('Snapshot',hFigMri21,[],'Sensor-Scalp registration left view', [200,200,750,475]);

hFigMri22      = script_view_surface(ScalpFile, [], [], [],'right');
hFigMri22      = view_channels(sFiles.ChannelFile, 'EEG', 1, 0, hFigMri22, 1);
bst_report('Snapshot',hFigMri22,[],'Sensor-Scalp registration right view', [200,200,750,475]);

hFigMri23      = script_view_surface(ScalpFile, [], [], [],'back');
hFigMri23      = view_channels(sFiles.ChannelFile, 'EEG', 1, 0, hFigMri23, 1);
bst_report('Snapshot',hFigMri23,[],'Sensor-Scalp registration back view', [200,200,750,475]);

% Close figures
close([hFigMri16 hFigMri17 hFigMri18 hFigMri19 hFigMri20 hFigMri21 hFigMri22 hFigMri23]);
%%
[sSubject, iSubject] = bst_get('Subject', SubjectName);
% Process: Import Atlas
LabelFile = {fullfile(AnatDir,'aparc+aseg.nii.gz'),'MRI-MASK-MNI'};
script_import_label(sSubject.Surface(sSubject.iCortex).FileName,LabelFile,0);

%% Quality control 
%%
% 
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
% ===== HEAD MODEL: SURFACE =====
% Process: Compute head model
sFiles = bst_process('CallProcess', 'process_headmodel', sFiles, [], ...
    'sourcespace', 1, ...  % Cortex surface
    'eeg',         3, ...  % OpenMEEG BEM
    'openmeeg',    struct(...
         'BemSelect',    [0, 0, 1], ...
         'BemCond',      [1, 0.0125, 1], ...
         'BemNames',     {{'Scalp', 'Skull', 'Brain'}}, ...
         'BemFiles',     {{}}, ...
         'isAdjoint',    0, ...
         'isAdaptative', 1, ...
         'isSplit',      0, ...
         'SplitLength',  4000));


[sSubject, iSubject] = bst_get('Subject', SubjectName);


%% Export Subject to BC-VARETA
% export_subject_BCV(sSubject);



% Save and display report
ReportFile = bst_report('Save', sFiles);
bst_report('Export',  ReportFile, ['D:\\Reports\\Report_',SubjectName,'.html']);
bst_report('Open', ReportFile);
disp([10 'BST> TutorialPhilipsMFF: Done.' 10]);

