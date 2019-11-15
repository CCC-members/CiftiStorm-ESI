%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%               Brainstorm Protocol for Head Model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Scripted leadfield pipeline for Freesurfer anatomy files
% Brainstorm (25-Sep-2019)
%


% Authors
% - Ariosky Areces Gonzalez
% - Deirel Paz Linares
% - Usama Riaz
%
%    September 25, 2019


%% Preparing WorkSpace
restoredefaultpath;
clc;
close all;
clear all;
%%
%------------ Preparing properties --------------------
% brainstorm('stop');
addpath(fullfile('app'));
addpath(fullfile('external'));
addpath(fullfile('functions'));
addpath(fullfile('tools'));
% addpath(strcat('bst_lf_ppl',filesep,'guide'));
%app_properties = jsondecode(fileread(strcat('properties',filesep,'app_properties.json')));
app_properties = jsondecode(fileread(strcat('app',filesep,'app_properties.json')));
app_protocols = jsondecode(fileread(strcat('app',filesep,'app_protocols.json')));
selected_data_set = app_protocols.(strcat('x',app_properties.selected_data_set.value));

%% ------------ Checking MatLab compatibility ----------------
if(~app_check_matlab_version())
   return;
end

%% ------------  Checking updates --------------------------
app_check_version;

disp('------------Preparing BrainStorm properties ---------------');
bst_path =  app_properties.bst_path;
console = false;


%%
run_mode = app_properties.run_bash_mode.value;
if (run_mode)
    console = true;
    if(isempty( bst_path))
        bst_url =  app_properties.bst_url;
        filename = 'brainstorm.zip';
        [filepath,filename,ext] = download_file(url,pwd,filename);
        [folderpath,foldername] = unpackage_file(filename,pwd);
    else
        if(~isfolder(bst_path))
            fprintf(2,'\n ->> Error: The brainstorm path is wrong.');
            return;
        end
    end
else
    if(isempty( bst_path))
        answer = questdlg('Did you download the brainstorm?', ...
            'Select brainstorm source', ...
            'Yes I did','Download','Cancel','Close');
        switch answer
            case 'Yes I did'
                bst_path = uigetdir('tittle','Select the Source Folder');
                if(bst_path==0)
                    disp('User selected Cancel');
                    return;
                end
                app_properties.bs_path=bst_path;
                saveJSON(app_properties,strcat('app_properties.json'));
                
            case 'Download'
                bst_url =  app_properties.bs_url;
                filename = 'brainstorm.zip';
                
                [filepath,filename,ext] = download_file(url,pwd,filename);
                
                [folderpath,foldername] = unpackage_file(filename,pwd);
                
                app_properties.bs_path = fullfile(folderpath,foldername);
                saveJSON(app_properties,strcat('app_properties.json'));
                
            case 'Cancel'
                result = false;
                return;
        end
    end
    guiHandle = protocol_guide;
    disp('------Waitintg for Protocol------');
    uiwait(guiHandle.UIFigure);
    delete(guiHandle);
end
if(isfolder(bst_path) || isfolder(app_properties.spm_path))
    
    % Copying the new file channel
    colin_channel_path = fullfile(bst_path,'defaults','eeg','Colin27');
    channel_GSN_129 = strcat('tools',filesep,'channel_GSN_129.mat');
    channel_GSN_HydroCel_129_E001 = strcat('tools',filesep,'channel_GSN_HydroCel_129_E001.mat');
    copyfile( channel_GSN_129 , colin_channel_path);
    copyfile( channel_GSN_HydroCel_129_E001, colin_channel_path);
    
    addpath(genpath(bst_path));
    addpath(app_properties.spm_path);
    
    %---------------- Starting BrainStorm-----------------------
    if ~brainstorm('status')
        if(console)
            brainstorm nogui local
        else
            brainstorm nogui
            data_folder = uigetdir('tittle','Select the Data Folder');
            if(data_folder==0)
                return;
            end
            app_properties.raw_data_path = data_folder;
            saveJSON(app_properties,strcat('app_properties.json'));
        end
    end
    
    BrainstormDbDir = bst_get('BrainstormDbDir');
    app_properties.bs_db_path = BrainstormDbDir;
    saveJSON(app_properties,strcat('app',filesep,'app_properties.json'));
    
    %-------------- Uploading Data subject --------------------------
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
    brainstorm('stop');
    
else
    fprintf(2,'\n ->> Error: The spm path or brainstorm path are wrong.');
end



