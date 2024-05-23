function CiftiStorm = process_canonical_surfaces(CiftiStorm, properties,subID)

errMessage  = [];
mq_control  = properties.general_params.bst_config.after_MaQC.run;
%%
%% Compute SPM canonical surfaces
%%
if(~mq_control)   
    bst_process('CallProcess', 'process_generate_canonical', [], [], ...
        'subjectname', subID, ...
        'resolution',  2);  % 8196
end

%%
%% Quality control
%%
% Get subject definition and subject files
if(getGlobalVerbose())
    report_path = get_report_path(CiftiStorm, subID);
    sSubject    = bst_get('Subject', subID);
    MriFile     = sSubject.Anatomy(sSubject.iAnatomy).FileName;
    ScalpFile   = sSubject.Surface(sSubject.iScalp).FileName;
    hFigMri15   = view_mri(MriFile, ScalpFile);
    bst_report('Snapshot',hFigMri15,[],'SPM Scalp Envelope - MRI registration', [200,200,900,700]);
    try
        savefig( hFigMri15,fullfile(report_path,'SPM_Scalp_Envelope-MRI_registration.fig'));
    catch
    end
    % Close figures
    close(hFigMri15);
end

if(isempty(errMessage))
    CiftiStorm.Participants(end).Status             = "Processing";
    CiftiStorm.Participants(end).FileInfo           = "";
    CiftiStorm.Participants(end).Process(end+1).Name    = "SPM_surfaces";
    CiftiStorm.Participants(end).Process(end).Status  = "Completed";
    CiftiStorm.Participants(end).Process(end).Error   = errMessage;
else    
    CiftiStorm.Participants(end).Status             = "Rejected";
    CiftiStorm.Participants(end).FileInfo           = "";
    CiftiStorm.Participants(end).Process(end+1).Name    = "SPM_surfaces";
    CiftiStorm.Participants(end).Process(end).Status  = "Rejected";
    CiftiStorm.Participants(end).Process(end).Error   = errMessage;     
end
end