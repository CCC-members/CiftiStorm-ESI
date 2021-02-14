function EEGs = get_marks_and_segments(EEG,varargin)
% GET_MARKS_AND_SEGMENTS Summary of this function goes here
%   Detailed explanation goes here
if(isequal(nargin,1))
    EEGs = EEG;
end

for i=1:2:length(varargin)
    eval([varargin{i} '=  varargin{(i+1)};'])
end

select_by   = lower(select_events.by);
events      = select_events.events;
if(isempty(events))
    if(isequal(select_by,'segments'))
        if( isfield(EEG,'TW') && ~isempty(EEG.TW))
            EEGs    = rejtime_by_segments(EEG);
        else
            EEGs    = [];
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
            if(~isempty(newEEG.TW))
                newEEG          = rejtime_by_segments(newEEG,'event',event);
                EEGs(countEEG)  = newEEG;
                countEEG        = countEEG + 1;
            end
        else
            newEEG              = rejtime_by_marks(newEEG,'event',event);
            EEGs(countEEG)      = newEEG;
            countEEG            = countEEG + 1;
        end        
    end
end
end

