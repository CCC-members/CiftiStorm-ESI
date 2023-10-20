function checked = cfs_check_properties( varargin )
checked = true;
if ((nargin >= 1) && ischar(varargin{1}))
    contextName = varargin{1};
else
    return
end

% Get required context structure
switch contextName
    %% General
    case 'BST_path'
        if(~isfile(fullfile(path,'brainstorm.m')))
            checked = false;
        end
    case 'BST_db'
        if(~isfolder(fullfile(path)) && ~isequal(path,'local'))
            checked = false;
        end
        [~,values] = fileattrib(path);
        if(values.UserWrite)
            app.BSTdbpathEditField.Value = folder;
        end
    case 'output_path'


    %% Anatomy

    %% Channel

    %% Headmodel
end

end

