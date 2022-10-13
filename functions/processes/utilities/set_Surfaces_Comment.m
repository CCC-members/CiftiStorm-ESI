function set_Surfaces_Comment(properties,iSubject)
%UNTITLED Summary of this function goes here

anatomy_type        = properties.anatomy_params.anatomy_type.type_list{properties.anatomy_params.anatomy_type.type};
layer_desc          = anatomy_type.layer_desc.desc;

[sSubject,~]        = bst_get('Subject', iSubject);
Surfaces            = sSubject.Surface;
for i=1:length(Surfaces)
    surface         = Surfaces(i);
    if(isequal(surface.SurfaceType,'Cortex'))
        [~,name,~]  = fileparts(surface.FileName);
        comment     = split(name,'_');
        if(isequal(comment{end},'high'))
            Cortex  = load(file_fullpath(surface.FileName));
            desc    = comment{end-1};
            switch desc
                case 'pial'
                    Cortex.Comment = 'Cortex_pial_high';
                case 'mid'
                    Cortex.Comment = 'Cortex_midthickness_high';
                case 'white'
                    Cortex.Comment = 'Cortex_white_high';
            end
            bst_save(file_fullpath(surface.FileName), Cortex, 'v7', 1);
            bst_memory('UnloadSurface', file_fullpath(surface.FileName));
        end
    end
end
%% Reload subject
db_reload_subjects(iSubject);

%%
%% Removing uneeded surfaces in case single surface processing
%%
if(isequal(layer_desc,'white') || isequal(layer_desc,'midthickness') || isequal(layer_desc,'pial'))
    [sSubject,~]        = bst_get('Subject', iSubject);
    Surfaces            = sSubject.Surface;
    for i=1:length(Surfaces)
        surface = Surfaces(i);
        if(isequal(surface.SurfaceType,'Cortex'))
            [~,name,~]  = fileparts(surface.Comment);
            comment     = split(name,'_');
            desc        = comment{end-1};
            if(~isequal(layer_desc,desc))
                file_delete(file_fullpath({surface.FileName}), 1);
            end
        end
    end
    %% Reload subject
    db_reload_subjects(iSubject);
end

end

