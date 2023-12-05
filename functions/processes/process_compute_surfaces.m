function [CiftiStorm, CSurfaces, sub_to_FSAve] = process_compute_surfaces(CiftiStorm, properties, subID, CSurfaces)

errMessage = [];

%%
%% Getting params
%%
ProtocolInfo    = bst_get('ProtocolInfo');
anatomy_type    = properties.anatomy_params.anatomy_type;
layer_desc      = properties.anatomy_params.common_params.layer_desc.desc;
mq_control      = properties.general_params.bst_config.after_MaQC.run;
nvertices     = properties.anatomy_params.common_params.surfaces_resolution.nvertices;

%%
%% Getting report path
%%
report_path = get_report_path(properties, subID);

%%
%% Compute surfaces like BigBrain
%%
if(isequal(lower(layer_desc),'bigbrain'))
    disp("-->> Computing Surfaces like BigBrain reference");
    CSurfaces = compute_BigBrain_surfaces(subID, CSurfaces);
end

%%
%% Downsampling Surfaces
%%
% [NewTessFile, iSurface]             = tess_force_envelope_batch(CSurfaces(7).filename, CSurfaces(1).filename);
% [NewTessFile, iSurface]             = tess_force_envelope_batch(CSurfaces(4).filename, CSurfaces(1).filename);
% [NewTessFile, iSurface]             = tess_force_envelope_batch(CSurfaces(7).filename, CSurfaces(4).filename);

[sSubject, iSubject]        = bst_get('Subject', subID);
for i=1:length(CSurfaces)
    CSurface = CSurfaces(i);
    if(~isempty(CSurface.name) && isequal(CSurface.type,'cortex'))
        comment                 = split(CSurface.comment,'_');
        [NewFile,iSurface,I,J]  = tess_downsize(CSurface.filename, nvertices, 'reducepatch');
        CortexMat.Comment       = strcat('Cortex_',comment{2},'_low');
        if(isequal(layer_desc,lower('bigbrain')) || isequal(layer_desc,lower('fs_lr')))
            if(isequal(comment{2},'pial'))
                SurfaceDir          = bst_fullfile(ProtocolInfo.SUBJECTS, NewFile);
                Spial               = load(SurfaceDir);
                Vcommon             = I;
                Fcommon             = Spial.Faces;
            else
                SurfaceDir          = bst_fullfile(ProtocolInfo.SUBJECTS, CSurface.filename);
                SurfaceHigh         = load(SurfaceDir);
                CortexMat.Faces     = Fcommon;
                CortexMat.Vertices  = SurfaceHigh.Vertices(Vcommon,:);
            end   
        end
        bst_save(file_fullpath(NewFile), CortexMat, 'v7', 1);
        bst_memory('UnloadSurface', file_fullpath(NewFile));
        in_tess_bst( NewFile, 1);
        CSurfaces(i).iSurface   = iSurface;
        CSurfaces(i).filename   = NewFile;
        CSurfaces(i).comment    = CortexMat.Comment;
        CSurfaces(i).filename   = NewFile;
    end
end

%% Reload subject
db_reload_subjects(iSubject);

%%
%% Get CSurfaces from Subject
%%
CSurfaces                       = get_CSurfaces_from_sSubject(properties,iSubject);

% %%
% %% Setting the default cortex
% %%
[~, iSubject]   = bst_get('Subject', subID);
for i=1:length(CSurfaces)
    if(~isempty(CSurfaces(i).iCSurface) && CSurfaces(i).iCSurface)
        db_surface_default(iSubject, 'Cortex', CSurfaces(i).iSurface);
        break;
    end
end

%%
%% Correcting overlapping surfaces
%%
if(~mq_control)
    [sSubject, iSubject]                = bst_get('Subject', subID);
    Surfaces                            = sSubject.Surface;
    InnerSkullFile                      = Surfaces(sSubject.iInnerSkull).FileName;
    for i=1:length(CSurfaces)
        CSurface                        = CSurfaces(i);
        if(~isempty(CSurface.name)  && isequal(CSurface.type,'cortex'))
            CortexFile                  = Surfaces(CSurface.iSurface).FileName;
            % [NewTessFile, iSurface]     = tess_force_envelope(CortexFile, InnerSkullFile);
            [NewTessFile, iSurface]     = script_tess_force_envelope(CortexFile, InnerSkullFile, report_path);
            if(~isempty(iSurface)) 
                CSurfaces(i).comment    = strcat(CSurface.comment,'_fix');
                CSurfaces(i).iSurface   = iSurface;
                CSurfaces(i).filename   = NewTessFile;
            end
        end
    end
end
% if(~mq_control)
%     disp("-->> Correcting overlay with InnerSkull");
%     [sSubject, iSubject]                = bst_get('Subject', subID);
%     Surfaces                            = sSubject.Surface;
%     Envelop                             = Surfaces(sSubject.iInnerSkull);
%     Tess                                = Surfaces(sSubject.iCortex);
%     disp(strcat("----> Correcting Tess: ", Tess.Comment, " by Envelop: " , Envelop.Comment));
%     [NewTessFile, iSurface]             = tess_force_envelope_batch(Tess.FileName, Envelop.FileName);
%     if(~isempty(iSurface))
%         for i=1:7
%             if(CSurfaces(i).iCSurface)
%                 CSurfaces(i).comment    = strcat(CSurfaces(i).comment,'_fix');
%                 CSurfaces(i).iSurface   = iSurface;
%                 CSurfaces(i).filename   = NewTessFile;
%             end
%         end
%     end 
%     if(isequal(lower(layer_desc),'bigbrain'))
%         disp("-->> Correcting overlapping vertices between surfaces");
%         for i=1:6            
%             Envelop                     = CSurfaces(i);
%             Tess                        = CSurfaces(i+1);
%             [NewTessFile, iSurface]     = correct_surfaces_overlaping(Envelop.filename,Tess.filename, report_path);
%             if(~isempty(iSurface))
%                 CSurfaces(i+1).comment  = strcat(CSurfaces(i+1).comment,'_fix');
%                 CSurfaces(i+1).iSurface = iSurface;
%                 CSurfaces(i+1).filename = NewTessFile;
%             end
%             
%         end
%     end
% end
% 
% %% Reload subject
% db_reload_subjects(iSubject);

