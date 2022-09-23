function process_error = headmodel_indiv_anat(properties, reject_subjects)
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
process_error           = [];
subjects_process_error  = [];
subjects_processed      = [];
ProtocolName            = properties.general_params.bst_config.protocol_name;
bst_output_path         = properties.general_params.bst_export.output_path;
general_params          = properties.general_params;
anatomy_type            = properties.anatomy_params.anatomy_type.type_list{3};

disp(strcat('-->> Data Source:  ', anatomy_type.base_path ));
base_path = anatomy_type.base_path;
subjects  = dir(base_path);
subjects(ismember( {subjects.name}, {'.', '..'})) = [];  %remove . and ..
if(~isempty(reject_subjects))
   subjects(ismember({subjects.name}, reject_subjects)) = []; 
end

for j=1:length(subjects)
    subject_name = subjects(j).name;
    if(isequal(anatomy_type.subID_prefix,'none') || isempty(anatomy_type.subID_prefix))
        subID = subject_name;
    else
        subID_prefix = anatomy_type.subID_prefix;
        subID = strrep(subject_name, subID_prefix,'');
    end
    disp(strcat('-->> Processing subject: ', subID));
    disp('==========================================================================');
    
    %%
    %% Getting report path
    %%
    [subject_report_path] = get_report_path(properties, subID);
    
    %%
    %%  Checking protocol
    %%
    if(general_params.bst_config.protocol_reset)
        gui_brainstorm('DeleteProtocol',ProtocolName);
        bst_db_path = bst_get('BrainstormDbDir');
        if(isfolder(fullfile(bst_db_path,ProtocolName)))
            protocol_folder = fullfile(bst_db_path,ProtocolName);
            rmdir(protocol_folder, 's');
        end
        gui_brainstorm('CreateProtocol',ProtocolName , 0, 0);
    else
        gui_brainstorm('UpdateProtocolsList');
        iProtocol = bst_get('Protocol', ProtocolName);
        if(isempty(iProtocol))
            gui_brainstorm('CreateProtocol',ProtocolName , 0, 0);
        else
            gui_brainstorm('SetCurrentProtocol', iProtocol);
            ProtocolSubjects = bst_get('ProtocolSubjects');
            if(~isempty(find(ismember({ProtocolSubjects.Subject.Name},subID), 1)))
                db_delete_subjects( find(ismember({ProtocolSubjects.Subject.Name},subID)) );
            end
        end
    end

    %%
    %% Creating subject in Protocol
    %%
    db_add_subject(subID);
    % Get subject definition
    [sSubject, iSubject] = bst_get('Subject', subID);
    
    %%
    %% Start a New Report
    %%
    bst_report('Start',['Protocol for subject:' , subID]);
    bst_report('Info',    '', [], ['Protocol for subject:' , subID]);
    
    %%
    %% Process Import Anatomy
    %%
    disp("--------------------------------------------------------------------------");
    disp("-->> Process Import Anatomy");
    disp("--------------------------------------------------------------------------");
    [anat_error, CSurfaces, sub_to_FSAve] = process_import_anat(properties,'individual',iSubject,subID);
    if(~isempty(fieldnames(anat_error)))
        continue;
    end
    
    %%
    %% Process: Import Atlas
    %%
    disp("--------------------------------------------------------------------------");
    disp("-->> Process Import Atlas");
    disp("--------------------------------------------------------------------------");
    atlas_error = process_import_atlas(properties, 'individual', subID, CSurfaces);
    
    %%
    %% Process: Generate BEM surfaces
    %%
    disp("--------------------------------------------------------------------------");
    disp("-->> Process Generate BEM surfaces");
    disp("--------------------------------------------------------------------------");    
    [errMessage]    = process_gen_bem_surfaces(properties, subID, CSurfaces);
    sSubject        = bst_get('Subject', subID);
    iScalp          = sSubject.iScalp;
    iOuterSkull     = sSubject.iOuterSkull;
    iInnerSkull     = sSubject.iInnerSkull;
    iCortex         = sSubject.iCortex;
    
    %%
    %% Process: Generate SPM canonical surfaces
    %%
    disp("--------------------------------------------------------------------------");
    disp("Process Generate SPM canonical surfaces");
    disp("--------------------------------------------------------------------------");
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
    sSubject    = bst_get('Subject', subID);
    MriFile     = sSubject.Anatomy(sSubject.iAnatomy).FileName;
    ScalpFile   = sSubject.Surface(sSubject.iScalp).FileName;
    
    %
    hFigMri15 = view_mri(MriFile, ScalpFile);
    bst_report('Snapshot',hFigMri15,[],'SPM Scalp Envelope - MRI registration', [200,200,900,700]);
    savefig( hFigMri15,fullfile(subject_report_path,'SPM Scalp Envelope - MRI registration.fig'));
    % Close figures
    close(hFigMri15);
    
    %%
    %% Process Import Channel
    %%
    disp("--------------------------------------------------------------------------");
    disp("-->> Process Import Channel");
    disp("--------------------------------------------------------------------------");
    iSurfaces = {iScalp, iOuterSkull, iInnerSkull, iCortex};
    if(isequal(properties.channel_params.channel_type.type,3))
        channel_type = 'template';
    elseif(isequal(properties.channel_params.channel_type.type,1))
        channel_type = 'individual';
    else
        channel_type = 'default';
    end
    [ChannelFile, channel_error] = process_import_chann(properties, channel_type, subID, iSurfaces);
    if(~isempty(channel_error))
        continue;
    end
        
    %%
    %% Process: Compute Headmodel
    %%
    disp("--------------------------------------------------------------------------");
    disp("-->> Process Compute HeadModel");
    disp("--------------------------------------------------------------------------");
    errMessage = process_comp_headmodel(properties, subID, CSurfaces);
    
    %%
    %% Export subject from protocol
    %%
    disp("--------------------------------------------------------------------------");
    disp("-->> Export Subject from BST Protocol");
    disp("--------------------------------------------------------------------------");
    if(~isfolder(fullfile(bst_output_path,'Subjects',ProtocolName)))
        mkdir(fullfile(bst_output_path,'Subjects',ProtocolName));
    end
    iProtocol       = bst_get('iProtocol');
    [~, iSubject]   = bst_get('Subject', subID);
    export_protocol(iProtocol, iSubject, fullfile(bst_output_path,'Subjects',ProtocolName,strcat(subID,'.zip')));
    
    %%
    %% Save and display report
    %%
    disp("--------------------------------------------------------------------------");
    disp("-->> Export BST Report");
    disp("--------------------------------------------------------------------------");
    [~, report_name]    = get_report_path(properties, subID);
    ReportFile          = bst_report('Save', []);
    bst_report('Export',  ReportFile, report_name);
    %     bst_report('Open', ReportFile);
    %     bst_report('Close');
    disp(strcat("-->> Process finished for subject: ",subID));
        
    %%
    %% Export Subject to BC-VARETA
    %%
    disp("--------------------------------------------------------------------------");
    disp("-->> Export to BC-VARETA Structure");
    disp("--------------------------------------------------------------------------");
    if(isempty(errMessage))
        disp(strcat('BC-V -->> Export subject:' , subID, ' to BC-VARETA structure'));
        if(general_params.bcv_config.export)
            export_error = export_subject_BCV_structure(properties,subID,CSurfaces,sub_to_FSAve);
        end
    end
    %%    
    % Genering Manual QC file (need to check)
    %                     generate_MaQC_file();
    
    disp(strcat('-->> Subject:' , subID, '. Processing finished.'));
    disp('==========================================================================');
    
end
disp(strcat('-->> Process finished....'));
disp('==========================================================================');
disp('==========================================================================');
save report.mat subjects_processed subjects_process_error;

end

