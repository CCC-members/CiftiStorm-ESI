function [inds] = get_inds_co_registration(high_cortex,low_cortex)

inds = zeros(length(low_cortex.Vertices),1);
x1  = high_cortex.Vertices;
for i = 1:length(low_cortex.Vertices)
    x2     = repmat(low_cortex.Vertices(i,:),length(x1),1);
    dist   = sqrt(sum(abs(x2-x1).^2,2));
    if(~isempty(find(dist == 0)))
        inds(i) = find(dist == 0);
    end
end

end