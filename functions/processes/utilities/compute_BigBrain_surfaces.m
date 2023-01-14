function CSurfaces = compute_BigBrain_surfaces(subID, CSurfaces)
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

%%
%%  Compute (r) for FSAverage Surfaces
%% 
%   A = R(0); B = N(0)  r = 0 
%   A + B + C + D = R(1); B + 2C + 3C = N(1)
%   --------------------------------------------------
%   C + D = R(1) - R(0) - N(0)
%   2C + 3D = N(1) - N(0)
%   --------------------------------------------------
%   3C + 3D = 3R(1) - 3R(0) - 3N(0)   x 3
%   2C + 3D = N(1) - N(0)
%   --------------------------------------------------
%   3C - 2C = 3R(1) - 3R(0) - 3N(0) - ( N(1) - N(0) )
%         C = 3R(1) - 3R(0) - 3N(0) - N(1) + N(0)
%   --------------------------------------------------
%   C + D = R(1) - R(0) - N(0)
%       D = R(1) - R(0) - N(0) - C

%%
%% BigBrain surfaces
%%
% White
BBSwhite        = load('cortex_layer6_high.mat');
RBBSwhite       = BBSwhite.Vertices;                % R(0)
% Six
BBSsix          = load('cortex_layer5_high.mat');
RBBSsix         = BBSsix.Vertices;  
% Five
BBSfive         = load('cortex_layer4_high.mat');
RBBSfive        = BBSfive.Vertices;  
% Four
BBSfour         = load('cortex_layer3_high.mat');
RBBSfour        = BBSfour.Vertices;  
% Three
BBSthree        = load('cortex_layer2_high.mat');
RBBSthree       = BBSthree.Vertices;  
% Two
BBStwo          = load('cortex_layer1_high.mat');
RBBStwo         = BBStwo.Vertices;  
% Pial
BBSpial         = load('cortex_layer0_high.mat');
RBBSpial        = BBSpial.Vertices;                 % R(1)

%%
%%  Compute (r) for BigBrain Surfaces
%% 
%   A = R(0); B = N(0)  r = 0 
%   A + B + C + D = R(1); B + 2C + 3C = N(1)
%   --------------------------------------------------
%   C + D = R(1) - R(0) - N(0)
%   2C + 3D = N(1) - N(0)
%   --------------------------------------------------
%   3C + 3D = 3R(1) - 3R(0) - 3N(0)   x 3
%   2C + 3D = N(1) - N(0)
%   --------------------------------------------------
%   3C - 2C = 3R(1) - 3R(0) - 3N(0) - ( N(1) - N(0) )
%         C = 3R(1) - 3R(0) - 3N(0) - N(1) + N(0)
%         C = 3R(1) - 3R(0) - 2N(0) - N(1)
%   --------------------------------------------------
%   C + D = R(1) - R(0) - N(0)
%       D = R(1) - R(0) - N(0) - C
%
%  ---------------------------------------------------
%  Linear reconstruction
%  R'(r) = R(0) + r * (R(1) - R(0))
%


% Finding (r) for layers from six to two
disp("-->> Computing Surfaces like BigBrain reference");
fprintf(1,'---->> Finding (r) for layers from six to two: %3d%%\n',0);
radios = [0:0.001:1];
n_six = []; n_five = []; n_four = []; n_three = []; n_two = [];
for r=1:length(radios)    
    RBBSsix_p   = RBBSwhite + radios(r) * (RBBSpial - RBBSwhite);
    Snorm       = norm(RBBSsix_p - RBBSsix, 2);
    n_six       = [n_six Snorm];
    
    RBBSfive_p  = RBBSwhite + radios(r) * (RBBSpial - RBBSwhite);
    Snorm       = norm(RBBSfive_p - RBBSfive, 2);
    n_five      = [n_five Snorm];
    
    RBBSfour_p  = RBBSwhite + radios(r) * (RBBSpial - RBBSwhite);
    Snorm       = norm(RBBSfour_p - RBBSfour, 2);
    n_four      = [n_four Snorm];
    
    RBBSthree_p = RBBSwhite + radios(r) * (RBBSpial - RBBSwhite);
    Snorm       = norm(RBBSthree_p - RBBSthree, 2);
    n_three     = [n_three Snorm];
    
    RBBStwo_p   = RBBSwhite + radios(r) * (RBBSpial - RBBSwhite);
    Snorm       = norm(RBBStwo_p - RBBStwo, 2);
    n_two       = [n_two Snorm];    
    fprintf(1,'\b\b\b\b%3.0f%%',(r)/(length(radios))*100);
end
[~,ind_six] = min(n_six);
r_six = radios(ind_six);

[~,ind_five] = min(n_five);
r_five = radios(ind_five);

[~,ind_four] = min(n_four);
r_four = radios(ind_four);

[~,ind_three] = min(n_three);
r_three = radios(ind_three);

[~,ind_two] = min(n_two);
r_two = radios(ind_two);
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
% Rsix                    = Rwhite*(2*r_six^3 -3*r_six^2+1) + Nwhite*(r_six^3+2*r_six^2) + Rpial*(3*r_six^2-2*r_six^3) + Npial*(r_six^3-r_six^2);

% %  Linear reconstruction
%  R'(r) = R(0) + r * (R(1) - R(0))
%
[~, iSubject]           = bst_get('Subject', subID);

% Creating surface 6
disp("-->> Getting layer six in FSAverage space");
Rsix                    = Rwhite + r_six * (Rpial - Rwhite);
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
Rfive                   = Rwhite + r_five * (Rpial - Rwhite);
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
Rfour                   = Rwhite + r_four * (Rpial - Rwhite);
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
Rthree                   = Rwhite + r_three * (Rpial - Rwhite);
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
Rtwo                    = Rwhite + r_two * (Rpial - Rwhite);
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

