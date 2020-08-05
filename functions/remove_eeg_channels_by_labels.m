function [data,hdr] = remove_eeg_channels_by_labels(labels,data,hdr)
from = 1;
limit = size(data,1);
while(from <= limit)
    pos = find(strcmpi(replace(hdr.label(from),'REF',''), labels), 1);
    if (isempty(pos))
        data(from,:)=[];
        hdr.label(from)=[];       
        limit = limit - 1;
    else
        from = from + 1;
    end
end
end

