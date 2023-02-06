function [NewTessFile, iSurface] = correct_surfaces_overlaping(EnvFileName, TessFileName, subject_report_path)

% Load envelope file
EnvMat = in_tess_bst(EnvFileName);
EnvMat.Faces    = double(EnvMat.Faces);
EnvMat.Vertices = double(EnvMat.Vertices);

% Load surface file
TessMat = in_tess_bst(TessFileName);
TessMat.Faces    = double(TessMat.Faces);
TessMat.Vertices = double(TessMat.Vertices);

% Compute best fitting sphere from envelope
bfs_center = bst_bfs(EnvMat.Vertices);
% Center the two surfaces on the center of the sphere
vTess = bst_bsxfun(@minus, TessMat.Vertices, bfs_center(:)');
vEnv = bst_bsxfun(@minus, EnvMat.Vertices, bfs_center(:)');
% % Convert to spherical coordinates
% [thTess, phiTess, rTess] = cart2sph(vTess(:,1), vTess(:,2), vTess(:,3));
% Look for points of the cortex inside the Envelop
iVertOut = find(~inpolyhd(vTess, vEnv, EnvMat.Faces));
if isempty(iVertOut)
    NewTessFile = '';
    iSurface = '';
    return;
end
% Display where the outside points are
hFig_before = view_surface(TessFileName, [], [], 'NewFigure');
panel_surface('SetSurfaceEdges', hFig_before, 1, 1);
line(TessMat.Vertices(iVertOut,1), TessMat.Vertices(iVertOut,2), TessMat.Vertices(iVertOut,3),...
    'LineStyle', 'none', 'Marker', 'o',  'MarkerFaceColor', [1 0 0], 'MarkerSize', 6);
view_surface(EnvFileName, [], [], hFig_before);
figure_3d('SetStandardView', hFig_before, 'top');

newTessVertices = TessMat.Vertices;
% Fixing overlay points
radius                          = -0.5:0.001:-0.3;
while ~isempty(iVertOut)
    % Find new interpolant    
    n_Tess                      = [];
    for r=1:length(radius)
        RTess_p                 = TessMat.Vertices + radius(r) * (EnvMat.Vertices - TessMat.Vertices);
        Snorm                   = norm(RTess_p - TessMat.Vertices, 2);
        n_Tess                  = [n_Tess Snorm];
    end
    [~,ind_Tess]                = min(n_Tess);
    r_Tess                      = radius(ind_Tess);
    V_interp                    = TessMat.Vertices + r_Tess * (EnvMat.Vertices - TessMat.Vertices);
    newTessVertices(iVertOut,:) = V_interp(iVertOut,:);
    vTess                       = bst_bsxfun(@minus, newTessVertices, bfs_center(:)');
    iVertOut                    = find(~inpolyhd(vTess, vEnv, EnvMat.Faces));
    radius(ind_Tess)            = [];
end

% Output structure
NewTessMat = TessMat;
NewTessMat.Vertices = newTessVertices;

% ===== CREATE NEW SURFACE STRUCTURE =====
% Build new filename and Comment
[filepath, filebase, fileext] = bst_fileparts(file_fullpath(TessFileName));
NewTessMat.Comment = [TessMat.Comment, '_fix'];
NewTessFile = file_unique(bst_fullfile(filepath, [filebase, '_fix', fileext]));
% Copy history field
if isfield(TessMat, 'History')
    NewTessMat.History = TessMat.History;
end
% History: Downsample surface
NewTessMat = bst_history('add', NewTessMat, 'fix', sprintf('%d vertices moved the surface envelop.', length(iVertOut)));

% ===== UPDATE DATABASE =====
% Save downsized surface file
bst_save(NewTessFile, NewTessMat, 'v7');
% Make output filename relative
NewTessFile = file_short(NewTessFile);
% Get subject
[sSubject, iSubject] = bst_get('SurfaceFile', TessFileName);
% Register this file in Brainstorm database
iSurface = db_add_surface(iSubject, NewTessFile, NewTessMat.Comment);

% Display modified surface
hFig_after = view_surface(NewTessFile, [], [], 'NewFigure');
panel_surface('SetSurfaceEdges', hFig_after, 1, 1);
view_surface(EnvFileName, [], [], hFig_after);
figure_3d('SetStandardView', hFig_after, 'bottom');


figures     = {hFig_before, hFig_before, hFig_before, hFig_before};
desc = split(TessMat.Comment,"_");
fig_text    =  strcat("Distance correction - ",desc{2});
fig_out     = merge_figures(fig_text, fig_text, figures,...
    'rows', 2, 'cols', 2,'axis_on',{'off','off','off','off'},...
    'colorbars',{'off','off','off','off'},...
    'view_orient',{[0,90],[1,270],[1,180],[0,360]});
bst_report('Snapshot',fig_out,[],'Cortex view before force the vertices inside of InnerSkull.', [200,200,900,700]);
savefig( hFig_before,fullfile(subject_report_path,fig_text));
close(fig_out);
fig_text    =  strcat("Distance corrected - ",desc{2});
figures     = {hFig_after, hFig_after, hFig_after, hFig_after};
fig_out     = merge_figures(fig_text, fig_text, figures,...
    'rows', 2, 'cols', 2,'axis_on',{'off','off','off','off'},...
    'colorbars',{'off','off','off','off'},...
    'view_orient',{[0,90],[1,270],[1,180],[0,360]});
bst_report('Snapshot',fig_out,[],'Cortex view. All cortex vertices are already inside the inner skull.', [200,200,900,700]);
savefig( hFig_after,fullfile(subject_report_path,fig_text));
close(fig_out);

close([hFig_before,hFig_after]);
end


