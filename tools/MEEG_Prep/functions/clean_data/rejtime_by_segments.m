function newEEG = rejtime_by_segments(EEG,source,varargin)

if(isequal(nargin,1))
    regions = [EEG.TW];
    rej_regions = [];
    for i=1:length(regions)
        if(isempty(rej_regions))
            time_end    = regions(i).start - 1;
            rej_regions = [0 time_end];
        else
            time_start  = regions(i-1).end + 1;
            time_end    = regions(i).start - 1 ;
            rej_regions = [rej_regions; time_start time_end];
        end
    end
    time_start          = regions(end).end + 1;
    time_end            = length(EEG.times) ;
    rej_regions         = [rej_regions; time_start time_end];
    
    newEEG                 = eeg_eegrej(EEG, rej_regions);
    newEEG.RejTime         = rej_regions;
else
    for i=1:2:length(varargin)
        eval([varargin{i} '=  varargin{(i+1)};'])
    end
    events_translate    = get_envents_translate();
    [row, col]          = find( strcmp(events_translate,event)==1);
    event_name          = events_translate{row,end};
    EEG.event_name      = event_name ;
    if(isequal(source,'TW'))
        regions             = [EEG.TW];
    elseif(isequal(source,'derivatives'))
        regions = EEG.derivatives;
        for i=1:length(regions.label)
            TW(i).type = regions.label{i};
            TW(i).start = regions.onset(i)*200;
            TW(i).end = regions.onset(i)*200 + regions.duration(i)*200;
        end
        regions = [TW];
    else
    end
    select_regions      = zeros(1,length(regions));
    for i=1:size(events_translate,2)
        select_regions_part     = strcmp({regions.type}, events_translate{row,i});
        select_regions          = select_regions + select_regions_part;
    end
    regions(find(select_regions==0)) = [];
    if(~isempty(regions))
        rej_regions = [];
        for i=1:length(regions)
            if(isempty(rej_regions))
                time_end    = regions(i).start - 1;
                rej_regions = [1 time_end];
            else
                time_start  = regions(i-1).end + 1;
                time_end    = regions(i).start - 1 ;
                rej_regions = [rej_regions; time_start time_end];
            end
        end
        time_start          = regions(end).end + 1;
        time_end            = length(EEG.times);
        rej_regions         = [rej_regions; time_start time_end];
        
        newEEG              = eeg_eegrej(EEG, rej_regions);
        newEEG.RejTime      = rej_regions;
    else
        newEEG = [];
    end
end
end

