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
fig = figure('Name', fig_title, 'NumberTitle', 'off', 'units','normalized','outerposition',[0 0 1 1],'Color','w');
hold on;

% PLotting sources
scatter3(XYZ(:,1),XYZ(:,2),XYZ(:,3),Kqme/max(Kqme)*2*mS,'k','filled');

% Plotting head
patch('Vertices',head.Vertices,'Faces',head.Faces,'EdgeColor','none','FaceAlpha',.2,'FaceColor',[0.7,0.7,0.7]);

% Plotting field vector
quiver3(XYZ(:,1),XYZ(:,2),XYZ(:,3),Kq(:,1,elecIndex),Kq(:,2,elecIndex),Kq(:,3,elecIndex),'LineWidth',2,'Color','b','AutoScaleFactor',3);

% PLotting electrodes
% ElectrodeGrid = CreateGeometry3DElectrode(channels,'EEG',head, 'nVert', 34);
% patch('Faces',               ElectrodeGrid.Faces, ...
%     'Vertices',            ElectrodeGrid.Vertices,...
%     'FaceVertexCData',     ElectrodeGrid.FaceVertexCData, ...
%     'FaceVertexAlphaData', ElectrodeGrid.FaceVertexAlphaData, ...
%     'FaceColor',           'flat', ...
%     'FaceAlpha',           'flat', ...
%     'AlphaDataMapping',    'none', ...
%     ElectrodeGrid.Options{:});

% Marking channel
ElectrodeGrid = CreateGeometry3DElectrode(channels(elecIndex,:),'EEG',head, 'ctColor', [1 0 0], 'nVert', 34);
patch('Faces',               ElectrodeGrid.Faces, ...
    'Vertices',            ElectrodeGrid.Vertices,...
    'FaceVertexCData',     ElectrodeGrid.FaceVertexCData, ...
    'FaceVertexAlphaData', ElectrodeGrid.FaceVertexAlphaData, ...
    'FaceColor',           'flat', ...
    'FaceAlpha',           'flat', ...
    'AlphaDataMapping',    'none', ...
    ElectrodeGrid.Options{:});


axis(fig.CurrentAxes,'off');
axis(fig.CurrentAxes,'equal');
axis(fig.CurrentAxes,'tight');

title(fig_title);
rotate3d on;

end

