function [Rnew, Tnew, Rescale] = ComputeChannelsTransf(action, val)
% Get channels to modify

% Initialize the transformations that are done
Rnew = [];
Tnew = [];
Rescale = [];
% Selected button
switch (action)
    case 'TransX'
        Tnew = [val / 5, 0, 0];
    case 'TransY'
        Tnew = [0, val / 5, 0];
    case 'TransZ'
        Tnew = [0, 0, val / 5];
    case 'RotX'
        a = val;
        Rnew = [1,       0,      0;
            0,  cos(a), sin(a);
            0, -sin(a), cos(a)];
    case 'RotY'
        a = val;
        Rnew = [cos(a), 0, -sin(a);
            0, 1,       0;
            sin(a), 0,  cos(a)];
    case 'RotZ'
        a = val;
        Rnew = [cos(a), -sin(a), 0;
            sin(a),  cos(a), 0;
            0,  0,      1];
    case 'Resize'
        Rescale = repmat(1 + val, [1 3]);
    case 'ResizeX'
        Rescale = [1 + val, 0, 0];
    case 'ResizeY'
        Rescale = [0, 1 + val, 0];
    case 'ResizeZ'
        Rescale = [0, 0, 1 + val];
    case 'MoveChan'
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
end


