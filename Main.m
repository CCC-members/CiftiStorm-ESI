%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%         Brainstorm Protocol for Automatic Head Model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Scripted leadfield pipeline for Freesurfer anatomy files
% Brainstorm (25-Sep-2019) or higher
%


% Authors
% - Ariosky Areces Gonzalez
% - Deirel Paz Linares
%
%    November 15, 2019


%% Preparing WorkSpace
clc;
close all;
clear all;
disp('-->> Starting process');
restoredefaultpath;

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

if(~isempty(app_properties.selected_data_set.value) && isnumeric(double(app_properties.selected_data_set.value)))

app_protocols = jsondecode(fileread(strcat('app',filesep,'app_protocols.json')));
try
    selected_data_set = app_protocols.(strcat('x',app_properties.selected_data_set.value));
catch
    fprintf(2,"\n ->> Error: The selected_data_set.value in aap\\app_properties.json file have to be a number \n");
end


%% Printing data information
disp(strcat("-->> Name:",app_properties.generals.name));
disp(strcat("-->> Version:",app_properties.generals.version));
disp(strcat("-->> Version date:",app_properties.generals.version_date));
disp("=======================================================");

%% ------------ Checking MatLab compatibility ----------------
disp('-->> Checking installed matlab version');
if(~app_check_matlab_version())
    return;
end

%% ------------  Checking updates --------------------------
disp('-->> Checking project laster version');
if(isequal(app_check_version,'updated'))
    return;
end

%%
disp('-->> Preparing BrainStorm properties.');
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
            fprintf(2,'\n -->> Error: The brainstorm path is wrong.');
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
    brainstorm reset
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
    if(~isequal( app_properties.bst_db_path,"local"))
       bst_set('BrainstormDbDir', app_properties.bst_db_path);
    end
        
    %% Process selected dataset and compute the leadfield subjects
    selected_datataset_process(selected_data_set);
    
    %% Stoping BrainStorm
    brainstorm('stop');
    
else
    fprintf(2,'\n ->> Error: The spm path or brainstorm path are wrong.');
end

else 
    fprintf(2,"\n ->> Error: The selected_data_set.value in aap\\app_properties.json file have to be a number \n");
    disp("______________________________________________________________________________________________");
    disp("Please configure aap\app_properties.json and aap\app_protocols.json files correctly. ")
end

