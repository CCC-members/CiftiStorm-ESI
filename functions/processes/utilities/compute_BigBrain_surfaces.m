function [CSurfaces, CRadius] = compute_BigBrain_surfaces(subID, CSurfaces)

%%
%%  Getting Subject's Surfaces (Pial and White)
%%
ProtocolInfo                = bst_get('ProtocolInfo');
anat_path                   = ProtocolInfo.SUBJECTS;
[~,~,iSurface]              = bst_get('SurfaceFile', CSurfaces(7).filename);
CSurfaces(7).iSurface       = iSurface;
Swhite                      = load(fullfile(anat_path,CSurfaces(7).filename));
Rwhite                      = Swhite.Vertices;                                  % R(0) 
Nwhite                      = Swhite.VertNormals;                               % N(0)
[~,~,iSurface]              = bst_get('SurfaceFile', CSurfaces(1).filename);
CSurfaces(1).iSurface       = iSurface;
Spial                       = load(fullfile(anat_path,CSurfaces(1).filename));
Rpial                       = Spial.Vertices;                                   % R(1)
Npial                       = Spial.VertNormals;                                % N(1)
Faces                       = Spial.Faces;

%%
%% Correcting cortex overlay (Pial and White)
%%
% [NewTessFile, iSurface] = correct_surfaces_overlaping(CSurfaces(1).filename, CSurfaces(7).filename, '');

%%
%%  Compute (r) for FSAverage Surfaces
%% 
%  v0 = sum(abs(R(1) - R(0)).^2,2).^(1/2);
%  v1 = sum(abs(R(1) - R(0)).^2,2).^(1/2);
%   A = R(0); B = v0.*N(0)  r = 0 
%   A + B + C + D = R(1); B + 2C + 3C = v1.*N(1)
%   --------------------------------------------------
%   C + D = R(1) - R(0) - v0.*N(0)
%   2C + 3D = v1.*N(1) - v0.*N(0)
%   --------------------------------------------------
%   3C + 3D = 3R(1) - 3R(0) - 3*v0.*N(0)   x 3
%   2C + 3D = v1.*N(1) - v0.*N(0)
%   --------------------------------------------------
%   3C - 2C = 3R(1) - 3R(0) - 3*v0.*N(0) - ( v1.*N(1) - v0.*N(0) )
%         C = 3R(1) - 3R(0) - 3*v0.*N(0) - v1.*N(1) + v0.*N(0)
%   --------------------------------------------------
%   C + D = R(1) - R(0) - v0.*N(0)
%       D = R(1) - R(0) - v0.*N(0) - C

%%
%% BigBrain surfaces
%%
% BigBrain White
BBSwhite                    = load('cortex_layer6_high.mat');
BBRwhite                    = BBSwhite.Vertices;                % R(0)
BBNwhite                    = BBSwhite.VertNormals;             % N(0)
% BigBrain Pial
BBSpial                     = load('cortex_layer0_high.mat');
BBRpial                     = BBSpial.Vertices;                 % R(1)
BBNpial                     = BBSpial.VertNormals;             % N(1)

%%
%% Finding (r) for layers from six to two
%%
disp("-->> Computing Surfaces like BigBrain reference");
fprintf(1,'---->> Finding (r) for layers from two to six: %3d%%\n',0);
m_radius                    = 100;
radius                      = 0:(1/m_radius):1;
v_white                     = sum(abs(BBRpial - BBRwhite).^2,2).^(1/2);
v_pial                      = sum(abs(BBRpial - BBRwhite).^2,2).^(1/2);
[BBR]                       = chp(BBRwhite,BBNwhite,BBRpial,BBNpial,m_radius,radius,v_white,v_pial);
CRadius                     = {};
fprintf(1,'---->> Finding (r) for layers from two to six: %3d%%\n',fix(1/6*100));
desc_list                   = {'One','Two','Three','Four','Five','Six','White'};

