function process_error = headmodel_indiv_anat(properties)
% Description here
%
%
%
% Author:
% - Ariosky Areces Gonzalez
% - Deirel Paz Linares
%%

%%
%% Preparing selected protocol
%%
process_error = [];
modality = properties.general_params.modality;
ProtocolName            = properties.general_params.bst_config.protocol_name;
subjects_process_error  = [];
subjects_processed      = [];
report_output_path      = properties.general_params.reports.output_path;
general_params          = properties.general_params;
anatomy_type            = properties.anatomy_params.anatomy_type.type_list{3};

disp(strcat('-->> Data Source:  ', anatomy_type.base_path ));
[base_path,name,ext] = fileparts(anatomy_type.base_path);
subjects = dir(base_path);
load("templates/good_cases_wMRI_Usama.mat");
subjects(~ismember( {subjects.name}, IDg)) = []; 
%subjects(ismember( {subjects.name}, {'.', '..'})) = [];  %remove . and ..
subjects_process_error = [];
subjects_processed =[];
Protocol_count = 0;
for j=1:length(subjects)
    subject_name = subjects(j).name;
    if(isequal(anatomy_type.subID_prefix,'none') || isempty(anatomy_type.subID_prefix))
        subID = subject_name;
    else
        subID_prefix = anatomy_type.subID_prefix;
        subID = strrep(subject_name, subID_prefix,'');
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
    %%  Checking protocol
    %%
    if( mod(Protocol_count,general_params.bst_config.protocol_subjet_count) == 0  )
        ProtocolName_R = strcat(ProtocolName,'_',char(num2str(Protocol_count)));
        
        if(general_params.bst_config.protocol_reset)
            gui_brainstorm('DeleteProtocol',ProtocolName_R);
            bst_db_path = bst_get('BrainstormDbDir');
            if(isfolder(fullfile(bst_db_path,ProtocolName_R)))
                protocol_folder = fullfile(bst_db_path,ProtocolName_R);
                rmdir(protocol_folder, 's');
            end
            gui_brainstorm('CreateProtocol',ProtocolName_R , 0, 0);
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
    
