function [anat_error, CSurfaces, sub_to_FSAve] = process_import_anat(properties, type, iSubject, subID)
% === ANATOMY ===
anat_error = struct;

%%
%% Getting params
%%
anatomy_type    = properties.anatomy_params.anatomy_type.type_list{properties.anatomy_params.anatomy_type.type};


%%
%% Process: Import Anatomy
%%
if isequal(type, 'default')
    anatomy_type    = properties.anatomy_params.anatomy_type.type_list{1};
    sTemplates      = bst_get('AnatomyDefaults');
    Name            = anatomy_type.template_name;
    sTemplate       = sTemplates(find(strcmpi(Name, {sTemplates.Name}),1));
    surfaces        = {};
    db_set_template( iSubject, sTemplate, false );      
else
    non_brain_surfaces  = properties.anatomy_params.non_brain_surfaces;
    
    % MRI File
    anat_path           = fullfile(anatomy_type.base_path, subID, strrep(anatomy_type.HCP_anat_path, 'SubID', subID), 'T1w');
    T1w_file            = fullfile(anat_path,anatomy_type.T1w_file_name);
    % Non-Brain surface files
    base_path           = non_brain_surfaces.base_path;
    head_file           = fullfile(base_path,subID,strcat(subID,"_outskin_mesh.nii.gz"));
    outerskull_file     = fullfile(base_path,subID,strcat(subID,"_outskull_mesh.nii.gz"));
    innerskull_file     = fullfile(base_path,subID,strcat(subID,"_inskull_mesh.nii.gz"));
    % Cortex Surfaces
    white_L             = fullfile(anat_path,'fsaverage_LR32k',strcat(subID,'.L.white.32k_fs_LR.surf.gii'));
    white_R             = fullfile(anat_path,'fsaverage_LR32k',strcat(subID,'.R.white.32k_fs_LR.surf.gii'));
    midthickness_L      = fullfile(anat_path,'fsaverage_LR32k',strcat(subID,'.L.midthickness.32k_fs_LR.surf.gii'));
    midthickness_R      = fullfile(anat_path,'fsaverage_LR32k',strcat(subID,'.R.midthickness.32k_fs_LR.surf.gii'));
    pial_L              = fullfile(anat_path,'fsaverage_LR32k',strcat(subID,'.L.pial.32k_fs_LR.surf.gii'));
    pial_R              = fullfile(anat_path,'fsaverage_LR32k',strcat(subID,'.R.pial.32k_fs_LR.surf.gii'));
    surfaces            = {head_file, outerskull_file, innerskull_file, pial_L, pial_R, midthickness_L, midthickness_R, white_L, white_R};
    %%
    %% Process: Import MRI
    %%
    if(properties.anatomy_params.mri_transformation.use_transformation)
        [BstMriFile, sMri] = import_mri(iSubject, T1w_file, 'ALL-MNI', 0);
        %%
        %% Read Transformation
        %%
        base_path           = properties.anatomy_params.mri_transformation.base_path;
        transformation_ref  = strrep(properties.anatomy_params.mri_transformation.file_location,'SubID',subID);
        transformation_file = fullfile(base_path,subID,transformation_ref);
        if(isfile(transformation_file))
            apply_mri_transf(BstMriFile, sMri,transformation_file);
        end
    else
        sFiles = bst_process('CallProcess', 'process_import_mri', [], [], ...
            'subjectname', subID, ...
            'mrifile',     {T1w_file, 'ALL-MNI'});
    end    
end

%%
%% Process: Import Surfaces
%%
[CSurfaces, sub_to_FSAve] = import_HCP_surfaces(properties, subID, surfaces);

%%
%% Getting report path
%%
[subject_report_path] = get_report_path(properties, subID);
%%
%% Quality control
%%
% Get MRI file and surface files
[sSubject, iSubject] = bst_get('Subject', subID);
MriFile  = sSubject.Anatomy(sSubject.iAnatomy).FileName;
hFigMri1 = view_mri_slices(MriFile, 'x', 20);
bst_report('Snapshot',hFigMri1,MriFile,'MRI Axial view', [200,200,900,700]);
savefig( hFigMri1,fullfile(subject_report_path,'MRI Axial view.fig'));
close(hFigMri1);

hFigMri2 = view_mri_slices(MriFile, 'y', 20);
bst_report('Snapshot',hFigMri2,MriFile,'MRI Coronal view', [200,200,900,700]);
savefig( hFigMri2,fullfile(subject_report_path,'MRI Coronal view.fig'));
close(hFigMri2);

