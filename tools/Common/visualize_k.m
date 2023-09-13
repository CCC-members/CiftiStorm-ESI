function visualize_k(leadfield,sources,scalp,elec_file,e)

leadfield = '/home/ckbreaker/Documents/LF/Pedrito/newSimBioModel/LF/Monkey-EEG.mat';
sources = '/home/ckbreaker/Documents/LF/Pedrito/newSimBioModel/Cortex-mid_Su.mat';
scalp = '/home/ckbreaker/Documents/LF/Pedrito/newSimBioModel/Inskull_Su-corrected.mat';
elec_file = '/home/ckbreaker/Documents/LF/Pedrito/newSimBioModel/EEG-elecs_Su.mat';
e = 12; %5 8

load(leadfield);
sources = load(sources);
Scalp = load(scalp);
load(elec_file);

%XYZ = sources.vertices(1:2:end,:);
%XYZ = sources.vertices(2:2:end,:);

XYZ = sources.vertices;

[Ne, Ng] = size(K);
Kq = reshape(K, [Ne 3 Ng/3]);
Kq = permute(Kq, [3 2 1]);
Kqm = sqrt(dot(Kq,Kq,2));
Kqme = Kqm(:,:,e);

figure; hold on;
scatter3(XYZ(:,1),XYZ(:,2),XYZ(:,3),Kqme/max(Kqme)*50,'r','filled');
patch('Vertices',Scalp.vertices,'Faces',Scalp.faces,'EdgeColor','none','FaceAlpha',.2,'FaceColor',[202 189 38]/255);
quiver3(XYZ(:,1),XYZ(:,2),XYZ(:,3),Kq(:,1,e),Kq(:,2,e),Kq(:,3,e),'Color','k','AutoScaleFactor',3);
scatter3(electrodes(:,1),electrodes(:,2),electrodes(:,3),50,'g','filled');
scatter3(electrodes(e,1),electrodes(e,2),electrodes(e,3),50,'b','filled');
axis equal off;
cameratoolbar;
whitebg('w');
%% Crear laplaciano
o = ones(Ng/3,1);
L = spdiags([-o 2*o -o],-1:1,Ng/3,Ng/3);
L(1,Ng/3) = -1;
L(Ng/3,1) = -1;
% Lo = o'/L;
% scatter3(XYZ(:,1),XYZ(:,2),XYZ(:,3),Lo/max(Lo)*50,'r','filled');
% hold on;
% text(XYZ(1,1),XYZ(1,2),XYZ(1,3),'1');
% cameratoolbar;
%% Standardized K
L3 = 1e-5*kron(L,eye(3));
K = K/L3;

[Ne, Ng] = size(K);
Kq = reshape(K, [Ne 3 Ng/3]);
Kq = permute(Kq, [3 2 1]);
Kqm = sqrt(dot(Kq,Kq,2));
Kqme = Kqm(:,:,e);

figure; hold on;
scatter3(XYZ(:,1),XYZ(:,2),XYZ(:,3),Kqme/max(Kqme)*50,'r','filled');
patch('Vertices',Scalp.vertices,'Faces',Scalp.faces,'EdgeColor','none','FaceAlpha',.2,'FaceColor',[202 189 38]/255);
quiver3(XYZ(:,1),XYZ(:,2),XYZ(:,3),Kq(:,1,e),Kq(:,2,e),Kq(:,3,e),'Color','k','AutoScaleFactor',3);
scatter3(electrodes(:,1),electrodes(:,2),electrodes(:,3),50,'g','filled');
scatter3(electrodes(e,1),electrodes(e,2),electrodes(e,3),50,'b','filled');
axis equal off;
cameratoolbar;

end


