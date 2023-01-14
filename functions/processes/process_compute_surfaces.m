function [errMessage, CSurfaces, sub_to_FSAve] = process_compute_surfaces(properties, subID, CSurfaces)

errMessage = [];

%%
%% Getting params
%%
ProtocolInfo    = bst_get('ProtocolInfo');
anatomy_type    = properties.anatomy_params.anatomy_type.type_list{properties.anatomy_params.anatomy_type.type};
if(isequal(anatomy_type.id,1)); type = 'default';end
if(isequal(anatomy_type.id,2)); type = 'template';end
if(isequal(anatomy_type.id,3)); type = 'individual';end
layer_desc      = anatomy_type.layer_desc.desc;
mq_control      = properties.general_params.bst_config.after_MaQC.run;
nVertCortex     = properties.anatomy_params.surfaces_resolution.nvertcortex;

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
[sSubject, iSubject]        = bst_get('Subject', subID);
for i=1:length(CSurfaces)
    CSurface = CSurfaces(i);
    if(~isempty(CSurface.name) && isequal(CSurface.type,'cortex'))
        comment                 = split(CSurface.comment,'_');
        [NewFile,iSurface,I,J]  = tess_downsize(CSurface.filename, nVertCortex, 'reducepatch');              
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
        CortexMat.Comment       = strcat('Cortex_',comment{2},'_low');        
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
%% Correcting overlapping surfaces
%%
% if(~mq_control)
%     for i=1:length(CSurfaces)
%         CSurface                        = CSurfaces(i);
%         if(~isempty(CSurface.name)  && isequal(CSurface.type,'cortex'))
%             CortexFile                  = Surfaces(CSurface.iSurface).FileName;
%             [NewTessFile, iSurface]     = script_tess_force_envelope(CortexFile, InnerSkullFile, report_path);
%             if(~isempty(iSurface)) 
%                 CSurfaces(i).comment    = strcat(CSurface.comment,'_fix');
%                 CSurfaces(i).iSurface   = iSurface;
%                 CSurfaces(i).filename   = NewTessFile;
%             end
%         end
%     end
% end
disp("-->> Correcting overlapping surfaces");
[sSubject, iSubject]        = bst_get('Subject', subID);
Surfaces                    = sSubject.Surface;
Envelop = Surfaces(sSubject.i);
EnvFile = CSurfaces(8).filename;
disp(strcat("----> Correcting Tess: ", CSurface.comment,...
                " by Envelop: " , Envelop.comment));
if(~mq_control)
    for i=1:7
        CSurface                        = CSurfaces(i);
        if(~isempty(CSurface.name)  && isequal(CSurface.type,'cortex'))
            TessFile                    = CSurface.filename;
            disp(strcat("----> Correcting Tess: ", CSurface.comment,...
                " by Envelop: " , Envelop.comment));
            [NewTessFile, iSurface]     = tess_force_envelope_batch(TessFile, EnvFile);
            if(~isempty(iSurface))
                CSurfaces(i).comment    = strcat(CSurface.comment,'_fix');
                CSurfaces(i).iSurface   = iSurface;
                CSurfaces(i).filename   = NewTessFile;
                EnvFile = NewTessFile;
                Envelop = CSurfaces(i);
            else
                EnvFile = CSurface.filename;
                Envelop = CSurfaces(i);
            end
        end
    end
end

% Load surface file
TessMat = in_tess_bst(TessFile);
TessMat.Faces    = double(TessMat.Faces);
TessMat.Vertices = double(TessMat.Vertices);
% Load envelope file
EnvMat = in_tess_bst(EnvFile);
EnvMat.Faces    = double(EnvMat.Faces);
EnvMat.Vertices = double(EnvMat.Vertices);
% Compute best fitting sphere from envelope
bfs_center = bst_bfs(EnvMat.Vertices);
% Center the two surfaces on the center of the sphere
vCortex = bst_bsxfun(@minus, TessMat.Vertices, bfs_center(:)');
vInner = bst_bsxfun(@minus, EnvMat.Vertices, bfs_center(:)');
% Convert to spherical coordinates
[thCortex, phiCortex, rCortex] = cart2sph(vCortex(:,1), vCortex(:,2), vCortex(:,3));
% Look for points of the cortex inside the innerskull
iVertOut = find(~inpolyhd(vCortex, vInner, EnvMat.Faces));

%% Reload subject
db_reload_subjects(iSubject);

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
sub_to_FSAve        = get_FSAve_Surfaces_interpolation(properties,subID);

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


end

