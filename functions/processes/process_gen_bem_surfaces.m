function [CiftiStorm, CSurfaces] = process_gen_bem_surfaces(CiftiStorm, properties, subID, CSurfaces)

errMessage  = [];
mq_control  = properties.general_params.bst_config.after_MaQC.run;
%%
%% Getting report path
%%
report_path = get_report_path(properties, subID);

%%
%% Compute BEM Surfaces
%%
if(~mq_control)
    bst_process('CallProcess', 'process_generate_bem', [], [], ...
        'subjectname', subID, ...
        'nscalp',      4322, ...%3242
        'nouter',      4322, ...
        'ninner',      4322, ...
        'thickness',   4);
end

%%
%% Include BEM surfaces into CSurfaces
%%
sSubject                = bst_get('Subject', subID);
CSurfaces(8).name       = 'InnerSkull';
CSurfaces(8).comment    = sSubject.Surface(sSubject.iInnerSkull).Comment;
CSurfaces(8).iSurface   = sSubject.iInnerSkull;
CSurfaces(8).iCSurface  = true;
CSurfaces(8).type       = 'innerskull';
CSurfaces(8).filename   = sSubject.Surface(sSubject.iInnerSkull).FileName;

CSurfaces(9).name       = 'OuterSkull';
CSurfaces(9).comment    = sSubject.Surface(sSubject.iOuterSkull).Comment;
CSurfaces(9).iSurface   = sSubject.iOuterSkull;
CSurfaces(9).iCSurface  = true;
CSurfaces(9).type       = 'outerskull';
CSurfaces(9).filename   = sSubject.Surface(sSubject.iOuterSkull).FileName;

CSurfaces(10).name      = 'Scalp';
CSurfaces(10).comment   = sSubject.Surface(sSubject.iScalp).Comment;
CSurfaces(10).iSurface  = sSubject.iScalp;
CSurfaces(10).iCSurface = true;
CSurfaces(10).type      = 'scalp';
CSurfaces(10).filename  = sSubject.Surface(sSubject.iScalp).FileName;

%%
%% Quality control
%%
if(getGlobalVerbose())
    sSubject    = bst_get('Subject', subID);
    Surfaces    = sSubject.Surface;
    CortexFile  = Surfaces(sSubject.iCortex).FileName;
    hFigSurf11  = script_view_surface(CortexFile, [], [], [],'top');

    hFigSurf11  = script_view_surface(CSurfaces(8).filename, [], [], hFigSurf11);
    hFigSurf11  = script_view_surface(CSurfaces(9).filename, [], [], hFigSurf11);
    hFigSurf11  = script_view_surface(CSurfaces(10).filename, [], [], hFigSurf11);
    figures     = {hFigSurf11, hFigSurf11, hFigSurf11, hFigSurf11};
    fig_out     = merge_figures("BEM surfaces registration", "BEM surfaces registration", figures,...
        'rows', 2, 'cols', 2,'axis_on',{'off','off','off','off'},...
        'colorbars',{'off','off','off','off'},...
        'view_orient',{[0,90],[90,360],[1,180],[0,360]});
    bst_report('Snapshot',fig_out,[],strcat('BEM surfaces registration'), [200,200,900,700]);
    try
        savefig( hFigSurf11,fullfile(report_path,strcat('BEM surfaces registration.fig')));
    catch
    end
    % Closing figure
    close(fig_out,hFigSurf11);
end

%%
%% Registering process
%%
if(isempty(errMessage))
    CiftiStorm.Participants(end).Status             = "Processing";
    CiftiStorm.Participants(end).FileInfo           = "";
    CiftiStorm.Participants(end).Process(end+1).Name    = "BEM_surfaces";
    CiftiStorm.Participants(end).Process(end).Status  = "Completed";
    CiftiStorm.Participants(end).Process(end).Error   = errMessage;
else
    CiftiStorm.Participants(end).Status             = "Rejected";
    CiftiStorm.Participants(end).FileInfo           = "";
    CiftiStorm.Participants(end).Process(end+1).Name    = "BEM_surfaces";
    CiftiStorm.Participants(end).Process(end).Status  = "Rejected";
    CiftiStorm.Participants(end).Process(end).Error   = errMessage;
end

end

