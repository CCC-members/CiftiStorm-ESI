function set_Surfaces_Comment(properties,iSubject)
%UNTITLED Summary of this function goes here

layer_desc          = properties.anatomy_params.common_params.layer_desc.desc;

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
if(isequal(lower(layer_desc),'white') || isequal(lower(layer_desc),'midthickness') || isequal(lower(layer_desc),'pial'))
    [sSubject,~]        = bst_get('Subject', iSubject);
    Surfaces            = sSubject.Surface;
    for i=1:length(Surfaces)
        surface = Surfaces(i);
        if(isequal(surface.SurfaceType,'Cortex'))
            [~,name,~]  = fileparts(surface.Comment);
            comment     = split(name,'_');
            desc        = comment{end-1};
            if(~isequal(lower(layer_desc),desc))
                file_delete(file_fullpath({surface.FileName}), 1);
            end
        end
    end
    %% Reload subject
    db_reload_subjects(iSubject);
end

end

