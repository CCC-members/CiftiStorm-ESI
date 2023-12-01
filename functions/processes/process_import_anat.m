function [anat_error, CSurfaces, properties] = process_import_anat(properties, subID)
% === ANATOMY ===
anat_error = struct;

%%
%% Getting params
%%
anatomy_type    = properties.anatomy_params.anatomy_type;
type            = anatomy_type.id;
mq_control      = properties.general_params.bst_config.after_MaQC.run;

% Get subject definition
[~, iSubject]   = bst_get('Subject', subID);

%%
%% Process: Import Anatomy
%%
if(mq_control)
    CSurfaces           = get_CSurfaces_from_sSubject(properties,iSubject);  
    sub_to_FSAve        = get_FSAve_Surfaces_interpolation(properties,subID);
else    
    if isequal(type, 'default')
        sTemplates      = bst_get('AnatomyDefaults');
        Name            = anatomy_type.template_name;
        sTemplate       = sTemplates(find(strcmpi(Name, {sTemplates.Name}),1));
        surfaces        = {};
        db_set_template( iSubject, sTemplate, false );
        set_Surfaces_Comment(properties,iSubject);
        
        CSurfaces = get_Surfaces_from_template(subID);
        
    else
        non_brain_surfaces  = properties.anatomy_params.common_params.non_brain_surfaces;
        % MRI File
        folderlist          = dir(fullfile(anatomy_type.base_path,subID, '**'));  %get list of files and folders in any subfolder
        folderlist          = folderlist([folderlist.isdir]);  %remove folders from list
        C                   = {folderlist.name};
        idx                 = find(~cellfun('isempty',regexp(C,'T1w')),1);        
        anat_path           = fullfile(folderlist(idx).folder, 'T1w');
        T1w_file            = fullfile(anat_path,anatomy_type.T1w_file_name);
        % Non-Brain surface files
        non_brain_path      = non_brain_surfaces.base_path;
        filelist = dir(fullfile(non_brain_path,subID, '**'));  %get list of files and folders in any subfolder
        filelist = filelist(~[filelist.isdir]);  %remove folders from list
        C = {filelist.name};
        idx = find(~cellfun('isempty',regexp(C,strcat(subID,"_outskin_mesh.nii.gz"))),1);
        head_file = fullfile(filelist(idx).folder,filelist(idx).name);
        idx = find(~cellfun('isempty',regexp(C,strcat(subID,"_outskull_mesh.nii.gz"))),1);
        outerskull_file = fullfile(filelist(idx).folder,filelist(idx).name);
        idx = find(~cellfun('isempty',regexp(C,strcat(subID,"_inskull_mesh.nii.gz"))),1);
        innerskull_file = fullfile(filelist(idx).folder,filelist(idx).name);        
        % Cortex Surfaces
        white_L             = fullfile(anat_path,'fsaverage_LR32k',strcat(subID,'.L.white.32k_fs_LR.surf.gii'));
        white_R             = fullfile(anat_path,'fsaverage_LR32k',strcat(subID,'.R.white.32k_fs_LR.surf.gii'));
        midthickness_L      = fullfile(anat_path,'fsaverage_LR32k',strcat(subID,'.L.midthickness.32k_fs_LR.surf.gii'));
        midthickness_R      = fullfile(anat_path,'fsaverage_LR32k',strcat(subID,'.R.midthickness.32k_fs_LR.surf.gii'));
        pial_L              = fullfile(anat_path,'fsaverage_LR32k',strcat(subID,'.L.pial.32k_fs_LR.surf.gii'));
        pial_R              = fullfile(anat_path,'fsaverage_LR32k',strcat(subID,'.R.pial.32k_fs_LR.surf.gii'));
        
        atlas_file          = fullfile(anat_path,anatomy_type.Atlas_file_name);
        surfaces            = {head_file, outerskull_file, innerskull_file, pial_L, pial_R, midthickness_L, midthickness_R, white_L, white_R, atlas_file};
        properties.anatomy_params.surfaces = surfaces;
        
        %%
        %% Process: Applaying MRI transformation 
        %%
        if(properties.anatomy_params.common_params.mri_transformation.use_transformation)
            [BstMriFile, sMri]  = import_mri(iSubject, T1w_file, 'ALL-MNI', 0);
            %%
            %% Read Transformation
            %%
            base_path           = properties.anatomy_params.common_params.mri_transformation.base_path;
            transformation_ref  = strrep(properties.anatomy_params.common_params.mri_transformation.file_location,'SubID',subID);
            transformation_file = fullfile(base_path,subID,transformation_ref);
            if(isfile(transformation_file))
                apply_mri_transf(BstMriFile, sMri,transformation_file);
            end
        else
            bst_process('CallProcess', 'process_import_mri', [], [], ...
                'subjectname', subID, ...
                'mrifile',     {T1w_file, 'ALL-MNI'});
        end
        %%
        %% Process: Import Surfaces
        %%
        CSurfaces = import_HCP_surfaces(properties, subID, surfaces);
    end   
