function checked = check_HCP_anat_structure(anat_path,SubID, properties)

checked = true;
t1w             = fullfile(anat_path,properties.T1w_file_name);
white_L         = fullfile(anat_path,'fsaverage_LR32k',strcat(SubID,'.L.white.32k_fs_LR.surf.gii'));
white_R         = fullfile(anat_path,'fsaverage_LR32k',strcat(SubID,'.R.white.32k_fs_LR.surf.gii'));
midthickness_L  = fullfile(anat_path,'fsaverage_LR32k',strcat(SubID,'.L.midthickness.32k_fs_LR.surf.gii'));
midthickness_R  = fullfile(anat_path,'fsaverage_LR32k',strcat(SubID,'.R.midthickness.32k_fs_LR.surf.gii'));
pial_L          = fullfile(anat_path,'fsaverage_LR32k',strcat(SubID,'.L.pial.32k_fs_LR.surf.gii'));
pial_R          = fullfile(anat_path,'fsaverage_LR32k',strcat(SubID,'.R.pial.32k_fs_LR.surf.gii'));
atlas           = fullfile(anat_path,properties.Atlas_file_name); 
if(~isfile(t1w) || ~isfile(white_L) || ~isfile(white_R) || ~isfile(midthickness_L) || ~isfile(midthickness_R) || ~isfile(pial_L) || ~isfile(pial_R) || ~isfile(atlas))
    checked = false;    
end

end
