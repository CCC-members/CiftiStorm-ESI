function checked = check_non_brain_surfaces(structure)

checked = true;
SubID = structure.name;
filelist = dir(fullfile(structure.folder,SubID, '**'));  %get list of files and folders in any subfolder
filelist = filelist(~[filelist.isdir]);  %remove folders from list
C = {filelist.name};
idx = find(~cellfun('isempty',regexp(C,strcat(SubID,"_outskin_mesh.nii.gz"))),1);
if(isempty(idx))   
    checked = false; 
    return;
end
idx = find(~cellfun('isempty',regexp(C,strcat(SubID,"_outskull_mesh.nii.gz"))),1);
if(isempty(idx))   
    checked = false; 
    return;
end
idx = find(~cellfun('isempty',regexp(C,strcat(SubID,"_inskull_mesh.nii.gz"))),1);
if(isempty(idx))   
    checked = false; 
    return;
end
end

