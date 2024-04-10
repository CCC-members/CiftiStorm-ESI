function AQCI = AutomaticQCI(Lvj, Cdata, Scortex)

Channels    = [Cdata.Channel.Loc];
Channels    = Channels';
ChannOri    = [Cdata.Channel.Orient];

%%
%% Checking LF correlation
%%
[Ne,Nv]     = size(Lvj);
Nv          = Nv/3;
VoxelCoord  = Scortex.Vertices;
VertNorms   = Scortex.VertNormals;
% Computing homogeneous lead field
[LvjN, LvjHom, LvjHomN]   = computeNunezLF(Lvj, VoxelCoord, VertNorms, Channels, ChannOri, 'EEG');
VertNorms   = reshape(VertNorms,[1,Nv,3]);
VertNorms   = repmat(VertNorms,[Ne,1,1]);
LvjN          = sum(LvjN.*VertNorms,3);
LvjHom        = sum(LvjHom.*VertNorms,3);
LvjHomN       = sum(LvjHomN.*VertNorms,3);

AQCI.LvjN     = LvjN;
AQCI.LvjHom   = LvjHom;
AQCI.LvjHomN  = LvjHomN;

distE=sum((LvjHom-LvjN).^2,2).^0.5;
AQCI.Channels.distE = distE;
distV=sum((LvjHom-LvjN).^2,1).^0.5;
AQCI.Voxels.distV = distV;

%%
%% Computing channel-wise correlation
%%
for k=1:size(LvjN,1)
    corelch(k,1)    = corr(LvjHom(k,:).',LvjN(k,:).');
end
% figure;
% plot([1:size(LvjN,1)],corelch,[1:size(LvjN,1)],0.7,'r-');
% xlabel('Channels');
% ylabel('Correlation');
AQCI.Channels.corelch = corelch;

%%
%% Computing voxel-wise correlation
%%
zLvjHom                 = zscore(LvjHom')';
zLvjN                   = zscore(LvjN')';
for k=1:Nv
    corelv(k,1)         = corr(zLvjHom(:,k),zLvjN(:,k));
end
corelv(isnan(corelv))   = 0;
% figure;
% plot([1:Nv],corelv);
% xlabel('Voxels');
% ylabel('Correlation');
AQCI.Voxels.corelv = corelv;

% figure;
% %colormap(gca,cmap);
% patch('Faces',Scortex.Faces,'Vertices',Scortex.Vertices,'FaceVertexCData',corelv,'FaceColor','interp','EdgeColor','none','FaceAlpha',.99);
% view(90,270);
% axis off;
% colorbar;

end

