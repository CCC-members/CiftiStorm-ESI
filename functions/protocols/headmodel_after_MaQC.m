function process_error = headmodel_after_MaQC(properties)
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
%% Preparing selected protocol
%%
process_error           = [];
modality                = properties.general_params.modality;
subjects_process_error  = [];
subjects_processed      = [];
report_output_path      = properties.general_params.reports.output_path;
general_params          = properties.general_params;

new_bst_DB              = general_params.bst_config.db_path;
if(isequal(new_bst_DB,lower('local')))
    new_bst_DB = bst_fullfile(bst_get('BrainstormUserDir'), 'local_db');
end
bst_set('BrainstormDbDir', new_bst_DB);

gui_brainstorm('UpdateProtocolsList');
nProtocols              = db_import(new_bst_DB);

%getting existing protocols on DB
ProtocolFiles           = dir(fullfile(new_bst_DB,'**','protocol.mat'));
cases_to_correct        = jsondecode(fileread(fullfile(properties.general_params.bst_config.after_MaQC.cases_file)));

for i=1:length(ProtocolFiles)
    Protocol            = load(fullfile(ProtocolFiles(i).folder,ProtocolFiles(i).name));   
    ProtocolName        = Protocol.ProtocolInfo.Comment;
    if(isempty(find(ismember({cases_to_correct.protocol_name},ProtocolName),1)))
        continue;
    else
        Protocol_correct = cases_to_correct(find(ismember({cases_to_correct.protocol_name},ProtocolName),1));
        subject_correct  = Protocol_correct.subjects;
    end
    
    iProtocol           = bst_get('Protocol', ProtocolName);
    gui_brainstorm('SetCurrentProtocol', iProtocol);
    ProtocolInfo        = bst_get('ProtocolInfo');
    subjects            = bst_get('ProtocolSubjects');
    for j=1:length(subjects.Subject)   
        sSubject        = subjects.Subject(j);     
        subID           = sSubject.Name;        
        if(isempty(find(ismember(subject_correct,subID),1)))
            continue;
        end
        disp(strcat('-->> Processing subject: ', subID));
        disp('=================================================================');
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
        % Get MRI file and surface files
        if(isempty(sSubject) || isempty(sSubject.iAnatomy) || isempty(sSubject.iCortex) || isempty(sSubject.iInnerSkull) || isempty(sSubject.iOuterSkull) || isempty(sSubject.iScalp))
            return;
        end
        % Start a new report
        bst_report('Start',['Protocol for subject:' , subID]);
        bst_report('Info',    '', [], ['Protocol for subject:' , subID]);
        
        MriFile     = sSubject.Anatomy(sSubject.iAnatomy).FileName;
        hFigMri1    = view_mri_slices(MriFile, 'x', 20);
        bst_report('Snapshot',hFigMri1,MriFile,'MRI Axial view', [200,200,750,475]);
        saveas( hFigMri1,fullfile(subject_report_path,'MRI Axial view.fig'));
        
        hFigMri2    = view_mri_slices(MriFile, 'y', 20);
        bst_report('Snapshot',hFigMri2,MriFile,'MRI Coronal view', [200,200,750,475]);
        saveas( hFigMri2,fullfile(subject_report_path,'MRI Coronal view.fig'));
        
        hFigMri3    = view_mri_slices(MriFile, 'z', 20);
        bst_report('Snapshot',hFigMri3,MriFile,'MRI Sagital view', [200,200,750,475]);
        saveas( hFigMri3,fullfile(subject_report_path,'MRI Sagital view.fig'));
        
        close([hFigMri1 hFigMri2 hFigMri3]);
        
        %%
        %% Quality control
        %%
        % Get subject definition and subject files
        CortexFile      = sSubject.Surface(sSubject.iCortex).FileName;
        InnerSkullFile  = sSubject.Surface(sSubject.iInnerSkull).FileName;
        OuterSkullFile  = sSubject.Surface(sSubject.iOuterSkull).FileName;
        ScalpFile       = sSubject.Surface(sSubject.iScalp).FileName;
        
        %        
        hFigMriSurf     = view_mri(MriFile, CortexFile);        
        %
        hFigMri4        = script_view_contactsheet( hFigMriSurf, 'volume', 'x','');
        bst_report('Snapshot',hFigMri4,MriFile,'Cortex - MRI registration Axial view', [200,200,750,475]);
        saveas( hFigMri4,fullfile(subject_report_path,'Cortex - MRI registration Axial view.fig'));
        close(hFigMri4);
        %
        hFigMri5        = script_view_contactsheet( hFigMriSurf, 'volume', 'y','');
        bst_report('Snapshot',hFigMri5,MriFile,'Cortex - MRI registration Coronal view', [200,200,750,475]);
        saveas( hFigMri5,fullfile(subject_report_path,'Cortex - MRI registration Coronal view.fig'));
        close(hFigMri5);
        %
        hFigMri6        = script_view_contactsheet( hFigMriSurf, 'volume', 'z','');
        bst_report('Snapshot',hFigMri6,MriFile,'Cortex - MRI registration Sagital view', [200,200,750,475]);
        saveas( hFigMri6,fullfile(subject_report_path,'Cortex - MRI registration Sagital view.fig'));        
        close([hFigMriSurf hFigMri6]);
        
        %
        hFigMri7        = view_mri(MriFile, ScalpFile);
        bst_report('Snapshot',hFigMri7,MriFile,'Scalp registration', [200,200,750,475]);
        saveas( hFigMri7,fullfile(subject_report_path,'Scalp registration.fig'));
        close(hFigMri7);
        %
        hFigMri8        = view_mri(MriFile, OuterSkullFile);
        bst_report('Snapshot',hFigMri8,MriFile,'Outer Skull - MRI registration', [200,200,750,475]);
        saveas( hFigMri8,fullfile(subject_report_path,'Outer Skull - MRI registration.fig'));
        close(hFigMri8);
        %
        hFigMri9        = view_mri(MriFile, InnerSkullFile);
        bst_report('Snapshot',hFigMri9,MriFile,'Inner Skull - MRI registration', [200,200,750,475]);
        saveas( hFigMri9,fullfile(subject_report_path,'Inner Skull - MRI registration.fig'));        
        % Closing figures
        close(hFigMri9);
        
        %        
        % Top
        hFigSurf10      = view_surface(CortexFile);
        
        delete(findobj(hFigSurf10, 'Tag', 'ScoutPatch'));
        delete(findobj(hFigSurf10, 'Tag', 'ScoutLabel'));
        delete(findobj(hFigSurf10, 'Tag', 'ScoutMarker'));
        delete(findobj(hFigSurf10, 'Tag', 'ScoutContour'));
        bst_report('Snapshot',hFigSurf10,[],'Cortex mesh 3D top view', [200,200,750,475]);
        saveas( hFigSurf10,fullfile(subject_report_path,'Cortex mesh 3D view.fig'));
        % Bottom
        view(90,270)
        bst_report('Snapshot',hFigSurf10,[],'Cortex mesh 3D bottom view', [200,200,750,475]);
        %Left
        view(1,180)
        bst_report('Snapshot',hFigSurf10,[],'Cortex mesh 3D left hemisphere view', [200,200,750,475]);
        % Right
        view(0,360)
        bst_report('Snapshot',hFigSurf10,[],'Cortex mesh 3D right hemisphere view', [200,200,750,475]);
        % Closing figure
        close(hFigSurf10);
        
        %%
        %%
        %% Test
        %%
        %%
