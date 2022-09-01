function checked = check_HCP_anat_structure(base_path,SubID, properties)

checked = true;
head_file = "SubID_outskin_mesh.nii.gz";
outer_file = "SubID_outskull_mesh.nii.gz";
inner_file = "SubID_inskull_mesh.nii.gz";
if(~isfile(head_file) || ~isfile(outer_file) || ~isfile(inner_file))
    checked = false;    
end

end

