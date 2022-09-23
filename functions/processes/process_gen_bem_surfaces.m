function [errMessage, CSurfaces] = process_gen_bem_surfaces(properties, subID, CSurfaces)

errMessage = [];
%%
%% Getting report path
%%
[subject_report_path] = get_report_path(properties, subID);

%%
%% Compute BEM Surfaces
%%
if(properties.anatomy_params.surfaces_resolution.gener_BEM_surf)
    sFiles = bst_process('CallProcess', 'process_generate_bem', [], [], ...
        'subjectname', subID, ...
        'nscalp',      3242, ...
        'nouter',      3242, ...
        'ninner',      3242, ...
        'thickness',   4);
end

%%
%% Get subject definition and subject files
%%
sSubject        = bst_get('Subject', subID);
InnerSkullFile  = sSubject.Surface(sSubject.iInnerSkull).FileName;
OuterSkullFile  = sSubject.Surface(sSubject.iOuterSkull).FileName;
ScalpFile       = sSubject.Surface(sSubject.iScalp).FileName;
Surfaces        = sSubject.Surface;
%%
%% Forcing dipoles inside innerskull
%%
for i=1:length(CSurfaces)
    CSurface = CSurfaces(i);
    if(~isempty(CSurface.name))
        CortexFile              = Surfaces(CSurface.iSurface).FileName;
        [~, iSurface]           = script_tess_force_envelope(CortexFile, InnerSkullFile, subject_report_path);
        if(~isempty(iSurface))
            CSurfaces(i).iSurface   = iSurface;
        end
    end
end


%%
%% Quality control
%%
sSubject    = bst_get('Subject', subID);
Surfaces    = sSubject.Surface;
for i=1:length(CSurfaces)
    CSurface = CSurfaces(i);     
    if(~isempty(CSurface.name))
        CortexFile = Surfaces(CSurface.iSurface).FileName;
        if(~exist('hFigSurf11','var'))
            hFigSurf11 = script_view_surface(CortexFile, [], [], [],'top');
        else
            hFigSurf11 = script_view_surface(CortexFile, [], [], hFigSurf11);
        end        
    end
end
hFigSurf11 = script_view_surface(InnerSkullFile, [], [], hFigSurf11);
hFigSurf11 = script_view_surface(OuterSkullFile, [], [], hFigSurf11);
hFigSurf11 = script_view_surface(ScalpFile, [], [], hFigSurf11);

figures     = {hFigSurf11, hFigSurf11, hFigSurf11, hFigSurf11};
fig_out     = merge_figures("BEM surfaces registration", "BEM surfaces registration", figures,...
    'rows', 2, 'cols', 2,'axis_on',{'off','off','off','off'},...
    'colorbars',{'off','off','off','off'},...
    'view_orient',{[0,90],[90,360],[1,180],[0,360]});
bst_report('Snapshot',fig_out,[],strcat('BEM surfaces registration'), [200,200,900,700]);
savefig( hFigSurf11,fullfile(subject_report_path,strcat('BEM surfaces registration.fig')));

% Closing figure
close(fig_out,hFigSurf11);

end

