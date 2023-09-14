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
addpath('tools/Common');
addpath(genpath('tools/MEEGprep'));

try
    app_properties = jsondecode(fileread(fullfile('app','properties.json')));
catch EM
    fprintf(2,"\n ->> Error: The app/properties file do not have a correct format \n");
    disp("-->> Message error");
    disp(EM.message);
    disp('-->> Process stopped!!!');
    return;
end

%%
%% Init processing
%%
init_processing("tools/MEEGprep/app/properties.json");

%% ------------  Checking app properties --------------------------
properties  = prep_get_properties();
if(isequal(properties,'canceled'))
    return;
end
[status, reject_subjects]    = prep_check_properties(properties);
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
    load('tools/Common/mycolormap.mat');
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




