function [processed] = protocol_headmodel_hcp(subID,ProtocolName)
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
%% Preparing selected protocol
%%
app_properties = jsondecode(fileread(strcat('app',filesep,'app_properties.json')));
selected_data_set = jsondecode(fileread(strcat('config_protocols',filesep,app_properties.selected_data_set.file_name)));

if(is_check_dataset_properties(selected_data_set))
    disp(strcat('-->> Data Source:  ', selected_data_set.hcp_data_path.base_path ));
    ProtocolName = selected_data_set.protocol_name;
    [base_path,name,ext] = fileparts(selected_data_set.hcp_data_path.base_path);
    subjects = dir(base_path);
    subjects_process_error = [];
    subjects_processed =[];
    Protocol_count = 0;
    for j=1:size(subjects,1)
        subject_name = subjects(j).name;
        if(subject_name ~= '.' & string(subject_name) ~="..")
            
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
                if(isfile(T1w_file) && ~isfile(L_surface_file) && ~isfile(R_surface_file))
                    if(isfield(selected_data_set, 'brain_external_surface_path'))
                        base_path =  strrep(selected_data_set.brain_external_surface_path.base_path,'SubID',subID);
                        filepath = strrep(selected_data_set.brain_external_surface_path.L_surface_location,'SubID',subID);
                        L_surface_file = fullfile(base_path,filepath);
                        
                        filepath = strrep(selected_data_set.brain_external_surface_path.R_surface_location,'SubID',subID);
                        R_surface_file = fullfile(base_path,filepath);
                        if(~isfile(L_surface_file) || ~isfile(R_surface_file))
                            fprintf(2,strcat('\n -->> Error: The Tw1 or Cortex surfaces: \n'));
                            disp(string(L_surface_file));
                            disp(string(R_surface_file));
                            fprintf(2,strcat('\n -->> Do not exist. \n'));
                            fprintf(2,strcat('-->> Jumping to an other subject. \n'));
                            processed = false;
                            return;
                        end
                    else
                        fprintf(2,strcat('\n -->> Error: You need to configure the cortex surfaces in at least one of follows field\n'));
                        disp(string(T1w_file));
                        disp("hcp_data_path");
                        disp("OR");
                        disp("brain_external_surface_path");
                        fprintf(2,strcat('-->> Jumping to an other subject. \n'));
                        processed = false;
                        return;
                    end
                else
                    fprintf(2,strcat('\n -->> Error: The Tw1 or Cortex surfaces: \n'));
                    disp(string(T1w_file));
                    disp(string(L_surface_file));
                    disp(string(R_surface_file));
                    disp(string(Atlas_seg_location));
                    fprintf(2,strcat('\n -->> Do not exist. \n'));
                    fprintf(2,strcat('-->> Jumping to an other subject. \n'));
                    processed = false;
                    return;
                end
            end
            
            % Non-Brain surface files
            base_path =  strrep(selected_data_set.non_brain_data_path.base_path,'SubID',subID);
            filepath = strrep(selected_data_set.non_brain_data_path.head_file_location,'SubID',subID);
            head_file = fullfile(base_path,filepath);
            
            filepath =  strrep(selected_data_set.non_brain_data_path.outerfile_file_location,'SubID',subID);
            outerskull_file = fullfile(base_path,filepath);
            
            filepath = strrep(selected_data_set.non_brain_data_path.innerfile_file_location,'SubID',subID);
            innerskull_file = fullfile(base_path,filepath);
            
            if(~isfile(head_file) || ~isfile(outerskull_file) || ~isfile(innerskull_file))
                fprintf(2,strcat('\n -->> Error: The Non-brain surfaces: \n'));
                disp(string(T1w_file));
                disp(string(L_surface_file));
                disp(string(R_surface_file));
                fprintf(2,strcat('\n -->> Do not exist. \n'));
                fprintf(2,strcat('-->> Jumping to an other subject. \n'));
                processed = false;
                return;
            end            
            
            % MEG file
            base_path =  strrep(selected_data_set.meg_data_path.base_path,'SubID',subID);
            filepath = strrep(selected_data_set.meg_data_path.file_location,'SubID',subID);
            MEG_file = fullfile(base_path,filepath);
            if(~isfile(MEG_file))
                fprintf(2,strcat('\n -->> Error: The MEG: \n'));
                disp(string(MEG_file));
                fprintf(2,strcat('\n -->> Do not exist. \n'));
                fprintf(2,strcat('\n -->> Jumping to an other subject. \n'));
                processed = false;
                return;
            end
            
            % Transformation file
            base_path =  strrep(selected_data_set.meg_transformation_path.base_path,'SubID',subID);
            filepath = strrep(selected_data_set.meg_transformation_path.file_location,'SubID',subID);
            MEG_transformation_file = fullfile(base_path,filepath);
            if(~isfile(MEG_transformation_file) && ~isequal(base_path,'none'))
                fprintf(2,strcat('\n -->> Error: The MEG tranformation file: \n'));
                disp(string(MEG_transformation_file));
                fprintf(2,strcat('\n -->> Do not exist. \n'));
                fprintf(2,strcat('\n -->> Jumping to an other subject. \n'));
                processed = false;
                return;
            end
            if(isequal(base_path,'none'))
                MEG_transformation_file = 'none';
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
            if(~isequal(selected_data_set.sub_prefix,'none') && ~isempty(selected_data_set.sub_prefix))
                subID = strrep(subject_name,selected_data_set.sub_prefix,'');
            end
            disp(strcat('-->> Processing subject: ', subID));
                        
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
            if(~isequal(MEG_transformation_file,'none'))
                bst_progress('start', 'Import HCP MEG/anatomy folder', 'Reading transformations...');
                % Read file
                fid = fopen(MEG_transformation_file, 'rt');
                strFid = fread(fid, [1 Inf], '*char');
                fclose(fid);
                % Evaluate the file (.m file syntax)
                eval(strFid);
            end
            %%
            %% MRI=>MNI Tranformation
            %%
            if(~isequal(MEG_transformation_file,'none'))
                % Convert transformations from "Brainstorm MRI" to "FieldTrip voxel"
                Tbst2ft = [diag([-1, 1, 1] ./ sMri.Voxsize), [size(sMri.Cube,1); 0; 0]; 0 0 0 1];
                % Set the MNI=>SCS transformation in the MRI
                Tmni = transform.vox07mm2spm * Tbst2ft;
                sMri.NCS.R = Tmni(1:3,1:3);
                sMri.NCS.T = Tmni(1:3,4);
                % Compute default fiducials positions based on MNI coordinates
                sMri = mri_set_default_fid(sMri);
            end
            %%
            %% MRI=>SCS TRANSFORMATION =====
            %%
            if(~isequal(MEG_transformation_file,'none'))
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
            end
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
            saveas( hFigMri1,fullfile(subject_report_path,'MRI Axial view.fig'));
            
            hFigMri2 = view_mri_slices(MriFile, 'y', 20);
            bst_report('Snapshot',hFigMri2,MriFile,'MRI Coronal view', [200,200,750,475]);
            saveas( hFigMri2,fullfile(subject_report_path,'MRI Coronal view.fig'));
            
            hFigMri3 = view_mri_slices(MriFile, 'z', 20);
            bst_report('Snapshot',hFigMri3,MriFile,'MRI Sagital view', [200,200,750,475]);
            saveas( hFigMri3,fullfile(subject_report_path,'MRI Sagital view.fig'));
            
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
            InnerSkullFile = sSubject.Surface(sSubject.iInnerSkull).FileName;
            OuterSkullFile = sSubject.Surface(sSubject.iOuterSkull).FileName;
            ScalpFile      = sSubject.Surface(sSubject.iScalp).FileName;
            
            %
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
            close([hFigMriSurf hFigMri4 hFigMri5 hFigMri6]);
            
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
            
            % Closing figures
            close([hFigMri7 hFigMri8 hFigMri9]);
            
            %
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
            saveas( hFigSurf11,fullfile(subject_report_path,'BEM surfaces registration view.fig'));
            
            %Left
            view(1,180)
            bst_report('Snapshot',hFigSurf11,[],'BEM surfaces registration left view', [200,200,750,475]);
            
            % Right
            view(0,360)
            bst_report('Snapshot',hFigSurf11,[],'BEM surfaces registration right view', [200,200,750,475]);
            
            % Back
            view(90,360)
            bst_report('Snapshot',hFigSurf11,[],'BEM surfaces registration back view', [200,200,750,475]);
            
            close(hFigSurf11);
            
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
            saveas( hFigMri15,fullfile(subject_report_path,'SPM Scalp Envelope - MRI registration.fig'));
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
            saveas( hFigScalp16,fullfile(subject_report_path,'Sensor-Helmet registration front view.fig'));
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
            
            % View 4D coils on Scalp
            [hFigScalp20, iDS, iFig] = view_channels_3d(sFiles.ChannelFile,'4D', 'scalp', 0, 0);
            view(90,360)
            bst_report('Snapshot',hFigScalp20,[],'4D coils-Scalp registration front view', [200,200,750,475]);
            saveas( hFigScalp20,fullfile(subject_report_path,'Sensor-Scalp registration front view.fig'));
            
            view(180,360)
            bst_report('Snapshot',hFigScalp20,[],'4D coils-Scalp registration left view', [200,200,750,475]);
            
            view(0,360)
            bst_report('Snapshot',hFigScalp20,[],'4D coils-Scalp registration right view', [200,200,750,475]);
            
            view(270,360)
            bst_report('Snapshot',hFigScalp20,[],'4D coils-Scalp registration back view', [200,200,750,475]);
            
            % Close figures
            close(hFigScalp20);
            
            
            % View 4D coils on Scalp
            [hFigScalp21, iDS, iFig] = view_channels_3d(sFiles.ChannelFile,'MEG', 'scalp');
            view(90,360)
            bst_report('Snapshot',hFigScalp21,[],'4D coils-Scalp registration front view', [200,200,750,475]);
            saveas( hFigScalp21,fullfile(subject_report_path,'4D coils-Scalp registration front view.fig'));
            
            view(180,360)
            bst_report('Snapshot',hFigScalp21,[],'4D coils-Scalp registration left view', [200,200,750,475]);
            
            view(0,360)
            bst_report('Snapshot',hFigScalp21,[],'4D coils-Scalp registration right view', [200,200,750,475]);
            
            view(270,360)
            bst_report('Snapshot',hFigScalp21,[],'4D coils-Scalp registration back view', [200,200,750,475]);
            
            % Close figures
            close(hFigScalp21);
            
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
            saveas( hFigSurf24,fullfile(subject_report_path,'Surface view.fig'));
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
            
            iStudy = ProtocolInfo.iStudy;
            sStudy = bst_get('Study', iStudy);
            headmodel_options = struct();
            headmodel_options.Comment = 'Overlapping spheres'; % for EEG 'OpenMEEG BEM'
            headmodel_options.HeadModelFile = bst_fullfile(ProtocolInfo.STUDIES,sSubject.Name,sStudy.Name);
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
            
            if(~isempty(headmodel_options))
                ProtocolInfo = bst_get('ProtocolInfo');
                iStudy = ProtocolInfo.iStudy;
                sStudy = bst_get('Study', iStudy);
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
                bst_set('Study', iStudy, sStudy);
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
                [hFig25] = view3D_K(Ke,cortex,head,channels,200);
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
            ReportFile = bst_report('Save', sFiles);
            bst_report('Export',  ReportFile,report_name);
            bst_report('Open', ReportFile);
            bst_report('Close');
            
            disp([10 '-->> BrainStorm Protocol PhilipsMFF: Done.' 10]);
            
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
            Protocol_count = Protocol_count + 1;
            if( mod(Protocol_count,selected_data_set.protocol_subjet_count) == 0  || j == size(subjects,1))
                % Genering Manual QC file (need to check)
                %                     generate_MaQC_file();
            end
            disp(strcat('-->> Subject:' , subject_name, '. Processing finished.'));
        end
    end
    disp(strcat('-->> Process finished....'));
    disp('=================================================================');
    disp('=================================================================');
    save report.mat subjects_processed subjects_process_error;
end
end
