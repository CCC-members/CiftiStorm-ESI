close all
clear all

% Initial point
Surf0 = load('/mnt/CoLab_Cloud/CCLab_OneDrive_SharePoint/CC-Lab Education - Ariosky Thesis - 文档/Ariosky Thesis/BigBrain/white.mat');
R0 = Surf0.Vertices;
N0 = Surf0.VertNormals;
F0 = Surf0.Faces;
% Final point
Surf1 = load('/mnt/CoLab_Cloud/CCLab_OneDrive_SharePoint/CC-Lab Education - Ariosky Thesis - 文档/Ariosky Thesis/BigBrain/pial.mat');
R1 = Surf1.Vertices;
N1 = Surf1.VertNormals;
F1 = Surf1.Faces;

% Plot surface data
figure; 
patch('FaceAlpha',0.5,'EdgeAlpha',0.5,'Vertices',R0,...
    'MarkerSize',1,...
    'MarkerFaceColor',[0.650980392156863 0.650980392156863 0.650980392156863],...
    'MarkerEdgeColor',[0.650980392156863 0.650980392156863 0.650980392156863],...
    'Marker','.',...
    'LineJoin','chamfer',...
    'LineWidth',2,...
    'Faces',F0,...
    'FaceColor',[0.650980392156863 0.650980392156863 0.650980392156863],...
    'EdgeColor',[0.650980392156863 0.650980392156863 0.650980392156863]);
hold on;
patch('FaceAlpha',0.01,'EdgeAlpha',0.01,'Vertices',R1,...
    'MarkerSize',1,...
    'MarkerFaceColor',[0 1 0],...
    'MarkerEdgeColor',[0 1 0],...
    'Marker','.',...
    'LineJoin','chamfer',...
    'LineWidth',2,...
    'Faces',F1,...
    'FaceColor',[0 1 0],...
    'EdgeColor',[0 1 0]);

m  = 100; % step number
t  = 0:1/m:1; % time steps

v0 = sum(abs(R1 - R0).^2,2).^(1/2);
v1 = sum(abs(R1 - R0).^2,2).^(1/2);

[R,V,d] = chp(R0,N0,R1,N1,m,t,v0,v1);
figure;
quiver3(r(:,1),r(:,2),r(:,3),v(:,1),v(:,2),v(:,3));
hold on;
quiver3([r0(:,1);r1(:,1)],[r0(:,2);r1(:,2)],[r0(:,3);r1(:,3)],[n0(:,1);n1(:,1)],[n0(:,2);n1(:,2)],[n0(:,3);n1(:,3)]);


%% Computes positions and velocities of the Cubic Hermite Polynomial (CHP) within the time interval [0,1]
function [R,V,d] = chp(R0,N0,R1,N1,m,t,v0,v1)
t = reshape(t,1,1,m + 1);
% Positions
R = (2*t.^3 - 3*t.^2 + 1).*R0 + ...
    (t.^3 - 2*t.^2 + t).*v0.*N0 + ...
    (-2*t.^3 + 3*t.^2).*R1 + ...
    (t.^3 - t.^2).*v1.*N1;
% Velocities
V = 6*(t.^2 - t).*R0 + ...
    (3*t.^2 - 4*t + 1).*v0.*N0 + ...
    6*(-t.^2 + t).*R1 + ...
    (3*t.^2 - 2*t).*v1.*N1;
% Distance
v_norm = squeeze(sum(abs(V).^2,2).^(1/2));
d      = (1/m)*(sum(v_norm,2) - v_norm(:,1)/2 - v_norm(:,end)/2);
end
