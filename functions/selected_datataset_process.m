function selected_datataset_process(selected_data_set)
% try
if(isnumeric(selected_data_set.id))
    if(is_check_dataset_properties(selected_data_set))
        disp(strcat('-->> Data Source:  ', selected_data_set.hcp_data_path.base_path ));
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
                    if(selected_data_set.bcv_config.export)
                        export_subject_BCV_structure(selected_data_set,subject_name);
                    end
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
        disp('=================================================================');
        disp('=================================================================');
        save report.mat subjects_processed subjects_process_error;
    end
elseif(isequal(selected_data_set.id,''))
    
    % Creating permutations
    
    
    for i=1:2 %length(ProtocolFiles)
        Protocol = load(fullfile(ProtocolFiles(i).folder,ProtocolFiles(i).name));
        protocol_name = Protocol.ProtocolInfo.Comment;
        iProtocol = bst_get('Protocol', protocol_name);
        gui_brainstorm('SetCurrentProtocol', iProtocol);
        subjects = bst_get('ProtocolSubjects');
        for j=1:length(subjects.Subject)
            current_sub = subjects.Subject(j);
            str_function = strcat(selected_data_set.function,'(''',protocol_name,''',''',current_sub.Name,''')');
            eval(str_function);
            %%
            %% Export Subject to BC-VARETA
            %%
            %             if(processed)
            %                 disp(strcat('BC-V -->> Export subject:' , current_sub.Name, ' to BC-VARETA structure'));
            %                 if(selected_data_set.bcv_config.export)
            %                     export_subject_BCV_structure(selected_data_set,current_sub.Name);
            %                 end
            %             end
        end
    end
elseif(isequal(selected_data_set.id,'after_MaQC'))
    % Load all protools
    new_bst_DB = selected_data_set.bst_db_path;
    bst_set('BrainstormDbDir', new_bst_DB);
    
    gui_brainstorm('UpdateProtocolsList');
    nProtocols = db_import(new_bst_DB);
    
    %getting existing protocols on DB
    ProtocolInfo = bst_get('ProtocolInfo');
    ProtocolFiles = dir(fullfile(new_bst_DB,'**','protocol.mat'));
    
    for i=1:2 %length(ProtocolFiles)
        Protocol = load(fullfile(ProtocolFiles(i).folder,ProtocolFiles(i).name));
        protocol_name = Protocol.ProtocolInfo.Comment;
        iProtocol = bst_get('Protocol', protocol_name);
        gui_brainstorm('SetCurrentProtocol', iProtocol);
        subjects = bst_get('ProtocolSubjects');
        for j=1:length(subjects.Subject)
            current_sub = subjects.Subject(j);
            str_function = strcat(selected_data_set.function,'(''',protocol_name,''',''',current_sub.Name,''')');
            eval(str_function);
            %%
            %% Export Subject to BC-VARETA
            %%
            %             if(processed)
            %                 disp(strcat('BC-V -->> Export subject:' , current_sub.Name, ' to BC-VARETA structure'));
            %                 if(selected_data_set.bcv_config.export)
            %                     export_subject_BCV_structure(selected_data_set,current_sub.Name);
            %                 end
            %             end
        end
    end
elseif(isequal(selected_data_set.id,'export_to_BCV'))
    new_bst_DB = selected_data_set.bst_db_path;
    bst_set('BrainstormDbDir', new_bst_DB);
    
    gui_brainstorm('UpdateProtocolsList');
    db_import(new_bst_DB);
    
elseif(isequal(selected_data_set.id,'update_protocol'))
    % ===== LOAD PROTOCOL =====
    %     if ~bst_get('isProtocolLoaded')
    %         db_load_protocol(iProtocol);
    %     end
    
    new_bst_DB = selected_data_set.bst_db_path;
    bst_set('BrainstormDbDir', new_bst_DB);
    
    gui_brainstorm('UpdateProtocolsList');
    nProtocols = db_import(new_bst_DB);
    
    %getting existing protocols on DB
    ProtocolInfo = bst_get('ProtocolInfo');
    ProtocolFiles = dir(fullfile(new_bst_DB,'**','protocol.mat'));
    
    for i=2:length(ProtocolFiles)
        Protocol = load(fullfile(ProtocolFiles(i).folder,ProtocolFiles(i).name));
        protocol_name = Protocol.ProtocolInfo.Comment;
        iProtocol = bst_get('Protocol', protocol_name);
        gui_brainstorm('SetCurrentProtocol', iProtocol);
        subjects = bst_get('ProtocolSubjects');
        for j=1:length(subjects.Subject)
            current_sub = subjects.Subject(j);
            processed =  protocol_headmodel_EEG_from_MEG(protocol_name,current_sub.Name);
            %%
            %% Export Subject to BC-VARETA
            %%
            %             if(processed)
            %                 disp(strcat('BC-V -->> Export subject:' , current_sub.Name, ' to BC-VARETA structure'));
            %                 if(selected_data_set.bcv_config.export)
            %                     export_subject_BCV_structure(selected_data_set,current_sub.Name);
            %                 end
            %             end
        end
    end
    
else
end

% catch exception
%     brainstorm stop;
%     fprintf(2,strcat("\n -->> Protocol stoped \n"));
%     msgText = getReport(exception);
%     fprintf(2,strcat("\n -->> ", string(msgText), "\n"));
% end
end