hFigMri3 = view_mri_slices(MriFile, 'z', 20);
bst_report('Snapshot',hFigMri3,MriFile,'MRI Sagital view', [200,200,900,700]);
savefig( hFigMri3,fullfile(subject_report_path,'MRI Sagital view.fig'));
close(hFigMri3);

if(isequal(type,'template') || isequal(type,'individual'))
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
    
    hFigMri4  = script_view_contactsheet( hFigMriSurf, 'volume', 'x','');
    bst_report('Snapshot',hFigMri4,MriFile,'Cortex - MRI registration Axial view', [200,200,900,700]);
    savefig( hFigMri4,fullfile(subject_report_path,'Cortex - MRI registration Axial view.fig'));
    close(hFigMri4);
    %
    hFigMri5  = script_view_contactsheet( hFigMriSurf, 'volume', 'y','');
    bst_report('Snapshot',hFigMri5,MriFile,'Cortex - MRI registration Coronal view', [200,200,900,700]);
    savefig( hFigMri5,fullfile(subject_report_path,'Cortex - MRI registration Coronal view.fig'));
    close(hFigMri5);
    %
    hFigMri6  = script_view_contactsheet( hFigMriSurf, 'volume', 'z','');
    bst_report('Snapshot',hFigMri6,MriFile,'Cortex - MRI registration Sagital view', [200,200,900,700]);
    savefig( hFigMri6,fullfile(subject_report_path,'Cortex - MRI registration Sagital view.fig'));
    % Closing figures
    close([hFigMri6,hFigMriSurf]);
    
    %
    hFigMri7 = view_mri(MriFile, ScalpFile);
    bst_report('Snapshot',hFigMri7,MriFile,'Scalp registration', [200,200,900,700]);
    savefig( hFigMri7,fullfile(subject_report_path,'Scalp registration.fig'));
    close(hFigMri7);
    %
    hFigMri8 = view_mri(MriFile, OuterSkullFile);
    bst_report('Snapshot',hFigMri8,MriFile,'Outer Skull - MRI registration', [200,200,900,700]);
    savefig( hFigMri8,fullfile(subject_report_path,'Outer Skull - MRI registration.fig'));
    close(hFigMri8);
    %
    hFigMri9 = view_mri(MriFile, InnerSkullFile);
    bst_report('Snapshot',hFigMri9,MriFile,'Inner Skull - MRI registration', [200,200,900,700]);
    savefig( hFigMri9,fullfile(subject_report_path,'Inner Skull - MRI registration.fig'));
    % Closing figures
    close(hFigMri9);
end
Surfaces    = sSubject.Surface;
for i=1:length(CSurfaces)
    CSurface = CSurfaces(i);
    if(~isempty(CSurface.name))
        Cortex = Surfaces(CSurface.iSurface);
        hFigSurf = view_surface(Cortex.FileName);
        figures = {hFigSurf, hFigSurf, hFigSurf, hFigSurf};
        fig_out         = merge_figures(Cortex.Comment, strrep(Cortex.Comment,'_','-'), figures,...
            'rows', 2, 'cols', 2,'axis_on',{'off','off','off','off'},...
            'colorbars',{'off','off','off','off'},...
            'view_orient',{[0,90],[1,270],[1,180],[0,360]});
        bst_report('Snapshot',fig_out,[],strcat(Cortex.Comment,' 3D view'), [200,200,900,700]);
        savefig( hFigSurf,fullfile(subject_report_path,strcat(Cortex.Comment,' 3D view.fig')));
        % Closing figure
        close(fig_out,hFigSurf);
    end
end
if(length(CSurfaces)>1)
    for i=1:length(CSurfaces)
        CSurface = CSurfaces(i);
        if(~isempty(CSurface.name))
            Cortex = Surfaces(CSurface.iSurface);
            if(~exist('hFigSurfaces','var'))
                hFigSurfaces = script_view_surface(Cortex.FileName, [], [], [],'top');
            else
                hFigSurfaces = script_view_surface(Cortex.FileName, [], [], hFigSurfaces);
            end
        end
    end
    figures = {hFigSurfaces, hFigSurfaces, hFigSurfaces, hFigSurfaces};
    fig_out         = merge_figures("Surfaces cortex 3D view", "Surfaces cortex 3D view", figures,...
        'rows', 2, 'cols', 2,'axis_on',{'off','off','off','off'},...
        'colorbars',{'off','off','off','off'},...
        'view_orient',{[0,90],[1,270],[1,180],[0,360]});
    bst_report('Snapshot',fig_out,[],strcat('Surfaces cortex 3D view'), [200,200,900,700]);
    savefig( hFigSurfaces,fullfile(subject_report_path,strcat('Surfaces cortex 3D view.fig')));
    % Closing figure
    close(fig_out,hFigSurfaces);
end

end