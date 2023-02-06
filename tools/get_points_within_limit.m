function [vert_inds,dist, mins] = get_points_within_limit(S1,S2,limit)
vert_inds   = [];
N1     = size(S1,1);
N2     = size(S2,1);

S1_rs   = reshape(S1,1,N1,3);
S2_rs   = reshape(S2,N2,1,3);

S1_rm   = repmat(S1_rs,N2,1,1);
S2_rm   = repmat(S2_rs,1,N1,1);
distance    = sqrt(sum((S1_rm-S2_rm).^2,3));
mins        = min(distance,[],2);
vert_inds   = find(mins<limit);
dist        = mins(vert_inds);
end
