function [Kn,Khom] = computeNunezLF(Ke,VoxelCoord, channels)

[Ne,Nv]     = size(Ke);
Nv          = Nv/3;
% H           = eye(Ne)-ones(Ne)./Ne;

% Compute Distance vector R between Electrodes and Voxels
channels    = reshape(channels,[Ne,1,3]);
VoxelCoord  = permute(VoxelCoord,[2 1]);
VoxelCoord  = reshape(VoxelCoord,1,Nv,3);
Cr          = repmat(channels,1,Nv,1);
VCr         = repmat(VoxelCoord,Ne,1,1);
R           = Cr-VCr;

% Compute Nunez Homogenous Media Leadfield
Khom        = R./repmat(sqrt(sum(R.^2,3)).^3,1,1,3);
% Khom(:,:,1) = H*Khom(:,:,1);
% Khom(:,:,2) = H*Khom(:,:,2);
% Khom(:,:,3) = H*Khom(:,:,3);

% Compute realistics Leadfield
Kn          = reshape(Ke,Ne,3,Nv);
Kn          = permute(Kn,[1,3,2]);
% Kn(:,:,1)   = H*Kn(:,:,1);
% Kn(:,:,2)   = H*Kn(:,:,2);
% Kn(:,:,3)   = H*Kn(:,:,3);
end

