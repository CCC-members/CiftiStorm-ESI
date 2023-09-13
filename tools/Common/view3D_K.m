function [fig] = view3D_K(fig_title, Kq, cortex, head, channels, elecIndex)

%% define electrode to show and Marker size
%elecIndex = 12; %5 8
mS = 50;

%% initial computations
XYZ = cortex.Vertices;
[Ne, Ng, ~] = size(Kq);
Kq = permute(Kq, [1 3 2]);
Kq = permute(Kq, [3 2 1]);
Kqm = sqrt(dot(Kq,Kq,2));
Kqme = Kqm(:,:,elecIndex);

%% plot Lead Field
fig = figure('Name', fig_title, 'NumberTitle', 'off', 'units','normalized','outerposition',[0 0 1 1]);
hold on;
scatter3(XYZ(:,1),XYZ(:,2),XYZ(:,3),Kqme/max(Kqme)*2*mS,'r','filled');
patch('Vertices',head.Vertices,'Faces',head.Faces,'EdgeColor','none','FaceAlpha',.2,'FaceColor',[0.50,0.50,0.50]);
quiver3(XYZ(:,1),XYZ(:,2),XYZ(:,3),Kq(:,1,elecIndex),Kq(:,2,elecIndex),Kq(:,3,elecIndex),'LineWidth',2,'Color','k','AutoScaleFactor',3);
scatter3(channels(:,1),channels(:,2),channels(:,3),mS,'g','filled');
scatter3(channels(elecIndex,1),channels(elecIndex,2),channels(elecIndex,3),mS,'b','filled');
axis equal off;
title(fig_title)
rotate3d('on')





