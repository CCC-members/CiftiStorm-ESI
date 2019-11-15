function selected_datataset_process(selected_data_set)
try
if(isnumeric(selected_data_set.id))
    if(is_check_dataset_properties(selected_data_set))
        disp(strcat('--> Data Source:  ', selected_data_set.hcp_data_path ));
        ProtocolName = selected_data_set.protocol_name;
        subjects = dir(selected_data_set.hcp_data_path);
        subjects_process_error = [];
        subjects_processed =[];
        Protocol_count = 0;
        for j=1:size(subjects,1)
            subject_name = subjects(j).name;
            if(subject_name ~= '.' & string(subject_name) ~="..")
                if( mod(Protocol_count,10) == 0  )
                    ProtocolName_R = strcat(ProtocolName,'_',char(num2str(Protocol_count)));
                    gui_brainstorm('DeleteProtocol',ProtocolName_R);
                    gui_brainstorm('CreateProtocol',ProtocolName_R , 0, 0);
                end
                disp(strcat('-->> Processing subject: ', subject_name));
                
                str_function = strcat(selected_data_set.function,'("',subject_name,'","',ProtocolName_R,'")');
                eval(str_function);
                
                Protocol_count = Protocol_count + 1;
                if( mod(Protocol_count,10) == 0  || j == size(subjects,1))
                    % Genering Manual QC file
                    generate_MaQC_file();
                end
            end
        end
        
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
            end
        end
    end
end
catch
    brainstorm stop;
    fprintf(2,strcat("\n -->> Protocol stoped \n"));
    msgText = getReport(exception);
    fprintf(2,strcat("\n ->> ", msgText, "\n"));   
end
end