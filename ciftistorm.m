function ciftistorm(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%         Automatic Head Model Processing
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
disp('CFS -->> Starting process');
disp('==========================================================================');

%%
%% Preparing properties
%%
addpath(genpath('app'));
addpath('bst_defaults');
addpath(genpath('cfs_properties'));
addpath('external');
addpath(genpath('functions'));
addpath(genpath('guide'));
addpath(genpath('templates'));
addpath(genpath('tools'));

%%
%% Init processing
%%
init_processing("app/properties.json");

%%
%% Starting mode
%%
setGlobalGuimode(true);
setGlobalVerbose(false);
for i=1:length(varargin)
    if(isequal(lower(varargin{i}),'nogui'))
        setGlobalGuimode(false);
    end
    if(isequal(lower(varargin{i}),'verbose'))
        setGlobalVerbose(true);
    end
end
if(getGlobalGuimode())
    CiftiStorm
else 
    %% Checking app properties
    properties  = get_properties('run');
    if(isequal(properties,'canceled'))
        return;
    end
    [status, reject_subjects]   = check_properties(properties);
    if(~status)
        fprintf(2,strcat('\n-->> Error: The current configuration files are wrong \n'));
        disp('Please check the configuration files.');
        return;
    end    
    
    %% BrainStorm configuration
    disp('CFS -->> Preparing BrainStorm properties.');
    disp('==========================================================================');    
    status          = starting_brainstorm(properties);
    
    %% Calling dataset function to analysis
    if(status)
        datasetFile = cfs_process_interface(properties,reject_subjects, []);
        dataset = jsondecode(fileread(datasetFile));
        datasets  = cfs_get('datasets');
        if(isempty(datasets))            
            datasets = dataset;
        else
            datasets(end+1) = dataset;
        end
        cfs_set('datasets',datasets);
    end
    
    %% Stopping BrainStorm
    disp('==========================================================================');
    brainstorm('stop');
    disp('==========================================================================');
    disp("CFS -->> Process Finished.");
    disp('==========================================================================');
    close all;
    clear all;
end
end


