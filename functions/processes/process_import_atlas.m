function atlas_error = process_import_atlas(properties, subID, CSurfaces)

%%
%% Getting report path and params
%%
report_path     = get_report_path(properties, subID);
atlas_error     = [];
anatomy_type    = properties.anatomy_params.anatomy_type.type_list{properties.anatomy_params.anatomy_type.type};
if(isequal(anatomy_type.id,1)); type = 'default';end
if(isequal(anatomy_type.id,2)); type = 'template';end
if(isequal(anatomy_type.id,3)); type = 'individual';end
mq_control      = properties.general_params.bst_config.after_MaQC.run;
ProtocolInfo    = bst_get('ProtocolInfo');
[sSubject, ~]   = bst_get('Subject', subID);
Surfaces        = sSubject.Surface;
for i=1:length(CSurfaces)
    CSurface = CSurfaces(i);
    if(~isempty(CSurface.name) && isequal(CSurface.type,'cortex'))
        BSTCortexFile   = bst_fullfile(ProtocolInfo.SUBJECTS, Surfaces(CSurface.iSurface).FileName);
        Cortex          = load(BSTCortexFile);
        if(~mq_control)
            switch type
                case 'default'
                    if(isfield(anatomy_type,'default_atlas') && ~isempty(anatomy_type.default_atlas))
                        atlas_name  = anatomy_type.default_atlas;
                        iAtlas      = find(strcmp({Cortex.Atlas.Name},atlas_name),1);
                        if(isempty(iAtlas))
                            iAtlas  = 1;
                            for j=2:length(Cortex.Atlas)
                                if(~isempty(Cortex.Atlas(j).Scouts) && length(Cortex.Atlas(j).Scouts)>length(Cortex.Atlas(iAtlas).Scouts))
                                    iAtlas = j;
                                end
                            end
                        end
                        Cortex.iAtlas = iAtlas;
                        bst_save(BSTCortexFile, Cortex, 'v7', 1);
                        bst_memory('UnloadSurface', BSTCortexFile);
                    end
                otherwise
                    Atlas_seg_location  = properties.anatomy_params.surfaces{end};
                    % Add this sentence in import_label function in line 80
                    %  case '.gz',     FileFormat = 'MRI-MASK-MNI';
                    % modify import_label function in line 341
                    %  sMriMask = in_mri(LabelFiles{iFile}, 'ALL-MNI', 0, 0);
                    script_import_label(BSTCortexFile,Atlas_seg_location,0);
            end
        end
        %%
        %% Quality control
        %%
        panel_scout('SetScoutsOptions', 0, 0, 1, 'all', 1, 0, 0, 0);
        panel_scout('UpdateScoutsDisplay', 'all');
        panel_scout('SetScoutContourVisible', 0, 0);
        panel_scout('SetScoutTransparency', 0);
        panel_scout('SetScoutTextVisible', 0, 1);
        hFigSurf    = view_surface(BSTCortexFile,  0, [.6,.6,.6], 'NewFigure', 1);
        % Deleting the Atlas Labels and Countour from Cortex
        delete(findobj(hFigSurf, 'Tag', 'ScoutLabel'));
        delete(findobj(hFigSurf, 'Tag', 'ScoutMarker'));
        delete(findobj(hFigSurf, 'Tag', 'ScoutContour'));
        figures     = {hFigSurf, hFigSurf, hFigSurf, hFigSurf};
        fig_out     = merge_figures(Cortex.Comment, strrep(Cortex.Comment,'_','-'), figures,...
            'rows', 2, 'cols', 2,'axis_on',{'off','off','off','off'},...
            'colorbars',{'off','off','off','off'},...
            'view_orient',{[0,90],[1,270],[1,180],[0,360]});
        bst_report('Snapshot',fig_out,[],strcat(Cortex.Comment,' atlas seg'), [200,200,900,700]);
        try
            savefig(hFigSurf,fullfile(report_path,strcat(Cortex.Comment,' atlas seg.fig')));
        catch
        end
        % Closing figure
        close(fig_out,hFigSurf);
    end
end
end

