function [CSurfaces, CRadius] = compute_BigBrain_surfaces(subID, CSurfaces)
%PROCESS_GEN_BB_SURFACES Summary of this function goes here
%   Detailed explanation goes here

ProtocolInfo            = bst_get('ProtocolInfo');
anat_path               = ProtocolInfo.SUBJECTS;
[~,~,iSurface]          = bst_get('SurfaceFile', CSurfaces(7).filename);
CSurfaces(7).iSurface   = iSurface;
Swhite                  = load(fullfile(anat_path,CSurfaces(7).filename));
Rwhite                  = Swhite.Vertices;                                  % R(0) 
Nwhite                  = Swhite.VertNormals;                               % N(0)
[~,~,iSurface]          = bst_get('SurfaceFile', CSurfaces(1).filename);
CSurfaces(1).iSurface   = iSurface;
Spial                   = load(fullfile(anat_path,CSurfaces(1).filename));
Rpial                   = Spial.Vertices;                                   % R(1)
Npial                   = Spial.VertNormals;                                % N(1)
Faces                   = Spial.Faces;

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
% White
BBSwhite        = load('cortex_layer6_high.mat');
BBRwhite       = BBSwhite.Vertices;                % R(0)
BBNwhite       = BBSwhite.VertNormals;             % N(0)
% Six
BBSsix          = load('cortex_layer5_high.mat');
BBRsix         = BBSsix.Vertices;  
% Five
BBSfive         = load('cortex_layer4_high.mat');
BBRfive        = BBSfive.Vertices;  
% Four
BBSfour         = load('cortex_layer3_high.mat');
BBRfour        = BBSfour.Vertices;  
% Three
BBSthree        = load('cortex_layer2_high.mat');
BBRthree       = BBSthree.Vertices;  
% Two
BBStwo          = load('cortex_layer1_high.mat');
BBRtwo         = BBStwo.Vertices;  
% Pial
BBSpial         = load('cortex_layer0_high.mat');
BBRpial        = BBSpial.Vertices;                 % R(1)
BBNpial        = BBSpial.VertNormals;             % N(0)

%% Finding (r) for layers from six to two
disp("-->> Computing Surfaces like BigBrain reference");
fprintf(1,'---->> Finding (r) for layers from six to two: %3d%%\n',0);
m_radius       = 100;
radius         = 0:(1/m_radius):1;
v_white        = sum(abs(BBRpial - BBRwhite).^2,2).^(1/2);
v_pial         = sum(abs(BBRpial - BBRwhite).^2,2).^(1/2);
[BBR]          = chp(BBRwhite,BBNwhite,BBRpial,BBNpial,m_radius,radius,v_white,v_pial);
[radius_six]   = opt(BBR,BBRsix,radius); 
[radius_five]  = opt(BBR,BBRfive,radius); 
[radius_four]  = opt(BBR,BBRfour,radius); 
[radius_three] = opt(BBR,BBRthree,radius);
[radius_two]   = opt(BBR,BBRtwo,radius); 

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
% Rsix                    = Rwhite*(2*r_six^3 -3*r_six^2+1) + Nwhite*(r_six^3+2*r_six^2) + Rpial*(3*r_six^2-2*r_six^3) + Npial*(r_six^3-r_six^2);

% %  Linear reconstruction
%  R'(r) = R(0) + r * (R(1) - R(0))
%
[~, iSubject]           = bst_get('Subject', subID);
v_white                 = sum(abs(Rpial - Rwhite).^2,2).^(1/2);
v_pial                  = sum(abs(Rpial - Rwhite).^2,2).^(1/2);

% Creating surface 6
disp("-->> Getting layer six in FSAverage space");
[Rsix]                  = chp(Rwhite,Nwhite,Rpial,Npial,0,radius_six,v_white,v_pial);
Ssix                    = db_template('surfacemat');
Ssix.Vertices           = Rsix;
Ssix.Faces              = Faces;
Ssix.Comment            = 'Cortex_six_high';
SsixFile                = file_unique(bst_fullfile(anat_path, subID, 'tess_cortex_six_high.mat'));
Ssix                    = bst_history('add', Ssix, 'Create', 'Reconstruction');
bst_save(SsixFile, Ssix, 'v7');
SsixFileShort           = file_short(SsixFile);
iSsix                   = db_add_surface(iSubject, SsixFileShort, Ssix.Comment,'Cortex');
CSurfaces(6).name       = 'Six';
CSurfaces(6).comment    = Ssix.Comment;
CSurfaces(6).iSurface   = iSsix;
CSurfaces(6).iCSurface  = false;
CSurfaces(6).type       = 'cortex';
CSurfaces(6).filename   = SsixFileShort;

