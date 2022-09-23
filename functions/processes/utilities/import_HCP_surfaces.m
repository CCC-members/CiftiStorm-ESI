function [CSurfaces, sub_to_FSAve] = import_HCP_surfaces(properties, subID, surfaces)
%%
%% Surfaces resolution
%%
anatomy_type    = properties.anatomy_params.anatomy_type.type_list{properties.anatomy_params.anatomy_type.type};
layer_desc      = anatomy_type.layer_desc.desc;
nVertHead       = properties.anatomy_params.surfaces_resolution.nverthead;
nVertCortex     = properties.anatomy_params.surfaces_resolution.nvertcortex;
nVertSkull      = properties.anatomy_params.surfaces_resolution.nvertskull;

%%
%% Process: Import surfaces
%%
if(isequal(properties.anatomy_params.anatomy_type.type,1))    
    % Get subject definition and subject files
    sSubject        = bst_get('Subject', subID);
    Surfaces        = sSubject.Surface;
    for i=1:length(Surfaces)
        surface     = Surfaces(i);
        file_name   = split(surface.FileName,'_');
        if((length(file_name)>4))
            desc        = file_name{4};
            resol       = file_name{5};
            if(isequal(resol,'high.mat'))
                if(isequal(layer_desc,'white') || isequal(layer_desc,'midthickness') || isequal(layer_desc,'pial'))
                    switch layer_desc
                        case 'white'
                            if(isequal(desc,'white'))
                                CSurfaces(1).name       = 'white';
                                CSurfaces(1).iSurface   = i;
                                iCSurface               = i;
                                break;
                            end
                        case 'midthickness'
                            if(isequal(desc,'mid'))
                                CSurfaces(4).name       = 'midthickness';
                                CSurfaces(4).iSurface   = i;
                                iCSurface               = i;
                                break;
                            end
                            
                        case 'pial'
                            if(isequal(desc,'pial'))
                                CSurfaces(7).name       = 'pial';
                                CSurfaces(7).iSurface   = i;
                                iCSurface               = i;
                                break;
                            end
                    end
                else
                    switch desc
                        case 'white'
                            CSurfaces(1).name       = 'white';
                            CSurfaces(1).iSurface   = i;
                        case 'mid'
                            CSurfaces(4).name       = 'midthickness';
                            CSurfaces(4).iSurface   = i;
                        case 'pial'
                            CSurfaces(7).name       = 'pial';
                            CSurfaces(7).iSurface   = i;
                            iCSurface               = i;
                    end
                end
            end
        end
    end    
