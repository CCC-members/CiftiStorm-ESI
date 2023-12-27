function [FinalTransf, SensorsVertices, isChanged] = ApplyChannelsTransf(FinalTransf,SensorsVertices, iSelChan, Rnew, Tnew, Rescale)   
    % Mark the channel file as modified
    isChanged = 1;
    % Apply rotation
    if ~isempty(Rnew)
        % Update sensors positions
        SensorsVertices(iSelChan,:) = SensorsVertices(iSelChan,:) * Rnew';
        % Update helmet position
        % if ~isempty(gChanAlign.HelmetVertices)
        %     gChanAlign.HelmetVertices(iSelChan,:) = gChanAlign.HelmetVertices(iSelChan,:) * Rnew';
        % end        
        % Add this transformation to the final transformation
        newTransf = eye(4);
        newTransf(1:3,1:3) = Rnew;
        FinalTransf = newTransf * FinalTransf;
    end
    % Apply Translation
    if ~isempty(Tnew)
        % Update sensors positions
        SensorsVertices(iSelChan,:) = bst_bsxfun(@plus, SensorsVertices(iSelChan,:), Tnew);
        % Update helmet position
        % if ~isempty(gChanAlign.HelmetVertices)
        %     gChanAlign.HelmetVertices(iSelChan,:) = bst_bsxfun(@plus, gChanAlign.HelmetVertices(iSelChan,:), Tnew);
        % end       
        % Add this transformation to the final transformation
        newTransf = eye(4);
        newTransf(1:3,4) = Tnew;
        FinalTransf = newTransf * FinalTransf;
    end
    % Apply rescale
    if ~isempty(Rescale)
        for iDim = 1:3
            if (Rescale(iDim) ~= 0)
                % Resize sensors
                SensorsVertices(iSelChan,iDim) = SensorsVertices(iSelChan,iDim) * Rescale(iDim);  
            end
        end
    end
end

