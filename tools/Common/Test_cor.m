

qc_DC = load('/mnt/Store/ShatePoint/CC-Lab Education - Ariosky Thesis - 文档/Ariosky Thesis/Papers/CiftiStorm/Review 1er round/Source_model/QC/BST/Reports/HeadModel_CHBMP_DC/sub-CBM00001/qc_output.mat');
qc_NDC = load('/mnt/Store/ShatePoint/CC-Lab Education - Ariosky Thesis - 文档/Ariosky Thesis/Papers/CiftiStorm/Review 1er round/Source_model/QC/BST/Reports/HeadModel_CHBMP_NDC/sub-CBM00001/qc_output.mat');
Nv = size(qc_NDC.Ke,2)/3;

%%
%% Computing channel-wise correlation
%%
corelch_DC = load('/mnt/Store/ShatePoint/CC-Lab Education - Ariosky Thesis - 文档/Ariosky Thesis/Papers/CiftiStorm/Review 1er round/Source_model/QC/BST/Reports/HeadModel_CHBMP_DC/sub-CBM00001/qc_corelch.mat');
corelch_NDC = load('/mnt/Store/ShatePoint/CC-Lab Education - Ariosky Thesis - 文档/Ariosky Thesis/Papers/CiftiStorm/Review 1er round/Source_model/QC/BST/Reports/HeadModel_CHBMP_NDC/sub-CBM00001/qc_corelch.mat');

figure;
plot([1:size(qc_NDC.Kn,1)],corelch_NDC.corelch,[1:size(qc_NDC.Kn,1)],0.7,'--','Color','r');
hold on
plot([1:size(qc_DC.Kn,1)],corelch_DC.corelch,[1:size(qc_DC.Kn,1)],0.7,'-','Color','b');
xlabel('Channels');
ylabel('Correlation');
title(strcat('Correlation between both lead fields channel-wise'));

%%
%% Computing voxel-wise correlation
%%
corelv_DC = load('/mnt/Store/ShatePoint/CC-Lab Education - Ariosky Thesis - 文档/Ariosky Thesis/Papers/CiftiStorm/Review 1er round/Source_model/QC/BST/Reports/HeadModel_CHBMP_DC/sub-CBM00001/qc_corelv.mat');
corelv_NDC = load('/mnt/Store/ShatePoint/CC-Lab Education - Ariosky Thesis - 文档/Ariosky Thesis/Papers/CiftiStorm/Review 1er round/Source_model/QC/BST/Reports/HeadModel_CHBMP_NDC/sub-CBM00001/qc_corelv.mat');
figure;
plot([1:Nv],corelv_NDC.corelv,'--','Color','r');
hold on;
plot([1:Nv],corelv_DC.corelv','-','Color','b');
xlabel('Voxels');
ylabel('Correlation');
title(strcat('Correlation both lead fields Voxel wise'));


%%
%% Distance correlation map
%%

cortexNDC = load("/home/ariosky/.brainstorm/local_db/HeadModel_CHBMP_NDC/anat/sub-CBM00001/tess_cortex_concat_8000V.mat");
cortexDC  = load("/home/ariosky/.brainstorm/local_db/HeadModel_CHBMP_DC/anat/sub-CBM00001/tess_cortex_concat_8000V_fix.mat");
old_DC    = load("/mnt/Store/ShatePoint/CC-Lab Education - Ariosky Thesis - 文档/Ariosky Thesis/Papers/CiftiStorm/Review 1er round/Source_model/QC/old_corelv.mat");
minColorLimit = min([min(corelv_NDC.corelv),min(corelv_DC.corelv)]);
maxColorLimit = max([max(corelv_NDC.corelv),max(corelv_DC.corelv)]);
fig = figure;
fig_text            =  strcat('Distance correlation map');
title(fig_text);
%colormap(gca,cmap);
sp1 = subplot(1,2,1);
p1 = patch('Faces',cortexNDC.Faces,'Vertices',cortexNDC.Vertices,'FaceVertexCData',corelv_NDC.corelv,'FaceColor','interp','EdgeColor','none','FaceAlpha',.99);
view(90,270);
axis off;
clim(sp1,[minColorLimit maxColorLimit]);

rotate3d on
copyobj(p1,sp1);

sp2 = subplot(1,2,2);
p2 = patch('Faces',cortexDC.Faces,'Vertices',cortexDC.Vertices,'FaceVertexCData',corelv_DC.corelv,'FaceColor','interp','EdgeColor','none','FaceAlpha',.99);
view(90,270);
axis off;
clim(sp2,[minColorLimit maxColorLimit]);
rotate3d on
copyobj(p2,sp2);


ax = axes(fig,'visible','off');
c = colorbar(ax,'Position',[0.93 0.168 0.022 0.7]);  % attach colorbar to h
colormap(c);
clim(ax,[minColorLimit maxColorLimit]); 
