function [vert_inds,dist, mins] = get_points_within_limit(iSkull,Cortex,limit)
vert_inds   = [];
NiSkull     = size(iSkull,1);
NCortex     = size(Cortex,1);

iSkull_rs   = reshape(iSkull,1,NiSkull,3);
Cortex_rs   = reshape(Cortex,NCortex,1,3);

iSkull_rm   = repmat(iSkull_rs,NCortex,1,1);
Cortex_rm   = repmat(Cortex_rs,1,NiSkull,1);
distance    = sqrt(sum((iSkull_rm-Cortex_rm).^2,3));
mins        = min(distance,[],2);
vert_inds   = find(mins<limit);
dist        = mins(vert_inds);
% for i=1:length(Cortex)
%     distances = zeros(length(iSkull),1);
%     for j=1:length(iSkull)
%         c_vert = Cortex(i,:);
%         iS_vert = iSkull(j,:);
%         distances (j) = norm(iS_vert - c_vert);       
%     end
%     if(min(distances) < limit)
%         vert_inds = [vert_inds ; i];
%     end
% end

end
