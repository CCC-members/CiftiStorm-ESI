function [Kn,Khom,KhomN] = computeNunezLF(Ke, Vertices, VertNorms, Channels, ChannOrient, Modality)

[Ne,Nv]     = size(Ke);
Nv          = Nv/3;
if(isequal(Modality,'EEG'))    
    % H           = eye(Ne)-ones(Ne)./Ne;
    
    % Compute Distance vector R between Electrodes and Voxels
    Channels    = reshape(Channels,[Ne,1,3]);
    % VoxelCoord  = permute(VoxelCoord,[2 1]);
    Vertices    = reshape(Vertices,1,Nv,3);
    Cr          = repmat(Channels,1,Nv,1);
    VCr         = repmat(Vertices,Ne,1,1);
    R           = Cr-VCr;
    
    % Compute Nunez Homogenous Media Leadfield
    Khom        = R./repmat(sqrt(sum(R.^2,3)).^3,1,1,3);
    % Khom(:,:,1) = H*Khom(:,:,1);
    % Khom(:,:,2) = H*Khom(:,:,2);
    % Khom(:,:,3) = H*Khom(:,:,3);
    %  ver   -----------------------------------
    VertNormsR  = reshape(VertNorms,[1,Nv,3]);
    VertNormsR  = repmat(VertNormsR,[Ne,1,1]);
    KhomN       = Khom.*VertNormsR;
    
    % Compute realistics Leadfield
    Kn          = reshape(Ke,Ne,3,Nv);
    Kn          = permute(Kn,[1,3,2]);
    % Kn(:,:,1)   = H*Kn(:,:,1);
    % Kn(:,:,2)   = H*Kn(:,:,2);
    % Kn(:,:,3)   = H*Kn(:,:,3);
else
    e            = [1 0 0; 0 1 0; 0 0 1];
    Khom           = zeros(Ne,Nv,3);
    for chan = 1:Ne
        for gen = 1:Nv
            r      = Channels(:,chan) - Vertices(:,gen);
            r_norm = norm(r,2);
            r_hat  = r/r_norm;
            for dir = 1:3
                m = e(:,dir);
                B = cross(m,r_hat)/(4*pi*r_norm^2);
                Khom(chan,gen,dir) = B'*ChannOrient(:,chan);
            end
        end
    end
    VertNormsR  = reshape(VertNorms,[1,Nv,3]);
    VertNormsR  = repmat(VertNormsR,[Ne,1,1]);
    KhomN       = Khom.*VertNormsR;
    KhomN       = sum(KhomN,3);
    Kn          = reshape(K,Ne,3,Nv);
    Kn          = permute(Kn,[1,3,2]);
    Kn          = Kn.*VertNormsR;
    Kn          = sum(Kn,3);
    Khom        = permute(Khom,[1 3 2]);
    Khom        = reshape(Khom,Ne,3*Nv);
end
end

