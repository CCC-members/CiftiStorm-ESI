function status = starting_brainstorm(properties)
%%
%% Starting BrainStorm
%%
bst_path        = properties.general_params.bst_config.bst_path;
addpath(genpath(bst_path));
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
disp('==========================================================================');
disp("CFS -->> Installing external plugins.");
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

end