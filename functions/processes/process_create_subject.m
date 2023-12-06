function [CiftiStorm, errMessage] = process_create_subject(CiftiStorm, properties, subID)

errMessage      = [];
general_params  = properties.general_params;
ProtocolName    = general_params.bst_config.protocol_name;

%%
%% Creating BST Protocol
%%
if(~general_params.bst_config.after_MaQC.run)
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
            gui_brainstorm('CreateProtocol',ProtocolName , 0, 0)
        else
            gui_brainstorm('SetCurrentProtocol', iProtocol);
            ProtocolSubjects = bst_get('ProtocolSubjects');
            if(~isempty(find(ismember({ProtocolSubjects.Subject.Name},subID), 1)))
                db_delete_subjects( find(ismember({ProtocolSubjects.Subject.Name},subID)) );
            end
        end
    end
    db_reload_database('current');
    db_add_subject(subID);
    create_report_path(properties, subID);
else
    gui_brainstorm('UpdateProtocolsList');
    iProtocol = bst_get('Protocol', ProtocolName);
    if(isempty(iProtocol))
       errMessage = strcat("The protocol: ", ProtocolName, ". Do not exist in the BST database.");
    else
        gui_brainstorm('SetCurrentProtocol', iProtocol);
        ProtocolSubjects = bst_get('ProtocolSubjects');
        if(isempty(find(ismember({ProtocolSubjects.Subject.Name},subID), 1)))
            errMessage = strcat("The subject: ", subID, ". Do not exist in the protocol:", ProtocolName, ".");
        end
    end
end

CiftiStorm.Participants(end+1).SubID                = subID;
if(isempty(errMessage))
    CiftiStorm.Participants(end).Status             = "Processing";
    CiftiStorm.Participants(end).FileInfo           = "";
    CiftiStorm.Participants(end).Process(1).Name    = "Create";
    CiftiStorm.Participants(end).Process(1).Status  = "Completed";
    CiftiStorm.Participants(end).Process(1).Error   = errMessage;
else    
    CiftiStorm.Participants(end).Status             = "Rejected";
    CiftiStorm.Participants(end).FileInfo           = "";
    CiftiStorm.Participants(end).Process(1).Name    = "Create";
    CiftiStorm.Participants(end).Process(1).Status  = "Rejected";
    CiftiStorm.Participants(end).Process(1).Error   = errMessage;    
end

end