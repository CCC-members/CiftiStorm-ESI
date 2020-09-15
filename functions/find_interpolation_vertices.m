function [vertices_interp] = find_interpolation_vertices(Sc64k,Sc8k, fsave_inds_template)

subject_inds            = get_inds_co_registration(Sc64k,Sc8k);
vertices_interp  = zeros(length(subject_inds),3);
fprintf(1,'-->> Finding vertices interpolation: %3d%%\n',0);
for i=1:length(fsave_inds_template.ind)
    % Checking
    pivot_ind       = fsave_inds_template.ind(i);
    selected_vertices = [];
    % find neigh vertices in 64k subject surface
    while isempty(selected_vertices)
        [neigh_indexes] = surfpatch(pivot_ind,Sc64k.Faces);
        neigh_inter = intersect(subject_inds,neigh_indexes);
        if(isempty(neigh_inter) || length(neigh_inter)<3)
            pivot_ind = neigh_indexes;
            continue;
        end
        P_64k = Sc64k.Vertices(fsave_inds_template.ind(i),:);
        distances =  zeros(length(neigh_inter),1);
        for j=1:length(neigh_inter)
            P_8k = Sc64k.Vertices(neigh_inter(j),:);
            distances(j) = norm(P_64k - P_8k);
        end
        for j=1:length(neigh_inter)-1
            for k=j+1:length(neigh_inter)
                if(distances(k)< distances(j))
                    temp_d = distances(j);
                    temp_p = neigh_inter(j);
                    distances(j) = distances(k);
                    neigh_inter(j) = neigh_inter(k);
                    distances(k) = temp_d;
                    neigh_inter(k) = temp_p;
                end
            end
        end
        ind_vert1 = find(subject_inds==neigh_inter(1));
        ind_vert2 = find(subject_inds==neigh_inter(2));
        ind_vert3 = find(subject_inds==neigh_inter(3));
        selected_vertices = [ind_vert1 ind_vert2 ind_vert3];
    end
    vertices_interp(i,:) = selected_vertices;
    fprintf(1,'\b\b\b\b%3.0f%%',(i)/(length(fsave_inds_template.ind))*100);
end
%
% fig = figure;
% hold on
% vect = zeros(length(Sc8k.Vertices),1);
% for i=1:length(vertices_interp)
%     vect(subject_inds(1)) = 1;
%
% end
%  patch('Faces',vertices_interp,'Vertices',Sc8k.Vertices,'FaceVertexCData',vect,...
%         'FaceColor','interp','EdgeColor','none','FaceAlpha',.5);
%     figure
%  patch('Faces',Faces,'Vertices',Vertices,'FaceVertexCData',J_new,...
%         'FaceColor','interp','EdgeColor','none','FaceAlpha',.99);
%     figure
%  patch('Faces',Sc8k.Faces,'Vertices',Sc8k.Vertices,'FaceVertexCData',J,...
%         'FaceColor','interp','EdgeColor','none','FaceAlpha',.99);

% close(fig);
end