%     try
        %%
        %% Creating subject in Protocol
        %%
        db_add_subject(subID);
        % Get subject definition
        [sSubject, iSubject] = bst_get('Subject', subID);
        
        
        % Start a new report
        bst_report('Start',['Protocol for subject:' , subID]);
        bst_report('Info',    '', [], ['Protocol for subject:' , subID]);
        
        %%
        %% Process import anatomy
        %%
        anat_error = process_import_anat(properties,'individual',iSubject,subID);
        if(~isempty(fieldnames(anat_error)))
            continue;
        end
        %%
        %% Quality control
        %%
        % Get MRI file and surface files
        [sSubject, iSubject] = bst_get('Subject', subID);
        MriFile  = sSubject.Anatomy(sSubject.iAnatomy).FileName;
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
        hFigMri8 = view_mri(MriFile, OuterSkullFile);
        bst_report('Snapshot',hFigMri8,MriFile,'Outer Skull - MRI registration', [200,200,750,475]);
        savefig( hFigMri8,fullfile(subject_report_path,'Outer Skull - MRI registration.fig'));
        close(hFigMri8);
        %
        hFigMri9 = view_mri(MriFile, InnerSkullFile);
        bst_report('Snapshot',hFigMri9,MriFile,'Inner Skull - MRI registration', [200,200,750,475]);
        savefig( hFigMri9,fullfile(subject_report_path,'Inner Skull - MRI registration.fig'));
        % Closing figures
        close(hFigMri9);
        
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
        sFiles = bst_process('CallProcess', 'process_generate_bem', [], [], ...
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
%         [isOk, errMsg] = process_mni_normalize('Compute', MriFile, 'segment');
        sFiles = bst_process('CallProcess', 'process_generate_canonical', [], [], ...
            'subjectname', subID, ...
            'resolution',  2);  % 8196
        if(isempty(sFiles))
            subj_error.spm_canonical = "Updated SPM caninonical pluging";
           return; 
        end
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
        %% Process: Import Atlas
        %%
        atlas_error = process_import_atlas(properties, 'individual', subID);
        
        %%
        %% Quality control
        %%
        panel_scout('SetScoutsOptions', 0, 0, 1, 'all', 1, 0, 0, 0);
        panel_scout('UpdateScoutsDisplay', 'all');
        panel_scout('SetScoutContourVisible', 0, 0);        
        panel_scout('SetScoutTransparency', 0);
        panel_scout('SetScoutTextVisible', 0, 1);
        
        hFigSurf24 = view_surface(CortexFile);
        % Deleting the Atlas Labels and Countour from Cortex
        
        delete(findobj(hFigSurf24, 'Tag', 'ScoutLabel'));
        delete(findobj(hFigSurf24, 'Tag', 'ScoutMarker'));
        delete(findobj(hFigSurf24, 'Tag', 'ScoutContour'));
        
        bst_report('Snapshot',hFigSurf24,[],'surface view', [200,200,750,475]);
        savefig( hFigSurf24,fullfile(subject_report_path,'Surface view.fig'));
        %Left
        view(1,180);
        bst_report('Snapshot',hFigSurf24,[],'Surface left view', [200,200,750,475]);
        % Bottom
        view(90,270);
        bst_report('Snapshot',hFigSurf24,[],'Surface bottom view', [200,200,750,475]);
        % Rigth
        view(0,360);
        bst_report('Snapshot',hFigSurf24,[],'Surface right view', [200,200,750,475]);
        % Closing figure
        close(hFigSurf24);
        
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
        if(~isempty(channel_error))
           continue; 
        end
        %%
        %% Quality control
        %%
        % View sources on MRI (3D orthogonal slices)
        [sSubject, iSubject] = bst_get('Subject', subID);
        ScalpFile      = sSubject.Surface(sSubject.iScalp).FileName;
        MriFile        = sSubject.Anatomy(sSubject.iAnatomy).FileName;
        
        if(isequal(properties.general_params.modality,'EEG'))
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
        else
            hFigMri16      = script_view_mri_3d(MriFile, [], [], [], 'front');
            [hFigMri16, iDS, iFig] = view_helmet(ChannelFile, hFigMri16);
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
            
            hFigScalp20      = script_view_surface(ScalpFile, [], [], [], 'front');
            [hFigScalp20, iDS, iFig] = view_helmet(ChannelFile, hFigScalp20);
            bst_report('Snapshot',hFigScalp20,[],'Sensor-Helmet registration front view', [200,200,750,475]);
            saveas( hFigScalp20,fullfile(subject_report_path,'Sensor-Helmet registration front view.fig'));
            %Left
            view(1,180)
            bst_report('Snapshot',hFigScalp20,[],'Sensor-Helmet registration left view', [200,200,750,475]);
            % Right
            view(0,360)
            bst_report('Snapshot',hFigScalp20,[],'Sensor-Helmet registration right view', [200,200,750,475]);
            % Back
            view(90,360)
            bst_report('Snapshot',hFigScalp20,[],'Sensor-Helmet registration back view', [200,200,750,475]);
            % Close figures
            close(hFigScalp20);
        end
                
        %%
        %% Getting Headmodeler options
        %%
        [headmodel_options, errMessage] = process_comp_headmodel(properties, subID);

        %     catch
        %         subjects_process_error = [subjects_process_error; subID];
        %         [~, iSubject] = bst_get('Subject', subID);
        %         db_delete_subjects( iSubject );
        %         processed = false;
        %         continue;
        %     end
        %%
        %% Export Subject to BC-VARETA
        %%
    if(isempty(errMessage))
        disp(strcat('BC-V -->> Export subject:' , subID, ' to BC-VARETA structure'));
        if(properties.general_params.bcv_config.export)
            try
                export_error = export_subject_BCV_structure(properties,subID);
            catch
                continue;
            end
        end
    end
    %%
    if( mod(Protocol_count,properties.general_params.bst_config.protocol_subjet_count) == 0  || j == size(subjects,1))
        % Genering Manual QC file (need to check)
        %                     generate_MaQC_file();
    end
    disp(strcat('-->> Subject:' , subID, '. Processing finished.'));
    disp('=================================================================');
    
end
disp(strcat('-->> Process finished....'));
disp('=================================================================');
disp('=================================================================');
save report.mat subjects_processed subjects_process_error;

end

