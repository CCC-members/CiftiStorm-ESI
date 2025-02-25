function [CiftiStorm, AQCI] = process_AQC(CiftiStorm, headmodel_options, properties, subID)
%QC_HEADMODEL Summary of this function goes here
%   Detailed explanation goes here

%%
%% Getting report path
%%
modality        = properties.general_params.modality;
report_path     = get_report_path(properties, subID);

%%
%% Quality control
%%
ProtocolInfo    = bst_get('ProtocolInfo');
sSubject        = bst_get('Subject', subID);
if(isequal(lower(properties.channel_params.channel_type.id),'raw'))
    sStudy      = bst_get('StudyWithSubject', sSubject.FileName);else
    sStudy      = bst_get('StudyWithSubject', sSubject.FileName, 'intra_subject');
end
BSTCortexFile   = bst_fullfile(ProtocolInfo.SUBJECTS, headmodel_options.CortexFile);
cortex          = load(BSTCortexFile);
desc            = split(cortex.Comment,'_');
desc            = desc{2};
BSTScalpFile    = bst_fullfile(ProtocolInfo.SUBJECTS, headmodel_options.HeadFile);
head            = load(BSTScalpFile);
% Uploading Gain matrix
BSTHeadModelFile= bst_fullfile(headmodel_options.HeadModelFile);
BSTHeadModel    = load(BSTHeadModelFile);
Ke              = BSTHeadModel.Gain;
if(isequal(modality,'EEG'))
    % Uploading Channels Loc
    Channels    = [headmodel_options.Channel.Loc];
    Channels    = Channels';
    ChannOri    = [headmodel_options.Channel.Orient];

    %%
    %% Checking LF correlation
    %%
    [Ne,Nv]     = size(Ke);
    Nv          = Nv/3;
    VoxelCoord  = cortex.Vertices;
    VertNorms   = cortex.VertNormals;
    %computing homogeneous lead field
    [Kn, Khom, KhomN]   = computeNunezLF(Ke, VoxelCoord, VertNorms, Channels, ChannOri, modality);
    %save(fullfile(report_path,'qc_output.mat'),'Ke', 'VoxelCoord', 'VertNorms', 'Channels', 'ChannOri', 'modality', 'Kn', 'Khom');

    %%
    %% Ploting sensors and sources on the scalp and cortex
    %%
    if(getGlobalVerbose())
        fig_title   = strcat('Realistic field view (',desc,')');
        [hFig25]    = view3D_K(fig_title, Kn, cortex, head, Channels,2);
        figures     = {hFig25, hFig25, hFig25, hFig25};
        fig_out     = merge_figures(fig_title, fig_title, figures,...
            'rows', 2, 'cols', 2,'axis_on',{'off','off','off','off'},...
            'colorbars',{'off','off','off','off'},...
            'view_orient',{[0,90],[90,360],[1,180],[0,360]});
        bst_report('Snapshot',fig_out,[],fig_title, [200,200,900,700]);
        try
            savefig( hFig25,fullfile(report_path,strcat(fig_title,'.fig')));
        catch
        end
        % Closing figure
        close(hFig25, fig_out);
    end

    %%
    %% Homogenous field view
    %%
    if(getGlobalVerbose())
        fig_title   = strcat('Homogenous field view (',desc,')');
        [hFig26]    = view3D_K(fig_title, Khom,cortex,head,Channels,2);
        figures     = {hFig26, hFig26, hFig26, hFig26};
        fig_out     = merge_figures(fig_title, fig_title, figures,...
            'rows', 2, 'cols', 2,'axis_on',{'off','off','off','off'},...
            'colorbars',{'off','off','off','off'},...
            'view_orient',{[0,90],[90,360],[1,180],[0,360]});
        bst_report('Snapshot',fig_out,[],fig_title, [200,200,900,700]);
        try
            savefig( hFig26,fullfile(report_path,strcat(fig_title,'.fig')));
        catch
        end
        % Closing figure
        close(hFig26, fig_out);
    end

    VertNorms   = reshape(VertNorms,[1,Nv,3]);
    VertNorms   = repmat(VertNorms,[Ne,1,1]);
    Kn          = sum(Kn.*VertNorms,3);
    Khom        = sum(Khom.*VertNorms,3);
    KhomN       = sum(KhomN.*VertNorms,3);
    %save(fullfile(report_path,'qc_Khom_vs_Kn.mat'),'VertNorms', 'Kn', 'Khom');

    %%
    %% Homogenous Lead Field vs. Tester Lead Field Plot
    %%
    if(getGlobalVerbose())
        hFig27      = figure;
        scatter(Khom(:),Kn(:));
        title(strcat('Homogenous Lead Field vs. Tester Lead Field (',desc,')'));
        xlabel('Homogenous Lead Field');
        ylabel('Tester Lead Field');
        bst_report('Snapshot',hFig27,[],strcat('Homogenous Lead Field vs. Tester Lead Field (',desc,')'), [200,200,900,700]);
        try
            savefig( hFig27,fullfile(report_path,strcat('Homogenous Lead Field vs. Tester Lead Field (',desc,').fig')));
        catch
        end
        % Closing figure
        close(hFig27);
    end

    % (𝜗𝑐ℎ𝑎𝑛𝑛𝑒𝑙, 𝜗𝑠𝑜𝑢𝑟𝑐𝑒) = (0.80, 0.79) Artifactual greater than −0.9755
    distE=sum((Khom-Kn).^2,2).^0.5;
    AQCI.Channels.distE = distE;
    distV=sum((Khom-Kn).^2,1).^0.5;
    AQCI.Voxels.distV = distV;

    %%
    %% Computing channel-wise correlation
    %%
    for k=1:size(Kn,1)
        corelch(k,1)    = corr(Khom(k,:).',Kn(k,:).');
    end
    AQCI.Channels.corelch = corelch;
    if(getGlobalVerbose())        
        save(fullfile(report_path,'qc_corelch.mat'),'corelch');
        %plotting channel wise correlation
        hFig28              = figure;
        plot([1:size(Kn,1)],corelch,[1:size(Kn,1)],0.7,'r-');
        xlabel('Channels');
        ylabel('Correlation');
        title(strcat('Correlation between both lead fields channel-wise (',desc,')'));
        bst_report('Snapshot',hFig28,[],strcat('Correlation between both lead fields channel-wise (',desc,')'), [200,200,900,700]);
        try
            savefig( hFig28,fullfile(report_path,strcat('Correlation channel-wise(',desc,').fig')));
        catch
        end
        % Closing figure
        close(hFig28);
    end

    %%
    %% Computing voxel-wise correlation
    %%
    zKhom                   = zscore(Khom')';
    zKn                     = zscore(Kn')';
    for k=1:Nv
        corelv(k,1)         = corr(zKhom(:,k),zKn(:,k));
    end
    corelv(isnan(corelv))   = 0;
    AQCI.Voxels.corelv = corelv;
    if(getGlobalVerbose())        
        corr2d                  = corr2(Khom, Kn);
        save(fullfile(report_path,'qc_corelv.mat'),'corelv','zKhom','zKn');
        % plotting voxel wise correlation
        hFig29                  = figure;
        plot([1:Nv],corelv);
        title(strcat('Correlation both lead fields Voxel wise (',desc,')'));
        % Including to report
        bst_report('Snapshot',hFig29,[],strcat('Correlation both lead fields Voxel wise (',desc,')'), [200,200,900,700]);
        try
            savefig( hFig29,fullfile(report_path,strcat('Correlation Voxel wise (',desc,').fig')));
        catch
        end
        close(hFig29);
    end

    %%
    %% Finding points of low correlation
    %%
    if(getGlobalVerbose())
        low_cor_inds            = find(corelv < .3);
        BSTCortexFile           = bst_fullfile(ProtocolInfo.SUBJECTS, headmodel_options.CortexFile);
        hFig_low_cor            = view_surface(BSTCortexFile, [], [], 'NewFigure');
        hFig_low_cor            = view_surface(BSTCortexFile, [], [], hFig_low_cor);
        % Delete scouts
        delete(findobj(hFig_low_cor, 'Tag', 'ScoutLabel'));
        delete(findobj(hFig_low_cor, 'Tag', 'ScoutMarker'));
        delete(findobj(hFig_low_cor, 'Tag', 'ScoutPatch'));
        delete(findobj(hFig_low_cor, 'Tag', 'ScoutContour'));
        line(cortex.Vertices(low_cor_inds,1), cortex.Vertices(low_cor_inds,2), cortex.Vertices(low_cor_inds,3), 'LineStyle', 'none', 'Marker', 'o',  'MarkerFaceColor', [1 0 0], 'MarkerSize', 6);
        figure_3d('SetStandardView', hFig_low_cor, 'bottom');
        fig_text                =  strcat('Low correlation Voxel (',desc,')');
        figures                 = {hFig_low_cor, hFig_low_cor, hFig_low_cor, hFig_low_cor};
        fig_out                 = merge_figures(fig_text, fig_text, figures,...
            'rows', 2, 'cols', 2,'axis_on',{'off','off','off','off'},...
            'colorbars',{'off','off','off','off'},...
            'view_orient',{[0,90],[1,270],[1,180],[0,360]});
        bst_report('Snapshot',fig_out,[],strcat('Low correlation Voxel under 0.3 - (',desc,')'), [200,200,900,700]);
        try
            savefig( hFig_low_cor,fullfile(report_path,strcat('Low correlation Voxel (',desc,').fig')));
        catch
        end
        close(hFig_low_cor, fig_out);
    end
    %%
    %% Distance correlation map
    %%
    if(getGlobalVerbose())
        figure_cor          = figure;
        %colormap(gca,cmap);
        patch('Faces',cortex.Faces,'Vertices',cortex.Vertices,'FaceVertexCData',corelv,'FaceColor','interp','EdgeColor','none','FaceAlpha',.99);
        view(90,270);
        axis off;
        colorbar;
        fig_text            =  strcat('Distance correlation map (',desc,')');
        title(fig_text);
        figures             = {figure_cor, figure_cor, figure_cor, figure_cor};
        fig_out             = merge_figures(fig_text, fig_text, figures,...
            'rows', 2, 'cols', 2,'axis_on',{'off','off','off','off'},...
            'colorbars',{'on','on','on','on'}, 'position', 'relative',...
            'view_orient',{[0,90],[1,270],[1,180],[0,360]});
        bst_report('Snapshot',fig_out,[],strcat('Low correlation map (',desc,')'), [200,200,900,700]);
        try
            savefig( figure_cor,fullfile(report_path,strcat('Low correlation Voxel interpolation (',desc,').fig')));
        catch
        end
        close(figure_cor,fig_out);
    end
else
    %%
    %% Uploading Channels Loc
    %%
    BSTChannelsFile     = bst_fullfile(ProtocolInfo.STUDIES,sStudy.Channel.FileName);
    BSTChannels         = load(BSTChannelsFile);
    Channels            = [];
    ChannelsOrient      = [];
    for i = 1: length(BSTChannels.Channel)
        Loc             = BSTChannels.Channel(i).Loc;
        center          = mean(Loc,2);
        Channels        = [Channels; center(1),center(2),center(3) ];
        Orient          = BSTChannels.Channel(i).Orient;
        center          = mean(Orient,2);
        ChannelsOrient  = [ChannelsOrient; center(1),center(2),center(3) ];
    end

    %%
    %% Checking LF correlation
    %%
    [Ne,Nv]             = size(Ke);
    Nv                  = Nv/3;
    VoxelCoord          = cortex.Vertices;
    VertNorms           = cortex.VertNormals;
    %computing homogeneous lead field
    [Kn,Khom,KhomN]     = computeNunezLF(Ke, VoxelCoord, VertNorms, Channels, ChannelsOrient, modality);

end
end

