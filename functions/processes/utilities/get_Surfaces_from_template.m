function CSurfaces = get_Surfaces_from_template(subID)

[sSubject, iSubject]                = bst_get('Subject', subID);
Surfaces                            = sSubject.Surface;

for i=1:length(Surfaces)
   surface                          = Surfaces(i);
   type                             = surface.SurfaceType;
   switch type
       case "Cortex"
           CSurfaces(4).name        = 'Midthickness';
           CSurfaces(4).comment     = 'Cortex_midthickness_high';
           CSurfaces(4).iSurface    = i;
           CSurfaces(4).iCSurface   = true;
           CSurfaces(4).type        = 'cortex';
           CSurfaces(4).filename    = surface.FileName;
       case "InnerSkull"
           CSurfaces(8).name       = 'InnerSkull';
           CSurfaces(8).comment    = surface.Comment;
           CSurfaces(8).iSurface   = sSubject.iInnerSkull;
           CSurfaces(8).iCSurface  = true;
           CSurfaces(8).type       = 'innerskull';
           CSurfaces(8).filename   = surface.FileName;
       case "OuterSkull"
           CSurfaces(9).name       = 'OuterSkull';
           CSurfaces(9).comment    = surface.Comment;
           CSurfaces(9).iSurface   = sSubject.iOuterSkull;
           CSurfaces(9).iCSurface  = true;
           CSurfaces(9).type       = 'outerskull';
           CSurfaces(9).filename   = surface.FileName;
       case "Scalp"
           CSurfaces(10).name       = 'Scalp';
           CSurfaces(10).comment    = surface.Comment;
           CSurfaces(10).iSurface   = sSubject.iScalp;
           CSurfaces(10).iCSurface  = true;
           CSurfaces(10).type       = 'scalp';
           CSurfaces(10).filename   = surface.FileName;           
   end
end

