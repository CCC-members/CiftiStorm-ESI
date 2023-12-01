function status = starting_brainstorm(properties)
%%
%% Starting BrainStorm
%%
status = true;
brainstorm reset
brainstorm nogui local
if(isempty(properties.general_params.bst_config.db_path) || isequal(properties.general_params.bst_config.db_path,'local'))
    db_import(bst_get('BrainstormDbDir'));
else
    bst_db_path     = properties.general_params.bst_config.db_path;
    bst_set('BrainstormDbDir', bst_db_path);
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
    disp('-->> Process stopped!!!');
    status = false;
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
        disp('-->> Process stopped!!!');
        status = false;
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
        disp('-->> Process stopped!!!');
        status = false;
        return;
    end
end

%%
%% Checking templates
%%
if(isequal(lower(properties.anatomy_params.anatomy_type.id),'template'))
    anatomy_type    = properties.anatomy_params.anatomy_type;
    sTemplates      = bst_get('AnatomyDefaults');
    Name            = anatomy_type.template_name;
    sTemplate       = sTemplates(find(strcmpi(Name, {sTemplates.Name}),1));
    if(isempty(sTemplate))
        fprintf(2,'\n ->> Error: The selected anatomy template is wrong.');
        disp(Name);
        disp("Please, type a correct anatomy template in configuration file.");
        disp("The process will be stoped!!!");
        status = false;
        return;
    end
end
if(isequal(lower(properties.channel_params.channel_type.id),'default'))
    % ===== GET DEFAULT =====
    % Get registered Brainstorm EEG defaults
    channel_params          = properties.channel_params.channel_type;
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
        status = false;
        return;
    end
    iLayout                 = strcmpi(nameLayout, {bstDefaults(iGroup).contents.name});
    if(isempty(find(iLayout,1)))
        fprintf(2,'\n ->> Error: The selected channel layout is wrong.');
        disp(nameLayout);
        disp("Please, type a correct Channel layout name");
        disp("The process will be stoped!!!");
        status = false;
        return;
    end
end

end