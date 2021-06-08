function EEG = remove_eeg_channels_by_labels(user_labels, EEG)
data        = EEG.data;
labels      = {EEG.chanlocs.labels}';
from        = 1;
limit       = size(data,1);
while(from <= limit)
    pos = find(strcmpi(labels{from}, user_labels), 1);
    if (isempty(pos))
        data(from,:)    = [];
        labels(from)    = [];
        limit           = limit - 1;        
    else
        from = from + 1;
    end
end
EEG.data                    = data;
rej_indms                   = length(labels)+1:length(EEG.chanlocs);
EEG.chanlocs(rej_indms)     = [];
[EEG.chanlocs.labels]       = labels{:};
EEG.nbchan                  = size(data,1);
end

