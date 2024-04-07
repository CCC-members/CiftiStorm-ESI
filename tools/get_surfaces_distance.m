function distance = get_surfaces_distance(VS1, VS2)
% VS1 -> Vertices Envelop surface
% S2 -> Vertices Internal surface

N1          = size(VS1,1);
N2          = size(VS2,1);
S1_rs       = reshape(VS1,1,N1,3);
S2_rs       = reshape(VS2,N2,1,3);
S1_rm       = repmat(S1_rs,N2,1,1);
S2_rm       = repmat(S2_rs,1,N1,1);
distance    = sqrt(sum((S1_rm-S2_rm).^2,3));
end
