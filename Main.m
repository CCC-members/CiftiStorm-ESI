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
addpath('bst_templates');
addpath(fullfile('config_labels'));
addpath(fullfile('config_MaQC'));
addpath(fullfile('config_protocols'));
addpath(fullfile('external'));
addpath(genpath(fullfile('functions')));
addpath(genpath('plugins'));
addpath(fullfile('templates'));
addpath(fullfile('tools'));
% addpath(strcat('bst_lf_ppl',filesep,'guide'));
%app_properties = jsondecode(fileread(strcat('properties',filesep,'app_properties.json')));
app_properties = jsondecode(fileread(fullfile('app','properties.json')));

if(isfile(fullfile("config_protocols",app_properties.selected_data_set.file_name)))    
    try
        selected_data_set = jsondecode(fileread(fullfile('config_protocols',app_properties.selected_data_set.file_name)));
    catch
        fprintf(2,"\n ->> Error: The selected_data_set file in config_protocols do not have a correct format \n");
        disp('-->> Process stoped!!!');
        return;
    end
    
    %% Printing data information
    disp(strcat("-->> Name:",app_properties.generals.name));
    disp(strcat("-->> Version:",app_properties.generals.version));
    disp(strcat("-->> Version date:",app_properties.generals.version_date));
    disp("=================================================================");
    
    %% ------------ Checking MatLab compatibility ----------------
    disp('-->> Checking installed matlab version');
    if(~check_matlab_version())
        return;
    end
    
    %% ------------  Checking updates --------------------------
    disp('-->> Checking project laster version');
    if(isequal(check_version,'updated'))
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
                    saveJSON(app_properties,strcat('properties.json'));
                    
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
    if(isfolder(bst_path) && isfolder(app_properties.spm_path))       
        addpath(genpath(bst_path));
        addpath(app_properties.spm_path);
        
        %---------------- Starting BrainStorm-----------------------
        brainstorm reset
        if ~brainstorm('status')
            if(console)
                brainstorm nogui local
                bst_set('SpmDir', app_properties.spm_path);
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
        if(~isequal( app_properties.bst_db_path,'local'))
            bst_set('BrainstormDbDir', app_properties.bst_db_path);
        end
        
        if(selected_data_set.preprocessed_data.clean_data.run)
            toolbox = selected_data_set.preprocessed_data.clean_data.toolbox;
            switch toolbox
                case 'eeglab'
                    if(isfile(fullfile(selected_data_set.preprocessed_data.clean_data.toolbox_path,'eeglab.m')))
                        toolbox_path    = selected_data_set.preprocessed_data.clean_data.toolbox_path;
                        addpath(toolbox_path);
                        eeglab nogui;
                    else
                        fprintf(2,'\n ->> Error: The eeglab path is wrong.');
                    end            
            end
        else
        end
        
        %% Process selected dataset and compute the leadfield subjects
        %%
        %% Calling dataset function to analysis
        %%
        str_function = strcat(selected_data_set.function_name,'();');
        eval(str_function);
        
        %% Stoping BrainStorm
        disp("=================================================================");
        brainstorm('stop');
        close all;
        clear all;
        
    else
        fprintf(2,'\n ->> Error: The spm path or brainstorm path are wrong.');
    end    
else
    fprintf(2,strcat("\n ->> Error: The file ",app_properties.selected_data_set.file_name," do not exit \n"));
    disp("______________________________________________________________________________________________");
    disp("Please configure app_properties.selected_data_set.file_name element in app/properties file. ")
end

