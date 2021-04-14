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
addpath(fullfile('config_StP_prop'));
addpath(fullfile('external'));
addpath(genpath(fullfile('functions')));
addpath('guide');
addpath(genpath('plugins'));
addpath(fullfile('templates'));
addpath(fullfile('tools'));

try
    app_properties = jsondecode(fileread(fullfile('app','properties.json')));
catch EM
    fprintf(2,"\n ->> Error: The app/properties file do not have a correct format \n");
    disp("-->> Message error");
    disp(EM.message);
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
%% ------------  Checking app properties --------------------------
properties  = get_properties();
if(isequal(properties,'canceled'))
    return;
end
status      = check_properties(properties);
if(~status)
    fprintf(2,strcat('\nBC-V-->> Error: The current configuration files are wrong \n'));
    disp('Please check the configuration files.');
    return;
end
if(~check_app_properties(app_properties))
    return;
end



try
    selected_dataset = jsondecode(fileread(fullfile('config_protocols',app_properties.selected_data_set.file_name)));
catch EM
    fprintf(2,"\n ->> Error: The selected_data_set file in config_protocols do not have a correct format \n");
    disp("-->> Message error");
    disp(EM.message);
    disp('-->> Process stoped!!!');
    return;
end
if(~check_dataset_properties(selected_dataset))
    return;
end
%%
disp('-->> Preparing BrainStorm properties.');
bst_path =  app_properties.bst_path;
spm_path = app_properties.spm_path;
addpath(genpath(bst_path));
addpath(spm_path);

%---------------- Starting BrainStorm-----------------------
brainstorm reset
if ~brainstorm('status')
    brainstorm nogui local
    bst_set('SpmDir', app_properties.spm_path);
end
if(~isequal( app_properties.bst_db_path,'local'))
    bst_set('BrainstormDbDir', app_properties.bst_db_path);
end

if(selected_dataset.preprocessed_data.clean_data.run)
    toolbox = selected_dataset.preprocessed_data.clean_data.toolbox;
    switch toolbox
        case 'eeglab'
            if(isfile(fullfile(selected_dataset.preprocessed_data.clean_data.toolbox_path,'eeglab.m')))
                toolbox_path    = selected_dataset.preprocessed_data.clean_data.toolbox_path;
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
str_function = strcat(selected_dataset.function_name,'();');
eval(str_function);

%% Stoping BrainStorm
disp("=================================================================");
brainstorm('stop');
close all;
clear all;




