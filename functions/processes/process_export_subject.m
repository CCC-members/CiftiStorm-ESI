function process_export_subject(output_subject_dir, subID, EEG)


%%
%% Update subject protocol with preprocessed data
%%
% Get subject directory
ProtocolInfo                = bst_get('ProtocolInfo');
sSubject        = bst_get('Subject', subID);

% Get the current Study
[sStudies, ~]   = bst_get('StudyWithSubject', sSubject.FileName, 'intra_subject');
if(length(sStudies)>1)
    conditions  = [sStudies.Condition];
    sStudy      = sStudies(find(contains(conditions,strcat('@raw')),1));else
    sStudy      = sStudies;
end
if(isempty(sSubject) || isempty(sSubject.iAnatomy) || isempty(sSubject.iCortex) || isempty(sSubject.iInnerSkull) || isempty(sSubject.iOuterSkull) || isempty(sSubject.iScalp))
    return;
end
HeadModel = load(fullfile(ProtocolInfo.STUDIES, sStudies.HeadModel.FileName));
Cdata     = load(fullfile(ProtocolInfo.STUDIES, sStudies.Channel.FileName));
[Cdata_r, Gain] = remove_channels_by_preproc_data({EEG.EEG.chanlocs.labels}, Cdata, HeadModel.Gain);

HeadModel.Gain = Gain;
save(fullfile(ProtocolInfo.STUDIES, sStudies.HeadModel.FileName),'-struct','HeadModel');
Cdata = Cdata_r;
save(fullfile(ProtocolInfo.STUDIES, sStudies.Channel.FileName),'-struct','Cdata');


%%
%% Export subject from protocol
%%
disp("-->> Export Subject from BST Protocol");
if(~isfolder(fullfile(output_subject_dir,'brainstorm')))
    mkdir(fullfile(output_subject_dir,'brainstorm'));
end
iProtocol       = bst_get('iProtocol');
[~, iSubject]   = bst_get('Subject', subID);
subject_file    = fullfile(output_subject_dir,'brainstorm',strcat(subID,'.zip'));
export_protocol(iProtocol, iSubject, subject_file);

%%
%% Save and display report
%%
% if(getGlobalVerbose())
%     disp("-->> Export BST Report");
%     report_path     = get_report_path(CiftiStorm, subID);
%     ReportFile      = bst_report('Save', []);
%     bst_report('Export',  ReportFile, fullfile(report_path,[subID,'.html'])); 
% end


end

