
 %%
            %% Voxel corelation vs Cortex and InnerSkull Minimal Distance
            %%
            iSkull = load(BSTInnerSkullFile);
            [vert_inds,distances,min_distances] = get_points_within_limit(head.Vertices,outer.Vertices,0.003);
            save(fullfile(subject_report_path,'cortex_vs_inner_dist.fig'),'min_distances','vert_inds');
            
            hFig30 = figure;
            plot(min_distances,corelv,'.');
            xlabel('Cortex-InnerSkull distance');
            ylabel('Correlation');
            title('Voxel corelation vs Cortex and InnerSkull Minimal Distance');
            hold on;
            corela_low = corelv(vert_inds);
            low_distance = min_distances(vert_inds);
            plot(low_distance,corela_low,'o');
            bst_report('Snapshot',hFig30,[],'Voxel correlation and Cortex-InnarSkull distance', [200,200,750,475]);
            saveas( hFig30,fullfile(subject_report_path,'Correlation Voxel correlaton-vert_distance.fig'));
            % Closing figure
            close(hFig30);
            
            %%
            %% Finding points of low corelation
            %%           
            low_cor_inds = find(corelv < .3);            
            save(fullfile(subject_report_path,'voxel_cor.fig'),'corelv','low_cor_inds');
            
            BSTCortexFile = bst_fullfile(ProtocolInfo.SUBJECTS, headmodel_options.CortexFile);            
            hFig_low_cor = view_surface(BSTCortexFile, [], [], 'NewFigure');         
            hFig_low_cor = view_surface(BSTCortexFile, [], [], hFig_low_cor);           
            % Delete scouts
            delete(findobj(hFig_low_cor, 'Tag', 'ScoutLabel'));
            delete(findobj(hFig_low_cor, 'Tag', 'ScoutMarker'));
            delete(findobj(hFig_low_cor, 'Tag', 'ScoutPatch'));
            delete(findobj(hFig_low_cor, 'Tag', 'ScoutContour'));           
            
            line(cortex.Vertices(vert_inds,1), cortex.Vertices(vert_inds,2), cortex.Vertices(vert_inds,3), 'LineStyle', 'none', 'Marker', 'o',  'MarkerFaceColor', [1 0 0], 'MarkerSize', 6);
            figure_3d('SetStandardView', hFig_low_cor, 'top');
            bst_report('Snapshot',hFig_low_cor,[],'Low correlation Voxel', [200,200,750,475]);
            saveas( hFig_low_cor,fullfile(subject_report_path,'Low correlation Voxel.fig'));
            close(hFig_low_cor);
            
            figure_cor = figure;
            colormap(gca,cmap);
            
            patch('Faces',cortex.Faces,'Vertices',cortex.Vertices,'FaceVertexCData',corelv,'FaceColor','interp','EdgeColor','none','FaceAlpha',.99);
            saveas( figure_cor,fullfile(subject_report_path,'Low correlation Voxel interpolation.fig'));
            close(figure_cor);
            
            
            
            