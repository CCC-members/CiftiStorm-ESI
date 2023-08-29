function apply_mri_transf(BstMriFile, sMri, transformation_file)
bst_progress('start', 'Import HCP MEG/anatomy folder', 'Reading transformations...');
% Read file
fid = fopen(transformation_file, 'rt');
strFid = fread(fid, [1 Inf], '*char');
fclose(fid);
% Evaluate the file (.m file syntax)
eval(strFid);

%%
%% MRI=>MNI Transformation
%%
% Convert transformations from "Brainstorm MRI" to "FieldTrip voxel"
Tbst2ft = [diag([-1, 1, 1] ./ sMri.Voxsize), [size(sMri.Cube,1); 0; 0]; 0 0 0 1];
% Set the MNI=>SCS transformation in the MRI
Tmni = transform.vox07mm2spm * Tbst2ft;
sMri.NCS.R = Tmni(1:3,1:3);
sMri.NCS.T = Tmni(1:3,4);
% Compute default fiducials positions based on MNI coordinates
sMri = mri_set_default_fid(sMri);

%%
%% MRI=>SCS TRANSFORMATION =====
%%

% Set the MRI=>SCS transformation in the MRI
Tscs = transform.vox07mm2bti * Tbst2ft;
sMri.SCS.R = Tscs(1:3,1:3);
sMri.SCS.T = Tscs(1:3,4);
% Standard positions for the SCS fiducials
NAS = [90,   0, 0] ./ 1000;
LPA = [ 0,  75, 0] ./ 1000;
RPA = [ 0, -75, 0] ./ 1000;
Origin = [0, 0, 0];
% Convert: SCS (meters) => MRI (millimeters)
sMri.SCS.NAS    = cs_convert(sMri, 'scs', 'mri', NAS) .* 1000;
sMri.SCS.LPA    = cs_convert(sMri, 'scs', 'mri', LPA) .* 1000;
sMri.SCS.RPA    = cs_convert(sMri, 'scs', 'mri', RPA) .* 1000;
sMri.SCS.Origin = cs_convert(sMri, 'scs', 'mri', Origin) .* 1000;
% Save MRI structure (with fiducials)
bst_save(BstMriFile, sMri, 'v7');
end

