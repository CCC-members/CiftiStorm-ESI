function checked = cfs_check_properties( varargin )
checked = true;
if ((nargin >= 1) && ischar(varargin{1}))
    contextName = varargin{1};
else
    return
end
if((nargin >= 2))
    path = varargin{2};
else
    return;
end

% Check case parameters
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
        if(~values.UserWrite)
            checked = false;
        end
    case 'output_path'
        if(~isfolder(fullfile(path)) && ~isequal(path,'local'))
            checked = false;
        end
        [~,values] = fileattrib(path);
        if(~values.UserWrite)
            checked = false;
        end

    %% Anatomy

    %% Channel

    %% Headmodel
end

end

