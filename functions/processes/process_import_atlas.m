function atlas_error = process_import_atlas(properties, type, subID, CSurfaces)

atlas_error             = [];
anatomy_type            = properties.anatomy_params.anatomy_type.type_list{properties.anatomy_params.anatomy_type.type};
ProtocolInfo            = bst_get('ProtocolInfo');
[sSubject, iSubject]    = bst_get('Subject', subID);
Surfaces                = sSubject.Surface;
 for i=1:length(CSurfaces)
     CSurface = CSurfaces(i);
     if(~isempty(CSurface.name))
         switch type
             case 'default'
                 CortexFile      = Surfaces(CSurface.iSurface).FileName;
                 BSTCortexFile   = bst_fullfile(ProtocolInfo.SUBJECTS, CortexFile);
                 cortex          = load(BSTCortexFile);
                 if(isfield(anatomy_type,'default_atlas') && ~isempty(anatomy_type.default_atlas))
                     atlas_name  = anatomy_type.default_atlas;
                     iAtlas      = find(strcmp({cortex.Atlas.Name},atlas_name),1);
                     if(isempty(iAtlas))
                         iAtlas  = 1;
                         for j=2:length(cortex.Atlas)
                             if(~isempty(cortex.Atlas(j).Scouts) && length(cortex.Atlas(j).Scouts)>length(cortex.Atlas(iAtlas).Scouts))
                                 iAtlas = j;
                             end
                         end
                     end
                     cortex.iAtlas = iAtlas;
                     bst_save(BSTCortexFile, cortex, 'v7', 1); 
                     bst_memory('UnloadSurface', BSTCortexFile);
                 end
             case 'template'
                 temp_sub_ID         = anatomy_type.template_name;
                 base_path           =  strrep(anatomy_type.base_path,'SubID','');
                 base_path           = strrep(base_path, subID, '');
                 filepath            = strrep(anatomy_type.Atlas_seg_location,'SubID',subID);
                 Atlas_seg_location  = fullfile(base_path, subID, filepath);
                 script_import_label(sSubject.Surface(sSubject.iCortex).FileName,Atlas_seg_location,0);
             case 'individual'                 
                 CortexFile          = Surfaces(CSurface.iSurface).FileName;
                 BSTCortexFile       = bst_fullfile(ProtocolInfo.SUBJECTS, CortexFile);
                 anat_path           = fullfile(anatomy_type.base_path, subID, strrep(anatomy_type.HCP_anat_path, 'SubID', subID), 'T1w');
                 file_name           = anatomy_type.Atlas_file_name;
                 Atlas_seg_location  = fullfile(anat_path,file_name);
                 % Add this sentence in import_label function in line 80
                 %  case '.gz',     FileFormat = 'MRI-MASK-MNI';
                 % modify import_label function in line 341
                 %  sMriMask = in_mri(LabelFiles{iFile}, 'ALL-MNI', 0, 0);
                 script_import_label(CortexFile,Atlas_seg_location,0);
         end
     end
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
[sSubject, iSubject]    = bst_get('Subject', subID);
Surfaces    = sSubject.Surface;
for i=1:length(CSurfaces)
    CSurface        = CSurfaces(i);
    if(~isempty(CSurface.name))
        Cortex      = Surfaces(CSurface.iSurface);
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
        savefig(hFigSurf,fullfile(subject_report_path,strcat(Cortex.Comment,' atlas seg.fig')));
        % Closing figure
        close(fig_out,hFigSurf);
    end
end
end

