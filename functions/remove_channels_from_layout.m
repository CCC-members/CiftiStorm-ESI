function ChannelFile = remove_channels_from_layout(labels,channel_layout,ChannelFile)
from = 1;
limit = length(channel_layout.Channel);
while(from <= limit)
    pos = find(strcmpi(channel_layout.Channel(from).Name, labels), 1);
    if (isempty(pos))
        channel_layout.Channel(from)=[];
        limit = limit - 1;
    else
        from = from + 1;
    end
end
disp('-->> Saving new channel file in tmp folder.')
save(ChannelFile,'-struct','channel_layout');
end

