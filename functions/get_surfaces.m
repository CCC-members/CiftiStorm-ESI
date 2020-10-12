function [Sc,iCortex] = get_surfaces(protocol_anat_path,subject)

disp ("-->> Genering surf file");
Sc      = struct([]);
count   = 1;
for h=1:length(subject.Surface)
    surface = subject.Surface(h);
    if(isequal(surface.SurfaceType,'Cortex'))
        if(isequal(subject.iCortex,h))
            iCortex = count;
        end
        CortexFile              = fullfile(protocol_anat_path, surface.FileName);
        Cortex                  = load(CortexFile);
        Sc(count).Comment       = Cortex.Comment;
        Sc(count).Vertices      = Cortex.Vertices;
        Sc(count).Faces         = Cortex.Faces;
        Sc(count).VertConn      = Cortex.VertConn;
        Sc(count).VertNormals   = Cortex.VertNormals;
        Sc(count).Curvature     = Cortex.Curvature;
        Sc(count).SulciMap      = Cortex.SulciMap;
        if(isequal(Cortex.Atlas(Cortex.iAtlas).Name,'Structures') || isempty(Cortex.Atlas(Cortex.iAtlas).Scouts))
            Sc(count).Atlas      = generate_scouts(Cortex);
        else
            Sc(count).Atlas     = Cortex.Atlas;
        end
        Sc(count).iAtlas        = Cortex.iAtlas;
        count                   = count + 1;
    end
end
end

