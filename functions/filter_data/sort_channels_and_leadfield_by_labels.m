function [channel_layout,leadfield] = sort_channels_and_leadfield_by_labels(labels,channel_layout,leadfield)
channel_layout_new = channel_layout;
leadfield_new = leadfield;
for i = 1:length(channel_layout.Channel)
    pos = find(strcmpi(channel_layout.Channel(i).Name, labels), 1);
    if pos == i
        continue
    else
        channel_layout_new.Channel(pos) = channel_layout.Channel(i);
        leadfield_new(pos,:) = leadfield(i,:);
    end
end
channel_layout = channel_layout_new;
leadfield = leadfield_new;
end

