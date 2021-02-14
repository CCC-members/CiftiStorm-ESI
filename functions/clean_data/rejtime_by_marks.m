function newEEG = rejtime_by_marks(EEG,varargin)

for i=1:2:length(varargin)
    eval([varargin{i} '=  varargin{(i+1)};'])
end

urevents = [EEG.urevent];
regions = struct;
for i=1:length(urevents)-1
    regions(i).type     = urevents(i).type;
    regions(i).start    = urevents(i).latency;
    regions(i).end      = urevents(i+1).latency - 1;
end
regions(i+1).type         = urevents(i+1).type;
regions(i+1).start        = urevents(i+1).latency;
regions(i+1).end          = length(EEG.times);

events_translate    = get_envents_translate();
[row, col]          = find( strcmp(events_translate,event)==1);
sufix               = events_translate{row,end};
EEG.setname         = strcat(EEG.setname,'_',sufix) ;
EEG.subID           = strcat(EEG.setname) ;

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
    time_end            = length(EEG.times) ;
    rej_regions         = [rej_regions; time_start time_end];
    
    newEEG              = eeg_eegrej(EEG, rej_regions);
    newEEG.RejTime      = rej_regions;
else
    newEEG = [];
end
end

