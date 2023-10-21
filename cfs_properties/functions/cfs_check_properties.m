function checked = cfs_check_properties( varargin )
checked = true;
if ((nargin >= 1) && ischar(varargin{1}))
    contextName = varargin{1};
else
    return
end
if((nargin >= 2))
    path = varargin{2};
    path = strrep(path,'\','/');
else
    return;
end
if((nargin >= 3))
    ref_file = varargin{3};
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
    
    %% Anatomy
    case 'output_path'
        if(~isfolder(fullfile(path)) && ~isequal(path,'local'))
            checked = false;
        end
        [~,values] = fileattrib(path);
        if(~values.UserWrite)
            checked = false;
        end
    case 'indiv_anat_path'
        if(~isfolder(path))
             checked = false;
             return;
        end
        structures = dir(path);
        structures(ismember( {structures.name}, {'.', '..'})) = [];  %remove . and ..
        count = 0;
        for i=1:length(structures)
            structure = structures(i);
            if(~isfile(fullfile(structure.folder,structure.name,'T1w','T1w.nii.gz'))...
                    && ~isfile(fullfile(structure.folder,structure.name,'T1w','T1w_acpc_dc_restore.nii.gz'))...
                    && ~isfile(fullfile(structure.folder,structure.name,'T1w','T1w_acpc_dc.nii.gz'))...
                    && ~isfile(fullfile(structure.folder,structure.name,'T1w','T2w.nii.gz'))...
                    && ~isfile(fullfile(structure.folder,structure.name,'T1w','T2w_acpc_dc_restore.nii.gz'))...
                    && ~isfile(fullfile(structure.folder,structure.name,'T1w','T2w_acpc_dc.nii.gz')))
                count = count + 1;
            end
        end
        if(isequal(count,length(structures)))
            checked = false;
        end
    case 'non_brain_path'
        if(~isfolder(path))
             checked = false;
             return;
        end
        structures = dir(path);
        structures(ismember( {structures.name}, {'.', '..'})) = [];  %remove . and ..
        count = 0;
        for i=1:length(structures)
            structure = structures(i);
            if(~isfile(fullfile(structure.folder,structure.name,[structure.name,'_outskin_mesh.nii.gz']))...
                    || ~isfile(fullfile(structure.folder,structure.name,[structure.name,'_outskull_mesh.nii.gz']))...
                    || ~isfile(fullfile(structure.folder,structure.name,[structure.name,'_inskull_mesh.nii.gz'])))
                count = count + 1;
            end
        end
        if(isequal(count,length(structures)))
           checked = false;
        end
    case 'mri_transf_path'
        if(~isfolder(path))
            checked = false;
            return;
        end
        structures = dir(path);
        structures(ismember( {structures.name}, {'.', '..'})) = [];  %remove . and ..
        count = 0;
        for i=1:length(structures)
            structure = structures(i);
            SubID = structure.name;
            tmp_file = strrep(ref_file,'SubID',SubID);
            if(~isfile(fullfile(structure.folder,structure.name,tmp_file)))
                count = count + 1;
            end
        end
        if(isequal(count,length(structures)))
           checked = false;
        end
    %% Channel
    case 'raw_data_path'
        if(~isfolder(path))
            checked = false;
            return;
        end
        structures = dir(path);
        structures(ismember( {structures.name}, {'.', '..'})) = [];  %remove . and ..
        count = 0;
        for i=1:length(structures)
            structure = structures(i);
            SubID = structure.name;
            tmp_file = strrep(ref_file,'SubID',SubID);
            if(~isfile(fullfile(structure.folder,structure.name,tmp_file)))
                count = count + 1;
            end
        end
        if(isequal(count,length(structures)))
           checked = false;
        end

    %% Headmodel
end

end

