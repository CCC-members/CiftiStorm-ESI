function [Shead, Sout, Sinn, Scortex] = get_surfaces(ProtocolInfo,sSubject,FSAve_interp,iter)

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
CortexFile8K        = sSubject.Surface(sSubject.iCortex).FileName;
BSTCortexFile8K     = fullfile(anat_path, CortexFile8K);
Sc8k                = load(BSTCortexFile8K);
if(FSAve_interp)
    disp ("-->> Getting FSAve surface corregistration");
    % Loadding FSAve templates
    %     FSAve_64k               = load('templates/FSAve_cortex_64K.mat');
    fsave_inds_template     = load('templates/FSAve_64K_8K_coregister_indms.mat');
    %     fsave_inds_template     = load('templates/FSAve_64k_coregister_indms.mat');    
    CortexFile64K           = sSubject.Surface(1).FileName;
    BSTCortexFile64K        = fullfile(anat_path, CortexFile64K);
    Sc64k                   = load(BSTCortexFile64K);
    
    % Finding near FSAve vertices on subject surface
    if(exist('iter','var'))
        if(isequal(iter,1))
            sub_to_FSAve = find_interpolation_vertices(Sc64k,Sc8k, fsave_inds_template);
            if(~isfolder(fullfile(pwd,'tmp')))
                mkdir(fullfile(pwd,'tmp'));
            end
            addpath(fullfile(pwd,'tmp'));
            save(fullfile(pwd,'tmp','sub_to_FSAve.mat'),'sub_to_FSAve');
        end
        load(fullfile(pwd,'tmp','sub_to_FSAve.mat'));
    else
        sub_to_FSAve = find_interpolation_vertices(Sc64k,Sc8k, fsave_inds_template);
    end
else
    sub_to_FSAve = [];
end
disp ("-->> Genering surf file");
Sc      = struct([]);
count   = 1;
for h=1:length(sSubject.Surface)
    surface = sSubject.Surface(h);
    if(isequal(surface.SurfaceType,'Cortex'))
        if(isequal(sSubject.iCortex,h))
            iCortex = count;
        end
        CortexFile                  = fullfile(anat_path, surface.FileName);
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
Scortex.iCortex        = iCortex;

end