else
    head_file           = surfaces{1};
    outerskull_file     = surfaces{2};
    innerskull_file     = surfaces{3};
    pial_L              = surfaces{4};
    pial_R              = surfaces{5};
    midthickness_L      = surfaces{6};
    midthickness_R      = surfaces{7};
    white_L             = surfaces{8};
    white_R             = surfaces{9};
    if(isequal(layer_desc,'white') || isequal(layer_desc,'midthickness') || isequal(layer_desc,'pial'))
        switch layer_desc
            case 'white'
                L_surface_file      = white_L;
                R_surface_file      = white_R;
                CSurfaces(1).name   = 'white';
                iCSurface           = 1;
            case 'midthickness'
                L_surface_file      = midthickness_L;
                R_surface_file      = midthickness_R;
                CSurfaces(4).name   = 'midthickness';
                iCSurface           = 4;
            case 'pial'
                L_surface_file      = pial_L;
                R_surface_file      = pial_R;
                CSurfaces(7).name   = 'pial';
                iCSurface           = 7;
        end
        sFiles = bst_process('CallProcess', 'process_import_surfaces', [], [], ...
            'subjectname', subID, ...
            'headfile',    {head_file, 'MRI-MASK-MNI'}, ...
            'cortexfile1', {L_surface_file, 'GII-MNI'}, ...
            'cortexfile2', {R_surface_file, 'GII-MNI'}, ...
            'innerfile',   {innerskull_file, 'MRI-MASK-MNI'}, ...
            'outerfile',   {outerskull_file, 'MRI-MASK-MNI'}, ...
            'nverthead',   nVertHead, ...
            'nvertcortex', nVertCortex, ...
            'nvertskull',  nVertSkull);
        
        %===== IMPORT SURFACES 32K =====
        [sSubject, iSubject]            = bst_get('Subject', subID);
        % Left pial
        [~, BstTessLhFile, nVertOrigL]  = import_surfaces(iSubject, L_surface_file, 'GII-MNI', 0);
        BstTessLhFile                   = BstTessLhFile{1};
        % Right pial
        [~, BstTessRhFile, nVertOrigR]  = import_surfaces(iSubject, R_surface_file, 'GII-MNI', 0);
        BstTessRhFile                   = BstTessRhFile{1};
        % Merge surfaces
        [TessFile32K, iSurface_high]    = tess_concatenate({BstTessLhFile, BstTessRhFile}, strcat('Cortex_',layer_desc,'_', num2str(nVertOrigL + nVertOrigR)));
        % Delete original files
        file_delete(file_fullpath({BstTessLhFile, BstTessRhFile}), 1);
        % Compute missing fields
        in_tess_bst( TessFile32K, 1);
        % Reload subject
        db_reload_subjects(iSubject);
        % Set file type
        db_surface_type(TessFile32K, 'Cortex');
        % Set default cortex
        [sSubject, iSubject]            = bst_get('Subject', subID);
        iSurface_low                    = 2;
        iSurface_high                   = 1;
        CSurfaces(iCSurface).iSurface   = iSurface_low;
        db_surface_default(iSubject, 'Cortex', iSurface_low);
    else
        sFiles = bst_process('CallProcess', 'process_import_surfaces', [], [], ...
            'subjectname', subID, ...
            'headfile',    {head_file, 'MRI-MASK-MNI'}, ...
            'innerfile',   {innerskull_file, 'MRI-MASK-MNI'}, ...
            'outerfile',   {outerskull_file, 'MRI-MASK-MNI'}, ...
            'nverthead',   nVertHead, ...
            'nvertskull',  nVertSkull);
        
        %===== IMPORT SURFACES 32K =====
        [sSubject, iSubject]              = bst_get('Subject', subID);
        % Left white
        [~, BstTessLhFile, nVertOrigL]    = import_surfaces(iSubject, white_L, 'GII-MNI', 0);
        BstTessLhFile                     = BstTessLhFile{1};
        % Right white
        [~, BstTessRhFile, nVertOrigR]    = import_surfaces(iSubject, white_R, 'GII-MNI', 0);
        BstTessRhFile                     = BstTessRhFile{1};
        % Merge surfaces
        [TessFile32K, iSurface]           = tess_concatenate({BstTessLhFile, BstTessRhFile}, sprintf('Cortex_white_%dV', nVertOrigL + nVertOrigR));
        % Delete original files
        file_delete(file_fullpath({BstTessLhFile, BstTessRhFile}), 1);
        % Compute missing fields
        in_tess_bst( TessFile32K, 1);
        % Set file type
        db_surface_type(TessFile32K, 'Cortex');
        
        % Left midthickness
        [~, BstTessLhFile, nVertOrigL]  = import_surfaces(iSubject, midthickness_L, 'GII-MNI', 0);
        BstTessLhFile                   = BstTessLhFile{1};
        % Right midthickness
        [~, BstTessRhFile, nVertOrigR]  = import_surfaces(iSubject, midthickness_R, 'GII-MNI', 0);
        BstTessRhFile                   = BstTessRhFile{1};
        % Merge surfaces
        [TessFile32K, iSurface]         = tess_concatenate({BstTessLhFile, BstTessRhFile}, sprintf('Cortex_midthickness_%dV', nVertOrigL + nVertOrigR));
        % Delete original files
        file_delete(file_fullpath({BstTessLhFile, BstTessRhFile}), 1);
        % Compute missing fields
        in_tess_bst( TessFile32K, 1);
        % Set file type
        db_surface_type(TessFile32K, 'Cortex');
        
        % Left pial
        [~, BstTessLhFile, nVertOrigL]  = import_surfaces(iSubject, pial_L, 'GII-MNI', 0);
        BstTessLhFile                   = BstTessLhFile{1};
        % Right pial
        [~, BstTessRhFile, nVertOrigR]  = import_surfaces(iSubject, pial_R, 'GII-MNI', 0);
        BstTessRhFile                   = BstTessRhFile{1};
        % Merge surfaces
        [TessFile32K, iSurface]    = tess_concatenate({BstTessLhFile, BstTessRhFile}, sprintf('Cortex_pial_%dV', nVertOrigL + nVertOrigR));
        % Delete original files
        file_delete(file_fullpath({BstTessLhFile, BstTessRhFile}), 1);
        % Compute missing fields
        in_tess_bst( TessFile32K, 1);
        % Set file type
        db_surface_type(TessFile32K, 'Cortex');
        
        % Reload subject
        db_reload_subjects(iSubject);
        
        CSurfaces(1).name       = 'white';
        CSurfaces(1).iSurface   = 1;
        CSurfaces(4).name       = 'midthickness';
        CSurfaces(4).iSurface   = 2;
        CSurfaces(7).name       = 'pial';
        CSurfaces(7).iSurface   = 3;
        iSurface_high           = 3;
        iCSurface               = 7;
    end
