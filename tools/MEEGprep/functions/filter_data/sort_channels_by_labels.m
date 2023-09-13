function [channel_layout] = sort_channels_by_labels(labels,channel_layout)
channel_layout_new = channel_layout;
for i = 1:length(channel_layout.Channel)
    pos = find(strcmpi(channel_layout.Channel(i).Name, labels), 1);
    if pos == i
        continue
    else
        channel_layout_new.Channel(pos) = channel_layout.Channel(i);
    end
end
channel_layout = channel_layout_new;
end

