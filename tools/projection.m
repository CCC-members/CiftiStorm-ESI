matched_rows = [];
for k=1:length(neigh_inter)
    [row,col] = find(Sc8k.Faces==neigh_inter(k));
    matched_rows = [matched_rows; row];
end

% find faces in 8k subject surfaces that include the neigh_indexes
posible_faces = Sc8k.Faces(matched_rows,:,:);
% checking in which face is projected sub_source_ind
P = Sc64k.Vertices(i,:);
for j=1:length(posible_faces)
    posible_face    = posible_faces(j,:);
    P1              = Sc8k.Vertices(posible_face(1),:);
    P2              = Sc8k.Vertices(posible_face(2),:);
    P3              = Sc8k.Vertices(posible_face(3),:);
    % finding projection point onto plane
    M = [P1; P2; P3];
    M = inv(M);
    d = 1;
    n = -M*[1;1;1];
    lambda = ((n'*P')+d)/(n'*n);
    PP = P' - (lambda*n);
    
    %
    Ptri=[P1;P2;P3];
    if f_check_inside_triangle( P1,P2,P3,PP')==1
        selected_vertices
    elseif f_check_inside_triangle( P1,P2,P3,PP') ==0
        continue;
    end
    figure
    hold on
    patch('Vertices',Ptri,'Faces',[1 2 3],'FaceColor',[0 0 0.5],'FaceAlpha',0.5)
    scatter3(PP(1),PP(2),PP(3),100,'Marker','.','MarkerFaceColor',col, 'MarkerEdgeColor','b');
    
    % projected_faces =
end
% find the minimal face area in projected faces
if(~isempty(projected_faces))
    vert1   = Sc64k.Vertices(projected_faces(1,1));
    vert2   = Sc64k.Vertices(projected_faces(1,2));
    vert3   = Sc64k.Vertices(projected_faces(1,2));
    x       = [vert1.Loc(1);vert2.Loc(1);vert3.Loc(1)];
    y       = [vert1.Loc(2);vert2.Loc(2);vert3.Loc(2)];
    z       = [vert1.Loc(3);vert2.Loc(3);vert3.Loc(3)];
    x       = x(:)';
    y       = y(:)';
    z       = z(:)';
    ons     = [1 1 1];
    min_A   = 0.5*sqrt(det([x;y;ons])^2 + det([y;z;ons])^2 + det([z;x;ons])^2);
    minimal_face = projected_faces(1);
    for j=1:length(projected_faces)
        vert1   = Sc64k.Vertices(projected_faces(j,1));
        vert2   = Sc64k.Vertices(projected_faces(j,2));
        vert3   = Sc64k.Vertices(projected_faces(j,2));
        x       = [vert1.Loc(1);vert2.Loc(1);vert3.Loc(1)];
        y       = [vert1.Loc(2);vert2.Loc(2);vert3.Loc(2)];
        z       = [vert1.Loc(3);vert2.Loc(3);vert3.Loc(3)];
        x       = x(:)';
        y       = y(:)';
        z       = z(:)';
        ons     = [1 1 1];
        A       = 0.5*sqrt(det([x;y;ons])^2 + det([y;z;ons])^2 + det([z;x;ons])^2);
        if(A<min_A)
            minimal_face = projected_faces(j);
        end
    end
end