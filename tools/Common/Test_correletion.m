
input_path = "/mnt/Store/ShatePoint/CC-Lab Education - Ariosky Thesis - 文档/Ariosky Thesis/Papers/CiftiStorm/Review 1er round/Source_model/QC";
output_path = "/mnt/Store/ShatePoint/CC-Lab Education - Ariosky Thesis - 文档/Ariosky Thesis/Papers/CiftiStorm/Review 1er round/Source_model/QC";


qc_DC = load(fullfile(input_path,'BST/Reports/HeadModel_CHBMP_DC/sub-CBM00001/qc_output.mat'));
qc_NDC = load(fullfile(input_path,'BST/Reports/HeadModel_CHBMP_NDC/sub-CBM00001/qc_output.mat'));
Nv = size(qc_NDC.Ke,2)/3;

%%
%% Computing channel-wise correlation
%%
corelch_DC = load(fullfile(input_path,'BST/Reports/HeadModel_CHBMP_DC/sub-CBM00001/qc_corelch.mat'));
corelch_NDC = load(fullfile(input_path,'BST/Reports/HeadModel_CHBMP_NDC/sub-CBM00001/qc_corelch.mat'));

fig1 = figure("Color",'w');
plot([1:size(qc_NDC.Kn,1)],corelch_NDC.corelch,'-','Color','r');
hold on
plot([1:size(qc_DC.Kn,1)],corelch_DC.corelch,'-','Color','g');
hold on
yline(0.7,'m-.','Threshold','LineWidth',2,'LabelHorizontalAlignment','left');
xlabel('Channels');
ylabel('Correlation');
xlim([0 length(corelch_DC.corelch)+5]);
title(strcat('Correlation between both lead fields channel-wise'),'FontSize',14,'FontWeight','bold');
legend('No corrected','Corrected','Location','south','Orientation','horizontal');
saveas(fig1,fullfile(output_path,strcat('Correlation between both lead fields channel-wise NDC & DC (3).fig')));
saveas(fig1,fullfile(output_path,strcat('Correlation between both lead fields channel-wise NDC & DC (3).png')));
close(fig1);

%%
%% Computing voxel-wise correlation
%%
corelv_DC = load(fullfile(input_path,'BST/Reports/HeadModel_CHBMP_DC/sub-CBM00001/qc_corelv.mat'));
corelv_NDC = load(fullfile(input_path,'BST/Reports/HeadModel_CHBMP_NDC/sub-CBM00001/qc_corelv.mat'));
yminLimit = min([min(corelv_NDC.corelv),min(corelv_DC.corelv)]);
ymaxLimit = max([max(corelv_NDC.corelv),max(corelv_DC.corelv)]);
fig2 = figure("Color",'w');
plot([1:Nv],corelv_NDC.corelv,'-','Color','r');
hold on;
plot([1:Nv],corelv_DC.corelv','-','Color','g');
hold on
yline(0.3,'m-.','Threshold','LineWidth',2,'LabelHorizontalAlignment','left');
xlabel('Voxels');
ylabel('Correlation');
xlim([0 Nv+5]);
yticks((yminLimit - 0.05):0.2:1)
yticklabels(round((yminLimit - 0.05):0.2:1,2));
title(strcat('Correlation both lead fields Voxel wise'),'FontSize',14,'FontWeight','bold');
legend('No corrected','Corrected','Location','south','Orientation','horizontal');
saveas(fig2,fullfile(output_path,strcat('Correlation both lead fields Voxel wise NDC & DC (3).fig')));
saveas(fig2,fullfile(output_path,strcat('Correlation both lead fields Voxel wise NDC & DC (3).png')));
close(fig2);

%%
%% Distance correlation map
%%

cortexNDC = load("/home/ariosky/.brainstorm/local_db/HeadModel_CHBMP_DC/anat/sub-CBM00001/tess_cortex_concat_8000V_fix.mat");
cortexDC  = load("/home/ariosky/.brainstorm/local_db/HeadModel_CHBMP_DC/anat/sub-CBM00001/tess_cortex_concat_8000V_fix.mat");
smoothValue          = 0.3;
SurfSmoothIterations = 10;
cortexNDC.Vertices = tess_smooth(cortexNDC.Vertices, smoothValue, SurfSmoothIterations, cortexNDC.VertConn, 1);
cortexDC.Vertices = tess_smooth(cortexDC.Vertices, smoothValue, SurfSmoothIterations, cortexDC.VertConn, 1);
minColorLimit = min([min(corelv_NDC.corelv),min(corelv_DC.corelv)]);
maxColorLimit = max([max(corelv_NDC.corelv),max(corelv_DC.corelv)]);
fig3 = figure("Color",'w');
fig_text            =  strcat('Distance correlation map');
title(fig_text);
%colormap(gca,cmap);
sp1 = subplot(1,2,1);
subtitle("No corrected");
p1 = patch('Faces',cortexNDC.Faces,'Vertices',cortexNDC.Vertices,'FaceVertexCData',1-corelv_NDC.corelv,'FaceColor','interp','EdgeColor','none','FaceAlpha',.99);
view(-180,-90);
axis off;
sp1.Colormap = Cmap1_cor;
clim(sp1,[minColorLimit maxColorLimit]);

rotate3d on
copyobj(p1,sp1);

sp2 = subplot(1,2,2);
subtitle("Corrected");
p2 = patch('Faces',cortexDC.Faces,'Vertices',cortexDC.Vertices,'FaceVertexCData',1-corelv_DC.corelv,'FaceColor','interp','EdgeColor','none','FaceAlpha',.99);
view(-180,-90);
axis off;
sp2.Colormap = Cmap1_cor;
clim(sp2,[minColorLimit maxColorLimit]);
rotate3d on
copyobj(p2,sp2);

ax = axes(fig3,'visible','off');
c = colorbar(ax,'Position',[0.93 0.110 0.012 0.8],'FontSize',12);  % attach colorbar to h
c.Ticks  = minColorLimit:0.1:maxColorLimit;
c.TickLabels = round(maxColorLimit:-0.1:minColorLimit,2);
ax.Colormap = Cmap1_cor;
% colormap(c);
clim(ax,[minColorLimit maxColorLimit]);

saveas(fig3,fullfile(output_path,strcat('Distance correlation map NDC & DC (inflate).fig')));
saveas(fig3,fullfile(output_path,strcat('Distance correlation map NDC & DC (inflate).png')));
close(fig3);
