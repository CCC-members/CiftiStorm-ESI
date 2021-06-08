function qc_headmodel(headmodel_options,modality,subject_report_path)
%QC_HEADMODEL Summary of this function goes here
%   Detailed explanation goes here
%%
%% Quality control
%%
ProtocolInfo = bst_get('ProtocolInfo');
[sStudy iStudy] = bst_get('Study');
if(isempty(iStudy))
    [sStudy, iStudy]  = bst_get('StudyWithSubject', sSubject.FileName, 'intra_subject');
end
BSTCortexFile = bst_fullfile(ProtocolInfo.SUBJECTS, headmodel_options.CortexFile);
cortex = load(BSTCortexFile);

BSTScalpFile = bst_fullfile(ProtocolInfo.SUBJECTS, headmodel_options.HeadFile);
head = load(BSTScalpFile);

% Uploading Gain matrix
BSTHeadModelFile = bst_fullfile(headmodel_options.HeadModelFile);
BSTHeadModel = load(BSTHeadModelFile);
Ke = BSTHeadModel.Gain;
if(isequal(modality,'EEG'))
    % Uploading Channels Loc
    Channels = [headmodel_options.Channel.Loc];
    Channels = Channels';
    ChannOri = [headmodel_options.Channel.Orient];
    
    %%
    %% Checking LF correlation
    %%
    [Ne,Nv]=size(Ke);
    Nv= Nv/3;
    VoxelCoord=cortex.Vertices;
    VertNorms=cortex.VertNormals;    
    
    %computing homogeneous lead field
    [Kn, Khom, KhomN]   = computeNunezLF(Ke, VoxelCoord, VertNorms, Channels, ChannOri, modality);
    
    %%
    %% Ploting sensors and sources on the scalp and cortex
    %%
    [hFig25] = view3D_K(Kn,cortex,head,Channels,17);
    bst_report('Snapshot',hFig25,[],'Field top view', [200,200,750,475]);
    view(0,360)
    savefig( hFig25,fullfile(subject_report_path,'Field view.fig'));
    
    bst_report('Snapshot',hFig25,[],'Field right view', [200,200,750,475]);
    view(1,180)
    bst_report('Snapshot',hFig25,[],'Field left view', [200,200,750,475]);
    view(90,360)
    bst_report('Snapshot',hFig25,[],'Field front view', [200,200,750,475]);
    view(270,360)
    bst_report('Snapshot',hFig25,[],'Field back view', [200,200,750,475]);
    % Closing figure
    close(hFig25);
    
    
    [hFig26]    = view3D_K(Khom,cortex,head,Channels,17);
    bst_report('Snapshot',hFig26,[],'Homogenous field top view', [200,200,750,475]);
    view(0,360)
    savefig( hFig26,fullfile(subject_report_path,'Homogenous field view.fig'));
    
    bst_report('Snapshot',hFig26,[],'Homogenous field right view', [200,200,750,475]);
    view(1,180)
    bst_report('Snapshot',hFig26,[],'Homogenous field left view', [200,200,750,475]);
    view(90,360)
    bst_report('Snapshot',hFig26,[],'Homogenous field front view', [200,200,750,475]);
    view(270,360)
    bst_report('Snapshot',hFig26,[],'Homogenous field back view', [200,200,750,475]);
    % Closing figure
    close(hFig26);
    
    VertNorms   = reshape(VertNorms,[1,Nv,3]);
    VertNorms   = repmat(VertNorms,[Ne,1,1]);
    Kn          = sum(Kn.*VertNorms,3);
    Khom        = sum(Khom.*VertNorms,3);
    KhomN        = sum(KhomN.*VertNorms,3);
    
    %Homogenous Lead Field vs. Tester Lead Field Plot
    hFig27 = figure;
    scatter(Khom(:),Kn(:));
    title('Homogenous Lead Field vs. Tester Lead Field');
    xlabel('Homogenous Lead Field');
    ylabel('Tester Lead Field');
    bst_report('Snapshot',hFig27,[],'Homogenous Lead Field vs. Tester Lead Field', [200,200,750,475]);
    savefig( hFig27,fullfile(subject_report_path,'Homogenous Lead Field vs. Tester Lead Field.fig'));
    % Closing figure
    close(hFig27);
    
    %computing channel-wise correlation
    for k=1:size(Kn,1)
        corelch(k,1)=corr(Khom(k,:).',Kn(k,:).');
    end
    %plotting channel wise correlation
    hFig28 = figure;
    plot([1:size(Kn,1)],corelch,[1:size(Kn,1)],0.7,'r-');
    xlabel('Channels');
    ylabel('Correlation');
    title('Correlation between both lead fields channel-wise');
    bst_report('Snapshot',hFig28,[],'Correlation between both lead fields channel-wise', [200,200,750,475]);
    savefig( hFig28,fullfile(subject_report_path,'Correlation channel-wise.fig'));
    % Closing figure
    close(hFig28);
    
    zKhom = zscore(Khom')';
    zK = zscore(Kn')';
    %computing voxel-wise correlation
    for k=1:Nv
        corelv(k,1)=corr(zKhom(:,k),zK(:,k));
    end
    corelv(isnan(corelv))=0;
    corr2d = corr2(Khom, Kn);
    %plotting voxel wise correlation
    hFig29 = figure;
    plot([1:Nv],corelv);
    title('Correlation both lead fields Voxel wise');
    % Including to report
    bst_report('Snapshot',hFig29,[],'Correlation both lead fields Voxel wise', [200,200,750,475]);
    savefig( hFig29,fullfile(subject_report_path,'Correlation Voxel wise.fig'));
    close(hFig29);
    
    %%
    %% Finding points of low corelation
    %%
    low_cor_inds = find(corelv < .3);
    BSTCortexFile = bst_fullfile(ProtocolInfo.SUBJECTS, headmodel_options.CortexFile);
    hFig_low_cor = view_surface(BSTCortexFile, [], [], 'NewFigure');
    hFig_low_cor = view_surface(BSTCortexFile, [], [], hFig_low_cor);
    % Delete scouts
    delete(findobj(hFig_low_cor, 'Tag', 'ScoutLabel'));
    delete(findobj(hFig_low_cor, 'Tag', 'ScoutMarker'));
    delete(findobj(hFig_low_cor, 'Tag', 'ScoutPatch'));
    delete(findobj(hFig_low_cor, 'Tag', 'ScoutContour'));
    
    line(cortex.Vertices(low_cor_inds,1), cortex.Vertices(low_cor_inds,2), cortex.Vertices(low_cor_inds,3), 'LineStyle', 'none', 'Marker', 'o',  'MarkerFaceColor', [1 0 0], 'MarkerSize', 6);
    figure_3d('SetStandardView', hFig_low_cor, 'bottom');
    bst_report('Snapshot',hFig_low_cor,[],'Low correlation Voxel', [200,200,750,475]);
    savefig( hFig_low_cor,fullfile(subject_report_path,'Low correlation Voxel.fig'));
    close(hFig_low_cor);
    
    figure_cor = figure;
    %colormap(gca,cmap);
    patch('Faces',cortex.Faces,'Vertices',cortex.Vertices,'FaceVertexCData',corelv,'FaceColor','interp','EdgeColor','none','FaceAlpha',.99);
    view(90,270);
    axis off;
    colorbar;
    title('Distance correlation map');
    bst_report('Snapshot',figure_cor,[],'Low correlation map', [200,200,750,475]);
    savefig( figure_cor,fullfile(subject_report_path,'Low correlation Voxel interpolation.fig'));
    close(figure_cor);
else
    %%
    %% Uploading Channels Loc
    %%
    BSTChannelsFile = bst_fullfile(ProtocolInfo.STUDIES,sStudy.Channel.FileName);
    BSTChannels = load(BSTChannelsFile);
    
    [BSTChannels,Ke] = remove_channels_and_leadfield_from_layout([],BSTChannels,Ke,true);
    
    Channels = [];
    ChannelsOrient = [];
    for i = 1: length(BSTChannels.Channel)
        Loc = BSTChannels.Channel(i).Loc;
        center = mean(Loc,2);
        Channels = [Channels; center(1),center(2),center(3) ];
        Orient = BSTChannels.Channel(i).Orient;
        center = mean(Orient,2);
        ChannelsOrient = [ChannelsOrient; center(1),center(2),center(3) ];
    end
    %%
    %% Checking LF correlation
    %%
    [Ne,Nv]=size(Ke);
    Nv= Nv/3;
    VoxelCoord=cortex.Vertices;
    VertNorms=cortex.VertNormals;
    
    %computing homogeneous lead field
    [Kn, Khom, KhomN]   = computeNunezLF(Ke, VoxelCoord, VertNorms, Channels, ChannelsOrient, modality);
end


end

