function atlas_error = process_import_atlas(properties, type, subID)

atlas_error             = [];
anatomy_type            = properties.anatomy_params.anatomy_type.type_list{properties.anatomy_params.anatomy_type.type};
ProtocolInfo            = bst_get('ProtocolInfo');
[sSubject, ~]           = bst_get('Subject', subID);
switch type
    case 'default' 
        CortexFile      = sSubject.Surface(sSubject.iCortex).FileName;
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
        import_label(sSubject.Surface(sSubject.iCortex).FileName,Atlas_seg_location,0);
end

end

