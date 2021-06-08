function result = is_match_labels_vs_channel_layout(labels,Channel)
result = true;
for i = 1: length(labels)
    if(isempty(find(strcmpi(labels(i,1), {Channel.Name}), 1)))
        result = false;
        break;
    end
end

end

