function CSurfaces = import_HCP_surfaces(properties, subID, surfaces)
%%
%% Getting params
%%
anatomy_type            = properties.anatomy_params.anatomy_type;
layer_desc              = properties.anatomy_params.common_params.layer_desc.desc;
surfaces_resolution     = properties.anatomy_params.common_params.surfaces_resolution;

if(~isequal(anatomy_type.id,'default'))
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
    nvertices           = surfaces_resolution.nvertices;
    
    %% Importing non-brain surfacs
    bst_process('CallProcess', 'process_import_surfaces', [], [], ...
        'subjectname', subID, ...
        'headfile',    {head_file, 'MRI-MASK-MNI'}, ...
        'innerfile',   {innerskull_file, 'MRI-MASK-MNI'}, ...
        'outerfile',   {outerskull_file, 'MRI-MASK-MNI'}, ...
        'nverthead',   nvertices, ...
        'nvertskull',  nvertices);
    
    %% Importing Brain surfaces
    if(isequal(lower(layer_desc),'white') || isequal(lower(layer_desc),'midthickness') || isequal(lower(layer_desc),'pial'))
        type = 'single';
    elseif(isequal(lower(layer_desc),'fs_lr'))
        type = 'fs_lr';
    else
        type = 'bigbrain';
    end
    switch type
        case 'single'
            %% ===== IMPORT SURFACES 32K =====
            switch lower(layer_desc)
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
            [TessFile32K,iSurface]  = tess_concatenate({BstTessLhFile, BstTessRhFile}, strcat('Cortex_',lower(layer_desc),'_high'));
            file_delete(file_fullpath({BstTessLhFile, BstTessRhFile}), 1);
            [~, TessFile32K]        = in_tess_bst(TessFile32K,1);
            TessFile32K             = db_surface_type(TessFile32K,'Cortex');            
            switch lower(layer_desc)
                case 'pial'
                    CSurfaces(1).name               = 'Pial';
                    CSurfaces(1).comment            = 'Cortex_pial_high';
                    CSurfaces(1).iSurface           = iSurface;
                    CSurfaces(1).iCSurface          = true;
                    CSurfaces(1).type               = 'cortex';
                    CSurfaces(1).filename           = TessFile32K;
                case 'midthickness'
                    CSurfaces(4).name               = 'Midthickness';
                    CSurfaces(4).comment            = 'Cortex_midthickness_high';
                    CSurfaces(4).iSurface           = iSurface;
                    CSurfaces(4).iCSurface          = true;
                    CSurfaces(4).type               = 'cortex';
                    CSurfaces(4).filename           = TessFile32K;
                case 'white'
                    CSurfaces(7).name               = 'White';
                    CSurfaces(7).comment            = 'Cortex_white_high';
                    CSurfaces(7).iSurface           = iSurface;
                    CSurfaces(7).iCSurface          = true;
                    CSurfaces(7).type               = 'cortex';
                    CSurfaces(7).filename           = TessFile32K;
            end
            
        case 'fs_lr'
            %% ===== IMPORT SURFACES 32K =====
            [~, iSubject]                   = bst_get('Subject', subID);
            %% Pial
            [~,BstTessLhFile,~]             = import_surfaces(iSubject, pial_L, 'GII-MNI', 0);
            BstTessLhFile                   = BstTessLhFile{1};
            [~,BstTessRhFile,~]             = import_surfaces(iSubject, pial_R, 'GII-MNI', 0);
            BstTessRhFile                   = BstTessRhFile{1};
            [TessFile32K, iSurface]         = tess_concatenate({BstTessLhFile, BstTessRhFile}, strcat('Cortex_pial_high'));
            file_delete(file_fullpath({BstTessLhFile, BstTessRhFile}), 1);
            [~, TessFile32K]                = in_tess_bst( TessFile32K, 1);
            TessFile32K                     = db_surface_type(TessFile32K, 'Cortex');
            
            CSurfaces(1).name               = 'Pial';
            CSurfaces(1).comment            = 'Cortex_pial_high';
            CSurfaces(1).iSurface           = iSurface;
            CSurfaces(1).iCSurface          = true;
            CSurfaces(1).type               = 'cortex';
            CSurfaces(1).filename           = TessFile32K;
            
            
            %% Midthickness
            [~,BstTessLhFile,~]             = import_surfaces(iSubject, midthickness_L, 'GII-MNI', 0);
            BstTessLhFile                   = BstTessLhFile{1};
            [~,BstTessRhFile,~]             = import_surfaces(iSubject, midthickness_R, 'GII-MNI', 0);
            BstTessRhFile                   = BstTessRhFile{1};
            [TessFile32K, iSurface]         = tess_concatenate({BstTessLhFile, BstTessRhFile}, strcat('Cortex_midthickness_high'));
            file_delete(file_fullpath({BstTessLhFile, BstTessRhFile}), 1);
            [~, TessFile32K]                = in_tess_bst( TessFile32K, 1);
            TessFile32K                     = db_surface_type(TessFile32K, 'Cortex');
            
            CSurfaces(4).name               = 'Midthickness';
            CSurfaces(4).comment            = 'Cortex_midthickness_high';
            CSurfaces(4).iSurface           = iSurface;
            CSurfaces(4).iCSurface          = false;
            CSurfaces(4).type               = 'cortex';
            CSurfaces(4).filename           = TessFile32K;
            
            %% White
            [~,BstTessLhFile,~]             = import_surfaces(iSubject, white_L, 'GII-MNI', 0);
            BstTessLhFile                   = BstTessLhFile{1};
            [~,BstTessRhFile,~]             = import_surfaces(iSubject, white_R, 'GII-MNI', 0);
            BstTessRhFile                   = BstTessRhFile{1};
            [TessFile32K, iSurface]         = tess_concatenate({BstTessLhFile, BstTessRhFile}, strcat('Cortex_white_high'));
            file_delete(file_fullpath({BstTessLhFile, BstTessRhFile}), 1);
            [~, TessFile32K]                = in_tess_bst( TessFile32K, 1);
            TessFile32K                     = db_surface_type(TessFile32K, 'Cortex');
            
            CSurfaces(7).name               = 'White';
            CSurfaces(7).comment            = 'Cortex_white_high';
            CSurfaces(7).iSurface           = iSurface;
            CSurfaces(7).iCSurface          = false;
            CSurfaces(7).type               = 'cortex';
            CSurfaces(7).filename           = TessFile32K;
            
        case 'bigbrain'
             %% ===== IMPORT SURFACES 32K =====
            [~, iSubject]                   = bst_get('Subject', subID);            
                                    
            %% White
            [~,BstTessLhFile,~]             = import_surfaces(iSubject, white_L, 'GII-MNI', 0);
            BstTessLhFile                   = BstTessLhFile{1};
            [~,BstTessRhFile,~]             = import_surfaces(iSubject, white_R, 'GII-MNI', 0);
            BstTessRhFile                   = BstTessRhFile{1};
            [TessFile32K_white, iSurface]   = tess_concatenate({BstTessLhFile, BstTessRhFile}, strcat('Cortex_white_high'));
            file_delete(file_fullpath({BstTessLhFile, BstTessRhFile}), 1);
            [~, TessFile32K_white]          = in_tess_bst( TessFile32K_white, 1);
            TessFile32K_white               = db_surface_type(TessFile32K_white, 'Cortex');
            
            CSurfaces(7).name               = 'White';
            CSurfaces(7).comment            = 'Cortex_white_high';
            CSurfaces(7).iSurface           = iSurface;
            CSurfaces(7).iCSurface          = false;
            CSurfaces(7).type               = 'cortex';
            CSurfaces(7).filename           = TessFile32K_white;
            
            %% Pial
            [~,BstTessLhFile,~]             = import_surfaces(iSubject, pial_L, 'GII-MNI', 0);
            BstTessLhFile                   = BstTessLhFile{1};
            [~,BstTessRhFile,~]             = import_surfaces(iSubject, pial_R, 'GII-MNI', 0);
            BstTessRhFile                   = BstTessRhFile{1};
            [TessFile32K_pial, iSurface]    = tess_concatenate({BstTessLhFile, BstTessRhFile}, strcat('Cortex_pial_high'));
            file_delete(file_fullpath({BstTessLhFile, BstTessRhFile}), 1);
            [~, TessFile32K_pial]           = in_tess_bst( TessFile32K_pial, 1);
            TessFile32K_pial                = db_surface_type(TessFile32K_pial, 'Cortex');   
            
            CSurfaces(1).name               = 'Pial';
            CSurfaces(1).comment            = 'Cortex_pial_high';
            CSurfaces(1).iSurface           = iSurface;
            CSurfaces(1).iCSurface          = true;
            CSurfaces(1).type               = 'cortex';
            CSurfaces(1).filename           = TessFile32K_pial;
    end
    %% Reload subject
    db_reload_subjects(iSubject);    
    
    for i=1:length(CSurfaces)
        if(~isempty(CSurfaces(i).filename))
            [~,~,iSurface]           = bst_get('SurfaceFile', CSurfaces(i).filename);
            CSurfaces(i).iSurface    = iSurface;
        end
    end
end

end