%         script_tess_force_envelope(CortexFile, InnerSkullFile);
        
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
        %% Quality Control
        %%
        hFigSurf11      = script_view_surface(CortexFile, [], [], [],'top');
        hFigSurf11      = script_view_surface(InnerSkullFile, [], [], hFigSurf11);
        hFigSurf11      = script_view_surface(OuterSkullFile, [], [], hFigSurf11);
        hFigSurf11      = script_view_surface(ScalpFile, [], [], hFigSurf11);
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
        % Closing figure
        close(hFigSurf11);        
                
        %%
        %% Quality control
        %%
        % View sources on MRI (3D orthogonal slices)
        iStudy          = bst_get('ChannelStudiesWithSubject', j);        
        sStudy          = bst_get('Study', iStudy);
        
        BSTChannelsFile = bst_fullfile(ProtocolInfo.STUDIES,sStudy.Channel(1).FileName);
%         BSTChannelsFile = bst_fullfile(ProtocolInfo.STUDIES,subID,'@raw5-Restin_c_rfDC','channel_10-20_19.mat');
                
        hFigMri16       = script_view_mri_3d(MriFile, [], [], [], 'front');
        hFigMri16       = view_channels(BSTChannelsFile, 'EEG', 1, 0, hFigMri16, 1);
        bst_report('Snapshot',hFigMri16,[],'Sensor-MRI registration front view', [200,200,750,475]);
        saveas( hFigMri16,fullfile(subject_report_path,'Sensor-MRI registration view.fig'));
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
        hFigMri20      = script_view_surface(ScalpFile, [], [], [],'front');
        hFigMri20      = view_channels(BSTChannelsFile, 'EEG', 1, 0, hFigMri20, 1);
        bst_report('Snapshot',hFigMri20,[],'Sensor-Scalp registration front view', [200,200,750,475]);
        saveas( hFigMri20,fullfile(subject_report_path,'Sensor-Scalp registration view.fig'));
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
        %% Quality control
        %%
        %%        
        hFigSurf24      = view_surface(CortexFile);
        delete(findobj(hFigSurf24, 'Tag', 'ScoutLabel'));
        delete(findobj(hFigSurf24, 'Tag', 'ScoutMarker'));
        delete(findobj(hFigSurf24, 'Tag', 'ScoutContour'));
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
        %% Getting Headmodeler options
        %%
        headmodel_options = get_headmodeler_options(modality, subID, iStudy);
        
        %%
        %% Recomputing Head Model
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
          
            %%
            %% Export Subject to BC-VARETA
            %%
            if(processed)
                disp(strcat('BC-V -->> Export subject:' , subID, ' to BC-VARETA structure'));
                if(properties.general_params.bcv_config.export)
                    export_subject_BCV_structure(properties,subID);
                end
            end   
            disp(strcat('-->> Subject:' , subID, '. Processing finished.'));            
            disp('=================================================================');
        end
    end
end
