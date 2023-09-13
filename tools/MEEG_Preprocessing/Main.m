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
% restoredefaultpath;

%%
%------------ Preparing properties --------------------
% brainstorm('stop');
addpath(fullfile('app'));
addpath(fullfile('config_labels'));
addpath(fullfile('config_properties'));
addpath(genpath(fullfile('functions')));
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
disp(strcat("-->> Name: ",app_properties.generals.name));
disp(strcat("-->> Version: ",app_properties.generals.version));
disp(strcat("-->> Version date: ",app_properties.generals.version_date));
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
[status, reject_subjects]    = check_properties(properties);
if(~status)
    fprintf(2,strcat('\nBC-V-->> Error: The current configuration files are wrong \n'));
    disp('Please check the configuration files.');
    return;
end

%%
%% Getting params
%%
properties.general_params       = properties.general_params.params;
properties.prep_data_params     = properties.prep_data_params.params;

if(isfile(properties.general_params.colormap))
    load(properties.general_params.colormap);
else
    load('tools/mycolormap.mat');
end

%%
%% Starting EEGLAB
%%
if(properties.prep_data_params.clean_data.run)
    toolbox = properties.prep_data_params.clean_data.toolbox;

    switch toolbox
        case 'eeglab'
            if(isfile(fullfile(properties.prep_data_params.clean_data.toolbox_path,'eeglab.m')))
                toolbox_path    = properties.prep_data_params.clean_data.toolbox_path;
                addpath(toolbox_path);
                eeglab nogui;
            else
                fprintf(2,'\n ->> Error: The eeglab path is wrong.');
            end
    end
end

%%
%% Calling dataset function to analysis
%%
process_error = process_interface(properties, reject_subjects);

restoredefaultpath;
disp('-->> Process finished...');
disp("=================================================================");
close all;
clear all;




