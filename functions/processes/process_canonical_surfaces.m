function errMessage = process_canonical_surfaces(properties,subID)

errMessage  = [];
mq_control  = properties.general_params.bst_config.after_MaQC.run;
%%
%% Getting report path
%%
report_path = get_report_path(properties, subID);

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
sSubject    = bst_get('Subject', subID);
MriFile     = sSubject.Anatomy(sSubject.iAnatomy).FileName;
ScalpFile   = sSubject.Surface(sSubject.iScalp).FileName;
hFigMri15   = view_mri(MriFile, ScalpFile);
bst_report('Snapshot',hFigMri15,[],'SPM Scalp Envelope - MRI registration', [200,200,900,700]);
savefig( hFigMri15,fullfile(report_path,'SPM_Scalp_Envelope-MRI_registration.fig'));
% Close figures
close(hFigMri15);
end