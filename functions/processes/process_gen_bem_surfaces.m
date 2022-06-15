function [errMessage] = process_gen_bem_surfaces(properties, subID)

errMessage = [];

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
sSubject       = bst_get('Subject', subID);
CortexFile     = sSubject.Surface(sSubject.iCortex).FileName;
InnerSkullFile = sSubject.Surface(sSubject.iInnerSkull).FileName;

%%
%% Forcing dipoles inside innerskull
%%
%             [iIS, BstTessISFile, nVertOrigR] = import_surfaces(iSubject, innerskull_file, 'MRI-MASK-MNI', 1);
%             BstTessISFile = BstTessISFile{1};
script_tess_force_envelope(CortexFile, InnerSkullFile);

%%
%% Get subject definition and subject files
%%
sSubject       = bst_get('Subject', subID);
MriFile        = sSubject.Anatomy(sSubject.iAnatomy).FileName;
CortexFile     = sSubject.Surface(sSubject.iCortex).FileName;
InnerSkullFile = sSubject.Surface(sSubject.iInnerSkull).FileName;
OuterSkullFile = sSubject.Surface(sSubject.iOuterSkull).FileName;
ScalpFile      = sSubject.Surface(sSubject.iScalp).FileName;

%%
%% Getting report path
%%
[subject_report_path] = get_report_path(properties, subID);
%%
%% Quality control
%%
hFigSurf11 = script_view_surface(CortexFile, [], [], [],'top');
hFigSurf11 = script_view_surface(InnerSkullFile, [], [], hFigSurf11);
hFigSurf11 = script_view_surface(OuterSkullFile, [], [], hFigSurf11);
hFigSurf11 = script_view_surface(ScalpFile, [], [], hFigSurf11);
bst_report('Snapshot',hFigSurf11,[],'BEM surfaces registration top view', [200,200,750,475]);
savefig( hFigSurf11,fullfile(subject_report_path,'BEM surfaces registration view.fig'));
% Left
view(1,180)
bst_report('Snapshot',hFigSurf11,[],'BEM surfaces registration left view', [200,200,750,475]);
% Right
view(0,360)
bst_report('Snapshot',hFigSurf11,[],'BEM surfaces registration right view', [200,200,750,475]);
% Front
view(90,360)
bst_report('Snapshot',hFigSurf11,[],'BEM surfaces registration front view', [200,200,750,475]);
% Back
view(270,360)
bst_report('Snapshot',hFigSurf11,[],'BEM surfaces registration back view', [200,200,750,475]);
% Closing figure
close(hFigSurf11);

end