%%
%% Get CSurfaces from Subject
%%
CSurfaces                           = get_CSurfaces_from_sSubject(properties,iSubject);

% %%
% %% Setting the default cortex
% %%
[~, iSubject]   = bst_get('Subject', subID);
for i=1:length(CSurfaces)
    if(~isempty(CSurfaces(i).iCSurface) && CSurfaces(i).iCSurface)
        db_surface_default(iSubject, 'Cortex', CSurfaces(i).iSurface);
        break;
    end
end

%%
%% FSAve Surfaces interpolation
%%
sub_to_FSAve        = [];
% sub_to_FSAve        = get_FSAve_Surfaces_interpolation(properties,subID);

%%
%% Quality control
%%
[sSubject, ~]       = bst_get('Subject', subID);
Surfaces            = sSubject.Surface;
for i=1:length(CSurfaces)
    CSurface        = CSurfaces(i);
    if(~isempty(CSurface.name) && isequal(CSurface.type,'cortex'))
        Cortex      = Surfaces(CSurface.iSurface);
        hFigSurf    = view_surface(Cortex.FileName);
        delete(findobj(hFigSurf, 'Tag', 'ScoutLabel'));
        delete(findobj(hFigSurf, 'Tag', 'ScoutMarker'));
        delete(findobj(hFigSurf, 'Tag', 'ScoutPatch'));
        delete(findobj(hFigSurf, 'Tag', 'ScoutContour'));
        figures     = {hFigSurf, hFigSurf, hFigSurf, hFigSurf};
        fig_out     = merge_figures(Cortex.Comment, strrep(Cortex.Comment,'_','-'), figures,...
            'rows', 2, 'cols', 2,'axis_on',{'off','off','off','off'},...
            'colorbars',{'off','off','off','off'},...
            'view_orient',{[0,90],[1,270],[1,180],[0,360]});
        bst_report('Snapshot',fig_out,[],strcat(Cortex.Comment,' 3D view'), [200,200,900,700]);
        try
            savefig( hFigSurf,fullfile(report_path,strcat(Cortex.Comment,' 3D view.fig')));
        catch
        end
        % Closing figure
        close(fig_out,hFigSurf);
    end
end
if(isequal(lower(layer_desc),'fs_lr') || isequal(lower(layer_desc),'bigbrain'))
    for i=length(CSurfaces):-1:1
        CSurface    = CSurfaces(i);
        if(~isempty(CSurface.name) && isequal(CSurface.type,'cortex'))
            Cortex  = Surfaces(CSurface.iSurface);
            if(~exist('hFigSurfaces','var'))
                hFigSurfaces = script_view_surface(Cortex.FileName, [], [], [],'top');
            else
                hFigSurfaces = script_view_surface(Cortex.FileName, [], [], hFigSurfaces);
            end            
        end
    end
    delete(findobj(hFigSurfaces, 'Tag', 'ScoutLabel'));
    delete(findobj(hFigSurfaces, 'Tag', 'ScoutMarker'));
    delete(findobj(hFigSurfaces, 'Tag', 'ScoutPatch'));
    delete(findobj(hFigSurfaces, 'Tag', 'ScoutContour'));
    figures     = {hFigSurfaces, hFigSurfaces, hFigSurfaces, hFigSurfaces};
    fig_out     = merge_figures("Surfaces cortex 3D view", "Surfaces cortex 3D view", figures,...
        'rows', 2, 'cols', 2,'axis_on',{'off','off','off','off'},...
        'colorbars',{'off','off','off','off'},...
        'view_orient',{[0,90],[1,270],[1,180],[0,360]});
    bst_report('Snapshot',fig_out,[],strcat('Surfaces cortex 3D view'), [200,200,900,700]);
    try
        savefig( hFigSurfaces,fullfile(report_path,strcat('Surfaces cortex 3D view.fig')));
    catch
    end
    % Closing figure
    close(fig_out,hFigSurfaces);
end
if(isempty(errMessage))
    CiftiStorm.Participants(end).Status             = "Processing";
    CiftiStorm.Participants(end).FileInfo           = "";
    CiftiStorm.Participants(end).Process(4).Name    = "Compute_surfaces";
    CiftiStorm.Participants(end).Process(4).Status  = "Completed";
    CiftiStorm.Participants(end).Process(4).Error   = errMessage;
else    
    CiftiStorm.Participants(end).Status             = "Rejected";
    CiftiStorm.Participants(end).FileInfo           = "";
    CiftiStorm.Participants(end).Process(4).Name    = "Compute_surfaces";
    CiftiStorm.Participants(end).Process(4).Status  = "Rejected";
    CiftiStorm.Participants(end).Process(4).Error   = errMessage;     
end

end