end

%%
%% Getting report path
%%
report_path = get_report_path(properties, subID);
%%
%% Quality control
%%
% Get MRI file and surface files
[sSubject,~]    = bst_get('Subject', subID);
MriFile         = sSubject.Anatomy(sSubject.iAnatomy).FileName;
hFigMri1        = view_mri_slices(MriFile, 'x', 20);
bst_report('Snapshot',hFigMri1,MriFile,'MRI Axial view', [200,200,900,700]);
try
    savefig( hFigMri1,fullfile(report_path,'MRI Axial view.fig'));
catch
end
close(hFigMri1);

hFigMri2        = view_mri_slices(MriFile, 'y', 20);
bst_report('Snapshot',hFigMri2,MriFile,'MRI Coronal view', [200,200,900,700]);
try
    savefig( hFigMri2,fullfile(report_path,'MRI Coronal view.fig'));
catch
end
close(hFigMri2);

hFigMri3        = view_mri_slices(MriFile, 'z', 20);
bst_report('Snapshot',hFigMri3,MriFile,'MRI Sagital view', [200,200,900,700]);
try
    savefig( hFigMri3,fullfile(report_path,'MRI Sagital view.fig'));
catch
end
close(hFigMri3);

if(isequal(type,'individual'))
    %%
    %% Quality control
    %%
    % Get subject definition and subject files
    sSubject       = bst_get('Subject', subID);
    MriFile        = sSubject.Anatomy(sSubject.iAnatomy).FileName;
    CortexFile     = sSubject.Surface(sSubject.iCortex).FileName;
    InnerSkullFile = sSubject.Surface(sSubject.iInnerSkull).FileName;
    OuterSkullFile = sSubject.Surface(sSubject.iOuterSkull).FileName;
    ScalpFile      = sSubject.Surface(sSubject.iScalp).FileName;    
    %
    hFigMriSurf = view_mri(MriFile, CortexFile);
    hFigMri4    = script_view_contactsheet( hFigMriSurf, 'volume', 'x','');
    bst_report('Snapshot',hFigMri4,MriFile,'Cortex - MRI registration Axial view', [200,200,900,700]);
    try
        savefig( hFigMri4,fullfile(report_path,'Cortex - MRI registration Axial view.fig'));
    catch
    end
    close(hFigMri4);
    %
    hFigMri5    = script_view_contactsheet( hFigMriSurf, 'volume', 'y','');
    bst_report('Snapshot',hFigMri5,MriFile,'Cortex - MRI registration Coronal view', [200,200,900,700]);
    try
        savefig( hFigMri5,fullfile(report_path,'Cortex - MRI registration Coronal view.fig'));
    catch
    end
    close(hFigMri5);
    %
    hFigMri6    = script_view_contactsheet( hFigMriSurf, 'volume', 'z','');
    bst_report('Snapshot',hFigMri6,MriFile,'Cortex - MRI registration Sagital view', [200,200,900,700]);
    try
        savefig( hFigMri6,fullfile(report_path,'Cortex - MRI registration Sagital view.fig'));
    catch
    end
    % Closing figures
    close([hFigMri6,hFigMriSurf]);    
    %
    hFigMri7    = view_mri(MriFile, ScalpFile);
    bst_report('Snapshot',hFigMri7,MriFile,'Scalp registration', [200,200,900,700]);
    try
        savefig( hFigMri7,fullfile(report_path,'Scalp registration.fig'));
    catch
    end
    close(hFigMri7);
    %
    hFigMri8    = view_mri(MriFile, OuterSkullFile);
    bst_report('Snapshot',hFigMri8,MriFile,'Outer Skull - MRI registration', [200,200,900,700]);
    try
        savefig( hFigMri8,fullfile(report_path,'Outer Skull - MRI registration.fig'));
    catch
    end
    close(hFigMri8);
    %
    hFigMri9    = view_mri(MriFile, InnerSkullFile);
    bst_report('Snapshot',hFigMri9,MriFile,'Inner Skull - MRI registration', [200,200,900,700]);
    try
        savefig( hFigMri9,fullfile(report_path,'Inner Skull - MRI registration.fig'));
    catch
    end
    % Closing figures
    close(hFigMri9);
end

end