% Getting BigBrain layers and radius
CRadius{1} = 1;
for s=2:6
    BBStmp                  = load(strcat('cortex_layer',num2str(s-1),'_high.mat'));
    BBRtmp                  = BBStmp.Vertices;
    [CRadius{s}]            = opt(BBR,BBRtmp,radius); 
    fprintf(1,'\b\b\b\b%3.0f%%',fix((s)/(6)*100));
end
CRadius{7} = 0;
for r=1:length(CRadius)-1
    CRadius{r} = (CRadius{r}+CRadius{r+1})/2;
end
fprintf(1,'\n');

%%
%% ===== CREATE NEW SURFACE STRUCTURE =====
%%
% A = R(0); B = N(0)  r = 0 
% C = 3R(1) - 3R(0) - 2N(0) - N(1)  
% D = R(1) - R(0) - N(0) - C
% R(r') = A + Br' + Cr'^2 + Dr'^3
% N(r') = B + 2Cr' + 3Dr'^2
% % r_six                   = 0.15;
% % A                       = Rwhite; 
% % B                       = Nwhite;
% % C                       = 3*Rpial-3*Rwhite-2*Nwhite-Npial;
% % D                       = Rpial-Rwhite-Nwhite-C;
% % Rsix                    = A + B.*r_six + C.*r_six^2 + D.*r_six^3;
% % Nsix                    = B + 2*C.*r_six + 3*D.*r_six^2;
% Rsix                      = Rwhite*(2*r_six^3 -3*r_six^2+1) + Nwhite*(r_six^3+2*r_six^2) + Rpial*(3*r_six^2-2*r_six^3) + Npial*(r_six^3-r_six^2);

% %  Linear reconstruction
%  R'(r) = R(0) + r * (R(1) - R(0))
%
[~, iSubject]               = bst_get('Subject', subID);
v_white                     = sum(abs(Rpial - Rwhite).^2,2).^(1/2);
v_pial                      = sum(abs(Rpial - Rwhite).^2,2).^(1/2);

% Creating missing surfaces
for s=1:6
    disp(strcat("-->> Getting layer ",lower(desc_list{s})," in FSAverage space"));
    [Rtmp]                  = chp(Rwhite,Nwhite,Rpial,Npial,0,CRadius{s},v_white,v_pial);
    Stmp                    = db_template('surfacemat');
    Stmp.Vertices           = Rtmp;
    Stmp.Faces              = Faces;
    Stmp.Comment            = strcat('Cortex_',lower(desc_list{s}),'_high');
    StmpFile                = file_unique(bst_fullfile(anat_path, subID, strcat('tess_cortex_',lower(desc_list{s}),'_high.mat')));
    Stmp                    = bst_history('add', Stmp, 'Create', 'Reconstruction');
    bst_save(StmpFile, Stmp, 'v7');
    StmpFileShort           = file_short(StmpFile);
    iStmp                   = db_add_surface(iSubject, StmpFileShort, Stmp.Comment,'Cortex');
    CSurfaces(s).name       = desc_list{s};
    CSurfaces(s).comment    = Stmp.Comment;
    CSurfaces(s).iSurface   = iStmp;
    CSurfaces(s).iCSurface  = false;
    CSurfaces(s).type       = 'cortex';
    CSurfaces(s).filename   = StmpFileShort;
end
end

%%
%% Computes positions of the Cubic Hermite Polynomial (CHP) within the time interval [0,1]
%%
function [R] = chp(R0,N0,R1,N1,m,radius,v0,v1)
radius = reshape(radius,1,1,m + 1);
R = (2*radius.^3 - 3*radius.^2 + 1).*R0 + ...
    (radius.^3 - 2*radius.^2 + radius).*v0.*N0 + ...
    (-2*radius.^3 + 3*radius.^2).*R1 + ...
    (radius.^3 - radius.^2).*v1.*N1;
end

%%
%% Computes optimal position of the Cubic Hermite Polynomial (CHP)
%%
function [radius_opt] = opt(R,Ropt,radius)
[~,ind_opt] = min(squeeze(sum(sum(abs(R - Ropt).^2,2),1).^(1/2)));
radius_opt = radius(ind_opt);
end