end
%%
%% Compute surfaces like BigBrain
%%
if(isequal(layer_desc,'bigbrain'))
    CSurfaces = compute_BigBrain_surfaces(properties, iSubject, BB_surfaces, CSurfaces);
end
%%
%% FSAve Surfaces interpolation
%%
if(~isequal(properties.anatomy_params.anatomy_type.type,1))
    ProtocolInfo            = bst_get('ProtocolInfo');
    anat_path               = ProtocolInfo.SUBJECTS;
    [sSubject, iSubject]    = bst_get('Subject', subID);
    iSurface_low            = CSurfaces(iCSurface).iSurface;
    CortexFile8K            = sSubject.Surface(iSurface_low).FileName;    
    BSTCortexFile8K         = fullfile(anat_path, CortexFile8K);
    Sc8k                    = load(BSTCortexFile8K);
    disp ("-->> Getting FSAve surface corregistration");
    fsave_inds_template     = load('templates/FSAve_64K_8K_coregister_indms.mat');
    CortexFile64K           = sSubject.Surface(iSurface_high).FileName;
    BSTCortexFile64K        = fullfile(anat_path, CortexFile64K);
    Sc64k                   = load(BSTCortexFile64K);
    % Finding near FSAve vertices on subject surface
    sub_to_FSAve = find_interpolation_vertices(Sc64k,Sc8k, fsave_inds_template);    
else
    sub_to_FSAve = [];
end

%%
%% Downsampling Surfaces
%%
[sSubject, iSubject]    = bst_get('Subject', subID);
Surfaces                = sSubject.Surface;
for i=1:length(CSurfaces)
    CSurface = CSurfaces(i);
    if(~isempty(CSurface.name))
        Cortex                      = Surfaces(CSurface.iSurface);
        [NewCortexFile, iSurface]   = tess_downsize(Cortex.FileName, nVertCortex, 'reducepatch');
        CSurfaces(i).iSurface       = iSurface;
        CortexMat.Comment           = strcat('cortex_',CSurface.name,'_8KV');
        bst_save(file_fullpath(NewCortexFile), CortexMat, 'v7', 1);
    end
end
db_surface_default(iSubject, 'Cortex', CSurfaces(iCSurface).iSurface);

end

