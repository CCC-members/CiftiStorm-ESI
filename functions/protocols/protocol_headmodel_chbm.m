function [processed] = protocol_headmodel_chbm()
% TUTORIAL: Script that reproduces the results of the online tutorials.
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
%%
% Updaters:
% - Ariosky Areces Gonzalez
% - Deirel Paz Linares
%%


%%
%% Preparing selected protocol
%%
load('tools/mycolormap');

app_properties = jsondecode(fileread(strcat('app',filesep,'app_properties.json')));
selected_data_set = jsondecode(fileread(strcat('config_protocols',filesep,app_properties.selected_data_set.file_name)));

if(is_check_dataset_properties(selected_data_set))
    disp(strcat('-->> Data Source:  ', selected_data_set.hcp_data_path.base_path ));
    ProtocolName = selected_data_set.protocol_name;
    [base_path,name,ext] = fileparts(selected_data_set.hcp_data_path.base_path);
    subjects = dir(base_path);
    subjects(ismember( {subjects.name}, {'.', '..'})) = [];  %remove . and ..
    subjects_process_error = [];
    subjects_processed =[];
    Protocol_count = 0;
    for j=1:size(subjects,1)
        subject_name = subjects(j).name;
        subID = subject_name;
        if(~isequal(selected_data_set.sub_prefix,'none') && ~isempty(selected_data_set.sub_prefix))
            subID = strrep(subject_name,selected_data_set.sub_prefix,'');
        end
        
        disp(strcat('-->> Processing subject: ', subID));
        %%
        %% Preparing Subject files
        %%
        
        % MRI File
        base_path =  strrep(selected_data_set.hcp_data_path.base_path,'SubID',subID);
        filepath = strrep(selected_data_set.hcp_data_path.file_location,'SubID',subID);
        T1w_file = fullfile(base_path,filepath);
        
        % Cortex Surfaces
        filepath = strrep(selected_data_set.hcp_data_path.L_surface_location,'SubID',subID);
        L_surface_file = fullfile(base_path,filepath);
        
        filepath = strrep(selected_data_set.hcp_data_path.R_surface_location,'SubID',subID);
        R_surface_file = fullfile(base_path,filepath);
        
        filepath = strrep(selected_data_set.hcp_data_path.Atlas_seg_location,'SubID',subID);
        Atlas_seg_location = fullfile(base_path,filepath);
        
        if(~isfile(T1w_file) || ~isfile(L_surface_file) || ~isfile(R_surface_file) || ~isfile(Atlas_seg_location))
            fprintf(2,strcat('\n -->> Error: The Tw1 or Cortex surfaces: \n'));
            disp(string(T1w_file));
            disp(string(L_surface_file));
            disp(string(R_surface_file));
            disp(string(Atlas_seg_location));
            fprintf(2,strcat('\n -->> Do not exist. \n'));
            fprintf(2,strcat('\n -->> Jumping to an other subject. \n'));
            processed = false;
            continue;
        end
        
        % Non-Brain surface files
        base_path =  strrep(selected_data_set.non_brain_data_path.base_path,'SubID',subID);
        filepath = strrep(selected_data_set.non_brain_data_path.head_file_location,'SubID',subID);
        head_file = fullfile(base_path,filepath);
        
        %         filepath =  strrep(selected_data_set.non_brain_data_path.outerfile_file_location,'SubID',subID);
        %         outerskull_file = fullfile(base_path,filepath);
        %
        %         filepath = strrep(selected_data_set.non_brain_data_path.innerfile_file_location,'SubID',subID);
        %         innerskull_file = fullfile(base_path,filepath);
        
        %         if(~isfile(head_file) || ~isfile(outerskull_file) || ~isfile(innerskull_file))
        if(~isfile(head_file))
            fprintf(2,strcat('\n -->> Error: The Non-brain surfaces: \n'));
            disp(string(head_file));
            %             disp(string(L_surface_file));
            %             disp(string(R_surface_file));
            fprintf(2,strcat('\n -->> Do not exist. \n'));
            fprintf(2,strcat('\n -->> Jumping to an other subject. \n'));
            processed = false;
            continue;
        end
        
        %%
        %%  Checking protocol
        %%
        if( mod(Protocol_count,selected_data_set.protocol_subjet_count) == 0  )
            ProtocolName_R = strcat(ProtocolName,'_',char(num2str(Protocol_count)));
            
            if(selected_data_set.protocol_reset)
                gui_brainstorm('DeleteProtocol',ProtocolName_R);
                bst_db_path = bst_get('BrainstormDbDir');
                if(isfolder(fullfile(bst_db_path,ProtocolName_R)))
                    protocol_folder = fullfile(bst_db_path,ProtocolName_R);
                    rmdir(protocol_folder, 's');
                end
                gui_brainstorm('CreateProtocol',ProtocolName_R ,selected_data_set.use_default_anatomy, selected_data_set.use_default_channel);
            else
                %                 gui_brainstorm('UpdateProtocolsList');
                iProtocol = bst_get('Protocol', ProtocolName_R);
                gui_brainstorm('SetCurrentProtocol', iProtocol);
                subjects = bst_get('ProtocolSubjects');
                if(j <= length(subjects.Subject))
                    db_delete_subjects( j );
                end
            end
        end
        
        try
            %%
            %% Creating subject in Protocol
            %%
            db_add_subject(subID);
            
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
            %% Preparing eviroment
            %%
            % ===== GET DEFAULT =====
            % Get registered Brainstorm EEG defaults
            bstDefaults = bst_get('EegDefaults');
            nameGroup = selected_data_set.process_import_channel.group_layout_name;
            nameLayout = selected_data_set.process_import_channel.channel_layout_name;
            
            iGroup = find(strcmpi(nameGroup, {bstDefaults.name}));
            iLayout = strcmpi(nameLayout, {bstDefaults(iGroup).contents.name});
            ChannelFile = bstDefaults(iGroup).contents(iLayout).fullpath;
            channel_layout= load(ChannelFile);
            
            %% reduce channel by preprocessed eeg or user labels
            [ChannelFile] = reduce_channel_BY_prep_eeg_OR_user_labels(selected_data_set,channel_layout,ChannelFile,subID);
            
            %%
            %% ===== IMPORT ANATOMY =====
            %%
            % Start a new report
            bst_report('Start',['Protocol for subject:' , subID]);
            bst_report('Info',    '', [], ['Protocol for subject:' , subID]);
            
            %%
            %% Process: Import MRI
            %%
            sFiles = bst_process('CallProcess', 'process_import_mri', [], [], ...
                'subjectname', subID, ...
                'mrifile',     {T1w_file, 'ALL-MNI'});
            
            %%
            %% Quality control
            %%
            % Get subject definition
            sSubject = bst_get('Subject', subID);
            % [sStudies, iStudies] = bst_get('StudyWithSubject', sSubject.FileName);
            % if(~isempty(iStudies))
            % else
            % [sStudies, iStudies] = bst_get('StudyWithSubject', sSubject.FileName, 'intra_subject');
            % end
            % Get MRI file and surface files
            
            MriFile    = sSubject.Anatomy(sSubject.iAnatomy).FileName;
            hFigMri1 = view_mri_slices(MriFile, 'x', 20);
            bst_report('Snapshot',hFigMri1,MriFile,'MRI Axial view', [200,200,750,475]);
            savefig( hFigMri1,fullfile(subject_report_path,'MRI Axial view.fig'));
            close(hFigMri1);
            
            hFigMri2 = view_mri_slices(MriFile, 'y', 20);
            bst_report('Snapshot',hFigMri2,MriFile,'MRI Coronal view', [200,200,750,475]);
            savefig( hFigMri2,fullfile(subject_report_path,'MRI Coronal view.fig'));
            close(hFigMri2);
            
            hFigMri3 = view_mri_slices(MriFile, 'z', 20);
            bst_report('Snapshot',hFigMri3,MriFile,'MRI Sagital view', [200,200,750,475]);
            savefig( hFigMri3,fullfile(subject_report_path,'MRI Sagital view.fig'));
            close(hFigMri3);
            
            %%
            %% Process: Import surfaces
            %%
            nverthead = selected_data_set.process_import_surfaces.nverthead;
            nvertcortex = selected_data_set.process_import_surfaces.nvertcortex;
            nvertskull = selected_data_set.process_import_surfaces.nvertskull;
            
            sFiles = bst_process('CallProcess', 'script_process_import_surfaces', sFiles, [], ...
                'subjectname', subID, ...
                'headfile',    {head_file, 'MRI-MASK-MNI'}, ...
                'cortexfile1', {L_surface_file, 'GII-MNI'}, ...
                'cortexfile2', {R_surface_file, 'GII-MNI'}, ...
                'nverthead',   nverthead, ...
                'nvertcortex', nvertcortex, ...
                'nvertskull',  nvertskull);
            %                 'innerfile',   {innerskull_file, 'MRI-MASK-MNI'}, ...
            %                 'outerfile',   {outerskull_file, 'MRI-MASK-MNI'}, ...
            
            
            %% ===== IMPORT SURFACES 32K =====
            [sSubject, iSubject] = bst_get('Subject', subID);
            % Left pial
            [iLh, BstTessLhFile, nVertOrigL] = import_surfaces(iSubject, L_surface_file, 'GII-MNI', 0);
            BstTessLhFile = BstTessLhFile{1};
            % Right pial
            [iRh, BstTessRhFile, nVertOrigR] = import_surfaces(iSubject, R_surface_file, 'GII-MNI', 0);
            BstTessRhFile = BstTessRhFile{1};
            
            %% ===== MERGE SURFACES =====
            % Merge surfaces
            tess_concatenate({BstTessLhFile, BstTessRhFile}, sprintf('cortex_%dV', nVertOrigL + nVertOrigR), 'Cortex');
            % Delete original files
            file_delete(file_fullpath({BstTessLhFile, BstTessRhFile}), 1);
            % Reload subject
            db_reload_subjects(iSubject);
            db_surface_default(iSubject, 'Cortex', 2);
            %%
            %% Quality control
            %%
            % Get subject definition and subject files
            sSubject       = bst_get('Subject', subID);
            MriFile        = sSubject.Anatomy(sSubject.iAnatomy).FileName;
            CortexFile     = sSubject.Surface(sSubject.iCortex).FileName;
            %             InnerSkullFile = sSubject.Surface(sSubject.iInnerSkull).FileName;
            %             OuterSkullFile = sSubject.Surface(sSubject.iOuterSkull).FileName;
            ScalpFile      = sSubject.Surface(sSubject.iScalp).FileName;
            
            %
            
            hFigMriSurf = view_mri(MriFile, CortexFile);
            
            hFigMri4  = script_view_contactsheet( hFigMriSurf, 'volume', 'x','');
            bst_report('Snapshot',hFigMri4,MriFile,'Cortex - MRI registration Axial view', [200,200,750,475]);
            savefig( hFigMri4,fullfile(subject_report_path,'Cortex - MRI registration Axial view.fig'));
            close(hFigMri4);
            %
            hFigMri5  = script_view_contactsheet( hFigMriSurf, 'volume', 'y','');
            bst_report('Snapshot',hFigMri5,MriFile,'Cortex - MRI registration Coronal view', [200,200,750,475]);
            savefig( hFigMri5,fullfile(subject_report_path,'Cortex - MRI registration Coronal view.fig'));
            close(hFigMri5);
            %
            hFigMri6  = script_view_contactsheet( hFigMriSurf, 'volume', 'z','');
            bst_report('Snapshot',hFigMri6,MriFile,'Cortex - MRI registration Sagital view', [200,200,750,475]);
            savefig( hFigMri6,fullfile(subject_report_path,'Cortex - MRI registration Sagital view.fig'));
            % Closing figures
            close([hFigMri6,hFigMriSurf]);
            
            %
            hFigMri7 = view_mri(MriFile, ScalpFile);
            bst_report('Snapshot',hFigMri7,MriFile,'Scalp registration', [200,200,750,475]);
            savefig( hFigMri7,fullfile(subject_report_path,'Scalp registration.fig'));
            close(hFigMri7);
            %
            %             hFigMri8 = view_mri(MriFile, OuterSkullFile);
            %             bst_report('Snapshot',hFigMri8,MriFile,'Outer Skull - MRI registration', [200,200,750,475]);
            %             savefig( hFigMri8,fullfile(subject_report_path,'Outer Skull - MRI registration.fig'));
            %             close(hFigMri8);
            %             %
            %             hFigMri9 = view_mri(MriFile, InnerSkullFile);
            %             bst_report('Snapshot',hFigMri9,MriFile,'Inner Skull - MRI registration', [200,200,750,475]);
            %             savefig( hFigMri9,fullfile(subject_report_path,'Inner Skull - MRI registration.fig'));
            %             % Closing figures
            %             close(hFigMri9);
            
            %
            hFigSurf10 = view_surface(CortexFile);
            bst_report('Snapshot',hFigSurf10,[],'Cortex mesh 3D top view', [200,200,750,475]);
            savefig( hFigSurf10,fullfile(subject_report_path,'Cortex mesh 3D view.fig'));
            % Bottom
            view(90,270)
            bst_report('Snapshot',hFigSurf10,[],'Cortex mesh 3D bottom view', [200,200,750,475]);
            %Left
            view(1,180)
            bst_report('Snapshot',hFigSurf10,[],'Cortex mesh 3D left hemisphere view', [200,200,750,475]);
            % Rigth
            view(0,360)
            bst_report('Snapshot',hFigSurf10,[],'Cortex mesh 3D right hemisphere view', [200,200,750,475]);
            
            % Closing figure
            close(hFigSurf10);
            
            %%
            %% Process: Generate BEM surfaces
            %%
            bst_process('CallProcess', 'process_generate_bem', [], [], ...
                'subjectname', subID, ...
                'nscalp',      3242, ...
                'nouter',      3242, ...
                'ninner',      3242, ...
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
            %             [iIS, BstTessISFile, nVertOrigR] = import_surfaces(iSubject, innerskull_file, 'MRI-MASK-MNI', 1);
            %             BstTessISFile = BstTessISFile{1};
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
            %% Quality control
            %%
            
            hFigSurf11 = script_view_surface(CortexFile, [], [], [],'top');
            hFigSurf11 = script_view_surface(InnerSkullFile, [], [], hFigSurf11);
            hFigSurf11 = script_view_surface(OuterSkullFile, [], [], hFigSurf11);
            hFigSurf11 = script_view_surface(ScalpFile, [], [], hFigSurf11);
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
            sFiles = bst_process('CallProcess', 'process_generate_canonical', sFiles, [], ...
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
            savefig( hFigMri15,fullfile(subject_report_path,'SPM Scalp Envelope - MRI registration.fig'));
            % Close figures
            close(hFigMri15);
            
            %%
            %% ===== ACCESS RECORDINGS =====
            %%
            FileFormat = 'BST';
            
            %%
            %% See Description for -->> import_channel(iStudies, ChannelFile, FileFormat, ChannelReplace,
            % ChannelAlign, isSave, isFixUnits, isApplyVox2ras)
            %%
            sSubject = bst_get('Subject', subID);
            [sStudies, iStudies] = bst_get('StudyWithSubject', sSubject.FileName);
            if(~isempty(iStudies))
            else
                [sStudies, iStudies] = bst_get('StudyWithSubject', sSubject.FileName, 'intra_subject');
            end
            
            [Output, ChannelFile, FileFormat] = import_channel(iStudies, ChannelFile, FileFormat, 2, 2, 1, 1, 1);
            
            %%
            %% Process: Set BEM Surfaces
            %%
            [sSubject, iSubject] = bst_get('Subject', subID);
            db_surface_default(iSubject, 'Scalp', iScalp);
            db_surface_default(iSubject, 'OuterSkull', iOuterSkull);
            db_surface_default(iSubject, 'InnerSkull', iInnerSkull);
            db_surface_default(iSubject, 'Cortex', iCortex);
            
            %%
            %% Project electrodes on the scalp surface.
            %%
            % Get Protocol information
            ProtocolInfo = bst_get('ProtocolInfo');
            % Get subject directory
            [sSubject] = bst_get('Subject', subID);
            sStudy = bst_get('Study', iStudies);
            
            ScalpFile      = sSubject.Surface(sSubject.iScalp).FileName;
            BSTScalpFile = bst_fullfile(ProtocolInfo.SUBJECTS, ScalpFile);
            head = load(BSTScalpFile);
            
            BSTChannelsFile = bst_fullfile(ProtocolInfo.STUDIES,sStudy.Channel.FileName);
            BSTChannels = load(BSTChannelsFile);
            channels = [BSTChannels.Channel.Loc];
            channels = channels';
            channels = channel_project_scalp(head.Vertices, channels);
            
            % Report projections in original structure
            for iChan = 1:length(channels)
                BSTChannels.Channel(iChan).Loc = channels(iChan,:)';
            end
            % Save modifications in channel file
            bst_save(file_fullpath(BSTChannelsFile), BSTChannels, 'v7');
            
            %%
            %% Quality control
            %%
            % View sources on MRI (3D orthogonal slices)
            [sSubject, iSubject] = bst_get('Subject', subID);
            
            MriFile        = sSubject.Anatomy(sSubject.iAnatomy).FileName;
            
            hFigMri16      = script_view_mri_3d(MriFile, [], [], [], 'front');
            hFigMri16      = view_channels(ChannelFile, 'EEG', 1, 0, hFigMri16, 1);
            bst_report('Snapshot',hFigMri16,[],'Sensor-MRI registration front view', [200,200,750,475]);
            savefig( hFigMri16,fullfile(subject_report_path,'Sensor-MRI registration front view.fig'));
            %Left
            view(1,180)
            bst_report('Snapshot',hFigMri16,[],'Sensor-MRI registration left view', [200,200,750,475]);
            % Right
            view(0,360)
            bst_report('Snapshot',hFigMri16,[],'Sensor-MRI registration right view', [200,200,750,475]);
            % Back
            view(90,360)
            bst_report('Snapshot',hFigMri16,[],'Sensor-MRI registration back view', [200,200,750,475]);
            % Close figures
            close(hFigMri16);
            
            % View sources on Scalp
            [sSubject, iSubject] = bst_get('Subject', subID);
            
            MriFile        = sSubject.Anatomy(sSubject.iAnatomy).FileName;
            ScalpFile      = sSubject.Surface(sSubject.iScalp).FileName;
            
            hFigMri20      = script_view_surface(ScalpFile, [], [], [],'front');
            hFigMri20      = view_channels(ChannelFile, 'EEG', 1, 0, hFigMri20, 1);
            bst_report('Snapshot',hFigMri20,[],'Sensor-Scalp registration front view', [200,200,750,475]);
            savefig( hFigMri20,fullfile(subject_report_path,'Sensor-Scalp registration front view.fig'));
            %Left
            view(1,180)
            bst_report('Snapshot',hFigMri20,[],'Sensor-Scalp registration left view', [200,200,750,475]);
            % Right
            view(0,360)
            bst_report('Snapshot',hFigMri20,[],'Sensor-Scalp registration right view', [200,200,750,475]);
            % Back
            view(90,360)
            bst_report('Snapshot',hFigMri20,[],'Sensor-Scalp registration back view', [200,200,750,475]);
            % Close figures
            close(hFigMri20);
            
            %%
            %% Process: Import Atlas
            %%
            [sSubject, iSubject] = bst_get('Subject', subID);
            %
            LabelFile = {Atlas_seg_location,'MRI-MASK-MNI'};
            script_import_label(sSubject.Surface(sSubject.iCortex).FileName,LabelFile,0);
            
            %%
            %% Quality control
            %%
            %
            hFigSurf24 = view_surface(CortexFile);
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
            %% Get Protocol information
            %%
            ProtocolInfo = bst_get('ProtocolInfo');
            % Get subject directory
            [sSubject] = bst_get('Subject', subID);
            
            headmodel_options = struct();
            headmodel_options.Comment = 'OpenMEEG BEM';
            headmodel_options.HeadModelFile = bst_fullfile(ProtocolInfo.STUDIES,sSubject.Name,sStudy.Name);
            headmodel_options.HeadModelType = 'surface';
            
            % Uploading Channels
            BSTChannelsFile = bst_fullfile(ProtocolInfo.STUDIES,sStudy.Channel.FileName);
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
            
            %%
            %% Process: OpenMEEG
            %%
            [headmodel_options, errMessage] = bst_headmodeler(headmodel_options);
            
            if(~isempty(headmodel_options))
                sStudy = bst_get('Study', iStudies);
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
                
                head = load(BSTScalpFile);
                
                % Uploading Gain matrix
                BSTHeadModelFile = bst_fullfile(headmodel_options.HeadModelFile);
                BSTHeadModel = load(BSTHeadModelFile);
                Ke = BSTHeadModel.Gain;
                
                % Uploading Channels Loc
                channels = [headmodel_options.Channel.Loc];
                channels = channels';
                
                %%
                %% Checking LF correlation
                %%
                [Ne,Nv]=size(Ke);
                Nv= Nv/3;
                VoxelCoord=cortex.Vertices;
                VertNorms=cortex.VertNormals;
                
                %computing homogeneous lead field
                [Kn,Khom]   = computeNunezLF(Ke,VoxelCoord, channels);
                
                %%
                %% Ploting sensors and sources on the scalp and cortex
                %%
                [hFig25] = view3D_K(Kn,cortex,head,channels,17);
                bst_report('Snapshot',hFig25,[],'Field top view', [200,200,750,475]);
                view(0,360)
                savefig( hFig25,fullfile(subject_report_path,'Field view.fig'));
                
                bst_report('Snapshot',hFig25,[],'Field right view', [200,200,750,475]);
                view(1,180)
                bst_report('Snapshot',hFig25,[],'Field left view', [200,200,750,475]);
                view(90,360)
                bst_report('Snapshot',hFig25,[],'Field front view', [200,200,750,475]);
                view(270,360)
                bst_report('Snapshot',hFig25,[],'Field back view', [200,200,750,475]);
                % Closing figure
                close(hFig25);
                
                
                [hFig26]    = view3D_K(Khom,cortex,head,channels,17);
                bst_report('Snapshot',hFig26,[],'Homogenous field top view', [200,200,750,475]);
                view(0,360)
                savefig( hFig26,fullfile(subject_report_path,'Homogenous field view.fig'));
                
                bst_report('Snapshot',hFig26,[],'Homogenous field right view', [200,200,750,475]);
                view(1,180)
                bst_report('Snapshot',hFig26,[],'Homogenous field left view', [200,200,750,475]);
                view(90,360)
                bst_report('Snapshot',hFig26,[],'Homogenous field front view', [200,200,750,475]);
                view(270,360)
                bst_report('Snapshot',hFig26,[],'Homogenous field back view', [200,200,750,475]);
                % Closing figure
                close(hFig26);
                
                VertNorms   = reshape(VertNorms,[1,Nv,3]);
                VertNorms   = repmat(VertNorms,[Ne,1,1]);
                Kn          = sum(Kn.*VertNorms,3);
                Khom        = sum(Khom.*VertNorms,3);
                
                
                %Homogenous Lead Field vs. Tester Lead Field Plot
                hFig27 = figure;
                scatter(Khom(:),Kn(:));
                title('Homogenous Lead Field vs. Tester Lead Field');
                xlabel('Homogenous Lead Field');
                ylabel('Tester Lead Field');
                bst_report('Snapshot',hFig27,[],'Homogenous Lead Field vs. Tester Lead Field', [200,200,750,475]);
                savefig( hFig27,fullfile(subject_report_path,'Homogenous Lead Field vs. Tester Lead Field.fig'));
                % Closing figure
                close(hFig27);
                
                %computing channel-wise correlation
                for k=1:size(Kn,1)
                    corelch(k,1)=corr(Khom(k,:).',Kn(k,:).');
                end
                %plotting channel wise correlation
                hFig28 = figure;
                plot([1:size(Kn,1)],corelch,[1:size(Kn,1)],0.7,'r-');
                xlabel('Channels');
                ylabel('Correlation');
                title('Correlation between both lead fields channel-wise');
                bst_report('Snapshot',hFig28,[],'Correlation between both lead fields channel-wise', [200,200,750,475]);
                savefig( hFig28,fullfile(subject_report_path,'Correlation channel-wise.fig'));
                % Closing figure
                close(hFig28);
                
                zKhom = zscore(Khom')';
                zK = zscore(Kn')';
                %computing voxel-wise correlation
                for k=1:Nv
                    corelv(k,1)=corr(zKhom(:,k),zK(:,k));
                end
                corelv(isnan(corelv))=0;
                corr2d = corr2(Khom, Kn);
                %plotting voxel wise correlation
                hFig29 = figure;
                plot([1:Nv],corelv);
                title('Correlation both lead fields Voxel wise');
                % Including to report
                bst_report('Snapshot',hFig29,[],'Correlation both lead fields Voxel wise', [200,200,750,475]);
                savefig( hFig29,fullfile(subject_report_path,'Correlation Voxel wise.fig'));
                close(hFig29);
                
                %%
                %% Finding points of low corelation
                %%
                low_cor_inds = find(corelv < .3);
                BSTCortexFile = bst_fullfile(ProtocolInfo.SUBJECTS, headmodel_options.CortexFile);
                hFig_low_cor = view_surface(BSTCortexFile, [], [], 'NewFigure');
                hFig_low_cor = view_surface(BSTCortexFile, [], [], hFig_low_cor);
                % Delete scouts
                delete(findobj(hFig_low_cor, 'Tag', 'ScoutLabel'));
                delete(findobj(hFig_low_cor, 'Tag', 'ScoutMarker'));
                delete(findobj(hFig_low_cor, 'Tag', 'ScoutPatch'));
                delete(findobj(hFig_low_cor, 'Tag', 'ScoutContour'));
                
                line(cortex.Vertices(low_cor_inds,1), cortex.Vertices(low_cor_inds,2), cortex.Vertices(low_cor_inds,3), 'LineStyle', 'none', 'Marker', 'o',  'MarkerFaceColor', [1 0 0], 'MarkerSize', 6);
                figure_3d('SetStandardView', hFig_low_cor, 'bottom');
                bst_report('Snapshot',hFig_low_cor,[],'Low correlation Voxel', [200,200,750,475]);
                savefig( hFig_low_cor,fullfile(subject_report_path,'Low correlation Voxel.fig'));
                close(hFig_low_cor);
                
                figure_cor = figure;
                %colormap(gca,cmap);
                patch('Faces',cortex.Faces,'Vertices',cortex.Vertices,'FaceVertexCData',corelv,'FaceColor','interp','EdgeColor','none','FaceAlpha',.99);
                view(90,270)
                bst_report('Snapshot',figure_cor,[],'Low correlation map', [200,200,750,475]);
                savefig( figure_cor,fullfile(subject_report_path,'Low correlation Voxel interpolation.fig'));
                close(figure_cor);
                
                %%
                %% Save and display report
                %%
                ReportFile = bst_report('Save', sFiles);
                bst_report('Export',  ReportFile,report_name);
                bst_report('Open', ReportFile);
                bst_report('Close');
                processed = true;
                disp(strcat("-->> Process finished for subject: ", subID));
                
                Protocol_count = Protocol_count+1;
            else
                subjects_process_error = [subjects_process_error; subID];
                continue;
            end
        catch
            subjects_process_error = [subjects_process_error; subID];
            [~, iSubject] = bst_get('Subject', subID);
            db_delete_subjects( iSubject );
            processed = false;
            continue;
        end
        %%
        %% Export Subject to BC-VARETA
        %%
        if(processed)
            disp(strcat('BC-V -->> Export subject:' , subject_name, ' to BC-VARETA structure'));
            if(selected_data_set.bcv_config.export)
                export_subject_BCV_structure(selected_data_set,subject_name);
            end
        end
        %%
        if( mod(Protocol_count,selected_data_set.protocol_subjet_count) == 0  || j == size(subjects,1))
            % Genering Manual QC file (need to check)
            %                     generate_MaQC_file();
        end
        disp(strcat('-->> Subject:' , subject_name, '. Processing finished.'));
        
    end
    disp(strcat('-->> Process finished....'));
    disp('=================================================================');
    disp('=================================================================');
    save report.mat subjects_processed subjects_process_error;
end
end
