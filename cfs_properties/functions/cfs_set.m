function cfs_set( varargin )

if ((nargin >= 2) && ischar(varargin{1}))
    contextName = varargin{1};
    data = varargin{2};
else
    return
end

% Get required context structure
switch contextName
    case 'cfs_dir'
        output1 = fullfile(getUserDir(),'.CiftiStorm');
    case 'defaults_dir'
        cfs_db_dir = fullfile(getUserDir(),'.CiftiStorm');
        output1 =  fullfile(cfs_db_dir,'defaults','anatomy');
        output2 =  fullfile(cfs_db_dir,'defaults','eeg');
        output3 =  fullfile(cfs_db_dir,'defaults','meg');
    case 'datasets'
        if(~isfolder(fullfile(getUserDir(),'.CiftiStorm')))
            mkdir(fullfile(getUserDir(),'.CiftiStorm'));
        end
        if(~isfolder(fullfile(getUserDir(),'.CiftiStorm','Datasets')))
            mkdir(fullfile(getUserDir(),'.CiftiStorm','Datasets'));
        end
        saveJSON(data,fullfile(getUserDir(),'.CiftiStorm','Datasets','Datasets.json')) 

    case 'bst_default_eeg'
        output1 = 'https://github.com/brainstorm-tools/brainstorm3/raw/master/defaults/eeg';

    case 'openmeeg'
        
    case 'duneruro'
end

end