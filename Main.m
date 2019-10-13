%% Brainstorm Protocol
%%%%%%%%%%%%%%%%%%%%


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
   selected_data_set = app_properties.data_set(app_properties.selected_data_set.value);
   selected_data_set = selected_data_set{1,1};
   ProtocolName = selected_data_set.protocol_name;
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
    
    selected_data_set = app_properties.data_set(app_properties.selected_data_set.value);
    ProtocolName = selected_data_set.protocol_name;
end
colin_channel_path = fullfile(bst_path,'defaults','eeg','Colin27');
channel_GSN_129 = strcat('tools',filesep,'channel_GSN_129.mat');
channel_GSN_HydroCel_129_E001 = strcat('tools',filesep,'channel_GSN_HydroCel_129_E001.mat');
copyfile( channel_GSN_129 , colin_channel_path);
copyfile( channel_GSN_HydroCel_129_E001, colin_channel_path);

addpath(genpath(bst_path));
addpath(genpath(app_properties.spm_path));

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
% gui_brainstorm('DeleteProtocol', [char(ProtocolName),'_','1']);
% % 
% gui_brainstorm('CreateProtocol', [char(ProtocolName),'_','1'], 0, 0);



%-------------- Uploading Data subject --------------------------

disp(strcat('--> Data Source:  ', selected_data_set.hcp_data_path ));

subjects = dir(selected_data_set.hcp_data_path);
subjects_process_error = []; 
subjects_processed =[];

for j=1:size(subjects,1)
    subject_name = subjects(j).name;
    if(subject_name ~= '.' & string(subject_name) ~="..")
        if( mod((j-3),10) == 0  )
            Protocol_count = j-3;            
            ProtocolName = strcat(ProtocolName,'_',char(num2str(Protocol_count)));
            gui_brainstorm('DeleteProtocol',ProtocolName);
            gui_brainstorm('CreateProtocol',ProtocolName , 0, 0);
        end
        disp(strcat('--> Processing subject: ', subject_name));
        % Input files
        try
            str_function = strcat(selected_data_set.function,'("',selected_data_set.hcp_data_path,'","',selected_data_set.eeg_data_path,'","',selected_data_set.non_brain_data_path,'","',subject_name,'","',ProtocolName,'")');
            eval(str_function);
            subjects_processed = [subjects_processed ; subject_name] ;
        catch            
            subjects_process_error = [subjects_process_error ; subject_name] ;
            disp(strcat('--> The subject:  ', subject_name, ' have some problen with the input data.' ));
        end
    end
end

save report.mat subjects_processed subjects_process_error;

brainstorm('stop');


