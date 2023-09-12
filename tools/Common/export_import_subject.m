


%%===================================================================================
%%
%% Export subject template
%%
iProtocol               = bst_get('Protocol', ProtocolName_R);
gui_brainstorm('SetCurrentProtocol', iProtocol);
[sSubject, iSubject]    = bst_get('Subject', iSubject);
templateFile              = fullfile(pwd,'tmp',[subID,'.zip']);
export_protocol(iProtocol, iSubject, templateFile);

%%
%% Import subject template
%%
import_subject(templateFile);
[sOldSubject, ~] = bst_get('Subject', 'Template', 1);
% Rename subject
db_rename_subject(sOldSubject.Name, subID);
[sSubject, iSubject] = bst_get('Subject', subID, 1);