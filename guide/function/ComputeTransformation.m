function ComputeTransformation(val)
% Get channels to modify
iSelChan = GetSelectedChannels();
% Initialize the transformations that are done
Rnew = [];
Tnew = [];
Rescale = [];
% Selected button
switch (gChanAlign.selectedButton)
    case gChanAlign.hButtonTransX
        Tnew = [val / 5, 0, 0];
    case gChanAlign.hButtonTransY
        Tnew = [0, val / 5, 0];
    case gChanAlign.hButtonTransZ
        Tnew = [0, 0, val / 5];
    case gChanAlign.hButtonRotX
        a = val;
        Rnew = [1,       0,      0;
            0,  cos(a), sin(a);
            0, -sin(a), cos(a)];
    case gChanAlign.hButtonRotY
        a = val;
        Rnew = [cos(a), 0, -sin(a);
            0, 1,       0;
            sin(a), 0,  cos(a)];
    case gChanAlign.hButtonRotZ
        a = val;
        Rnew = [cos(a), -sin(a), 0;
            sin(a),  cos(a), 0;
            0,  0,      1];
    case gChanAlign.hButtonResize
        Rescale = repmat(1 + val, [1 3]);
    case gChanAlign.hButtonResizeX
        Rescale = [1 + val, 0, 0];
    case gChanAlign.hButtonResizeY
        Rescale = [0, 1 + val, 0];
    case gChanAlign.hButtonResizeZ
        Rescale = [0, 0, 1 + val];
    case gChanAlign.hButtonMoveChan
        % Works only iif one channel is selected
        if (length(iSelChan) ~= 1)
            return
        end
        % Select the nearest sensor from the mouse
        [p, v, vi] = select3d(gChanAlign.hSurfacePatch);
        % If sensor index is valid
        if ~isempty(vi) && (vi > 0) && (norm(p' - gChanAlign.SensorsVertices(iSelChan,:)) < 0.01)
            gChanAlign.SensorsVertices(iSelChan,:) = p';
        end
    otherwise
        return;
end
% Apply transformation
ApplyTransformation(iSelChan, Rnew, Tnew, Rescale);
% Update display
UpdatePoints(iSelChan);
end


