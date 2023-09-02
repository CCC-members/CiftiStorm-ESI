function Main(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%         Brainstorm Protocol for Automatic Head Model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scripted leadfield pipeline for Freesurfer anatomy files
% Brainstorm (25-Sep-2019) or higher
%
%
%
% Authors
% - Ariosky Areces Gonzalez
% - Deirel Paz Linares
%
%    November 15, 2019

%%
%% Preparing WorkSpace
%%
clc;
close all;
restoredefaultpath;
clearvars -except varargin;
disp('-->> Starting process');
disp('==========================================================================');

%%
%% Preparing properties
%%
addpath(genpath('app'));
addpath('bst_templates');
addpath(genpath('config_properties'));
addpath('external');
addpath(genpath('functions'));
addpath('guide');
addpath(genpath('templates'));
addpath(fullfile('tools'));

%%
%% Init processing
%%
init_processing();

%%
%% Starting mode
%%
setGlobalGuimode(true);
for i=1:length(varargin)
    if(isequal(varargin{i},'nogui'))
        setGlobalGuimode(false);
    end
end
if(getGlobalGuimode())
    CiftiStorm
else    
    %% Checking app properties
    properties  = get_properties();
    if(isequal(properties,'canceled'))
        return;
    end
    [status, reject_subjects]     = check_properties(properties);
    if(~status)
        fprintf(2,strcat('\nBC-V-->> Error: The current configuration files are wrong \n'));
        disp('Please check the configuration files.');
        return;
    end    
    
    %% BrainStorm configuration
    disp('-->> Preparing BrainStorm properties.');
    disp('==========================================================================');
    bst_path        = properties.general_params.bst_config.bst_path;
    addpath(genpath(bst_path));
    status          = starting_brainstorm(properties);
    
    %% Calling dataset function to analysis
    if(status)
        process_error = headmodel_process_interface(properties,reject_subjects);
        save("process_output.mat","process_error","reject_subjects");
    end
    
    %% Stopping BrainStorm
    disp('==========================================================================');
    brainstorm('stop');
    disp('==========================================================================');
    disp(properties.generals.name);
    disp('==========================================================================');
    close all;
    clear all;
end
end


