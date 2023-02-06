function checked = check_non_brain_surfaces(base_path,file_location,SubID)

checked = true;
head_file = fullfile(base_path,SubID,strcat(SubID,"_outskin_mesh.nii.gz"));
outer_file = fullfile(base_path,SubID,strcat(SubID,"_outskull_mesh.nii.gz"));
inner_file = fullfile(base_path,SubID,strcat(SubID,"_inskull_mesh.nii.gz"));
if(~isfile(head_file) || ~isfile(outer_file) || ~isfile(inner_file))
    checked = false;    
end

end

