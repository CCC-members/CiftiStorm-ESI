function CSurfaces = get_CSurfaces_from_sSubject(properties,iSubject)

anatomy_type            = properties.anatomy_params.anatomy_type.type_list{properties.anatomy_params.anatomy_type.type};
layer_desc              = anatomy_type.layer_desc.desc;
sSubject                = bst_get('Subject', iSubject);
CSurfaces(8).name       = 'InnerSkull';
CSurfaces(8).iSurface   = sSubject.iInnerSkull;
CSurfaces(8).iCSurface  = true;
CSurfaces(8).type       = 'innerskull';

CSurfaces(9).name       = 'OuterSkull';
CSurfaces(9).iSurface   = sSubject.iOuterSkull;
CSurfaces(9).iCSurface  = true;
CSurfaces(9).type       = 'outerskull';

CSurfaces(10).name      = 'Scalp';
CSurfaces(10).iSurface  = sSubject.iScalp;
CSurfaces(10).iCSurface = true;
CSurfaces(10).type      = 'scalp';

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
                switch desc
                    case 'pial'
                        if(isequal(fix,'fix') || isempty(CSurfaces(1).name))
                            CSurfaces(1).name       = 'pial';
                            CSurfaces(1).iCSurface  = true;
                            CSurfaces(1).iSurface   = i;
                            if(isequal(layer_desc,'pial') || isequal(layer_desc,'fs_LR')) CSurfaces(1).iCSurface  = true; else CSurfaces(1).iCSurface  = false; end
                            CSurfaces(1).type       = 'cortex';
                        end
                    case 'midthickness'
                        if(isequal(fix,'fix') || isempty(CSurfaces(4).name))
                            CSurfaces(4).name       = 'midthickness';
                            CSurfaces(4).iSurface   = i;
                            if(isequal(layer_desc,'midthickness')) CSurfaces(4).iCSurface  = true; else CSurfaces(4).iCSurface  = false; end
                            CSurfaces(4).type       = 'cortex';
                        end
                    case 'white'
                        if(isequal(fix,'fix') || isempty(CSurfaces(7).name))
                            CSurfaces(7).name       = 'white';
                            CSurfaces(7).iSurface   = i;
                            if(isequal(layer_desc,'white')) CSurfaces(7).iCSurface  = true; else CSurfaces(7).iCSurface  = false; end
                            CSurfaces(7).type       = 'cortex';
                        end
                end
            end
        end
    end
end
end