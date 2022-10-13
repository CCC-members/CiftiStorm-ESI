

clc;
clear all;
close all;


disp('-->> Starting process');

% preparing environment
addpath(fullfile('app'));
addpath(fullfile('config_protocols'));
addpath(fullfile('external'));
addpath(genpath(fullfile('functions')));
addpath(fullfile('templates'));
addpath(fullfile('tools'));

bst_path = "D:\Tools\brainstorm3";
addpath(bst_path);



% initializing params
T1w_file = 'E:\Data\CHBM\ciftify\sub-CBM00009\T1w\T1w.nii.gz';
nverthead = 8000;
nvertcortex = 8000;
nvertskull = 8000;
head_file = 'E:\Data\CHBM\non-brain\sub-CBM00009\sub-CBM00009_outskin_mesh.nii.gz';
L_surface_file = 'E:\Data\CHBM\ciftify\sub-CBM00009\T1w\fsaverage_LR32k\sub-CBM00009.L.midthickness.32k_fs_LR.surf.gii';
R_surface_file = 'E:\Data\CHBM\ciftify\sub-CBM00009\T1w\fsaverage_LR32k\sub-CBM00009.R.midthickness.32k_fs_LR.surf.gii';
innerskull_file = 'E:\Data\CHBM\non-brain\sub-CBM00009\sub-CBM00009_inskull_mesh.nii.gz';
outerskull_file = 'E:\Data\CHBM\non-brain\sub-CBM00009\sub-CBM00009_outskull_mesh.nii.gz';
L_surface_300k = 'E:\Data\CHBM\ciftify\sub-CBM00009\T1w\Native\sub-CBM00009.L.midthickness.native.surf.gii';
R_surface_300k = 'E:\Data\CHBM\ciftify\sub-CBM00009\T1w\Native\sub-CBM00009.R.midthickness.native.surf.gii';

%%
%% Starting brainstorm process
%%
brainstorm nogui local

% Creating Protocol
gui_brainstorm('DeleteProtocol','Protocol_Test');
gui_brainstorm('CreateProtocol','Protocol_Test' ,false, false);

% Add subject
subID = 'Individual_test';
db_add_subject(subID);

% Process: Import MRI
sFiles = bst_process('CallProcess', 'process_import_mri', [], [], ...
    'subjectname', subID, ...
    'mrifile',     {T1w_file, 'ALL-MNI'});

% Process: Import surfaces
sFiles = bst_process('CallProcess', 'script_process_import_surfaces', sFiles, [], ...
    'subjectname', subID, ...
    'headfile',    {head_file, 'MRI-MASK-MNI'}, ...
    'cortexfile1', {L_surface_file, 'GII-MNI'}, ...
    'cortexfile2', {R_surface_file, 'GII-MNI'}, ...
    'innerfile',   {innerskull_file, 'MRI-MASK-MNI'}, ...
    'outerfile',   {outerskull_file, 'MRI-MASK-MNI'}, ...
    'nverthead',   nverthead, ...
    'nvertcortex', nvertcortex, ...
    'nvertskull',  nvertskull);


% ===== IMPORT SURFACES 32K =====
[sSubject, iSubject] = bst_get('Subject', subID);
% Left pial
[iLh, BstTessLhFile, nVertOrigL] = import_surfaces(iSubject, L_surface_file, 'GII-MNI', 0);
BstTessLhFile = BstTessLhFile{1};
% Right pial
[iRh, BstTessRhFile, nVertOrigR] = import_surfaces(iSubject, R_surface_file, 'GII-MNI', 0);
BstTessRhFile = BstTessRhFile{1};
% Merge surfaces
tess_concatenate({BstTessLhFile, BstTessRhFile}, sprintf('cortex_%dV', nVertOrigL + nVertOrigR), 'Cortex');
% Delete original files
file_delete(file_fullpath({BstTessLhFile, BstTessRhFile}), 1);
% Reload subject
db_reload_subjects(iSubject);
db_surface_default(iSubject, 'Cortex', 2);

% ===== IMPORT SURFACES 300K =====
[sSubject, iSubject] = bst_get('Subject', subID);
% Left pial
[iLh, BstTessLhFile, nVertOrigL] = import_surfaces(iSubject, L_surface_300k, 'GII-MNI', 0);
BstTessLhFile = BstTessLhFile{1};
% Right pial
[iRh, BstTessRhFile, nVertOrigR] = import_surfaces(iSubject, R_surface_300k, 'GII-MNI', 0);
BstTessRhFile = BstTessRhFile{1};

% Merge surfaces
tess_concatenate({BstTessLhFile, BstTessRhFile}, sprintf('cortex_%dV', nVertOrigL + nVertOrigR), 'Cortex');
% Delete original files
file_delete(file_fullpath({BstTessLhFile, BstTessRhFile}), 1);
% Reload subject
db_reload_subjects(iSubject);
db_surface_default(iSubject, 'Cortex', 2);

% Merch 300K surface and 32K surface


disp("-->> Processing Finished.");

