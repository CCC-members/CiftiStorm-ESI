function errMessage = process_create_subject(properties,subID)

errMessage      = [];
general_params  = properties.general_params;
ProtocolName    = general_params.bst_config.protocol_name;

%%
%% Creating BST Protocol
%%
if(general_params.bst_config.reset_protocol)
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
        gui_brainstorm('CreateProtocol',ProtocolName , 0, 0);else
        gui_brainstorm('SetCurrentProtocol', iProtocol);
        ProtocolSubjects = bst_get('ProtocolSubjects');
        if(~isempty(find(ismember({ProtocolSubjects.Subject.Name},subID), 1)))
            db_delete_subjects( find(ismember({ProtocolSubjects.Subject.Name},subID)) );
        end
    end
end
db_reload_database('current');
%%
%% Creating subject in Protocol
%%
db_add_subject(subID);
create_report_path(properties, subID);

end