% Creating surface 5
disp("-->> Getting layer five in FSAverage space");
[Rfive]                  = chp(Rwhite,Nwhite,Rpial,Npial,0,radius_five,v_white,v_pial);
Sfive                   = db_template('surfacemat');
Sfive.Vertices          = Rfive;
Sfive.Faces             = Faces;
Sfive.Comment           = 'Cortex_five_high';
SfiveFile               = file_unique(bst_fullfile(anat_path, subID, 'tess_cortex_five_high.mat'));
Sfive                   = bst_history('add', Sfive, 'Create', 'Reconstruction');
bst_save(SfiveFile, Sfive, 'v7');
SfiveFileShort          = file_short(SfiveFile);
iSfive                  = db_add_surface(iSubject, SfiveFileShort, Sfive.Comment,'Cortex');
CSurfaces(5).name       = 'Five';
CSurfaces(5).comment    = Sfive.Comment;
CSurfaces(5).iSurface   = iSfive;
CSurfaces(5).iCSurface  = false;
CSurfaces(5).type       = 'cortex';
CSurfaces(5).filename   = SfiveFileShort;

% Creating surface 4
disp("-->> Getting layer four in FSAverage space");
[Rfour]                  = chp(Rwhite,Nwhite,Rpial,Npial,0,radius_four,v_white,v_pial);
Sfour                   = db_template('surfacemat');
Sfour.Vertices          = Rfour;
Sfour.Faces             = Faces;
Sfour.Comment           = 'Cortex_four_high';
SfourFile               = file_unique(bst_fullfile(anat_path, subID, 'tess_cortex_four_high.mat'));
Sfour                   = bst_history('add', Sfour, 'Create', 'Reconstruction');
bst_save(SfourFile, Sfour, 'v7');
SfourFileShort          = file_short(SfourFile);
iSfour                  = db_add_surface(iSubject, SfourFileShort, Sfour.Comment,'Cortex');
CSurfaces(4).name       = 'Four';
CSurfaces(4).comment    = Sfour.Comment;
CSurfaces(4).iSurface   = iSfour;
CSurfaces(4).iCSurface  = false;
CSurfaces(4).type       = 'cortex';
CSurfaces(4).filename   = SfourFileShort;

% Creating surface 3
disp("-->> Getting layer three in FSAverage space");
[Rthree]                  = chp(Rwhite,Nwhite,Rpial,Npial,0,radius_three,v_white,v_pial);
Sthree                  = db_template('surfacemat');
Sthree.Vertices         = Rthree;
Sthree.Faces            = Faces;
Sthree.Comment          = 'Cortex_three_high';
SthreeFile              = file_unique(bst_fullfile(anat_path, subID, 'tess_cortex_three_high.mat'));
Sthree                  = bst_history('add', Sthree, 'Create', 'Reconstruction');
bst_save(SthreeFile, Sthree, 'v7');
SthreeFileShort         = file_short(SthreeFile);
iSthree                 = db_add_surface(iSubject, SthreeFileShort, Sthree.Comment,'Cortex');
CSurfaces(3).name       = 'Three';
CSurfaces(3).comment    = Sthree.Comment;
CSurfaces(3).iSurface   = iSthree;
CSurfaces(3).iCSurface  = false;
CSurfaces(3).type       = 'cortex';
CSurfaces(3).filename   = SthreeFileShort;

% Creating surface 2
disp("-->> Getting layer two in FSAverage space");
[Rtwo]                  = chp(Rwhite,Nwhite,Rpial,Npial,0,radius_two,v_white,v_pial);
Stwo                    = db_template('surfacemat');
Stwo.Vertices           = Rtwo;
Stwo.Faces              = Faces;
Stwo.Comment            = 'Cortex_two_high';
StwoFile                = file_unique(bst_fullfile(anat_path, subID, 'tess_cortex_two_high.mat'));
Stwo                    = bst_history('add', Stwo, 'Create', 'Reconstruction');
bst_save(StwoFile, Stwo, 'v7');
StwoFileShort           = file_short(StwoFile);
iStwo                   = db_add_surface(iSubject, StwoFileShort, Stwo.Comment,'Cortex');
CSurfaces(2).name       = 'Two';
CSurfaces(2).comment    = Stwo.Comment;
CSurfaces(2).iSurface   = iStwo;
CSurfaces(2).iCSurface  = false;
CSurfaces(2).type       = 'cortex';
CSurfaces(2).filename   = StwoFileShort;
end

%% Computes positions of the Cubic Hermite Polynomial (CHP) within the time interval [0,1]
function [R] = chp(R0,N0,R1,N1,m,radius,v0,v1)
radius = reshape(radius,1,1,m + 1);
R = (2*radius.^3 - 3*radius.^2 + 1).*R0 + ...
    (radius.^3 - 2*radius.^2 + radius).*v0.*N0 + ...
    (-2*radius.^3 + 3*radius.^2).*R1 + ...
    (radius.^3 - radius.^2).*v1.*N1;
end
%% Computes optimal position of the Cubic Hermite Polynomial (CHP)
function [radius_opt] = opt(R,Ropt,radius)
[~,ind_opt] = min(squeeze(sum(sum(abs(R - Ropt).^2,2),1).^(1/2)));
radius_opt = radius(ind_opt);
end