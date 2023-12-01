function CSurfaces = get_CSurfaces_from_sSubject(properties,iSubject)

layer_desc              = properties.anatomy_params.common_params.layer_desc.desc;
sSubject                = bst_get('Subject', iSubject);
CSurfaces(8).name       = 'InnerSkull';
CSurfaces(8).comment    = sSubject.Surface(sSubject.iInnerSkull).Comment;
CSurfaces(8).iSurface   = sSubject.iInnerSkull;
CSurfaces(8).iCSurface  = true;
CSurfaces(8).type       = 'innerskull';
CSurfaces(8).filename   = sSubject.Surface(sSubject.iInnerSkull).FileName;

CSurfaces(9).name       = 'OuterSkull';
CSurfaces(9).comment    = sSubject.Surface(sSubject.iOuterSkull).Comment;
CSurfaces(9).iSurface   = sSubject.iOuterSkull;
CSurfaces(9).iCSurface  = true;
CSurfaces(9).type       = 'outerskull';
CSurfaces(9).filename   = sSubject.Surface(sSubject.iOuterSkull).FileName;

CSurfaces(10).name      = 'Scalp';
CSurfaces(10).comment   = sSubject.Surface(sSubject.iScalp).Comment;
CSurfaces(10).iSurface  = sSubject.iScalp;
CSurfaces(10).iCSurface = true;
CSurfaces(10).type      = 'scalp';
CSurfaces(10).filename  = sSubject.Surface(sSubject.iScalp).FileName;

Surfaces            = sSubject.Surface;
for i=1:length(Surfaces)
    surface         = Surfaces(i);
    if(isequal(surface.SurfaceType,'Cortex'))
        comment     = split(surface.Comment,'_');
        if(length(comment) >= 3)
            desc        = comment{2};
            resol       = comment{3};
            fix         = comment{end};
            if(isequal(resol,'low'))
                switch lower(desc)
                    case 'pial'
                        if(isequal(fix,'fix') || isempty(CSurfaces(1).name))
                            CSurfaces(1).name       = 'Pial';
                            CSurfaces(1).comment    = 'Cortex_pial_low';
                            CSurfaces(1).iCSurface  = true;
                            CSurfaces(1).iSurface   = i;
                            if(isequal(lower(layer_desc),'pial') || isequal(lower(layer_desc),'fs_LR') || isequal(lower(layer_desc),'bigbrain')) 
                                CSurfaces(1).iCSurface  = true; 
                            else
                                CSurfaces(1).iCSurface  = false; 
                            end
                            CSurfaces(1).type       = 'cortex';                            
                            CSurfaces(1).filename   = surface.FileName;
                            
                        end
                    case 'midthickness'
                        if(isequal(fix,'fix') || isempty(CSurfaces(4).name))
                            CSurfaces(4).name       = 'Midthickness';
                            CSurfaces(4).comment    = 'Cortex_midthickness_low';
                            CSurfaces(4).iSurface   = i;
                            if(isequal(lower(layer_desc),'midthickness')) CSurfaces(4).iCSurface  = true; else CSurfaces(4).iCSurface  = false; end
                            CSurfaces(4).type       = 'cortex';
                            CSurfaces(4).filename   = surface.FileName;
                        end
                    case 'white'
                        if(isequal(fix,'fix') || isempty(CSurfaces(7).name))
                            CSurfaces(7).name       = 'White';                            
                            CSurfaces(7).comment    = 'Cortex_white_low';
                            CSurfaces(7).iSurface   = i;
                            if(isequal(lower(layer_desc),'white')) CSurfaces(7).iCSurface  = true; else CSurfaces(7).iCSurface  = false; end
                            CSurfaces(7).type       = 'cortex';                            
                            CSurfaces(7).filename   = surface.FileName;
                        end
                    case 'six'
                        if(isequal(fix,'fix') || isempty(CSurfaces(6).name))
                            CSurfaces(6).name       = 'Six';                            
                            CSurfaces(6).comment    = 'Cortex_six_low';
                            CSurfaces(6).iSurface   = i;
                            CSurfaces(6).iCSurface  = false;
                            CSurfaces(6).type       = 'cortex';                            
                            CSurfaces(6).filename   = surface.FileName;
                        end
                    case 'five'
                        if(isequal(fix,'fix') || isempty(CSurfaces(5).name))
                            CSurfaces(5).name       = 'Five';                            
                            CSurfaces(5).comment    = 'Cortex_five_low';
                            CSurfaces(5).iSurface   = i;
                            CSurfaces(5).iCSurface  = false;
                            CSurfaces(5).type       = 'cortex';                            
                            CSurfaces(5).filename   = surface.FileName;
                        end
                    case 'four'
                        if(isequal(fix,'fix') || isempty(CSurfaces(4).name))
                            CSurfaces(4).name       = 'Four';                            
                            CSurfaces(4).comment    = 'Cortex_four_low';
                            CSurfaces(4).iSurface   = i;
                            CSurfaces(4).iCSurface  = false;
                            CSurfaces(4).type       = 'cortex';                            
                            CSurfaces(4).filename   = surface.FileName;
                        end
                    case 'three'
                        if(isequal(fix,'fix') || isempty(CSurfaces(3).name))
                            CSurfaces(3).name       = 'Three';                            
                            CSurfaces(3).comment    = 'Cortex_three_low';
                            CSurfaces(3).iSurface   = i;
                            CSurfaces(3).iCSurface  = false;
                            CSurfaces(3).type       = 'cortex';                            
                            CSurfaces(3).filename   = surface.FileName;
                        end
                    case 'two'
                        if(isequal(fix,'fix') || isempty(CSurfaces(2).name))
                            CSurfaces(2).name       = 'Two';                            
                            CSurfaces(2).comment    = 'Cortex_two_low';
                            CSurfaces(2).iSurface   = i;
                            CSurfaces(2).iCSurface  = false;
                            CSurfaces(2).type       = 'cortex';                            
                            CSurfaces(2).filename   = surface.FileName;
                        end
                end
            end
        end
    end
end
end