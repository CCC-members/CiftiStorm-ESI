function tutorial_philips_mff_cmi(eeg_data_path,hcp_data_path,subID,ProtocolName)
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
subID = char(subID);
ProtocolName = char(ProtocolName);

% Start a new report
bst_report('Start');

ID = strsplit(subID,'-');
ID = ID(2);




% ===== IMPORT ANATOMY =====
% Subject name
SubjectName = char(ID);

% Build the path of the files to import
AnatDir   = char(fullfile(hcp_data_path, subID, 'T1w'));
RawFile   = char(fullfile(eeg_data_path, subID, 'EEG', 'raw', 'mff_format', SubjectName));


% Process: Import MRI
sFiles = bst_process('CallProcess', 'process_import_mri', [], [], ...
    'subjectname', SubjectName, ...
    'mrifile',     {fullfile(AnatDir,'T1w.nii.gz'), 'ALL-MNI'});

% Process: Generate head surface
bst_process('CallProcess', 'process_generate_head', [], [], ...
    'subjectname', SubjectName, ...
    'nvertices',   10000, ...
    'erodefactor', 1, ...
    'fillfactor',  2);

% % Process: Import surfaces
% L_surf = fullfile(AnatDir,'Native',strcat('P-',SubjectName,'.L.midthickness.native.surf.gii'));
% R_surf = fullfile(AnatDir,'Native',strcat('P-',SubjectName,'.R.midthickness.native.surf.gii'));
% sFiles = bst_process('CallProcess', 'process_import_surfaces', sFiles, [], ...
%     'subjectname', SubjectName, ...
%     'cortexfile1', {L_surf, 'GII-MNI'}, ...
%     'cortexfile2', {R_surf, 'GII-MNI'}, ...
%     'nvertcortex', 8000);
% 
% % Process: Generate BEM surfaces
% bst_process('CallProcess', 'process_generate_bem', [], [], ...
%     'subjectname', SubjectName, ...
%     'nscalp',      1922, ...
%     'nouter',      1922, ...
%     'ninner',      1922, ...
%     'thickness',   4);
% 
% SurfFile  = fullfile(bst_get('BrainstormDbDir'),ProtocolName,'anat',SubjectName,'tess_cortex_concat.mat');
% LabelFile = {fullfile(AnatDir,'aparc+aseg.nii.gz'),'MRI-MASK-MNI'};
% script_import_label(SurfFile,LabelFile,0);
% 
% % ===== ACCESS RECORDINGS =====
% % Process: Create link to raw file
% sFiles = bst_process('CallProcess', 'process_import_data_raw', sFiles, [], ...
%     'subjectname',    SubjectName, ...
%     'datafile',       {RawFile, 'EEG-EGI-MFF'}, ...
%     'channelreplace', 1, ...
%     'channelalign',   1);
% 
% % Process: Snapshot: Sensors/MRI registration
% bst_process('CallProcess', 'process_snapshot', sFiles, [], ...
%     'target',   1, ...  % Sensors/MRI registration
%     'modality', 4, ...  % EEG
%     'orient',   1, ...  % left
%     'comment',  'MEG/MRI Registration');
% 
% % Process: Refine registration
% sFiles = bst_process('CallProcess', 'process_headpoints_refine', sFiles, []);
% 
% % Process: Snapshot: Sensors/MRI registration
% bst_process('CallProcess', 'process_snapshot', sFiles, [], ...
%     'target',   1, ...  % Sensors/MRI registration
%     'modality', 4, ...  % EEG
%     'orient',   1, ...  % left
%     'comment',  'MEG/MRI Registration');
% 
% % Process: Refine registration
% sFiles = bst_process('CallProcess', 'process_headpoints_refine', sFiles, []);
% 
% % Process: Snapshot: Sensors/MRI registration
% bst_process('CallProcess', 'process_snapshot', sFiles, [], ...
%     'target',   1, ...  % Sensors/MRI registration
%     'modality', 4, ...  % EEG
%     'orient',   1, ...  % left
%     'comment',  'MEG/MRI Registration');
% 
% % Process: Refine registration
% sFiles = bst_process('CallProcess', 'process_headpoints_refine', sFiles, []);
% 
% 
% 
% % Process: Snapshot: Sensors/MRI registration
% bst_process('CallProcess', 'process_snapshot', sFiles, [], ...
%     'target',   1, ...  % Sensors/MRI registration
%     'modality', 4, ...  % EEG
%     'orient',   1, ...  % left
%     'comment',  'MEG/MRI Registration');
% 
% % Process: Project electrodes on scalp
% sFiles = bst_process('CallProcess', 'process_channel_project', sFiles, []);
% 
% % Process: Snapshot: Sensors/MRI registration
% bst_process('CallProcess', 'process_snapshot', sFiles, [], ...
%     'target',   1, ...  % Sensors/MRI registration
%     'modality', 4, ...  % EEG
%     'orient',   1, ...  % left
%     'comment',  'MEG/MRI Registration');
% 
% 
% % ===== HEAD MODEL: SURFACE =====
% % Process: Compute head model
% sFiles = bst_process('CallProcess', 'process_headmodel', sFiles, [], ...
%     'sourcespace', 1, ...  % Cortex surface
%     'eeg',         3, ...  % OpenMEEG BEM
%     'openmeeg',    struct(...
%          'BemSelect',    [0, 0, 1], ...
%          'BemCond',      [1, 0.0125, 1], ...
%          'BemNames',     {{'Scalp', 'Skull', 'Brain'}}, ...
%          'BemFiles',     {{}}, ...
%          'isAdjoint',    0, ...
%          'isAdaptative', 1, ...
%          'isSplit',      0, ...
%          'SplitLength',  4000));
     
     
% Save and display report
ReportFile = bst_report('Save', sFiles);
bst_report('Open', ReportFile);
disp([10 'BST> TutorialPhilipsMFF: Done.' 10]);

