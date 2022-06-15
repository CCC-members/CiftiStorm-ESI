function atlas_error = process_import_atlas(properties, type, subID)

atlas_error             = [];
anatomy_type            = properties.anatomy_params.anatomy_type.type_list{properties.anatomy_params.anatomy_type.type};
ProtocolInfo            = bst_get('ProtocolInfo');
[sSubject, ~]           = bst_get('Subject', subID);
CortexFile              = sSubject.Surface(sSubject.iCortex).FileName;
switch type
    case 'default'         
        BSTCortexFile   = bst_fullfile(ProtocolInfo.SUBJECTS, CortexFile);
        cortex          = load(BSTCortexFile);
        if(isfield(anatomy_type,'default_atlas') && ~isempty(anatomy_type.default_atlas))
            atlas_name  = anatomy_type.default_atlas;
            iAtlas      = find(strcmp({cortex.Atlas.Name},atlas_name),1);
            if(isempty(iAtlas))
                iAtlas  = 1;
                for i=2:length(cortex.Atlas)
                    if(~isempty(cortex.Atlas(i).Scouts) && length(cortex.Atlas(i).Scouts)>length(cortex.Atlas(iAtlas).Scouts))
                        iAtlas = i;
                    end
                end
            end
            panel_scout('SetAtlas', CortexFile, 1, cortex.Atlas(iAtlas));
        end
    case 'template'
        temp_sub_ID         = anatomy_type.template_name;
        base_path           =  strrep(anatomy_type.base_path,'SubID','');        
        base_path           = strrep(base_path, subID, '');
        filepath            = strrep(anatomy_type.Atlas_seg_location,'SubID',subID);
        Atlas_seg_location  = fullfile(base_path, subID, filepath);
        import_label(sSubject.Surface(sSubject.iCortex).FileName,Atlas_seg_location,0);
    case 'individual'
        base_path           =  strrep(anatomy_type.base_path,'SubID',subID);
        filepath            = strrep(anatomy_type.Atlas_seg_location,'SubID',subID);
        Atlas_seg_location  = fullfile(base_path,filepath);
        % Add this sentence in import_label function in line 80
        %  case '.gz',     FileFormat = 'MRI-MASK-MNI';
        % modify import_label function in line 341 
        %  sMriMask = in_mri(LabelFiles{iFile}, 'ALL-MNI', 0, 0);         
        import_label(sSubject.Surface(sSubject.iCortex).FileName,Atlas_seg_location,0);
end

%%
%% Getting report path
%%
[subject_report_path] = get_report_path(properties, subID);

%%
%% Quality control
%%
panel_scout('SetScoutsOptions', 0, 0, 1, 'all', 1, 0, 0, 0);
panel_scout('UpdateScoutsDisplay', 'all');
panel_scout('SetScoutContourVisible', 0, 0);
panel_scout('SetScoutTransparency', 0);
panel_scout('SetScoutTextVisible', 0, 1);

hFigSurf24 = view_surface(CortexFile);
% Deleting the Atlas Labels and Countour from Cortex

delete(findobj(hFigSurf24, 'Tag', 'ScoutLabel'));
delete(findobj(hFigSurf24, 'Tag', 'ScoutMarker'));
delete(findobj(hFigSurf24, 'Tag', 'ScoutContour'));

bst_report('Snapshot',hFigSurf24,[],'surface view', [200,200,750,475]);
savefig( hFigSurf24,fullfile(subject_report_path,'Surface view.fig'));
%Left
view(1,180);
bst_report('Snapshot',hFigSurf24,[],'Surface left view', [200,200,750,475]);
% Bottom
view(90,270);
bst_report('Snapshot',hFigSurf24,[],'Surface bottom view', [200,200,750,475]);
% Rigth
view(0,360);
bst_report('Snapshot',hFigSurf24,[],'Surface right view', [200,200,750,475]);
% Closing figure
close(hFigSurf24);

end

