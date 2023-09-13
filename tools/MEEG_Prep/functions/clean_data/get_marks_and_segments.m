function [EEGs, select_events] = get_marks_and_segments(EEG,varargin)
% GET_MARKS_AND_SEGMENTS Summary of this function goes here
%   Detailed explanation goes here
if(isequal(nargin,1))
    EEGs = EEG;
end

for i=1:length(varargin)
    eval([inputname(i+1) '= varargin{i};']);
end

select_by   = lower(select_events.by);
events      = select_events.events;
if(isempty(events))
    if(isequal(select_by,'segments'))
        if( isfield(EEG,'TW') && ~isempty(EEG.TW))
            EEGs    = rejtime_by_segments(EEG,'TW');
        elseif(isfield(EEG,'derivatives') && ~isempty(EEG.derivatives))
            EEGs    = rejtime_by_segments(EEG,'derivatives');
        else
            EEGs    = EEG;
        end
    else
        EEGs        = EEG;
    end
else
    countEEG = 1;
    for j=1:length(events)
        event   = events(j);
        newEEG  = EEG;
        if(isequal(select_by,'segments'))
            if(isfield(newEEG,'TW') && ~isempty(newEEG.TW))
                newEEG          = rejtime_by_segments(newEEG,'TW','event',event);
                if(~isempty(newEEG))
                    EEGs(countEEG)  = newEEG;
                    countEEG        = countEEG + 1;
                end                
            elseif(isfield(newEEG,'derivatives') && ~isempty(newEEG.derivatives))
                newEEG              = rejtime_by_segments(newEEG,'derivatives','event',event);
                if(~isempty(newEEG))
                    EEGs(countEEG)  = newEEG;
                    countEEG        = countEEG + 1;
                end
            else
                EEGs =  newEEG;
                select_events.events = [];
                break;
            end
        else
            newEEG                  = rejtime_by_marks(newEEG,'event',event);
            if(~isempty(newEEG))
                EEGs(countEEG)      = newEEG;
                countEEG            = countEEG + 1;
            end
        end
    end
    if(~exist('EEGs','var'))
        EEGs = [];
    end
end
end