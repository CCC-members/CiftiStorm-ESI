function [output1, output2, output3]   = cfs_get( varargin )

if ((nargin >= 1) && ischar(varargin{1}))
    contextName = varargin{1};
else
    return
end

% Get required context structure
switch contextName
    case 'cfs_dir'
        output1 = fullfile(getUserDir(),'.ciftistorm');
    case 'defaults_dir'
        cfs_db_dir = fullfile(getUserDir(),'.ciftistorm');
        output1 =  fullfile(cfs_db_dir,'defaults','anatomy');
        output2 =  fullfile(cfs_db_dir,'defaults','eeg');
        output3 =  fullfile(cfs_db_dir,'defaults','meg');
    case 'dataset'


end