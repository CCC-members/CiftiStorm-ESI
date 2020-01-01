function selected_datataset_process(selected_data_set)
% try
if(isnumeric(selected_data_set.id))
    if(is_check_dataset_properties(selected_data_set))
        disp(strcat('--> Data Source:  ', selected_data_set.hcp_data_path.base_path ));
        ProtocolName = selected_data_set.protocol_name;
        [base_path,name,ext] = fileparts(selected_data_set.hcp_data_path.base_path);
        subjects = dir(base_path);
        subjects_process_error = [];
        subjects_processed =[];
        Protocol_count = 0;
        for j=1:size(subjects,1)
            subject_name = subjects(j).name;
            if(subject_name ~= '.' & string(subject_name) ~="..")
                if( mod(Protocol_count,selected_data_set.protocol_subjet_count) == 0  )
                    ProtocolName_R = strcat(ProtocolName,'_',char(num2str(Protocol_count)));
                    gui_brainstorm('DeleteProtocol',ProtocolName_R);
                    bst_db_path = bst_get('BrainstormDbDir');
                    if(isfolder(fullfile(bst_db_path,ProtocolName_R)))
                        protocol_folder = fullfile(bst_db_path,ProtocolName_R);
                        rmdir(protocol_folder, 's');
                    end
                    gui_brainstorm('CreateProtocol',ProtocolName_R ,selected_data_set.use_default_anatomy, selected_data_set.use_default_channel);
                end
                if(~isequal(selected_data_set.sub_prefix,'none') && ~isempty(selected_data_set.sub_prefix))
                    subject_name = strrep(subject_name,selected_data_set.sub_prefix,'');
                end
                disp(strcat('-->> Processing subject: ', subject_name));
                str_function = strcat('[processed]=',selected_data_set.function,'(''',subject_name,''',''',ProtocolName_R,''');');
                eval(str_function);
                
                %%
                %% Export Subject to BC-VARETA
                %%
                if(processed)
                    disp(strcat('BC-V -->> Export subject:' , subject_name, ' to BC-VARETA structure'));
                    export_subject_BCV_structure(selected_data_set,subject_name);
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
        save report.mat subjects_processed subjects_process_error;
    end
else
    if(isequal(selected_data_set.id,'after_MaQC'))
        % Load all protools
        new_bst_DB = selected_data_set.bst_db_path;
        bst_set('BrainstormDbDir', new_bst_DB);
        
        gui_brainstorm('UpdateProtocolsList');
        db_import(new_bst_DB);
        
        protocols = jsondecode(fileread(selected_data_set.MaQC_report_file));
        for i = 1 : length(protocols)
            protocol_name = protocols(i).protocol_name;
            iProtocol = bst_get('Protocol', protocol_name);
            gui_brainstorm('SetCurrentProtocol', iProtocol);
            for j = 1 : length(protocols(i).subjects)
                subjectID = protocols(i).subjects(j);
                disp(strcat('Recomputing Lead Field for Protocol: ',protocol_name,'. Subject: ',subjectID));
                str_function = strcat(selected_data_set.function,'(''',protocol_name,''',''',char(subjectID),''')');
                eval(str_function);
                
                %%
                %% Export Subject to BC-VARETA
                %%
                disp(['BC-V -->> Export subject:' , char(subjectID), ' to BC-VARETA structure']);
                export_subject_BCV_structure(selected_data_set,char(subjectID));
            end
        end
    elseif(isequal(selected_data_set.id,'export_to_BCV'))
        new_bst_DB = selected_data_set.bst_db_path;
        bst_set('BrainstormDbDir', new_bst_DB);
        
        gui_brainstorm('UpdateProtocolsList');
        db_import(new_bst_DB);
        
    else
    end
end
% catch exception
%     brainstorm stop;
%     fprintf(2,strcat("\n -->> Protocol stoped \n"));
%     msgText = getReport(exception);
%     fprintf(2,strcat("\n -->> ", string(msgText), "\n"));
% end
end