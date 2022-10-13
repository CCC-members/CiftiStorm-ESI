function [CSurfaces, sub_to_FSAve] = import_HCP_surfaces(properties, subID, surfaces)
%%
%% Getting params
%%
anatomy_type    = properties.anatomy_params.anatomy_type.type_list{properties.anatomy_params.anatomy_type.type};
layer_desc      = anatomy_type.layer_desc.desc;
nVertCortex     = properties.anatomy_params.surfaces_resolution.nvertcortex;

if(~isequal(anatomy_type.id,1))
    %%
    %% Process: Import surfaces
    %%
    head_file           = surfaces{1};
    outerskull_file     = surfaces{2};
    innerskull_file     = surfaces{3};
    pial_L              = surfaces{4};
    pial_R              = surfaces{5};
    midthickness_L      = surfaces{6};
    midthickness_R      = surfaces{7};
    white_L             = surfaces{8};
    white_R             = surfaces{9};
    nVertHead           = properties.anatomy_params.surfaces_resolution.nverthead;
    nVertSkull          = properties.anatomy_params.surfaces_resolution.nvertskull;
    
    %% Importing non-brain surfacs
    bst_process('CallProcess', 'process_import_surfaces', [], [], ...
        'subjectname', subID, ...
        'headfile',    {head_file, 'MRI-MASK-MNI'}, ...
        'innerfile',   {innerskull_file, 'MRI-MASK-MNI'}, ...
        'outerfile',   {outerskull_file, 'MRI-MASK-MNI'}, ...
        'nverthead',   nVertHead, ...
        'nvertskull',  nVertSkull);
    
    %% Importing Brain surfaces
    if(isequal(layer_desc,'white') || isequal(layer_desc,'midthickness') || isequal(layer_desc,'pial'))
        type = 'single';
    else
        type = 'fs_ave';
    end
    switch type
        case 'single'
            %% ===== IMPORT SURFACES 32K =====
            switch layer_desc
                case 'pial'
                    L_surface_file  = pial_L;
                    R_surface_file  = pial_R;
                case 'midthickness'
                    L_surface_file  = midthickness_L;
                    R_surface_file  = midthickness_R;
                case 'white'
                    L_surface_file  = white_L;
                    R_surface_file  = white_R;
            end
            [~, iSubject]           = bst_get('Subject', subID);
            %% Single cortex
            [~,BstTessLhFile,~]     = import_surfaces(iSubject, L_surface_file, 'GII-MNI', 0);
            BstTessLhFile           = BstTessLhFile{1};
            [~,BstTessRhFile,~]     = import_surfaces(iSubject, R_surface_file, 'GII-MNI', 0);
            BstTessRhFile           = BstTessRhFile{1};
            [TessFile32K,~]         = tess_concatenate({BstTessLhFile, BstTessRhFile}, strcat('Cortex_',layer_desc,'_high'));
            file_delete(file_fullpath({BstTessLhFile, BstTessRhFile}), 1);
            in_tess_bst(TessFile32K,1);
            db_surface_type(TessFile32K,'Cortex');
        case 'fs_ave'
            %% ===== IMPORT SURFACES 32K =====
            [~, iSubject]                   = bst_get('Subject', subID);
            %% Pial
            [~,BstTessLhFile,~]             = import_surfaces(iSubject, pial_L, 'GII-MNI', 0);
            BstTessLhFile                   = BstTessLhFile{1};
            [~,BstTessRhFile,~]             = import_surfaces(iSubject, pial_R, 'GII-MNI', 0);
            BstTessRhFile                   = BstTessRhFile{1};
            [TessFile32K, ~]                = tess_concatenate({BstTessLhFile, BstTessRhFile}, strcat('Cortex_pial_high'));
            file_delete(file_fullpath({BstTessLhFile, BstTessRhFile}), 1);
            in_tess_bst( TessFile32K, 1);
            db_surface_type(TessFile32K, 'Cortex');
            %% Midthickness
            [~,BstTessLhFile,~]             = import_surfaces(iSubject, midthickness_L, 'GII-MNI', 0);
            BstTessLhFile                   = BstTessLhFile{1};
            [~,BstTessRhFile,~]             = import_surfaces(iSubject, midthickness_R, 'GII-MNI', 0);
            BstTessRhFile                   = BstTessRhFile{1};
            [TessFile32K, ~]                = tess_concatenate({BstTessLhFile, BstTessRhFile}, strcat('Cortex_midthickness_high'));
            file_delete(file_fullpath({BstTessLhFile, BstTessRhFile}), 1);
            in_tess_bst( TessFile32K, 1);
            db_surface_type(TessFile32K, 'Cortex');
            %% White
            [~,BstTessLhFile,~]             = import_surfaces(iSubject, white_L, 'GII-MNI', 0);
            BstTessLhFile                   = BstTessLhFile{1};
            [~,BstTessRhFile,~]             = import_surfaces(iSubject, white_R, 'GII-MNI', 0);
            BstTessRhFile                   = BstTessRhFile{1};
            [TessFile32K, ~]                = tess_concatenate({BstTessLhFile, BstTessRhFile}, strcat('Cortex_white_high'));
            file_delete(file_fullpath({BstTessLhFile, BstTessRhFile}), 1);
            in_tess_bst( TessFile32K, 1);
            db_surface_type(TessFile32K, 'Cortex');
    end
    %% Reload subject
    db_reload_subjects(iSubject);
end

%%
%% Downsampling Surfaces
%%
[sSubject, iSubject]        = bst_get('Subject', subID);
Surfaces                    = sSubject.Surface;
for i=1:length(Surfaces)
    surface = Surfaces(i);
    if(isequal(surface.SurfaceType,'Cortex'))
        Cortex              = Surfaces(i);
        comment             = split(Cortex.Comment,'_');
        if(isequal(comment{end},'high'))
            NewCortexFile       = tess_downsize(Cortex.FileName, nVertCortex, 'reducepatch');
            CortexMat.Comment   = strcat('Cortex_',comment{2},'_low');
            bst_save(file_fullpath(NewCortexFile), CortexMat, 'v7', 1);
        end
    end
end
%% Reload subject
db_reload_subjects(iSubject);

%%
%% Get CSurfaces from Subject
%%
CSurfaces                           = get_CSurfaces_from_sSubject(properties,iSubject);
%%
%% FSAve Surfaces interpolation
%%
sub_to_FSAve                        = get_FSAve_Surfaces_interpolation(properties,subID);
end