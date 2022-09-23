function [Shead, Sout, Sinn, Scortex] = get_surfaces(ProtocolInfo,sSubject,CSurfaces,sub_to_FSAve)

anat_path           = ProtocolInfo.SUBJECTS;
%%
%% Genering scalp file
%%
disp ("-->> Genering scalp file");
ScalpFile           = fullfile(anat_path,sSubject.Surface(sSubject.iScalp).FileName);
Shead               = load(ScalpFile);

%%
%% Genering outer skull file
%%
disp ("-->> Genering outer skull file");
OuterSkullFile      = fullfile(anat_path,sSubject.Surface(sSubject.iOuterSkull).FileName);
Sout                = load(OuterSkullFile);

%%
%% Genering inner skull file
%%
disp ("-->> Genering inner skull file");
InnerSkullFile      = fullfile(anat_path,sSubject.Surface(sSubject.iInnerSkull).FileName);
Sinn                = load(InnerSkullFile);

%%
%% Genering surf file
%%
disp ("-->> Genering surf file");
Sc      = struct([]);
Surfaces    = sSubject.Surface;
count = 1;
for i=1:length(CSurfaces)
    CSurface = CSurfaces(i);
    if(~isempty(CSurface.name))
        BSTSurface = Surfaces(CSurface.iSurface);
        CortexFile                  = fullfile(anat_path, BSTSurface.FileName);
        Cortex                      = load(CortexFile);
        Sc(count).Comment           = Cortex.Comment;
        Sc(count).Vertices          = Cortex.Vertices;
        Sc(count).Faces             = Cortex.Faces;
        Sc(count).VertConn          = Cortex.VertConn;
        Sc(count).VertNormals       = Cortex.VertNormals;
        Sc(count).Curvature         = Cortex.Curvature;
        Sc(count).SulciMap          = Cortex.SulciMap;
        if(isequal(Cortex.Atlas(Cortex.iAtlas).Name,'Structures') || isempty(Cortex.Atlas(Cortex.iAtlas).Scouts))
            Sc(count).Atlas.Name    = 'User scouts';
            Sc(count).Atlas.Scouts  = generate_scouts(Cortex);
        else
            Sc(count).Atlas         = Cortex.Atlas;
        end
        Sc(count).iAtlas            = Cortex.iAtlas;
        count                       = count + 1;
    end
end

% Loadding subject surfaces
Scortex.Sc             = Sc;
Scortex.sub_to_FSAve   = sub_to_FSAve;
Scortex.iCortex        = sSubject.iCortex;

end

