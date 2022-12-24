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
clear all;
restoredefaultpath;
disp('-->> Starting process');

%%
%% Preparing properties
%%
addpath(fullfile('app'));
addpath('bst_templates');
addpath(fullfile('config_labels'));
addpath(fullfile('config_properties'));
addpath(fullfile('external'));
addpath(genpath(fullfile('functions')));
addpath('guide');
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

%%
%% Printing data information
%%
disp(strcat("-->> Name: ",app_properties.generals.name));
disp(strcat("-->> Version: ",app_properties.generals.version));
disp(strcat("-->> Version date: ",app_properties.generals.version_date));
disp('==========================================================================');

%%
%% Checking MatLab compatibility
%%
disp('-->> Checking installed matlab version');
if(~check_matlab_version())
    return;
end

%%
%% Checking updates
%%
disp('-->> Checking project laster version');
if(isequal(check_version,'updated'))
    return;
end

%%
%% Checking app properties
%%
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

properties.general_params       = properties.general_params.params;
properties.anatomy_params       = properties.anatomy_params.params;
properties.channel_params       = properties.channel_params.params;
properties.headmodel_params     = properties.headmodel_params.params;

if(isfile(properties.general_params.colormap))
    load(properties.general_params.colormap);
else
    load('tools/mycolormap.mat');
end
%%
disp('-->> Preparing BrainStorm properties.');
disp('==========================================================================');
bst_path        = properties.general_params.bst_config.bst_path;
bst_db_path     = properties.general_params.bst_config.db_path;
spm_path        = properties.general_params.spm_config.spm_path;
addpath(genpath(bst_path));
addpath(spm_path);

%%
%% Starting BrainStorm
%%
brainstorm reset
brainstorm nogui local
BrainstormUserDir = bst_get('BrainstormUserDir');
if(isempty(properties.general_params.bst_config.db_path) || isequal(properties.general_params.bst_config.db_path,'local'))       
    db_import(bst_get('BrainstormDbDir'));
else
    bst_set('BrainstormDbDir', app_properties.bst_db_path);
    db_import(properties.general_params.bst_config.db_path);
end

%%
%% Loading BST modules
%%
disp("-->> Installing external plugins.");
disp('==========================================================================');
if(~isempty(bst_plugin('GetInstalled', 'spm12')))
    [isOk, errMsg, PlugDesc] = bst_plugin('Unload', 'spm12');
end
[isOk, errMsg, PlugDesc] = bst_plugin('Install', 'spm12', 0, []);
if(isOk)
    [isOk, errMsg, PlugDesc] = bst_plugin('Load', 'spm12');
else
    fprintf(2,"\n ->> Error: We can not install the spm12 plugin. Please see the fallow error and restart the process. \n");
    disp("-->> Message error");
    disp(errMsg);
    disp('-->> Process stoped!!!');
    return;
end
if(isempty(bst_plugin('GetInstalled', 'openmeeg')))
    [isOk, errMsg, PlugDesc] = bst_plugin('Install', 'openmeeg', 0, []);
    if(isOk)
        [isOk, errMsg, PlugDesc] = bst_plugin('Load', 'openmeeg');
    else
        fprintf(2,"\n ->> Error: We can not install tha openmeeg plugin. Please see the fallow error and restart the process. \n");
        disp("-->> Message error");
        disp(errMsg);
        disp('-->> Process stoped!!!');
        return;
    end
end
if(isempty(bst_plugin('GetInstalled', 'duneuro')))
    [isOk, errMsg, PlugDesc] = bst_plugin('Install', 'duneuro', 0, []);
    if(isOk)
        [isOk, errMsg, PlugDesc] = bst_plugin('Load', 'duneuro');
    else
        fprintf(2,"\n ->> Error: We can not install tha duneuro plugin. Please see the fallow error and restart the process. \n");
        disp("-->> Message error");
        disp(errMsg);
        disp('-->> Process stoped!!!');
        return;
    end
end

%%
%% Checking templates
%%
if(isequal(properties.anatomy_params.anatomy_type.type,1))
    anatomy_type    = properties.anatomy_params.anatomy_type.type_list{1};
    sTemplates      = bst_get('AnatomyDefaults');
    Name            = anatomy_type.template_name;
    sTemplate       = sTemplates(find(strcmpi(Name, {sTemplates.Name}),1));
    if(isempty(sTemplate))
        fprintf(2,'\n ->> Error: The selected anatomy template is wrong.');
        disp(Name);
        disp("Please, type a correct anatomy template in configuration file.");
        disp("The process will be stoped!!!");
        return;
    end
end
if(isequal(properties.channel_params.channel_type.type,2))
    % ===== GET DEFAULT =====
    % Get registered Brainstorm EEG defaults
    channel_params          = properties.channel_params.chann_config;
    bstDefaults             = bst_get('EegDefaults');
    nameGroup               = channel_params.group_layout_name;
    nameLayout              = channel_params.channel_layout_name;
    copyfile("templates/channel_GSN_129.mat",fullfile(bst_get('BrainstormHomeDir'),"defaults","eeg",nameGroup));
    copyfile("templates/channel_GSN_HydroCel_129_E001.mat",fullfile(bst_get('BrainstormHomeDir'),"defaults","eeg",nameGroup));
    iGroup                  = find(strcmpi(nameGroup, {bstDefaults.name}));
    if(isempty(iGroup))
        fprintf(2,'\n ->> Error: The selected channel template group name is wrong.');
        disp(nameGroup);
        disp("Please, type a correct  Channel group name");
        disp("The process will be stoped!!!");
        return;
    end
    iLayout                 = strcmpi(nameLayout, {bstDefaults(iGroup).contents.name});
    if(isempty(find(iLayout,1)))
        fprintf(2,'\n ->> Error: The selected channel layout is wrong.');
        disp(nameLayout);
        disp("Please, type a correct Channel layout name");
        disp("The process will be stoped!!!");
        return;
    end
end

%% Process selected dataset and compute the leadfield subjects
%%
%% Calling dataset function to analysis
%%
process_error = headmodel_process_interface(properties,reject_subjects);
save("process_output.mat","process_error","reject_subjects");

%% Stoping BrainStorm
disp('==========================================================================');
brainstorm('stop');
close all;
clear all;




