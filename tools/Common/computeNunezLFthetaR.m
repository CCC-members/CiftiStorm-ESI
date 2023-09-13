function [Kn,Khomn,Khom,Kr,M,angle] = computeNunezLFthetaR( K,LFisNormal,VertNorms,VoxelCoord,Channels)
% this function computed homogenous lead field using cortex and channel
% information of test lead field
% Input:
%       K= lead field gain plot
%       LFisNormal= flag for normal or not-normal LF
%       VertNorms= ver normals for cortex from brainstorm
%       VoxelCoord= voxel coordinate for cortex from brainstorm
%       Channels= EEG channels coordinate information
% Output:
%       Khomn = Normalised Homogeneous LF
%       Khom = Homogenous LF
%       Kr = projected to normal test LF   
% Authors: Usama Riaz, Fuleah A Razzaq, Pedro A Valdes
[Ne,Nv]=size(K);
H=eye(Ne)-ones(Ne)./Ne;
if (LFisNormal)
VertNorms=reshape(VertNorms,[1,Nv,3]);VertNorms=repmat(VertNorms,[Ne,1,1]);
Kn=K;
else
%Intialization if LFisNormal = 0 
Nv=Nv/3;
K=reshape(K,Ne,3,Nv);
K=permute(K,[1,3,2]);
%% compute lead field in direction of vertex normal n
VertNorms=reshape(VertNorms,[1,Nv,3]);
VertNorms=repmat(VertNorms,[Ne,1,1]);
Kn=sum(K.*VertNorms,3);
Kr=repmat(Kn,1,1,3);
Kr=Kr.*VertNorms;
Kr=permute(Kr,[1,3,2]);
Kr=reshape(Kr,[Ne,3*Nv]);
end
%% Compute Distance vector R between Electrodes and Voxels
Channels=reshape(Channels,[Ne,1,3]);
VoxelCoord=permute(VoxelCoord,[2 1]); 
VoxelCoord=reshape(VoxelCoord,1,Nv,3);
R=repmat(Channels,1,Nv,1)-repmat(VoxelCoord,Ne,1,1);
%% Compute Nunez Homogenous Media Leadfield 
M = sqrt(sum(R.^2,3));
M = M./(max(M(:)));
sc = sum(VertNorms.*R,3);
angle = acos(sc./M);
angle(imag(angle) ~= 0) = 0;
% Khom=sc./(M.^3);
%% compute adjusted homogeneous LF
idx = M<0.15;
M(idx) = 0.15;
Khom=sc./(M.^3);
%% Applying Average Reference and normalizing
Khomn=H*Khom;
Kn=H*Kn;
Khomn=Khomn./sqrt(sum(Khomn(:).^2));
Kn=Kn./sqrt(sum(Kn(:).^2));
end