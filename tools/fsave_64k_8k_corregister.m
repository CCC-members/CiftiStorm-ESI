corregister_inds = struct;

cortex_8k = load(fullfile('D:\Develop\BrainStorm_Protocol\templates','FSAve_cortex_8k.mat'));
cortex_32k = load(fullfile('D:\Develop\BrainStorm_Protocol\templates','FSAve_cortex_32k.mat'));
ind = zeros(length(cortex_8k.Vertices),1);
x1  = cortex_32k.Vertices;
for i = 1:length(cortex_8k.Vertices)
    x2     = repmat(cortex_8k.Vertices(i,:),length(x1),1);
    dist   = sqrt(sum(abs(x2-x1).^2,2));
    ind(i) = find(dist == 0);
end
corregister_inds.ind  = ind;
