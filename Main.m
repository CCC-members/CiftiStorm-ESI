%% Brainstorm Protocol
%%%%%%%%%%%%%%%%%%%%


% Scripted leadfield pipeline for Freesurfer anatomy files
% Brainstorm (24-Feb-2019)
% Andy Hu, Feb. 24, 2019


% Authors
% - Ariosky Areces Gonzalez
% - Deirel Paz Linares
% - Usama Riaz
%
%    September 25, 2019


%%
%------------ Preparing properties --------------------
% brainstorm('stop');
addpath(fullfile('app'));
addpath(fullfile('functions'));
addpath(fullfile('tools'));
% addpath(strcat('bst_lf_ppl',filesep,'properties'));
% addpath(strcat('bst_lf_ppl',filesep,'guide'));
%app_properties = jsondecode(fileread(strcat('properties',filesep,'app_properties.json')));
app_properties = jsondecode(fileread(strcat('app',filesep,'app_properties.json')));

disp('------------Preparing BrianStorm properties ---------------');
bst_path =  app_properties.bst_path;
console = false;

run_mode = app_properties.run_bash_mode.value;
if (run_mode)
    console = true;
    if(isempty( bst_path))
        bst_url =  app_properties.bst_url;
        filename = 'brainstorm.zip';
        [filepath,filename,ext] = download_file(url,pwd,filename);
        [folderpath,foldername] = unpackage_file(filename,pwd);
    end
    ProtocolName = app_properties.protocol_name;
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
    ProtocolName = app_properties.protocol_name;
end

addpath(genpath(bst_path));

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

        
% Delete existing protocol
% brainstorm('start');
gui_brainstorm('DeleteProtocol', ProtocolName);
% Create new protocol
gui_brainstorm('CreateProtocol', ProtocolName, 0, 0);



%-------------- Uploading Data subject --------------------------
eeg_data_path = app_properties.eeg_data_path;
anat_data_path = app_properties.anat_data_path;
hcp_data_path = app_properties.hcp_data_path;
disp(strcat('--> Data Source:  ', hcp_data_path ));
app_properties.hcp_data_path
subjects = dir(hcp_data_path);
subjects_process_error = [];  
for j=1:size(subjects,1)
    subject_name = subjects(j).name;
    if(isfolder(fullfile(eeg_data_path,subject_name)) & isfolder(fullfile(hcp_data_path,subject_name)) & subject_name ~= '.' & string(subject_name) ~="..")
        disp(strcat('--> Processing subject: ', subject_name));
        % Input files
        selected_data_set = app_properties.data_set(app_properties.selected_data_set.value);
        str_function = strcat(selected_data_set.function,'("',eeg_data_path,'","',hcp_data_path,'","',subject_name,'","',ProtocolName,'")');        
        eval(str_function);
    end
    if(~isfolder(fullfile(eeg_data_path,subject_name)) || ~isfolder(fullfile(hcp_data_path,subject_name)))
        subjects_process_error = [subjects_process_error ; subject_name] ;
        disp(strcat('--> The subject:  ', subject_name, ' have some problen with the input data.' ));
    end
end

brainstorm('stop');



